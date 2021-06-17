public inherited sharing class HDT_QR_PostSalesMasterBatch {

    Date todayDate = System.today();
    String phaseInstallments = 'Elaborazione Manuale';
    String typeInstallments = 'Piano Rateizzazione';

    public List<Knowledge__kav> getExpiredArticle(){

        return [SELECT Id,
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
        SuspensionDate__c
        FROM Case
        WHERE Phase__c = :this.phaseInstallments
        AND Type = :this.typeInstallments
        AND SuspensionDate__c < :this.todayDate
        WITH SECURITY_ENFORCED
        ];

    }

}
