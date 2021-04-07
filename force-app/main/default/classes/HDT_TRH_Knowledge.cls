public inherited sharing class HDT_TRH_Knowledge {
    public void myUpdateMethodToPublish() {
        if(Trigger.isUpdate){
        //Approval.UnlockResult ur = Approval.unlock(article.Id);
        //KbManagement.PublishingService.scheduleForPublication(article.KnowledgeArticleId, article.ToPublishDate__c);
            for (Knowledge__kav article : (List<Knowledge__kav>) Trigger.new){
                
                if(article.PublishStatus == 'Draft' && article.ValidationStatus == 'Validato Da Pubblicatore'){
                    Approval.UnlockResult ur = Approval.unlock(article.Id);
                    //myUpdateHandler.myUpdateMethodToPublish(article);
                    KbManagement.PublishingService.scheduleForPublication(article.KnowledgeArticleId, article.ToPublishDate__c);
                    //KbManagement.PublishingService.scheduleForPublication(article.KnowledgeArticleId, article.ToPublishDate__c);
        
                }
            }
        }
        
        return;
    }
}