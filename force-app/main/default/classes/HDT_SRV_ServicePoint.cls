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
    
    /**
     * Init security access check
     * @param String fields to check
     * @param crud Define read, update, create, delete
     */
    public void checkAccessInit(String fields, String crud){
        
        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('ServicePoint__c', fields, crud);
        securityAccess.checkSecurityAccess();
    }

    /**
     * Check if user has read access to fields and throw exception if access not granted
     * @param String fields
     */
    public void checkReadAccess(String fields){
        checkAccessInit(fields, READPERMISSION);
    }

    /**
     * Create ServicePoint__c record
     * @param ServicePoint__c servicePoint
     * @return ServicePoint__c servicePoint
     */
    public ServicePoint__c createRecord(ServicePoint__c servicePoint) {

        List<ServicePoint__c> existingServicePoint = servicePointQuery.getRecordByCode(servicePoint.ServicePointCode__c, 'ServicePointCode__c');

        if (!existingServicePoint.isEmpty()) {
            throw new AuraHandledException('Codice POD/PDR duplicato');
        } else {

            List<String> fields = helperMethods.getObjAttrList(servicePoint);
            
            HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('ServicePoint__c', String.join(fields, ','), 'create');
            securityAccess.checkSecurityAccess();

            HDT_UTL_DatabaseService.insertSObject(servicePoint);
            return servicePoint;
        }
    }

    /**
     * Update ServicePoint__c
     * @param ServicePoint__c servicePoint
     */
    public void updateRecord(ServicePoint__c servicePoint){
        List<String> fields = helperMethods.getObjAttrList(servicePoint);
            
        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('ServicePoint__c', String.join(fields, ','), 'update');
        securityAccess.checkSecurityAccess();

        List<ServicePoint__c> existingServicePoint = servicePointQuery.getRecordById(servicePoint.Id, 'ServicePointCode__c,RecordType.Name');

        if (existingServicePoint[0].ServicePointCode__c != servicePoint.ServicePointCode__c) {
            throw new AuraHandledException('Codice POD/PDR e stato cambiato');
        } else {
            HDT_UTL_DatabaseService.updateSObject(servicePoint);
        }

    }
}
