@SuppressWarnings('PMD.AvoidDebugStatements')
public with sharing class HDT_LC_AccountAlerts {

    @AuraEnabled
    public static String getAccountAlerts(Id accountId) {

        HDT_QR_AlertAccountConfiguration queryHandler = new HDT_QR_AlertAccountConfiguration();
        
        List<AlertAccountConfiguration__c> accountAlerts = queryHandler.getRecordsByAccountId(accountId);

        return JSON.serialize(accountAlerts);
    }

    @AuraEnabled(cacheable=true)
    public static String getAvailableRulesFor(String accountCategory, String accountId) {

        HDT_QR_AlertConfiguration queryHandler = new HDT_QR_AlertConfiguration();
        
        List<AlertConfiguration__c> availableAlerts = queryHandler.getRecordsForAccount(accountId, accountCategory);
        System.debug(LoggingLevel.DEBUG, '@Davide - HDT_LC_AccountAlerts - getAvailableRulesFor()');

        return JSON.serialize(availableAlerts);
    }

    @AuraEnabled
    public static Boolean addAlertToAccount(String alertRule, Id accountId) {
        System.debug(LoggingLevel.DEBUG, 'Going to add alert rule ' + alertRule + ' to Account with Id: ' + accountId);
        AlertConfiguration__c alertRuleObj = (AlertConfiguration__c) JSON.deserialize(alertRule, AlertConfiguration__c.class);
        
        AlertAccountConfiguration__c accountAlert = new AlertAccountConfiguration__c();
        accountAlert.Account__c = accountId;
        accountAlert.AlertConfiguration__c = alertRuleObj.Id;
        accountAlert.IsActive__c = false;

        return HDT_UTL_DatabaseService.insertSObject(accountAlert);
    }

    @AuraEnabled
    public static Boolean updateAlert(String alert) {
        System.debug(LoggingLevel.DEBUG, 'Going to update alert ' + alert);
        AlertAccountConfiguration__c alertObj = (AlertAccountConfiguration__c) JSON.deserialize(alert, AlertAccountConfiguration__c.class);
        return HDT_UTL_DatabaseService.updateSObject(alertObj);
    }

    @AuraEnabled(cacheable=true)
    public static HDT_WRP_AccountContactDetails getContactDetails(String accountId) {
        HDT_QR_AccountContactRelation acrQueryHandler = new HDT_QR_AccountContactRelation();
        
        AccountContactRelation acr = acrQueryHandler.getPrimaryContactRelation(accountId);
        System.debug(LoggingLevel.DEBUG, 'AccountContactRelation: ' + acr);
        if (acr != null) {
            return new HDT_WRP_AccountContactDetails(acr.Contact.Email, acr.Contact.MobilePhone);
        }
        
        return new HDT_WRP_AccountContactDetails('', '');
    }

    public class HDT_WRP_AccountContactDetails {
        @AuraEnabled
        public String email { get; set; }
        @AuraEnabled
        public String mobilePhone { get; set; }

        public HDT_WRP_AccountContactDetails(String email, String mobilePhone){
            this.email = email;
            this.mobilePhone = mobilePhone;
        }
    }
}
