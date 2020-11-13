public inherited sharing class HDT_QR_Sale {

    private static HDT_UTL_HelperMethods helperMethods = new HDT_UTL_HelperMethods();
    
    /**
     * Get Sale__c record by id
     * @param String id
     * @param String fields
     * @return Sale__c sale
     */
    public Sale__c getRecordById(String id, String fields){
        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('Sale__c', fields, 'read');
        securityAccess.checkSecurityAccess();

        String stringId = String.escapeSingleQuotes(id);
        String stringFields = String.escapeSingleQuotes(fields);

        String query = 'SELECT '+ stringFields +
                ' FROM Sale__c WHERE Id = :stringId LIMIT 1';
        List<Sale__c> sales = Database.query(query);

        return sales[0];
    }
}
