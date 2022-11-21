@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_QR_CaseValidations {


    public Case getCaseById(string recordId){

        return [SELECT Id,
        Type,
        Subprocess__c,
        Cluster__c,
        Commodity__c,
        CommodityFormula__c,
        ServicePoint__r.ServicePointCode__c,
        OpinionRequest__c,
        PhoneNumber__c,
        Email__c,
        ElementDetail__c,
        Disconnectable__c,
        AttachmentManagement__c,
        AmountToPayInInstallments__c,
        BillingProfile__c,
        AlternativeAddress__c,
        AccountId,
        Account.CustomerMarking__c,
        Account.RecordType.DeveloperName,
        ContactId,
        Contract__r.StartDate,
        ClientCategory__c,
        ShipmentAddressAssign__c,
        TemporaryConnectionEndDate__c,
        Description,
        SupplyCity__c,
        InvoicingCity__c,
        ContractAccountCode__c,
        RateCategory__c,
        BillingIsAddressVerified__c
        FROM Case
        WHERE Id = :recordId
        WITH SECURITY_ENFORCED
        LIMIT 1
        ];

    }

    public List<Case> getCaseByTypeBillingProfile(String processType, Id accountId, String contractAccount){
        return [SELECT Id FROM Case WHERE Type =: processType AND AccountId =: accountId AND ContractAccountCode__c =:contractAccount];
    }

    public List<ContentDocumentLink> getDocumentByCaseId(String recordId){

        List<ContentDocumentLink> attachedDocument = new List<ContentDocumentLink>();

        try{
            attachedDocument = [SELECT Id, ContentDocument.Title
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :recordId 
            WITH SECURITY_ENFORCED];
            
        } catch(Exception e){
            System.debug(LoggingLevel.DEBUG, 'QR_CaseValidations Exception--> '+e.getMessage());
            
        }

        return attachedDocument;

    }


    public String getUserSessionRole(){

        String userId= UserInfo.getUserId();
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