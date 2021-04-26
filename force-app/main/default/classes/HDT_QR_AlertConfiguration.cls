public with sharing class HDT_QR_AlertConfiguration {
    
    public List<AlertConfiguration__c> getRecordsByAccountCategory(String accountCategory) {

        List<AlertConfiguration__c> availableAlerts = [
            SELECT 
            Id,
            AlertRule__c, AlertType__c,
            IsActive__c, IsEmailChannelActive__c,
            IsSmsChannelActive__c, IsPushChannelActive__c,
            IsSolChannelActive__c,
            Description__c
            FROM AlertConfiguration__c
            WHERE AccountCategory__c INCLUDES (:accountCategory)
            WITH SECURITY_ENFORCED
        ];

        return availableAlerts;
    }

}
