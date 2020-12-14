/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 14/12/2020
* @description Apex controller for hdtSaleActions.js component
* @history Keltin Mesonjesi – 14/12/2020 – Created class
*/
public inherited sharing class HDT_LC_SaleActions {
    
    private static HDT_SRV_Sale saleSrv = new HDT_SRV_Sale();
    private static HDT_SRV_QuoteLine quoteLineSrv = new HDT_SRV_QuoteLine();
    private static HDT_QR_QuoteLine quoteLineQr = new HDT_QR_QuoteLine();
    private static HDT_SRV_Opportunity opportunitySrv = new HDT_SRV_Opportunity();
    private static HDT_QR_Opportunity opportunityQr = new HDT_QR_Opportunity();
    private static HDT_SRV_Quote quoteSrv = new HDT_SRV_Quote();
    private static HDT_QR_Quote quoteQr = new HDT_QR_Quote();

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Save sale as draft
     * @param Sale__c sale
     */
    @AuraEnabled
    public static void saveDraft(Sale__c sale){
        saleSrv.updateRecord(sale);
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Save sale
     * @param Sale__c sale
     */
    @AuraEnabled
    public static void save(Sale__c sale){
        
        //Check if QuoteLines have BillingProfiles associated
        quoteLineSrv.checkReadAccess('Name,Billing_Profile__c');
        List<SBQQ__QuoteLine__c> quoteLinesList = quoteLineQr.getRecordsBySaleFilteredPaymentMethodNotNull(sale.Id);

        List<String> quoteLinesWithoutBilling = new List<String>();

        for (SBQQ__QuoteLine__c quoteLine : quoteLinesList) {
            if (quoteLine.Billing_Profile__c == null) {
                quoteLinesWithoutBilling.add(quoteLine.Name);
            }
        }
        
        if (!quoteLinesWithoutBilling.isEmpty()) {
            throw new AuraHandledException('Attenzione! Ai bundle “' + String.join(quoteLinesWithoutBilling, ',') +'” non è stato associato un Metodo di Pagamento');
        }

        //Change Opportunity stage
        opportunitySrv.checkReadAccess('StageName');
        List<Opportunity> opps = opportunityQr.getRecordsBySaleFilterStageName(sale.Id, 'StageName', 'Proposal');
        
        for (Opportunity opp : opps) {
            opp.StageName = 'Closed Won';
        }
        opportunitySrv.updateRecords(opps);

        //Change SBQQ__Quote

    }
}
