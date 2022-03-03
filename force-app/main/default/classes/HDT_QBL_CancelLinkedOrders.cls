public with sharing class HDT_QBL_CancelLinkedOrders implements Queueable,Database.AllowsCallouts {
    private Set<Id> canceledOrderIds;
    private Set<Id> canceledOrderQuotesIds;

    public HDT_QBL_CancelLinkedOrders(Set<Id> canceledOrderIds, Set<Id> canceledOrderQuotesIds) {
        this.canceledOrderIds = canceledOrderIds;
        this.canceledOrderQuotesIds = canceledOrderQuotesIds;
    }

    public void execute(QueueableContext context) {
        HDT_UTL_OrderTriggerVas.cancelLinkedOrders(canceledOrderIds, canceledOrderQuotesIds);
    }
}