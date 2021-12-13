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

    public List<Lead> getLeads(Set<Id> ids) {
        return [
            SELECT 
            Id, 
            CompanyOwner__c,
            IndividualId,
            Individual.OneshotBlacklist__c
            FROM Lead 
            WHERE 
            Id IN :ids
            WITH SECURITY_ENFORCED
        ];
    }

    public List<ContactPointPhone> getPrimaryMobilePhone(Set<Id> parentIds) {
        return [
            SELECT 
            Id,
            ParentId,
            TelephoneNumber
            FROM ContactPointPhone 
            WHERE 
            ParentId IN :parentIds
            AND IsPrimary = True
            AND Type__c = 'Mobile'
            WITH SECURITY_ENFORCED
        ];
    }

    public List<ContactPointEmail> getCertifiedContactPointEmails(Set<Id> parentIds) {
        return [
            SELECT 
            Id, 
            ParentId,
            EmailAddress
            FROM ContactPointEmail 
            WHERE 
            ParentId IN :parentIds
            AND IsCertifiedEmail__c = True
            AND Type__c = 'E-mail Anagrafica'
            WITH SECURITY_ENFORCED
        ];
    }
}
