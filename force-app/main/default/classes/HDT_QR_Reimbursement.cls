public inherited sharing class HDT_QR_Reimbursement {

    public List<DocumentSelected__c> getDocumentSelectedByCaseId(String recordId){

        return [SELECT Id,
        IssueDate__c,
        Residue__c,
        DocumentResidue__c
        FROM DocumentSelected__c
        WHERE Case__c = :recordId
        WITH SECURITY_ENFORCED];

    }
    

}
