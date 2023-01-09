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
    private static HDT_QR_AccountContactRelation acrQr = new HDT_QR_AccountContactRelation();
    private static HDT_UTL_Constants utlConstants = new HDT_UTL_Constants();

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 06/01/2021
    * @description Initialize controller
    * @param String saleId
    * @return Map<String, Object>
    */
    @AuraEnabled
    public static Map<String, Object> controllerInit(String saleId){
        Map<String, Object> result = controllerInit(saleId, 'handleProcess');
        return result;
    }

    private static Order createOrderParent(Sale__c sale, String saleOrder, String contactId)
    {
        /* If Sale is null no reason to go further */
        if(sale == null)
        {
            return null;
        }
        Order parentOrder = new Order();
        parentOrder.Name = 'Ord. ' + sale.Name.abbreviate(70) + saleOrder;
        parentOrder.AccountId = sale.Account__c;
        parentOrder.Contact__c = contactId;
        parentOrder.Sale__c = sale.Id;
        parentOrder.Status = 'Draft';
        parentOrder.RecordTypeId = utlConstants.ORDER_RECORDTYPEID_ORDERDOSSIER;
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
        Map<String, Map<String, String>> result = new Map<String, Map<String, String>>();
        for(OrderItem item : orderItemList)
        {
            if(!result.containsKey(item.orderId))
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

    private static List<Order> createOrderStructure(Sale__c sale, String contactId, String macroProcessType)
    {
        List<Id> listOrdersId = new List<Id>();
        List<Order> listOrder = orderQr.getRecordBySale(sale.Id);
        List<Order> orderToUpdate = new List<Order>();
        /* Create Order Parent */
        String saleOrder = macroProcessType.equalsIgnoreCase('handleProcess') ? 'a' : 'b';
        Order parentOrder = createOrderParent(sale, saleOrder, contactId);
        if(macroProcessType != null && macroProcessType.equalsIgnoreCase('handleProcessTari')){
            parentOrder.WasteCommodityType__c = 'Ambiente';
        }
        orderSrv.createRecord(parentOrder);
        /* Loop add child orders to listOrderIds */
        for(Order o : listOrder){
            listOrdersId.add(o.Id);
        }
        if(listOrder != null && !listOrder.isEmpty())
        {
            /* Get all orderItem which are not sconti, bonus */
            List<OrderItem> orderItemsList = orderItemQr.getRecordsByOrderIdListFilteredPdrPodBillingProfile(listOrdersId);
            orderItemsList.addAll(handleNotAmendBonus(listOrdersId));
            /* Separates order item of Ambiente */
            Set<Id> orderTariIds = new Set<Id>();
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
                if(macroProcessType.equalsIgnoreCase('handleProcess') && !orderTariIds.isEmpty() && orderTariIds.contains(orderId))
                {
                    continue;
                }
                if(macroProcessType.equalsIgnoreCase('handleProcessTari') && !orderNotTariIds.isEmpty() && orderNotTariIds.contains(orderId))
                {
                    continue;
                }
                Order singleOrder = new Order();
                Map<String, String> singleParams = paramsMap.get(orderId);
                singleOrder.id = orderId;
                singleOrder.ServicePoint__c = singleParams.get('servicepoint') != null ? singleParams.get('servicepoint') : null;
                singleOrder.BillingProfile__c = singleParams.get('billingprofile') != null ? singleParams.get('billingprofile') : null;
                singleOrder.ParentOrder__c = parentOrder.Id;
                singleOrder.RecordTypeId = utlConstants.ORDER_RECORDTYPEID_DEFAULT;
                orderToUpdate.add(singleOrder);
            }
        }
        return orderToUpdate;
    }

    public static Map<String,Order> checkExistingOrderParent(String saleId)
    {
        Map<String, Order> resultMap = new Map<String, Order>();
        /* Query all orders under the sale */
        List<Order> saleItems =  [SELECT Name, OrderNumber, RecordTypeId, AccountId, Account.Name, Account.FirstName__c, Account.LastName__c, Account.VATNumber__c,
        Account.FiscalCode__c, Account.BillingAddress, Account.ShippingAddress, Account.RecordType.DeveloperName, Status, ContractSigned__c, SignedDate__c, SignatureMethod__c,
        DocSendingMethod__c, CreatedDate, Step__c, Phase__c, ParentOrder__c,
        (SELECT Id, ServicePoint__c, ServicePoint__r.CommoditySector__c FROM Orders__r )
        FROM Order WHERE Sale__c = :saleId AND RecordTypeId = :utlConstants.ORDER_RECORDTYPEID_ORDERDOSSIER WITH SECURITY_ENFORCED];
        for(Order saleItem : saleItems)
        {
            if(saleItem.Orders__r != null)
            {
                for(Order childOrder : saleItem.Orders__r)
                {
                    if(childOrder.ServicePoint__c != null && childOrder.ServicePoint__r.CommoditySector__c.equalsIgnoreCase('Ambiente'))
                    {
                        resultMap.put('tari', saleItem);
                        break;
                    }
                }
                if(resultMap.get('tari') == null || resultMap.get('tari') != null && ((Order) resultMap.get('tari')).Id != saleItem.Id)
                {
                    resultMap.put('standard', saleItem);
                }
            }
            else 
            {
                break;    
            }
        }
        return resultMap;
    }

    @AuraEnabled
    public static Map<String, Object> controllerInit(String saleId, String macroProcessType) {
        
        Map<String,Object> mapResponse = new Map<String,Object>();
        
        Boolean check = false;

        //Get Sale
        saleSrv.checkReadAccess('Status__c,Account__c,Name,Channel__c,VendorLastName__c,VendorFirstName__c,CommercialId__c,AgencyCode__c,Agency__c,AreaManager__c,DocumentNumber__c,DocumentDate__c,DocumentType__c');
        Sale__c sale = saleQr.getRecordById(saleId, 'Interaction__c,UpperChannelAgency__c,LowerChannelAgency__c,SalesContact__c,CreatedBy.LoginChannel__c,Status__c,Account__c,Name,Channel__c,VendorLastName__c,VendorFirstName__c,CommercialId__c,AgencyCode__c,Agency__c,AreaManager__c,DocumentNumber__c,DocumentDate__c,DocumentType__c');
        check = sale.Status__c == 'Attiva' ? true : false;
        
        Map<String, Order> checkMap = checkExistingOrderParent(saleId);
        Boolean isTari = checkMap != null && !checkMap.isEmpty() && macroProcessType.equalsIgnoreCase('handleProcessTari') && checkMap.keySet().contains('tari');
        Boolean isStandard = checkMap != null && !checkMap.isEmpty() && macroProcessType.equalsIgnoreCase('handleProcess') && checkMap.keySet().contains('standard');
        Boolean createOrder = !isTari && !isStandard;

        Order parentOrder = new Order();

        //Case Sale is 'Attiva'
        if(check){
            //When there is no parent order
            if(createOrder){
                
                AccountContactRelation acr = acrQr.getPrimaryContactRelationBusiness(sale.Account__c);
                Id contactId = acr != null ? acr.ContactId : null;
                
                List<Order> childOrderToUpdate = createOrderStructure(sale, contactId, macroProcessType);

                if(childOrderToUpdate != null && !childOrderToUpdate.isEmpty())
                {
                    HDT_UTL_DatabaseService.updateSObject(childOrderToUpdate);
                    parentOrder = orderQr.getRecordById(childOrderToUpdate[0].ParentOrder__c);
                }

            } 
            else 
            { 
                parentOrder = isTari ? (Order) checkMap.get('tari') : (Order) checkMap.get('standard');
            }
        }

        mapResponse.put('check',check);
        mapResponse.put('checkExist',!createOrder);
        mapResponse.put('orderParent',parentOrder.Id);
        mapResponse.put('orderParentRecord',parentOrder);
        mapResponse.put('orderParentName',parentOrder.Name);
        mapResponse.put('accountId',parentOrder.AccountId);

        return mapResponse;
    }

    @AuraEnabled
    public static Map<String, Object> initWihoutSale(String orderParentId) {
        Map<String,Object> mapResponse = new Map<String,Object>();

        Order parentOrder = orderQr.getRecordById(orderParentId);
        mapResponse.put('check',true);
        mapResponse.put('orderParent',parentOrder.Id);
        mapResponse.put('orderParentRecord',parentOrder);
        mapResponse.put('orderParentName',parentOrder.Name);
        mapResponse.put('accountId',parentOrder.AccountId);
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