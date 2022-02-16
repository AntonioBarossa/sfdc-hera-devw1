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

        system.debug(LoggingLevel.DEBUG,'list ordItems'+orderItemsIds);

        Map<Id,Order> orderPerItem = new Map<Id,Order>();
        Set<id> orderReferenceIds = new Set<id>();
        for (OrderItem ordItem:[SELECT Order.RecordType.DeveloperName,Order.ActivatedDate, Order.CreatedDate, Order.VasPracticeCode__c, Order.ContractReference__c, Order.OrderReference__c FROM OrderItem
                                WHERE Id IN :orderItemsIds WITH SECURITY_ENFORCED]) {
            orderPerItem.put( ordItem.Id, ordItem.Order );
            if(ordItem.Order.OrderReference__c!=null){
                orderReferenceIds.add(ordItem.Order.OrderReference__c);
            }
        }

        Map<Id, Contract> referenceToContract = new Map<Id, Contract>();
        if(!orderReferenceIds.isEmpty()){
            for(Contract c : [Select SBQQ__Order__c from Contract where SBQQ__Order__c IN :orderReferenceIds WITH SECURITY_ENFORCED]){
                referenceToContract.put(c.SBQQ__Order__c, c);
            }
        }

        system.debug(LoggingLevel.DEBUG,'list map '+orderPerItem);
        for (Asset asset:assets) {
            if (String.isNotBlank(asset.SBQQ__OrderProduct__c)) {
                Order currentOrder = orderPerItem.get(asset.SBQQ__OrderProduct__c);
                //Boolean isParentAsset = (asset.SBQQ__RootAsset__c==null);
                Boolean isVasOrder = (currentOrder.RecordType.DeveloperName==ORDER_VAS_RT);

                /**@frpanico 16/02/2022
                 * Rimosso il controllo sul parent asset
                 * Per far valorizzare i campi su tutti
                 * Gli asset del bundle
                 */
                if (isVasOrder) {//dont set status if was already setted
                    asset.DigitalAssetStatus =  String.isBlank((String) oldMap?.get(asset.Id)?.get('DigitalAssetStatus'))? ASSET_ACTIVE_STATUS : asset.DigitalAssetStatus;//setting status to active
                    asset.Contract__c = currentOrder.ContractReference__c!=null? currentOrder.ContractReference__c : referenceToContract.get(currentOrder.OrderReference__c)?.Id;
                    asset.VasPracticeCode__c = String.isNotBlank(asset.VasPracticeCode__c)? asset.VasPracticeCode__c : currentOrder.VasPracticeCode__c;//copying Vas fields from order
                    /**@frpanico 16/02/2022
                     * Aggiunta campi Data
                     * PurchaseDate, InstallDate
                     */
                    asset.PurchaseDate = Date.valueOf(currentOrder.CreatedDate);
                    asset.InstallDate = currentOrder.ActivatedDate != null ? Date.valueOf(currentOrder.ActivatedDate) : null;
                
                }
            }
        }
    }
}
