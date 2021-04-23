public with sharing class HDT_LC_AccountAlerts {

    @AuraEnabled(cacheable=true)
    public static String getAccountAlerts(Id accountId) {

        HDT_QR_AlertAccountConfiguration queryHandler = new HDT_QR_AlertAccountConfiguration();
        
        List<AlertAccountConfiguration__c> accountAlerts = queryHandler.getRecordsByAccountId(accountId);

        return JSON.serialize(accountAlerts);
    }
}
