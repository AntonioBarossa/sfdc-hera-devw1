public inherited sharing class HDT_QR_Opportunity {
    
    /**
     * Counts all records
     * @param String Sale__c.Id
     * @return Integer
     */
    public Integer countRecordsBySale(String saleId){
        return [SELECT count() FROM Opportunity WHERE Vendita__c = :saleId WITH SECURITY_ENFORCED];
    }

    /**
     * Get Opportunities by Sale__c
     * @param String Sale__c.Id
     * @param String fields
     * @return List<Opportunity>
     */
    public List<Opportunity> getRecordsBySale(String saleId, String fields){
        
        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('Opportunity', fields, 'read');
        securityAccess.checkSecurityAccess();

        String stringId = String.escapeSingleQuotes(saleId);
        String stringFields = String.escapeSingleQuotes(fields);

        String stageNameFilter = 'Closed Lost';

        String query = 'SELECT '+ stringFields +
                ' FROM Opportunity WHERE Vendita__c = :stringId AND StageName != :stageNameFilter ORDER BY CreatedDate ASC';
        return Database.query(query);

    }

    public Opportunity getRecordById(String opportunityId){
        String fieldsToCheck = 'StageName';
        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('Opportunity', fieldsToCheck, 'read');
        securityAccess.checkSecurityAccess();

        List<Opportunity> records = [
            SELECT
            Id,
            StageName
            FROM Opportunity
            WHERE Id = :opportunityId
            AND StageName != 'Closed Lost'
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        return records[0];
    }
}
