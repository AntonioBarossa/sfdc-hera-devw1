public with sharing class HDT_LC_SellingWizardController {

    public static List<String> getObjAttrList(Sale__c obj){

        Map<String,Object> objMap = obj.getPopulatedFieldsAsMap();

        List<String> fields = new List<String>();
        for (String field: objMap.keySet()) {
            if (! (field.equalsIgnoreCase('Id') || field.equalsIgnoreCase('attributes'))){
                fields.add(field); 
            } 
        }

        return fields;
    }

    @AuraEnabled
    public static Account getAccount(String id, String fields){
        
        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('Account', fields, 'read');
        securityAccess.checkSecurityAccess();

        String stringId = String.escapeSingleQuotes(id);
        String stringFields = String.escapeSingleQuotes(fields);

        String query = 'SELECT '+ stringFields +
                ' FROM Account WHERE Id = :stringId LIMIT 1';
        List<Account> accounts = Database.query(query);

        return accounts[0];

    }

    @AuraEnabled
    public static Sale__c getSale(String id, String fields){
        
        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('Sale__c', fields, 'read');
        securityAccess.checkSecurityAccess();

        String stringId = String.escapeSingleQuotes(id);
        String stringFields = String.escapeSingleQuotes(fields);

        String query = 'SELECT '+ stringFields +
                ' FROM Sale__c WHERE Id = :stringId LIMIT 1';
        List<Sale__c> sales = Database.query(query);

        return sales[0];

    }

    @AuraEnabled
    public static Sale__c createSale(Sale__c sale){

        Account account = getAccount(Sale.Account__c, 'Id, Name, SalesNumber__c');
        sale.Name = 'Vendita Account ' + account.Name + ' ' + (account.SalesNumber__c + 1);

        List<String> fields = getObjAttrList(sale);
        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('Sale__c', String.join(fields, ','), 'create');
        securityAccess.checkSecurityAccess();
        insert sale;

        system.debug('create sale: ' + sale);

        Sale__c retrievedSale = getSale(sale.id, 'Id,Name,Account__r.Name,Account__r.FiscalCode__c,CreatedDate');

        return retrievedSale;
    }

}
