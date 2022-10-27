/**
 * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
 * @date 29/10/2020
 * @description HDT_SRV_ServicePoint.cls - Class that holds create,update,delete and other business logic for ServicePoint__c
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */

public inherited sharing class HDT_SRV_ServicePoint {

    private static HDT_UTL_HelperMethods helperMethods = new HDT_UTL_HelperMethods();
    private static HDT_QR_ServicePoint servicePointQuery = new HDT_QR_ServicePoint();
    private static final String READPERMISSION = 'read';
    private static final String CREATEPERMISSION = 'create';
    private static final String UPDATEPERMISSION = 'update';
    
    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Init security access check
     * @param fields to check
     * @param crud Define read, update, create, delete
     */
    public void checkAccessInit(String fields, String crud){
        
        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('ServicePoint__c', fields, crud);
        securityAccess.checkSecurityAccess();
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Check if user has read access to fields and throw exception if access not granted
     * @param fields
     */
    public void checkReadAccess(String fields){
        checkAccessInit(fields, READPERMISSION);
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description Check if current user has create permission on object and specified fields
    * @param fields - Fields to check for access
    */
    public void checkCreateAccess(String fields){
        checkAccessInit(fields, CREATEPERMISSION);
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description Check if current user has update permission on object and specified fields
    * @param fields - Fields to check for access
    */
    public void checkUpdateAccess(String fields){
        checkAccessInit(fields, UPDATEPERMISSION);
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Create ServicePoint__c record
     * @param servicePoint
     * @return ServicePoint__c servicePoint
     */
    public ServicePoint__c createRecord(ServicePoint__c servicePoint) {

        checkReadAccess('ServicePointCode__c');
        checkReadAccess('CommoditySector__c');
        String commodity = servicePoint.CommoditySector__c != null? servicePoint.CommoditySector__c:'';
        List<ServicePoint__c> existingServicePoint = new List<ServicePoint__c>();
        if(String.isNotBlank(commodity) && (commodity.equalsIgnoreCase('Acqua') || commodity.equalsIgnoreCase('Ambiente'))){
            existingServicePoint = new List<ServicePoint__c>();
        }else{
            existingServicePoint = servicePointQuery.getRecordByCode(servicePoint.ServicePointCode__c, 'ServicePointCode__c');
        }
        if (!existingServicePoint.isEmpty() && (servicePoint.PlugPresence__c == null ||(servicePoint.PlugPresence__c != null && servicePoint.PlugPresence__c == 'Si'))) {
            throw new AuraHandledException('Codice POD/PDR duplicato');
        } else {

            // if(servicePoint.PlugPresence__c == 'No'){
            //     servicePoint.ServicePointCode__c = 'IT001E56897542';
            // }
            List<String> fields = helperMethods.getObjAttrList(servicePoint);
            fields.add('MarketOrigin__c');
            checkCreateAccess(String.join(fields, ','));

            servicePoint.MarketOrigin__c = servicePoint.MarketOrigin__c == null && (servicePoint.CommoditySector__c == 'Acqua' || servicePoint.CommoditySector__c == 'Ambiente')? 'Regolamentato':'Libero';

            HDT_UTL_DatabaseService.insertSObject(servicePoint);
            return servicePoint;
        }
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Update ServicePoint__c
     * @param servicePoint
     */
    public void updateRecord(ServicePoint__c servicePoint){

        checkReadAccess('ServicePointCode__c,RecordType.DeveloperName');
        List<ServicePoint__c> existingServicePoint = servicePointQuery.getRecordById(servicePoint.Id, 'ServicePointCode__c,RecordType.DeveloperName');

        if (servicePoint.ServicePointCode__c != null && existingServicePoint[0].ServicePointCode__c != servicePoint.ServicePointCode__c) {
            throw new AuraHandledException('Codice POD/PDR e stato cambiato');
        } else {
            List<String> fields = helperMethods.getObjAttrList(servicePoint);
            checkUpdateAccess(String.join(fields, ','));
            HDT_UTL_DatabaseService.updateSObject(servicePoint);
        }

    }

    /**
     * @description updateRecordRemiCode
     * @param servicePointList
     */
    public void updateRecordRemiCode(List<ServicePoint__c> servicePointList){

 
        HDT_UTL_DatabaseService.updateSObject(servicePointList);
    }
}
