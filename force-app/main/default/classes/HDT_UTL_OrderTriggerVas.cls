/**
 * @description       : Processing Orders for VAS process
 * @author            : gabriele.rota@webresults.it
 * @group             : WR
 * @last modified on  : 2021-09-28
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
        for (Order newOrder : (List<Order>)newMap.values()) {
            Order oldOrder = (Order) oldMap.get(newOrder.Id);
            if (newOrder.RecordTypeId!=VAS_RT && newOrder.RecordTypeId!=SCONTIBONUS_RT && (newOrder.Status==STATUS_CANCELLED && oldOrder.Status!=STATUS_CANCELLED)) {
                canceledOrderIds.add( newOrder.Id );
                canceledOrderQuotesIds.add(newOrder.SBQQ__Quote__c);
            }
        }
        if(canceledOrderIds.isEmpty() && canceledOrderQuotesIds.isEmpty())
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
        List<Order> vasOrdersToCancel = [SELECT Id FROM Order WHERE RecordType.DeveloperName IN('HDT_RT_VAS','HDT_RT_ScontiBonus') AND (OrderReference__c IN :canceledOrderIds OR SBQQ__Quote__c IN :canceledOrderQuotesIds) WITH SECURITY_ENFORCED];
        if(vasOrdersToCancel.isEmpty())
            return;
        for (Order vasOrder:vasOrdersToCancel) {
            vasOrder.Phase__c = PHASE_CANCELLED;
            vasOrder.Status = STATUS_CANCELLED;
        }

        orderSrv.updateRecords(vasOrdersToCancel);
    }
}
