/**
 * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
 * @date 16/02/2021
 * @description HDT_LC_OrderDossierWizardActions.cls - Class that holds methods that are called from hdtOrderDossierWizardActions.js
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */
public inherited sharing class HDT_LC_OrderDossierWizardActions {
    
    private static HDT_QR_Order orderQr = new HDT_QR_Order();
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 16/02/2021
    * @description Handle "stampa" action
    * @param Order orderParent
    */
    @AuraEnabled
    public static void save(Order orderParent){

        List<Order> childOrders = orderQr.getChildOrdersByParentId(orderParent.Id);
        List<Order> ordersToUpdate = new List<Order>();
        
        if (orderParent.ContractSigned__c == false) {

            //update child orders
            for (Order childOrder : childOrders) {
                ordersToUpdate.add(new Order(
                    Id = childOrder.Id,
                    //EVERIS: Aggiunto caso per Voltura 
                    Phase__c = childOrder.RecordType.DeveloperName == 'HDT_RT_Voltura' ? childOrder.Phase__c 
                    : checkRequiredDocs(childOrder) ? 'Documentazione Validata': 'In attesa validazione'
                ));
            }

            //update parent order
            ordersToUpdate.add(new Order(
                Id = orderParent.Id,
                Phase__c = 'Plico da inviare' //Everis: modificato in 'Plico da inviare poiche la fase 'Plico inviato da validare' non presente a DM'
            ));

        } else {

            //update child orders
            for (Order childOrder : childOrders) {
                ordersToUpdate.add(new Order(
                    Id = childOrder.Id,
                    Phase__c = checkRequiredDocs(childOrder) ? 'Documentazione Validata': 'In attesa validazione'
                ));
            }

            //update parent order
            ordersToUpdate.add(new Order(
                Id = orderParent.Id,
                Phase__c = 'Plico Firmato da validare'
            ));

        }

        orderSrv.updateRecords(ordersToUpdate);

    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 17/02/2021
    * @description Handle "Annulla" action
    * @param Order orderParent
    * @param String cancellationReason
    */
    @AuraEnabled
    public static void cancel(Order orderParent, String cancellationReason){
        
        List<Order> childOrders = orderQr.getChildOrdersByParentId(orderParent.Id);
        List<Order> ordersToUpdate = new List<Order>();

        //update child orders
        for (Order childOrder : childOrders) {
            ordersToUpdate.add(new Order(
                Id = childOrder.Id,
                Status = 'Annullato',
                Phase__c = 'Annullato',
                CancellationReason__c = cancellationReason
            ));
        }

        //update parent order
        ordersToUpdate.add(new Order(
            Id = orderParent.Id,
            Status = 'Annullato',
            Phase__c = 'Annullato',
            CancellationReason__c = cancellationReason
        ));

        orderSrv.updateRecords(ordersToUpdate);
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 16/02/2021
    * @description Check order required documents
    * @param Order ord
    * @return Boolean
    */
    public static Boolean checkRequiredDocs(Order ord){

        Boolean check = true;

        if(ord.AutorizationVolturaThirdTrader__c != null || ord.CILegalRepresentative__c != null ||  ord.CIAccoutn__c != null || ord.QuickQuote__c != null || ord.ChamberCommerceRegistration__c != null || ord.Instance326__c != null || ord.DocumentLow80__c != null)
        {
           	check = true;
            if(ord.CILegalRepresentative__c != null && !'Validato'.EqualsIgnoreCase(ord.CILegalRepresentative__c)){
                check = false;
            }
            if(ord.CIAccoutn__c != null && !'Validato'.EqualsIgnoreCase(ord.CIAccoutn__c)){
                check = false;
            }
            if(ord.QuickQuote__c != null && !'Validato'.EqualsIgnoreCase(ord.QuickQuote__c)){
                check = false;
            }
            if(ord.ChamberCommerceRegistration__c != null && !'Validato'.EqualsIgnoreCase(ord.ChamberCommerceRegistration__c)){
                check = false;
            }
            if(ord.Instance326__c != null && !'Validato'.EqualsIgnoreCase(ord.Instance326__c)){
                check = false;
            }
            if(ord.DocumentLow80__c != null && !'Validato'.EqualsIgnoreCase(ord.DocumentLow80__c)){
                check = false;
            }
            if(ord.AutorizationVolturaThirdTrader__c != null && !'Validato'.EqualsIgnoreCase(ord.AutorizationVolturaThirdTrader__c)){
                check = false;
            }
        } else if(ord.AutorizationVolturaThirdTrader__c == null && ord.CILegalRepresentative__c == null &&  ord.CIAccoutn__c == null && ord.QuickQuote__c == null && ord.ChamberCommerceRegistration__c == null && ord.Instance326__c == null && ord.DocumentLow80__c == null) {
            check = true;
        }

        return check;
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 16/02/2021
    * @description Check if save button should be disabled or not
    * @param String orderParentId
    * @return Boolean
    */
    @AuraEnabled
    public static Boolean isSaveDisabled(String orderParentId){
        Boolean result = false;
        
        List<Order> childOrders = orderQr.getChildOrdersByParentId(orderParentId);
        
        for (Order childOrder : childOrders) {
            if (childOrder.Step__c != 20) {
                result = true;
                break;
            }
        }

        return result;
    }

}