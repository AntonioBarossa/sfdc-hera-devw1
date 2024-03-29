

//THIS CLASS IS OBSOLETE

public without sharing class HDT_WS_MulesoftCallerHelper {
// APEX CLASS NOT IN USE - EVALUATE TO DELETE
    /*
    public static Boolean isMock = true; 

    public static Object createMulesoftCall(String techObj, String requestObj){

        ReponseWrapper wrapObj = new ReponseWrapper();
        Set<String> commonTabs = new Set<String>{'EC1', 'EC9', 'EC4', 'EC5', 'EC6', 'EC7', 'EC8', 'npi'};

        TechObj tObj = (TechObj)JSON.deserialize(techObj, TechObj.class);
        System.debug('# Technical Object: -> ' + tObj);
        System.debug('# RequestObj -> ' + requestObj);

        HDT_WRP_HttpDataBodyRow dbr;
        if(String.isBlank(requestObj)){
            System.debug('# requestObj is null');
            dbr = new HDT_WRP_HttpDataBodyRow();
        } else {
            System.debug('# requestObj is NOT null');
            dbr = (HDT_WRP_HttpDataBodyRow)JSON.deserialize(requestObj, HDT_WRP_HttpDataBodyRow.class);
        }

        try{

            List<HDT_StatementRequest__mdt> mdtList = new List<HDT_StatementRequest__mdt>();
            mdtList = [
                SELECT Aggregation__c, StatementType__c, TransactionType__c, LoginId__c
                FROM HDT_StatementRequest__mdt
                WHERE DeveloperName =: tObj.requestType
            ];

            if(mdtList.size()==0){
                System.debug('# No custom metadata found on Salesforce');
                wrapObj.success = false;
                wrapObj.message = 'No custom metadata found on Salesforce';
                return wrapObj;
            }   

            dbr.applicativo = tObj.requestType;
            dbr.codiceCliente = tObj.recordId;
            dbr.aggregazione = mdtList[0].Aggregation__c;
            dbr.tipoTransazione = tObj.tabCode;
            dbr.tipoEstrattoConto = tObj.statementType;
            dbr.loginId = mdtList[0].LoginId__c;

            switch on tObj.requestType {
                when 'home' {
                    
                }
                when 'allRecentItems' {
                    Date todayDate = date.today();
                    Date minusDate = todayDate.addYears(-5);                    
                    dbr.dataFine = String.valueOf(todayDate.day()) + '/' + String.valueOf(todayDate.month()) + '/' + String.valueOf(todayDate.year());
                    dbr.dataInizio = String.valueOf(minusDate.day()) + '/' + String.valueOf(minusDate.month()) + '/' + String.valueOf(minusDate.year());
                }
                when 'joinFilter' {
                    dbr.dataFine = convertDateFormat(dbr.dataFine);
                    dbr.dataInizio = convertDateFormat(dbr.dataInizio);
                }
                when 'viewResult' {

                }

            }

        } catch (Exception ex){
            System.debug('# Exception #');
            wrapObj.success = false;
            wrapObj.message = String.valueOf(ex.getLineNumber()) + '; ' + ex.getMessage();
            return wrapObj;
        }

        HDT_WS_MulesoftCaller.HttpObj httpObj = setHttpObject(tObj.tabCode);

        if(isMock){
            dbr.applicativo = 'AL';
            dbr.aggregazione = '01';
            dbr.codiceCliente = '1001635149';
            dbr.tipoTransazione = 'EC2';
            dbr.tipoEstrattoConto = 'ORDINARIO';
        }

       //MODIFICATION START HERE
       String body = JSON.serialize(dbr, true);
       HDT_WS_MulesoftCaller.ResponseCtrl responseCtrl = HDT_WS_MulesoftCaller.retrieveDataCtrl(body, httpObj);

       if(!responseCtrl.success){
            wrapObj.success = false;
            wrapObj.message = responseCtrl.message;
            return wrapObj;
        }

        HDT_WRP_MulesoftResponse.ReturnObj restMessage = (HDT_WRP_MulesoftResponse.ReturnObj)JSON.deserialize(responseCtrl.body, HDT_WRP_MulesoftResponse.ReturnObj.class);

        if(restMessage.status != 'success'){
            wrapObj.success = false;
            wrapObj.message = 'Mulesoft side [code: ' + restMessage.errorDetails.code;
            wrapObj.message += ']; Detail: ' + restMessage.errorDetails.message;
            wrapObj.message += '; Additional Info' + restMessage.errorDetails.additionalInfo;
            return wrapObj;
        }

        wrapObj.success = true;
        wrapObj.data = responseCtrl.body;
        return wrapObj;

    }

    public static HDT_WS_MulesoftCaller.HttpObj setHttpObject(String tabCode){

        HDT_WS_MulesoftCaller.HttpObj httpObj = new HDT_WS_MulesoftCaller.HttpObj();
        httpObj.headersMap = new Map<String, String>();

        if(isMock){
            httpObj.endPoint = 'https://hera-salesforce-api-exp-dev.de-c1.cloudhub.io:443/api/v1/service-console/statements/search';
            httpObj.httpMethod = 'POST';

            httpObj.headersMap.put('Authorization', 'Basic NDhmZTUxNjVhNDBjNDlhYTliZjRiM2Q5YmNhMjU1MmY6YTc0YjUwZGJhYWMwNDIxNWJmYmY4OWEyZWUzMTVhODA=');
            httpObj.headersMap.put('Content-Type', 'application/json');
        } else {
            List<HDT_TabConfiguration__mdt> endPointMDT = new List<HDT_TabConfiguration__mdt>();
            endPointMDT = [
                SELECT EndpointService__c
                FROM HDT_TabConfiguration__mdt
                WHERE DeveloperName =: tabCode
            ];
    
            httpObj.endPoint = endPointMDT[0].EndpointService__c;
            httpObj.httpMethod = 'POST';
            httpObj.headersMap.put('Authorization', 'Bearer ' + Label.MockSessionId);
            httpObj.headersMap.put('Content-Type', 'application/json');
        }

        return httpObj;
    }

    public static String convertDateFormat(String inputDate){
        Date tempDate = Date.valueOf(inputDate);
        String day = String.valueOf(tempDate.day());
        String month = String.valueOf(tempDate.month());
        String year = String.valueOf(tempDate.year());
        return day + '/' + month + '/' + year;
    }

    //EXAMPLE OBJ
    public class ReponseWrapper {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public String data;
    }

    public class TechObj {
        public String requestType;
        public String recordId;
        public String tabCode;
        public String statementType;
    }
*/
}