public inherited sharing class HDT_LC_ConfigurePaymentMethods {

    private static HDT_QR_Activity activityQr = new HDT_QR_Activity();


    public HDT_LC_ConfigurePaymentMethods() {}

     @AuraEnabled
     public static Boolean disableBotton(){

        wrts_prcgvr__Activity__c activity = activityQr.getLastActivity();
        if(activity.Approved__c != null){
            if(activity.Approved__c != 'No'){
                return false;
            }
        }
            return true;

     }

    
}
