/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 05/01/2021
* @description Apex controller HDT_LCP_ProcessesContainer component
* @history Keltin Mesonjesi – 05/01/2021 – Created class
*/
public inherited sharing class HDT_LC_ProcessesContainer {

    private static HDT_QR_Sale saleQr = new HDT_QR_Sale();
    private static HDT_SRV_Sale saleSrv = new HDT_SRV_Sale();
    private static HDT_QR_Order orderQr = new HDT_QR_Order();
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();
    
    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 05/01/2021
    * @description Initialize controller
    * @param String saleId
    */
    @AuraEnabled
    public static map<string,object> controllerInit(String saleId) {

        boolean check = false;
        map<string,object> mapResponse = new map<string,object>();

        //Get Sale
        saleSrv.checkReadAccess('Status__c,Account__c,Name');
        Sale__c sale = saleQr.getRecordById(saleId, 'Status__c,Account__c,Name');
        check = sale.Status__c == 'Attiva' ? true : false;
        
        //Get Orders
        List<Order> listOrder = orderQr.getRecordBySale(saleId);
        
        //Get OrderDossier record type
        String recordTypeIdOrderDossier = orderSrv.getRecordTypeIdOrderDossier();

        //Check for parent orders
        List<Order> listOrderParent = orderQr.getRecordBySaleFilterRecordTypeId(saleId, recordTypeIdOrderDossier);

        //Init parent order
        Order parentOrder = new Order(
            Name = 'Ordine ' + sale.Name,
            AccountId = sale.Account__c,
            Sale__c = sale.Id,
            Status = 'Draft',
            RecordTypeId = recordTypeIdOrderDossier,
            EffectiveDate = Date.today()
        );

        //Case Order is 'Attiva'
        if(check){
            //When there is no parent order
            if(listOrderParent.isEmpty()){    
                orderSrv.createRecord(parentOrder);
                for(Order o : listOrder){
                    o.ParentOrder__c = parentOrder.Id;
                }
                if(listOrder != null && !listOrder.isEmpty()){
                    orderSrv.updateRecords(listOrder);
                }
            } else { //when there is a parent order
                parentOrder = listOrderParent[0];
            }
        }
        mapResponse.put('check',check);
        mapResponse.put('checkExist',!listOrderParent.isEmpty());
        mapResponse.put('orderParent',parentOrder.Id);
        mapResponse.put('accountId',parentOrder.AccountId);

        return mapResponse;
    }

    @AuraEnabled
    public static map<string,object> controllerInitRedirect(String orderId) {
        
        Boolean check = true;

        Map<String,Object> mapResponse = new Map<String,Object>();

        orderSrv.checkReadAccess('AccountId,Sale__c,ParentOrder__c,Status,Phase__c,WasteCommodityType__c');
        Order order = orderQr.getRecordById(orderId);
        String orderParentId = order.ParentOrder__c == null ? order.Id : order.ParentOrder__c;
        String parentPhase = order.ParentOrder__c == null ? order.Phase__c : order.ParentOrder__r.Phase__c;
        String status = order.ParentOrder__c == null ? order.Status : order.ParentOrder__r.Status;
        String accountId = order.AccountId;
        String saleId = order.Sale__c;
        String macroProcessType = order.ServicePoint__c != null && order.ServicePoint__r.CommoditySector__c.equalsIgnoreCase('Ambiente') ? 'handleProcessTari' : 'handleProcess';
        macroProcessType = String.isNotBlank(order.WasteCommodityType__c) && order.WasteCommodityType__c.equalsIgnoreCase('Ambiente')?'handleProcessTari' : macroProcessType;
        if(status == 'Annullato' || (parentPhase == 'Documentazione da validare')){
            check = false;
        }

        mapResponse.put('check',check);
        mapResponse.put('orderParent', orderParentId);
        mapResponse.put('accountId', accountId);
        mapResponse.put('saleId', saleId);
        mapResponse.put('macroProcessType', macroProcessType);
        return mapResponse;
    }

    /**
    * @author Andrei Necsulescu (andrei.necsulescu@webresults.it)
    * @date 03/09/2021
    * @description New community check logic using Site Class
    * @return Map<String, Object> Containing indication if it's community context or not + any errors
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

}
