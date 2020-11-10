public with sharing class HDT_LC_ConfigureProduct {
    
    private static HDT_QR_SaleServiceItem saleServiceItemQR = new HDT_QR_SaleServiceItem();

    /**
     * Get SBQQ__Quote__c records to fill table
     * @param String Sale.Id
     * @return List<SaleServiceItem__c>
     */
    @AuraEnabled
    public static List<SaleServiceItem__c> getQuotes(String saleId){
        return saleServiceItemQR.getRecordsGroupedByQuote(saleId);
    }
}
