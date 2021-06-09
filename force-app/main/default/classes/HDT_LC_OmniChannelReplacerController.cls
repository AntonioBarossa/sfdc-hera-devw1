public with sharing class HDT_LC_OmniChannelReplacerController {
    @AuraEnabled
    public static String getSigmaLogin() {
        return [SELECT LoginADN__c FROM User WHERE Id =: UserInfo.getUserID() WITH SECURITY_ENFORCED].LoginADN__c;
    }

    @AuraEnabled
    public static String getUserChannel() {
        return [SELECT LoginChannel__c FROM User WHERE Id =: UserInfo.getUserID() WITH SECURITY_ENFORCED].LoginChannel__c;
    }

    @AuraEnabled
    public static List<wrts_prcgvr__Activity__c> getActivities(String qadLogin) {
        return [
            SELECT
                Id,
                Name,
                Lead__c,
                Account__c,
                QAdTicketCallTime__c,
                ActivityEndTime__c,
                ActivityDurationFormula__c,
                wrts_prcgvr__Status__c
            FROM
                wrts_prcgvr__Activity__c
            WHERE
                QAdLogin__c =: QAdLogin AND
                Type__c = 'Sportello' AND
                (wrts_prcgvr__Status__c != 'Completed' OR CreatedDate = TODAY)
            WITH SECURITY_ENFORCED
            ORDER BY
                wrts_prcgvr__Status__c DESC,
                CreatedDate DESC
        ];
    }
}