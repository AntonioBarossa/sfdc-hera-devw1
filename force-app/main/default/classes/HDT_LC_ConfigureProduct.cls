public inherited sharing class HDT_LC_ConfigureProduct {
    
    private static HDT_QR_Quote quoteQR = new HDT_QR_Quote();
    private static HDT_QR_SaleServiceItem saleServiceItemQR = new HDT_QR_SaleServiceItem();
    private static HDT_SRV_SaleServiceItem saleServiceItemSRV = new HDT_SRV_SaleServiceItem();

    /**
     * Get SBQQ__Quote__c records to fill table
     * @param String Sale.Id
     * @return List<List<SaleServiceItem__c>>
     */
    @AuraEnabled
    public static List<List<SaleServiceItem__c>> getQuotes(String saleId){

        List<SBQQ__Quote__c> quoteRecords = quoteQR.getRecordsBySale(saleId);
        List<SaleServiceItem__C> itemRecords = saleServiceItemQR.getRecordsBySaleId(saleId);
        return saleServiceItemSRV.groupRecordsByQuote(quoteRecords, itemRecords);
    }
}
