public with sharing class HDT_SRV_ServicePoint {

    private static HDT_UTL_HelperMethods helperMethods = new HDT_UTL_HelperMethods();
    
    /**
     * Update ServicePoint__c
     * @param ServicePoint__c servicePoint
     */
    public void updateRecord(ServicePoint__c servicePoint){
        List<String> fields = helperMethods.getObjAttrList(servicePoint);
            
        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('ServicePoint__c', String.join(fields, ','), 'update');
        securityAccess.checkSecurityAccess();

        update servicePoint;

    }
}
