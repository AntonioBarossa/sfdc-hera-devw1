public with sharing class HDT_LC_AccountAlerts {

    @AuraEnabled(cacheable=true)
    public static String getAccountAlerts(Id accountId) {

        HDT_QR_AlertAccountConfiguration queryHandler = new HDT_QR_AlertAccountConfiguration();
        
        List<AlertAccountConfiguration__c> accountAlerts = queryHandler.getRecordsByAccountId(accountId);

        return JSON.serialize(accountAlerts);
    }

    @AuraEnabled(cacheable=true)
    public static String getAvailableRulesFor(String accountCategory) {

        HDT_QR_AlertConfiguration queryHandler = new HDT_QR_AlertConfiguration();
        
        List<AlertConfiguration__c> availableAlerts = queryHandler.getRecordsByAccountCategory(accountCategory);

        return JSON.serialize(availableAlerts);
    }
}
