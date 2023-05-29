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
    * @param orderId
    * @return Map<String, Object>
    */

    @AuraEnabled
    public static Map<String, Object> isCommunity(){

        Map<String, Object> result = new Map<String, Object>();

        try {

            Id siteId = Site.getSiteId(); 
            
            if (siteId != null) {
                result.put('isCommunity', true);
            } else {
                result.put('isCommunity', false);
            }

            result.put('error', false);
            
            
        } catch (Exception e) {
            
            result.put('error', true);
            result.put('errorMessage', e.getMessage());
            result.put('errorStackTrace', e.getStackTraceString());
            
        }

        return result;
    }

    @AuraEnabled
    public static Map<String, Object> controllerInit(String orderId) {

        Map<String,Object> mapResponse = new Map<String,Object>();
        
        orderSrv.checkReadAccess('AccountId,Account.Name,RecordType.DeveloperName,Status,SBQQ__Quote__r.IsVAS__c,SBQQ__Quote__r.AmendmentAllowed__c,SBQQ__Quote__r.ContractReference__c,SBQQ__Quote__r.AllowChangeUse__c');
        Order ord = orderQr.getRecordById(orderId);
		System.debug(ord);
        System.debug(ord.RecordType.DeveloperName);
        if (ord.RecordType.DeveloperName == 'HDT_RT_Default' || ord.ProcessType__c == 'Switch in Fittizio') {
            HDT_UTL_OrderFieldsAlignment.alignFields(ord);
            ord = orderQr.getRecordById(orderId);
        }

        orderItemSrv.checkReadAccess('Service_Point__r.Name,Service_Point__r.ServicePointCode__c,OrderId,Product2.name');
        List<OrderItem> orderItemList = orderItemQr.getRecordsByOrderIdFilteredPdrPod(orderId);

        OrderItem ordItem = new OrderItem();
        
        if(!orderItemList.isEmpty()) {
        	ordItem = orderItemList[0];
        }

        List<OrderItem> mainOrderItemList = orderItemQr.getMainItem(orderId);
        OrderItem mainOrderItem = new OrderItem();
        
        if(!mainOrderItemList.isEmpty()) {
        	mainOrderItem = mainOrderItemList[0];
        }

        List<OrderItem> analisiConsumiList = orderItemQr.getAnalisiConsumi(orderId);
        OrderItem analisiConsumi = new OrderItem();
        
        if(!analisiConsumiList.isEmpty()) {
        	analisiConsumi = analisiConsumiList[0];
        }

        mapResponse.put('analisiConsumi', analisiConsumi);
        mapResponse.put('mainOrderItem',mainOrderItem);
        mapResponse.put('orderItem',ordItem);
        mapResponse.put('order',ord);
        mapResponse.put('accountId',ord.AccountId);
        mapResponse.put('venditaId',ord.Sale__c);
        mapResponse.put('stepRepeated', isStepRepeated(ord));
        return mapResponse;
    }
    
    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description Initialize order process component
    * @param orderId
    * @param processo - Dropdown selection for child order process
    * @param parentOrderId
    */
    @AuraEnabled
    public static void saveOption(String orderId,String processo,String parentOrderId) {//Reference: String ordineVendita
        
        //Reference: Order ord = [SELECT AccountId,Account.Name, Id,Name, Status FROM Order Where id = :orderId];
        orderSrv.checkReadAccess('AccountId,Account.Name,Name,Status');
        orderQr.getRecordById(orderId);

        System.debug('****** :' + processo);
        //Reference: List<Recordtype> rList = [Select id from Recordtype where sObjectType='Order' AND Developername = :processo];
        orderSrv.getRecordTypeIdByDeveloperName(processo);

        //Reference: List<Ordine_di_Vendita__c> ordvenLis = [Select id,stato__c from Ordine_di_Vendita__c Where id = :ordineVendita and (stato__c = 'Bozza' OR stato__c = 'Sospeso')];
        orderQr.getRecordByIdFilterStatus(parentOrderId, 'Draft');
        
        // ord.Status = 'In Lavorazione' ;

       	// Reference: if(!rList.isEmpty()) {

        // orderSrv.updateRecord(ord);
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description Refresh order
    * @param orderId
    * @return Order
    */
    @AuraEnabled
    public static Order refreshOrderChild(String orderId){
        orderSrv.checkReadAccess('AccountId,Account.Name,RecordType.DeveloperName,Status');
        return orderQr.getRecordById(orderId);
    }


    @AuraEnabled
    public static Map<String, Object> refreshOrderChildAndHistory(String orderId){
        Order ord = refreshOrderChild(orderId);
        Boolean stepRepeated = isStepRepeated(ord);
        Map<String, Object> result = new Map<String, Object>{'order'=>ord, 'stepRepeated'=> stepRepeated};
        return result;
    }

    private static Boolean isStepRepeated(Order ord){
        List<OrderHistory> histories = [ SELECT OldValue FROM OrderHistory WHERE OrderId=:ord.Id AND Field='Step__c' WITH SECURITY_ENFORCED ];
        for(OrderHistory hist : histories){
            if(hist.OldValue == ord.Step__c){return true;}
        }
        return false;
    }
}