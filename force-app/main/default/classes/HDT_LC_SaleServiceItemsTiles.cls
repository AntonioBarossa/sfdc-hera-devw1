public with sharing class HDT_LC_SaleServiceItemsTiles {
    
    private static HDT_QR_SaleServiceItem saleServiceItemQuery = new HDT_QR_SaleServiceItem();

    /**
     * Get list of tiles
     * @return List<SaleServiceItems__c>
     */
    @AuraEnabled
    public static List<SaleServiceItem__c> getTiles(String saleId){

        return saleServiceItemQuery.getRecordsBySaleId(saleId);

    }

}
