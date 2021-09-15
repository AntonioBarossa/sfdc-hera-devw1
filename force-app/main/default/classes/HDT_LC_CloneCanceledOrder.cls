/**
 * @description       : Controller for HDT_LCP_CloneCanceledOrder
 * @author            : gabriele.rota@webresults.it
 * @group             : WR
 * @last modified on  : 2021-08-02
 * @last modified by  : gabriele.rota@webresults.it
**/
public with sharing class HDT_LC_CloneCanceledOrder {

    private static final String CLONE_PERMISSION = 'HDT_CP_CloneCanceledOrder';
    private static final Integer CANCELLATION_EXPIRE_DAYS = 60;

    private static HDT_QR_Order orderQr = new HDT_QR_Order();
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();

    @AuraEnabled
    public static Boolean isCloneAllowed(Id orderId){
        Boolean permissionCheck = FeatureManagement.checkPermission(CLONE_PERMISSION);

        Order currentOrder = [SELECT CancellationRequestDate__c FROM Order WHERE Id = :orderId WITH SECURITY_ENFORCED LIMIT 1];
        Boolean dateCheck = (currentOrder.CancellationRequestDate__c!=null &&
            currentOrder.CancellationRequestDate__c.daysBetween(Date.today())<=CANCELLATION_EXPIRE_DAYS);

        return (permissionCheck && dateCheck);
    }

    @AuraEnabled
    public static Id cloneOrder(Id orderId){
        Order currentOrder = new Order(Id=orderId);
        currentOrder.Phase__c = 'Bozza';
        currentOrder.Status = 'In Lavorazione';
        currentOrder.IsCloned__c = true;
        currentOrder.IncomingCreditCheckResult__c = null;
        orderSrv.updateRecord(currentOrder);
        return orderId;
    }
}
