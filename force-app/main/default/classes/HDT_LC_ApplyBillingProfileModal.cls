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
    * @return Map<String, List<SBQQ__QuoteLine__c>>
    */
    @AuraEnabled
    public static Map<String, List<SBQQ__QuoteLine__c>> getQuoteLineBundle(String saleId, String paymentMethod, String sendingBillMode){

        System.debug('saleId: ' + saleId);
        System.debug('paymentMethod: ' + paymentMethod);
        System.debug('sendingBillMode: ' + sendingBillMode);

        quoteLineSrv.checkReadAccess('SBQQ__RequiredBy__c,SBQQ__RequiredBy__r.Name,ServicePoint__c,ServicePoint__r.ServicePointCode__c,SBQQ__RequiredBy__r.SBQQ__Product__r.Name,SBQQ__Quote__r.Name,SBQQ__Quote__r.SBQQ__Opportunity2__r.Name');
        
        System.debug('query result pod/pdr: ' + quoteLineQr.getRecordsBySaleFilteredPaymentMethodPodPdr(saleId, paymentMethod, sendingBillMode));
        List<SBQQ__QuoteLine__c> listPodPdr = quoteLineQr.getRecordsBySaleFilteredPaymentMethodPodPdr(saleId, paymentMethod, sendingBillMode);
        
        System.debug('query result vas: ' + quoteLineQr.getRecordsBySaleFilteredPaymentMethodforVas(saleId));
        List<SBQQ__QuoteLine__c> listVas = quoteLineQr.getRecordsBySaleFilteredPaymentMethodforVas(saleId);

        Map<String, List<SBQQ__QuoteLine__c>> quoteLineMap = new Map<String, List<SBQQ__QuoteLine__c>>();
        quoteLineMap.put('listPodPdr', listPodPdr);
        quoteLineMap.put('listVas', listVas);

        return quoteLineMap;
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

        List<String> quoteLineIds = new List<String>();

        for (SObject quoteLine : quoteLinesToUpdate) {
            SBQQ__QuoteLine__c quoteLineUpdate = new SBQQ__QuoteLine__c(
                Id = quoteLine.Id,
                BillingProfile__c = billingProfileId
            );
            quoteLineListUpdate.add(quoteLineUpdate);
            quoteLineIds.add(quoteLine.Id);
        }

        List<SBQQ__QuoteLine__c> quoteLineVas = quoteLineQr.getChildAnalisi(quoteLineIds);

        for (SBQQ__QuoteLine__c qlv : quoteLineVas) {
            SBQQ__QuoteLine__c qlvUpdate = new SBQQ__QuoteLine__c(
                Id = qlv.Id,
                BillingProfile__c = billingProfileId
            );
            quoteLineListUpdate.add(qlvUpdate);
        }

        quoteLineSrv.updateRecords(quoteLineListUpdate);

    }

}
