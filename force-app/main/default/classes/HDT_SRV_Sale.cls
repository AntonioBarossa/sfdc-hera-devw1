public with sharing class HDT_SRV_Sale {

    private static HDT_UTL_HelperMethods helperMethods = new HDT_UTL_HelperMethods();
    private static HDT_QR_Account accountQuery = new HDT_QR_Account();

    /**
     * Create Sale__c record
     * @param Sale__c sale
     * @return Sale__c sale
     */
    public Sale__c createRecord(Sale__c sale){

        Account account = accountQuery.getRecordById(Sale.Account__c, 'Id, Name, SalesNumber__c');
        sale.Name = 'Vendita Account ' + account.Name + ' ' + (account.SalesNumber__c + 1);

        List<String> fields = helperMethods.getObjAttrList(sale);

        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('Sale__c', String.join(fields, ','), 'create');
        securityAccess.checkSecurityAccess();

        insert sale;

        return sale;
    }
}
