/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 06/01/2021
* @description Apex controller for HDT_LCP_OrderDossierWizard component
* @history Keltin Mesonjesi – 06/01/2021 – Created class
*/
public inherited sharing class HDT_LC_OrderDossierWizard {
    
    private static HDT_QR_Order orderQr = new HDT_QR_Order();
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 06/01/2021
    * @description Initialize controller
    * @param String saleId
    */
    @AuraEnabled
    public static Map<String, Object> controllerInit(String ordineVendita) {
        
        Map<String,Object> mapResponse = new Map<String,Object>();
        
        List<id> listaOrderId = new List<ID>();
        
        String recordTypeIdOrderDossier = orderSrv.getRecordTypeIdOrderDossier();



        // Ordine_di_Vendita__c ordVen = [Select id,account__c,account__r.name,Account__r.VAT_Number__c ,Account__r.Fiscal_Code__c,Name from Ordine_di_vendita__c where id=:ordineVendita];
        
        // List<Order> ordList = [SELECT AccountId,Account.Name,recordtypeid,recordtype.name, id,status,OrderNumber  FROM Order Where ordine_di_vendita__c = :ordineVendita];
        
        // for(Order o : ordList){
        //     listaOrderId.add(o.id);
        // }
        
        // List<OrderItem> orderItemList = [SELECT Id, Codice_POD__r.name,Codice_PDR__r.name, OrderId, Product2.name FROM OrderItem where Product2.name IN ('PDR','POD') AND OrderId IN :listaOrderId];
        
        // mapResponse.put('accountName',ordVen.Account__r.Name);
        // mapResponse.put('ordineVenditaName',ordVen.Name);
        // mapResponse.put('codFi',ordVen.Account__r.Fiscal_Code__c);
        // mapResponse.put('pIv',ordVen.Account__r.VAT_Number__c);
        // mapResponse.put('orderList',ordList);
        // mapResponse.put('orderItemList',orderItemList);
        
        return mapResponse;
    }

    // @AuraEnabled
    // public static String ordineVenditaCancel(String id){
    //     Ordine_di_Vendita__c ordVen = [Select id,account__c,account__r.name,Stato__c from Ordine_di_vendita__c where id=:id];
    //     ordVen.Stato__c = 'Disattivo';
    //     update ordVen;
    //     return ordVen.account__c;
    // }

    // @AuraEnabled
    // public static boolean saveProsegui(String ordineVendita){
    //     Boolean check = true;
    //     List<Order> ordList = [SELECT AccountId,Account.Name,Name, id,status,OrderNumber  FROM Order Where ordine_di_vendita__c = :ordineVendita];
    //     For(Order ord : ordList){
    //         if(ord.Status != 'Activated'){
    //         	check = false;
    //         }
    //     }
    //     if(check){
    //     	Ordine_di_Vendita__c odv = [SELECT SystemModstamp, Id,stato__c FROM Ordine_di_Vendita__c where id = :ordineVendita];
    //         odv.Stato__c = 'Attivo';
    //         update odv;
    //     }    
            
    //     return check;
    // }

    // @AuraEnabled
    // public static void saveDraftController(String ordineVendita){
    //     Boolean check = true;
    //     system.debug('******' + ordineVendita);
    //     ordine_di_vendita__c odv = new Ordine_di_vendita__c(id=ordineVendita,stato__c='Sospeso');
	// 	update odv;
    // }

}
