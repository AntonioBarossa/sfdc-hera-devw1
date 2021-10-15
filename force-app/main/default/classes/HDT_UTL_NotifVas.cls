/**
 * @description       : Handle Vas notify requests after activation/deactivation callouts
 * @author            : gabriele.rota@webresults.it
 * @group             : WR
 * @last modified on  : 29-07-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class HDT_UTL_NotifVas implements wrts_prcgvr.Interfaces_1_0.IApexAction{

    private static HDT_QR_Order orderQr = new HDT_QR_Order();
    private static HDT_QR_Case caseQr = new HDT_QR_Case();
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();
    private static HDT_SRV_Case caseSrv = new HDT_SRV_Case();

    //private static Boolean isDisatt = false;

    /**
    * @description close old discard activities
    * @author costanzo.lomele@webresults.it | 2021-10-05
    * @param args 
    **/
    public Object execute(Object args){
        Map<String, Object> argsMap = (Map<String, Object>) args;
        SObject transition = (SObject) argsMap.get('transition');
        SObject action = (SObject) argsMap.get('action');
        String method = (String) argsMap.get('method');
        SObject sender = (SObject) argsMap.get('sender');

        if(method.equalsIgnoreCase('ClearDiscardActivities')){
            Id parentId = (Id) sender.get('Id');
            wrts_prcgvr__Activity__c fakeActivity = new wrts_prcgvr__Activity__c(DiscardCategory__c = 'Scarto semplice');
            if(Schema.Case.SObjectType == parentId.getSobjectType()) fakeActivity.Case__c = parentId;
            if(Schema.Order.SObjectType == parentId.getSobjectType()) fakeActivity.Order__c = parentId;
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
        system.debug(json.serialize(request));
        for(HDT_WRP_MrrRequest.HDT_WRP_Field field : request.objects.get(0).fields){
            requestMap.put(field.name, field.value);
        }

        Exception processExc;
        
        try {
            system.debug(request.header.fields.get(0).value);
            switch on request.header.fields.get(0).value {
                when 'sales' {
                    isPostSales = false;
                    handleVasActivation(request, requestMap);
                }
                when 'postsales' {
                    isPostSales = true;
                    handleVasDeactivation(request, requestMap);
                }
                when else{
                    throw new HDT_UTL_HeraException('TIPO_OPERAZIONE: Blank or invalid value');
                }
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            processExc = e;
        }

        setResponse(mrrResponseItem, processExc);

        //20/09/2021 - gabriele.rota@webresults.it - Temporary Logging
        Case logCase = new Case();
        logCase.Causal__c = 'CALLIN-Vas.'+request.header.fields.get(0).value;
        logCase.Note__c = JSON.serializePretty(request);
        logCase.Description = RestContext.response.statusCode+'\n'+JSON.serializePretty(mrrResponseItem);
        //insert logCase;
    }

    /**
    * @description Handling Vas activation requests
    * @author gabriele.rota@webresults.it | 2021-07-28 
    * @param request 
    * @param requestMap 
    **/
    private static void handleVasActivation(HDT_WRP_MrrRequest.HDT_WRP_Request request, Map<String, String> requestMap) {
        Map<String,SObject> sObjMap = getRequestSObjects(requestMap, Order.sObjectType);
        HDT_StatoMotoreVas__mdt statusMapping = getStatusMapping(requestMap);

        Order currentOrder = (Order)sObjMap.get('Order');
        populateFieldsFromRequest(requestMap, currentOrder);

        mapPhaseAndStatus(statusMapping, sObjMap);

        updateRecords(sObjMap);
    }

    /**
    * @description Handling Vas deactivation requests
    * @author gabriele.rota@webresults.it | 2021-07-28 
    * @param request 
    * @param requestMap 
    **/
    private static void handleVasDeactivation(HDT_WRP_MrrRequest.HDT_WRP_Request request, Map<String, String> requestMap) {
        Map<String,SObject> sObjMap = getRequestSObjects(requestMap, Case.sObjectType);
        HDT_StatoMotoreVas__mdt statusMapping = getStatusMapping(requestMap);

        Case currentCase = (Case)sObjMap.get('Case');
        populateFieldsFromRequest(requestMap, currentCase);
        
        if (sObjMap.containsKey('Order')) {
            Order currentOrder = (Order)sObjMap.get('Order');
            populateFieldsFromRequest(requestMap, currentOrder);
        }
        
        mapPhaseAndStatus(statusMapping, sObjMap);
        system.debug('ivaste '+json.serialize(sObjMap));
        updateRecords(sObjMap);
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


    /**
    * @description Getting SObject related to request (Order/Case/Asset/Subscription)
    * @author gabriele.rota@webresults.it | 2021-07-28 
    * @param requestMap 
    * @param sObjType 
    * @return Map<String, SObject> 
    **/
    private static Map<String,SObject> getRequestSObjects(Map<String, String> requestMap, SObjectType sObjType) {
        String sObjectKey = requestMap.get('KEY_SERVIZIO');

        Map<String,SObject> sObjMap = new Map<String,SObject>();
        switch on String.valueof(sObjType)  {
            when 'Order' {
                List<Order> orders = orderQr.getRecordByOrderNumber(sObjectKey);
                if (!orders.isEmpty()) {
                    sObjMap.put('Order', orders.get(0));
                }
            }
            when 'Case' {
                List<Order> orders = orderQr.getRecordByOrderNumber(sObjectKey);
                if (!orders.isEmpty()) {
                    sObjMap.put('Order', orders.get(0));

                    Id orderId = orders.get(0).Id;

                    List<Case> cases = [SELECT Asset.Id, Subscription__r.Id FROM Case
                        WHERE RecordType.DeveloperName='HDT_RT_PostSalesVAS' AND Type='Disattivazione VAS'
                        AND (Asset.SBQQ__OrderProduct__r.OrderId=:orderId OR Subscription__r.SBQQ__Contract__r.SBQQ__Order__c=:orderId)
                        WITH SECURITY_ENFORCED LIMIT 1];

                    if (!cases.isEmpty()) {
                        sObjMap.put('Case', cases.get(0));

                        if (cases.get(0).Asset!=null) {
                            sObjMap.put('Asset', cases.get(0).Asset);
                        }
                        if (cases.get(0).Subscription__r!=null) {
                            sObjMap.put('SBQQ__Subscription__c', cases.get(0).Subscription__r);
                        }
                    }
                }
            }
        }

        System.debug('sObjMap.keySet()');
        System.debug(sObjMap.keySet());

        if (sObjMap.isEmpty()) {
            throw new HDT_UTL_HeraException('KEY_SERVIZIO: No records found');
        }

        return sObjMap;
    }

    /**
    * @description Getting status mapping from Custom Metadata
    * @author gabriele.rota@webresults.it | 2021-07-28 
    * @param requestMap 
    * @return HDT_StatoMotoreVas__mdt 
    **/
    private static HDT_StatoMotoreVas__mdt getStatusMapping(Map<String, String> requestMap) {
        String statoPratica = requestMap.get('STATO_PRATICA').replace(' ','_');
        HDT_StatoMotoreVas__mdt statusMapping = HDT_StatoMotoreVas__mdt.getAll().get(statoPratica);

        if (statusMapping==null) {
            throw new HDT_UTL_HeraException('STATO_PRATICA: No status mapping found');
        }

        return statusMapping;
    }

    /**
    * @description Mapping phase/status from Custom Metadata to SObjects
    * @author gabriele.rota@webresults.it | 2021-07-28 
    * @param statusMapping 
    * @param sObjMap 
    **/
    private static void mapPhaseAndStatus(HDT_StatoMotoreVas__mdt statusMapping, Map<String,SObject> sObjMap) {
        try {
            if (sObjMap.containsKey('Order') && !sObjMap.containsKey('Case')) {
                Order currentOrder = (Order)sObjMap.get('Order');

                if (String.isNotBlank(statusMapping.OrderPhase__c)) {
                    currentOrder.Phase__c = statusMapping.OrderPhase__c;
                }

                if (String.isNotBlank(statusMapping.OrderStatus__c)) {
                    currentOrder.Status = statusMapping.OrderStatus__c;
                }
            }
    
            if (sObjMap.containsKey('Case')) {
                Case currentCase = (Case)sObjMap.get('Case');
                if (String.isNotBlank(statusMapping.CasePhase__c)) {
                    currentCase.Phase__c = statusMapping.CasePhase__c;
                }

                if (String.isNotBlank(statusMapping.CaseStatus__c)) {
                    currentCase.Status = statusMapping.CaseStatus__c;
                }
            }
    
            if (sObjMap.containsKey('Asset')) {
                Asset currentAsset = (Asset)sObjMap.get('Asset');
                if (String.isNotBlank(statusMapping.AssetStatus__c)) {
                    currentAsset.DigitalAssetStatus = statusMapping.AssetStatus__c;
                }
            }

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
            System.debug(LoggingLevel.ERROR, e.getStackTraceString());
            throw new HDT_UTL_HeraException('Error while mapping Phase/Status to Objects');
        }
    }

    /**
    * @description Saving SObjects
    * @author gabriele.rota@webresults.it | 2021-07-28 
    * @param sObjMap 
    **/
    private static void updateRecords(Map<String,SObject> sObjMap) {

        Order orderToUpdate;
        Case caseToUpdate;
        List<SObject> recordsToUpdate = new List<SObject>();

        for (String sObjectName:sObjMap.keySet()) {
            switch on sObjectName {
                when 'Order' {
                    orderToUpdate = (Order)sObjMap.get(sObjectName);
                }
                when 'Case' {
                    caseToUpdate = (Case)sObjMap.get(sObjectName);
                }
                when else {
                    SObject record = sObjMap.get(sObjectName);
                    recordsToUpdate.add(record);
                }
            }
        }

        Savepoint sp = Database.setSavepoint();
        try {
            if (orderToUpdate!=null) {
                system.debug('ivaste ord updated');
                orderSrv.updateRecord(orderToUpdate);
            }

            if (caseToUpdate!=null) {
                system.debug('ivaste case updated');
                caseSrv.updateRecord(caseToUpdate);
            }

            if (!recordsToUpdate.isEmpty()) {
                system.debug('ivaste else updated');
                HDT_UTL_DatabaseService.updateSObject(recordsToUpdate);
            }
        } catch (Exception e) {
            Database.rollback(sp);
            System.debug(LoggingLevel.ERROR, e.getMessage());
            System.debug(LoggingLevel.ERROR, e.getStackTraceString());
            throw new HDT_UTL_HeraException('Error while saving records ('+e.getMessage()+')');
        }
    }

    /**
    * @description Mapping request fields to Order/Case record
    * @author gabriele.rota@webresults.it | 2021-07-28 
    * @param requestMap 
    * @param targetRecord 
    **/
    private static void populateFieldsFromRequest(Map<String, String> requestMap, SObject targetRecord) {
        targetRecord.put('VasPracticeCode__c', requestMap.get('ID_PRATICA_VAS') );
        targetRecord.put('VasStatus__c', requestMap.get('STATO_PRATICA') );

        //updating Order.VasSupplierStatus__c only in deactivation process
        if (isPostSales && targetRecord.getSObjectType()==Schema.Order.getSObjectType()) {
            targetRecord.put('VasSupplierStatus__c', requestMap.get('STATO_PRATICA') );
        }

        targetRecord.put('VasStatusDescription__c', requestMap.get('ESITO') );
        targetRecord.put('VasPolicyNumber__c', requestMap.get('NUMERO_POLIZZA') );
        targetRecord.put('OrderODV__c', requestMap.get('ODV') );

        if (String.isNotBlank(requestMap.get('DATA_DECORRENZA'))) {
            targetRecord.put('VasServiceActivationDate__c', Date.valueOf(requestMap.get('DATA_DECORRENZA')) );
        }

        if (String.isNotBlank(requestMap.get('DATA_CESSAZIONE'))) {
            targetRecord.put('TerminationDate__c', Date.valueOf(requestMap.get('DATA_CESSAZIONE')) );
        }
    }
}