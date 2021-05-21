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
        Boolean isReading,
        Date readingDate){
        //FINE SVILUPPI EVERIS

        System.debug('updateProcessStep: ' + order);
        System.debug('isVolture: '+isVolture);

        //INIZIO SVILUPPI EVERIS CHECK VOLTURA
        if(isVolture != null && isVolture == true){
            //Commentato finche non viene creato campo a DM
            if(order.NotRegisteredMeterCase__c != null && order.NotRegisteredMeterCase__c == true){
                if(caseQr.getChageNonRegMeterByOrder(order.Id).size() == 0){                
                    throw new AuraHandledException('Necessario completare un Case di \'Cambio Contatore Non Registrato\'');
                
                }
            } else if(order.EffectiveDate__c != null && order.EffectiveDate__c < orderSrv.addBusinessDay(System.today(),3)){

                if(orderQr.getRoleNameByRoleId() != 'CEO'){

                    throw new AuraHandledException('Impossibile inserire una data inferiore a 3 gg lavorativi');

                } else{

                    order.RetroactiveDate__c = order.EffectiveDate__c;
                    order.Subprocess__c = 'Retroattiva';

                }

            } else if(isReading != null && isReading == true && isRetroactive != null && isRetroactive == false){

                order.Subprocess__c = 'Con Autolettura';

            }

            if(readingDate != null && (isReading != null && isReading == true)){

                order.ReadingCustomerDate__c = readingDate;

            }
        }
        //FINE SVILUPPI EVERIS CHECK VOLTURA 

        exeChecks(order);

        orderSrv.updateRecord(order);
    }

    private static void exeChecks(Order order){
        //Check RequestOption__c (Opzione di Distribuzione) START
        if(order.ImplantType__c != null && order.PowerCommitted__c != null){
            orderSrv.checkReadAccess('RequestOption__c');
            Order oldOrder = orderQr.getRecordById(order.Id);

            String calculatedRequestOption = HDT_UTL_OrderFieldsAlignment.calculateRequestedOption(oldOrder.ImplantType__c, oldOrder.PowerCommitted__c);

            if (calculatedRequestOption != oldOrder.RequestOption__c) {
                throw new AuraHandledException('Il campo Opzione di Distribuzione e stato cambiato');
            }
        } else if(order.RequestOption__c != null){
            orderSrv.checkReadAccess('RequestOption__c');
            Order oldOrder = orderQr.getRecordById(order.Id);

            if (order.RequestOption__c != '' && oldOrder.RequestOption__c != null && order.RequestOption__c != oldOrder.RequestOption__c) {
                throw new AuraHandledException('Il campo Opzione di Distribuzione e stato cambiato');
            }
        }
        //Check RequestOption__c (Opzione di Distribuzione) END
    }

}