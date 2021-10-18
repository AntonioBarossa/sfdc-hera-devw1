/**
 * @description       : Processing Asset for VAS orders
 * @author            : gabriele.rota@webresults.it
 * @group             : WR
 * @last modified on  : 2021-09-27
 * @last modified by  : gabriele.rota@webresults.it
 * Modifications Log 
 * Ver   Date         Author                        Modification
 * 1.0   2021-09-27   gabriele.rota@webresults.it   Initial Version
**/
public inherited sharing class HDT_UTL_AssetStatusVas {

    private static final String ORDER_VAS_RT = 'HDT_RT_VAS';
    private static final String ASSET_ACTIVE_STATUS = 'Attivo';
    
    /**
    * @description Prepopulating Assets status
    * @author gabriele.rota@webresults.it | 2021-09-27 
    * @param assets  
    **/
    public static void processAssets(List<Asset> assets, Map<Id, sobject> oldMap) {
        Set<Id> orderItemsIds = new Set<Id>();
        for (Asset asset:assets) {
            if (String.isNotBlank(asset.SBQQ__OrderProduct__c)) {
                orderItemsIds.add( asset.SBQQ__OrderProduct__c );
            }
        }

        Map<Id,Order> orderPerItem = new Map<Id,Order>();
        for (OrderItem ordItem:[SELECT Order.RecordType.DeveloperName, Order.VasPracticeCode__c, Order.ContractReference__c FROM OrderItem
                                WHERE Id IN :orderItemsIds WITH SECURITY_ENFORCED]) {
            orderPerItem.put( ordItem.Id, ordItem.Order );
        }

        for (Asset asset:assets) {
            if (String.isNotBlank(asset.SBQQ__OrderProduct__c)) {
                Order currentOrder = orderPerItem.get(asset.SBQQ__OrderProduct__c);
                Boolean isParentAsset = (asset.SBQQ__RootAsset__c==null);
                Boolean isVasOrder = (currentOrder.RecordType.DeveloperName==ORDER_VAS_RT);

                if (isVasOrder && isParentAsset && String.isBlank((String) oldMap?.get(asset.Id)?.get('DigitalAssetStatus'))) {//dont set status if was already setted
                    asset.DigitalAssetStatus = ASSET_ACTIVE_STATUS;//setting status to active
                    asset.Contract__c = currentOrder.ContractReference__c;
                    asset.VasPracticeCode__c = String.isNotBlank(asset.VasPracticeCode__c)? asset.VasPracticeCode__c : currentOrder.VasPracticeCode__c;//copying Vas fields from order
                }
            }
        }
    }
}
