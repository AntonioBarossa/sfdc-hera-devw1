/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 12/01/2021
* @description Apex controller for hdtOrderDossierWizardTable component
* @history Keltin Mesonjesi – 12/01/2021 – Created class
*/
public inherited sharing class HDT_LC_OrderDossierWizardTable {
    
    private static HDT_QR_Order orderQr = new HDT_QR_Order();
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();
    private static HDT_QR_OrderItem orderItemQr = new HDT_QR_OrderItem();
    private static HDT_SRV_OrderItem orderItemSrv = new HDT_SRV_OrderItem();

    @AuraEnabled
    public static Map<String,Object> getTableData(String orderParentId) {

        Map<String,Object> mapResponse = new Map<String,Object>();

        List<id> listChildOrderId = new List<Id>(); //List<id> listaOrderId = new List<ID>();

        orderSrv.checkReadAccess('AccountId,Account.Name,Account.VATNumber__c,Account.FiscalCode__c,Name');
        Order orderParent = orderQr.getRecordById(orderParentId); // Ordine_di_Vendita__c ordVen = [Select id,account__c,account__r.name,Account__r.VAT_Number__c ,Account__r.Fiscal_Code__c,Name from Ordine_di_vendita__c where id=:ordineVendita];

        orderSrv.checkReadAccess('AccountId,Account.Name,Recordtypeid,Recordtype.Name,Recordtype.DeveloperName,Status,OrderNumber');
        List<Order> childOrders = orderQr.getChildOrdersByParentIdAllStatus(orderParentId); // List<Order> ordList = [SELECT AccountId,Account.Name,recordtypeid,recordtype.DeveloperName, id,status,OrderNumber  FROM Order Where ordine_di_vendita__c = :ordineVendita];

        System.debug('ChildOrders '+childOrders);
      
        // for(Order o : ordList){
        //     listaOrderId.add(o.id);
        // }
        for (Order o : childOrders) {
            listChildOrderId.add(o.Id);
        }
        
        orderItemSrv.checkReadAccess('ServicePoint__c,Service_Point__r.Name,OrderId,Product2.Name');
        List<OrderItem> orderItemList = orderItemQr.getRecordsByOrderIdListFilteredPdrPod(listChildOrderId); // List<OrderItem> orderItemList = [SELECT Id, Codice_POD__r.name,Codice_PDR__r.name, OrderId, Product2.name FROM OrderItem where Product2.name IN ('PDR','POD') AND OrderId IN :listaOrderId];

        mapResponse.put('childOrdersList',childOrders); // mapResponse.put('orderList',ordList);
        mapResponse.put('orderItemList',orderItemList); // mapResponse.put('orderItemList',orderItemList);
        
        return mapResponse;
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 05/02/2021
    * @description Handle next action on signature section
    * @param Order orderUpdates
    */
    @AuraEnabled
    public static void next(Order orderUpdates){
        orderUpdates.Step__c = 3;
        orderSrv.updateRecord(orderUpdates);
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
            Step__c = 2
        ));
    }
}
