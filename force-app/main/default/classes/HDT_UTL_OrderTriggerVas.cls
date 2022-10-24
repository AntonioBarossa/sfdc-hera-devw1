/**
 * @description       : Processing Orders for VAS process
 * @author            : gabriele.rota@webresults.it
 * @group             : WR
 * @last modified on  : 10-24-2022
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
            ordersToWork = [SELECT Id, isBillableVas__c,Contact__c, CancellationReason__c, OrderReference__c, SBQQ__Quote__c, RecordType.DeveloperName FROM Order WHERE OrderReference__c IN :canceledOrderIds WITH SECURITY_ENFORCED];
        }else if (!canceledOrderIds.isEmpty()){
            ordersToWork = [SELECT Id, isBillableVas__c, Contact__c, CancellationReason__c, OrderReference__c, SBQQ__Quote__c, RecordType.DeveloperName FROM Order WHERE OrderReference__c IN :canceledOrderIds OR SBQQ__Quote__c IN :canceledOrderQuotesIds WITH SECURITY_ENFORCED];
        }

       

        if(ordersToWork.isEmpty()){
            return;
        }
        List<Order> ordersToCancel = new List<Order>();
        //Map<Id,Order> commodityOrderMap = new Map<Id,Order>();
        Map<Id,Id> mapQuoteContactId = new Map<Id,Id>();
        Map<Id,Id> mapOrderContactId = new Map<Id,Id>();
        Map<Id,Order> orderToCheckVas = new Map<Id,Order>();
        for (Order orderToWork:ordersToWork) {
            if (canceledOrderIds.contains(orderToWork.Id) && orderToWork.Contact__c != null){
                mapQuoteContactId.put(orderToWork.SBQQ__Quote__c,orderToWork.Contact__c);
                mapOrderContactId.put(orderToWork.Id,orderToWork.Contact__c);
                continue;
            }
            switch on orderToWork.RecordType.DeveloperName {
                when 'HDT_RT_VAS','HDT_RT_ScontiBonus', 'HDT_RT_AgevolazioniAmbiente', 'HDT_RT_ModificaTariffaRimozione' {
                    ordersToCancel.add(orderToWork);
                }
                when 'HDT_RT_Default'{
                    //verifyDraftVas(orderToWork,vasOrdersToCancel);
                    orderToCheckVas.put(orderToWork.Id, orderToWork);
                }
            }
        }
        if (verifyDraftVas(orderToCheckVas)){
            vasOrdersToCancel.addAll(orderToCheckVas.values());
        }   
        for (Order vasOrder:vasOrdersToCancel) {
            vasOrder.Phase__c = PHASE_CANCELLED;
            vasOrder.Status = STATUS_CANCELLED;
            if (vasOrder.Contact__c == null && (mapQuoteContactId.containsKey(vasOrder.SBQQ__Quote__c) || (vasOrder.OrderReference__c != null && mapOrderContactId.containsKey(vasOrder.OrderReference__c)))){
                vasOrder.Contact__c = mapQuoteContactId.containsKey(vasOrder.SBQQ__Quote__c)? mapQuoteContactId.get(vasOrder.SBQQ__Quote__c) : mapOrderContactId.get(vasOrder.OrderReference__c);
            }
            vasOrder.CancellationReason__c = 'Annullamento Ordine di Riferimento';
        }

        orderSrv.updateRecords(ordersToCancel);
    }

    /* 
    private static void verifyDraftVas(Order orderToWork,List<Order> vasOrdersToCancel){
        if (orderToWork.isBillableVas__c){
            vasOrdersToCancel.add(orderToWork);
        }
    } 
    */

    private static Boolean verifyDraftVas(Map<Id,Order> orderToCheckVas){
        if (orderToCheckVas.isEmpty()){
            return false;
        }
        for (Order o : [
            SELECT id,isVas__c,VasSubType__c,CommodityFormula__c,PowerRequested__c,PowerCommitted__c, ServicePoint__r.Account__c,AccountId,SBQQ__Quote__r.AmendmentAllowed__c,ServicePoint__r.PlugPresence__c,ServicePoint__r.SAPContractStatus__c,ServicePoint__r.isReseller__c,IsWinback__c
            FROM Order 
            WHERE Id IN :orderToCheckVas.keySet() 
            //condizione per toglere i vas dalla query
            WITH SECURITY_ENFORCED]
        ){

            Boolean plugPresence = o.ServicePoint__r.PlugPresence__c == null ? true : o.ServicePoint__r.PlugPresence__c.containsIgnoreCase('Si');
            Boolean isPowerChange = 'Energia Elettrica'.equalsIgnoreCase(o.CommodityFormula__c) && o.PowerRequested__c != null && o.PowerRequested__c!= o.PowerCommitted__c;

            
            if (
                //Condizione per vas
                (o.isVas__c) 
                || ('Analisi Consumi'.equalsIgnoreCase(o.VasSubType__c))
                //Condizione per Sconti e bonus
                || ('Attivo'.equalsIgnoreCase(o.ServicePoint__r.SAPContractStatus__c) 
                && plugPresence 
                && o.ServicePoint__r.Account__c == o.AccountId 
                && !o.ServicePoint__r.isReseller__c
                && !o.IsWinback__c
                && !isPowerChange
                && o.SBQQ__Quote__r.AmendmentAllowed__c)
            ){
                continue;
            }
            orderToCheckVas.remove(o.Id);
        }
        if (orderToCheckVas.isEmpty()){
            return false;
        }
        return true;
    }

}
