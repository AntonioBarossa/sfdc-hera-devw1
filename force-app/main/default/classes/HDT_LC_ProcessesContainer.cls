/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 05/01/2021
* @description Apex controller HDT_LCP_ProcessesContainer component
* @history Keltin Mesonjesi – 05/01/2021 – Created class
*/
public inherited sharing class HDT_LC_ProcessesContainer {

    private static HDT_QR_Sale saleQr = new HDT_QR_Sale();
    private static HDT_SRV_Sale saleSrv = new HDT_SRV_Sale();
    
    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 01/05/2021
    * @description Initialize controller
    * @param String saleId
    */
    @AuraEnabled
    public static map<string,object> controllerInit(String saleId) {
		System.debug('********recordid :' +saleId);
        boolean check = false;
        map<string,object> mapResponse = new map<string,object>();
        Sale__c sale = saleQr.getRecordById(saleId, 'Status__c,Account__c,Name');
        check = sale.Status__c == 'Attiva' ? true : false;

        // List<Order> listOrder = [Select id,Ordine_di_Vendita__c from order where vendite__c=:venditaId];
        // List<Ordine_di_vendita__c> listOrdVen = [Select id,account__c from Ordine_di_vendita__c where vendite__c = :ven.Id];
        // Ordine_di_vendita__c ordven = new Ordine_di_vendita__c(account__c = ven.Account__c,vendite__c = ven.Id,name= 'Ordine ' + ven.Name, Stato__c = 'Bozza');
        // if(check){
        //     if(listOrdVen.isEmpty()){    
        //         insert ordven;
        //         for(Order o : listOrder){
        //             o.ordine_di_vendita__c = ordven.id;    
        //         }
        //         if(listOrder != null && !listOrder.isEmpty()){
        //             update listOrder;
        //         }
        //     }
        //     else{
        //         ordven = listOrdVen[0];
        //     }
        // }
        // mapResponse.put('check',check);
        // mapResponse.put('checkExist',!listOrdVen.isEmpty());
        // mapResponse.put('ordineVendita',ordven.Id);
        // mapResponse.put('accountId',ordven.Account__c);
        
        return mapResponse;     
    }

    // @AuraEnabled
    // public static map<string,object> controllerInitRedirect(String ordineVenditaId) {
	// 	System.debug('********recordid :' +ordineVenditaId);
    //     boolean check = true;
    //     map<string,object> mapResponse = new map<string,object>();
    //     Ordine_di_vendita__c ordven = [Select id,account__c,stato__c from ordine_di_vendita__c where id = :ordineVenditaId];
    //     if(ordven.stato__c == 'Completato'){
    //         check = false;
    //     }
    //     mapResponse.put('check',check);
    //     mapResponse.put('ordineVendita',ordven.Id);
    //     mapResponse.put('accountId',ordven.Account__c);
        
    //     return mapResponse;     
    // }

}
