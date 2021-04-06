public inherited sharing class HDT_LC_CloneArticle {

    private static HDT_QR_Knowledge qrKb = new HDT_QR_Knowledge();


    @AuraEnabled
    public static List<RecordType> getRecordTypeOptions(){

        return qrKb.getArticleRecordType();
        
    }

    @AuraEnabled
    public static Knowledge__kav cloneArticle(Id articleId, String title, String urlName, Id recordtypeId){

        Knowledge__kav articleToClone = qrKb.getArticleToClone(articleId);

        Knowledge__kav articleToInsert = new Knowledge__kav(Title = title,
        UrlName = urlName,
        ArticleContent__c = articleToClone.ArticleContent__c,
        RecordTypeId = recordtypeId,
        Question__c = articleToClone.Question__c,
        Answer__c = articleToClone.Answer__c,
        FlowDiagram__c = articleToClone.FlowDiagram__c,
        FlowManagement__c = articleToClone.FlowManagement__c,
        MailArea__c = articleToClone.MailArea__c,
        ProblemType__c = articleToClone.ProblemType__c,
        FirstLevelClassification__c = articleToClone.FirstLevelClassification__c,
        SecondLevelClassification__c = articleToClone.SecondLevelClassification__c,
        OfferedService__c = articleToClone.OfferedService__c,
        FrontOffice__c = articleToClone.FrontOffice__c,
        CommercialDocumentationType__c = articleToClone.CommercialDocumentationType__c,
        FormationDocumentationType__c = articleToClone.FormationDocumentationType__c,
        SalesCompany__c = articleToClone.SalesCompany__c,
        MainArticle__c = articleToClone.MainArticle__c,
        Language = articleToClone.Language);

        HDT_UTL_DatabaseService.insertSObject(articleToInsert);

        return articleToInsert;  

    } 

    @AuraEnabled
    public static Id redirectToArticle(String title, string urlName){
        
        Knowledge__kav insertedArticle = qrKb.getArticleCreated(title,urlName);

        return insertedArticle.Id;



    }

}