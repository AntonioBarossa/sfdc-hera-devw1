/**
 * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
 * @date 30/10/2020
 * @description HDT_LC_ConfigureProduct.cls - Class that holds methods that are called from hdtConfigureProduct.js
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */
public inherited sharing class HDT_LC_ConfigureProduct {
    
    private static HDT_QR_Quote quoteQR = new HDT_QR_Quote();
    private static HDT_SRV_Quote quoteSRV = new HDT_SRV_Quote();
    private static HDT_QR_SaleServiceItem saleServiceItemQR = new HDT_QR_SaleServiceItem();
    private static HDT_SRV_SaleServiceItem saleServiceItemSRV = new HDT_SRV_SaleServiceItem();
    private static HDT_QR_QuoteLine quoteLineQR = new HDT_QR_QuoteLine();
    private static HDT_SRV_QuoteLine quoteLineSRV = new HDT_SRV_QuoteLine();
    private static HDT_QR_Opportunity opportunityQR = new HDT_QR_Opportunity();
    private static HDT_SRV_Opportunity opportunitySRV = new HDT_SRV_Opportunity();

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @date 18/11/2020
     * @description Get SBQQ__Quote__c and SBQQ__QuoteLine__c records to fill table
     * @param String Sale.Id
     * @return List<Map<String,List<SObject>>>
     */
    @AuraEnabled
    public static List<Map<String,List<SObject>>> getQuotes(String saleId){

        List<Map<String,List<SObject>>> resultsList = new List<Map<String,List<SObject>>>();

        List<SBQQ__Quote__c> quoteList = quoteQR.getRecordsBySaleFilterStatus(saleId, 'Rejected');
        List<SBQQ__QuoteLine__c> quoteLineList = quoteLineQR.getRecordsBySale(saleId);

        resultsList = quoteLineSRV.groupRecordsByQuote(quoteList, quoteLineList);

        return resultsList;
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @date 19/11/2020
     * @description Cancel SBQQ__Quote__c record by changing its status (Status=”Annullata”) and related Opportunity (StageName= “Chiusa/Annullata”)
     * @param String quoteId
     */
    @AuraEnabled
    public static void cancelQuote(String quoteId){

        SBQQ__Quote__c quoteToUpdate = quoteQR.getRecordById(quoteId);
        quoteToUpdate.SBQQ__Status__c = 'Rejected';

        Opportunity oppToUpdate = opportunityQR.getRecordById(quoteToUpdate.SBQQ__Opportunity2__c);
        oppToUpdate.StageName = 'Closed Lost';

        quoteSRV.updateRecord(quoteToUpdate);
        opportunitySRV.updateRecord(oppToUpdate);
    }
}
