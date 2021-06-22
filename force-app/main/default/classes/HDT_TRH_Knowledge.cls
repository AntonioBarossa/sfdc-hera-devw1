public inherited sharing class HDT_TRH_Knowledge {
    public void handleUpdate() {

        for (Knowledge__kav article :(List<Knowledge__kav >) Trigger.new){

            if(Trigger.isUpdate && Trigger.isBefore){    

                System.debug('Knowledge Before Update Trigger Start');


                System.debug('Knowledge Before Update Trigger End');
                
            }

            if(Trigger.isUpdate && Trigger.isAfter){

                System.debug('Knowledge After Update Trigger Start');

                if(article.PublishStatus == 'Draft' && article.ValidationStatus == 'Validato Da Pubblicatore'){

                    if(article.ToPublishDate__c != null){

                        Approval.UnlockResult ur = Approval.unlock(article.Id);

                        KbManagement.PublishingService.scheduleForPublication(article.KnowledgeArticleId, article.ToPublishDate__c);
                    }

                    if(article.RecordTypeId == Schema.SobjectType.Knowledge__kav.getRecordTypeInfosByName().get('News').getRecordTypeId()
                && article.VersionNumber == 0){

                    System.debug('News Notification Center Start');

                    HDT_UTL_NewsNotificationCenter.sendNotification(article);

                    System.debug('News Notification Center End');

                }

                }

                

                System.debug('Knowledge After Update Trigger End');

            }

        } 

        return;
    
    }

}