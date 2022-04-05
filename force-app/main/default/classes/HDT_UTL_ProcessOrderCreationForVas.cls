@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_UTL_ProcessOrderCreationForVas extends HDT_UTL_ProcessExecution {

    private Map<String, HDT_MassiveFieldsObjectMap__mdt> sobjectMap;
    private List<MassiveLoaderRequestItem__c> itemsToUpdate;
    private List<HDT_WRP_Order> wrapperOrderList;
    private List<HDT_WRP_OrderItem> wrapperOrderItemList;
    private Map<String, String> mapAllFields;
    private Map<Id, Account> accountMap;
    private Id childOrderRecordTypeId;
    private List<String> productNameList = new List<String>();
    private List<String> productDescrList = new List<String>();
    private Map<String, Product2> productMap;
    private Map<Id, Map<Id, PriceBookEntry>> pricebookEntryForVasMap;
    private List<String> contractSapCodeList = new List<String>();
    private Map<String, Contract> contractToPbookIdMap = new Map<String, Contract>();

    public override void checks(){

        mapFieldsObject();

        Map<String, Id> failedMap = new Map<String, Id>();
        itemsToUpdate = new List<MassiveLoaderRequestItem__c>();
        productMap = new Map<String, Product2>();

        childOrderRecordTypeId = getOrderRecordTypeMap(processName);

        HDT_WRP_Order wrpOrder;
        HDT_WRP_OrderItem wrpOrderItem;
        List<String> tempSplitedFields;

        String rowType = '';
        String orderUniqueKey;
        //Integer rowTypeIndex = mapHeaderForWrapper.get('RowType');
        //Integer orderCodeIndex = mapHeaderForWrapper.get('OrderCode');
        Integer orderCodeIndex = mapHeaderForWrapper.get('Contratto');
        Integer nomeVasIndex = mapHeaderForWrapper.get('NomeVAS');

        List<HDT_WRP_Order> wrapperOrderTempList = new List<HDT_WRP_Order>();
        List<HDT_WRP_OrderItem> wrapperOrderItemTempList = new List<HDT_WRP_OrderItem>();

        wrapperOrderList = new List<HDT_WRP_Order>();
        wrapperOrderItemList = new List<HDT_WRP_OrderItem>();

        for(MassiveLoaderRequestItem__c item : requestItemList){

            tempSplitedFields = item.Data__c.split(splitCharacter, -1);

            orderUniqueKey = tempSplitedFields[orderCodeIndex];
            //rowType = tempSplitedFields[rowTypeIndex];
            rowType = (String.isEmpty(tempSplitedFields[nomeVasIndex])) ? 'Order' : 'OrderItem';

            if(rowType.equalsIgnoreCase('Order')){
                wrpOrder = new HDT_WRP_Order();
                wrpOrder.parentOrder = new Order();
                wrpOrder.order = new Order();
                wrpOrder.contract = new Contract();
                wrpOrder.requestItem = item;
                wrpOrder.orderUniqueKey = orderUniqueKey;
            }

            if(rowType.equalsIgnoreCase('OrderItem')){
                wrpOrderItem = new HDT_WRP_OrderItem();
                wrpOrderItem.orderUniqueKey = orderUniqueKey;
                wrpOrderItem.itemType = 'OrderItem';
                wrpOrderItem.orderItem = new OrderItem();
                wrpOrderItem.product = new Product2();
                wrpOrderItem.requestItem = item;
            }

            String csvHeader;
            String convertionError;
            String tempValue;
            String objField;
            for(Integer count=0; count < tempSplitedFields.size(); count++){
                tempValue = tempSplitedFields[count];
                csvHeader = mapHeaderByPosition.get(count);
                objField = mapAllFields.get(csvHeader);

                if(String.isBlank(objField) || String.isBlank(tempValue)){
                    continue;
                }

                if(sobjectMap.containsKey(csvHeader)){
                    System.debug('>>> objField: ' + objField + ' - tempValue: ' + tempValue + ' - objectType: ' + sobjectMap.get(csvHeader).objectType__c);
                    switch on sobjectMap.get(csvHeader).objectType__c {
                        when 'Sale__c' {
                            convertionError = mapTypeField(wrpOrder.sale, mapAllFields, count, tempValue);
                        }
                        when 'Order' {
                            convertionError = mapTypeField(wrpOrder.order, mapAllFields, count, tempValue);
                        }
                        when 'ParentOrder' {
                            convertionError = mapTypeField(wrpOrder.parentOrder, mapAllFields, count, tempValue);
                        }
                        when 'Product2' {
                            convertionError = mapTypeField(wrpOrderItem.product, mapAllFields, count, tempValue);
                        }
                        when 'Contract' {
                            convertionError = mapTypeField(wrpOrder.contract, mapAllFields, count, tempValue);
                        }
                        when 'OrderItem' {
                            convertionError = mapTypeField(wrpOrderItem.OrderItem, mapAllFields, count, tempValue);
                        }
                    }
                }

                if(String.isNotEmpty(convertionError)){
                    // error happened -> exit
                    System.debug(LoggingLevel.DEBUG, '>>> break for loop...' + csvHeader + ' - ' + tempValue);
                    break;
                }

            }

            if(rowType.equalsIgnoreCase('Order')){
                
                wrapperOrderTempList.add(wrpOrder);

                if(String.isNotEmpty(convertionError)){
                    //wrpOrder.requestItem.Status__c = 'Errore';
                    //wrpOrder.requestItem.StatusDescription__c = convertionError;
                    wrpOrder.requestItem = setErrorItem(wrpOrder.requestItem, convertionError);
                    failedMap.put(wrpOrder.orderUniqueKey, wrpOrder.requestItem.Id);
                    continue;
                }

            }

            if(rowType.equalsIgnoreCase('OrderItem')){
                
                wrapperOrderItemTempList.add(wrpOrderItem);

                if(String.isNotEmpty(convertionError)){
                    //wrpOrderItem.requestItem.Status__c = 'Errore';
                    //wrpOrderItem.requestItem.StatusDescription__c = convertionError;
                    wrpOrderItem.requestItem = setErrorItem(wrpOrderItem.requestItem, convertionError);
                    failedMap.put(wrpOrderItem.orderUniqueKey, wrpOrderItem.requestItem.Id);
                    continue;
                }

            }


        }

        for(HDT_WRP_Order wrp_order : wrapperOrderTempList){
            if(failedMap.containsKey(wrp_order.orderUniqueKey)){
                wrp_order.requestItem.Status__c = 'Errore';

                if(failedMap.get(wrp_order.orderUniqueKey) != wrp_order.requestItem.Id){
                    wrp_order.requestItem.StatusDescription__c = 'Errore nel formato dati';
                }

                itemsToUpdate.add(wrp_order.requestItem);
            } else {
                contractSapCodeList.add(wrp_order.contract.SAPContractCode__c);
                wrapperOrderList.add(wrp_order);
            }
        }

        for(HDT_WRP_OrderItem wrp_ordetItem : wrapperOrderItemTempList){
            if(failedMap.containsKey(wrp_ordetItem.orderUniqueKey)){
                wrp_ordetItem.requestItem.Status__c = 'Errore';

                if(failedMap.get(wrp_ordetItem.orderUniqueKey) != wrp_ordetItem.requestItem.Id){
                    wrp_ordetItem.requestItem.StatusDescription__c = 'Errore nel formato dati';
                }

                itemsToUpdate.add(wrp_ordetItem.requestItem);
            } else {
                productNameList.add(wrp_ordetItem.product.Name);
                productDescrList.add(wrp_ordetItem.product.DescriptionSAP__c);
                wrapperOrderItemList.add(wrp_ordetItem);
            }
        }


    }

    public override void getRecords(){
        
        List<String> versionList = new List<String>();
        List<Product2> productRetrievedFromDb = new List<Product2>();
        List<Id> productIdList = new List<Id>();
        List<PriceBookEntry> pbeList = new List<PriceBookEntry>();
        List<SBQQ__ProductOption__c> productOptionList = new List<SBQQ__ProductOption__c>();
        pricebookEntryForVasMap = new Map<Id, Map<Id, PriceBookEntry>>();
        

        List<Product2> retrieveVasList = [
            SELECT Id, Name, ProductCode, DescriptionSAP__c, Version__c
            FROM Product2
            WHERE Name IN :productNameList 
            OR DescriptionSAP__c IN :productDescrList
            WITH SECURITY_ENFORCED
        ];

        for(Product2 p : retrieveVasList){
            productMap.put(p.Name + '-' + p.DescriptionSAP__c + '-' + p.Version__c, P);
            productIdList.add(p.Id);
        }
        
        List<Contract> contractList = [
            SELECT Id, SAPContractCode__c, SBQQ__AmendmentPricebookId__c, AccountId
            FROM Contract
            WHERE SAPContractCode__c IN :contractSapCodeList
        ];
        
        List<String> priceBookIdList = new List<String>();
        for(Contract c : contractList){
            priceBookIdList.add(c.SBQQ__AmendmentPricebookId__c);
            contractToPbookIdMap.put(c.SAPContractCode__c, c);
            if(!pricebookEntryForVasMap.containsKey(c.SBQQ__AmendmentPricebookId__c)){
                pricebookEntryForVasMap.put(c.SBQQ__AmendmentPricebookId__c, new Map<Id, PriceBookEntry>());
            }
        }

        List<PriceBookEntry> pbeForVasList = [
            SELECT Id, Pricebook2Id, Product2Id, UnitPrice
            FROM PricebookEntry
            WHERE Product2Id IN :productIdList
            AND Pricebook2Id IN :priceBookIdList
            WITH SECURITY_ENFORCED
        ];

        for(PriceBookEntry pbe : pbeForVasList){
            if(pricebookEntryForVasMap.containsKey(pbe.Pricebook2Id)){
                Map<Id, PriceBookEntry> tempMap = pricebookEntryForVasMap.get(pbe.Pricebook2Id);
                tempMap.put(pbe.Product2Id, pbe);
                pricebookEntryForVasMap.put(pbe.Pricebook2Id, tempMap);
            }
        }
        
    }

    public override void registryCreation(){

        List<sObject> recordToDelete = new List<sObject>();
        List<Order> parentOrderToInsert = new List<Order>();
        List<Order> childOrderToInsert = new List<Order>();
        List<OrderItem> orderItemToInsert = new List<OrderItem>();
        List<Sale__c> saleToInsert = new List<Sale__c>();
        List<MassiveLoaderRequestItem__c> requestItemForUpsert = new List<MassiveLoaderRequestItem__c>();
        Map<String, HDT_WRP_Order> orderUniqueKeyMap = new Map<String, HDT_WRP_Order>();

        for(HDT_WRP_Order wrpOrder : wrapperOrderList){
            wrpOrder.Order.PriceBook2Id = contractToPbookIdMap.get(wrpOrder.contract.SAPContractCode__c).SBQQ__AmendmentPricebookId__c;
            wrpOrder.order.AccountId = contractToPbookIdMap.get(wrpOrder.contract.SAPContractCode__c).AccountId;
            wrpOrder.Order.EffectiveDate = Date.today();
            wrpOrder.Order.Status = 'Draft';
            childOrderToInsert.add(wrpOrder.Order);
            requestItemForUpsert.add(wrpOrder.requestItem);
        }

        HDT_WRP_SaveResponse saveChildOrderResponse;
        saveChildOrderResponse = databaseUpsert(childOrderToInsert, requestItemForUpsert, 'Order');
        requestItemForUpsert.clear();

        for(HDT_WRP_Order wrpOrder : wrapperOrderList){

            if(saveChildOrderResponse.errorItemMap.containsKey(wrpOrder.requestItem.Id)){
                wrpOrder.requestItem.Status__c = 'Errore';
                wrpOrder.requestItem.StatusDescription__c = saveChildOrderResponse.errorItemMap.get(wrpOrder.requestItem.Id);
                continue;
            }
            orderUniqueKeyMap.put(wrpOrder.orderUniqueKey, wrpOrder);
        }

        String prodKey;
        String contractCode = '';
        for(HDT_WRP_OrderItem wrpOrderItem : wrapperOrderItemList){

            if(orderUniqueKeyMap.containsKey(wrpOrderItem.orderUniqueKey)){
                wrpOrderItem.orderItem.OrderId = orderUniqueKeyMap.get(wrpOrderItem.orderUniqueKey).order.Id;
                contractCode = orderUniqueKeyMap.get(wrpOrderItem.orderUniqueKey).contract.SAPContractCode__c;
            } else {
                wrpOrderItem.requestItem.Status__c = 'Errore';
                wrpOrderItem.requestItem.StatusDescription__c = 'Controllare parametri Order';
                continue;
            }

            System.debug('>>> contractCode ' + contractCode);

            prodKey = wrpOrderItem.product.Name + '-' + wrpOrderItem.product.DescriptionSAP__c + '-' + wrpOrderItem.product.Version__c;

            if(productMap.containsKey(prodKey)){
                wrpOrderItem.orderItem.Product2Id = productMap.get(prodKey).Id;

                String pricebook2Id = contractToPbookIdMap.get(contractCode).SBQQ__AmendmentPricebookId__c;

                System.debug('>>> priceBook2Id ' + priceBook2Id);

                if(pricebookEntryForVasMap.containsKey(pricebook2Id)){
                    Map<Id, PriceBookEntry> tempMap = pricebookEntryForVasMap.get(pricebook2Id);
                    wrpOrderItem.orderItem.PricebookEntryId = tempMap.get(wrpOrderItem.orderItem.Product2Id).Id;
                    wrpOrderItem.orderItem.UnitPrice = tempMap.get(wrpOrderItem.orderItem.Product2Id).UnitPrice;
                }

            }

            requestItemForUpsert.add(wrpOrderItem.requestItem);
            orderItemToInsert.add(wrpOrderItem.orderItem);

        }

        //System.debug(JSON.serializePretty(wrapperOrderList));
        //System.debug(JSON.serializePretty(wrapperOrderItemList));

        HDT_WRP_SaveResponse saveOrderItemResponse;
        saveOrderItemResponse = databaseUpsert(orderItemToInsert, requestItemForUpsert, 'OrderItem');
        requestItemForUpsert.clear();

        Set<String> uniqueKeyErrorList = new Set<String>();
        for(HDT_WRP_OrderItem wrpOrderItem : wrapperOrderItemList){

            if(!orderUniqueKeyMap.containsKey(wrpOrderItem.orderUniqueKey)){
                continue;
            }

            if(saveOrderItemResponse.errorItemMap.containsKey(wrpOrderItem.requestItem.Id)){
                wrpOrderItem.requestItem.Status__c = 'Errore';
                wrpOrderItem.requestItem.StatusDescription__c = saveOrderItemResponse.errorItemMap.get(wrpOrderItem.requestItem.Id);
                uniqueKeyErrorList.add(wrpOrderItem.orderUniqueKey);
            } else {
                wrpOrderItem.requestItem.Status__c = 'Chiuso';
            }

        }

        for(HDT_WRP_OrderItem wrpOrderItem : wrapperOrderItemList){

            if(!orderUniqueKeyMap.containsKey(wrpOrderItem.orderUniqueKey)){
                continue;
            }

            if(uniqueKeyErrorList.contains(wrpOrderItem.orderUniqueKey) && wrpOrderItem.requestItem.Status__c != 'Errore'){
                wrpOrderItem.requestItem.Status__c = 'Errore';
                wrpOrderItem.requestItem.StatusDescription__c = 'Controllare struttura order';
            }

        }

        for(HDT_WRP_Order wrpOrder : wrapperOrderList){

            if(!orderUniqueKeyMap.containsKey(wrpOrder.orderUniqueKey)){
                continue;
            }

            if(uniqueKeyErrorList.contains(wrpOrder.orderUniqueKey)){
                wrpOrder.requestItem.Status__c = 'Errore';
                wrpOrder.requestItem.StatusDescription__c = 'Controllare struttura orderItem';
                recordToDelete.add(wrpOrder.order);
            } else {
                wrpOrder.requestItem.Status__c = 'Chiuso';
            }

        }

        HDT_UTL_DatabaseService.deleteSObject(recordToDelete);

        for(HDT_WRP_Order wrpOrder : wrapperOrderList){
            itemsToUpdate.add(wrpOrder.requestItem);
        }

        for(HDT_WRP_OrderItem wrpOrderItem : wrapperOrderItemList){
            itemsToUpdate.add(wrpOrderItem.requestItem);
        }

        getLimitDetails('---processEnd---');

    }

    public override void finalUpdate(){
        System.debug(LoggingLevel.DEBUG, 'finalUpdate');

        if(itemsToUpdate.size() > 0){
            update itemsToUpdate;
        }
    }

    private static List<HDT_WRP_OrderItem> setRequiredByLookup(List<HDT_WRP_OrderItem> wrpOrderItemList){

        OrderItem offComm;
        OrderItem agg;

        for(HDT_WRP_OrderItem wrpOrderItem : wrpOrderItemList){
           if( (wrpOrderItem.itemType == 'POD' || wrpOrderItem.itemType == 'PDR') ){
               agg = wrpOrderItem.orderItem;
           } else if(wrpOrderItem.itemType == 'offertaComm'){
               offComm = wrpOrderItem.orderItem;
           }
        }

        for(HDT_WRP_OrderItem wrpOrderItem : wrpOrderItemList){
            if( (wrpOrderItem.itemType == 'POD' || wrpOrderItem.itemType == 'PDR') ){
                wrpOrderItem.orderItem.SBQQ__RequiredBy__c = offComm.Id;
           }
        }

        return wrpOrderItemList;

    }

    private void mapFieldsObject(){

        mapAllFields = new Map<String, String>();
        List<HDT_MassiveFieldsObjectMap__mdt> allFieldForThisProcess;

        sobjectMap = new Map<String, HDT_MassiveFieldsObjectMap__mdt>();
        allFieldForThisProcess = [
            SELECT MasterLabel, labelField__c, nameField__c, objectType__c, processType__c
            FROM HDT_MassiveFieldsObjectMap__mdt 
            WHERE DeveloperName LIKE 'VAS_%'
            AND processType__c = 'VAS'
            WITH SECURITY_ENFORCED
        ];

        for(HDT_MassiveFieldsObjectMap__mdt temp : allFieldForThisProcess){
            if(temp.objectType__c != 'RowCsv'){
                mapAllFields.put(temp.MasterLabel, temp.nameField__c);
                sobjectMap.put(temp.MasterLabel, temp);
            }
        }

    }

    private Sale__c setSaleObject(Sale__c sale, Id accountId, Id contactId){
        sale.Account__c = accountId;
        sale.SalesContact__c = contactId;
        sale.Name = 'Vendita ' + accountMap.get(accountId).Name;
        sale.SalesContactRole__c = 'Titolare';
        sale.Status__c = 'Attiva';
        return sale;
    }

    //private static HDT_WRP_ProcessObjects setSaleServiceItem(HDT_WRP_ProcessObjects processObj){
    //    processObj.saleServiceItem.Opportunity__c = processObj.opportunity.Id;
    //    processObj.saleServiceItem.ServicePoint__c = processObj.servPointId;
    //    return processObj;
    //}

    private Opportunity setOpportunityObj(Opportunity opp, Sale__c sale, String accountId){
        opp.Sale__c = sale.Id;
        opp.AccountId = accountId;
        opp.Name = 'Opportunity ' + sale.Name;
        opp.StageName = 'Closed Won';
        opp.CloseDate = Date.today();
        return opp;
    }

    private Order setParentOrder(Order childOrder, Order parentOrder, Sale__c sale){

        parentOrder.RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_OrderDossier').getRecordTypeId();
        parentOrder.Name = 'Ordine ' + sale.Name;
        parentOrder.Status = 'In Lavorazione';
        parentOrder.Phase__c = 'Documentazione da firmare';
        parentOrder.ContractSigned__c = true;
        parentOrder.EffectiveDate = Date.today();
        parentOrder.Step__c = 2;
        parentOrder.AccountId = sale.Account__c;
        parentOrder.Sale__c = sale.Id;
        parentOrder.Contact__c = sale.SalesContact__c;
        parentOrder.Channel__c = sale.Channel__c;
        parentOrder.LoginChannel__c = sale.Channel__c;
        parentOrder.VendorLastName__c = sale.VendorLastName__c;
        parentOrder.VendorFirstName__c = sale.VendorFirstName__C;
        parentOrder.CommercialId__c = sale.CommercialId__c;
        parentOrder.AgencyCode__c = sale.AgencyCode__c;
        parentOrder.Agency__c = sale.Agency__c;
        parentOrder.AreaManager__c = sale.AreaManager__c;
        parentOrder.ServicePoint__c = childOrder.ServicePoint__c;
        parentOrder.SignatureMethod__c = childOrder.SignatureMethod__c;
        parentOrder.DocSendingMethod__c = childOrder.DocSendingMethod__c;
        return parentOrder;

    }

    private static Id getOrderRecordTypeMap(String processName){
        Map<String, String> rtNameMap = new Map<String, String>();
        rtNameMap.put('SwitchIn', 'HDT_RT_SwitchIn');
        rtNameMap.put('Subentro', 'HDT_RT_Subentro');
        rtNameMap.put('PrimaAttivazione', 'HDT_RT_Attivazione');
        rtNameMap.put('Voltura', 'HDT_RT_Voltura');
        rtNameMap.put('VAS', 'HDT_RT_VAS');
        rtNameMap.put('CambioUso', 'HDT_RT_CambioUso');
        rtNameMap.put('CambioOfferta', 'HDT_RT_CambioOfferta');
        rtNameMap.put('MUC', '');
        rtNameMap.put('TariffeSconti', 'HDT_RT_ScontiBonus');

        String devName = rtNameMap.get(processName);
        return Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get(devName).getRecordTypeId();

    }

    private class HDT_WRP_Order {
        private MassiveLoaderRequestItem__c requestItem;
        private Opportunity opportunity;
        private Sale__c sale;
        private SaleServiceItem__c saleServiceItem;
        private Order parentOrder;
        private Order order;
        private Contract contract;
        private String orderUniqueKey;
    }
    
    private class HDT_WRP_OrderItem {
        private MassiveLoaderRequestItem__c requestItem;
        private String orderUniqueKey;
        private String contractCode;
        private String itemType;
        private OrderItem orderItem;
        private Product2 product;
    }

}