@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_UTL_ProcessOrderCreationForVas extends HDT_UTL_ProcessExecution {

    private Map<String, HDT_MassiveFieldsObjectMap__mdt> sobjectMap;
    private List<MassiveLoaderRequestItem__c> itemsToUpdate;
    private List<HDT_WRP_Order> wrapperOrderList;
    private List<HDT_WRP_OrderItem> wrapperOrderItemList;
    private List<Product2> commOfferForRetrieve;
    private List<Product2> additionalProduct2;
    private List<SaleServiceItem__c> saleServiceToInsert = new List<SaleServiceItem__c>();
    private Map<Id, PricebookEntry> priceBookEntryMap = new Map<Id, PricebookEntry>();
    private Map<String, Product2> commOfferMap;
    private Map<String, Map<String, String>> additionalOrderItemMap;
    private List<PricebookEntry> pbeOptionalSkuList = new List<PricebookEntry>();
    private Map<String, String> mapAllFields;
    private List<Opportunity> opportunityToinsert = new List<Opportunity>();
    private Map<Id, Map<Id, PriceBookEntry>> pricebookEntryForOptionalMap;
    private List<Id> accountIdToRetrieve;
    private List<Id> billProfToRetrieve;
    private List<Id> servPointToRetrieve;
    private Map<Id, Account> accountMap;
    private Map<Id, BillingProfile__c> billingProfileMap;
    private Map<Id, ServicePoint__c> servicePointMap;
    private Id childOrderRecordTypeId;
    private Integer parentOrderIndex;

    private List<String> productCodeList = new List<String>();
    private List<String> productNameList = new List<String>();
    private List<String> productDescrList = new List<String>();

    private Map<String, Product2> productMap;
    private Map<Id, Map<Id, PriceBookEntry>> pricebookEntryForVasMap;
    private List<String> contractSapCodeList = new List<String>();
    Map<String, Contract> contractToPbookIdMap = new Map<String, Contract>();


    public override void checks(){

        mapFieldsObject();

        itemsToUpdate = new List<MassiveLoaderRequestItem__c>();
        commOfferForRetrieve = new List<Product2>();
        additionalProduct2 = new List<Product2>();
        accountIdToRetrieve = new List<Id>();
        billProfToRetrieve = new List<Id>();
        servPointToRetrieve = new List<Id>();
        productMap = new Map<String, Product2>();

        childOrderRecordTypeId = getOrderRecordTypeMap(processName);
        parentOrderIndex = 10;

        HDT_WRP_Order wrpOrder;
        HDT_WRP_OrderItem wrpOrderItem;

        List<String> tempSplitedFields;
        HDT_UTL_ProcessSales.HDT_WRP_NextDataObj nextDataObj;
        String orderCode = '';
        Integer rowTypeIndex = mapHeaderForWrapper.get('RowType');
        Integer orderCodeIndex = mapHeaderForWrapper.get('OrderCode');
        String rowType = '';

        wrapperOrderList = new List<HDT_WRP_Order>();
        wrapperOrderItemList = new List<HDT_WRP_OrderItem>();

        for(MassiveLoaderRequestItem__c item : requestItemList){

            tempSplitedFields = item.Data__c.split(splitCharacter, -1);

            rowType = tempSplitedFields[rowTypeIndex];

            if(rowType.equalsIgnoreCase('Order')){

                if(!String.isEmpty(item.NextStepData__c)){
                    nextDataObj = (HDT_UTL_ProcessSales.HDT_WRP_NextDataObj)JSON.deserialize(item.NextStepData__c, HDT_UTL_ProcessSales.HDT_WRP_NextDataObj.class);
                }

                wrpOrder = new HDT_WRP_Order();
                wrpOrder.parentOrder = new Order();
                wrpOrder.order = new Order();
                wrpOrder.contract = new Contract();
                wrpOrder.requestItem = item;

                wrpOrder.orderUniqueKey = tempSplitedFields[orderCodeIndex];

                //wrpOrder.accountId = nextDataObj.accountId;
                //wrpOrder.contactId = nextDataObj.contactId;
                //wrpOrder.billProfId = nextDataObj.billProfId;
                //wrpOrder.servPointId = nextDataObj.servPointId;

                //accountIdToRetrieve.add(nextDataObj.accountId);
                //billProfToRetrieve.add(nextDataObj.billProfId);
                //servPointToRetrieve.add(nextDataObj.servPointId);
                
                orderCode = tempSplitedFields[parentOrderIndex];
                //processObj = buildWrapperOrderStructure(processObj, tempSplitedFields, nextDataObj);
            }

            if(rowType.equalsIgnoreCase('OrderItem')){
                wrpOrderItem = new HDT_WRP_OrderItem();
                wrpOrderItem.orderUniqueKey = tempSplitedFields[orderCodeIndex];
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
                if(String.isNotEmpty(convertionError)){
                    wrpOrder.requestItem.Status__c = 'Errore';
                    wrpOrder.requestItem.StatusDescription__c = convertionError;
                    itemsToUpdate.add(wrpOrder.requestItem);
                    continue;
                }
                //wrpOrder.order.AccountId = contractToPbookIdMap.get(contractCode).AccountId;
                contractSapCodeList.add(wrpOrder.contract.SAPContractCode__c);
                wrapperOrderList.add(wrpOrder);
            }

            if(rowType.equalsIgnoreCase('OrderItem')){
                if(String.isNotEmpty(convertionError)){
                    wrpOrderItem.requestItem.Status__c = 'Errore';
                    wrpOrderItem.requestItem.StatusDescription__c = convertionError;
                    itemsToUpdate.add(wrpOrderItem.requestItem);
                    continue;
                }
                productNameList.add(wrpOrderItem.product.Name);
                productDescrList.add(wrpOrderItem.product.DescriptionSAP__c);
                wrapperOrderItemList.add(wrpOrderItem);
            }


        }

    }

    public override void getRecords(){
        
        List<String> versionList = new List<String>();
        List<Product2> productRetrievedFromDb = new List<Product2>();
        List<Id> productIdList = new List<Id>();
        List<PriceBookEntry> pbeList = new List<PriceBookEntry>();
        List<SBQQ__ProductOption__c> productOptionList = new List<SBQQ__ProductOption__c>();
        commOfferMap = new Map<String, Product2>();
        additionalOrderItemMap = new Map<String, Map<String, String>>();
        pricebookEntryForOptionalMap = new Map<Id, Map<Id, PriceBookEntry>>();
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

        /*for(Product2 commOffer : commOfferForRetrieve){
            productCodeList.add(commOffer.ProductCode);
            versionList.add(commOffer.Version__c);
        }

        for(Product2 orderItemSupplyPoint : additionalProduct2){
            productCodeList.add(orderItemSupplyPoint.ProductCode);
        }

        productRetrievedFromDb = [
            SELECT Id, ProductCode, Version__c
            FROM Product2
            WHERE ProductCode IN :productCodeList AND ProductCode != null
            AND Version__c IN :versionList AND Version__c != null
            AND Family = 'Offerta commerciale'
            WITH SECURITY_ENFORCED
        ];

        for(Product2 p : productRetrievedFromDb){
            productIdList.add(p.Id);
            commOfferMap.put(p.ProductCode + '-' + p.Version__c, p);
            additionalOrderItemMap.put(p.Id, new Map<String, String>());
        }

        pbeList = [
            SELECT Id, Pricebook2Id, Product2Id, UnitPrice
            FROM PricebookEntry
            WHERE Product2Id IN :productIdList
            AND Pricebook2.IsStandard = false
            WITH SECURITY_ENFORCED
        ];
        
        for(PriceBookEntry pbe : pbeList){
            priceBookEntryMap.put(pbe.Product2Id, pbe);

            if(!pricebookEntryForOptionalMap.containsKey(pbe.Pricebook2Id)){
                pricebookEntryForOptionalMap.put(pbe.Pricebook2Id, new Map<Id, PriceBookEntry>());
            }

        }

        productOptionList = [
            SELECT SBQQ__ConfiguredSKU__c, SBQQ__OptionalSKU__c, SBQQ__OptionalSKU__r.ProductCode
            FROM SBQQ__ProductOption__c
            WHERE SBQQ__ConfiguredSKU__c IN :productIdList
            WITH SECURITY_ENFORCED
        ];

        List<Id> optnionalSkuIdList = new List<Id>();
        
        for(SBQQ__ProductOption__c prodOpt : productOptionList){
            if(additionalOrderItemMap.containsKey(prodOpt.SBQQ__ConfiguredSKU__c)){
                Map<String, String> tempMap = additionalOrderItemMap.get(prodOpt.SBQQ__ConfiguredSKU__c);
                tempMap.put(prodOpt.SBQQ__OptionalSKU__r.ProductCode, prodOpt.SBQQ__OptionalSKU__c);
                additionalOrderItemMap.put(prodOpt.SBQQ__ConfiguredSKU__c, tempMap);
                optnionalSkuIdList.add(prodOpt.SBQQ__OptionalSKU__c);
            }
        }
        
        pbeOptionalSkuList = [
            SELECT Id, Pricebook2Id, Product2Id, UnitPrice
            FROM PricebookEntry
            WHERE Product2Id IN :optnionalSkuIdList
            AND Pricebook2.IsStandard = false
            WITH SECURITY_ENFORCED
        ];

        for(PricebookEntry pbe : pbeOptionalSkuList){
            if(pricebookEntryForOptionalMap.containsKey(pbe.Pricebook2Id)){
                Map<Id, PriceBookEntry> tempMap = pricebookEntryForOptionalMap.get(pbe.Pricebook2Id);
                tempMap.put(pbe.Product2Id, pbe);
                pricebookEntryForOptionalMap.put(pbe.Pricebook2Id, tempMap);
            }
        }*/

        //List<Account> accList = HDT_UTL_MassiveOrderFieldsAlignment.getAccountByIds(accountIdToRetrieve);
        //List<BillingProfile__c> billProfList = HDT_UTL_MassiveOrderFieldsAlignment.getBillingProfileByIds(billProfToRetrieve);
        //List<ServicePoint__c> servPointList = HDT_UTL_MassiveOrderFieldsAlignment.getServicePointByIds(servPointToRetrieve);

        //accountMap = new Map<Id, Account>(accList);
        //billingProfileMap = new Map<Id, BillingProfile__c>(billProfList);
        //servicePointMap = new Map<Id, ServicePoint__c>(servPointList);
        
    }

    public override void registryCreation(){

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
            orderUniqueKeyMap.put(wrpOrder.orderUniqueKey, wrpOrder);
        }

        String prodKey;
        for(HDT_WRP_OrderItem wrpOrderItem : wrapperOrderItemList){

            prodKey = wrpOrderItem.product.Name + '-' + wrpOrderItem.product.DescriptionSAP__c + '-' + wrpOrderItem.product.Version__c;
            //wrpOrderItem.orderItem.Quantity = 1;

            String contractCode = '';
            if(orderUniqueKeyMap.containsKey(wrpOrderItem.orderUniqueKey)){
                wrpOrderItem.orderItem.OrderId = orderUniqueKeyMap.get(wrpOrderItem.orderUniqueKey).order.Id;
                contractCode = orderUniqueKeyMap.get(wrpOrderItem.orderUniqueKey).contract.SAPContractCode__c;
            }
            System.debug('>>> contractCode ' + contractCode);
            if(productMap.containsKey(prodKey)){
                wrpOrderItem.orderItem.Product2Id = productMap.get(prodKey).Id;

                String priceBook2Id = contractToPbookIdMap.get(contractCode).SBQQ__AmendmentPricebookId__c;

                System.debug('>>> priceBook2Id ' + priceBook2Id);

                Map<Id, PriceBookEntry> tempMap = pricebookEntryForVasMap.get(Pricebook2Id);

                wrpOrderItem.orderItem.PricebookEntryId = tempMap.get(wrpOrderItem.orderItem.Product2Id).Id;
                wrpOrderItem.orderItem.UnitPrice = tempMap.get(wrpOrderItem.orderItem.Product2Id).UnitPrice;
            }

            requestItemForUpsert.add(wrpOrderItem.requestItem);
            orderItemToInsert.add(wrpOrderItem.orderItem);

        }

        System.debug(JSON.serializePretty(wrapperOrderList));
        System.debug(JSON.serializePretty(wrapperOrderItemList));

        HDT_WRP_SaveResponse saveOrderItemResponse;
        saveOrderItemResponse = databaseUpsert(orderItemToInsert, requestItemForUpsert, 'OrderItem');
        requestItemForUpsert.clear();

        /*
        Id commOffId;
        Id priceBookId;

        for(HDT_WRP_ProcessObjects processObj : processObjList){

            if(processObj.requestItem.Status__c == 'Errore'){
                continue;
            }

            processObj.sale = setSaleObject(processObj.sale, processObj.accountId, processObj.contactId);
            requestItemForUpsert.add(processObj.requestItem);
            saleToInsert.add(processObj.sale);
        }

        HDT_WRP_SaveResponse saveSaleResponse;
        saveSaleResponse = databaseUpsert(saleToInsert, requestItemForUpsert, 'Sale__C');

        requestItemForUpsert.clear();

        for(HDT_WRP_ProcessObjects processObj : processObjList){

            if(processObj.requestItem.Status__c == 'Errore'){
                continue;
            }

            if(saveSaleResponse.errorItemMap.containsKey(processObj.requestItem.Id)){
                System.debug(LoggingLevel.DEBUG, '>>> requestItem.Status__c after save');
                processObj.requestItem.Status__c = 'Errore';
                processObj.requestItem.StatusDescription__c = saveSaleResponse.errorItemMap.get(processObj.requestItem.Id);
                continue;
            }

            processObj.opportunity = setOpportunityObj(processObj.opportunity, processObj.sale, processObj.accountId);
            requestItemForUpsert.add(processObj.requestItem);
            opportunityToinsert.add(processObj.opportunity);
        }

        HDT_WRP_SaveResponse saveOpportunityResponse;
        saveOpportunityResponse = databaseUpsert(opportunityToinsert, requestItemForUpsert, 'Opportunity');

        requestItemForUpsert.clear();

        for(HDT_WRP_ProcessObjects processObj : processObjList){

            if(processObj.requestItem.Status__c == 'Errore'){
                continue;
            }

            if(saveOpportunityResponse.errorItemMap.containsKey(processObj.requestItem.Id)){
                System.debug(LoggingLevel.DEBUG, '>>> requestItem.Status__c after save');
                processObj.requestItem.Status__c = 'Errore';
                processObj.requestItem.StatusDescription__c = saveOpportunityResponse.errorItemMap.get(processObj.requestItem.Id);
                continue;
            }

            for(HDT_WRP_ChildOrder childOrder : processObj.childOrderList){
                if(childOrder.orderType.equalsIgnoreCase('Attivazione')){
                    System.debug(LoggingLevel.DEBUG, '>>> activation');
                    for(HDT_WRP_OrderItem wrpOrderItem : childOrder.orderItemList){
                        if(wrpOrderItem.itemType.equalsIgnoreCase('offertaComm')){
                            System.debug(LoggingLevel.DEBUG, '>>> offertaComm');
                            wrpOrderItem.product = commOfferMap.get(wrpOrderItem.product.ProductCode + '-' + wrpOrderItem.product.Version__c);
                            commOffId = wrpOrderItem.product.Id;
                            wrpOrderItem.orderItem.PriceBookEntryId = priceBookEntryMap.get(commOffId).Id;
                            wrpOrderItem.orderItem.UnitPrice = priceBookEntryMap.get(commOffId).UnitPrice;
                            wrpOrderItem.orderItem.Quantity = 1;
                            wrpOrderItem.orderItem.Product2Id = commOffId;
                            priceBookId = priceBookEntryMap.get(commOffId).Pricebook2Id;
                            System.debug(LoggingLevel.DEBUG, '>>> pbeId offComm ' + wrpOrderItem.orderItem.PriceBookEntryId);
                        }

                    }
                }

            }

            for(HDT_WRP_ChildOrder wrpChildOrder : processObj.childOrderList){

                Map<Id, PriceBookEntry> pbeOptionalMap = pricebookEntryForOptionalMap.get(priceBookId);

                if(wrpChildOrder.orderType.equalsIgnoreCase('Attivazione')){
                    System.debug(LoggingLevel.DEBUG, '>>> activation');

                    wrpChildOrder.childOrder.Pricebook2Id = priceBookId;
                    wrpChildOrder.childOrder.EffectiveDate = Date.today();
                    wrpChildOrder.childOrder.Status = 'Draft';

                    for(HDT_WRP_OrderItem wrpOrderItem : wrpChildOrder.orderItemList){

                        if(wrpOrderItem.itemType.equalsIgnoreCase('POD') || wrpOrderItem.itemType.equalsIgnoreCase('PDR')){
                            Map<String, String> tempMap = additionalOrderItemMap.get(commOffId);
                            if(tempMap.containsKey(wrpOrderItem.product.ProductCode)){
                                wrpOrderItem.product.Id = tempMap.get(wrpOrderItem.product.ProductCode);
                                wrpOrderItem.orderItem.Product2Id = wrpOrderItem.product.Id;
                                wrpOrderItem.orderItem.PriceBookEntryId = pbeOptionalMap.get(wrpOrderItem.product.Id).Id;
                                wrpOrderItem.orderItem.UnitPrice = pbeOptionalMap.get(wrpOrderItem.product.Id).UnitPrice;
                                wrpOrderItem.orderItem.Quantity = 1;
                                System.debug(LoggingLevel.DEBUG, '>>> pbeId pod-pdr ' + wrpOrderItem.orderItem.PriceBookEntryId);
                            } else {
                                wrpOrderItem = null;
                            }
                            
                        }

                    }

                    processObj.parentOrder = setParentOrder(wrpChildOrder.childOrder, processObj.parentOrder, processObj.sale);
                    parentOrderToInsert.add(processObj.parentOrder);
                }

                if(wrpChildOrder.orderType.equalsIgnoreCase('Aggiuntivo')){

                    wrpChildOrder.childOrder.Pricebook2Id = priceBookId;
                    wrpChildOrder.childOrder.EffectiveDate = Date.today();
                    wrpChildOrder.childOrder.Status = 'Draft';

                    for(HDT_WRP_OrderItem wrpOrderItem : wrpChildOrder.orderItemList){
                        Map<String, String> tempMap = additionalOrderItemMap.get(commOffId);
                        if(tempMap.containsKey(wrpOrderItem.product.ProductCode)){
                            wrpOrderItem.product.Id = tempMap.get(wrpOrderItem.product.ProductCode);
                            wrpOrderItem.orderItem.Product2Id = wrpOrderItem.product.Id;
                            wrpOrderItem.orderItem.PriceBookEntryId = pbeOptionalMap.get(wrpOrderItem.product.Id).Id;
                            wrpOrderItem.orderItem.UnitPrice = pbeOptionalMap.get(wrpOrderItem.product.Id).UnitPrice;
                            wrpOrderItem.orderItem.Quantity = 1;
                            System.debug(LoggingLevel.DEBUG, '>>> pbeId aggint ' + wrpOrderItem.orderItem.PriceBookEntryId);
                        } else {
                            wrpOrderItem = null;
                        }
                        
                    }
                }

                requestItemForUpsert.add(processObj.requestItem);
                childOrderToInsert.add(wrpChildOrder.childOrder);

            }
            processObj = setSaleServiceItem(processObj);
            saleServiceToInsert.add(processObj.saleServiceItem);
            //System.debug(LoggingLevel.DEBUG, JSON.serializePretty(processObj));

        }

        HDT_UTL_DatabaseService.insertSObject(parentOrderToInsert);
        HDT_UTL_DatabaseService.insertSObject(saleServiceToInsert);

        for(HDT_WRP_ProcessObjects processObj : processObjList){
            for(HDT_WRP_ChildOrder wrpChildOrder : processObj.childOrderList){

                wrpChildOrder.childOrder.ParentOrder__c = processObj.parentOrder.Id;
                wrpChildOrder.childOrder.Contact__c = processObj.contactId;
                wrpChildOrder.childOrder.SalesContact__c = processObj.contactId;
                wrpChildOrder.childOrder.Sale__c = processObj.sale.Id;
                wrpChildOrder.childOrder = HDT_UTL_MassiveOrderFieldsAlignment.alignAccountFields(wrpChildOrder.childOrder, accountMap.get(processObj.accountId));
                wrpChildOrder.childOrder = HDT_UTL_MassiveOrderFieldsAlignment.alignSaleFields(wrpChildOrder.childOrder, processObj.sale);
                wrpChildOrder.childOrder = HDT_UTL_MassiveOrderFieldsAlignment.alignBillingProfileFields(wrpChildOrder.childOrder, billingProfileMap.get(processObj.billProfId));
                wrpChildOrder.childOrder = HDT_UTL_MassiveOrderFieldsAlignment.alignServicePointFields(wrpChildOrder.childOrder, servicePointMap.get(processObj.servPointId));
            }
        }

        //HDT_UTL_DatabaseService.insertSObject(childOrderToInsert);
        HDT_WRP_SaveResponse saveChildOrderResponse;
        saveChildOrderResponse = databaseUpsert(childOrderToInsert, requestItemForUpsert, 'Order');

        requestItemForUpsert.clear();

        for(HDT_WRP_ProcessObjects processObj : processObjList){

            if(processObj.requestItem.Status__c == 'Errore'){
                continue;
            }
            
            if(saveChildOrderResponse.errorItemMap.containsKey(processObj.requestItem.Id)){
                System.debug(LoggingLevel.DEBUG, '>>> requestItem.Status__c after save');
                processObj.requestItem.Status__c = 'Errore';
                processObj.requestItem.StatusDescription__c = saveChildOrderResponse.errorItemMap.get(processObj.requestItem.Id);
                continue;
            }

            for(HDT_WRP_ChildOrder wrpChildOrder : processObj.childOrderList){
                for(HDT_WRP_OrderItem wrpOrderItem : wrpChildOrder.orderItemList){
                    wrpOrderItem.orderItem.OrderId = wrpChildOrder.childOrder.Id;
                    requestItemForUpsert.add(processObj.requestItem);                    
                    orderItemToInsert.add(wrpOrderItem.orderItem);
                }
            
            }
            
        }

        //HDT_UTL_DatabaseService.insertSObject(orderItemToInsert);
        HDT_WRP_SaveResponse saveOrderItemResponse;
        saveOrderItemResponse = databaseUpsert(orderItemToInsert, requestItemForUpsert, 'OrderItem');

        requestItemForUpsert.clear();

        for(HDT_WRP_ProcessObjects processObj : processObjList){

            itemsToUpdate.add(processObj.requestItem);

            if(processObj.requestItem.Status__c == 'Errore'){
                continue;
            }
            
            if(saveOrderItemResponse.errorItemMap.containsKey(processObj.requestItem.Id)){
                System.debug(LoggingLevel.DEBUG, '>>> requestItem.Status__c after save');
                processObj.requestItem.Status__c = 'Errore';
                processObj.requestItem.StatusDescription__c = saveOrderItemResponse.errorItemMap.get(processObj.requestItem.Id);
                continue;
            }

            for(HDT_WRP_ChildOrder childOrder : processObj.childOrderList){
                if( childOrder.orderType == 'Attivazione' ){
                    childOrder.orderItemList = setRequiredByLookup(childOrder.orderItemList);
                }
            }

        }

        HDT_UTL_DatabaseService.updateSObject(orderItemToInsert);
*/
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
        private Id accountId;
        private Id contactId;
        private Id billProfId;
        private Id servPointId;
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