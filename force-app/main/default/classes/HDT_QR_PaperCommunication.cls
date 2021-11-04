public with sharing class HDT_QR_PaperCommunication {
    public static PaperCommunication__c getRecordById(String id){
        return [
            SELECT Id,
            Name,
            CommunicationId__c,
            PdfUniqueId__c,
            Response__c,
            DateOfMailing__c,
            PaperProcessing__c,
            Note__c,
            Contact__c,
            Campaign__c
            FROM PaperCommunication__c
            WHERE Id = :id
            WITH SECURITY_ENFORCED
        ];
    }
}
