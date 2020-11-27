/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 27/11/2020
* @description Apex controller for hdtManageBillingProfile.js component
* @history Keltin Mesonjesi – 27/11/2020 – Created class
*/

public inherited sharing class HDT_LC_ManageBillingProfile {
    
    private static HDT_QR_BillingProfile billingProfileQR = new HDT_QR_BillingProfile();
    private static HDT_SRV_BillingProfile billingProfileSRV = new HDT_SRV_BillingProfile();

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @date 27/11/2020
     * @description Get billing profile list based on accountId
     * @param String accountId
     * @return List<BillingProfile__c>
     */
    @AuraEnabled
    public static List<BillingProfile__c> getBillingProfileList(String accountId){
        
        billingProfileSRV.checkReadAccess('PaymentMethod__c,InvoicingCountry__c,BillSendingMethod__c,IBAN__c');

        return billingProfileQR.getRecordsByAccount(accountId);

    }
}
