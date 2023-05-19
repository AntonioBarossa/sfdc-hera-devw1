@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_UTL_ProcessOrderCreationForVas extends HDT_UTL_ProcessExecution {

    /*
    not used for wave 2
    
    private List<MassiveLoaderRequestItem__c> itemsToUpdate;
    private List<HDT_WRP_VasOrder.HDT_WRP_ProcessObjects> processObjList;
    private Id childOrderRecordTypeId;
    private Map<String, Product2> productMap;
    private Map<String, Order> orderMap;
    private Map<Id, Map<Id, PriceBookEntry>> pricebookEntryMatrix;
    private Map<String, Contract> contractToPbookIdMap = new Map<String, Contract>();
    private List<Id> productIdList = new List<Id>();
    private String salesForVasDataError = Label.CarMass_SalesForVasDataError;
    private String salesForVasContractError = Label.CarMass_SalesForVasContractError;
    private String salesForVasOrderError = Label.CarMass_SalesForVasOrderError;
    private String salesForVasOrderStructureError = Label.CarMass_SalesForVasOrderStructureError;
    private String salesForVasOrderItemStructureError = Label.CarMass_SalesForVasOrderItemStructureError;
    public HDT_WRP_VasOrder.HDT_WRP_ProcessObjects processObj;
    public List<String> tempSplitedFields;
    public List<MassiveLoaderRequestItem__c> allRequestItems;
    private Map<String, String> mapAllFields;
    private Map<String, MassiveFieldsObjectMap__c> sobjectMap;
    private Map<String, AccountContactRelation> accRelMap;
    private List<sObject> recordsToDelete = new List<sObject>();
    Id priceBookIdStandalone;

    public override void checks(){

        mapFieldsObject();

        Map<String, Id> failedMap = new Map<String, Id>();
        itemsToUpdate = new List<MassiveLoaderRequestItem__c>();
        productMap = new Map<String, Product2>();
        processObjList = new List<HDT_WRP_VasOrder.HDT_WRP_ProcessObjects>();
       
        for(MassiveLoaderRequestItem__c item : requestItemList){

            processObj = new HDT_WRP_VasOrder.HDT_WRP_ProcessObjects();
            processObj.mainRequestItemId = item.Id;
            
            processObj.allRequestItems = setItem(item);
            setOrderStructure();
            processObj = buildWrapperOrderStructure();

            System.debug('>>> @ ' + JSON.serialize(processObj));

            for(MassiveLoaderRequestItem__c errorItem : processObj.allRequestItems){
                System.debug('>>> ' + errorItem.Status__c + ' - ' + errorItem.StatusDescription__c);
                if(errorItem.Status__c.equalsIgnoreCase('Errore')){
                    itemsToUpdate.add(errorItem);
                }
            }

            if(!processObj.error){
                processObjList.add(processObj);
            }

        }

        getLimitDetails('EndConvertVasOrder');

    }

    public override void getRecords(){

        Set<String> orderNumberSet = new Set<String>();
        Set<String> contractSet = new Set<String>();
        List<String> offertaProductNameList = new List<String>();
        List<String> vasProductNameList = new List<String>();
        List<String> priceBookIdList = new List<String>();
        List<String> customerCodeList = new List<String>();
        accRelMap = new Map<String, AccountContactRelation>();
        orderMap = new Map<String, Order>();
        pricebookEntryMatrix = new Map<Id, Map<Id, PriceBookEntry>>();
        priceBookIdStandalone = [
            SELECT Id
            FROM Pricebook2
            WHERE Name = 'VAS Standalone'
            WITH SECURITY_ENFORCED
            LIMIT 1
        ].Id;

        priceBookIdList.add(priceBookIdStandalone);

        for(HDT_WRP_VasOrder.HDT_WRP_ProcessObjects processObject : processObjList){

            if(String.isNotEmpty(processObject.account.CustomerCode__c)){
                customerCodeList.add(processObject.account.CustomerCode__c);
            }

            if(String.isNotEmpty(processObject.orderNumber)){
                orderNumberSet.add(processObject.orderNumber);
            }

            if(String.isNotEmpty(processObject.contract.SAPContractCode__c)){
                contractSet.add(processObject.contract.SAPContractCode__c);
            }

            for(HDT_WRP_VasOrder.HDT_WRP_ChildOrder childOrder : processObject.childOrderList){
                for(HDT_WRP_VasOrder.HDT_WRP_OrderItem orderItem : childOrder.orderItemList){
                    switch on orderItem.itemType {
                        when 'vas' {
                            if(String.isNotEmpty(orderItem.product.Name)){
                                vasProductNameList.add(orderItem.product.Name);
                            }                            
                        }
                        when 'offerta' {
                            if(String.isNotEmpty(orderItem.product.Name)){
                                offertaProductNameList.add(orderItem.product.Name);
                            }                        
                        }
                    }

                }
            }


        }

        List<AccountContactRelation> acrList = [
            SELECT Id, Roles, ContactId, AccountId, Account.CustomerCode__c, Account.Name
            FROM AccountContactRelation
            WHERE Account.CustomerCode__c IN :customerCodeList
            AND Roles = 'Titolare'
            WITH SECURITY_ENFORCED
        ];
        if(acrList.size() > 0){
            for(AccountContactRelation acr : acrList){
                accRelMap.put(acr.Account.CustomerCode__c, acr);
            }
        }

        List<Product2> retrieveOffertList = [
            SELECT Id, Name, ProductCode, DescriptionSAP__c, Version__c
            FROM Product2
            WHERE Name IN :offertaProductNameList AND Name != null
            WITH SECURITY_ENFORCED
        ];

        if(retrieveOffertList.size() > 0){
            for(Product2 p : retrieveOffertList){
                productMap.put(offProductKey(p), p);
                productIdList.add(p.Id);
            }
        }

        List<Product2> retrieveVasList = [
            SELECT Id, Name, ProductCode, DescriptionSAP__c, Version__c
            FROM Product2
            WHERE Name IN :vasProductNameList AND Name != null
            WITH SECURITY_ENFORCED
        ];

        if(retrieveVasList.size() > 0){
            for(Product2 p : retrieveVasList){
                productMap.put(vasProductKey(p), p);
                productIdList.add(p.Id);
            }
        }

        System.debug('>>>  productMap ' + String.valueOf(productMap));
        
        List<Contract> contractList = [
            SELECT Id, SAPContractCode__c, SBQQ__AmendmentPricebookId__c, AccountId
            FROM Contract
            WHERE SAPContractCode__c IN :contractSet
            WITH SECURITY_ENFORCED
        ];
        
        if(contractList.size() > 0){
            for(Contract c : contractList){
                contractToPbookIdMap.put(c.SAPContractCode__c, c);
                priceBookIdList.add(c.SBQQ__AmendmentPricebookId__c);
            }
        }

        List<Order> orderList = [
            SELECT Id, PriceBook2Id, OrderNumber
            FROM Order
            WHERE OrderNumber IN :orderNumberSet
            AND PriceBook2Id != null
            WITH SECURITY_ENFORCED
        ];

        if(orderList.size() > 0){
            for(Order o : orderList){
                orderMap.put(o.OrderNumber, o);
                priceBookIdList.add(o.PriceBook2Id);
            }
        }

        System.debug('>>>  orderMap ' + String.valueOf(orderMap));

        List<PriceBookEntry> pbeForVasList = [
            SELECT Id, Pricebook2Id, Product2Id, UnitPrice
            FROM PricebookEntry
            WHERE Product2Id IN :productIdList
            AND Pricebook2Id IN :priceBookIdList
            WITH SECURITY_ENFORCED
        ];

        if(pbeForVasList.size() > 0){
            for(PriceBookEntry pbe : pbeForVasList){
                if(pricebookEntryMatrix.containsKey(pbe.Pricebook2Id)){
                    pricebookEntryMatrix.get(pbe.Pricebook2Id).put(pbe.Product2Id, pbe);
                } else {
                    pricebookEntryMatrix.put(pbe.Pricebook2Id, new Map<Id, PriceBookEntry>{pbe.Product2Id => pbe});
                }
            }
        }

        System.debug('>>>  pricebookEntryMatrix ' + String.valueOf(pricebookEntryMatrix));

    }

    public static String vasProductKey(Product2 p){
        //return p.Name + '-' + p.DescriptionSAP__c + '-' + p.Version__c;
        return p.Name + '-' + p.DescriptionSAP__c;
    }

    public static String offProductKey(Product2 p){
        return p.Name + '-' + p.ProductCode + '-' + p.Version__c;
    }

    public override void registryCreation(){

        List<Order> parentOrderToInsert = new List<Order>();
        List<Order> childOrderToInsert = new List<Order>();
        List<OrderItem> orderItemToInsert = new List<OrderItem>();
        List<OrderItem> orderItemToUpdate = new List<OrderItem>();
        List<Sale__c> saleToInsert = new List<Sale__c>();
        List<Opportunity> opportunityToinsert = new List<Opportunity>();
        Map<Id, Order> parentOrderMap;
        List<MassiveLoaderRequestItem__c> requestItemForUpsert = new List<MassiveLoaderRequestItem__c>();

        for(HDT_WRP_VasOrder.HDT_WRP_ProcessObjects processObject : processObjList){

            if(accRelMap.containsKey(processObject.account.CustomerCode__c)){
                processObject.sale = setSaleObject(processObject.sale, accRelMap.get(processObject.account.CustomerCode__c));
                requestItemForUpsert.add(processObject.allRequestItems[0]);
                saleToInsert.add(processObject.sale);
            } else {
                processObject = setErrorObj(processObject, 'Account non presente a sistema');
                continue;
            }

        }

        HDT_WRP_SaveResponse saveSaleResponse;
        saveSaleResponse = databaseUpsert(saleToInsert, requestItemForUpsert, 'Sale__c');
        requestItemForUpsert.clear();

        for(HDT_WRP_VasOrder.HDT_WRP_ProcessObjects processObject : processObjList){
        
            if(processObject.error){
                continue;
            }

            if(saveSaleResponse.errorItemMap.containsKey(processObject.allRequestItems[0].Id)){
                processObject = setErrorObj(processObject, saveSaleResponse.errorItemMap.get(processObject.allRequestItems[0].Id));
                continue;
            }

            processObject.parentOrder = setParentOrder(processObject.parentOrder, processObject.sale);
            processObject.opportunity = setOpportunityObj(processObject.opportunity, processObject.sale, accRelMap.get(processObject.account.CustomerCode__c).AccountId);
            opportunityToinsert.add(processObject.opportunity);
            requestItemForUpsert.add(processObject.allRequestItems[0]);
            parentOrderToInsert.add(processObject.parentOrder);
        }
        
        if(opportunityToinsert.size() > 0){
            HDT_UTL_DatabaseService.insertSObject(opportunityToinsert);
        }

        HDT_WRP_SaveResponse parentOrderResponse;
        parentOrderResponse = databaseUpsert(parentOrderToInsert, requestItemForUpsert, 'Order');
        requestItemForUpsert.clear();
        
        System.debug('>>> parent Order savedObject: ' + String.valueOf(parentOrderResponse.savedObject));
        System.debug('>>> parent Order itemIdToObjId: ' + String.valueOf(parentOrderResponse.itemIdToObjId));
        System.debug('>>> parent Order errorItemMap: ' + String.valueOf(parentOrderResponse.errorItemMap));

        if(parentOrderResponse.savedObject.size() > 0){
            List<Order> savedParentOrder = [
                SELECT Id, OrderNumber
                FROM Order
                WHERE Id IN :parentOrderResponse.itemIdToObjId.values()
                WITH SECURITY_ENFORCED
            ];
            parentOrderMap = new Map<Id, Order>(savedParentOrder);
        }

        Id priceBook2Id;
        Map<Id, PriceBookEntry> tempPbeMap;
        Id accountId;
        for(HDT_WRP_VasOrder.HDT_WRP_ProcessObjects processObject : processObjList){

            if(processObject.error){
                continue;
            }

            if(parentOrderResponse.errorItemMap.containsKey(processObject.allRequestItems[0].Id)){
                processObject = setErrorObj(processObject, parentOrderResponse.errorItemMap.get(processObject.allRequestItems[0].Id));
                continue;
            }

            switch on processObj.vasOrderType {
                when 'standalone' {
                    priceBook2Id = priceBookIdStandalone;
                }
                when 'singleOrder' {
                    if(contractToPbookIdMap.containsKey(processObject.contract.SAPContractCode__c)){
                        priceBook2Id = contractToPbookIdMap.get(processObject.contract.SAPContractCode__c).SBQQ__AmendmentPricebookId__c;
                        System.debug('>>> priceBook2Id ' + priceBook2Id);
                    } else {
                        processObject = setErrorObj(processObject, 'Contratto non presente a sistema');
                        continue;
                    }
                }
                when 'doubleOrder' {
                    if(orderMap.containsKey(processObject.orderNumber)){
                        priceBook2Id = orderMap.get(processObject.orderNumber).PriceBook2Id;
                        System.debug('>>> priceBook2Id ' + priceBook2Id);
                    } else {
                        processObject = setErrorObj(processObject, 'Ordine non presente a sistema');
                        continue;
                    }
                }
            }

            //if(orderMap.containsKey(processObject.orderNumber)){
            //    priceBook2Id = orderMap.get(processObject.orderNumber).PriceBook2Id;
            //    System.debug('>>> priceBook2Id ' + priceBook2Id);
            //} else {
            //    processObject = setErrorObj(processObject, 'Ordine non presente a sistema');
            //    continue;
            //}

            if(pricebookEntryMatrix.containsKey(priceBook2Id)){
                tempPbeMap = pricebookEntryMatrix.get(priceBook2Id);
                System.debug('>>> tempPbeMap ' + tempPbeMap);
            } else {
                processObject = setErrorObj(processObject, 'Errore nel listino prezzi');
                continue;
            }

            if(accRelMap.containsKey(processObject.account.CustomerCode__c)){
                accountId = accRelMap.get(processObject.account.CustomerCode__c).AccountId;
            } else {
                processObject = setErrorObj(processObject, 'Account non presente a sistema');
                continue;
            }

            for(HDT_WRP_VasOrder.HDT_WRP_ChildOrder wrpChildOrder : processObject.childOrderList){

                wrpChildOrder.childOrder.RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_VAS').getRecordTypeId();
                wrpChildOrder.childOrder.ParentOrder__c = processObject.parentOrder.Id;
                wrpChildOrder.childOrder.Pricebook2Id = priceBook2Id;
                wrpChildOrder.childOrder.AccountId = accountId;
                wrpChildOrder.childOrder.EffectiveDate = Date.today();
                wrpChildOrder.childOrder.Status = 'Draft';
                wrpChildOrder.childOrder.ProcessType__c = 'VAS';

                String productKey;
                PriceBookEntry tempPbe;
                for(HDT_WRP_VasOrder.HDT_WRP_OrderItem wrpOrderItem : wrpChildOrder.orderItemList){

                    System.debug('>>> itemType ' + wrpOrderItem.itemType);

                    switch on wrpOrderItem.itemType {
                        when 'vas' {
                            productKey = vasProductKey(wrpOrderItem.product);
                        }
                        when 'offerta' {
                            productKey = offProductKey(wrpOrderItem.product);
                        }
                    }

                    System.debug('>>> productKey ' + productKey);

                    if(productMap.containsKey(productKey)){
                        wrpOrderItem.orderItem.Product2Id = productMap.get(productKey).Id;
                        System.debug('>>> Product2Id ' + wrpOrderItem.orderItem.Product2Id);
                    } else {
                        processObject = setErrorObj(processObject, 'Prodotto non presente a sistema');
                        break;
                    }
                    
                    if(tempPbeMap.containsKey(wrpOrderItem.orderItem.Product2Id)){
                        tempPbe = tempPbeMap.get(wrpOrderItem.orderItem.Product2Id);
                        System.debug('>>> tempPbe ' + tempPbe);
                    } else {
                        processObject = setErrorObj(processObject, 'Prodotto non presente nel listino prezzi');
                        break;
                    }
                    
                    wrpOrderItem.orderItem.PriceBookEntryId = tempPbe.Id;
                    wrpOrderItem.orderItem.UnitPrice = tempPbe.UnitPrice;

                }

                if(processObject.error){
                    continue;
                }

                requestItemForUpsert.add(processObject.allRequestItems[0]);
                childOrderToInsert.add(wrpChildOrder.childOrder);
                productKey = '';
            }

        }

        HDT_WRP_SaveResponse childOrderResponse;
        childOrderResponse = databaseUpsert(childOrderToInsert, requestItemForUpsert, 'Order');
        requestItemForUpsert.clear();

        System.debug('>>> child Order savedObject: ' + String.valueOf(childOrderResponse.savedObject));
        System.debug('>>> child Order itemIdToObjId: ' + String.valueOf(childOrderResponse.itemIdToObjId));
        System.debug('>>> child Order errorItemMap: ' + String.valueOf(childOrderResponse.errorItemMap));

        for(HDT_WRP_VasOrder.HDT_WRP_ProcessObjects processObject : processObjList){

            if(processObject.error){
                continue;
            }

            if(childOrderResponse.errorItemMap.containsKey(processObject.allRequestItems[0].Id)){
                processObject = setErrorObj(processObject, childOrderResponse.errorItemMap.get(processObject.allRequestItems[0].Id));
                continue;
            }

            for(HDT_WRP_VasOrder.HDT_WRP_ChildOrder wrpChildOrder : processObject.childOrderList){
                for(HDT_WRP_VasOrder.HDT_WRP_OrderItem wrpOrderItem : wrpChildOrder.orderItemList){
                    wrpOrderItem.orderItem.OrderId = wrpChildOrder.childOrder.Id;
                    requestItemForUpsert.add(processObject.allRequestItems[0]);
                    orderItemToInsert.add(wrpOrderItem.orderItem);
                }

            }
        }

        HDT_WRP_SaveResponse orderItemResponse;
        orderItemResponse = databaseUpsert(orderItemToInsert, requestItemForUpsert, 'OrderItem');
        requestItemForUpsert.clear();

        System.debug('>>> OrderItem savedObject: ' + String.valueOf(orderItemResponse.savedObject));
        System.debug('>>> OrderItem itemIdToObjId: ' + String.valueOf(orderItemResponse.itemIdToObjId));
        System.debug('>>> OrderItem errorItemMap: ' + String.valueOf(orderItemResponse.errorItemMap));

        for(HDT_WRP_VasOrder.HDT_WRP_ProcessObjects processObject : processObjList){

            if(orderItemResponse.errorItemMap.containsKey(processObject.allRequestItems[0].Id)){
                processObject = setErrorObj(processObject, orderItemResponse.errorItemMap.get(processObject.allRequestItems[0].Id));
            }

            if(processObject.error){
                setRecordToDelete(processObject);
                processObject = setAllRequestForError(processObject);
            } else {

                if(parentOrderMap.containsKey(processObject.parentOrder.Id)){
                    //processObject.allRequestItems[0].Result__c = parentOrderMap.get(processObject.parentOrder.Id).OrderNumber;
                    String orderNumber = parentOrderMap.get(processObject.parentOrder.Id).OrderNumber;
                    for(MassiveLoaderRequestItem__c item : processObject.allRequestItems){
                        item.Result__c = orderNumber;
                        item.Status__c = 'Chiuso';
                    }
                }              

                for(HDT_WRP_VasOrder.HDT_WRP_ChildOrder wrpChildOrder : processObject.childOrderList){
                    wrpChildOrder.orderItemList[1].orderItem.SBQQ__RequiredBy__c = wrpChildOrder.orderItemList[0].orderItem.Id; // offerta
                    for(HDT_WRP_VasOrder.HDT_WRP_OrderItem wrpOrderItem : wrpChildOrder.orderItemList){
                        orderItemToUpdate.add(wrpOrderItem.orderItem);
                    }
                }
            }

            for(MassiveLoaderRequestItem__c item : processObject.allRequestItems){
                itemsToUpdate.add(item);
            }

            System.debug('>>> @ ' + JSON.serialize(processObj));

        }

        if(orderItemToUpdate.size() > 0){
            HDT_UTL_DatabaseService.updateSObject(orderItemToUpdate);
        }

        if(recordsToDelete.size() > 0){
            HDT_UTL_DatabaseService.deleteSObject(recordsToDelete);
        }

        getLimitDetails('EndCreation');

    }

    public static List<MassiveLoaderRequestItem__c> setItem(MassiveLoaderRequestItem__c containerItem){
        List<MassiveLoaderRequestItem__c> items = new List<MassiveLoaderRequestItem__c>();
        items.add(containerItem);

        if(containerItem.RelatedRequestItems__r.size() > 0){
            for(MassiveLoaderRequestItem__c innerItem : containerItem.RelatedRequestItems__r){
                items.add(innerItem);
            }
        }
        return items;
    }

    public void setOrderStructure(){
        Integer contrattoIndex = mapHeaderForWrapper.get('Contratto');
        Integer orderNumberIndex = mapHeaderForWrapper.get('Order');
        Integer standaloneIndex = mapHeaderForWrapper.get('Standalone');

        tempSplitedFields = new List<String>();
        tempSplitedFields = processObj.allRequestItems[0].Data__c.split(splitCharacter, -1);

        String contractCsvValue = tempSplitedFields[contrattoIndex];
        processObj.orderNumber = tempSplitedFields[orderNumberIndex];
        String standaloneCsvValue = tempSplitedFields[standaloneIndex];
        processObj.isStandalone = false;

        if(String.isNotEmpty(standaloneCsvValue) && standaloneCsvValue.equalsIgnoreCase('TRUE')){
            processObj.vasOrderType = 'standalone';
            processObj.isStandalone = true;
        } else if(String.isNotEmpty(contractCsvValue) && String.isEmpty(processObj.orderNumber)){
            processObj.vasOrderType = 'singleOrder';
            processObj.contract = new Contract();
            processObj.contract.SAPContractCode__c = contractCsvValue;
        } else if(String.isEmpty(contractCsvValue) && String.isNotEmpty(processObj.orderNumber)){
            processObj.vasOrderType = 'doubleOrder';
            processObj.contract = new Contract();
            processObj.contract.SAPContractCode__c = contractCsvValue;
        }
    }

    public HDT_WRP_VasOrder.HDT_WRP_ProcessObjects buildWrapperOrderStructure(){

        switch on processObj.vasOrderType {
            when 'standalone' {
                buildStandAlone();
            }
            when 'singleOrder' {
                buildSingleOrder();
            }
            when 'doubleOrder' {
                buildMultipleOrder();
            }
        }
        return processObj;

    }

    public HDT_WRP_VasOrder.HDT_WRP_ProcessObjects buildStandAlone(){

        HDT_WRP_VasOrder.HDT_WRP_ChildOrder wrpChildOrder = new HDT_WRP_VasOrder.HDT_WRP_ChildOrder();
        HDT_WRP_VasOrder.HDT_WRP_OrderItem wrpOff = new HDT_WRP_VasOrder.HDT_WRP_OrderItem('offerta');
        HDT_WRP_VasOrder.HDT_WRP_OrderItem wrpVas = new HDT_WRP_VasOrder.HDT_WRP_OrderItem('vas');

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
                //System.debug('>>> objField: ' + objField + ' - tempValue: ' + tempValue + ' - objectType: ' + sobjectMap.get(csvHeader).objectType__c);
                
                switch on sobjectMap.get(csvHeader).objectType__c {
                    when 'Sale__c' {
                        convertionError = mapTypeField(processObj.sale, mapAllFields, count, tempValue);
                    }
                    when 'Account' {
                        convertionError = mapTypeField(processObj.account, mapAllFields, count, tempValue);
                    }
                    when 'ParentOrder' {
                        convertionError = mapTypeField(processObj.parentOrder, mapAllFields, count, tempValue);
                    }
                    when 'Order' {
                        convertionError = mapTypeField(wrpChildOrder.childOrder, mapAllFields, count, tempValue);
                    }
                    when 'Contract' {
                        convertionError = mapTypeField(processObj.contract, mapAllFields, count, tempValue);
                    }
                    when 'vasProduct2' {
                        convertionError = mapTypeField(wrpVas.product, mapAllFields, count, tempValue);
                    }
                    when 'offProduct2' {
                        convertionError = mapTypeField(wrpOff.product, mapAllFields, count, tempValue);
                    }
                    when 'vasOrderItem' {
                        convertionError = mapTypeField(wrpVas.orderItem, mapAllFields, count, tempValue);
                    }
                    when 'offOrderItem' {
                        convertionError = mapTypeField(wrpOff.orderItem, mapAllFields, count, tempValue);
                    }
                }
                
            }

            if(String.isNotEmpty(convertionError)){
                // error happened -> exit
                System.debug(LoggingLevel.DEBUG, '>>> break for loop...' + csvHeader + ' - ' + tempValue);
                break;
            }

        }

        if(String.isNotEmpty(convertionError)){
            processObj.allRequestItems[0].Status__c = 'Errore';
            processObj.allRequestItems[0].StatusDescription__c = convertionError;
            processObj.error = true;
        } else {
            wrpChildOrder.orderItemList.add(wrpVas);
            wrpChildOrder.orderItemList.add(wrpOff);
            processObj.childOrderList.add(wrpChildOrder);
        }

        return processObj;

    }

    public HDT_WRP_VasOrder.HDT_WRP_ProcessObjects buildSingleOrder(){

        Set<Id> errorIds = new Set<Id>();

        HDT_WRP_VasOrder.HDT_WRP_ChildOrder wrpChildOrder = new HDT_WRP_VasOrder.HDT_WRP_ChildOrder();

        HDT_WRP_VasOrder.HDT_WRP_OrderItem wrpOff;
        HDT_WRP_VasOrder.HDT_WRP_OrderItem wrpVas;

        List<String> tempSplitedFields;
        String convertionError;
        for(Integer count=0; count < processObj.allRequestItems.size(); count++){

            tempSplitedFields = processObj.allRequestItems[count].Data__c.split(splitCharacter, -1);

            if(count == 0){
                wrpOff = new HDT_WRP_VasOrder.HDT_WRP_OrderItem('offerta');
                wrpOff.orderItem.Quantity = 1;
                wrpChildOrder.orderItemList.add(wrpOff);
            }

            wrpVas = new HDT_WRP_VasOrder.HDT_WRP_OrderItem('vas');

            wrpChildOrder.orderItemList.add(wrpVas);

            String csvHeader;
            String tempValue;
            String objField;

            for(Integer n=0; n < tempSplitedFields.size(); n++){
                tempValue = tempSplitedFields[n];
                csvHeader = mapHeaderByPosition.get(n);
                objField = mapAllFields.get(csvHeader);

                if(String.isBlank(objField) || String.isBlank(tempValue)){
                    continue;
                }

                if(sobjectMap.containsKey(csvHeader)){
                    //System.debug('>>> objField: ' + objField + ' - tempValue: ' + tempValue + ' - objectType: ' + sobjectMap.get(csvHeader).objectType__c);
                    
                    if(count == 0){
                        switch on sobjectMap.get(csvHeader).objectType__c {
                            when 'Sale__c' {
                                convertionError = mapTypeField(processObj.sale, mapAllFields, n, tempValue);
                            }
                            when 'Account' {
                                convertionError = mapTypeField(processObj.account, mapAllFields, n, tempValue);
                            }
                            when 'ParentOrder' {
                                convertionError = mapTypeField(processObj.parentOrder, mapAllFields, n, tempValue);
                            }
                            when 'Order' {
                                convertionError = mapTypeField(wrpChildOrder.childOrder, mapAllFields, n, tempValue);
                            }
                            when 'Contract' {
                                convertionError = mapTypeField(processObj.contract, mapAllFields, n, tempValue);
                            }
                            when 'vasProduct2' {
                                convertionError = mapTypeField(wrpVas.product, mapAllFields, n, tempValue);
                            }
                            when 'offProduct2' {
                                convertionError = mapTypeField(wrpOff.product, mapAllFields, n, tempValue);
                            }
                            when 'vasOrderItem' {
                                convertionError = mapTypeField(wrpVas.orderItem, mapAllFields, n, tempValue);
                            }
                            when 'offOrderItem' {
                                convertionError = mapTypeField(wrpOff.orderItem, mapAllFields, n, tempValue);
                            }
                        }
                    } else {
                        switch on sobjectMap.get(csvHeader).objectType__c {
                            when 'vasProduct2' {
                                convertionError = mapTypeField(wrpVas.product, mapAllFields, n, tempValue);
                            }
                            when 'vasOrderItem' {
                                convertionError = mapTypeField(wrpVas.orderItem, mapAllFields, n, tempValue);
                            }
                        }
                    }
                   
                }

                if(String.isNotEmpty(convertionError)){
                    // error happened -> exit
                    System.debug(LoggingLevel.DEBUG, '>>> break for loop...' + csvHeader + ' - ' + tempValue);
                    break;
                }

            }

            if(String.isNotEmpty(convertionError)){
                System.debug(LoggingLevel.DEBUG, '>>> error id ' + processObj.allRequestItems[count].Id + ' - ' + convertionError);
                processObj.allRequestItems[count].Status__c = 'Errore';
                processObj.allRequestItems[count].StatusDescription__c = convertionError.abbreviate(250);
                errorIds.add(processObj.allRequestItems[count].Id);
                break;
            }

        }

        for(MassiveLoaderRequestItem__c item : processObj.allRequestItems){

            System.debug(LoggingLevel.DEBUG, '>>> error ids ' + errorIds + ' - ' + item.Id);

            if(errorIds.size() > 0 && !errorIds.contains(item.Id)){
                item.Status__c = 'Errore';
                item.StatusDescription__c = 'Controllare tutte le righe csv';
            }
        }

        if(errorIds.size() > 0){
            processObj.error = true;
        }

        processObj.childOrderList.add(wrpChildOrder);

        return processObj;

    }

    public HDT_WRP_VasOrder.HDT_WRP_ProcessObjects buildMultipleOrder(){
        Set<Id> errorIds = new Set<Id>();

        HDT_WRP_VasOrder.HDT_WRP_ChildOrder wrpChildOrder;

        List<String> tempSplitedFields;
        String convertionError;
        for(Integer count=0; count < processObj.allRequestItems.size(); count++){

            tempSplitedFields = processObj.allRequestItems[count].Data__c.split(splitCharacter, -1);

            wrpChildOrder = new HDT_WRP_VasOrder.HDT_WRP_ChildOrder();
            HDT_WRP_VasOrder.HDT_WRP_OrderItem wrpOff = new HDT_WRP_VasOrder.HDT_WRP_OrderItem('offerta');
            wrpOff.orderItem.Quantity = 1;
            HDT_WRP_VasOrder.HDT_WRP_OrderItem wrpVas = new HDT_WRP_VasOrder.HDT_WRP_OrderItem('vas');
            wrpChildOrder.orderItemList.add(wrpOff);
            wrpChildOrder.orderItemList.add(wrpVas);

            String csvHeader;
            String tempValue;
            String objField;

            for(Integer n=0; n < tempSplitedFields.size(); n++){
                tempValue = tempSplitedFields[n];
                csvHeader = mapHeaderByPosition.get(n);
                objField = mapAllFields.get(csvHeader);

                if(String.isBlank(objField) || String.isBlank(tempValue)){
                    continue;
                }

                if(sobjectMap.containsKey(csvHeader)){
                    //System.debug('>>> objField: ' + objField + ' - tempValue: ' + tempValue + ' - objectType: ' + sobjectMap.get(csvHeader).objectType__c);

                    switch on sobjectMap.get(csvHeader).objectType__c {
                        when 'Sale__c' {
                            convertionError = mapTypeField(processObj.sale, mapAllFields, n, tempValue);
                        }
                        when 'Account' {
                            convertionError = mapTypeField(processObj.account, mapAllFields, n, tempValue);
                        }
                        when 'ParentOrder' {
                            convertionError = mapTypeField(processObj.parentOrder, mapAllFields, n, tempValue);
                        }
                        when 'Order' {
                            convertionError = mapTypeField(wrpChildOrder.childOrder, mapAllFields, n, tempValue);
                        }
                        when 'Contract' {
                            convertionError = mapTypeField(processObj.contract, mapAllFields, n, tempValue);
                        }
                        when 'vasProduct2' {
                            convertionError = mapTypeField(wrpVas.product, mapAllFields, n, tempValue);
                        }
                        when 'offProduct2' {
                            convertionError = mapTypeField(wrpOff.product, mapAllFields, n, tempValue);
                        }
                        when 'vasOrderItem' {
                            convertionError = mapTypeField(wrpVas.orderItem, mapAllFields, n, tempValue);
                        }
                        when 'offOrderItem' {
                            convertionError = mapTypeField(wrpOff.orderItem, mapAllFields, n, tempValue);
                        }
                    }
                   
                }

                if(String.isNotEmpty(convertionError)){
                    // error happened -> exit
                    System.debug(LoggingLevel.DEBUG, '>>> break for loop...' + csvHeader + ' - ' + tempValue);
                    break;
                }

            }

            if(String.isNotEmpty(convertionError)){
                System.debug(LoggingLevel.DEBUG, '>>> error id ' + processObj.allRequestItems[count].Id + ' - ' + convertionError);
                processObj.allRequestItems[count].Status__c = 'Errore';
                processObj.allRequestItems[count].StatusDescription__c = convertionError.abbreviate(250);
                errorIds.add(processObj.allRequestItems[count].Id);
                break;
            }

            processObj.childOrderList.add(wrpChildOrder);

        }

        for(MassiveLoaderRequestItem__c item : processObj.allRequestItems){

            System.debug(LoggingLevel.DEBUG, '>>> error ids ' + errorIds + ' - ' + item.Id);

            if(errorIds.size() > 0 && !errorIds.contains(item.Id)){
                item.Status__c = 'Errore';
                item.StatusDescription__c = 'Controllare tutte le righe csv';
            }
        }

        if(errorIds.size() > 0){
            processObj.error = true;
        }

        return processObj;

    }

    private void mapFieldsObject(){

        mapAllFields = new Map<String, String>();
        List<MassiveFieldsObjectMap__c> allFieldForThisProcess;

        sobjectMap = new Map<String, MassiveFieldsObjectMap__c>();
        allFieldForThisProcess = [
            SELECT labelField__c, nameField__c, objectType__c, processType__c
            FROM MassiveFieldsObjectMap__c 
            WHERE Name LIKE 'VAS_%'
            AND processType__c = 'VAS'
            WITH SECURITY_ENFORCED
        ];

        for(MassiveFieldsObjectMap__c temp : allFieldForThisProcess){
            if(temp.objectType__c != 'RowCsv'){
                mapAllFields.put(temp.labelField__c, temp.nameField__c);
                sobjectMap.put(temp.labelField__c, temp);
            }
        }

    }

    public override void finalUpdate(){
        System.debug(LoggingLevel.DEBUG, 'finalUpdate');
    
        if(itemsToUpdate.size() > 0){
            update itemsToUpdate;
        }
    }

    private Sale__c setSaleObject(Sale__c sale, AccountContactRelation acr){
        sale.Account__c = acr.AccountId;
        sale.SalesContact__c = acr.ContactId;
        sale.Name = 'Vendita ' + acr.Account.Name;
        sale.SalesContactRole__c = 'Titolare';
        sale.Status__c = 'Attiva';
        return sale;
    }

    private Opportunity setOpportunityObj(Opportunity opp, Sale__c sale, String accountId){
        opp.Sale__c = sale.Id;
        opp.AccountId = accountId;
        opp.Name = 'Opportunity ' + sale.Name;
        opp.StageName = 'Closed Won';
        opp.CloseDate = Date.today();
        return opp;
    }

    private Order setParentOrder(Order parentOrder, Sale__c sale){

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
        //parentOrder.ServicePoint__c = childOrder.ServicePoint__c;
        //parentOrder.SignatureMethod__c = childOrder.SignatureMethod__c;
        //parentOrder.DocSendingMethod__c = childOrder.DocSendingMethod__c;
        return parentOrder;

    }

    private HDT_WRP_VasOrder.HDT_WRP_ProcessObjects setErrorObj(HDT_WRP_VasOrder.HDT_WRP_ProcessObjects processObject, String errorMessage){
        processObject.error = true;
        processObject.allRequestItems[0].Status__c = 'Errore';
        processObject.allRequestItems[0].StatusDescription__c = errorMessage.abbreviate(250);
        return processObject;
    }

    private void setRecordToDelete(HDT_WRP_VasOrder.HDT_WRP_ProcessObjects processObject){
        recordsToDelete.add(processObject.parentOrder);
        recordsToDelete.add(processObject.sale);
        recordsToDelete.add(processObject.opportunity);
        for(HDT_WRP_VasOrder.HDT_WRP_ChildOrder wrpChildOrder : processObject.childOrderList){
            recordsToDelete.add(wrpChildOrder.childOrder);
        }
        System.debug('>>> recordsToDelete ' + String.valueOf(recordsToDelete));
    }

    private HDT_WRP_VasOrder.HDT_WRP_ProcessObjects setAllRequestForError(HDT_WRP_VasOrder.HDT_WRP_ProcessObjects processObject){
        for(MassiveLoaderRequestItem__c item : processObject.allRequestItems){
            if(!item.Status__c.equalsIgnoreCase('Errore')){
                item.Status__c = 'Errore';
                item.StatusDescription__c = 'Controllare tutte le righe csv';
            }
        }
        return processObject;
    }

    not used for wave 2
    */
}