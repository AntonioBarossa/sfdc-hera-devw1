public inherited sharing class HDT_QR_Paperless {

    public Case getCaseById(String recordId){

        return [SELECT Id,
        CaseNumber,
        AccountCode__c,
        BillingProfile__r.ContractAccountCode__c
        FROM Case
        WHERE Id = :recordId
        WITH SECURITY_ENFORCED
        LIMIT 1];

    }

    public List<DocumentSelected__c> getDocumentSelectedByCase(String recordId){

        return [SELECT Id,
        Amount__c,
        DocumentNumber__c,
        ExpirationDate__c,
        Position1__c,
        Position2__c,
        Position3__c
        FROM DocumentSelected__c
        WHERE Case__c = :recordId
        WITH SECURITY_ENFORCED];

    }


}
