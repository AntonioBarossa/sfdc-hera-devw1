/**
 * @description       : Handle Vas notify requests after activation/deactivation callouts
 * @author            : gabriele.rota@webresults.it
 * @group             : WR
 * @last modified on  : 29-07-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@SuppressWarnings('PMD.AvoidDebugStatements, PMD.AvoidGlobalModifier')
global with sharing class HDT_UTL_NotifVas implements wrts_prcgvr.Interfaces_1_0.IApexAction{

    //private static Boolean isDisatt = false;

    /**
    * @description close old discard activities
    * @author costanzo.lomele@webresults.it | 2021-10-05
    * @param args 
    **/
    global Object execute(Object args){
        Map<String, Object> argsMap = (Map<String, Object>) args;
        //SObject transition = (SObject) argsMap.get('transition');
        //SObject action = (SObject) argsMap.get('action');
        String method = (String) argsMap.get('method');
        SObject sender = (SObject) argsMap.get('sender');

        if(method.equalsIgnoreCase('ClearDiscardActivities')){
            Id parentId = (Id) sender.get('Id');
            wrts_prcgvr__Activity__c fakeActivity = new wrts_prcgvr__Activity__c(DiscardCategory__c = 'Scarto semplice');
            if(Schema.Case.SObjectType == parentId.getSobjectType()) {
                fakeActivity.Case__c = parentId;
            }
            if(Schema.Order.SObjectType == parentId.getSobjectType()) {
                fakeActivity.Order__c = parentId;
            }
            HDT_UTL_Scarti.checkForEsitiIntermedi(new List<wrts_prcgvr__Activity__c>{fakeActivity});
        }
        return null;
    }

    /**
    * @description Handling Vas notify requests
    * @author gabriele.rota@webresults.it | 2021-07-28 
    * @param request 
    * @param mrrResponseItem 
    **/
    public static void handleVasNotify(HDT_WRP_MrrRequest.HDT_WRP_Request request, HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseItem) {

        Map<String, String> requestMap = new Map<String, String>();
        System.debug(LoggingLevel.DEBUG, json.serialize(request));
        for(HDT_WRP_MrrRequest.HDT_WRP_Field field : request.objects.get(0).fields){
            requestMap.put(field.name, field.value);
        }

        Exception processExc;
        
        try {
            System.debug(LoggingLevel.DEBUG, request.header.fields.get(0).value);
            switch on request.header.fields.get(0).value {
                when 'sales' {
                    handleVasActivation(request, requestMap);
                }
                when 'postsales' {
                    handleVasDeactivation(request, requestMap);
                }
                when else{
                    throw new HDT_UTL_HeraException('TIPO_OPERAZIONE: Blank or invalid value');
                }
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
            System.debug(LoggingLevel.ERROR, e.getStackTraceString());
            processExc = e;
        }

        setResponse(mrrResponseItem, processExc);

        //20/09/2021 - gabriele.rota@webresults.it - Temporary Logging
        HDT_SRV_ServiceTwentySix.insertCalloutLog('CALLIN-Vas.'+request.header.fields.get(0).value, JSON.serializePretty(request), RestContext.response.statusCode+'\n'+JSON.serializePretty(mrrResponseItem));
    }

    /**
    * @description Handling Vas activation requests
    * @author gabriele.rota@webresults.it | 2021-07-28 
    * @param request 
    * @param requestMap 
    **/
    private static void handleVasActivation(HDT_WRP_MrrRequest.HDT_WRP_Request request, Map<String, String> requestMap) {
        Map<String,SObject> sObjMap = HDT_UTL_NotifVasHelper.getRequestSObjects(requestMap, Order.sObjectType);
        HDT_StatoMotoreVas__mdt statusMapping = HDT_UTL_NotifVasHelper.getStatusMapping(requestMap);

        Order currentOrder = (Order)sObjMap.get('Order');
        HDT_UTL_NotifVasHelper.populateFieldsFromRequest(requestMap, currentOrder);

        HDT_UTL_NotifVasHelper.mapPhaseAndStatus(statusMapping, sObjMap);

        HDT_UTL_NotifVasHelper.updateRecords(sObjMap);
    }

    /**
    * @description Handling Vas deactivation requests
    * @author gabriele.rota@webresults.it | 2021-07-28 
    * @param request 
    * @param requestMap 
    **/
    private static void handleVasDeactivation(HDT_WRP_MrrRequest.HDT_WRP_Request request, Map<String, String> requestMap) {
        Map<String,SObject> sObjMap = HDT_UTL_NotifVasHelper.getRequestSObjects(requestMap, Case.sObjectType);
        HDT_StatoMotoreVas__mdt statusMapping = HDT_UTL_NotifVasHelper.getStatusMapping(requestMap);

        Case currentCase = (Case)sObjMap.get('Case');
        if(currentCase!=null){
            HDT_UTL_NotifVasHelper.populateFieldsFromRequest(requestMap, currentCase);
        }
        if (sObjMap.containsKey('Order')) {
            Order currentOrder = (Order)sObjMap.get('Order');
            HDT_UTL_NotifVasHelper.populateFieldsFromRequest(requestMap, currentOrder);
        }
        
        HDT_UTL_NotifVasHelper.mapPhaseAndStatus(statusMapping, sObjMap);
        HDT_UTL_NotifVasHelper.updateRecords(sObjMap);
    }

    /**
    * @description Setting WS response
    * @author gabriele.rota@webresults.it | 2021-07-28 
    * @param mrrResponseItem 
    * @param processExc 
    **/
    private static void setResponse(HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseItem, Exception processExc) {

        Boolean isSuccess = (processExc==null);
        String outcome = isSuccess?'OK':'KO';
        Integer httpCode = isSuccess?200:400;

        List<HDT_WRP_MrrResponse.HDT_WRP_Field> respFields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>();
        
        HDT_WRP_MrrResponse.HDT_WRP_Field responseField = new HDT_WRP_MrrResponse.HDT_WRP_Field();
        responseField.fieldType = 'TEXT';
        responseField.name = 'ESITO';
        responseField.value = outcome;
        respFields.add(responseField);
        
        if (!isSuccess) {
            HDT_WRP_MrrResponse.HDT_WRP_Field responseFieldError = new HDT_WRP_MrrResponse.HDT_WRP_Field();
            responseFieldError.fieldType = 'TEXT';
            responseFieldError.name = 'ERROR_MESSAGE';
            responseFieldError.value = processExc.getMessage();
            respFields.add(responseFieldError);
        }
        
        HDT_WRP_MrrResponse.HDT_WRP_Object responseObject = new HDT_WRP_MrrResponse.HDT_WRP_Object();
        responseObject.fields = respFields;
        mrrResponseItem.objects.add(responseObject);

        RestContext.response.statusCode = httpCode;
    }
}