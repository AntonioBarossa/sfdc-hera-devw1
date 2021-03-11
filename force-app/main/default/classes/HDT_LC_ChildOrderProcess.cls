/**
 * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
 * @date 08/01/2021
 * @description HDT_LC_ChildOrderProcess.cls - Class that holds methods that are called from HDT_LCP_ChildOrderProcess component
 * @history Keltin Mesonjesi – 08/01/2021 – Created class
 */
public inherited sharing class HDT_LC_ChildOrderProcess {

    private static HDT_QR_Order orderQr = new HDT_QR_Order();
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();
    private static HDT_QR_OrderItem orderItemQr = new HDT_QR_OrderItem();
    private static HDT_SRV_OrderItem orderItemSrv = new HDT_SRV_OrderItem();
    
    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description Initialize order process component
    * @param String orderId
    * @return Map<String, Object>
    */
    @AuraEnabled
    public static Map<String, Object> controllerInit(String orderId) {

        Map<String,Object> mapResponse = new Map<String,Object>();
        
        // Order ord = [SELECT AccountId,Account.Name, Id,recordtype.DeveloperName, Status FROM Order Where id = :orderId];
        orderSrv.checkReadAccess('AccountId,Account.Name,RecordType.DeveloperName,Status,SBQQ__Quote__r.IsVAS__c,SBQQ__Quote__r.AmendmentAllowed__c');
        Order ord = orderQr.getRecordById(orderId);

        if (ord.SBQQ__Quote__r.IsVAS__c || ord.SBQQ__Quote__r.AmendmentAllowed__c) {
            Order ordToUpdate = new Order(
                Id = orderId,
                Step__c = 2,
                RecordTypeId = ord.SBQQ__Quote__r.IsVAS__c ? orderSrv.getRecordTypeIdByDeveloperName('HDT_RT_Subentro') : orderSrv.getRecordTypeIdByDeveloperName('HDT_RT_Subentro')//record type just for testing, will change later
            );
            orderSrv.updateRecord(ordToUpdate);
            ord = orderQr.getRecordById(orderId);
        }

        //List<OrderItem> orderItemList = [SELECT Id, Codice_POD__r.name,Codice_PDR__r.name, OrderId, Product2.name FROM OrderItem where Product2.name IN ('PDR','POD') AND OrderId = : ord.Id];
        orderItemSrv.checkReadAccess('Service_Point__r.Name,Service_Point__r.ServicePointCode__c,OrderId,Product2.name');
        List<OrderItem> orderItemList = orderItemQr.getRecordsByOrderIdFilteredPdrPod(orderId);

        OrderItem ordItem = new OrderItem();
        
        if(!orderItemList.isEmpty()) {
        	ordItem = orderItemList[0];
        }

        mapResponse.put('orderItem',ordItem);
        mapResponse.put('order',ord);
        mapResponse.put('accountId',ord.AccountId);
        mapResponse.put('venditaId',ord.Sale__c);
        return mapResponse;
    }
    
    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description Initialize order process component
    * @param String orderId
    * @param String processo - Dropdown selection for child order process
    * @param String parentOrderId
    */
    @AuraEnabled
    public static void saveOption(String orderId,String processo,String parentOrderId) {//Reference: String ordineVendita
        
        //Reference: Order ord = [SELECT AccountId,Account.Name, Id,Name, Status FROM Order Where id = :orderId];
        orderSrv.checkReadAccess('AccountId,Account.Name,Name,Status');
        Order ord = orderQr.getRecordById(orderId);

        System.debug('****** :' + processo);
        //Reference: List<Recordtype> rList = [Select id from Recordtype where sObjectType='Order' AND Developername = :processo];
        String recordTypeId = orderSrv.getRecordTypeIdByDeveloperName(processo);

        //Reference: List<Ordine_di_Vendita__c> ordvenLis = [Select id,stato__c from Ordine_di_Vendita__c Where id = :ordineVendita and (stato__c = 'Bozza' OR stato__c = 'Sospeso')];
        List<Order> ordvenLis = orderQr.getRecordByIdFilterStatus(parentOrderId, 'Draft');

        if(!ordvenLis.isEmpty()) {
            // ordvenLis[0].Status = 'In Lavorazione';
            // orderSrv.updateRecord(ordvenLis[0]);
        }
        
        // ord.Status = 'In Lavorazione' ;

       	// Reference: if(!rList.isEmpty()) {
        if(recordTypeId != '') {
            // Reference: ord.RecordTypeId = rList[0].id;
            // ord.RecordTypeId = recordTypeId;
        }

        // orderSrv.updateRecord(ord);
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description Refresh order
    * @param String orderId
    * @return Order
    */
    @AuraEnabled
    public static Order refreshOrderChild(String orderId){
        orderSrv.checkReadAccess('AccountId,Account.Name,RecordType.DeveloperName,Status');
        return orderQr.getRecordById(orderId);
    }

}
