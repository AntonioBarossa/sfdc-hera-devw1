/**
 * @description       : Get records from VasSupplierTable__c and copy their fields to related subscription/asset
 * @author            : gabriele.rota@webresults.it
 * @group             : WR
 * @last modified on  : 2021-08-13
 * @last modified by  : gabriele.rota@webresults.it
**/
public with sharing class HDT_BA_VasSupplierTable implements Database.Batchable<SObject>, Schedulable{

    private static final String STATUS_PENDING = 'PENDING';
    private static final String STATUS_SUCCESS = 'SUCCESS';
    private static final String STATUS_ERROR = 'ERROR';

    private static final List<String> FIELDS_TO_COPY = new List<String>{
        'VasPolicyNumber__c', //non c'è su Asset
        'VasSupplierStatus__c', //-> Ordine.VasSupplierStatus__c
        'VasEffectiveDate__c', //non c'è su Asset
        'VasSupplierStatusDetails__c',
        'VasSupplier__c',
        'VasPracticeDate__c',
        'VasShippingDate__c',
        'VasTrackingNr__c',
        'VasDeliveryDate__c',
        'VasServiceActivationDate__c',
        'VasCommunicationProgressive__c',
        'VasCommunicationDate__c',
        'VasReplacementRequestDate__c',
        'VasReplacementDate__c',
        'VasReturnedProductDate__c',
        'VasDisabledDate__c'
    };

    //Asset/Subscription.SBQQ__OrderProduct__c.Order

    /**
    * @description Running batch
    * @author gabriele.rota@webresults.it | 2021-08-13 
    * @param sc 
    **/
    public void execute(SchedulableContext sc){
        Database.executeBatch(this);
    }
    
    /**
    * @description Get records which have not been processed yet
    * @author gabriele.rota@webresults.it | 2021-08-13 
    * @param bc 
    * @return Database.QueryLocator 
    **/
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT '+String.join(FIELDS_TO_COPY, ',')+',VasPracticeCode__c FROM VasSupplierTable__c WHERE Status__c=:STATUS_PENDING';
        return Database.getQueryLocator(query);
    }

    /**
    * @description Copying VasSupplierTable__c recors to subscriptions/assets and saving outcome
    * @author gabriele.rota@webresults.it | 2021-08-13 
    * @param bc 
    * @param vasRecords 
    **/
    public void execute(Database.BatchableContext bc, List<VasSupplierTable__c> vasRecords) {
        Map<String, VasSupplierTable__c> vasRecordsMap = mapVasRecords(vasRecords);
        Set<String> codes = vasRecordsMap.keySet();

        List<SBQQ__Subscription__c> subs = getSubscriptions(codes);
        List<Asset> assets = getAssets(codes);

        copyVasFields(subs, vasRecordsMap);
        copyVasFields(assets, vasRecordsMap);
        
        updateRecords(subs, vasRecordsMap);
        updateRecords(assets, vasRecordsMap);

        //TODO: stato record senza match?

        Database.update(vasRecords, true);
    }

    public void finish(Database.BatchableContext bc) {}


    /**
    * @description Mapping Vas records by VasPracticeCode__c
    * @author gabriele.rota@webresults.it | 2021-08-13 
    * @param vasRecords 
    * @return Map<String, VasSupplierTable__c> 
    **/
    private Map<String, VasSupplierTable__c> mapVasRecords(List<VasSupplierTable__c> vasRecords) {
        Map<String, VasSupplierTable__c> vasRecordsMap = new Map<String, VasSupplierTable__c>();
        for (VasSupplierTable__c vasRecord:vasRecords) {
            String code = vasRecord.VasPracticeCode__c;
            vasRecordsMap.put(code, vasRecord);
        }
        return vasRecordsMap;
    }

    /**
    * @description Getting subscriptions by VasPracticeCode__c
    * @author gabriele.rota@webresults.it | 2021-08-13 
    * @param codes 
    * @return List<SBQQ__Subscription__c> 
    **/
    private List<SBQQ__Subscription__c> getSubscriptions(Set<String> codes) {
        return [SELECT VasPracticeCode__c FROM SBQQ__Subscription__c WHERE VasPracticeCode__c IN :codes WITH SECURITY_ENFORCED];
    }

    /**
    * @description Getting assets by VasPracticeCode__c
    * @author gabriele.rota@webresults.it | 2021-08-13 
    * @param codes 
    * @return List<Asset> 
    **/
    private List<Asset> getAssets(Set<String> codes) {
        return [SELECT VasPracticeCode__c FROM Asset WHERE VasPracticeCode__c IN :codes WITH SECURITY_ENFORCED];
    }

    /**
    * @description Copy fields from vas records to subscriptions/assets
    * @author gabriele.rota@webresults.it | 2021-08-13 
    * @param targets 
    * @param vasRecordsMap 
    **/
    private void copyVasFields(List<SObject> targets, Map<String, VasSupplierTable__c> vasRecordsMap) {
        for (SObject target:targets) {
            String code = (String)target.get('VasPracticeCode__c');
            SObject vasRecord = vasRecordsMap.get(code);

            for (String field:FIELDS_TO_COPY) {
                target.put(field, vasRecord.get(field));
            }
        }
    }

    /**
    * @description Updating subscriptions/assets and saving outcome on Status__c field
    * @author gabriele.rota@webresults.it | 2021-08-13 
    * @param targets 
    * @param vasRecordsMap 
    **/
    private void updateRecords(List<SObject> targets, Map<String, VasSupplierTable__c> vasRecordsMap) {
        Database.SaveResult[] saveResults = Database.update(targets, false);

        for (Integer i=0;i<saveResults.size();i++) {
            Database.SaveResult saveResult = saveResults.get(i);
            String code = (String)targets.get(i).get('VasPracticeCode__c');
            VasSupplierTable__c vasRecord = vasRecordsMap.get(code);

            if (saveResult.isSuccess()) {
                vasRecord.Status__c = STATUS_SUCCESS;
            }
            else {
                vasRecord.Status__c = STATUS_ERROR;
                vasRecord.ErrorDescription__c = getErrorDescription(saveResult);
            }
        }
    }

    /**
    * @description Get error description from SaveResult
    * @author gabriele.rota@webresults.it | 2021-08-20 
    * @param targets 
    * @param vasRecordsMap 
    **/
    private String getErrorDescription(Database.SaveResult saveResult) {
        String errorDesc = '';
        for(Database.Error err : saveResult.getErrors()) {
            errorDesc += err.getStatusCode()+': '+err.getMessage()+' ('+err.getFields()+'); ';
        }
        if (errorDesc.length()>255) {
            errorDesc = errorDesc.substring(0, 255);
        }
        return errorDesc;
    }
}
