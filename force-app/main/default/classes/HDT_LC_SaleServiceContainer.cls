/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 26/11/2020
* @description HDT_LC_SaleServiceContainer – Apex controller for hdtSaleServiceContainer.js component
* @history Keltin Mesonjesi – 23/11/2020 – Created class
*/
public inherited sharing class HDT_LC_SaleServiceContainer {
    
    private static HDT_SRV_SaleServiceItem saleServiceItemSRV = new HDT_SRV_SaleServiceItem();

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Create tile
     * @param ServicePoint__c servicePoint
     * @param Sale__c sale
     */
    @AuraEnabled
    public static void createSaleServiceItemTile(ServicePoint__c servicePoint, Sale__c sale){
        
        saleServiceItemSRV.createRecord(servicePoint, sale);

    }
}
