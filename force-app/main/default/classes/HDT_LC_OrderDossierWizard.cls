/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 06/01/2021
* @description Apex controller for HDT_LCP_OrderDossierWizard component
* @history Keltin Mesonjesi – 06/01/2021 – Created class
*/
public inherited sharing class HDT_LC_OrderDossierWizard {
    
    private static HDT_QR_Sale saleQr = new HDT_QR_Sale();
    private static HDT_SRV_Sale saleSrv = new HDT_SRV_Sale();
    private static HDT_QR_Order orderQr = new HDT_QR_Order();
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();
    private static HDT_QR_OrderItem orderItemQr = new HDT_QR_OrderItem();
    private static HDT_SRV_OrderItem orderItemSrv = new HDT_SRV_OrderItem();

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 06/01/2021
    * @description Initialize controller
    * @param String saleId
    * @return Map<String, Object>
    */
    @AuraEnabled
    public static Map<String, Object> controllerInit(String saleId) {
        
        Map<String,Object> mapResponse = new Map<String,Object>();
        
        Boolean check = false;

        //Get Sale
        saleSrv.checkReadAccess('Status__c,Account__c,Name');
        Sale__c sale = saleQr.getRecordById(saleId, 'Status__c,Account__c,Name');
        check = sale.Status__c == 'Attiva' ? true : false;
        
        //Get Orders
        List<Order> listOrder = orderQr.getRecordBySale(saleId);

        //Store orders Id
        List<Id> listOrdersId = new List<Id>();
        
        //Get OrderDossier record type
        String recordTypeIdOrderDossier = orderSrv.getRecordTypeIdOrderDossier();

        //Get Default record type
        String recordTypeIdDefault = orderSrv.getRecordTypeIdDefault();

        //Check for parent orders
        List<Order> listOrderParent = orderQr.getRecordBySaleFilterRecordTypeId(saleId, recordTypeIdOrderDossier);

        //Init parent order
        Order parentOrder = new Order();

        //Case Order is 'Attiva'
        if(check){
            //When there is no parent order
            if(listOrderParent.isEmpty()){
                
                Order parentOrderNew = new Order(
                    Name = 'Ordine ' + sale.Name,
                    AccountId = sale.Account__c,
                    Sale__c = sale.Id,
                    Status = 'Draft',
                    RecordTypeId = recordTypeIdOrderDossier,
                    EffectiveDate = Date.today(),
                    Step__c = 1
                );

                orderSrv.createRecord(parentOrderNew);
                
                for(Order o : listOrder){
                    listOrdersId.add(o.Id);
                }

                if(listOrder != null && !listOrder.isEmpty()){
                    Map<String, Order> ordersToUpdateMap = new Map<String, Order>();
                    List<Order> ordersToUpdate = new List<Order>();
                    orderItemSrv.checkReadAccess('ServicePoint__c,ServicePoint__r.Name,ServicePoint__r.ServicePointCode__c,OrderId,Product2.Name');
                    List<OrderItem> orderItemsList = orderItemQr.getRecordsByOrderIdListFilteredPdrPod(listOrdersId);
                    for (OrderItem orderItem : orderItemsList) {
                        ordersToUpdateMap.put(orderItem.OrderId, new Order(
                            Id = orderItem.OrderId,
                            ServicePoint__c = orderItem.ServicePoint__c,
                            ParentOrder__c = parentOrderNew.Id,
                            RecordTypeId = recordTypeIdDefault
                        ));
                    }
                    orderItemSrv.checkReadAccess('OrderId,BillingProfile__c');
                    List<OrderItem> orderItemsListWithBillingProfile = orderItemQr.getRecordsWithBillingProfile(listOrdersId);
                    for (OrderItem orderItem : orderItemsListWithBillingProfile) {
                        Order orderToUpdate = ordersToUpdateMap.get(orderItem.OrderId);
                        orderToUpdate.BillingProfile__c = orderItem.BillingProfile__c;
                        ordersToUpdate.add(orderToUpdate);
                    }
                    orderSrv.updateRecords(ordersToUpdate);
                }

                parentOrder = orderQr.getRecordById(parentOrderNew.Id);

            } else { //when there is a parent order
                parentOrder = listOrderParent[0];
            }
        }

        mapResponse.put('check',check);
        mapResponse.put('checkExist',!listOrderParent.isEmpty());
        mapResponse.put('orderParent',parentOrder.Id);
        mapResponse.put('orderParentRecord',parentOrder);
        mapResponse.put('orderParentName',parentOrder.Name);
        mapResponse.put('accountId',parentOrder.AccountId);

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
    public static Order getOrderParent(String orderParentId){
        orderSrv.checkReadAccess('AccountId,Account.Name,Account.VATNumber__c,Account.FiscalCode__c,Account.BillingAddress,Account.ShippingAddress,Name,RecordType.DeveloperName,SystemModstamp,Status,ContractSigned__c,SignedDate__c,SignatureMethod__c,DocSendingMethod__c,Sale__c,CreatedDate,Step__c');
        return orderQr.getRecordById(orderParentId);
    }

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
