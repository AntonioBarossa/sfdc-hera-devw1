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
        if(servicePoint.MeterStatus__c == 'Bozza'){
            servicePoint.Account__c=null;
        }
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

    @AuraEnabled
public static List<DistributorPointCode__c> getDistributorPointCode(String code,String commodity)
{
    system.debug('HDT_LC_TargetObjectCreateForm getDistributorPointCode START');
    system.debug('code : '+ code);

    HDT_QR_DistributorPointCode queryClass = new HDT_QR_DistributorPointCode();
    List<Map<String,Object>> listCustomDistributorPoint = new List<Map<String,Object>>();
	//Map<String,String> customDistributorPoint = new Map<String,String>();

    String[] splitCode = code.split('');
    system.debug('splitCode : '+ splitCode);
    String finalCode = splitCode[0]+splitCode[1]+splitCode[2]+splitCode[3]+splitCode[4];
    system.debug('finalCode : '+ finalCode);
	List<DistributorPointCode__c> listDistributorPoint = queryClass.getDistributorPointCode(finalCode,commodity);
    system.debug('listDistributorPoint : '+ listDistributorPoint);
    Map<String,Object> row = new Map<String,Object>();
    
    system.debug('HDT_LC_TargetObjectCreateForm getDistributorPointCode END');
    return listDistributorPoint;
}


}