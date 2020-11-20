public inherited sharing class HDT_QR_Quote {

    /**
     * Get records by Sale__c.Id
     * @param String Sale__c.Id
     * @return List<SBQQ__Quote__c>
     */
    public List<SBQQ__Quote__c> getRecordsBySale(String saleId){

        String fieldsToCheck = 'Name,SBQQ__Opportunity2__r.Name,SBQQ__Type__c';

        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('SBQQ__Quote__c', fieldsToCheck, 'read');
        securityAccess.checkSecurityAccess();

        return [
            SELECT
            Id,
            Name,
            SBQQ__Opportunity2__r.Name,
            SBQQ__Type__c
            FROM SBQQ__Quote__c
            WHERE Vendita__c = :saleId
            AND SBQQ__Status__c != 'Rejected'
            WITH SECURITY_ENFORCED
            ORDER BY CreatedDate ASC
        ];
    }

    public SBQQ__Quote__c getRecordById(String quoteId){

        String fieldsToCheck = 'SBQQ__Status__c,SBQQ__Opportunity2__c,SBQQ__Type__c';
        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('SBQQ__Quote__c', fieldsToCheck, 'read');
        securityAccess.checkSecurityAccess();

        List<SBQQ__Quote__c> records = [
            SELECT
            Id,
            SBQQ__Status__c,
            SBQQ__Opportunity2__c,
            SBQQ__Type__c
            FROM SBQQ__Quote__c
            WHERE Id = :quoteId
            AND SBQQ__Status__c != 'Rejected'
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        return records[0];
    }
}
