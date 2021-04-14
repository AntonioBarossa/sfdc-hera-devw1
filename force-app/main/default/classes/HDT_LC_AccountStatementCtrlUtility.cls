public inherited sharing class HDT_LC_AccountStatementCtrlUtility {

    public static HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow setHttpDataBodyRow(HDT_WRP_AccountStatement.HDT_WRP_TechObj tObj, HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow dbr){

        try{

            dbr.codiceCliente = tObj.customerCode;
            dbr.tipoTransazione = tObj.tabCode;
            dbr.applicativo = 'ML';
            dbr.tipoEstrattoConto = tObj.statementType;
            dbr.loginId = '0-1';

            switch on tObj.requestType {
                //Tasto Home
                when 'home' {
                    dbr = setDefaultHttpDataBodyRow(tObj, dbr);
                }
                //Tasto Tutte le partite recenti:
                when 'allRecentItems' {
                    Date todayDate = date.today();
                    Date minusDate = todayDate.addYears(-5);
                    dbr.dataFine = convertDateFormat(String.valueOf(todayDate));
                    dbr.dataInizio = convertDateFormat(String.valueOf(minusDate));
                }
                //Tasto Aggrega&Filtri 
                when 'joinFilter' {
                    dbr.dataFine = convertDateFormat(dbr.dataFine);
                    dbr.dataInizio = convertDateFormat(dbr.dataInizio);
                }
                //Tasto Filtri 
                when 'filters' {
                    dbr.applicativo = 'ML';
                    dbr.aggregazione = null;
                    dbr.codiceCliente = tObj.customerCode;
                    dbr.tipoTransazione = tObj.tabCode;
                    dbr.tipoEstrattoConto = 'ORDINARIO';
                    dbr.dataInizio = convertDateFormat(dbr.dataInizio);
                    dbr.dataFine = convertDateFormat(dbr.dataFine);
                    dbr.numeroFattura = null;
                    dbr.numeroBollettino = dbr.numeroBollettino;
                    dbr.contoContrattuale = null;
                    dbr.societa = null;
                    dbr.contratto = null;
                    dbr.loginId = '0-1';
                }
                //Tasto Visualizza Esito
                when 'viewResult' {
                    dbr.applicativo = null;
                    dbr.codiceCliente = null;
                    dbr.tipoEstrattoConto = null;
                    dbr.loginId = null;
                    dbr.tipoTransazione = 'EC4';
                }

            }

            return dbr;

        } catch(Exception e){
            return null;
        }

    }

    public static HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow setDefaultHttpDataBodyRow(HDT_WRP_AccountStatement.HDT_WRP_TechObj tObj, HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow dbr){
        
        switch on tObj.tabCode {
            //Estratto conto
            when 'EC' {
                dbr.aggregazione = null;
                dbr.tipoTransazione = 'EC1';
            }
            //Gestione del credito
            when 'EC1' {

            }
            //Indennizzi
            when 'EC8' {

            }
            //Note Var. IVA
            when 'NVI' {
                dbr.aggregazione = '03';
            }
            //Pagamenti e compensazioni
            when 'EC5' {

            }
            //Paperless
            when 'paperless' {
                dbr.tipoTransazione = null;
                dbr.tipoEstrattoConto = null;
            }
            //Parite non fatturate
            when 'EC7' {

            }
            //Rate
            when 'EC4' {

                

            }
            //Scaduto per riattivazione
            when 'EC9' {

            }
            //Solleciti
            when 'EC6' {

            }
        }
        return dbr;
    }

    public static String convertDateFormat(String inputDate){
        Date tempDate = Date.valueOf(inputDate);
        String day = (tempDate.day()<10) ? '0' + String.valueOf(tempDate.day()) : String.valueOf(tempDate.day());
        String month = (tempDate.month()<10) ? '0'+ String.valueOf(tempDate.month()) : String.valueOf(tempDate.month());
        String year = String.valueOf(tempDate.year());
        return day + '/' + month + '/' + year;
    }

    public static HDT_WS_MulesoftCaller.HDT_WRP_HttpObj setHttpObject(String tabCode, String requestType){

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

        //if(requestType.equalsIgnoreCase('viewResult')){
        //    httpObj.endPoint = 'https://monted-dev-ed.my.salesforce.com/services/apexrest/getAccountStatement/0';
        //}

        return httpObj;
    }

}