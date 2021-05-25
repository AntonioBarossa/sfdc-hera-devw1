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
        system.debug('HDT_LC_TargetObjectCreateForm createServicePoint ' + servicePoint );
        return serviceSp.createRecord(servicePoint);

    }

    @AuraEnabled
    public static ServicePoint__c confirmServicePoint(ServicePoint__c servicePoint, Boolean sap){
        system.debug('HDT_LC_TargetObjectCreateForm confirmServicePoint START');
        system.debug('ServicePoint : ' + servicePoint);
        system.debug('isSap = ' +  sap);
        if(sap == false){
            system.debug('entra in updateRecord');
            serviceSp.updateRecord(servicePoint);
        }else{
            system.debug('entra in createRecord');

            serviceSp.createRecord(servicePoint);
        }
        
        system.debug('HDT_LC_TargetObjectCreateForm confirmServicePoint END');
        return servicePoint;
    }
}