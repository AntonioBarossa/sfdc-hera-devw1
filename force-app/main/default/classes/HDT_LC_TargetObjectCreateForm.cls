/**
 * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
 * @date 30/10/2020
 * @description HDT_LC_TargetObjectCreateForm.cls - Class that holds methods that are called from hdtTargetObjectCreateForm.js
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */

public inherited sharing class HDT_LC_TargetObjectCreateForm {
    private static HDT_SRV_ServicePoint serviceSP = new HDT_SRV_ServicePoint();
    private static HDT_SRV_SaleServiceItem saleServiceItemService = new HDT_SRV_SaleServiceItem();
    private static HDT_QR_ServicePoint servicePointQuery = new HDT_QR_ServicePoint();


    @AuraEnabled
    public static List<ServicePoint__c> getServicePoint(String code, String fields) {
        
        serviceSP.checkReadAccess(fields);

        return servicePointQuery.getRecordByCode(code, fields);
    }

    @AuraEnabled
    public static ServicePoint__c createServicePoint(ServicePoint__c servicePoint) {

        try{
            return serviceSP.createRecord(servicePoint);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

    }

    @AuraEnabled
    public static ServicePoint__c confirmServicePoint(ServicePoint__c servicePoint, Sale__c sale){

        try {
            serviceSP.updateRecord(servicePoint);

            if (sale != null) {
                saleServiceItemService.createRecord(servicePoint, sale);
            }
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return servicePoint;
    }
}
