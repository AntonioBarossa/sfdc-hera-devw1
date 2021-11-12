public inherited sharing class HDT_QR_PostSalesMasterBatch {

    Date todayDate = System.today();
    String phaseInstallments = 'Pratica In Attesa';
    String typeInstallments = 'Piano Rateizzazione';
    String dunningBlock = 'Blocco Sollecito/Interessi';
    Set<String> typeSet = new Set<String>{typeInstallments,dunningBlock};
    String nonRequestedContract = 'Contratto Non Richiesto';
    String phaseQuotations = 'Attesa conferma preventivo cliente';
    String bozzaCase = 'Bozza';
    String autoletturaCase = 'Autolettura';

    public List<Knowledge__kav> getExpiredArticle(){

        return [SELECT Id,
        KnowledgeArticleId,
        ExpirationDate__c
        FROM Knowledge__kav
        WHERE ExpirationDate__c < :this.todayDate
        AND PublishStatus = 'Online'
        WITH SECURITY_ENFORCED
        ];

    }


    public List<Case> getExpiredCase(){

        return [SELECT Id,
        Phase__c,
        Type,
        Cluster__c,
        DepositPaymentMode__c,
        SuspensionEndDate__c
        FROM Case
        WHERE Phase__c = :this.phaseInstallments
        AND Type IN :this.typeSet
        AND SuspensionEndDate__c <= :this.todayDate
        WITH SECURITY_ENFORCED
        ];

    }

    public List<Case> getNonReqContract(){
        return [SELECT Id,
        Phase__c,
        EffectiveDate__c,
        Type,
        Cluster__c,
        Order__c
        FROM Case
        WHERE Type = :this.nonRequestedContract
        AND Phase__c = : this.phaseInstallments
        WITH SECURITY_ENFORCED
        ];
    }

    public Order getRelatedOrder(String orderId){
        return [SELECT Id,
        EffectiveDate__c
        FROM Order
        WHERE Id = :orderId
        WITH SECURITY_ENFORCED
        LIMIT 1];
    }

    public List<Case> getQuotationCase(){
        
        return [SELECT Id,
        Phase__c,
        Type,
        Cluster__c,
        QuotationType__c,
        QuotationValidityDate__c
        FROM Case
        WHERE QuotationValidityDate__c < :this.todayDate
        AND Phase__c = :this.phaseQuotations
        WITH SECURITY_ENFORCED];

    }

    public List<Case> getAutoletturaBozzaCase(){
        return [SELECT Id,
        Type,
        Phase__c,
        Cluster__c,        
        CreatedDate,
        DepositPaymentMode__c,
        SuspensionEndDate__c,
        EffectiveDate__c,
        Order__c,
        QuotationType__c,
        QuotationValidityDate__c
        FROM Case
        WHERE Phase__c = :this.bozzaCase
        AND Cluster__c = : this.autoletturaCase
        WITH SECURITY_ENFORCED
        ];
    }

    public List<Case> getPostSalesBozzaCase(){
        return [SELECT Id,
        Type,
        Phase__c,
        Cluster__c,
        CreatedDate,
        DepositPaymentMode__c,
        SuspensionEndDate__c,
        EffectiveDate__c,
        Order__c,
        QuotationType__c,
        QuotationValidityDate__c
        FROM Case
        WHERE Phase__c = :this.bozzaCase
        AND Cluster__c != : this.autoletturaCase
        WITH SECURITY_ENFORCED
        ];
    }

}