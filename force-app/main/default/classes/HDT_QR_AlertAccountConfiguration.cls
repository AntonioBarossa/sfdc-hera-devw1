public with sharing class HDT_QR_AlertAccountConfiguration {
    
    public List<AlertAccountConfiguration__c> getRecordsByAccountId(Id accountId) {

        List<AlertAccountConfiguration__c> accountAlerts = [
            SELECT 
            Id, 
            AlertType__c,
            AlertRule__c,
            AlertState__c,
            IsActive__c, 
            Contact__c,
            Contact__r.Name,
            IsEmailChannelActive__c, 
            IsSmsChannelActive__c, 
            IsPushChannelActive__c, 
            IsSolChannelActive__c,
            IsEmailChannelAllowed__c, 
            IsSmsChannelAllowed__c, 
            IsPushChannelAllowed__c, 
            IsSolChannelAllowed__c 
            FROM AlertAccountConfiguration__c
            WHERE Account__c = :accountId
            WITH SECURITY_ENFORCED
        ];

        return accountAlerts;
    }

}
