public with sharing class HDT_LC_SaleServiceItemsTiles {
    
    private static HDT_QR_Opportunity opportunityQuery = new HDT_QR_Opportunity();
    private static HDT_QR_SaleServiceItem saleServiceItemQuery = new HDT_QR_SaleServiceItem();
    private static HDT_SRV_SaleServiceItem itemsService = new HDT_SRV_SaleServiceItem();

    /**
     * Get list of tiles
     * @return List<SaleServiceItems__c>
     */
    @AuraEnabled
    public static List<List<SaleServiceItem__c>> getTiles(String saleId){

        List<Opportunity> opps = opportunityQuery.getRecordsBySale(saleId, 'Id,Name');
        List<SaleServiceItem__c> items = saleServiceItemQuery.getRecordsBySaleId(saleId);

        return itemsService.groupRecordsByOpportunity(opps, items);

    }

}
