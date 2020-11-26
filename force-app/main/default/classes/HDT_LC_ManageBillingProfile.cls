public inherited sharing class HDT_LC_ManageBillingProfile {
    
    private static HDT_QR_BillingProfile billingProfileQR = new HDT_QR_BillingProfile();

    @AuraEnabled
    public static List<BillingProfile__c> getBillingProfileList(String accountId){
        
        List<BillingProfile__c> records = new List<BillingProfile__c>();

        records = billingProfileQR.getRecordsByAccount(accountId);

        return records;
    }
}
