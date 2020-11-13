public inherited sharing class HDT_QR_Quote {

    /**
     * Get records by Sale__c.Id
     * @param String Sale__c.Id
     * @return List<SBQQ__Quote__c>
     */
    public List<SBQQ__Quote__c> getRecordsBySale(String saleId){

        String fieldsToCheck = 'Name';

        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('SaleServiceItem__c', fieldsToCheck, 'read');
        securityAccess.checkSecurityAccess();

        return [
            SELECT
            Id,
            Name
            FROM SBQQ__Quote__c
            WHERE Vendita__c = :saleId
            WITH SECURITY_ENFORCED
            ORDER BY CreatedDate ASC
        ];
    }
}
