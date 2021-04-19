public with sharing class HDT_LC_AccountAlerts {

    @AuraEnabled(cacheable=true)
    public static String getAccountAlerts(Id accountId) {
        List<AlertAccountConfiguration__c> accountAlerts = [
            SELECT Id, AlertType__c, IsActive__c, IsEmailChannelActive__c, IsSmsChannelActive__c, IsPushChannelActive__c, IsSolChannelActive__c from AlertAccountConfiguration__c where Account__c = :accountId
        ];

        return JSON.serialize(accountAlerts);
    }
}
