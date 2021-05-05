public inherited sharing class HDT_QR_CaseValidations {


    public Case getCaseById(string recordId){

        return [SELECT Id,
        Type,
        Subprocess__c,
        CommodityFormula__c,
        ServicePoint__r.ServicePointCode__c,
        OpinionRequest__c,
        AttachmentManagement__c,
        BillingProfile__c
        FROM Case
        WHERE Id = :recordId
        WITH SECURITY_ENFORCED
        LIMIT 1
        ];

    }

    public List<ContentDocumentLink> getDocumentByCaseId(String recordId){

        List<ContentDocumentLink> attachedDocument = new List<ContentDocumentLink>();

        try{

            attachedDocument = [SELECT Id 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :recordId 
            WITH SECURITY_ENFORCED];
            
        } catch(Exception e){

            System.debug('QR_CaseValidations Exception--> '+e.getMessage());

        }

        return attachedDocument;

    }


    public String getUserSessionRole(){

        String userId= UserInfo.getSessionId();
        String roleName;

        rolename = [SELECT UserRole.Name
        FROM User
        WHERE Id = :userId
        WITH SECURITY_ENFORCED
        LIMIT 1
        ].UserRole.Name;

        return roleName;

    }

    public BillingProfile__c getBillingProfileInfo(String recordId){

        return [SELECT Id,
        PaymentMethod__c
        FROM
        BillingProfile__c
        WHERE
        Id = :recordId
        WITH SECURITY_ENFORCED
        LIMIT 1
        ];

    }

}
