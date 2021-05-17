public inherited sharing class HDT_QR_PaymentCommunication {

    public Case getCaseById(String recordId){

        return [SELECT Id,
        CaseNumber,
        TotalPaidCustomer__c,
        TotalPaidCustomerToPay__c,
        TotalToPay__c,
        TotalResidue__c,
        Deposit__c
        FROM Case
        WHERE Id = :recordId
        WITH SECURITY_ENFORCED
        LIMIT 1];

    }

    public List<DocumentSelected__c> getDocumentSelectedByCase(String recordId){

        return [SELECT Id,
        Bill__c,
        DocumentNumber__c,
        ExpirationDate__c,
        PaidCustomer__c,
        Extension__c,
        IssueDate__c,
        TotalCommunicationPayment__c
        FROM DocumentSelected__c
        WHERE Case__c = :recordId
        WITH SECURITY_ENFORCED];

    }


}
