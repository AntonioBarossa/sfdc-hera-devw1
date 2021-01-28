/**
 * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
 * @date 30/10/2020
 * @description HDT_LC_TargetObjectCreateForm.cls - Class that holds methods that are called from hdtTargetObjectCreateForm.js
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */

public inherited sharing class HDT_LC_TargetObjectCreateForm {
    private static HDT_SRV_ServicePoint serviceSp = new HDT_SRV_ServicePoint();
    private static HDT_SRV_SaleServiceItem saleServiceItemService = new HDT_SRV_SaleServiceItem();
    private static HDT_QR_ServicePoint servicePointQuery = new HDT_QR_ServicePoint();


    @AuraEnabled
    public static List<ServicePoint__c> getServicePoint(String code, String fields) {
        
        serviceSp.checkReadAccess(fields);

        return servicePointQuery.getRecordByCode(code, fields);
    }

    @AuraEnabled
    public static ServicePoint__c createServicePoint(ServicePoint__c servicePoint) {

        return serviceSp.createRecord(servicePoint);

    }

    @AuraEnabled
    public static ServicePoint__c confirmServicePoint(ServicePoint__c servicePoint, Sale__c sale){

        serviceSp.updateRecord(servicePoint);

        return servicePoint;
    }
}
