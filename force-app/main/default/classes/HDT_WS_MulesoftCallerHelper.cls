public without sharing class HDT_WS_MulesoftCallerHelper {

    public static Boolean isMock = true; 

    public static Object createMulesoftCall(String techObj, String requestObj){

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
                ReponseObjGeneric respObjErr = new ReponseObjGeneric();
                respObjErr.success = false;
                respObjErr.message = 'No custom metadata found on Salesforce';
                return respObjErr;
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
            ReponseObjGeneric respObjException = new ReponseObjGeneric();
            respObjException.success = false;
            respObjException.message = String.valueOf(ex.getLineNumber()) + '; ' + ex.getMessage();
            return respObjException;
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
            ReponseObjGeneric r = new ReponseObjGeneric();
            r.success = false;
            r.message = responseCtrl.message;
            return r;
        }

       if(tObj.tabCode.equalsIgnoreCase('EC')){

            ReponseObj resp = new ReponseObj();

            HDT_WRP_AccountStatement.ReturnObj restMessage = (HDT_WRP_AccountStatement.ReturnObj)JSON.deserialize(responseCtrl.body, HDT_WRP_AccountStatement.ReturnObj.class);
            resp.data = new List<HDT_WRP_AccountStatement.DataWrapper>();

            if(restMessage.status != 'success'){
                resp.success = false;
                resp.message += 'Mulesoft side [code: ' + restMessage.errorDetails.code;
                resp.message += ']; Detail: ' + restMessage.errorDetails.message;
                resp.message += '; Additional Info' + restMessage.errorDetails.additionalInfo;
                return resp;
            }

            resp.data = restMessage.data;
            resp.totAmount = 0;

            for(Integer i=0; i<resp.data.size(); i++){
                resp.data[i].id = resp.data[i].idPrimoLivelloSAP;
                if(!String.isBlank(resp.data[i].importo)){
                    resp.totAmount += Decimal.valueOf(resp.data[i].importo);
                }      
            }
            
            resp.success = true;

            return resp;
        } else if(commonTabs.contains(tObj.tabCode)){
            ReponseObjCommonTab resp = new ReponseObjCommonTab();
            HDT_WRP_CommonTab.ReturnObj restMessage = (HDT_WRP_CommonTab.ReturnObj)JSON.deserialize(responseCtrl.body, HDT_WRP_CommonTab.ReturnObj.class);
            resp.data = new List<HDT_WRP_CommonTab.FirstLevelObj>();

            if(restMessage.status != 'success'){
                resp.success = false;
                resp.message += 'Mulesoft side [code: ' + restMessage.errorDetails.code;
                resp.message += ']; Detail: ' + restMessage.errorDetails.message;
                resp.message += '; Additional Info' + restMessage.errorDetails.additionalInfo;
                return resp;
            }

            resp.data = restMessage.data;
            resp.totAmount = 0;

            for(Integer i=0; i<resp.data.size(); i++){
                resp.totAmount += Decimal.valueOf(resp.data[i].importo);            
            }

            resp.success = true;

            return resp;
        } else if(tObj.tabCode.equalsIgnoreCase('paperless')){
            ReponseObjPaperless resp = new ReponseObjPaperless();

            HDT_WRP_Paperless.ReturnObj restMessage = (HDT_WRP_Paperless.ReturnObj)JSON.deserialize(responseCtrl.body, HDT_WRP_Paperless.ReturnObj.class);
            resp.data = new List<HDT_WRP_Paperless.FirstLevelObj>();

            if(restMessage.status != 'success'){
                resp.success = false;
                resp.message += 'Mulesoft side [code: ' + restMessage.errorDetails.code;
                resp.message += ']; Detail: ' + restMessage.errorDetails.message;
                resp.message += '; Additional Info' + restMessage.errorDetails.additionalInfo;
                return resp;
            }

            resp.data = restMessage.data;
           //resp.totAmount = 0;

           //for(Integer i=0; i<resp.data.size(); i++){
           //    resp.totAmount += Decimal.valueOf(resp.data[i].importo);            
           //}

            resp.success = true;

            return resp;
        }

        ReponseObjGeneric respNull = new ReponseObjGeneric();
        respNull.success = false;
        respNull.message = 'No logic developed';
        return respNull;

       //MODIFICATION END HERE
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

    public class ReponseObjGeneric {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
    }

    //RESPONSE OBJ RETURNED TO CONTROLLER FOR ACCOUNT STATEMENT
    public class ReponseObj {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public List<HDT_WRP_AccountStatement.DataWrapper> data;
        @AuraEnabled public Decimal totAmount;
    }

    //RESPONSE OBJ RETURNED TO CONTROLLER FOR Other tab
    public class ReponseObjCommonTab {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public List<HDT_WRP_CommonTab.FirstLevelObj> data;
        @AuraEnabled public Decimal totAmount;
    }

    //RESPONSE OBJ RETURNED TO CONTROLLER FOR Paperless
    public class ReponseObjPaperless {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public List<HDT_WRP_Paperless.FirstLevelObj> data;
    }

    public class TechObj {
        public String requestType;
        public String recordId;
        public String tabCode;
        public String statementType;
    }

}