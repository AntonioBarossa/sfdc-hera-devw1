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
    private static HDT_QR_Case caseQr = new HDT_QR_Case();

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description Update order process step
    * @param Order order
    * @param Decimal step
    * @param String objectApiName
    * @param SObject objectToUpdate
    */
    @AuraEnabled
    public static void updateProcessStep(Order order,
        //INIZIO SVILUPPI EVERIS 
        Boolean isVolture,
        Boolean isRetroactive,
        Boolean isReading){
        //FINE SVILUPPI EVERIS

        System.debug('updateProcessStep: ' + order);
        System.debug('isVolture: '+isVolture);

        if(isVolture == null){
            isVolture = false;
        }

        //INIZIO SVILUPPI EVERIS CHECK VOLTURA
        if(isVolture != null && isVolture == true){
            //Commentato finche non viene creato campo a DM
            /*if(order.NonRegMeter__c != null && order.NonRegMeter__c == true){
                if(caseQr.getChageNonRegMeterByOrder(order.Id).size() == 0){                
                    throw new AuraHandledException('Necessario completare un Case di \'Cambio Contatore Non Registrato\'');
                
                }
            } else*/ if(order.EffectiveDate__c != null && order.EffectiveDate__c < orderSrv.addBusinessDay(System.today(),3)){

                if(orderQr.getRoleNameByRoleId() != 'CEO'){

                    throw new AuraHandledException('Impossibile inserire una data inferiore a 3 gg lavorativi');


                } else{

                    order.RetroactiveDate__c = order.EffectiveDate__c;
                    order.Subprocess__c = 'Retroattiva';

                }

            } else if(isReading != null && isReading == true && isRetroactive != null && isRetroactive == false){

                order.Subprocess__c = 'Con Autolettura';

            } 
        }
        //FINE SVILUPPI EVERIS CHECK VOLTURA 

        orderSrv.updateRecord(order);
    }

}