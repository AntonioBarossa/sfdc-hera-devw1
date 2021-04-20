public inherited sharing class HDT_QR_Task {

    public List<Task> getRecordsByIds(Set<Id> ids) {
        return [
            SELECT 
            Id 
            FROM Task 
            WHERE Id IN :ids
            WITH SECURITY_ENFORCED
        ];
    }

    public List<Task> getCertifiedEmails() {
        return [
            SELECT 
            Id, 
            WhoId, 
            Description, 
            PecAddress__c, 
            DoxeePecTemplateCode__c 
            FROM Task 
            WHERE 
            IsPec__c = True AND 
            SentToMulesoft__c = False 
            WITH SECURITY_ENFORCED
        ];
    }
}
