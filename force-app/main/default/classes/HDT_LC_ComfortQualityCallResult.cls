public inherited sharing class HDT_LC_ComfortQualityCallResult {
    
    @AuraEnabled
    public static Boolean init(String activityId){
       List<wrts_prcgvr__Activity__c> listActivity = HDT_QR_ActivityCustom.getActivityByRecordId(activityId);

       return (listActivity[0].Type__c == 'Quality Call' || listActivity[0].Type__c == 'Comfort Call');
    }

    //Davide Viola - 24/10/2022: Aggiungo metodo per il controllo del permesso di esitazione C/Q Call (CR_3020)
    @AuraEnabled
    public static Boolean checkPermission(){
        
        Boolean res = FeatureManagement.checkPermission('HDT_CP_EsitoCQCall');
        return res;
    }
}
