/**
 * @description       : Helper for handling Vas notify requests
 * @author            : gabriele.rota@webresults.it
 * @group             : WR
 * @last modified on  : 2021-11-09
 * @last modified by  : gabriele.rota@webresults.it
 * Modifications Log 
 * Ver   Date         Author                        Modification
 * 1.0   2021-10-26   gabriele.rota@webresults.it   Initial Version
**/
@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_UTL_NotifVasHelper {

    private static HDT_QR_Order orderQr = new HDT_QR_Order();
    private static HDT_QR_Case caseQr = new HDT_QR_Case();
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();
    private static HDT_SRV_Case caseSrv = new HDT_SRV_Case();
    
    /**
    * @description Getting SObject related to request (Order/Case/Asset/Subscription)
    * @author gabriele.rota@webresults.it | 2021-07-28 
    * @param requestMap 
    * @param sObjType 
    * @return Map<String, SObject> 
    **/
    public static Map<String,SObject> getRequestSObjects(Map<String, String> requestMap, SObjectType sObjType) {
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
                        AND (Asset.SBQQ__OrderProduct__r.OrderId=:orderId OR Subscription__r.SBQQ__Contract__r.SBQQ__Order__c=:orderId) AND Status NOT IN ('Closed', 'Bozza')
                        WITH SECURITY_ENFORCED LIMIT 1];

                    if (!cases.isEmpty()) {
                        sObjMap.put('Case', cases.get(0));

                        if (cases.get(0).getSobject('Asset')!=null) {
                            sObjMap.put('Asset', cases.get(0).Asset);
                        }
                        if (cases.get(0).getSobject('Subscription__r')!=null) {
                            sObjMap.put('SBQQ__Subscription__c', cases.get(0).Subscription__r);
                        }
                    }
                }
            }
        }

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
    public static HDT_StatoMotoreVas__mdt getStatusMapping(Map<String, String> requestMap) {
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
    public static void mapPhaseAndStatus(HDT_StatoMotoreVas__mdt statusMapping, Map<String,SObject> sObjMap) {
        try {
            mapOrderPhaseAndStatus(statusMapping, sObjMap);
            mapCasePhaseAndStatus(statusMapping, sObjMap);
            mapAssetStatus(statusMapping, sObjMap);
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
    public static void updateRecords(Map<String,SObject> sObjMap) {

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
                System.debug(LoggingLevel.DEBUG, 'Order updated');
                orderSrv.updateRecord(orderToUpdate);
            }

            if (caseToUpdate!=null) {
                System.debug(LoggingLevel.DEBUG, 'Case updated');
                caseSrv.updateRecord(caseToUpdate);
            }

            if (!recordsToUpdate.isEmpty()) {
                System.debug(LoggingLevel.DEBUG, 'Asset/Subscription updated');
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
    public static void populateFieldsFromRequest(Map<String, String> requestMap, SObject targetRecord) {
        targetRecord.put('VasPracticeCode__c', requestMap.get('ID_PRATICA_VAS') );
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
    }

    /**
    * @description Mapping phase/status from Custom Metadata to Order
    * @author gabriele.rota@webresults.it | 2021-10-26 
    * @param statusMapping 
    * @param sObjMap 
    **/
    private static void mapOrderPhaseAndStatus(HDT_StatoMotoreVas__mdt statusMapping, Map<String,SObject> sObjMap) {
        if (sObjMap.containsKey('Order') && !sObjMap.containsKey('Case')) {
            Order currentOrder = (Order)sObjMap.get('Order');
            if (String.isNotBlank(statusMapping.OrderPhase__c)) {
                currentOrder.Phase__c = statusMapping.OrderPhase__c;
            }

            if (String.isNotBlank(statusMapping.OrderStatus__c)) {
                currentOrder.Status = statusMapping.OrderStatus__c;
            }
        }
    }

    /**
    * @description Mapping phase/status from Custom Metadata to Case
    * @author gabriele.rota@webresults.it | 2021-10-26 
    * @param statusMapping 
    * @param sObjMap 
    **/
    private static void mapCasePhaseAndStatus(HDT_StatoMotoreVas__mdt statusMapping, Map<String,SObject> sObjMap) {
        if (sObjMap.containsKey('Case')) {
            Case currentCase = (Case)sObjMap.get('Case');
            if (String.isNotBlank(statusMapping.CasePhase__c)) {
                currentCase.Phase__c = statusMapping.CasePhase__c;
            }

            if (String.isNotBlank(statusMapping.CaseStatus__c)) {
                currentCase.Status = statusMapping.CaseStatus__c;
            }
        }
    }

    /**
    * @description Mapping phase/status from Custom Metadata to Asset
    * @author gabriele.rota@webresults.it | 2021-10-26 
    * @param statusMapping 
    * @param sObjMap 
    **/
    private static void mapAssetStatus(HDT_StatoMotoreVas__mdt statusMapping, Map<String,SObject> sObjMap) {
        if (sObjMap.containsKey('Asset')) {
            Asset currentAsset = (Asset)sObjMap.get('Asset');
            Case currentCase = (Case)sObjMap.get('Case');
            /* Get Assets in bundle */
            List<Asset> bundle = [SELECT DigitalAssetStatus,UsageEndDate FROM Asset WHERE SBQQ__RootAsset__c = :currentAsset.Id WITH SECURITY_ENFORCED];
            bundle.add(currentAsset);
            for(Asset singleAsset : bundle)
            {
                if (String.isNotBlank(statusMapping.AssetStatus__c)) {
                    singleAsset.DigitalAssetStatus = statusMapping.AssetStatus__c;
                    /**@frpanico 16/02/2022
                     * Aggiunto UsageEndDate
                     */
                    if(currentCase.TerminationDate__c != null)
                    {
                        singleAsset.UsageEndDate = currentCase.TerminationDate__c;
                    }
                }
            }
            HDT_UTL_DatabaseService.updateSObject(bundle);
        }
    }
}
