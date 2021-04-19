public with sharing class HDT_LC_OmniChannelReplacerController {
    @AuraEnabled
    public static String getSigmaLogin(){
        return [SELECT FederationIdentifier FROM User WHERE Id =: UserInfo.getUserID()].FederationIdentifier;
    }

    @AuraEnabled
    public static List<wrts_prcgvr__Activity__c> getActivities(String qadLogin){
        return [
            SELECT
                Id,
                Name,
                Account__c,
                wrts_prcgvr__Status__c
            FROM
                wrts_prcgvr__Activity__c
            WHERE
                Type__c = 'Sportello' AND
                QAdLogin__c =: QAdLogin AND (
                    wrts_prcgvr__Status__c != 'Completed' OR
                    CreatedDate = TODAY
                )
            ORDER BY
                wrts_prcgvr__Status__c DESC,
                CreatedDate DESC
        ];
    }
}