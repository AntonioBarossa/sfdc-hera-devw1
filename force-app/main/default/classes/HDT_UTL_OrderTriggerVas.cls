/**
 * @description       : Processing Orders for VAS process
 * @author            : gabriele.rota@webresults.it
 * @group             : WR
 * @last modified on  : 09-12-2022
 * @last modified by  : gabriele.rota@webresults.it
 * Modifications Log 
 * Ver   Date         Author                        Modification
 * 1.0   2021-09-28   gabriele.rota@webresults.it   Initial Version
**/
public inherited sharing class HDT_UTL_OrderTriggerVas {

    private static final String STATUS_CANCELLED = 'Annullato';
    private static final String PHASE_CANCELLED = 'Annullato';
    private static final Id VAS_RT = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_VAS').getRecordTypeId();
    private static final Id SCONTIBONUS_RT = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_ScontiBonus').getRecordTypeId();
    private static final Id AGEVOLAZIONI_RT = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_AgevolazioniAmbiente').getRecordTypeId();
    private static final Id RIMOZ_AGEV_RT = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_ModificaTariffaRimozione').getRecordTypeId();

    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();
    
    /**
    * @description Cancel VAS orders when commodity orders is canceled
    * @author gabriele.rota@webresults.it | 2021-09-27 
    * @param newMap  
    * @param oldMap  
    **/
    public static void cancelLinkedVasOrders(Map<Id,SObject> newMap, Map<Id,SObject> oldMap) {

        Set<Id> canceledOrderIds = new Set<Id>();
        Set<Id> canceledOrderQuotesIds = new Set<Id>();
        Set<Id> excludedRecTypes = new Set<Id>{VAS_RT, SCONTIBONUS_RT, AGEVOLAZIONI_RT, RIMOZ_AGEV_RT};

        for (Order newOrder : (List<Order>)newMap.values()) {
            Order oldOrder = (Order) oldMap.get(newOrder.Id);
            if (!excludedRecTypes.contains(newOrder.RecordTypeId) && (newOrder.Status==STATUS_CANCELLED && oldOrder.Status!=STATUS_CANCELLED)) {
                canceledOrderIds.add( newOrder.Id );
                if (newOrder.SBQQ__Quote__c != null){
                    canceledOrderQuotesIds.add(newOrder.SBQQ__Quote__c);
                }
            }
        }
        if(canceledOrderIds.isEmpty() /* && canceledOrderQuotesIds.isEmpty() */)
            return;

        Boolean limitQueueablesOk = Limits.getQueueableJobs() < Limits.getLimitQueueableJobs();

        if(limitQueueablesOk){
            //enqueueJob
            System.enqueueJob(new HDT_QBL_CancelLinkedOrders(canceledOrderIds, canceledOrderQuotesIds));
        }
        else{
            cancelLinkedOrders(canceledOrderIds, canceledOrderQuotesIds);
        }
    }

    public static void cancelLinkedOrders(Set<Id> canceledOrderIds, Set<Id> canceledOrderQuotesIds){
        List<Order> ordersToWork = new List<Order>();
        if(!canceledOrderIds.isEmpty() && canceledOrderQuotesIds.isEmpty()){
            ordersToWork = [SELECT Id, isBillableVas__c, CancellationReason__c, OrderReference__c, SBQQ__Quote__c, RecordType.DeveloperName FROM Order WHERE OrderReference__c IN :canceledOrderIds WITH SECURITY_ENFORCED];
        }else if (!canceledOrderIds.isEmpty()){
            ordersToWork = [SELECT Id, isBillableVas__c, CancellationReason__c, OrderReference__c, SBQQ__Quote__c, RecordType.DeveloperName FROM Order WHERE OrderReference__c IN :canceledOrderIds OR SBQQ__Quote__c IN :canceledOrderQuotesIds WITH SECURITY_ENFORCED];
        }

       

        if(ordersToWork.isEmpty()){
            return;
        }
        List<Order> ordersToCancel = new List<Order>();
        //Map<Id,Order> commodityOrderMap = new Map<Id,Order>();
        for (Order orderToWork:ordersToWork) {
            switch on orderToWork.RecordType.DeveloperName {
                when 'HDT_RT_VAS','HDT_RT_ScontiBonus', 'HDT_RT_AgevolazioniAmbiente', 'HDT_RT_ModificaTariffaRimozione' {
                    ordersToCancel.add(orderToWork);
                }
                when 'HDT_RT_Default'{
                    verifyDraftVas(orderToWork,ordersToCancel);
                }
                /* when else {
                    setCommodityOrderMap(orderToWork, commodityOrderMap,canceledOrderIds);
                } */
            }
        }
        for (Order vasOrder:ordersToCancel) {
            vasOrder.Phase__c = PHASE_CANCELLED;
            vasOrder.Status = STATUS_CANCELLED;
            /* String cancellationReason;
            if (vasOrder.OrderReference__c != null && commodityOrderMap.containsKey(vasOrder.OrderReference__c)){
                cancellationReason = commodityOrderMap.get(vasOrder.OrderReference__c).CancellationReason__c;

            }else if (commodityOrderMap.containsKey(vasOrder.SBQQ__Quote__c)){
                cancellationReason = commodityOrderMap.get(vasOrder.SBQQ__Quote__c).CancellationReason__c;
            }
            vasOrder.CancellationReason__c = cancellationReason; */
            vasOrder.CancellationReason__c = 'Annullamento Ordine di Riferimento';
        }

        orderSrv.updateRecords(ordersToCancel);
    }

    private static void verifyDraftVas(Order orderToWork,List<Order> vasOrdersToCancel){
        if (orderToWork.isBillableVas__c){
            vasOrdersToCancel.add(orderToWork);
        }
    }

    /* private static void setCommodityOrderMap(Order ord, Map<Id,Order> commodityOrderMap, Set<Id> canceledOrderIds){
        if (canceledOrderIds.contains(ord.Id)){
            commodityOrderMap.put(ord.Id,ord);
            if (ord.SBQQ__Quote__c != null){
                commodityOrderMap.put(ord.SBQQ__Quote__c,ord);
            }
        }
    } */
}
