public with sharing class HDT_QR_SaleServiceItem {
    
    /**
     * Check for SaleServiceItem record that has a ServicePoint__c with this city and record type
     * @param String ServicePoint__r.SupplyCity__c
     * @param String ServicePoint__r.RecordType.Name
     * @return List<SaleServiceItem__c>
     */
    public List<SaleServiceItem__c> queryExsistingCityAndType(String city, String type){

        String fieldsToCheck = 'Opportunity__c,Quote__c,ServicePoint__c,ServicePoint__r.SupplyCity__c,ServicePoint__r.RecordType.Name';
        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('SaleServiceItem__c', fieldsToCheck, 'read');
        securityAccess.checkSecurityAccess();

        return [SELECT Id,
        Opportunity__c,
        Quote__c,
        ServicePoint__c,
        ServicePoint__r.SupplyCity__c,
        ServicePoint__r.RecordType.Name
        FROM SaleServiceItem__c
        WHERE ServicePoint__r.SupplyCity__c = :city
        AND ServicePoint__r.RecordType.Name = :type];
    }
}
