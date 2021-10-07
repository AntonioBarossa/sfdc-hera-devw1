public inherited sharing class HDT_LC_ConfigurePaymentMethods {

    private static HDT_QR_Activity activityQr = new HDT_QR_Activity();


    public HDT_LC_ConfigurePaymentMethods() {}

     @AuraEnabled
     public static Boolean disableBotton(String idAcc, SObject o){

        if (o != null) {
        
            wrts_prcgvr__Activity__c activity = activityQr.getLastActivity(idAcc,o);
            if(activity.Approved__c != null){
                if(activity.Approved__c != 'Si'){
                    return false;
                }
            }
        }
        
        return true;

     }

    
}
