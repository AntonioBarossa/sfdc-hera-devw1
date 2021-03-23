/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 13/01/2021
* @description Apex controller hdtOrderDossierWizardSignature component
* @history Keltin Mesonjesi – 13/01/2021 – Created class
*/
public inherited sharing class HDT_LC_OrderDossierWizardSignature {

    private static HDT_QR_Order orderQr = new HDT_QR_Order();
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();
    private static HDT_QR_Contact contactQr = new HDT_QR_Contact();
    private static HDT_SRV_Contact contactSrv = new HDT_SRV_Contact();

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 15/01/2021
    * @description Handle controller initial data fetch
    * @param String orderParentId
    * @param String accountId
    * @return Map<String,Object>
    */
    @AuraEnabled
    public static Map<String,Object> controllerInit(String orderParentId, String accountId){
        Map<String,Object> result = new Map<String,Object>();

        contactSrv.checkReadAccess('Email');
        List<Contact> primaryContact = contactQr.getPrimaryContactByAccount(accountId);
        String primaryContactEmail = primaryContact.isEmpty() ? '' : primaryContact[0].Email;
        result.put('primaryContactEmail', primaryContactEmail);

        orderSrv.checkReadAccess('BillingProfile__c,BillingProfile__r.InvoicingCityCode__c,BillingProfile__r.InvoicingCountry__c,BillingProfile__r.InvoicingPlace__c,BillingProfile__r.InvoicingPostalCode__c,BillingProfile__r.InvoicingProvince__c,BillingProfile__r.InvoicingStreetName__c,BillingProfile__r.InvoicingStreetNumber__c,BillingProfile__r.InvoicingStreetNumberExtension__c');
        List<Order>ordChildList = orderQr.getChildOrdersByParentId(orderParentId);
        result.put('ordChildList', ordChildList);

        return result;
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 05/02/2021
    * @description Handle next action on signature section
    * @param Order orderUpdates
    */
    @AuraEnabled
    public static void next(Order orderUpdates){
        List<Order> childOrders = orderQr.getChildOrdersByParentId(orderUpdates.Id);
        List<Order> ordersToUpdate = new List<Order>();
        Map<String,Object> objMap = orderUpdates.getPopulatedFieldsAsMap();

        for (Order childOrder : childOrders) {
            Order childOrderToUpdate = new Order(
                Id = childOrder.Id
            );

            for (String key : objMap.keySet()) {
                if (key != 'Id') {
                    childOrderToUpdate.put(key, objMap.get(key));
                }
            }

            system.debug('childOrderToUpdate: ' + childOrderToUpdate);
            ordersToUpdate.add(childOrderToUpdate);
        }

        if(orderUpdates.ContractSigned__c != null && orderUpdates.ContractSigned__c){
            orderUpdates.SignatureMethod__c = 'Stampa';
            orderUpdates.DocSendingMethod__c = 'Stampa';
        }

        orderUpdates.Step__c = 2;
        ordersToUpdate.add(orderUpdates);

        system.debug('childOrdersToUpdate before update: ' + ordersToUpdate);
        orderSrv.updateRecords(ordersToUpdate);
        system.debug('childOrdersToUpdate after update: ' + ordersToUpdate);
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 05/02/2021
    * @description Handle "modifica" action on signature section
    * @param String orderParentId
    */
    @AuraEnabled
    public static void edit(String orderParentId){
        orderSrv.updateRecord(new Order(
            Id = orderParentId,
            Step__c = 1
        ));
    }

}
