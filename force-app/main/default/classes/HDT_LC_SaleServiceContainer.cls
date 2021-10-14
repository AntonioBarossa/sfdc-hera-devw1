/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 26/11/2020
* @description HDT_LC_SaleServiceContainer – Apex controller for hdtSaleServiceContainer.js component
* @history Keltin Mesonjesi – 23/11/2020 – Created class
*/
public inherited sharing class HDT_LC_SaleServiceContainer {
    private static HDT_QR_Contract contractQr = new HDT_QR_Contract();
    
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
        
        saleServiceItemSrv.checkReadAccess('Id, Status,AccountId,ServicePoint__c ');
        List<Contract> linkedContracts = contractQr.getRecordsWithContractsByServicePointAndAccountId(newServicePoint.Id, accountId);

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

        return isServicePointLinkedToContract(newServicePoint, accountId) && newServicePoint.RecordType.DeveloperName == 'HDT_RT_Ele' && newServicePoint.SupplyTypeTemp__c !=null && oldServicePoint.SupplyTypeTemp__c != newServicePoint.SupplyTypeTemp__c;

    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Create tile
     * @param ServicePoint__c servicePoint
     * @param Sale__c sale
     */
    @AuraEnabled
    public static Map<String,Boolean> createSaleServiceItemTile(ServicePoint__c servicePoint, Sale__c sale, ServicePoint__c oldServicePoint){
        
        Map<String,String> extraParams = new Map<String,String>();

        if (hasUsoEnergiaChangedForEle(sale.Account__c, servicePoint, oldServicePoint)) {
            List<Contract> linkedContracts = contractQr.getRecordsWithContractsByServicePointAndAccountId(servicePoint.Id, sale.Account__c);
            String contractReference = linkedContracts[0].id;
            extraParams.put('AllowChangeUse__c', 'true');
            extraParams.put('contractReference', contractReference);
        }

        saleServiceItemSrv.createRecord(servicePoint, sale, extraParams);
        boolean isTransition =HDT_UTL_Sales.isTransition(ServicePoint,sale);
        Map<String,Boolean> result = new Map<String,Boolean>{
            'isTransition'=>isTransition
        };
        return result;

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