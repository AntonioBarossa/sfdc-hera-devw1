/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 26/11/2020
* @description HDT_LC_SaleServiceContainer – Apex controller for hdtSaleServiceContainer.js component
* @history Keltin Mesonjesi – 23/11/2020 – Created class
*/
public inherited sharing class HDT_LC_SaleServiceContainer {
    
    private static HDT_QR_SaleServiceItem saleServiceItemQr = new HDT_QR_SaleServiceItem();
    private static HDT_SRV_SaleServiceItem saleServiceItemSrv = new HDT_SRV_SaleServiceItem();
    private static HDT_SRV_Sale saleSrv = new HDT_SRV_Sale();

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Check if service point for current sale account is linked to quotes that have a contract
     * @param String accountId
     * @param ServicePoint__c newServicePoint
     */
    private static Boolean isServicePointLinkedToContract(ServicePoint__c newServicePoint, String accountId) {
        
        saleServiceItemSrv.checkReadAccess('Quote__c,Quote__r.ContractReference__c,Opportunity__c,Opportunity__r.CreatedDate');
        List<SaleServiceItem__c> linkedContracts = saleServiceItemQr.getRecordsWithContractsByServicePointAndAccount(newServicePoint.Id, accountId);

        return !linkedContracts.isEmpty();
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Check if field "Uso Energia" has been changed on confirmation for service point
     * @param String accountId
     * @param ServicePoint__c newServicePoint
     * @param ServicePoint__c oldServicePoint
     */
    private static Boolean hasUsoEnergiaChangedForEle(String accountId, ServicePoint__c newServicePoint, ServicePoint__c oldServicePoint) {

        return isServicePointLinkedToContract(newServicePoint, accountId) && newServicePoint.RecordType.DeveloperName == 'HDT_RT_Ele' && oldServicePoint.SupplyType__c !=null && newServicePoint.SupplyType__c != oldServicePoint.SupplyType__c;

    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Create tile
     * @param ServicePoint__c servicePoint
     * @param Sale__c sale
     */
    @AuraEnabled
    public static void createSaleServiceItemTile(ServicePoint__c servicePoint, Sale__c sale, ServicePoint__c oldServicePoint){
        
        Map<String,String> extraParams = new Map<String,String>();

        if (hasUsoEnergiaChangedForEle(sale.Account__c, servicePoint, oldServicePoint)) {
            List<SaleServiceItem__c> linkedContracts = saleServiceItemQr.getRecordsWithContractsByServicePointAndAccount(servicePoint.Id, sale.Account__c);
            String contractReference = linkedContracts[0].Quote__r.ContractReference__c;
            extraParams.put('AllowChangeUse__c', 'true');
            extraParams.put('contractReference', contractReference);
        }

        saleServiceItemSrv.createRecord(servicePoint, sale, extraParams);

    }
    
    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Update Sale
     * @param Sale__c sale
     */
    @AuraEnabled
    public static void updateSale(Sale__c sale){
        saleSrv.updateRecord(sale);
    }
}
