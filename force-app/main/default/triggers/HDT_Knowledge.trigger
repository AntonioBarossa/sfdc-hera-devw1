trigger HDT_Knowledge on Knowledge__kav (before update) {
    
    HDT_TRH_Knowledge myUpdateHandler = new HDT_TRH_Knowledge();
    /*for (Knowledge__kav article : Trigger.new){
        if(Trigger.isUpdate && article.PublishStatus == 'Draft' && article.ValidationStatus == 'Validato Da Pubblicatore'){
            
            myUpdateHandler.myUpdateMethodToPublish(article);
            //KbManagement.PublishingService.scheduleForPublication(article.KnowledgeArticleId, article.ToPublishDate__c);

        }
    }*/
    myUpdateHandler.myUpdateMethodToPublish();
}