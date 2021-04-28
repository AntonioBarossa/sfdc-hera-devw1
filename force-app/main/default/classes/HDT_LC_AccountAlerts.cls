public with sharing class HDT_LC_AccountAlerts {

    @AuraEnabled
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

    @AuraEnabled
    public static Boolean addAlertToAccount(String alertRule, Id accountId) {
        System.debug('Going to add alert rule ' + alertRule + ' to Account with Id: ' + accountId);
        AlertConfiguration__c alertRuleObj = (AlertConfiguration__c) JSON.deserialize(alertRule, AlertConfiguration__c.class);
        
        AlertAccountConfiguration__c accountAlert = new AlertAccountConfiguration__c();
        accountAlert.Account__c = accountId;
        accountAlert.AlertConfiguration__c = alertRuleObj.Id;
        accountAlert.IsActive__c = false;

        return HDT_UTL_DatabaseService.insertSObject(accountAlert);
    }
}
