/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 27/11/2020
* @description Apex controller for hdtSaleServiceItemsTiles.js component
* @history Keltin Mesonjesi – 27/11/2020 – Created class
*/
public inherited sharing class HDT_LC_SaleServiceItemsTiles {
    
    private static HDT_QR_Opportunity opportunityQuery = new HDT_QR_Opportunity();
    private static HDT_QR_SaleServiceItem saleServiceItemQuery = new HDT_QR_SaleServiceItem();
    private static HDT_SRV_SaleServiceItem saleServiceItemSrv = new HDT_SRV_SaleServiceItem();
    private static HDT_SRV_SaleServiceItem itemsService = new HDT_SRV_SaleServiceItem();
    private static HDT_SRV_Opportunity opportunityService = new HDT_SRV_Opportunity();

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Get list of tiles
     * @param String saleId
     * @return List<SaleServiceItems__c>
     */
    @AuraEnabled
    public static List<List<SaleServiceItem__c>> getTiles(String saleId){

        opportunityService.checkReadAccess('Name');
        saleServiceItemSRV.checkReadAccess('Opportunity__c,Opportunity__r.Sale__c,Opportunity__r.Name,Quote__c,Quote__r.Name,ServicePoint__c,ServicePoint__r.ServicePointCode__c,ServicePoint__r.RecordType.Name,ServicePoint__r.RecordType.DeveloperName,ServicePoint__r.SupplyCity__c');

        List<Opportunity> opps = opportunityQuery.getRecordsBySaleFilterStageName(saleId, 'Id,Name', 'Closed Lost');
        List<SaleServiceItem__c> items = saleServiceItemQuery.getRecordsBySaleId(saleId);

        return itemsService.groupRecordsByOpportunity(opps, items);

    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Delete single tile
     * @param String opportunityId
     */
    @AuraEnabled
    public static void deleteTile(String opportunityId){
        opportunityService.deleteRecord(opportunityId);
    }

}
