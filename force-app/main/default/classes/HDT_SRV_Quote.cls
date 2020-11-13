public inherited sharing class HDT_SRV_Quote {
    
    private static HDT_UTL_HelperMethods helperMethods = new HDT_UTL_HelperMethods();

    /**
     * Create SBQQ__Quote__c record
     * @param SBQQ__Quote__c quote
     */
    public SBQQ__Quote__c createRecord(SBQQ__Quote__c quote){
        
        List<String> fields = helperMethods.getObjAttrList(quote);

        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('SBQQ__Quote__c', String.join(fields, ','), 'create');
        securityAccess.checkSecurityAccess();

        HDT_UTL_DatabaseService.insertSObject(quote);

        return quote;
    }

    /**
     * Delete single record
     * @param SBQQ__Quote__c.Id
     */
    public void deleteRecord(String quoteId){
        HDT_UTL_DatabaseService.deleteSObject(quoteId);
    }
}
