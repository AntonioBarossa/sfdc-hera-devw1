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
    public static Map<String,List<List<SObject>>> getTiles(String saleId){

        opportunityService.checkReadAccess('Name, CreatedDate');
        saleServiceItemSRV.checkReadAccess('Opportunity__c,Opportunity__r.Sale__c,Opportunity__r.Name,Opportunity__r.CreatedDate,Quote__c,Quote__r.Name,ServicePoint__c,ServicePoint__r.ServicePointCode__c,ServicePoint__r.RecordType.Name,ServicePoint__r.RecordType.DeveloperName,ServicePoint__r.SupplyCity__c');

        List<Opportunity> opps = opportunityQuery.getRecordsBySaleFilterStageNameNotVas(saleId, 'Id,Name,CreatedDate', 'Closed Lost');
        List<SaleServiceItem__c> items = saleServiceItemQuery.getRecordsBySaleId(saleId);
        List<List<SaleServiceItem__c>> saleServiceItemsTiles = itemsService.groupRecordsByOpportunity(opps, items);

        opportunityService.checkReadAccess('Name,SBQQ__PrimaryQuote__r.OrderReference__c,SBQQ__PrimaryQuote__r.OrderReference__r.Name,SBQQ__PrimaryQuote__r.OrderReference__r.OrderNumber,SBQQ__PrimaryQuote__r.ContractReference__c,SBQQ__PrimaryQuote__r.ContractReference__r.ContractNumber,SBQQ__PrimaryQuote__r.SupplyCity__c,CreatedDate');
        List<Opportunity> oppsVasList = opportunityQuery.getRecordsBySaleFilteredVas(saleId);
        List<List<Opportunity>> vasTiles = new List<List<Opportunity>>();
        vasTiles.add(oppsVasList);

        Map<String,List<List<SObject>>> results = new Map<String,List<List<SObject>>>();
        results.put('saleServiceItemsTiles', saleServiceItemsTiles);
        results.put('vasTiles', vasTiles);

        return results;

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
