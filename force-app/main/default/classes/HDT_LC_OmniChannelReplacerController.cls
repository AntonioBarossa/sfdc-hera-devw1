    public with sharing class HDT_LC_OmniChannelReplacerController {
    @AuraEnabled
    public static String getSigmaLogin() {
        return [SELECT FederationIdentifier FROM User WHERE Id =: UserInfo.getUserID() WITH SECURITY_ENFORCED].FederationIdentifier;
    }

    @AuraEnabled
    public static List<wrts_prcgvr__Activity__c> getActivities(String qadLogin) {
        return [
            SELECT
                Id,
                Name,
                Lead__c,
                Account__c,
                wrts_prcgvr__Status__c
            FROM
                wrts_prcgvr__Activity__c
            WHERE
                QAdLogin__c =: QAdLogin AND
                (Type__c = 'Sportello' OR ContactReason__c != null) AND
                (wrts_prcgvr__Status__c != 'Completed' OR CreatedDate = TODAY)
            WITH SECURITY_ENFORCED
            ORDER BY
                wrts_prcgvr__Status__c DESC,
                CreatedDate DESC
        ];
    }
}