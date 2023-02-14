public with sharing class HDT_LC_AlertPrivacy {
    public HDT_LC_AlertPrivacy() {

    }
    @AuraEnabled(cacheable=false)
    public static Boolean handleShowAlert(String orderId){
        Boolean result = false;
        Boolean blankMarket = true;
        Boolean blankProfile = true;
        String signatureMethod = '';
        try {
            if(String.IsBlank(orderId))return false;
            List<Order> ordList = [SELECT id,Contact__r.Individual.MarketingPrivacy__c, Contact__r.Individual.ProfilingPrivacy__c,SignatureMethod__c FROM Order WHERE Id =:orderId AND CompanyOwner__c != 'MMS' WITH SECURITY_ENFORCED];
            if(!ordList.isEmpty()){
                if(ordList[0].Contact__r!=null){
                    blankMarket = ordList[0].Contact__r.Individual.MarketingPrivacy__c == 'Non espresso'?true:false;
                    blankProfile = ordList[0].Contact__r.Individual.ProfilingPrivacy__c == 'Non espresso'?true:false;
                    signatureMethod = ordList[0].SignatureMethod__c;
                }
                if(blankMarket && blankProfile && !signatureMethod.contains('OTP')){
                    result = true;
                }
            }
        } catch (Exception e) {
            return false;
        }
        return result;
    }
}
