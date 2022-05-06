@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_UTL_ProcessOrderCreationForVas extends HDT_UTL_ProcessExecution {

    private List<MassiveLoaderRequestItem__c> itemsToUpdate;
    private List<HDT_WRP_VasOrder.HDT_WRP_ProcessObjects> processObjList;
    private Map<Id, Account> accountMap;
    private Id childOrderRecordTypeId;
    private List<String> productNameList = new List<String>();
    private List<String> productDescrList = new List<String>();
    private Map<String, Product2> productMap;
    private Map<Id, Map<Id, PriceBookEntry>> pricebookEntryForVasMap;
    private List<String> contractSapCodeList = new List<String>();
    private Map<String, Contract> contractToPbookIdMap = new Map<String, Contract>();
    private Set<String> orderUniqueKeySet = new Set<String>();
    private List<Id> productIdList = new List<Id>();
    private String salesForVasDataError = Label.CarMass_SalesForVasDataError;
    private String salesForVasContractError = Label.CarMass_SalesForVasContractError;
    private String salesForVasOrderError = Label.CarMass_SalesForVasOrderError;
    private String salesForVasOrderStructureError = Label.CarMass_SalesForVasOrderStructureError;
    private String salesForVasOrderItemStructureError = Label.CarMass_SalesForVasOrderItemStructureError;
    public HDT_WRP_VasOrder.HDT_WRP_ProcessObjects processObj;
    public List<String> tempSplitedFields;
    public List<MassiveLoaderRequestItem__c> items;
    private Map<String, String> mapAllFields;
    private Map<String, MassiveFieldsObjectMap__c> sobjectMap;

    public override void checks(){

        mapFieldsObject();

        Map<String, Id> failedMap = new Map<String, Id>();
        itemsToUpdate = new List<MassiveLoaderRequestItem__c>();
        productMap = new Map<String, Product2>();

        //childOrderRecordTypeId = getOrderRecordTypeMap(processName);

        processObjList = new List<HDT_WRP_VasOrder.HDT_WRP_ProcessObjects>();
       
        for(MassiveLoaderRequestItem__c item : requestItemList){

            processObj = new HDT_WRP_VasOrder.HDT_WRP_ProcessObjects();
            
            items = setItem(item);
            setOrderStructure();
            processObj = buildWrapperOrderStructure();

            System.debug('>>> ' + JSON.serialize(processObj));

        }

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
        tempSplitedFields = items[0].Data__c.split(splitCharacter, -1);

        String contractCsvValue = tempSplitedFields[contrattoIndex];
        processObj.orderNumber = tempSplitedFields[orderNumberIndex];
        String standaloneCsvValue = tempSplitedFields[standaloneIndex];
        processObj.isStandalone = false;

        processObj.wrapperOrdeItemList = new List<HDT_WRP_VasOrder.HDT_WRP_OrderItem>();

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

        processObj.parentOrder = new Order();
        processObj.order = new Order();

        HDT_WRP_VasOrder.HDT_WRP_OrderItem wrpVas = new HDT_WRP_VasOrder.HDT_WRP_OrderItem();
        wrpVas.product = new Product2();
        wrpVas.orderItem = new OrderItem();

        HDT_WRP_VasOrder.HDT_WRP_OrderItem wrpOff = new HDT_WRP_VasOrder.HDT_WRP_OrderItem();
        wrpOff.product = new Product2();
        wrpOff.orderItem = new OrderItem();

        String csvHeader;
        String convertionError;
        String tempValue;
        String objField;
        System.debug('>>> tempSplitedFields ' + String.valueOf(tempSplitedFields));
        System.debug('>>> mapHeaderByPosition ' + String.valueOf(mapHeaderByPosition));
        System.debug('>>> mapAllFields ' + String.valueOf(mapAllFields));

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
                    when 'ParentOrder' {
                        convertionError = mapTypeField(processObj.parentOrder, mapAllFields, count, tempValue);
                    }
                    when 'Order' {
                        convertionError = mapTypeField(processObj.order, mapAllFields, count, tempValue);
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
            processObj.requestItem.Status__c = 'Errore';
            processObj.requestItem.StatusDescription__c = convertionError;
        } else {
            processObj.wrapperOrdeItemList.add(wrpVas);
            processObj.wrapperOrdeItemList.add(wrpOff);
        }

        return processObj;

    }

    public HDT_WRP_VasOrder.HDT_WRP_ProcessObjects buildSingleOrder(){

        processObj.parentOrder = new Order();

        processObj.order = new Order();

        HDT_WRP_VasOrder.HDT_WRP_OrderItem offerta = new HDT_WRP_VasOrder.HDT_WRP_OrderItem();
        offerta.product = new Product2();
        offerta.orderItem = new OrderItem();
        offerta.orderItem.Quantity = 1;
        processObj.wrapperOrdeItemList.add(offerta);

        HDT_WRP_VasOrder.HDT_WRP_OrderItem vas = new HDT_WRP_VasOrder.HDT_WRP_OrderItem();
        vas.product = new Product2();
        vas.orderItem = new OrderItem();
        processObj.wrapperOrdeItemList.add(vas);

        return processObj;

    }

    public HDT_WRP_VasOrder.HDT_WRP_ProcessObjects buildMultipleOrder(){

        processObj.parentOrder = new Order();

        processObj.order = new Order();

        HDT_WRP_VasOrder.HDT_WRP_OrderItem offerta = new HDT_WRP_VasOrder.HDT_WRP_OrderItem();
        offerta.product = new Product2();
        offerta.orderItem = new OrderItem();
        offerta.orderItem.Quantity = 1;
        processObj.wrapperOrdeItemList.add(offerta);

        HDT_WRP_VasOrder.HDT_WRP_OrderItem vas = new HDT_WRP_VasOrder.HDT_WRP_OrderItem();
        vas.product = new Product2();
        vas.orderItem = new OrderItem();
        processObj.wrapperOrdeItemList.add(vas);


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

    /*public override void getRecords(){
        
        List<String> versionList = new List<String>();
        List<Product2> productRetrievedFromDb = new List<Product2>();
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
        
        for(Contract c : contractList){
            contractToPbookIdMap.put(c.SAPContractCode__c, c);
        }
        
    }

    public override void registryCreation(){

        List<String> priceBookIdList = new List<String>();
        List<sObject> recordToDelete = new List<sObject>();
        List<Order> parentOrderToInsert = new List<Order>();
        List<Order> childOrderToInsert = new List<Order>();
        List<OrderItem> orderItemToInsert = new List<OrderItem>();
        List<Sale__c> saleToInsert = new List<Sale__c>();
        List<MassiveLoaderRequestItem__c> requestItemForUpsert = new List<MassiveLoaderRequestItem__c>();

        for(HDT_WRP_Order wrpOrder : wrapperOrderList){
            if(contractToPbookIdMap.containsKey(wrpOrder.contract.SAPContractCode__c)){
                wrpOrder.Order.PriceBook2Id = contractToPbookIdMap.get(wrpOrder.contract.SAPContractCode__c).SBQQ__AmendmentPricebookId__c;
                wrpOrder.order.AccountId = contractToPbookIdMap.get(wrpOrder.contract.SAPContractCode__c).AccountId;
                wrpOrder.Order.EffectiveDate = Date.today();
                wrpOrder.Order.Status = 'Draft';
                childOrderToInsert.add(wrpOrder.Order);
                requestItemForUpsert.add(wrpOrder.requestItem);
            } else {
                wrpOrder.requestItem.Status__c = 'Errore';
                wrpOrder.requestItem.StatusDescription__c = salesForVasContractError;
                continue;
            }
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
        }

        List<Order> orderList = new List<Order>();
        Map<String, Order> uniqueKeyToOrder = new Map<String, Order>();
        orderList = [
            SELECT Id, GlobalMigrationKey__c, PriceBook2Id
            FROM Order
            WHERE GlobalMigrationKey__c IN :orderUniqueKeySet
        ];

        for(Order o : orderList){
            uniqueKeyToOrder.put(o.GlobalMigrationKey__c, o);
            priceBookIdList.add(o.PriceBook2Id);
            if(!pricebookEntryForVasMap.containsKey(o.PriceBook2Id)){
                pricebookEntryForVasMap.put(o.PriceBook2Id, new Map<Id, PriceBookEntry>());
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


        String prodKey;
        String pricebookId = '';
        for(HDT_WRP_OrderItem wrpOrderItem : wrapperOrderItemList){

            if(uniqueKeyToOrder.containsKey(wrpOrderItem.orderUniqueKey)){
                wrpOrderItem.orderItem.OrderId = uniqueKeyToOrder.get(wrpOrderItem.orderUniqueKey).Id;
                pricebookId = uniqueKeyToOrder.get(wrpOrderItem.orderUniqueKey).PriceBook2Id;
            } else {
                wrpOrderItem.requestItem.Status__c = 'Errore';
                wrpOrderItem.requestItem.StatusDescription__c = salesForVasOrderError;
                continue;
            }

            System.debug('>>> pricebookId ' + pricebookId);

            prodKey = wrpOrderItem.product.Name + '-' + wrpOrderItem.product.DescriptionSAP__c + '-' + wrpOrderItem.product.Version__c;
            System.debug('>>> prodKey ' + prodKey);
            System.debug('>>> productMap ' + productMap);

            if(productMap.containsKey(prodKey)){
                wrpOrderItem.orderItem.Product2Id = productMap.get(prodKey).Id;

                System.debug('>>> priceBook2Id ' + priceBookId);

                if(pricebookEntryForVasMap.containsKey(pricebookId)){
                    Map<Id, PriceBookEntry> tempMap = pricebookEntryForVasMap.get(pricebookId);
                    wrpOrderItem.orderItem.PricebookEntryId = tempMap.get(wrpOrderItem.orderItem.Product2Id).Id;
                    wrpOrderItem.orderItem.UnitPrice = tempMap.get(wrpOrderItem.orderItem.Product2Id).UnitPrice;
                }

            }

            requestItemForUpsert.add(wrpOrderItem.requestItem);
            orderItemToInsert.add(wrpOrderItem.orderItem);

        }

        System.debug(JSON.serializePretty(wrapperOrderList));
        System.debug(JSON.serializePretty(wrapperOrderItemList));

        HDT_WRP_SaveResponse saveOrderItemResponse;
        saveOrderItemResponse = databaseUpsert(orderItemToInsert, requestItemForUpsert, 'OrderItem');
        requestItemForUpsert.clear();

        Set<String> uniqueKeyErrorList = new Set<String>();
        for(HDT_WRP_OrderItem wrpOrderItem : wrapperOrderItemList){

            if(!uniqueKeyToOrder.containsKey(wrpOrderItem.orderUniqueKey)){
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

            if(!uniqueKeyToOrder.containsKey(wrpOrderItem.orderUniqueKey)){
                continue;
            }

            if(uniqueKeyErrorList.contains(wrpOrderItem.orderUniqueKey) && wrpOrderItem.requestItem.Status__c != 'Errore'){
                wrpOrderItem.requestItem.Status__c = 'Errore';
                wrpOrderItem.requestItem.StatusDescription__c = salesForVasOrderStructureError;
            }

        }

        for(HDT_WRP_Order wrpOrder : wrapperOrderList){

            if(!uniqueKeyToOrder.containsKey(wrpOrder.orderUniqueKey)){
                continue;
            }

            if(uniqueKeyErrorList.contains(wrpOrder.orderUniqueKey)){
                wrpOrder.requestItem.Status__c = 'Errore';
                wrpOrder.requestItem.StatusDescription__c = salesForVasOrderItemStructureError;
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

    }*/



    /*private Sale__c setSaleObject(Sale__c sale, Id accountId, Id contactId){
        sale.Account__c = accountId;
        sale.SalesContact__c = contactId;
        sale.Name = 'Vendita ' + accountMap.get(accountId).Name;
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
        return Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_VAS').getRecordTypeId();
    }*/

}