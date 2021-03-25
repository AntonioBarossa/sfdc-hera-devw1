public inherited sharing class HDT_QR_Knowledge {
    

    public List<RecordType> getArticleRecordType(){

        return [SELECT Id, 
        Name 
        FROM RecordType 
        WHERE SobjectType = 'Knowledge__kav'
        WITH SECURITY_ENFORCED
        ];


    }


    public Knowledge__kav getArticleToClone(Id articleId){

        return [SELECT Language, 
        Question__c, 
        Answer__c,
        FlowDiagram__c,
        FlowManagement__c,
        MailArea__c,
        ProblemType__c,
        FirstLevelClassification__c,
        SecondLevelClassification__c,
        OfferedService__c,
        FrontOffice__c,
        CommercialDocumentationType__c,
        FormationDocumentationType__c,
        SalesCompany__c,
        ArticleContent__c,
        MainArticle__c
        FROM Knowledge__kav 
        WHERE Id = :articleId 
        WITH SECURITY_ENFORCED
        LIMIT 1];


    }


    public Knowledge__kav getArticleCreated(String title, string urlName){

        return [SELECT Id 
        FROM Knowledge__kav 
        WHERE Title = :title 
        AND UrlName = :urlName
        WITH SECURITY_ENFORCED
        LIMIT 1
        ];


    }



}