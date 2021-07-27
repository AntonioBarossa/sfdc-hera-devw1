public inherited sharing class HDT_QR_PostSalesMasterBatch {

    Date todayDate = System.today();
    String phaseInstallments = 'Pratica In Attesa';
    String typeInstallments = 'Piano Rateizzazione';
    String nonRequestedContract = 'Contratto Non Richiesto';

    public List<Knowledge__kav> getExpiredArticle(){

        return [SELECT Id,
        KnowledgeArticleId,
        ExpirationDate__c
        FROM Knowledge__kav
        WHERE ExpirationDate__c < :this.todayDate
        WITH SECURITY_ENFORCED
        ];

    }


    public List<Case> getExpiredCase(){

        return [SELECT Id,
        Phase__c,
        Type,
        DepositPaymentMode__c,
        SuspensionEndDate__c
        FROM Case
        WHERE Phase__c = :this.phaseInstallments
        AND Type = :this.typeInstallments
        AND SuspensionEndDate__c <= :this.todayDate
        WITH SECURITY_ENFORCED
        ];

    }

    public List<Order> getRelatedOred(){
        return [SELECT Id,
        Phase__c,
        EffectiveDate__c,
        (SELECT Id,
        Phase__c,
        EffectiveDate__c
        FROM Cases1__r
        WHERE Type = :this.nonRequestedContract
        LIMIT 1)
        FROM Order
        WHERE ProcessType__c = 'Switch in Ele'
        OR ProcessType__c = 'Switch in Gas'
        OR ProcessType__c = 'Switch in Reseller'
        WITH SECURITY_ENFORCED
        ];
    }

}
