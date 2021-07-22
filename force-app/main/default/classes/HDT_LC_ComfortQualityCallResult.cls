public inherited sharing class HDT_LC_ComfortQualityCallResult {
    
    @AuraEnabled
    public static Boolean init(String activityId){
       List<wrts_prcgvr__Activity__c> listActivity = HDT_QR_ActivityCustom.getActivityByRecordId(activityId);

       return (listActivity[0].Type__c == 'Quality Call' || listActivity[0].Type__c == 'Comfort Call');
    }
}
