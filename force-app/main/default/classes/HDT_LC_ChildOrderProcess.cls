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
    
    @AuraEnabled
    public static Map<String, Object> controllerInit(String orderId) {

        Map<String,Object> mapResponse = new Map<String,Object>();
        
        // Order ord = [SELECT AccountId,Account.Name, Id,recordtype.name, Status FROM Order Where id = :orderId];
        orderSrv.checkReadAccess('AccountId,Account.Name,RecordRype.Name,Status');
        Order ord = orderQr.getRecordById(orderId);

        //List<OrderItem> orderItemList = [SELECT Id, Codice_POD__r.name,Codice_PDR__r.name, OrderId, Product2.name FROM OrderItem where Product2.name IN ('PDR','POD') AND OrderId = : ord.Id];
        orderItemSrv.checkReadAccess('Service_Point__r.Name,Service_Point__r.ServicePointCode__c,OrderId,Product2.name');
        List<OrderItem> orderItemList = orderItemQr.getRecordsByOrderIdFilteredPdrPod(orderId);

        OrderItem ordItem = new OrderItem();
        
        if(!orderItemList.isEmpty()) {
        	ordItem = orderItemList[0];
        }

        mapResponse.put('orderItem',ordItem);
        mapResponse.put('order',ord);
        return mapResponse;
    }
    
    // @AuraEnabled
    // public static void saveOption(String orderId,String processo,String ordineVendita) {
    //     Order ord = [SELECT AccountId,Account.Name, Id,Name, Status FROM Order Where id = :orderId];
    //     System.debug('****** :' + processo);
    //     List<Recordtype> rList = [Select id from Recordtype where sObjectType='Order' AND Developername = :processo];
    //     List<Ordine_di_Vendita__c> ordvenLis = [Select id,stato__c from Ordine_di_Vendita__c Where id = :ordineVendita and (stato__c = 'Bozza' OR stato__c = 'Sospeso')];
    //     if(!ordvenLis.isEmpty())
    //     {
    //         ordvenLis[0].stato__c = 'In Lavorazione';
    //         update ordvenLis[0];
    //     }
    //     //Id RecordtypeSelected =	Schema.getGlobalDescribe().get('Order').getDescribe().getRecordTypeInfosByDeveloperName().get(Processo).getRecordTypeId();
    //     ord.Status = 'In Lavorazione' ;
    //    	if(!rList.isEmpty())
    //     	ord.RecordTypeId = rList[0].id;
    //     update ord;
    //     //mapResponse.put('orderStatus');
    // }

}
