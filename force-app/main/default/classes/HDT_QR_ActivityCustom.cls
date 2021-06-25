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

    public static List<wrts_prcgvr__Activity__c> getRecordByCaseId(String caseId) {
        return [
            SELECT
            
            Id,
            Approved__c,
            Name
            FROM wrts_prcgvr__Activity__c
            WHERE Case__c= :caseId
            WITH SECURITY_ENFORCED
        ];
    }
    public static List<wrts_prcgvr__Activity__c> getRecordByCaseIdList(List<String> caseId) {
        return [
            SELECT
            Id,
            Approved__c,
            case__c,
            owner.name,
            Name
            FROM wrts_prcgvr__Activity__c
            WHERE Case__c IN :caseId
            WITH SECURITY_ENFORCED
        ];
    }
    public static List<wrts_prcgvr__Activity__c> getRecordByOrderLine(List<String> quoteLine) {
        return [
            SELECT
            Id,
            Approved__c,
            QuoteLine__c,
            case__c,
            owner.name,
            Name
            FROM wrts_prcgvr__Activity__c
            WHERE QuoteLine__c IN :quoteLine
            WITH SECURITY_ENFORCED
        ];
    }
}
