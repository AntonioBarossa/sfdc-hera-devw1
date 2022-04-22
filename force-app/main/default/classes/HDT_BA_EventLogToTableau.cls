/**
 * @author Marco Arci (marco.arci@webresults.it)
 * @date 13/04/2021
 * @description HDT_BA_EventLogToTableau chiama tableau per aggiornare i 4 dataset specificati
 *              nella lista 'eventTypes' o per aggiornare il dataset PlatformLimits a seconda
 *              del parametro iniziale
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */
public with sharing class HDT_BA_EventLogToTableau implements Database.Batchable<SObject>, Database.AllowsCallouts {
    //lista dei 4 KPI
    private static final List<String> eventTypes = new List<String>{'ApexUnexpectedException','ExternalODataCallout','ContinuationCallout','Logout'};
    //variabile settata nel costruttore per scegliere quale logica eseguire
    public String whichEvent;
    //Lista dei platform limits da prelevare
    List<String> platformNameKpis = new List<String>{'DataStorageMB','FileStorageMB','DailyBulkApiBatches','HourlyODataCallout','HourlyTimeBasedWorkflow','DailyApiRequests'};

    //costructor per settaggio della variabile whichEvent
    public HDT_BA_EventLogToTableau(String param){
        this.whichEvent = param;
    }

    public Database.QueryLocator start(Database.BatchableContext info){ 
        //query degli EventLog che ci interessano
        if('EventLog'.equalsIgnoreCase(whichEvent)){
            Date eventLogDate = Date.Today()-2;
            String queryString = 'SELECT Id, LogDate, LogFileLength, EventType, Interval, LogFile '+
            'FROM EventLogFile '+
            'WHERE interval = \'Daily\' '+ 
            'AND LogDate =: eventLogDate '+
            'AND EventType IN: eventTypes';
            return Database.getQueryLocator(queryString);
        } else if ('PlatformLimits'.equalsIgnoreCase(whichEvent)){
            //query dei parametri del dataset di platform limits
            String queryString = 'SELECT Id, DeveloperName, DatasetApiName__c, EventType__c, JSONDatasetBase64__c '+
            'FROM HDT_TableauIntegrationSettings__mdt '+
            'WHERE EventType__c = \'platformLimits\'';
            return Database.getQueryLocator(queryString);
        } else {
            return null;
        }
    }

    public void execute(Database.BatchableContext info, List<SObject> scope){
        //logica che gestisce un solo record alla volta quindi la chiamata deve essere effettuata nel seguente
        //modo: database.executebatch(b,1);
        system.debug(scope[0]);
        //controllo per eseguire la logica dei 4 KPI
        if('EventLog'.equalsIgnoreCase(whichEvent)){
            //casting da SObject generico a EventLogFile
            EventLogFile currentScope = (EventLogFile)scope[0];
            //se il file ha una grandezza minore a 9mb = 9000000 bytes allora eseguiamo la logica
            if(currentScope.LogFileLength < 9000000){
                //settaggi variabili per effettuare la chiamata rest per inserire un object 'InsightsExternalData' 
                Map<String,String> headers = new Map<String,String>();
                headers.put('Accept', 'application/json');
                headers.put('Content-Type', 'application/json');
                headers.put('Authorization', 'OAuth ' + UserInfo.getSessionId());

                List<HDT_TableauIntegrationSettings__mdt> tableauIS = [select Id, DeveloperName, DatasetApiName__c, EventType__c, JSONDatasetBase64__c from HDT_TableauIntegrationSettings__mdt where EventType__c =: currentScope.EventType];
                String metadataJsonBase = tableauIS[0].JSONDatasetBase64__c;
                String datasetName = tableauIS[0].DatasetApiName__c;

                system.debug('@@@@ metadataJsonBase: '+metadataJsonBase);
                system.debug('@@@@ datasetName: '+datasetName);

                HTTPResponse getJobRes = RestRequest('https://'+System.URL.getSalesforceBaseUrl().getHost() + '/services/data/v54.0/sobjects/InsightsExternalData', 
                                                    'POST', 
                                                    headers, 
                                                    '{"Format" : "csv","EdgemartAlias" : "'+datasetName+'","Operation" : "Append","Action" : "None", "MetadataJson":"'+metadataJsonBase+'"}');
                system.debug(getJobRes.getBody()+' '+getJobRes.getStatusCode());
                //controllo se il record è stato creato
                if(getJobRes.getStatusCode() == 201){
                    //settaggi variabili per effettuare la chiamata rest per aggiungere un object 'InsightsExternalDataPart' 
                    Map<String,Object> getJobObject = (Map<String,Object>)JSON.deserializeUntyped(getJobRes.getbody());
                    system.debug(getJobObject.get('id'));
                    String jobId = (String)getJobObject.get('id');
                    String DataFile = EncodingUtil.base64Encode(currentScope.LogFile);

                    HTTPResponse putJobRes = RestRequest('https://'+System.URL.getSalesforceBaseUrl().getHost() + '/services/data/v47.0/sobjects/InsightsExternalDataPart', 
                                                        'POST', 
                                                        headers, 
                                                        '{"InsightsExternalDataId" : "'+jobId+'","PartNumber" : "1","DataFile" :"'+dataFile+'" }');
                    //chiamata di tipo 'PATCH' per avviare l'aggiornamento dei dataset su Tableau
                    HTTPResponse patchJobRes = RestRequest('https://'+System.URL.getSalesforceBaseUrl().getHost() + '/services/data/v47.0/sobjects/InsightsExternalData/'+jobId, 
                                                            'PATCH', 
                                                            headers, 
                                                            '{"Action" : "Process"}');
                }
            } else {
                system.debug('notification logic');    //gestire logica notifica
            }
        //controllo per eseguire la logica dei PlatformLimits
        } else if ('PlatformLimits'.equalsIgnoreCase(whichEvent)){
            //casting da SObject generico a HDT_TableauIntegrationSettings__mdt
            HDT_TableauIntegrationSettings__mdt currentScope = (HDT_TableauIntegrationSettings__mdt) scope[0];
            //settaggi variabili per effettuare la chiamata rest per prelevare i Platform Limits'
            Map<String,String> headers = new Map<String,String>();
            headers.put('Authorization', 'OAuth ' + UserInfo.getSessionId());
            HTTPResponse res = RestRequest('https://'+System.URL.getSalesforceBaseUrl().getHost() + '/services/data/v53.0/limits', 
                                            'GET', 
                                            headers, 
                                            null);
            //System.debug(res.getBody());
            //deserializzazione del body e convertito in una mappa per rendere prelevabili come oggetto i diversi platform limts
            Map<String,Object> obj = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
            //mappa per inserire i valori dei soli platform limits desiderati
            Map<String,Object> toConvert = new Map<String,Object>();
            //popolamento della lista
            for(String currentNameKpi : platformNameKpis){
                toConvert.put(currentNameKpi,obj.get(currentNameKpi));
            }
            /*
            toConvert.put('DataStorageMB',obj.get('DataStorageMB'));
            toConvert.put('FileStorageMB',obj.get('FileStorageMB'));
            toConvert.put('DailyBulkApiBatches',obj.get('DailyBulkApiBatches'));
            toConvert.put('HourlyODataCallout',obj.get('HourlyODataCallout'));
            toConvert.put('HourlyTimeBasedWorkflow',obj.get('HourlyTimeBasedWorkflow'));
            toConvert.put('DailyApiRequests',obj.get('DailyApiRequests'));
            */
            //chiamata al metodo CreateCSV che passandogli la prima riga di intestazione del csv crea il csv con la mappa passata come parametro
            //e restituisce il file sottoforma di blob
            Blob BlobDataFile = CreateCSV('"Nome","Max","Rem","TIMESTAMP_DERIVED"',toConvert);
            //conversione del file base64
            String dataFile = EncodingUtil.base64Encode(BlobDataFile);

            //JSON da convertire in Base64:
            //{"fileFormat":{"charsetName":"UTF-8","fieldsDelimitedBy":",","fieldsEnclosedBy":"\"","linesTerminatedBy":"\r\n"},"objects":[{"connector":"CSV","fullyQualifiedName":"platformLimits_csv","label":"platformLimits.csv","name":"platformLimits_csv","fields":[{"fullyQualifiedName":"Name","name":"Name","type":"Text","label":"Name"},{"fullyQualifiedName":"Max","name":"Max","type":"Numeric","label":"Max","precision":18,"defaultValue":"0","scale":0,"format":"0"},{"fullyQualifiedName":"Rem","name":"Rem","type":"Numeric","label":"Rem","precision":18,"defaultValue":"0","scale":0,"format":"0"},{"fullyQualifiedName":"TIMESTAMP_DERIVED","name":"TIMESTAMP_DERIVED","type":"Date","label":"TIMESTAMP_DERIVED","format":"yyyy-MM-dd HH:mm:ss"}]}]}
            //poi inserirla nella const metadataJsonBase
            String metadataJsonBase = currentScope.JSONDatasetBase64__c;

            //pulizia e risettaggio degli header per la nuova chiamata rest per inserire un object 'InsightsExternalData'
            headers.clear();
            headers.put('Accept', 'application/json');
            headers.put('Content-Type', 'application/json');
            headers.put('Authorization', 'OAuth ' + UserInfo.getSessionId());
            HTTPResponse getJobRes = RestRequest('https://'+System.URL.getSalesforceBaseUrl().getHost() + '/services/data/v54.0/sobjects/InsightsExternalData', 
                                                'POST', 
                                                headers, 
                                                '{"Format" : "csv","EdgemartAlias" : "'+currentScope.DatasetApiName__c+'","Operation" : "Append","Action" : "None", "MetadataJson":"'+metadataJsonBase+'"}');

            system.debug(getJobRes.getBody()+' '+getJobRes.getStatusCode());
            //controllo se la chiamata è andata a buon fine
            if(getJobRes.getStatusCode() == 201){
                //prelievo dell'id del 'InsightsExternalData' dalla response per fare la nuova chiamata per inserire un object 'InsightsExternalDataPart'
                Map<String,Object> getJobObject = (Map<String,Object>)JSON.deserializeUntyped(getJobRes.getbody());
                system.debug(getJobObject.get('id'));
                String jobId = (String)getJobObject.get('id');

                headers.clear();
                headers.put('Accept', 'application/json');
                headers.put('Content-Type', 'application/json');
                headers.put('Authorization', 'OAuth ' + UserInfo.getSessionId());
                HTTPResponse putJobRes = RestRequest('https://'+System.URL.getSalesforceBaseUrl().getHost() + '/services/data/v47.0/sobjects/InsightsExternalDataPart', 
                                                    'POST', 
                                                    headers, 
                                                    '{"InsightsExternalDataId" : "'+jobId+'","PartNumber" : "1","DataFile" :"'+dataFile+'" }');

                system.debug(JSON.deserializeUntyped(putJobRes.getbody()));
                //Map<String,Object> putMap = (Map<String,Object>)JSON.deserializeUntyped(putJobRes.getbody());
                // String workId = (String)putMap.get('Id');

                //chiamata per far effettuare l'aggiornamento del dataset a Tableau
                headers.clear();
                headers = new Map<String,String>();
                headers.put('Accept', 'application/json');
                headers.put('Content-Type', 'application/json');
                headers.put('Authorization', 'OAuth ' + UserInfo.getSessionId());
                HTTPResponse patchJobRes = RestRequest('https://'+System.URL.getSalesforceBaseUrl().getHost() + '/services/data/v47.0/sobjects/InsightsExternalData/'+jobId, 
                                                    'PATCH', 
                                                    headers, 
                                                    '{"Action" : "Process"}');
            }
        }
    }

    public void finish(Database.BatchableContext info){ 
        //logica finale
        //invio email/notifica
        system.debug(info);
    }
    
    /**
    * @author Marco Arci (marco.arci@webresults.it)
    * @date 13/04/2021
    * @description HDT_BA_EventLogToTableau .CreateCSV - Generazione Csv
    * @param headers - String - Stringa con la prima riga del CSV (label dei valori in scrittura csv)
    * @param toConvert - Map<String,Object> - mappa dei valori dei platform limits che verranno inseriti nel csv
    * @return Blob - File CSV generato convertito in Blob
    */
    private static Blob CreateCSV(String headers, Map<String,Object> toConvert){	
        Map<String,Object> tempMap = new Map<String,Object>();
        String toCsv = headers+'\n';
        DateTime timeOfLaunch = DateTime.valueOfGMT(system.now().format('yyyy-MM-dd HH:mm:ss'));
        for(String key : toConvert.keySet()){
            toCsv+= '"'+key+'",';
            tempMap = (Map<String,Object>)toConvert.get(key);
            toCsv += tempMap.get('Max')+',';
            toCsv += tempMap.get('Remaining')+',';
            toCsv += timeOfLaunch+',';
            toCsv = toCsv.removeEnd(',');
            toCsv += '\n';
        }
        toCsv = toCsv.removeEnd('\n');
        blob csvBlob = Blob.valueOf(toCsv);
        system.debug(toCsv);
        return csvBlob;
    }

    /**
    * @author Marco Arci (marco.arci@webresults.it)
    * @date 13/04/2021
    * @description HDT_BA_EventLogToTableau .RestRequest - Metodo di appoggio per effettuare le chiamate rest
    * @param endpoint - String - endpoint a cui effettuare la chiamata
    * @param method - String - metodo della chiamata
    * @param headers - Map<String,String> - Mappa conentente le label e i valori degli headers
    * @param body - String - body per effettuare la richiesta (se non necessario passare il valore: null)
    * @return HTTPResponse - ritorna la response ricevuta dalla chiamata
    */
    private static HTTPResponse RestRequest(String endpoint, String method, Map<String,String> headers, String body){	
        Http callout = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod(method);
        for(String currHeaderKey : headers.keySet()){
            req.setHeader(currHeaderKey, headers.get(currHeaderKey));
        }
        if(body != null){
            req.setBody(body);
        }
        HTTPResponse res = callout.send(req);
        return res;
    }

}