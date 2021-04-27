/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 04/12/2020
* @description HDT_LC_ApplyBillingProfileModal – Back-end controller for hdtApplyBillingProfileModal.js lwc component
* @history Keltin Mesonjesi – 04/12/2020 – Created class
*/
public inherited sharing class HDT_LC_ApplyBillingProfileModal {
    
    private static HDT_QR_QuoteLine quoteLineQr = new HDT_QR_QuoteLine();
    private static HDT_SRV_QuoteLine quoteLineSrv = new HDT_SRV_QuoteLine();

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 04/12/2020
    * @description Get SBQQ__QuoteLine__c based on payment method
    * @param String saleId
    * @param String paymentMethod
    * @return List<SBQQ__QuoteLine__c>
    */
    @AuraEnabled
    public static List<SBQQ__QuoteLine__c> getQuoteLineBundle(String saleId, String paymentMethod){

        System.debug('saleId: ' + saleId);
        System.debug('paymentMethod: ' + paymentMethod);

        quoteLineSrv.checkReadAccess('SBQQ__RequiredBy__c,SBQQ__RequiredBy__r.Name,ServicePoint__c,ServicePoint__r.ServicePointCode__c,SBQQ__RequiredBy__r.SBQQ__Product__r.Name,SBQQ__Quote__r.Name,SBQQ__Quote__r.SBQQ__Opportunity2__r.Name');
        
        System.debug('query result: ' + quoteLineQr.getRecordsBySaleFilteredPaymentMethodNoContractNoOrder(saleId, paymentMethod));
        return quoteLineQr.getRecordsBySaleFilteredPaymentMethodNoContractNoOrder(saleId, paymentMethod);
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 04/12/2020
    * @description Update SBQQ__QuoteLine__c BillingProfile__C
    * @param List<SObject> quoteLinesToUpdate
    * @param String billingProfileId
    */
    @AuraEnabled
    public static void updateQuoteLinesBillingProfile(List<SObject> quoteLinesToUpdate, String billingProfileId){
        
        List<SBQQ__QuoteLine__c> quoteLineListUpdate = new List<SBQQ__QuoteLine__c>();

        for (SObject quoteLine : quoteLinesToUpdate) {
            SBQQ__QuoteLine__c quoteLineUpdate = new SBQQ__QuoteLine__c(
                Id = quoteLine.Id,
                BillingProfile__c = billingProfileId
            );
            quoteLineListUpdate.add(quoteLineUpdate);
        }

        quoteLineSrv.updateRecords(quoteLineListUpdate);

    }

}
