public with sharing class HDT_TRH_NewsNotificationCenter extends HDT_TRH_TriggerHandler {

    private static HDT_QR_Knowledge qrKb = new HDT_QR_Knowledge();

    public override void beforeInsert(){
        getPotentialDuplicate(Trigger.new);
    }

    public static String getPotentialDuplicate(List<NewsNotificationCenter__c> newsConfig){

        for(NewsNotificationCenter__c news : newsConfig){

            NewsNotificationCenter__c newsDup = qrKb.getDuplicateNews(news);

            if(newsDup.Id != null){

                news.addError('Regola duplicata di '+newsDup.Name);

            }


        }

    return null;

    }

}