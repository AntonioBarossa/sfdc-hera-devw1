public inherited sharing class HDT_QR_ReminderBlock {

    public Case getCaseById(String recordId){

        return [SELECT Id,
        AccountCode__c,
        BlockType__c
        FROM Case
        WHERE Id = :recordId
        WITH SECURITY_ENFORCED
        LIMIT 1
        ];

    }

    public List<DocumentSelected__c> getDocumentSelectedByCaseId(String recordId){

        return [SELECT Id,
        DocumentNumber__c,
        ContractualAccount__c
        FROM DocumentSelected__c
        WHERE Case__c = :recordId
        WITH SECURITY_ENFORCED];

    }

}
