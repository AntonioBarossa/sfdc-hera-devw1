/**
 * @description       : 
 * @author            : gabriele.rota@webresults.it
 * @group             : WR
 * @last modified on  : 2021-07-27
 * @last modified by  : gabriele.rota@webresults.it
**/
public class HDT_UTL_NotifVas {

    private static HDT_QR_Order orderQr = new HDT_QR_Order();
    private static HDT_QR_Case caseQr = new HDT_QR_Case();
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();
    private static HDT_SRV_Case caseSrv = new HDT_SRV_Case();

    public static void handleVasNotify(HDT_WRP_MrrRequest.HDT_WRP_Request request, HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseItem) {

        Map<String, String> requestMap = new Map<String, String>();
        for(HDT_WRP_MrrRequest.HDT_WRP_Field field : request.objects.get(0).fields){
            requestMap.put(field.name, field.value);
        }

        Exception processExc;
        Savepoint sp = Database.setSavepoint();
        try {
            switch on requestMap.get('TIPO_OPERAZIONE') {
                when 'ATT' {
                    handleVasActivation(request, requestMap);
                }
                when 'DIS' {
                    handleVasDeactivation(request, requestMap);
                }
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            processExc = e;
            Database.rollback(sp);
        }

        setResponse(mrrResponseItem, processExc);
    }
    
    private static void handleVasActivation(HDT_WRP_MrrRequest.HDT_WRP_Request request, Map<String, String> requestMap) {
        Map<String,SObject> sObjMap = getRequestSObjects(requestMap, Order.sObjectType);
        HDT_StatoMotoreVas__mdt statusMapping = getStatusMapping(requestMap);

        Order currentOrder = (Order)sObjMap.get('Order');
        currentOrder.Phase__c = statusMapping.Phase__c;
        populateFieldsFromRequest(requestMap, currentOrder);
        orderSrv.updateRecord(currentOrder);
    }

    private static void handleVasDeactivation(HDT_WRP_MrrRequest.HDT_WRP_Request request, Map<String, String> requestMap) {
        Map<String,SObject> sObjMap = getRequestSObjects(requestMap, Case.sObjectType);
        HDT_StatoMotoreVas__mdt statusMapping = getStatusMapping(requestMap);

        Case currentCase = (Case)sObjMap.get('Case');
        currentCase.Phase__c = statusMapping.Phase__c;
        populateFieldsFromRequest(requestMap, currentCase);
        caseSrv.updateRecord(currentCase);

        if (sObjMap.containsKey('Order')) {
            Order currentOrder = (Order)sObjMap.get('Order');
            currentOrder.Phase__c = statusMapping.Phase__c;
            populateFieldsFromRequest(requestMap, sObjMap.get('Order'));
            orderSrv.updateRecord(currentOrder);
        }

        if (sObjMap.containsKey('Asset')) {
            Asset currentAsset = (Asset)sObjMap.get('Asset');
            currentAsset.Status = statusMapping.Phase__c;
            update currentAsset;
        }

        if (sObjMap.containsKey('SBQQ__Subscription__c')) {
            SBQQ__Subscription__c subs = (SBQQ__Subscription__c)sObjMap.get('SBQQ__Subscription__c');
            //subs.Phase__c = statusMapping.Phase__c;
            update subs;
        }
    }

    private static void setResponse(HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseItem, Exception processExc) {

        Boolean isSuccess = (processExc==null);
        String outcome = isSuccess?'OK':'KO';
        Integer httpCode = isSuccess?200:500;

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
                List<Case> cases = [SELECT Order__r.Id,Asset.Id,Subscription__r.Id FROM Case
                    WHERE CaseNumber = :sObjectKey WITH SECURITY_ENFORCED LIMIT 1];
                if (!cases.isEmpty()) {
                    sObjMap.put('Case', cases.get(0));
                }
                if (cases.get(0).Order__r!=null) {
                    sObjMap.put('Order', cases.get(0).Order__r);
                }
                if (cases.get(0).Asset!=null) {
                    sObjMap.put('Asset', cases.get(0).Asset);
                }
                if (cases.get(0).Subscription__r!=null) {
                    sObjMap.put('SBQQ__Subscription__c', cases.get(0).Subscription__r);
                }
            }
        }

        if (sObjMap.isEmpty()) {
            throw new HDT_UTL_HeraException('KEY_SERVIZIO: No records found');
        }

        return sObjMap;
    }

    private static HDT_StatoMotoreVas__mdt getStatusMapping(Map<String, String> requestMap) {
        String statoPratica = requestMap.get('STATO_PRATICA').replace(' ','_');
        HDT_StatoMotoreVas__mdt statusMapping = HDT_StatoMotoreVas__mdt.getAll().get(statoPratica);

        if (statusMapping==null) {
            throw new HDT_UTL_HeraException('STATO_PRATICA: No status mapping found');
        }

        return statusMapping;
    }

    private static void populateFieldsFromRequest(Map<String, String> requestMap, SObject targetRecord) {
        targetRecord.put('VasPracticeCode__c', requestMap.get('ID_PRATICA_MOTORE_VAS') );
        targetRecord.put('VasStatus__c', requestMap.get('STATO_PRATICA') );
        targetRecord.put('VasStatusDescription__c', requestMap.get('ESITO') );
        targetRecord.put('VasPolicyNumber__c', requestMap.get('NUMERO_POLIZZA') );
        targetRecord.put('OrderODV__c', requestMap.get('ODV') );

        if (String.isNotBlank(requestMap.get('DATA_DECORRENZA'))) {
            targetRecord.put('VasServiceActivationDate__c', Date.valueOf(requestMap.get('DATA_DECORRENZA')) );
        }

        if (String.isNotBlank(requestMap.get('DATA_CESSAZIONE'))) {
            targetRecord.put('TerminationDate__c', Date.valueOf(requestMap.get('DATA_CESSAZIONE')) );
        }

        if (String.isNotBlank(requestMap.get('DISATTIVAZIONE_COMPLETATA'))) {
            targetRecord.put('CompletedDeactivation__c', Boolean.valueOf(requestMap.get('DISATTIVAZIONE_COMPLETATA')) );
        }
    }
}
