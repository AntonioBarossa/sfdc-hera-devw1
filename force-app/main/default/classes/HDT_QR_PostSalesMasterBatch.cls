public inherited sharing class HDT_QR_PostSalesMasterBatch {

    Date todayDate = System.today();
    String phaseInstallments = 'Pratica In Attesa';
    String typeInstallments = 'Piano Rateizzazione';

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
        AND SuspensionEndDate__c < :this.todayDate
        WITH SECURITY_ENFORCED
        ];

    }

}
