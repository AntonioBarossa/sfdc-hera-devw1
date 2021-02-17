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
                    Phase__c = checkRequiredDocs(childOrder) ? 'Comunicazione verso Heroku OK': 'In attesa validazione'
                ));
            }

            //update parent order
            ordersToUpdate.add(new Order(
                Id = orderParent.Id,
                Phase__c = 'Plico inviato da validare'
            ));

        } else {

            //update child orders
            for (Order childOrder : childOrders) {
                ordersToUpdate.add(new Order(
                    Id = childOrder.Id,
                    Phase__c = checkRequiredDocs(childOrder) ? 'Comunicazione verso Heroku OK': 'In attesa validazione'
                ));
            }

            //update parent order
            ordersToUpdate.add(new Order(
                Id = orderParent.Id,
                Phase__c = 'Plico validato Firmato'
            ));

            system.debug('HDT_LC_OrderDossierWizardActions - save: orderParent.ContractSigned__c is true');
        }

        orderSrv.updateRecords(ordersToUpdate);

    }

    public static Boolean checkRequiredDocs(Order ord){

        Boolean check;

        if(ord.CiRappresentateLegale__c != null ||  ord.CiCliente__c != null || ord.PreventivoRapido__c != null || ord.VisuraCamerale__c != null || ord.Istanza326__c != null || ord.DocLegge80__c != null)
        {
           	check = true;
            if(ord.CiRappresentateLegale__c != null && !'Validato'.EqualsIgnoreCase(ord.CiRappresentateLegale__c)){
                check = false;
            }
            if(ord.CiCliente__c != null && !'Validato'.EqualsIgnoreCase(ord.CiCliente__c)){
                check = false;
            }
            if(ord.PreventivoRapido__c != null && !'Validato'.EqualsIgnoreCase(ord.PreventivoRapido__c)){
                check = false;
            }
            if(ord.VisuraCamerale__c != null && !'Validato'.EqualsIgnoreCase(ord.VisuraCamerale__c)){
                check = false;
            }
            if(ord.Istanza326__c != null && !'Validato'.EqualsIgnoreCase(ord.Istanza326__c)){
                check = false;
            }
            if(ord.DocLegge80__c != null && !'Validato'.EqualsIgnoreCase(ord.DocLegge80__c)){
                check = false;
            }
        } else if(ord.CiRappresentateLegale__c == null &&  ord.CiCliente__c == null && ord.PreventivoRapido__c == null && ord.VisuraCamerale__c == null && ord.Istanza326__c == null && ord.DocLegge80__c == null) {
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
