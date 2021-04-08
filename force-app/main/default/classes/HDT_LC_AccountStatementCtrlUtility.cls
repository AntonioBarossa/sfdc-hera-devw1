public inherited sharing class HDT_LC_AccountStatementCtrlUtility {

    public static HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow setHttpDataBodyRow(HDT_WRP_AccountStatement.HDT_WRP_TechObj tObj, HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow dbr){

        try{

            switch on tObj.requestType {
                //Tasto Home
                when 'home' {
                    //applicativo
                    //aggregazione
                    //codiceCliente
                    //tipoTransazione
                    //tipoEstrattoConto
                    //loginId
                    //dbr.aggregazione = tObj.aggregation;//01|02|03|04
                    dbr = setDefaultHttpDataBodyRow(tObj, dbr);
                }
                //Tasto Tutte le partite recenti:
                when 'allRecentItems' {
                    //dataFine
                    //dataInizio
                    //applicativo
                    //aggregazione
                    //codiceCliente
                    //tipoTransazione
                    //tipoEstrattoConto
                    //loginId

                    dbr.aggregazione = tObj.aggregation;//01|02|03|04
                    //dbr.tipoTransazione = tObj.tabCode;
                    Date todayDate = date.today();
                    Date minusDate = todayDate.addYears(-5);                    
                    dbr.dataFine = String.valueOf(todayDate.day()) + '/' + String.valueOf(todayDate.month()) + '/' + String.valueOf(todayDate.year());
                    dbr.dataInizio = String.valueOf(minusDate.day()) + '/' + String.valueOf(minusDate.month()) + '/' + String.valueOf(minusDate.year());
                }
                //Tasto Aggrega&Filtri 
                when 'joinFilter' {
                    //numeroFattura
                    //applicativo
                    //aggregazione
                    //codiceCliente
                    //tipoTransazione
                    //tipoEstrattoConto
                    //loginId

                    dbr.dataFine = convertDateFormat(dbr.dataFine);
                    dbr.dataInizio = convertDateFormat(dbr.dataInizio);
                }
                //Tasto Visualizza Esito
                when 'viewResult' {
                    dbr.aggregazione = tObj.aggregation;//01|02|03|04
                    //numeroFattura - ok
                    //applicativo - ok
                    //aggregazione - ok
                    //codiceCliente - ok
                    //tipoTransazione - ok
                    //tipoEstrattoConto - ok
                    //loginId - ok
                }

            }

            dbr.codiceCliente = tObj.customerCode;
            dbr.tipoTransazione = tObj.tabCode;

            dbr.applicativo = 'ML';//possible value -> ML, MT, AL --> Default=ML only for WAVE1
            dbr.tipoEstrattoConto = tObj.statementType;
            dbr.loginId = '0-1';

            return dbr;

        } catch(Exception e){
            return null;
        }

    }

    public static HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow setDefaultHttpDataBodyRow(HDT_WRP_AccountStatement.HDT_WRP_TechObj tObj, HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow dbr){
        
        switch on tObj.tabCode {
            //Estratto conto
            when 'EC' {
                dbr.aggregazione = '03';
            }
            //Gestione del credito
            when 'EC1' {
                //<Applicativo>AL</Applicativo>
                //<TipoEstrattoConto>ORDINARIO</TipoEstrattoConto>  
            }
            //Indennizzi
            when 'EC8' {
                //<Applicativo>AL</Applicativo>
                //<TipoEstrattoConto>ORDINARIO</TipoEstrattoConto>
            }
            //Note Var. IVA
            when 'npi' {
                //<Applicativo>AL</Applicativo>
                //<Aggregazione>03</Aggregazione>
                //<TipoEstrattoConto>NVI</TipoEstrattoConto>
            }
            //Pagamenti e compensazioni
            when 'EC5' {
                //va usato il tasto 'filtri'
                //<Applicativo>AL</Applicativo>
                //<DataInizio>XXXX</DataInizio>
                //<DataFine>XXXX</DataFine>
                //<TipoEstrattoConto>ORDINARIO</TipoEstrattoConto>
            }
            //Paperless
            when 'paperless' {
                //<Applicativo>AL</Applicativo>
            }
            //Parite non fatturate
            when 'EC7' {
                //<Applicativo>AL</Applicativo>
                //<TipoEstrattoConto>ORDINARIO</TipoEstrattoConto>
            }
            //Rate
            when 'EC4' {
                //<Applicativo>AL</Applicativo>
                //<TipoEstrattoConto>ORDINARIO</TipoEstrattoConto>
            }
            //Scaduto per riattivazione
            when 'EC9' {
                //<Applicativo>AL</Applicativo>
                //<TipoEstrattoConto>ORDINARIO</TipoEstrattoConto>
            }
            //Solleciti
            when 'EC6' {
                //<Applicativo>AL</Applicativo>
                //<TipoEstrattoConto>ORDINARIO</TipoEstrattoConto>
            }
        }
        return dbr;
    }

    public static String convertDateFormat(String inputDate){
        Date tempDate = Date.valueOf(inputDate);
        String day = String.valueOf(tempDate.day());
        String month = String.valueOf(tempDate.month());
        String year = String.valueOf(tempDate.year());
        return day + '/' + month + '/' + year;
    }

    public static HDT_WS_MulesoftCaller.HDT_WRP_HttpObj setHttpObject(String tabCode){

        HDT_WS_MulesoftCaller.HDT_WRP_HttpObj httpObj = new HDT_WS_MulesoftCaller.HDT_WRP_HttpObj();
        httpObj.headersMap = new Map<String, String>();

        List<HDT_TabConfiguration__mdt> endPointMDT;
        endPointMDT = HDT_QR_AccountStatement.getTabConfigurationMetaData(endPointMDT, tabCode);

        if(endPointMDT.size()>0 && !String.isEmpty(endPointMDT[0].EndpointService__c)){

            httpObj.endPoint = endPointMDT[0].EndpointService__c;
            httpObj.headersMap.put('Authorization', 'Basic NDhmZTUxNjVhNDBjNDlhYTliZjRiM2Q5YmNhMjU1MmY6YTc0YjUwZGJhYWMwNDIxNWJmYmY4OWEyZWUzMTVhODA=');

            if(endPointMDT[0].UseMockService__c){
                httpObj.endPoint = 'https://monted-dev-ed.my.salesforce.com/services/apexrest/getAccountStatement/0';
                httpObj.headersMap.put('Authorization', 'Bearer ' + Label.MockSessionId);
            }
            httpObj.httpMethod = 'POST';
            httpObj.headersMap.put('Content-Type', 'application/json');
        } else {
            httpObj = null;
        }

        return httpObj;
    }

}