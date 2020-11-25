/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 23/11/2020
* @description HDT_QR_BillingProfile – Contains queries for BillingProfile
* @history Keltin Mesonjesi – 23/11/2020 – Created class
*/
public inherited sharing class HDT_QR_BillingProfile {
    
    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Get records related to account
     * @param String accountId
     * @return List<BillingProfile__c>
     */
    public List<BillingProfile__c> getRecordsByAccount(String accountId){

        return [
            SELECT
            PaymentMethod__c,
            InvoicingCountry__c,
            BillSendingMethod__c,
            IBAN__c
            FROM BillingProfile__c
            WHERE Account__c = :accountId
            WITH SECURITY_ENFORCED
        ];
    }

}
