public inherited sharing class HDT_TRH_Knowledge extends HDT_TRH_TriggerHandler {

    public override void beforeUpdate(){
        this.handleUpdate();
    }

    public override void afterUpdate(){
        this.handleUpdate();
    }
    
    @SuppressWarnings('PMD.CyclomaticComplexity')
    public void handleUpdate() {

        if(Trigger.new != null && Trigger.new.size() > 0)
        {
            //@frpanico 01/10/2021
            //Refactoring: Trigger is meant to be used for one record only
            List<Knowledge__kav> articleList = (List<Knowledge__kav>) Trigger.new;
            Knowledge__kav article = (Knowledge__kav)articleList[0];

            if(Trigger.isUpdate && Trigger.isBefore){    

                //System.debug('Knowledge Before Update Trigger Start');

                if(article.ValidationStatus == 'Validato Da Pubblicatore' 
                    && article.RecordTypeId == Schema.SobjectType.Knowledge__kav.getRecordTypeInfosByName().get('News').getRecordTypeId()
                    && article.VersionNumber == 0){
                        
                        //System.debug('News Notification Center Start');
                        
                        if(article.ToPublishDate__c == null || (article.ToPublishDate__c != null && article.ToPublishDate__c < System.now()))
                        {
                            HDT_UTL_NewsNotificationCenter.sendNotification(article);
                        }
                        
                        //System.debug('News Notification Center End');

                }

                //System.debug('Knowledge Before Update Trigger End');
                
            }

            if(Trigger.isUpdate && Trigger.isAfter){

                //System.debug('Knowledge After Update Trigger Start');

                if(article.PublishStatus == 'Draft' && article.ValidationStatus == 'Validato Da Pubblicatore' && article.ToPublishDate__c != null){

                    Approval.UnlockResult ur;

                    ur = Approval.unlock(article.Id);

                    KbManagement.PublishingService.scheduleForPublication(article.KnowledgeArticleId, article.ToPublishDate__c);
                    
                }

                //System.debug('Knowledge After Update Trigger End');

            } 
        }
        return;
    
    }

}