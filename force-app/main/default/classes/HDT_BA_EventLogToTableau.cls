public with sharing class HDT_BA_EventLogToTableau implements Database.Batchable<SObject>, Database.AllowsCallouts {

    private static final List<String> eventTypes = new List<String>{'ApexUnexpectedException','ExternalODataCallout','ContinuationCallout','Logout'};

    public Database.QueryLocator start(Database.BatchableContext info){ 
        Date eventLogDate = Date.Today()-2;
        String queryString = 'SELECT Id, LogDate, LogFileLength, EventType, Interval, LogFile '+
        'FROM EventLogFile '+
        'WHERE interval = \'Daily\' '+ 
        'AND LogDate =: eventLogDate '+
        'AND EventType IN: eventTypes';
        return Database.getQueryLocator(queryString);
    }

    public void execute(Database.BatchableContext info, List<EventLogFile> scope){
        //logica
        if(scope[0].LogFileLength < 9000000){
            Map<String,String> headers = new Map<String,String>();
            headers.put('Accept', 'application/json');
            headers.put('Content-Type', 'application/json');
            headers.put('Authorization', 'OAuth ' + UserInfo.getSessionId());
           
            HDT_TableauIntegrationSettings__mdt tableauIS = HDT_TableauIntegrationSettings__mdt.getInstance(scope[0].EventType);
            String metadataJsonBase = tableauIS.JSONDatasetBase64__c;
            String datasetName = tableauIS.DatasetApiName__c;

            system.debug('@@@@ metadataJsonBase: '+metadataJsonBase);
            system.debug('@@@@ datasetName: '+datasetName);

            HTTPResponse getJobRes = RestRequest('https://'+System.URL.getSalesforceBaseUrl().getHost() + '/services/data/v54.0/sobjects/InsightsExternalData', 
                                                 'POST', 
                                                 headers, 
                                                 '{"Format" : "csv","EdgemartAlias" : "'+datasetName+'","Operation" : "Append","Action" : "None", "MetadataJson":"'+metadataJsonBase+'"}');
            if(getJobRes.getStatus() == 'OK'){
                Map<String,Object> getJobObject = (Map<String,Object>)JSON.deserializeUntyped(getJobRes.getbody());
                system.debug(getJobObject.get('id'));
                String jobId = (String)getJobObject.get('id');
                String DataFile = EncodingUtil.base64Encode(scope[0].LogFile);

                HTTPResponse putJobRes = RestRequest('https://'+System.URL.getSalesforceBaseUrl().getHost() + '/services/data/v47.0/sobjects/InsightsExternalDataPart', 
                                                    'POST', 
                                                    headers, 
                                                    '{"InsightsExternalDataId" : "'+jobId+'","PartNumber" : "1","DataFile" :"'+dataFile+'" }');

                HTTPResponse patchJobRes = RestRequest('https://'+System.URL.getSalesforceBaseUrl().getHost() + '/services/data/v47.0/sobjects/InsightsExternalData/'+jobId, 
                                                    'PATCH', 
                                                        headers, 
                                                    '{"Action" : "Process"}');
            }
        } else {
            system.debug('notification logic');    //gestire logica notifica
        }
    }

    public void finish(Database.BatchableContext info){ 
        //logica finale
        Map<String,String> headers = new Map<String,String>();
        headers.put('Authorization', 'OAuth ' + UserInfo.getSessionId());
        HTTPResponse res = RestRequest('https://'+System.URL.getSalesforceBaseUrl().getHost() + '/services/data/v53.0/limits', 
                                        'GET', 
                                        headers, 
                                        null);
        //System.debug(res.getBody());
        Map<String,Object> obj = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
        Map<String,Object> toConvert = new Map<String,Object>();
        toConvert.put('DataStorageMB',obj.get('DataStorageMB'));
        toConvert.put('FileStorageMB',obj.get('FileStorageMB'));
        toConvert.put('DailyBulkApiBatches',obj.get('DailyBulkApiBatches'));
        toConvert.put('HourlyODataCallout',obj.get('HourlyODataCallout'));
        toConvert.put('HourlyTimeBasedWorkflow',obj.get('HourlyTimeBasedWorkflow'));
        toConvert.put('DailyApiRequests',obj.get('DailyApiRequests'));
        Blob BlobDataFile = CreateCSV('"Nome","Max","Rem","TIMESTAMP_DERIVED"',toConvert);
        String dataFile = EncodingUtil.base64Encode(BlobDataFile);

        //JSON da convertire in Base64:
        //{"fileFormat":{"charsetName":"UTF-8","fieldsDelimitedBy":",","fieldsEnclosedBy":"\"","linesTerminatedBy":"\r\n"},"objects":[{"connector":"CSV","fullyQualifiedName":"platformLimits_csv","label":"platformLimits.csv","name":"platformLimits_csv","fields":[{"fullyQualifiedName":"Name","name":"Name","type":"Text","label":"Name"},{"fullyQualifiedName":"Max","name":"Max","type":"Numeric","label":"Max","precision":18,"defaultValue":"0","scale":0,"format":"0"},{"fullyQualifiedName":"Rem","name":"Rem","type":"Numeric","label":"Rem","precision":18,"defaultValue":"0","scale":0,"format":"0"},{"fullyQualifiedName":"TIMESTAMP_DERIVED","name":"TIMESTAMP_DERIVED","type":"Date","label":"TIMESTAMP_DERIVED","format":"yyyy-MM-dd HH:mm:ss"}]}]}
        //poi inserirla nella const metadataJsonBase
        final String metadataJsonBase = 'eyJmaWxlRm9ybWF0Ijp7ImNoYXJzZXROYW1lIjoiVVRGLTgiLCJmaWVsZHNEZWxpbWl0ZWRCeSI6IiwiLCJmaWVsZHNFbmNsb3NlZEJ5IjoiXCIiLCJsaW5lc1Rlcm1pbmF0ZWRCeSI6IlxyXG4ifSwib2JqZWN0cyI6W3siY29ubmVjdG9yIjoiQ1NWIiwiZnVsbHlRdWFsaWZpZWROYW1lIjoicGxhdGZvcm1MaW1pdHNfY3N2IiwibGFiZWwiOiJwbGF0Zm9ybUxpbWl0cy5jc3YiLCJuYW1lIjoicGxhdGZvcm1MaW1pdHNfY3N2IiwiZmllbGRzIjpbeyJmdWxseVF1YWxpZmllZE5hbWUiOiJOYW1lIiwibmFtZSI6Ik5hbWUiLCJ0eXBlIjoiVGV4dCIsImxhYmVsIjoiTmFtZSJ9LHsiZnVsbHlRdWFsaWZpZWROYW1lIjoiTWF4IiwibmFtZSI6Ik1heCIsInR5cGUiOiJOdW1lcmljIiwibGFiZWwiOiJNYXgiLCJwcmVjaXNpb24iOjE4LCJkZWZhdWx0VmFsdWUiOiIwIiwic2NhbGUiOjAsImZvcm1hdCI6IjAifSx7ImZ1bGx5UXVhbGlmaWVkTmFtZSI6IlJlbSIsIm5hbWUiOiJSZW0iLCJ0eXBlIjoiTnVtZXJpYyIsImxhYmVsIjoiUmVtIiwicHJlY2lzaW9uIjoxOCwiZGVmYXVsdFZhbHVlIjoiMCIsInNjYWxlIjowLCJmb3JtYXQiOiIwIn0seyJmdWxseVF1YWxpZmllZE5hbWUiOiJUSU1FU1RBTVBfREVSSVZFRCIsIm5hbWUiOiJUSU1FU1RBTVBfREVSSVZFRCIsInR5cGUiOiJEYXRlIiwibGFiZWwiOiJUSU1FU1RBTVBfREVSSVZFRCIsImZvcm1hdCI6Inl5eXktTU0tZGQgSEg6bW06c3MifV19XX0=';

        headers.clear();
        headers = new Map<String,String>();
        headers.put('Accept', 'application/json');
        headers.put('Content-Type', 'application/json');
        headers.put('Authorization', 'OAuth ' + UserInfo.getSessionId());
        HTTPResponse getJobRes = RestRequest('https://'+System.URL.getSalesforceBaseUrl().getHost() + '/services/data/v54.0/sobjects/InsightsExternalData', 
                                             'POST', 
                                             headers, 
                                             '{"Format" : "csv","EdgemartAlias" : "platformLimits","Operation" : "Append","Action" : "None", "MetadataJson":"'+metadataJsonBase+'"}');

        system.debug(getJobRes.getBody());
        if(getJobRes.getStatus() == 'OK'){
            Map<String,Object> getJobObject = (Map<String,Object>)JSON.deserializeUntyped(getJobRes.getbody());
            system.debug(getJobObject.get('id'));
            String jobId = (String)getJobObject.get('id');

            headers.clear();
            headers = new Map<String,String>();
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