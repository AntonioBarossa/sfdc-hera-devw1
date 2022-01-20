public inherited sharing class HDT_LC_ConfigurePaymentMethods {

    private static HDT_QR_Activity activityQr = new HDT_QR_Activity();


    public HDT_LC_ConfigurePaymentMethods() {
        system.debug('Costruttore HDT_LC_ConfigurePaymentMethods');
    }

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

    @AuraEnabled
    public static Boolean disableMyButtons(SObject mySale){
        boolean toBeDisabled;
        List<SBQQ__Quote__c> myQuoteList = [select id, IsVAS__c, IsBillableVas__c, OrderReference__c, ContractReference__c from SBQQ__Quote__c where Sale__c = :mySale.Id with security_enforced];
        for(SBQQ__Quote__c myQuote : myQuoteList){
            if(myQuote.IsVAS__c && !myQuote.IsBillableVas__c && (myQuote.OrderReference__c != null || myQuote.ContractReference__c != null)){
                toBeDisabled = true;
            }
            else{
                toBeDisabled = false;
            }
        }
        return toBeDisabled;
    }

    
}
