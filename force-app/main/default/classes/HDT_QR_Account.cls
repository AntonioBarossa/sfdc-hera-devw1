public inherited sharing class HDT_QR_Account {

    /**
     * Get Account by Id
     * @param String id
     * @param String Fields
     * @return Account account
     */
    public Account getRecordById(String id, String fields){
        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('Account', fields, 'read');
        securityAccess.checkSecurityAccess();

        String stringId = String.escapeSingleQuotes(id);
        String stringFields = String.escapeSingleQuotes(fields);

        String query = 'SELECT '+ stringFields +
                ' FROM Account WHERE Id = :stringId LIMIT 1';
        List<Account> accounts = Database.query(query);

        return accounts[0];
    }
}
