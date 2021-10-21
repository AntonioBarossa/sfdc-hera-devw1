@SuppressWarnings('PMD.AvoidDebugStatements, PMD.AvoidGlobalModifier')
global inherited sharing class HDT_SRV_HerokuPostSalesManager implements wrts_prcgvr.Interfaces_1_0.IApexCalloutAction {

    private static HDT_QR_HerokuPostSalesManager hpsmQr = new HDT_QR_HerokuPostSalesManager();
    private static HDT_UTL_HerokuPostSalesManager hpsmUtl = new HDT_UTL_HerokuPostSalesManager();

    global Object execute(Object args) {

        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse response = new wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse();
        wrts_prcgvr.MRR_1_0.MultiResponse responseMrr  = new wrts_prcgvr.MRR_1_0.MultiResponse();
        wrts_prcgvr__CalloutTemplate__c record = new wrts_prcgvr__CalloutTemplate__c();
        Map<String,Object> arg = new Map<String,Object>();
        List<Case> caseToUpdate = new List<Case>();
        Case currentCase = new Case();
        String ticket;
        String code;

        //fake code

        //Deprecato
        // HDT_WRP_HerokuPostSalesProva.HDT_WRP_MultiResponse mrrResponse = new HDT_WRP_HerokuPostSalesProva.HDT_WRP_MultiResponse();

        //fake code

        List<HDT_WRP_HerokuPostSalesManager> wrpResponses = new List<HDT_WRP_HerokuPostSalesManager>();
        /*
            @Author: Davide Viola - 19/10/2021
            Description: PMD -> Commentata variabile non utilizzata.
        */
        //String outputResult;


        Map<String,Object> argsMap = (Map<String,Object>) args;
        /*
            @Author: Davide Viola - 19/10/2021
            Description: PMD -> Commentate variabili non utilizzate.
        */
        /*SObject transition = (SObject) argsMap.get('transition'); //phase transition
        SObject action = (SObject) argsMap.get('action'); //phase transition detail
        String method = (String) argsMap.get('method');*/
        SObject obj = (SObject) argsMap.get('sender');
        /*
            @Author: Davide Viola - 19/10/2021
            Description: PMD -> Commentata variabile non utilizzata.
        */
        //Object templateMap = argsMap.get('templateMap');
        Map<String,String> parameters = (Map<String,String>)argsMap.get('parameters');
       

        try{
            ticket = (String) obj.get('Id');
            currentCase = (Case) obj;
            code = hpsmUtl.getCodeFromPhaseTransition(currentCase);
            record = hpsmQr.getCalloutTemplateByCode(code);

            wrts_prcgvr.Interfaces_1_0.IEndpointRulesIntegration endpointUtils = 
                (wrts_prcgvr.Interfaces_1_0.IEndpointRulesIntegration) wrts_prcgvr.VersionManager.newClassInstance('EndpointRulesIntegration');
        
            String endpoint = endpointUtils.getEndpoint(new Map<String,Object>{'Case'=>currentCase});
            System.debug(LoggingLevel.DEBUG, 'endpoint ' + endpointUtils.getEndpoint(new Map<String,Object>{'Case'=>currentCase}));
        
            argsMap.put('template', record);
            wrts_prcgvr.Interfaces_1_0.ICalloutTemplateMng templateEngine =
                (wrts_prcgvr.Interfaces_1_0.ICalloutTemplateMng) wrts_prcgvr.VersionManager.newClassInstance('CalloutTemplateMng');

            argsMap = (Map<String,Object>) templateEngine.getTemplate(argsMap);
            argsMap = (Map<String,Object>) templateEngine.applyTemplate(argsMap);
            System.debug(LoggingLevel.DEBUG, 'parameters ' + parameters);
            System.debug(LoggingLevel.DEBUG, 'argsMap ' + argsMap);

            wrts_prcgvr.MRR_1_0.MultiRequest mrrList = (wrts_prcgvr.MRR_1_0.MultiRequest) argsMap.get('multirequest');
            

            arg.put('endpoint', endpoint);
            arg.put('timeout', 12000);
            arg.put('payload',mrrList);
            arg.put('clientType','REST');
            arg.put('contentType','application/json');

            System.debug(LoggingLevel.DEBUG, 'mrrList--> '+mrrList);

            wrts_prcgvr.Interfaces_1_0.ICalloutClient client = (wrts_prcgvr.Interfaces_1_0.ICalloutClient) wrts_prcgvr.VersionManager.newClassInstance('CalloutClient');
            responseMrr = (wrts_prcgvr.MRR_1_0.MultiResponse) client.send(arg);
            /*HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('POST');
            req.setBody(wrts_prcgvr.MRR_1_0.serializeMultiRequest(mrrList));
            Http http = new Http();
            HTTPResponse res = http.send(req);
    
            System.debug(LoggingLevel.DEBUG, 'Body --> '+res.getBody());
            System.debug(res.getStatusCode());
            System.debug(res.getStatus());*/
            
        } catch (Exception ex) {
            //Error Handling
            System.debug(LoggingLevel.DEBUG, 'execute - Exception TypeName: ' + ex.getTypeName());
            System.debug(LoggingLevel.DEBUG, 'execute - Exception Message: ' + ex.getMessage());
            System.debug(LoggingLevel.DEBUG, 'execute - Exception StackTraceString: ' + ex.getStackTraceString());
            
        }

        System.debug(LoggingLevel.DEBUG, 'ResponseMrr --> '+responseMrr);

        wrpResponses = hpsmUtl.manipulateResponse(responseMrr);

        System.debug(LoggingLevel.DEBUG, 'WRPResponse --> '+wrpResponses);
        caseToUpdate = hpsmUtl.handleResponse(wrpResponses, currentCase);
        
        /*
            @Author: Davide Viola - 19/10/2021
            Description: PMD -> Commentata variabile non utilizzata.
        */
        /*if(caseToUpdate != null && caseToUpdate.size() > 0){
            String serializedCase = JSON.serialize(caseToUpdate[0]);
            //updateFuture(serializedCase);
        }*/
        

        response.success = true;
        response.message = 'OK';
        return response;
        
    }
    
    @TestVisible
    private static void updateFuture(String inputString){

        Case c = (Case) JSON.deserialize(inputString, Case.class);

        HDT_UTL_DatabaseService.updateSObject(c);

    }


    public HDT_WRP_MrrResponse.HDT_WRP_Object handleInboundRequest(HDT_WRP_MrrRequest.HDT_WRP_Request request){
        HDT_WRP_MrrResponse.HDT_WRP_Object responseObject = new HDT_WRP_MrrResponse.HDT_WRP_Object();
        HDT_WRP_MrrResponse.HDT_WRP_Field responseField = new HDT_WRP_MrrResponse.HDT_WRP_Field();
        HDT_WRP_MrrResponse.HDT_WRP_Field responseFieldError = new HDT_WRP_MrrResponse.HDT_WRP_Field();
        HDT_WRP_MrrResponse.HDT_WRP_Field responseFieldErrorCode = new HDT_WRP_MrrResponse.HDT_WRP_Field();
        responseObject.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>{responseField};
        List<Case> caseUpdate = new List<Case>();
        Case caseInsert = new Case();
        try {
            HDT_WRP_HerokuPostSalesManager reqWrp = hpsmUtl.manipulateRequest(request);
            switch on request.header.requestType{
                when 'NOTIF_ES'{
                    caseUpdate = hpsmUtl.handleRequest(reqWrp);
                    if(caseUpdate.size() > 0){
                        //HDT_UTL_DatabaseService.updateSObject(caseUpdate);
                        responseObject.fields.addAll(handleNotifEsResponseField(caseUpdate[0]));
                    }
                }
                when 'RICH_PASS'{
                    caseInsert = hpsmUtl.handleRequestRichPass(reqWrp);
                    responseObject.fields.addAll(handleRichPassResponseField(caseInsert));
                    //gestione response field
                }
            }
            responseField.fieldType = 'TEXT';
            responseField.name = 'ESITO';
            responseField.value = 'OK';
            responseFieldError.fieldType = 'TEXT';
            responseFieldError.name = 'ERROR_MESSAGE';
            responseFieldError.value = 'OK';
            responseFieldErrorCode.fieldType = 'TEXT';
            responseFieldErrorCode.name = 'ERROR_CODE';
            responseFieldErrorCode.value = '00';
            responseObject.fields.add(responseField);
            responseObject.fields.add(responseFieldError);
            responseObject.fields.add(responseFieldErrorCode);
            RestContext.response.statusCode = 200;
        } catch (Exception ex) {
		

            responseField.fieldType = 'TEXT';
            responseField.name = 'ESITO';
            responseField.value = 'KO';

            responseFieldError.fieldType = 'TEXT';
            responseFieldError.name = 'ERROR_MESSAGE';
            responseFieldError.value = 'Errore: ' + ex.getMessage();
			
            if (ex instanceof HDT_UTL_HerokuPostSalesManager.HDT_UTL_RichPassException) {
                HDT_UTL_HerokuPostSalesManager.HDT_UTL_RichPassException customEx = (HDT_UTL_HerokuPostSalesManager.HDT_UTL_RichPassException) ex;
                responseFieldErrorCode.fieldType = 'TEXT';
            	responseFieldErrorCode.name = 'ERROR_CODE';
            	responseFieldErrorCode.value = customEx.code;
            }

            responseObject.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>{responseField, responseFieldError, responseFieldErrorCode};
            RestContext.response.statusCode = 400;
        }
        return responseObject;
    }

    @TestVisible
    private List<HDT_WRP_MrrResponse.HDT_WRP_Field> handleRichPassResponseField(Case caseInsert){
        List<HDT_WRP_MrrResponse.HDT_WRP_Field> responseFieldList = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>();
        HDT_WRP_MrrResponse.HDT_WRP_Field rifRich = new HDT_WRP_MrrResponse.HDT_WRP_Field();
        HDT_WRP_MrrResponse.HDT_WRP_Field recordId = new HDT_WRP_MrrResponse.HDT_WRP_Field();
        HDT_WRP_MrrResponse.HDT_WRP_Field rds = new HDT_WRP_MrrResponse.HDT_WRP_Field();
        /*
            @Author: Davide Viola - 19/10/2021
            Description: PMD -> Commentata variabile non utilizzata.
        */
        //HDT_WRP_MrrResponse.HDT_WRP_Field rdo = new HDT_WRP_MrrResponse.HDT_WRP_Field();
        rifRich.fieldType = 'TEXT';
        rifRich.name = 'RIF_RICH';
        rifRich.value =caseInsert.CaseNumber;
        recordId.fieldType = 'TEXT';
        recordId.name = 'RECORD_ID';
        recordId.value =caseInsert.Id;
        rds.fieldType = 'TEXT';
        rds.name = 'PARENT_RIF_RICH';
        System.debug(LoggingLevel.DEBUG, 'ParentCaseNumber -> ' +caseInsert.Parent.CaseNumber);
        rds.value =caseInsert.Parent.CaseNumber;
        responseFieldList = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>{rifRich, recordId,rds};
        return responseFieldList;
    }

    @TestVisible
    private List<HDT_WRP_MrrResponse.HDT_WRP_Field> handleNotifEsResponseField(Case caseUpdate){
        List<HDT_WRP_MrrResponse.HDT_WRP_Field> responseFieldList = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>();
        HDT_WRP_MrrResponse.HDT_WRP_Field rifRich = new HDT_WRP_MrrResponse.HDT_WRP_Field();
        HDT_WRP_MrrResponse.HDT_WRP_Field recordId = new HDT_WRP_MrrResponse.HDT_WRP_Field();
        HDT_WRP_MrrResponse.HDT_WRP_Field herokuCode = new HDT_WRP_MrrResponse.HDT_WRP_Field();
        rifRich.fieldType = 'TEXT';
        rifRich.name = 'RIF_RICH';
        rifRich.value =caseUpdate.CaseNumber;
        recordId.fieldType = 'TEXT';
        recordId.name = 'RECORD_ID';
        recordId.value =caseUpdate.Id;
        herokuCode.fieldType = 'TEXT';
        herokuCode.name = 'DOCUMENTKEY';
        herokuCode.value =caseUpdate.HerokuPracticeCode__c;
        responseFieldList = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>{rifRich, recordId,herokuCode};
        return responseFieldList;
    }
    
}