/**
 * @description       : Controller for HDT_LCP_CloneCanceledOrder
 * @author            : gabriele.rota@webresults.it
 * @group             : WR
 * @last modified on  : 2021-08-02
 * @last modified by  : gabriele.rota@webresults.it
**/
public inherited sharing class HDT_LC_CloneCanceledOrder {

    private static final String CLONE_PERMISSION = 'HDT_CP_CloneCanceledOrder';
    private static final Integer CANCELLATION_EXPIRE_DAYS = 60;

    private static HDT_QR_Order orderQr = new HDT_QR_Order();
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();

    /**
    * @description Check if the order can be cloned and clone it if allowed
    * @author gabriele.rota@webresults.it | 2021-09-16 
    * @param orderId  
    **/
    @AuraEnabled
    public static void cloneOrder(Id orderId){

        if (!FeatureManagement.checkPermission(CLONE_PERMISSION)) {
            throw new AuraHandledException('L\'Utenza non è abilitata alla funzionalità Clona');
        }

        Order currentOrder = [SELECT CancellationRequestDate__c FROM Order WHERE Id = :orderId WITH SECURITY_ENFORCED LIMIT 1];
        Boolean isStillValid = (currentOrder.CancellationRequestDate__c!=null &&
            currentOrder.CancellationRequestDate__c.daysBetween(Date.today())<=CANCELLATION_EXPIRE_DAYS);

        if (!isStillValid) {
            throw new AuraHandledException('È possibile clonare gli Ordini solo nei primi '+CANCELLATION_EXPIRE_DAYS+' giorni dall\'annullamento');
        }

        try {
            currentOrder.Phase__c = 'Bozza';
            currentOrder.Status = 'In Lavorazione';
            currentOrder.IsCloned__c = true;
            currentOrder.Step__c = 2;
            
            currentOrder.IncomingCreditCheckResult__c = null;
            currentOrder.CreditCheckDescription__c = null;
            currentOrder.EffectiveDate__c = null;
            currentOrder.DateSentToSII__c = null;
            currentOrder.MaxAfterthoughtDate__c = null;
            currentOrder.WizardCompletedDate__c = null;
            currentOrder.PrecheckResultSII__c = null;
            /*@frpanico 16/12/2021 
            * Aggiunto devalorizzazione del campo 
            * CancellationRequestDate__c
            */
            currentOrder.CancellationRequestDate__c = null;

            List<ServiceRequest__c> servRequests = [SELECT Id FROM ServiceRequest__c WHERE Order__c=:orderId WITH SECURITY_ENFORCED];
            if (!servRequests.isEmpty()) {
                HDT_UTL_DatabaseService.deleteSObject(servRequests);
            }

            orderSrv.updateRecord(currentOrder);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static map<string,object> controllerInit(String saleId){
        return HDT_LC_ProcessesContainer.controllerInit(saleId);
    }

    @AuraEnabled
    public static map<string,object> controllerInitRedirect(String orderId){
        return HDT_LC_ProcessesContainer.controllerInitRedirect(orderId);
    }

    @AuraEnabled
    public static Map<String, Object> isCommunity(){
        return HDT_LC_ProcessesContainer.isCommunity();
    }
}
