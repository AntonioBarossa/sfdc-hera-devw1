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
    // EVERIS_NTTDATA START
    private static HDT_QR_AccountContactRelation acrQr = new HDT_QR_AccountContactRelation();
    // EVERIS_NTTDATA END

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 06/01/2021
    * @description Initialize controller
    * @param String saleId
    * @return Map<String, Object>
    */
    @AuraEnabled
    public static string controllerInit(String saleId){
        controllerInit(saleId, 'handleProcess');
    }

    private static Order createOrderParent(Sale sale, String saleOrder, String contactId)
    {
        /* If Sale is null no reason to go further */
        if(sale == null)
        {
            return;
        }
        Order parentOrder = new Order();
        parentOrder.Name = 'Ord. ' + sale.Name.abbreviate(70) + saleOrder;
        parentOrder.AccountId = sale.Account__c;
        parentOrder.Contact__c = contactId;
        parentOrder.Sale__c = sale.Id;
        parentOrder.Status = 'Draft';
        parentOrder.RecordTypeId = HDT_UTL_Constants.ORDER_RECORDTYPEID_ORDERDOSSIER;
        parentOrder.EffectiveDate = Date.today();
        parentOrder.Step__c = 1;
        parentOrder.Channel__c = sale.Channel__c;
        parentOrder.LoginChannel__c = sale.CreatedBy.LoginChannel__c;
        parentOrder.VendorLastName__c = sale.VendorLastName__c;
        parentOrder.VendorFirstName__c = sale.VendorFirstName__C;
        parentOrder.CommercialId__c = sale.CommercialId__c;
        parentOrder.AgencyCode__c = sale.AgencyCode__c;
        parentOrder.Agency__c = sale.Agency__c;
        parentOrder.AreaManager__c = sale.AreaManager__c;
        parentOrder.SalesContact__c = sale.SalesContact__c;
        parentOrder.Interaction__c = sale.Interaction__c;
        parentOrder.LowerChannelAgency__c = sale.LowerChannelAgency__c;
        parentOrder.UpperChannelAgency__c = sale.UpperChannelAgency__c;

        return parentOrder;
        
    }

    private static Map<String, Map<String, String>> createOrderParamsMap(List<Id> orderIds, List<OrderItem> orderItemList)
    {
        Map<String, List<String>> result = new Map<String, List<String>>();
        for(OrderItem item : orderItemList)
        {
            if(result.containsKey(item.orderId))
            {
                result.put(item.orderId, new Map<String, String>());
            }
            if(item.BillingProfile__c != null && String.isNotBlank(item.BillingProfile__c))
            {
                (result.get(item.orderId)).put('billingprofile',item.BillingProfile__c);
            }
            if(item.ServicePoint__c != null && String.isNotBlank(item.ServicePoint__c))
            {
                (result.get(item.orderId)).put('servicepoint',item.ServicePoint__c);
            }
        }
        return result;
    }

    private static List<Order> createOrderStructure(Sale sale, List<Order> listOrderParent, String contactId, String macroProcessType)
    {
        List<Id> listOrdersId = new List<Id>();
        List<Order> listOrder = orderQr.getRecordBySale(sale.Id);
        List<Order> orderToUpdate = new List<Order>();
        /* Check if order parent already exists */
        if(listOrderParent.isEmpty())
        {
            /* Create Order Parent */
            Order parentOrder = createOrderParent(sale, 'a', contactId);
            orderSrv.createRecord(parentOrder);
            /* Loop add child orders to listOrderIds */
            for(Order o : listOrder){
                listOrdersId.add(o.Id);
            }

            if(listOrder != null && !listOrder.isEmpty())
            {
                /* Get all orderItem which are not sconti, bonus */
                List<OrderItem> orderItemsList = orderItemQr.getRecordsByOrderIdListFilteredPdrPod(listOrdersId);
                orderItemsList.addAll(handleNotAmendBonus(listOrdersId));
                /* Separates order item of Ambiente */
                List<Id> orderTariIds = new List<Id>();
                List<Id> orderNotTariIds = new List<Id>();
                for(OrderItem item : orderItemsList)
                {
                    if(item.ServicePoint__c != null && item.ServicePoint__r.CommoditySector__c.equalsIgnoreCase('Ambiente'))
                    {
                        orderTariIds.add(item.OrderId);
                    }
                    else if(item.servicePoint__c != null && !item.ServicePoint__r.CommoditySector__c.equalsIgnoreCase('Ambiente'))
                    {
                        orderNotTariIds.add(item.OrderId);
                    }
                }
                /* Update child Orders */
                Map<String, Map<String, String>> paramsMap = createOrderParamsMap(listOrdersId,orderItemsList);
                for(String orderId : paramsMap.keySet())
                {
                    /* Excludes order Tari if handleProcess, excludes other orders if handleProcessTari */
                    if(macroProcessType.equalsIgnoreCase('handleProcess') && orderTariIds.contains(orderId))
                    {
                        continue;
                    }
                    if(macroProcessType.equalsIgnoreCase('handleProcessTari') && orderNotTariIds.contains(orderId))
                    {
                        continue;
                    }
                    Order singleOrder = new Order();
                    Map<String, String> singleParams = paramsMap.get(orderId);
                    singleOrder.id = orderId;
                    singleOrder.ServicePoint__c = singleParams.get('servicepoint') != null ? singleParams.get('servicepoint') : null;
                    singleOrder.BillingProfile__c = singleParams.get('billingprofile') != null ? singleParams.get('billingprofile') : null;
                    singleOrder.ParentOrder__c = parentOrder.Id;
                    singleOrder.RecordTypeId = ORDER_RECORDTYPEID_DEFAULT;
                    orderToUpdate.add(singleOrder);
                }
            }
        }
        return orderToUpdate;
        
    }

    @AuraEnabled
    public static Map<String, Object> controllerInit(String saleId, String macroProcessType) {
        
        Map<String,Object> mapResponse = new Map<String,Object>();
        
        Boolean check = false;

        //Get Sale
        saleSrv.checkReadAccess('Status__c,Account__c,Name,Channel__c,VendorLastName__c,VendorFirstName__c,CommercialId__c,AgencyCode__c,Agency__c,AreaManager__c');
        Sale__c sale = saleQr.getRecordById(saleId, 'Interaction__c,UpperChannelAgency__c,LowerChannelAgency__c,SalesContact__c,CreatedBy.LoginChannel__c,Status__c,Account__c,Name,Channel__c,VendorLastName__c,VendorFirstName__c,CommercialId__c,AgencyCode__c,Agency__c,AreaManager__c');
        check = sale.Status__c == 'Attiva' ? true : false;
        
        //Get Orders
        List<Order> listOrder = orderQr.getRecordBySale(saleId);

        System.debug('Lista Ordini da Legare ' +listOrder);

        //Store orders Id
        List<Id> listOrdersId = new List<Id>();
        
        //Get OrderDossier record type
        //String recordTypeIdOrderDossier = orderSrv.getRecordTypeIdOrderDossier();

        //Get Default record type
        String recordTypeIdDefault = orderSrv.getRecordTypeIdDefault();

        //Check for parent orders
        List<Order> listOrderParent = orderQr.getRecordBySaleFilterRecordTypeId(saleId, recordTypeIdOrderDossier);

        // EVERIS_NTTDATA START
        AccountContactRelation acr = acrQr.getPrimaryContactRelationBusiness(sale.Account__c);
        Id contactId = acr != null ? acr.ContactId : null;
        // EVERIS_NTTDATA END

        //Init parent order
        Order parentOrder = new Order();


        //Case Order is 'Attiva'
        if(check){
            //When there is no parent order
            if(listOrderParent.isEmpty()){

                Order parentOrderNew = new Order(
                    Name = sale.Name.length() < 80-7 ? 'Ordine '+sale.Name : 'Ordine '+sale.Name.substring(0, 80-7), //max length - size('Ordine ')
                    AccountId = sale.Account__c,
                    // EVERIS_NTTDATA START
                    Contact__c = contactId,
                    // EVERIS_NTTDATA END
                    Sale__c = sale.Id,
                    Status = 'Draft',
                    RecordTypeId = recordTypeIdOrderDossier,
                    EffectiveDate = Date.today(),
                    Step__c = 1,
                    Channel__c = sale.Channel__c,
                    LoginChannel__c = sale.CreatedBy.LoginChannel__c,
                    VendorLastName__c = sale.VendorLastName__c,
                    VendorFirstName__c = sale.VendorFirstName__C,
                    CommercialId__c = sale.CommercialId__c,
                    AgencyCode__c = sale.AgencyCode__c,
                    Agency__c = sale.Agency__c,
                    AreaManager__c = sale.AreaManager__c,
                    SalesContact__c = sale.SalesContact__c,
                    Interaction__c = sale.Interaction__c,
                    LowerChannelAgency__c = sale.LowerChannelAgency__c,
                    UpperChannelAgency__c = sale.UpperChannelAgency__c
                );

                orderSrv.createRecord(parentOrderNew);
                
                for(Order o : listOrder){
                    listOrdersId.add(o.Id);
                }

                System.debug(listOrder != null && !listOrder.isEmpty());

                if(listOrder != null && !listOrder.isEmpty()){

                    System.debug('Entrato nel Loop');
                    system.debug(listOrdersId);

                    Map<String, Order> ordersToUpdateMap = new Map<String, Order>();
                    List<Order> ordersToUpdate = new List<Order>();
                    orderItemSrv.checkReadAccess('ServicePoint__c,ServicePoint__r.Name,ServicePoint__r.ServicePointCode__c,OrderId,Product2.Name');
                    List<OrderItem> orderItemsList = orderItemQr.getRecordsByOrderIdListFilteredPdrPod(listOrdersId);
                    orderItemsList.addAll(handleNotAmendBonus(listOrdersId));


                    System.debug('Lista Ordini '+orderItemsList);

                    for (OrderItem orderItem : orderItemsList) {
                        ordersToUpdateMap.put(orderItem.OrderId, new Order(
                            Id = orderItem.OrderId,
                            ServicePoint__c = orderItem.ServicePoint__c != null ? orderItem.ServicePoint__c : null,
                            ParentOrder__c = parentOrderNew.Id,
                            RecordTypeId = recordTypeIdDefault
                        ));
                    }
                    orderItemSrv.checkReadAccess('OrderId,BillingProfile__c');
                    List<OrderItem> orderItemsListWithBillingProfile = orderItemQr.getRecordsWithBillingProfile(listOrdersId);
                    Boolean isDuplicated = false;
                    for (OrderItem orderItem : orderItemsListWithBillingProfile) {
                        if (ordersToUpdateMap.get(orderItem.OrderId) != null) {
                            Order orderToUpdate = ordersToUpdateMap.get(orderItem.OrderId);
                            orderToUpdate.BillingProfile__c = orderItem.BillingProfile__c != null ? orderItem.BillingProfile__c : null;
                            
                            for (Order ord : ordersToUpdate) {
                                if (ord.Id == orderToUpdate.Id) {
                                    isDuplicated = true;
                                    break;
                                }
                            }
    
                            if (!isDuplicated) {
                                ordersToUpdate.add(orderToUpdate);
                            }
    
                            isDuplicated = false;
                        }
                    }

                    List<OrderItem> orderItemsAmend = orderItemQr.getRecordsWithAmend(listOrdersId);
                    system.debug('ordersToUpdate before: ' + ordersToUpdate);
                    system.debug('orderItemsAmend: ' + orderItemsAmend);
                    
                    for (OrderItem orderItem : orderItemsAmend) {
                        Order orderToUpdate = ordersToUpdateMap.get(orderItem.OrderId);
                        system.debug('orderToUpdate: ' + orderToUpdate);
                        //system.debug('ordersToUpdate after: ' + ordersToUpdate);
                        if(orderToUpdate!=null){
                            for (Order ord : ordersToUpdate) {
                                if (ord?.Id == orderToUpdate?.Id) {
                                    isDuplicated = true;
                                    break;
                                }
                            }
    
                            if (!isDuplicated) {
                                ordersToUpdate.add(orderToUpdate);
                            }
    
                            isDuplicated = false;
                        }
                    }

                    if(!ordersToUpdate.isEmpty()){
                        system.debug(ordersToUpdate);
                        orderSrv.updateRecords(ordersToUpdate);
                    }
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

        System.debug(mapResponse);

        return mapResponse;
    }

    private static List<OrderItem> handleNotAmendBonus(List<Id> listOrdersId){
        List<OrderItem> bonusToUpdate = new List<OrderItem>();
        List<OrderItem> allBonuses = orderItemQr.getRecordsByOrderIdFilteredFamilyBonus(listOrdersId);
        for(OrderItem itm : allBonuses){
            if(itm.SBQQ__RequiredBy__c==null){
                bonusToUpdate.add(itm);
            }
        }
        system.debug(bonusToUpdate);
        return bonusToUpdate;
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
    public static boolean checkCommunityLogin(){
        boolean check=False;
        string us= userinfo.getUserType();
        system.debug(us);
        if (!'Standard'.Equals(us)){
            check=True;
           
        }
        return check;
    }
    @AuraEnabled
    public static boolean checkDatiDiscordanti(String orderid){

        boolean res = HDT_UTL_Order.checkToDiscordanti(orderid);


        return res;
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