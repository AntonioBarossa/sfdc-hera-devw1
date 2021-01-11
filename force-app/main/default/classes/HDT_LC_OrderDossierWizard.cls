/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 06/01/2021
* @description Apex controller for HDT_LCP_OrderDossierWizard component
* @history Keltin Mesonjesi – 06/01/2021 – Created class
*/
public inherited sharing class HDT_LC_OrderDossierWizard {
    
    private static HDT_QR_Order orderQr = new HDT_QR_Order();
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();
    private static HDT_QR_OrderItem orderItemQr = new HDT_QR_OrderItem();
    private static HDT_SRV_OrderItem orderItemSrv = new HDT_SRV_OrderItem();

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 06/01/2021
    * @description Initialize controller
    * @param String saleId
    */
    @AuraEnabled
    public static Map<String, Object> controllerInit(String orderParentId) {//String ordineVendita
        
        Map<String,Object> mapResponse = new Map<String,Object>();
        
        List<id> listChildOrderId = new List<Id>(); //List<id> listaOrderId = new List<ID>();

        orderSrv.checkReadAccess('AccountId,Account.Name,Account.VATNumber__c,Account.FiscalCode__c,Name');
        Order orderParent = orderQr.getRecordById(orderParentId); // Ordine_di_Vendita__c ordVen = [Select id,account__c,account__r.name,Account__r.VAT_Number__c ,Account__r.Fiscal_Code__c,Name from Ordine_di_vendita__c where id=:ordineVendita];

        orderSrv.checkReadAccess('AccountId,Account.Name,Recordtypeid,Recordtype.Name,Status,OrderNumber');
        List<Order> childOrders = orderQr.getChildOrdersByParentId(orderParentId); // List<Order> ordList = [SELECT AccountId,Account.Name,recordtypeid,recordtype.name, id,status,OrderNumber  FROM Order Where ordine_di_vendita__c = :ordineVendita];

        // for(Order o : ordList){
        //     listaOrderId.add(o.id);
        // }
        for (Order o : childOrders) {
            listChildOrderId.add(o.Id);
        }
        
        orderItemSrv.checkReadAccess('Service_Point__r.Name,OrderId,Product2.Name');
        List<OrderItem> orderItemList = orderItemQr.getRecordsByOrderIdListFilteredPdrPod(listChildOrderId); // List<OrderItem> orderItemList = [SELECT Id, Codice_POD__r.name,Codice_PDR__r.name, OrderId, Product2.name FROM OrderItem where Product2.name IN ('PDR','POD') AND OrderId IN :listaOrderId];
        
        mapResponse.put('accountName',orderParent.Account.Name); // mapResponse.put('accountName',ordVen.Account__r.Name);
        mapResponse.put('orderParentName',orderParent.Name); // mapResponse.put('ordineVenditaName',ordVen.Name);
        mapResponse.put('fiscalCode',orderParent.Account.FiscalCode__c); // mapResponse.put('codFi',ordVen.Account__r.Fiscal_Code__c);
        mapResponse.put('vatNumber',orderParent.Account.VATNumber__c); // mapResponse.put('pIv',ordVen.Account__r.VAT_Number__c);
        mapResponse.put('childOrdersList',childOrders); // mapResponse.put('orderList',ordList);
        mapResponse.put('orderItemList',orderItemList); // mapResponse.put('orderItemList',orderItemList);
        
        return mapResponse;
    }

    // @AuraEnabled
    // public static String ordineVenditaCancel(String id){
    //     Ordine_di_Vendita__c ordVen = [Select id,account__c,account__r.name,Stato__c from Ordine_di_vendita__c where id=:id];
    //     ordVen.Stato__c = 'Disattivo';
    //     update ordVen;
    //     return ordVen.account__c;
    // }

    @AuraEnabled
    public static boolean saveProsegui(String orderParentId){
        Boolean check = true;

        orderSrv.checkReadAccess('AccountId,Account.Name,Name,Status,OrderNumber');
        List<Order>ordList = orderQr.getChildOrdersByParentId(orderParentId);

        for(Order ord : ordList){
            if(ord.Status != 'Activated'){
            	check = false;
            }
        }
        
        if(check){
            orderSrv.checkReadAccess('SystemModstamp,Status');
            Order orderParent = orderQr.getRecordById(orderParentId);

            orderParent.Status = 'Activated';
            orderSrv.updateRecord(orderParent);
        }

        return check;
    }

    @AuraEnabled
    public static void saveDraftController(String orderParentId){
        
        Boolean check = true;

        Order orderParent = new Order(
            Id = orderParentId,
            Status = 'Draft'
        );

        orderSrv.updateRecord(orderParent);
    }

}
