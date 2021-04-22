/**
 * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
 * @date 13/02/2021
 * @description HDT_LC_ChildOrderProcessDetails.cls - Class that holds methods that are called from hdtChildOrderProcessDetails.js
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */
public inherited sharing class HDT_LC_ChildOrderProcessDetails {
    
    private static HDT_QR_Order orderQr = new HDT_QR_Order();
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();
    private static HDT_SRV_ServicePoint servicePointSrv= new HDT_SRV_ServicePoint();
    private static HDT_SRV_BillingProfile billingProfileSrv = new HDT_SRV_BillingProfile();
    private static HDT_SRV_Account accountSrv = new HDT_SRV_Account();

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description Update order process step
    * @param Order order
    * @param Decimal step
    * @param String objectApiName
    * @param SObject objectToUpdate
    */
    @AuraEnabled
    public static void updateProcessStep(Order order){
        system.debug('updateProcessStep: ' + order);
        orderSrv.updateRecord(order);
    }

}
