public inherited sharing class HDT_QR_ActivityCustom {
    public static List<wrts_prcgvr__Activity__c> getRecordByTypeAndStatusAndAccountAndServicePoint(String type, String status, String accountId, String servicePointCode) {
        return [
            SELECT
            Id,
            Name,
            Status__c,
            Account__c,
            ServicePointCode__c
            FROM wrts_prcgvr__Activity__c
            WHERE Type__c = :type
            AND Status__c = :status
            AND Account__c = :accountId
            AND ServicePointCode__c = :servicePointCode
            WITH SECURITY_ENFORCED
        ];
    }
}
