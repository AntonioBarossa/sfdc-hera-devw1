@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_UTL_ProcessOrderCreation extends HDT_UTL_ProcessExecution{

    /*
        List<MassiveLoaderRequestItem__c> scope;
        scope = [
            SELECT Id, Data__c, NextStepData__c
            FROM MassiveLoaderRequestItem__c
            WHERE MassiveLoaderRequest__c = 'a3d3O000000XFIJQA4'
            AND Status__c = 'In attesa di lavorazione'
        ];
        HDT_UTL_ProcessExecution cls;
        Type t = Type.forName('HDT_UTL_ProcessOrderCreation');
        cls = (HDT_UTL_ProcessExecution)t.newInstance();
        cls.setProcess('TestSales');
        cls.setMassiveLoaderRequestItemList(scope);
        cls.execute();
    */

    private Map<String, MassiveFieldsObjectMap__c> sobjectMap;
    private List<MassiveLoaderRequestItem__c> itemsToUpdate;
    private List<HDT_WRP_ProcessObjects> processObjList;
    private List<Product2> commOfferForRetrieve;
    private List<Product2> additionalProduct2;
    private List<SaleServiceItem__c> saleServiceToInsert = new List<SaleServiceItem__c>();
    private Map<Id, PricebookEntry> priceBookEntryMap = new Map<Id, PricebookEntry>();
    private Map<String, Product2> commOfferMap;
    private Map<String, Map<String, SBQQ__ProductOption__c>> additionalOrderItemMap;
    private List<PricebookEntry> pbeOptionalSkuList = new List<PricebookEntry>();
    private Map<String, String> mapAllFields;
    private List<Opportunity> opportunityToinsert = new List<Opportunity>();
    private Map<String, String> productForActivationMap;
    private Map<String, MassiveFieldsObjectMap__c> productForAdditionalMap ;
    private Map<Id, Map<Id, PriceBookEntry>> pricebookEntryForOptionalMap;
    private List<Id> accountIdToRetrieve;
    private List<Id> billProfToRetrieve;
    private List<Id> servPointToRetrieve;
    private Map<Id, Account> accountMap;
    private Map<Id, BillingProfile__c> billingProfileMap;
    private Map<Id, ServicePoint__c> servicePointMap;
    private Id childOrderRecordTypeId;
    private OrderItem fakeOrderItem;
    private Map<String, String> companyCodeMap;
    private Map<String, String> processMatrixMap;

    public override void checks(){

        mapFieldsObject();

        itemsToUpdate = new List<MassiveLoaderRequestItem__c>();
        commOfferForRetrieve = new List<Product2>();
        additionalProduct2 = new List<Product2>();
        accountIdToRetrieve = new List<Id>();
        billProfToRetrieve = new List<Id>();
        servPointToRetrieve = new List<Id>();

        childOrderRecordTypeId = getOrderRecordTypeMap(processName);

        HDT_WRP_ProcessObjects processObj;
        processObjList = new List<HDT_WRP_ProcessObjects>();
        List<String> tempSplitedFields;
        //HDT_UTL_ProcessSales.HDT_WRP_NextDataObj nextDataObj;
        fakeOrderItem = new OrderItem();
        for(MassiveLoaderRequestItem__c item : requestItemList){
            processObj = new HDT_WRP_ProcessObjects();
            tempSplitedFields = item.Data__c.split(splitCharacter, -1);
            if(!String.isEmpty(item.NextStepData__c)){
                processObj.nextDataObj = (HDT_UTL_ProcessSales.HDT_WRP_NextDataObj)JSON.deserialize(item.NextStepData__c, HDT_UTL_ProcessSales.HDT_WRP_NextDataObj.class);
            }

            processObj.requestItem = item;
            accountIdToRetrieve.add(processObj.nextDataObj.accountId);
            billProfToRetrieve.add(processObj.nextDataObj.billProfId);
            servPointToRetrieve.add(processObj.nextDataObj.servPointId);

            processObj = buildWrapperOrderStructure(processObj, tempSplitedFields, processObj.nextDataObj);

            ////system.debug('>>> ' + JSON.serializePretty(processObj));

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
                    switch on sobjectMap.get(csvHeader).objectType__c {
                        when 'Sale__c' {
                            convertionError = mapTypeField(processObj.sale, mapAllFields, count, tempValue);
                        }
                        when 'ChildOrder' {
                            for(HDT_WRP_ChildOrder wrpChildOrder : processObj.childOrderList){
                                convertionError = mapTypeField(wrpChildOrder.childOrder, mapAllFields, count, tempValue);
                            }
                        }
                        when 'ParentOrder' {
                            convertionError = mapTypeField(processObj.parentOrder, mapAllFields, count, tempValue);
                        }
                        when 'OrderItem' {
                            convertionError = mapTypeField(fakeOrderItem, mapAllFields, count, tempValue);
                        }
                    }
                }

                if(String.isNotEmpty(convertionError)){
                    // error happened -> exit
                    //system.debug(LoggingLevel.DEBUG, '>>> break for loop...' + csvHeader + ' - ' + tempValue);
                    break;
                }

            }

            if(String.isNotEmpty(convertionError)){
                processObj.requestItem.Status__c = 'Errore';
                processObj.requestItem.StatusDescription__c = convertionError;
                itemsToUpdate.add(processObj.requestItem);
                continue;
            }

            processObjList.add(processObj);

        }
        getLimitDetails('convertionEnd');
    }

    public override void getRecords(){

        List<String> productCodeList = new List<String>();
        List<String> versionList = new List<String>();
        List<Product2> productRetrievedFromDb = new List<Product2>();
        List<Id> productIdList = new List<Id>();
        List<PriceBookEntry> pbeList = new List<PriceBookEntry>();
        List<SBQQ__ProductOption__c> productOptionList = new List<SBQQ__ProductOption__c>();
        commOfferMap = new Map<String, Product2>();
        additionalOrderItemMap = new Map<String, Map<String, SBQQ__ProductOption__c>>();
        pricebookEntryForOptionalMap = new Map<Id, Map<Id, PriceBookEntry>>();
        processMatrixMap = new Map<String, String>();
        List<ProcessMatrix__c> processMatrixList = new List<ProcessMatrix__c>();

        processMatrixList = [
            SELECT ProcessName__c, RecordTypeName__c, CasualCode__c
            FROM ProcessMatrix__c
            WITH SECURITY_ENFORCED
        ];

        for(ProcessMatrix__c matrix : processMatrixList){
            processMatrixMap.put(matrix.ProcessName__c, matrix.CasualCode__c);
        }

        for(Product2 commOffer : commOfferForRetrieve){
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
            additionalOrderItemMap.put(p.Id, new Map<String, SBQQ__ProductOption__c>());
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
            SELECT SBQQ__ConfiguredSKU__c, SBQQ__OptionalSKU__c, SBQQ__OptionalSKU__r.ProductCode, SBQQ__OptionalSKU__r.Name
            FROM SBQQ__ProductOption__c
            WHERE SBQQ__ConfiguredSKU__c IN :productIdList
            WITH SECURITY_ENFORCED
        ];

        List<Id> optnionalSkuIdList = new List<Id>();
        
        for(SBQQ__ProductOption__c prodOpt : productOptionList){
            if(additionalOrderItemMap.containsKey(prodOpt.SBQQ__ConfiguredSKU__c)){
                Map<String, SBQQ__ProductOption__c> tempMap = additionalOrderItemMap.get(prodOpt.SBQQ__ConfiguredSKU__c);
                tempMap.put(prodOpt.SBQQ__OptionalSKU__r.ProductCode, prodOpt);
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
        }

        List<Account> accList = HDT_UTL_MassiveOrderFieldsAlignment.getAccountByIds(accountIdToRetrieve);
        List<BillingProfile__c> billProfList = HDT_UTL_MassiveOrderFieldsAlignment.getBillingProfileByIds(billProfToRetrieve);
        List<ServicePoint__c> servPointList = HDT_UTL_MassiveOrderFieldsAlignment.getServicePointByIds(servPointToRetrieve);

        accountMap = new Map<Id, Account>(accList);
        billingProfileMap = new Map<Id, BillingProfile__c>(billProfList);
        servicePointMap = new Map<Id, ServicePoint__c>(servPointList);
        
    }

    public override void registryCreation(){

        List<Order> parentOrderToInsert = new List<Order>();
        List<Order> childOrderToInsert = new List<Order>();
        List<OrderItem> orderItemToInsert = new List<OrderItem>();
        List<Sale__c> saleToInsert = new List<Sale__c>();
        List<MassiveLoaderRequestItem__c> requestItemForUpsert = new List<MassiveLoaderRequestItem__c>();

        Id commOffId;
        Id priceBookId;

        for(HDT_WRP_ProcessObjects processObj : processObjList){

            if(processObj.requestItem.Status__c == 'Errore'){
                continue;
            }

            processObj.sale = setSaleObject(processObj.sale, processObj.nextDataObj.accountId, processObj.nextDataObj.contactId);
            requestItemForUpsert.add(processObj.requestItem);
            saleToInsert.add(processObj.sale);
        }

        //HDT_UTL_DatabaseService.insertSObject(saleToInsert);
        HDT_WRP_SaveResponse saveSaleResponse;
        saveSaleResponse = databaseUpsert(saleToInsert, requestItemForUpsert, 'Sale__C');

        requestItemForUpsert.clear();

        for(HDT_WRP_ProcessObjects processObj : processObjList){

            if(processObj.requestItem.Status__c == 'Errore'){
                continue;
            }

            if(saveSaleResponse.errorItemMap.containsKey(processObj.requestItem.Id)){
                //system.debug(LoggingLevel.DEBUG, '>>> requestItem.Status__c after save');
                processObj.requestItem.Status__c = 'Errore';
                processObj.requestItem.StatusDescription__c = saveSaleResponse.errorItemMap.get(processObj.requestItem.Id);
                continue;
            }

            processObj.opportunity = setOpportunityObj(processObj.opportunity, processObj.sale, processObj.nextDataObj.accountId);
            requestItemForUpsert.add(processObj.requestItem);
            opportunityToinsert.add(processObj.opportunity);
        }

        //HDT_UTL_DatabaseService.insertSObject(opportunityToinsert);
        HDT_WRP_SaveResponse saveOpportunityResponse;
        saveOpportunityResponse = databaseUpsert(opportunityToinsert, requestItemForUpsert, 'Opportunity');

        requestItemForUpsert.clear();

        for(HDT_WRP_ProcessObjects processObj : processObjList){

            if(processObj.requestItem.Status__c == 'Errore'){
                continue;
            }

            if(saveOpportunityResponse.errorItemMap.containsKey(processObj.requestItem.Id)){
                //system.debug(LoggingLevel.DEBUG, '>>> requestItem.Status__c after save');
                processObj.requestItem.Status__c = 'Errore';
                processObj.requestItem.StatusDescription__c = saveOpportunityResponse.errorItemMap.get(processObj.requestItem.Id);
                continue;
            }

            for(HDT_WRP_ChildOrder childOrder : processObj.childOrderList){
                if(childOrder.orderType.equalsIgnoreCase('Attivazione')){
                    //system.debug(LoggingLevel.DEBUG, '>>> activation');
                    for(HDT_WRP_OrderItem wrpOrderItem : childOrder.orderItemList){

                        //wrpOrderItem.OrderItem = fakeOrderItem;

                        if(wrpOrderItem.itemType.equalsIgnoreCase('offertaComm')){
                            //system.debug(LoggingLevel.DEBUG, '>>> offertaComm');
                            wrpOrderItem.product = commOfferMap.get(wrpOrderItem.product.ProductCode + '-' + wrpOrderItem.product.Version__c);
                            commOffId = wrpOrderItem.product.Id;
                            wrpOrderItem.orderItem.PriceBookEntryId = priceBookEntryMap.get(commOffId).Id;
                            wrpOrderItem.orderItem.UnitPrice = priceBookEntryMap.get(commOffId).UnitPrice;
                            wrpOrderItem.orderItem.Quantity = 1;
                            wrpOrderItem.orderItem.Product2Id = commOffId;
                            priceBookId = priceBookEntryMap.get(commOffId).Pricebook2Id;
                            //system.debug(LoggingLevel.DEBUG, '>>> pbeId offComm ' + wrpOrderItem.orderItem.PriceBookEntryId);
                        }

                    }
                }

            }

            for(HDT_WRP_ChildOrder wrpChildOrder : processObj.childOrderList){

                Map<Id, PriceBookEntry> pbeOptionalMap = pricebookEntryForOptionalMap.get(priceBookId);

                if(wrpChildOrder.orderType.equalsIgnoreCase('Attivazione')){
                    //system.debug(LoggingLevel.DEBUG, '>>> activation');

                    wrpChildOrder.childOrder.Pricebook2Id = priceBookId;
                    wrpChildOrder.childOrder.EffectiveDate = Date.today();
                    wrpChildOrder.childOrder.Status = 'Draft';

                    for(HDT_WRP_OrderItem wrpOrderItem : wrpChildOrder.orderItemList){

                        if(wrpOrderItem.itemType.equalsIgnoreCase('POD') || wrpOrderItem.itemType.equalsIgnoreCase('PDR') ||
                           wrpOrderItem.itemType.equalsIgnoreCase('bonus') || wrpOrderItem.itemType.equalsIgnoreCase('promo')
                        ){
                            Map<String, SBQQ__ProductOption__c> tempMap = additionalOrderItemMap.get(commOffId);
                            if(tempMap.containsKey(wrpOrderItem.product.ProductCode)){
                                wrpOrderItem.product.Id = tempMap.get(wrpOrderItem.product.ProductCode).SBQQ__OptionalSKU__c;
                                wrpOrderItem.orderItem.Product2Id = wrpOrderItem.product.Id;
                                wrpOrderItem.orderItem.PriceBookEntryId = pbeOptionalMap.get(wrpOrderItem.product.Id).Id;
                                wrpOrderItem.orderItem.UnitPrice = pbeOptionalMap.get(wrpOrderItem.product.Id).UnitPrice;
                                wrpOrderItem.orderItem.Quantity = 1;
                                //system.debug(LoggingLevel.DEBUG, '>>> pbeId pod-pdr ' + wrpOrderItem.orderItem.PriceBookEntryId);
                            } else {
                                wrpOrderItem = null;
                            }
                            
                        }

                    }

                    processObj.parentOrder = setParentOrder(wrpChildOrder.childOrder, processObj.parentOrder, processObj.sale);
                    parentOrderToInsert.add(processObj.parentOrder);
                    
                } else if(wrpChildOrder.orderType.equalsIgnoreCase('analisiConsumi')){

                    wrpChildOrder.childOrder.Pricebook2Id = priceBookId;
                    wrpChildOrder.childOrder.EffectiveDate = Date.today();
                    wrpChildOrder.childOrder.Status = 'Draft';
                    wrpChildOrder.childOrder.processType__c = 'VAS';

                    for(HDT_WRP_OrderItem wrpOrderItem : wrpChildOrder.orderItemList){
                        Map<String, SBQQ__ProductOption__c> tempMap = additionalOrderItemMap.get(commOffId);

                        SBQQ__ProductOption__c tempProdOpt;
                        for(String key : tempMap.keySet()){
                            tempProdOpt = tempMap.get(key);
                            if(tempProdOpt.SBQQ__OptionalSKU__r.Name.equalsIgnoreCase('Analisi Consumi')){
                                wrpOrderItem.product.Id = tempProdOpt.SBQQ__OptionalSKU__c;
                                wrpOrderItem.orderItem.Product2Id = wrpOrderItem.product.Id;
                                wrpOrderItem.orderItem.PriceBookEntryId = pbeOptionalMap.get(wrpOrderItem.product.Id).Id;
                                wrpOrderItem.orderItem.UnitPrice = pbeOptionalMap.get(wrpOrderItem.product.Id).UnitPrice;
                                wrpOrderItem.orderItem.Quantity = 1;
                                //system.debug(LoggingLevel.DEBUG, '>>> pbeId aggint ' + wrpOrderItem.orderItem.PriceBookEntryId);
                            }
                            
                        }
                        
                    }
                }

                requestItemForUpsert.add(processObj.requestItem);
                childOrderToInsert.add(wrpChildOrder.childOrder);

            }
            processObj = setSaleServiceItem(processObj);
            saleServiceToInsert.add(processObj.saleServiceItem);
            ////system.debug(LoggingLevel.DEBUG, JSON.serializePretty(processObj));

        }

        HDT_UTL_DatabaseService.insertSObject(parentOrderToInsert);
        HDT_UTL_DatabaseService.insertSObject(saleServiceToInsert);

        String commodity = '';
        for(HDT_WRP_ProcessObjects processObj : processObjList){
            for(HDT_WRP_ChildOrder wrpChildOrder : processObj.childOrderList){

                wrpChildOrder.childOrder.ParentOrder__c = processObj.parentOrder.Id;
                wrpChildOrder.childOrder.Contact__c = processObj.nextDataObj.contactId;
                wrpChildOrder.childOrder.SalesContact__c = processObj.nextDataObj.contactId;
                wrpChildOrder.childOrder.Sale__c = processObj.sale.Id;
                wrpChildOrder.childOrder = HDT_UTL_MassiveOrderFieldsAlignment.alignAccountFields(wrpChildOrder.childOrder, accountMap.get(processObj.nextDataObj.accountId));
                wrpChildOrder.childOrder = HDT_UTL_MassiveOrderFieldsAlignment.alignSaleFields(wrpChildOrder.childOrder, processObj.sale);
                wrpChildOrder.childOrder = HDT_UTL_MassiveOrderFieldsAlignment.alignBillingProfileFields(wrpChildOrder.childOrder, billingProfileMap.get(processObj.nextDataObj.billProfId));
                wrpChildOrder.childOrder = HDT_UTL_MassiveOrderFieldsAlignment.alignServicePointFields(wrpChildOrder.childOrder, servicePointMap.get(processObj.nextDataObj.servPointId));

                commodity = servicePointMap.get(processObj.nextDataObj.servPointId).CommoditySector__c;

                if(companyCodeMap.containsKey(processObj.sale.SalesCompany__c + '_' +  commodity)){
                    wrpChildOrder.childOrder.SalesCompanyCode__c = companyCodeMap.get(processObj.sale.SalesCompany__c + '_' +  commodity);
                }

                wrpChildOrder.childOrder.SalesCompany__c = processObj.sale.SalesCompany__c;
                //wrpChildOrder.childOrder.Phase__c = 'Comunicazione verso Heroku';
                if(processMatrixMap.containsKey(wrpChildOrder.childOrder.ProcessType__c)){
                    wrpChildOrder.childOrder.ProcessCode__c = processMatrixMap.get(wrpChildOrder.childOrder.ProcessType__c);
                }
                
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
                //system.debug(LoggingLevel.DEBUG, '>>> requestItem.Status__c after save');
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
      
        HDT_WRP_SaveResponse saveOrderItemResponse;
        saveOrderItemResponse = databaseUpsert(orderItemToInsert, requestItemForUpsert, 'OrderItem');

        requestItemForUpsert.clear();

        List<OrderItem> orderItemToUpdate = new List<OrderItem>();
        for(HDT_WRP_ProcessObjects processObj : processObjList){

            if(processObj.requestItem.Status__c == 'Errore'){
                itemsToUpdate.add(processObj.requestItem);
                continue;
            }
            
            if(saveOrderItemResponse.errorItemMap.containsKey(processObj.requestItem.Id)){
                //system.debug(LoggingLevel.DEBUG, '>>> requestItem.Status__c after save');
                processObj.requestItem.Status__c = 'Errore';
                processObj.requestItem.StatusDescription__c = saveOrderItemResponse.errorItemMap.get(processObj.requestItem.Id);
                itemsToUpdate.add(processObj.requestItem);
                continue;
            }

            for(HDT_WRP_ChildOrder wrpChildOrder : processObj.childOrderList){
                if( wrpChildOrder.orderType == 'Attivazione' ){
                    wrpChildOrder.orderItemList = setRequiredByLookup(wrpChildOrder.orderItemList);
                    for(HDT_WRP_OrderItem wrpOrderItem : wrpChildOrder.orderItemList){
                        orderItemToUpdate.add(wrpOrderItem.orderItem);
                        requestItemForUpsert.add(processObj.requestItem);
                    }
                }
            }
            processObj.nextDataObj.parentOrderId = processObj.parentOrder.Id;
            processObj.requestItem.NextStepData__c = JSON.serialize(processObj.nextDataObj);
            itemsToUpdate.add(processObj.requestItem);
        }

        HDT_WRP_SaveResponse updateOrderItemResponse;
        updateOrderItemResponse = databaseUpsert(orderItemToUpdate, requestItemForUpsert, 'OrderItem');
        requestItemForUpsert.clear();

        for(HDT_WRP_ProcessObjects processObj : processObjList){
            if(processObj.requestItem.Status__c == 'Errore'){
                continue;
            }
            processObj.requestItem.Status__c = 'In Lavorazione';
        }
        getLimitDetails('processEnd');

    }

    public override void finalUpdate(){
        //system.debug(LoggingLevel.DEBUG, 'finalUpdate');

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

        productForAdditionalMap  = new Map<String, MassiveFieldsObjectMap__c>();
        productForActivationMap = new Map<String, String>();
        mapAllFields = new Map<String, String>();
        List<MassiveFieldsObjectMap__c> allFieldForThisProcess;
        companyCodeMap = new Map<String, String>();

        sobjectMap = new Map<String, MassiveFieldsObjectMap__c>();
        allFieldForThisProcess = [
            SELECT objectType__c, labelField__c, nameField__c
            FROM MassiveFieldsObjectMap__c 
            WHERE Name LIKE 'Sales%'
            WITH SECURITY_ENFORCED
        ];

        for(MassiveFieldsObjectMap__c temp : allFieldForThisProcess){
            mapAllFields.put(temp.labelField__c, temp.nameField__c);
            sobjectMap.put(temp.labelField__c, temp);
        }

        List<MassiveFieldsObjectMap__c> productMdtList  = [
            SELECT labelField__c, nameField__c, objectType__c, processType__c
            FROM MassiveFieldsObjectMap__c 
            WHERE Name LIKE 'Sales%'
            AND objectType__c = 'Product2'
            WITH SECURITY_ENFORCED
        ];

        for(MassiveFieldsObjectMap__c mdt : productMdtList ){
            if(mdt.labelField__c.equalsIgnoreCase('Attivazione')){
                productForActivationMap.put(mdt.labelField__c, mdt.nameField__c);
            }

            if(mdt.labelField__c.equalsIgnoreCase('Aggiuntivi')){
                productForAdditionalMap .put(mdt.labelField__c, mdt);
            }
            
        }

        List<HDT_MatriceSocietaVendita__mdt> matriceList  = [
            SELECT Id, SalesCompanyCode__c, SellerCompany__c, Service__c
            FROM HDT_MatriceSocietaVendita__mdt
            WITH SECURITY_ENFORCED
        ];

        for(HDT_MatriceSocietaVendita__mdt m : matriceList){
            companyCodeMap.put(m.SellerCompany__c + '_' + m.Service__c, m.SalesCompanyCode__c);
        }

    }

    private Sale__c setSaleObject(Sale__c sale, Id accountId, Id contactId){
        sale.Account__c = accountId;
        sale.SalesContact__c = contactId;
        sale.Name = 'Vendita ' + accountMap.get(accountId).Name;
        sale.SalesContactRole__c = 'Titolare';
        sale.Status__c = 'Attiva';
        sale.Channel__c = sale.LowerChannelAgency__c;
        return sale;
    }

    private static HDT_WRP_ProcessObjects setSaleServiceItem(HDT_WRP_ProcessObjects processObj){
        processObj.saleServiceItem.Opportunity__c = processObj.opportunity.Id;
        processObj.saleServiceItem.ServicePoint__c = processObj.nextDataObj.servPointId;
        return processObj;
    }

    private Opportunity setOpportunityObj(Opportunity opp, Sale__c sale, String accountId){
        opp.Sale__c = sale.Id;
        opp.AccountId = accountId;
        opp.Name = 'Opportunity ' + sale.Name;
        opp.StageName = 'Closed Won';
        opp.CloseDate = Date.today();
        return opp;
    }

    public Order setParentOrder(Order childOrder, Order parentOrder, Sale__c sale){

        parentOrder.RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_OrderDossier').getRecordTypeId();
        parentOrder.Name = 'Ordine ' + sale.Name;
        parentOrder.Status = 'In Lavorazione';
        parentOrder.Phase__c = 'Documentazione Gestita';
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
        parentOrder.SignatureMethod__c = childOrder.SignatureMethod__c;
        parentOrder.DocSendingMethod__c = childOrder.DocSendingMethod__c;
        parentOrder.SignedDate__c = childOrder.SignedDate__c;
        parentOrder.PhoneNumber__c = childOrder.PhoneNumber__c;
        parentOrder.ShippingMail__c = childOrder.ShippingMail__c;
        parentOrder.ShippingCity__c = childOrder.ShippingCity__c;
        parentOrder.ShippingCountry__c = childOrder.ShippingCountry__c;
        parentOrder.ShippingPostalCode__c = childOrder.ShippingPostalCode__c;
        parentOrder.ShippingProvince__c = childOrder.ShippingProvince__c;
        parentOrder.ShippingStreetName__c = childOrder.ShippingStreetName__c;
        parentOrder.ShippingStreetNumber__c	= childOrder.ShippingStreetNumber__c;
        return parentOrder;
    }

    private HDT_WRP_ProcessObjects buildWrapperOrderStructure(HDT_WRP_ProcessObjects processObject, List<String> csvValues, HDT_UTL_ProcessSales.HDT_WRP_NextDataObj nextDataObj){

        String codiceOfferta = csvValues[mapHeaderForWrapper.get('CodiceOfferta')];
        String versione = csvValues[mapHeaderForWrapper.get('VersioneOfferta')];

        if(String.isNotEmpty(codiceOfferta) && String.isNotEmpty(versione)){
            HDT_WRP_ChildOrder wrpChildOrder = new HDT_WRP_ChildOrder();
            wrpChildOrder.orderType = 'Attivazione';
            wrpChildOrder.childOrder = new Order();
            wrpChildOrder.childOrder.RecordTypeId = childOrderRecordTypeId;
            wrpChildOrder.childOrder.IsMassive__c = true;
            wrpChildOrder.childOrder.Status = 'In Lavorazione';
            wrpChildOrder.childOrder.AccountId = nextDataObj.accountId;
            wrpChildOrder.childOrder.ServicePoint__c = nextDataObj.servPointId;
            wrpChildOrder.childOrder.BillingProfile__c = nextDataObj.billProfId;
            wrpChildOrder.orderItemList = new List<HDT_WRP_OrderItem>();
    
            HDT_WRP_OrderItem wrpOrderItem;
            // set wrapper for "Attivazione"
            wrpOrderItem = new HDT_WRP_OrderItem();
            wrpOrderItem.itemType = 'offertaComm';
            wrpOrderItem.product = new Product2();
            wrpOrderItem.product.ProductCode = codiceOfferta;
            wrpOrderItem.product.Version__c = versione;
            wrpOrderItem.orderItem = new OrderItem();
            wrpChildOrder.orderItemList.add(wrpOrderItem);
            commOfferForRetrieve.add(wrpOrderItem.product);

            String itemTypeCsv = csvValues[mapHeaderForWrapper.get('ServicePointServizio')];
            String itemType = '';

            if(String.isNotEmpty(itemTypeCsv) && itemTypeCsv.equalsIgnoreCase('Energia Elettrica')){
                itemType = 'POD';
            } else if(String.isNotEmpty(itemTypeCsv) && itemTypeCsv.equalsIgnoreCase('Gas')){
                itemType = 'PDR';
            }

            wrpOrderItem = new HDT_WRP_OrderItem();
            wrpOrderItem.itemType = itemType;
            wrpOrderItem.product = new Product2();
            wrpOrderItem.product.ProductCode = itemType;
            wrpOrderItem.orderItem = new OrderItem();
            wrpChildOrder.orderItemList.add(wrpOrderItem);
            additionalProduct2.add(wrpOrderItem.product);

            String codiceBonus = csvValues[mapHeaderForWrapper.get('CodiceBonus')];
            String codicePromo = csvValues[mapHeaderForWrapper.get('CodicePromo')];
            
            Boolean enableCodiceBonus = (String.isNotEmpty(codiceBonus));
            Boolean enableCodicePromo = (String.isNotEmpty(codicePromo));

            if(enableCodiceBonus){
                // set wrapper for "bonus"
                wrpOrderItem = new HDT_WRP_OrderItem();
                wrpOrderItem.itemType = 'bonus';
                wrpOrderItem.product = new Product2();
                wrpOrderItem.product.ProductCode = codiceBonus;
                wrpOrderItem.orderItem = new OrderItem();
                wrpChildOrder.orderItemList.add(wrpOrderItem);
                additionalProduct2.add(wrpOrderItem.product);
            }

            if(enableCodicePromo){
                // set wrapper for "promo"
                wrpOrderItem = new HDT_WRP_OrderItem();
                wrpOrderItem.itemType = 'promo';
                wrpOrderItem.product = new Product2();
                wrpOrderItem.product.ProductCode = codicePromo;
                wrpOrderItem.orderItem = new OrderItem();
                wrpChildOrder.orderItemList.add(wrpOrderItem);
                additionalProduct2.add(wrpOrderItem.product);
            }

            processObject.childOrderList.add(wrpChildOrder);
        }

        String codiceAnalisiConsumi = csvValues[mapHeaderForWrapper.get('AnalisiConsumi')];
        Boolean enableCodiceAnalisiConsumi = (String.isNotEmpty(codiceAnalisiConsumi) && codiceAnalisiConsumi.equalsIgnoreCase('true')) ? true : false;

        if(enableCodiceAnalisiConsumi){

            HDT_WRP_ChildOrder wrpChildOrder = new HDT_WRP_ChildOrder();
            wrpChildOrder.orderType = 'analisiConsumi';
            wrpChildOrder.childOrder = new Order();
            //wrpChildOrder.childOrder.RecordTypeId = childOrderRecordTypeId;
            wrpChildOrder.childOrder.RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_VAS').getRecordTypeId();
            wrpChildOrder.childOrder.processType__c = 'VAS';
            wrpChildOrder.childOrder.IsMassive__c = true;
            wrpChildOrder.childOrder.Status = 'In Lavorazione';
            wrpChildOrder.childOrder.VasSubtype__c = 'Analisi Consumi';
            wrpChildOrder.childOrder.AccountId = nextDataObj.accountId;
            wrpChildOrder.childOrder.ServicePoint__c = nextDataObj.servPointId;
            wrpChildOrder.childOrder.BillingProfile__c = nextDataObj.billProfId;
            wrpChildOrder.orderItemList = new List<HDT_WRP_OrderItem>();

            HDT_WRP_OrderItem wrpOrderItem;
            // set wrapper for "Analisi consumi"
            wrpOrderItem = new HDT_WRP_OrderItem();
            wrpOrderItem.itemType = 'analisiConsumi';
            wrpOrderItem.product = new Product2();
            wrpOrderItem.product.Name = 'Analisi Consumi';
            wrpOrderItem.product.ProductCode = codiceAnalisiConsumi;
            wrpOrderItem.orderItem = new OrderItem();

            wrpChildOrder.orderItemList.add(wrpOrderItem);
            processObject.childOrderList.add(wrpChildOrder);
        }

        return processObject;

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

    private class HDT_WRP_ProcessObjects {
        private Opportunity opportunity;
        private Sale__c sale;
        private SaleServiceItem__c saleServiceItem;
        private Order parentOrder;
        private List<HDT_WRP_ChildOrder> childOrderList;
        private MassiveLoaderRequestItem__c requestItem;
        //private Id accountId;
        //private Id contactId;
        //private Id billProfId;
        //private Id servPointId;
        private HDT_UTL_ProcessSales.HDT_WRP_NextDataObj nextDataObj;

        private HDT_WRP_ProcessObjects(){
            opportunity = new Opportunity();
            sale = new Sale__c();
            saleServiceItem = new SaleServiceItem__c();
            parentOrder = new Order();
            childOrderList = new List<HDT_WRP_ChildOrder>();
        }

    }

    private class HDT_WRP_ChildOrder {
        private String orderType;
        private Order childOrder;
        private List<HDT_WRP_OrderItem> orderItemList;
    }

    private class HDT_WRP_OrderItem {
        private String itemType;
        private OrderItem orderItem;
        private Product2 product;
    }

}