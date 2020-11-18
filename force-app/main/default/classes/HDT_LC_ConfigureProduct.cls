/**
 * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
 * @date 30/10/2020
 * @description HDT_LC_ConfigureProduct.cls - Class that holds methods that are called from hdtConfigureProduct.js
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */
public inherited sharing class HDT_LC_ConfigureProduct {
    
    private static HDT_QR_Quote quoteQR = new HDT_QR_Quote();
    private static HDT_QR_SaleServiceItem saleServiceItemQR = new HDT_QR_SaleServiceItem();
    private static HDT_SRV_SaleServiceItem saleServiceItemSRV = new HDT_SRV_SaleServiceItem();
    private static HDT_QR_QuoteLine quoteLineQR = new HDT_QR_QuoteLine();
    private static HDT_SRV_QuoteLine quoteLineSRV = new HDT_SRV_QuoteLine();

    /**
     * @author Keltin Mesonjesi
     * @date 18/11/2020
     * @description Get SBQQ__Quote__c and SBQQ__QuoteLine__c records to fill table
     * @param String Sale.Id
     * @return List<Map<String,List<SObject>>>
     */
    @AuraEnabled
    public static List<Map<String,List<SObject>>> getQuotes(String saleId){

        List<Map<String,List<SObject>>> resultsList = new List<Map<String,List<SObject>>>();

        try {
            List<SBQQ__Quote__c> quoteList = quoteQR.getRecordsBySale(saleId);
            List<SBQQ__QuoteLine__c> quoteLineList = quoteLineQR.getRecordsBySale(saleId);

            resultsList = quoteLineSRV.groupRecordsByQuote(quoteList, quoteLineList);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return resultsList;
    }
}
