@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_UTL_ProcessOrderCreation extends HDT_UTL_ProcessExecution{

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
    private Map<Id, Contract> contractMap;
    private Id childOrderRecordTypeId;
    private OrderItem fakeOrderItem;
    private Map<String, String> companyCodeMap;
    private Map<String, String> processMatrixMap;
    private Map<Id, List<SBQQ__ProductOption__c>> otherRequiredOption;
    private List<sObject> sObjectToDelete = new List<sObject>();
    private List<HDT_ExciseTranscode__mdt> exciseList;
    private Map<String,Double> exciseMap = new Map<String,Double>();
    private List<HDT_RegionalAdditional__mdt> regionalAddList;
    private List<RateCategory__c> rateCategoryList;
    private HDT_UTL_CarMassPredefaultValues orderPreDefault;
    private HDT_UTL_ProcessDiscountAndBonus processDiscountBonus;
    private Set<String> activationItemTypes;

    public override void checks(){

        mapFieldsObject();

        if(isDiscountAndBonusProcess){
            processDiscountBonus = new HDT_UTL_ProcessDiscountAndBonus(mapHeaderForWrapper);
        }

        itemsToUpdate = new List<MassiveLoaderRequestItem__c>();
        commOfferForRetrieve = new List<Product2>();
        additionalProduct2 = new List<Product2>();
        accountIdToRetrieve = new List<Id>();
        billProfToRetrieve = new List<Id>();
        servPointToRetrieve = new List<Id>();
        exciseMap = new Map<String,Double>();
        regionalAddList = new List<HDT_RegionalAdditional__mdt>();
        contractMap = new Map<Id, Contract>();

        childOrderRecordTypeId = getOrderRecordTypeMap(processName);

        HDT_WRP_ProcessObjects processObj;
        processObjList = new List<HDT_WRP_ProcessObjects>();
        List<String> tempSplitedFields;

        fakeOrderItem = new OrderItem();
        // STEP 1: convert from csv the objects: 
        //      - Sale__c
        //      - Child Order
        //      - Parent Order
        //      - Order Item

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

            //System.debug('>>> ' + JSON.serializePretty(processObj));

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
                processObj.requestItem.StatusDescription__c = convertionError.abbreviate(250);
                itemsToUpdate.add(processObj.requestItem);
                continue;
            }

            processObjList.add(processObj);

        }
        //getLimitDetails('convertionEnd');

    }

    public override void getRecords(){

        List<String> productCodeList = new List<String>();
        List<String> versionList = new List<String>();
        List<Product2> productRetrievedFromDb = new List<Product2>();
        List<Id> productIdList = new List<Id>();
        List<PriceBookEntry> pbeList = new List<PriceBookEntry>();
        List<SBQQ__ProductOption__c> productOptionList = new List<SBQQ__ProductOption__c>();
        List<ProcessMatrix__c> processMatrixList;
        List<Id> optnionalSkuIdList;
        Set<String> defaultProdOption;

        commOfferMap = new Map<String, Product2>();
        additionalOrderItemMap = new Map<String, Map<String, SBQQ__ProductOption__c>>();
        pricebookEntryForOptionalMap = new Map<Id, Map<Id, PriceBookEntry>>();
        processMatrixMap = new Map<String, String>();
        processMatrixList = new List<ProcessMatrix__c>();
        otherRequiredOption = new Map<Id, List<SBQQ__ProductOption__c>>();
        defaultProdOption = new Set<String>();
        optnionalSkuIdList = new List<Id>();

        rateCategoryList = HDT_QR_RateCategory.getAllRecords();

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
            SELECT Id, ProductCode, Version__c,Name
            FROM Product2
            WHERE ProductCode IN :productCodeList AND ProductCode != null
            //AND Version__c IN :versionList AND Version__c != null
            //AND (Version__c IN :versionList OR Version__c = null)
            AND Family = 'Offerta commerciale'
            WITH SECURITY_ENFORCED
        ];

        for(Product2 p : productRetrievedFromDb){
            productIdList.add(p.Id);
            commOfferMap.put(buildProductKey(p), p);
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
            SELECT SBQQ__ConfiguredSKU__c, SBQQ__OptionalSKU__c, SBQQ__OptionalSKU__r.ProductCode, SBQQ__OptionalSKU__r.Name, SBQQ__Required__c,
                   SBQQ__OptionalSKU__r.DurationDay__c, SBQQ__OptionalSKU__r.DurationDayGas__c, SBQQ__OptionalSKU__r.DelayDay__c, SBQQ__OptionalSKU__r.DelayDayGas__c,
                   SBQQ__OptionalSKU__r.Percentage__c, SBQQ__OptionalSKU__r.Price__c,SBQQ__OptionalSKU__r.PriceGas__c
            FROM SBQQ__ProductOption__c
            WHERE SBQQ__ConfiguredSKU__c IN :productIdList
            WITH SECURITY_ENFORCED
        ];
        
        defaultProdOption.add('Analisi Consumi');
        defaultProdOption.add('PDR');
        defaultProdOption.add('POD');

        for(SBQQ__ProductOption__c prodOpt : productOptionList){
            if(additionalOrderItemMap.containsKey(prodOpt.SBQQ__ConfiguredSKU__c)){
                Map<String, SBQQ__ProductOption__c> tempMap = additionalOrderItemMap.get(prodOpt.SBQQ__ConfiguredSKU__c);
                tempMap.put(prodOpt.SBQQ__OptionalSKU__r.ProductCode, prodOpt);
                additionalOrderItemMap.put(prodOpt.SBQQ__ConfiguredSKU__c, tempMap);
                optnionalSkuIdList.add(prodOpt.SBQQ__OptionalSKU__c);
            }

            if(!defaultProdOption.contains(prodOpt.SBQQ__OptionalSKU__r.Name) && prodOpt.SBQQ__Required__c == true){
                if(otherRequiredOption.containsKey(prodOpt.SBQQ__ConfiguredSKU__c)){
                    otherRequiredOption.get(prodOpt.SBQQ__ConfiguredSKU__c).add(prodOpt);
                } else {
                    otherRequiredOption.put(prodOpt.SBQQ__ConfiguredSKU__c, new List<SBQQ__ProductOption__c>{prodOpt});
                }
            }

        }
        
        System.debug('>>> otherRequiredOption ' + otherRequiredOption);

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
        List<Contract> contractList = HDT_UTL_MassiveOrderFieldsAlignment.getContractByServicePointIds(servPointToRetrieve);

        accountMap = new Map<Id, Account>(accList);
        billingProfileMap = new Map<Id, BillingProfile__c>(billProfList);
        servicePointMap = new Map<Id, ServicePoint__c>(servPointList);
        for(Contract singleContract : contractList){
            contractMap.put(singleContract.ServicePoint__c, singleContract);
        }
        exciseList = [
            SELECT Id, Active__c, ExciseString__c, Excise__c
            FROM HDT_ExciseTranscode__mdt
            WHERE Active__c = true
        ];

        for(HDT_ExciseTranscode__mdt singleExcise : exciseList){
            exciseMap.put(singleExcise.ExciseString__c, singleExcise.Excise__c);
        }
        
        regionalAddList = [
            SELECT Id, Label, AdditionalValue__c, City__c, Region__c, Tax__c
            FROM HDT_RegionalAdditional__mdt
        ];
        
        if(isDiscountAndBonusProcess){
            processDiscountBonus.getDataForDiscountAndBonus();
        }

    }

    public override void registryCreation(){

        List<Order> parentOrderToInsert = new List<Order>();
        List<Order> childOrderToInsert = new List<Order>();
        List<OrderItem> orderItemToInsert = new List<OrderItem>();
        List<Sale__c> saleToInsert = new List<Sale__c>();
        List<MassiveLoaderRequestItem__c> requestItemForUpsert = new List<MassiveLoaderRequestItem__c>();
        orderPreDefault = new HDT_UTL_CarMassPredefaultValues();
        activationItemTypes = new Set<String>{'POD', 'PDR', 'promo', 'bonus'};

        Id commOffId;
        Id priceBookId;
        String errorFieldCheck;
        // STEP 2: check Sale__c required fields and save
        for(HDT_WRP_ProcessObjects processObj : processObjList){

            if(processObj.requestItem.Status__c == 'Errore'){
                continue;
            }

            if(isDiscountAndBonusProcess){
                processObj = processDiscountBonus.checkDiscountAndBonus(processObj);
            }

            if(processObj.requestItem.Status__c == 'Errore'){
                continue;
            }

            processObj.sale = setSaleObject(processObj.sale, processObj.nextDataObj.accountId, processObj.nextDataObj.contactId);

            errorFieldCheck = checkRequiredSalesField(processObj.sale);
            if(String.isNotEmpty(errorFieldCheck)){
                processObj.requestItem.Status__c = 'Errore';
                processObj.requestItem.StatusDescription__c = errorFieldCheck.abbreviate(250);
                continue;
            }

            requestItemForUpsert.add(processObj.requestItem);
            saleToInsert.add(processObj.sale);
        }

        HDT_WRP_SaveResponse saveSaleResponse;
        saveSaleResponse = databaseUpsert(saleToInsert, requestItemForUpsert, 'Sale__c');

        requestItemForUpsert.clear();

        // STEP 3: set new opportunity
        for(HDT_WRP_ProcessObjects processObj : processObjList){

            if(processObj.requestItem.Status__c == 'Errore'){
                continue;
            }

            if(saveSaleResponse.errorItemMap.containsKey(processObj.requestItem.Id)){
                //system.debug(LoggingLevel.DEBUG, '>>> requestItem.Status__c after save');
                processObj.requestItem.Status__c = 'Errore';
                processObj.requestItem.StatusDescription__c = (saveSaleResponse.errorItemMap.get(processObj.requestItem.Id)).abbreviate(250);
                continue;
            }

            processObj.opportunity = setOpportunityObj(processObj.opportunity, processObj.sale, processObj.nextDataObj.accountId);
            requestItemForUpsert.add(processObj.requestItem);
            opportunityToinsert.add(processObj.opportunity);
        }

        HDT_WRP_SaveResponse saveOpportunityResponse;
        saveOpportunityResponse = databaseUpsert(opportunityToinsert, requestItemForUpsert, 'Opportunity');

        requestItemForUpsert.clear();

        //STEP 4: create Order and SaleServiceItem__c

        for(HDT_WRP_ProcessObjects processObj : processObjList){

            if(processObj.requestItem.Status__c == 'Errore'){
                continue;
            }

            if(saveOpportunityResponse.errorItemMap.containsKey(processObj.requestItem.Id)){
                //system.debug(LoggingLevel.DEBUG, '>>> requestItem.Status__c after save');
                processObj.requestItem.Status__c = 'Errore';
                processObj.requestItem.StatusDescription__c = (saveOpportunityResponse.errorItemMap.get(processObj.requestItem.Id)).abbreviate(250);
                continue;
            }

            String errorForChildOrder = '';
            for(HDT_WRP_ChildOrder childOrder : processObj.childOrderList){

                if(childOrder.orderType.equalsIgnoreCase('Attivazione')){
                    //system.debug(LoggingLevel.DEBUG, '>>> activation');
                    for(HDT_WRP_OrderItem wrpOrderItem : childOrder.orderItemList){

                        //wrpOrderItem.OrderItem = fakeOrderItem;

                        if(wrpOrderItem.itemType.equalsIgnoreCase('offertaComm')){
                            String productKey = buildProductKey(wrpOrderItem.product);
                            
                            if(!commOfferMap.containsKey(productKey)){
                                errorForChildOrder = 'L\'offerta commerciale non è inserita nel catalogo';
                                break;
                            }

                            wrpOrderItem.product = commOfferMap.get(productKey);
                            commOffId = wrpOrderItem.product.Id;

                            if(!priceBookEntryMap.containsKey(commOffId)){
                                errorForChildOrder = 'L\'offerta commerciale non è inserita nel listino prezzi';
                                break;
                            }                      
                            
                            wrpOrderItem.orderItem.PriceBookEntryId = priceBookEntryMap.get(commOffId).Id;
                            wrpOrderItem.orderItem.UnitPrice = priceBookEntryMap.get(commOffId).UnitPrice;
                            wrpOrderItem.orderItem.Quantity = 1;
                            wrpOrderItem.orderItem.Product2Id = commOffId;
                            priceBookId = priceBookEntryMap.get(commOffId).Pricebook2Id;
                            childOrder.childOrder.CommercialProductLink__c = commOffId;
                            childOrder.childOrder.CommercialProductCode__c = wrpOrderItem.product.ProductCode;
                            childOrder.childOrder.CommercialProductVersion__c = wrpOrderItem.product.Version__c;
                            childOrder.childOrder.CommercialProduct__c  =  wrpOrderItem.product.Name;
                            
                        }

                    }

                } 

                if(String.isNotEmpty(errorForChildOrder)){
                    break;
                }

            }

            if(String.isNotEmpty(errorForChildOrder)){
                processObj.requestItem.Status__c = 'Errore';
                processObj.requestItem.StatusDescription__c = errorForChildOrder;
                continue;
            }

            // STEP 5: create product option
            String productOptionError = '';
            for(HDT_WRP_ChildOrder wrpChildOrder : processObj.childOrderList){

                if(!pricebookEntryForOptionalMap.containsKey(priceBookId)){
                    break;
                }

                if(!additionalOrderItemMap.containsKey(commOffId)){
                    productOptionError = 'Errore nell\'aggiunta del prodotto opzione';
                    break;
                }

                Map<Id, PriceBookEntry> pbeOptionalMap = pricebookEntryForOptionalMap.get(priceBookId);

                if(wrpChildOrder.orderType.equalsIgnoreCase('Attivazione')){
                    //system.debug(LoggingLevel.DEBUG, '>>> activation');

                    wrpChildOrder.childOrder.Pricebook2Id = priceBookId;
                    wrpChildOrder.childOrder.EffectiveDate = Date.today();
                    wrpChildOrder.childOrder.Status = 'Draft';
                    wrpChildOrder.childOrder.WizardCompletedDate__c = Date.today();

                    for(HDT_WRP_OrderItem wrpOrderItem : wrpChildOrder.orderItemList){

                        if(processName.equalsIgnoreCase('VolturaNoEnergy')){
                            break;
                        }

                        // check for itemType -> {'POD', 'PDR', 'promo', 'bonus'}
                        if(activationItemTypes.contains(wrpOrderItem.itemType)){

                            Map<String, SBQQ__ProductOption__c> tempMap = additionalOrderItemMap.get(commOffId);

                            if(!tempMap.containsKey(wrpOrderItem.product.ProductCode)){
                                productOptionError = 'Errore nell\'aggiunta del prodotto opzione';
                                break;
                            }
                            
                            SBQQ__ProductOption__c prodOption = tempMap.get(wrpOrderItem.product.ProductCode);
                            Id optionalSku = tempMap.get(wrpOrderItem.product.ProductCode).SBQQ__OptionalSKU__c;

                            if(!pbeOptionalMap.containsKey(optionalSku)){
                                productOptionError = 'Errore nell\'aggiunta del prodotto opzione';
                                break;
                            }

                            wrpOrderItem.product.Id = optionalSku;
                            wrpOrderItem.orderItem.Product2Id = wrpOrderItem.product.Id;
                            wrpOrderItem.orderItem.PriceBookEntryId = pbeOptionalMap.get(wrpOrderItem.product.Id).Id;
                            wrpOrderItem.orderItem.UnitPrice = pbeOptionalMap.get(wrpOrderItem.product.Id).UnitPrice;
                            wrpOrderItem.orderItem.Quantity = 1;

                            if(wrpOrderItem.itemType.equalsIgnoreCase('bonus')){
                                wrpOrderItem.orderItem.DurationDay__c = prodOption.SBQQ__OptionalSKU__r.DurationDay__c;
                                wrpOrderItem.orderItem.DurationDayGas__c = prodOption.SBQQ__OptionalSKU__r.DurationDayGas__c;
                                wrpOrderItem.orderItem.DelayDay__c = prodOption.SBQQ__OptionalSKU__r.DelayDay__c;
                                wrpOrderItem.orderItem.DelayDayGas__c = prodOption.SBQQ__OptionalSKU__r.DelayDayGas__c;
                                wrpOrderItem.orderItem.Percentage__c = prodOption.SBQQ__OptionalSKU__r.Percentage__c;
                                wrpOrderItem.orderItem.Price__c = prodOption.SBQQ__OptionalSKU__r.Price__c;
                                wrpOrderItem.orderItem.PriceGas__c = prodOption.SBQQ__OptionalSKU__r.PriceGas__c;
                            }
                            //system.debug(LoggingLevel.DEBUG, '>>> pbeId pod-pdr ' + wrpOrderItem.orderItem.PriceBookEntryId);

                        }

                    }

                    if(String.isNotEmpty(productOptionError)){
                        break;
                    }

                    HDT_WRP_OrderItem requiredItem;
                    System.debug('>>> required for ' + commOffId);

                    if(otherRequiredOption.containsKey(commOffId)){
                        for(SBQQ__ProductOption__c requiredOption : otherRequiredOption.get(commOffId)){
                            requiredItem = setRequiredItem(requiredOption, commOffId, priceBookId);

                            if(requiredItem == null){
                                productOptionError = 'Errore nel listino prezzi prodotti opzione obbligatori';
                                break;
                            }

                            wrpChildOrder.orderItemList.add(requiredItem);
                        }
                    }

                    if(String.isNotEmpty(productOptionError)){
                        break;
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

                                if(!pbeOptionalMap.containsKey(tempProdOpt.SBQQ__OptionalSKU__c)){
                                    productOptionError = 'Errore nell\'aggiunta Analisi consumi';
                                    break;
                                }

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

            if(String.isNotEmpty(productOptionError)){
                processObj.requestItem.Status__c = 'Errore';
                processObj.requestItem.StatusDescription__c = productOptionError;
                continue;
            }

            processObj = setSaleServiceItem(processObj);
            saleServiceToInsert.add(processObj.saleServiceItem);
            ////system.debug(LoggingLevel.DEBUG, JSON.serializePretty(processObj));
        }

        if(parentOrderToInsert.size()>0){
            HDT_UTL_DatabaseService.insertSObject(parentOrderToInsert);
        }
        
        if(saleServiceToInsert.size()>0){
            HDT_UTL_DatabaseService.insertSObject(saleServiceToInsert);
        }

        String commodity = '';
        //STEP 6: Order Fields Alignment
        for(HDT_WRP_ProcessObjects processObj : processObjList){

            if(processObj.requestItem.Status__c == 'Errore'){
                continue;
            }

            for(HDT_WRP_ChildOrder wrpChildOrder : processObj.childOrderList){

                wrpChildOrder.childOrder.ParentOrder__c = processObj.parentOrder.Id;
                wrpChildOrder.childOrder.Contact__c = processObj.nextDataObj.contactId;
                wrpChildOrder.childOrder.SalesContact__c = processObj.nextDataObj.contactId;
                wrpChildOrder.childOrder.Sale__c = processObj.sale.Id;
                wrpChildOrder.childOrder = HDT_UTL_MassiveOrderFieldsAlignment.alignAccountFields(wrpChildOrder.childOrder, accountMap.get(processObj.nextDataObj.accountId));
                wrpChildOrder.childOrder = HDT_UTL_MassiveOrderFieldsAlignment.alignSaleFields(wrpChildOrder.childOrder, processObj.sale);
                wrpChildOrder.childOrder = HDT_UTL_MassiveOrderFieldsAlignment.alignBillingProfileFields(wrpChildOrder.childOrder, billingProfileMap.get(processObj.nextDataObj.billProfId));
                wrpChildOrder.childOrder = HDT_UTL_MassiveOrderFieldsAlignment.alignServicePointFields(wrpChildOrder.childOrder, servicePointMap.get(processObj.nextDataObj.servPointId));
                
                if(contractMap.get(processObj.nextDataObj.servPointId) != null){
                    wrpChildOrder.childOrder = HDT_UTL_MassiveOrderFieldsAlignment.alignContractFields(wrpChildOrder.childOrder, contractMap.get(processObj.nextDataObj.servPointId));
                }

                commodity = servicePointMap.get(processObj.nextDataObj.servPointId).CommoditySector__c;
                setSalesCompanyAndCode(wrpChildOrder.childOrder, commodity);
                //handleCustomFieldLogic(wrpChildOrder.childOrder, commodity); 

                if(wrpChildOrder.childOrder.VasSubtype__c != null && wrpChildOrder.childOrder.VasSubtype__c == 'Analisi Consumi'){
                    //no rate
                }else{
                    calculateRateCategory(wrpChildOrder.childOrder);
                }

                if(wrpChildOrder.childOrder.ProcessType__c.equalsIgnoreCase('Voltura')){
                    orderPreDefault.setMetadataLists(wrpChildOrder.childOrder);
                }
            }
        }

        orderPreDefault.getMetadataList();

        //STEP 6: setDefaultOrderValues only for "Voltura"
        for(HDT_WRP_ProcessObjects processObj : processObjList){

            if(processObj.requestItem.Status__c == 'Errore'){
                continue;
            }

            for(HDT_WRP_ChildOrder wrpChildOrder : processObj.childOrderList){
                if(wrpChildOrder.childOrder.ProcessType__c.equalsIgnoreCase('Voltura')){
                    orderPreDefault.setServicePoint(servicePointMap.get(processObj.nextDataObj.servPointId));
                    orderPreDefault.setContract(contractMap.get(processObj.nextDataObj.servPointId));
                    wrpChildOrder.childOrder = orderPreDefault.setDefaultOrderValues(wrpChildOrder.childOrder);
                }
            }
        }

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
                processObj.requestItem.StatusDescription__c = (saveChildOrderResponse.errorItemMap.get(processObj.requestItem.Id)).abbreviate(250);
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
                processObj.requestItem.StatusDescription__c = (saveOrderItemResponse.errorItemMap.get(processObj.requestItem.Id)).abbreviate(250);
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

        //System.debug('>@> ' + JSON.serialize(processObjList));

        HDT_WRP_SaveResponse updateOrderItemResponse;
        updateOrderItemResponse = databaseUpsert(orderItemToUpdate, requestItemForUpsert, 'OrderItem');
        requestItemForUpsert.clear();

        for(HDT_WRP_ProcessObjects processObj : processObjList){
            if(processObj.requestItem.Status__c == 'Errore'){
                setObjectToDelete(processObj);
                continue;
            }
            processObj.requestItem.Status__c = 'In Lavorazione';
        }
        if(sObjectToDelete.size() > 0){
            //HDT_UTL_DatabaseService.deleteSObject(sObjectToDelete);
        }
        getLimitDetails('processEnd');

    }

    private void setObjectToDelete(HDT_WRP_ProcessObjects processObj){
        sObjectToDelete.add(processObj.opportunity);
        sObjectToDelete.add(processObj.sale);
        sObjectToDelete.add(processObj.saleServiceItem);
        sObjectToDelete.add(processObj.parentOrder);
        for(HDT_WRP_ChildOrder wrpChildOrder : processObj.childOrderList){
            sObjectToDelete.add(wrpChildOrder.childOrder);
        }
        
        if(String.isNotEmpty(processObj.nextDataObj.billProfId)){
            sObjectToDelete.add(new BillingProfile__c(Id=processObj.nextDataObj.billProfId));
        }
    }

    public override void finalUpdate(){
        //system.debug(LoggingLevel.DEBUG, 'finalUpdate');

        if(itemsToUpdate.size() > 0){
            update itemsToUpdate;
        }
    }

    private void handleCustomFieldLogic(Order orderToUpdate, String commodity){
        HDT_SRV_Order orderSrv = new HDT_SRV_Order();
        String processType = orderToUpdate.ProcessType__c;
        Date effectiveDate = orderToUpdate.EffectiveDate__c;

        //VOLTURA
        if(processType.equalsIgnoreCase('Voltura')){
            HDT_SRV_AnagAlignment srvAnag = new HDT_SRV_AnagAlignment();
            String tax = commodity == 'Energia Elettrica' ? orderToUpdate.ExciseEle__c : orderToUpdate.ExciseGAS__c;
            String city = orderToUpdate.SupplyCity__c;
            String province = orderToUpdate.SupplyState__c;
            String region = HDT_SRV_AnagAlignment.getRegion(province);
            if(effectiveDate < orderSrv.addBusinessDay(System.today(),3)){
                orderToUpdate.RetroactiveDate__c = orderToUpdate.EffectiveDate__c;
                orderToUpdate.Subprocess__c = 'Retroattiva';
            }else {
                orderToUpdate.Subprocess__c = 'Standard';
            }
            orderToUpdate.ProcessCode__c = commodity.equalsIgnoreCase('Gas') ? 'VTG' : 'VT1';
            orderToUpdate.ExciseRate__c = exciseMap.get(tax);
            if(String.isNotBlank(tax) && String.isNotBlank(city) && String.isNotBlank(region)){
                for(HDT_RegionalAdditional__mdt singleAdd : regionalAddList){
                    if(singleAdd.Tax__c == tax && (singleAdd.City__c == city || String.isBlank(singleAdd.City__c) && (singleAdd.Region__c == region || String.isBlank(singleAdd.Region__c)))){
                        orderToUpdate.RegionalAdditional__c = singleAdd.AdditionalValue__c;
                        break;
                    }
                }
            }
        }
        if(orderToUpdate.VasSubtype__c != null && orderToUpdate.VasSubtype__c == 'Analisi Consumi'){
            //no rate
        }else{
            calculateRateCategory(orderToUpdate);
        }
    }

    private void setSalesCompanyAndCode(Order orderToUpdate, String commodity){
        if(commodity.equalsIgnoreCase('Gas')){
            orderToUpdate.SalesCompany__c = 'Hera Comm Marche';
        } else if(commodity.equalsIgnoreCase('Acqua')){
            orderToUpdate.SalesCompany__c = 'Marche Multiservizi S.p.A';
        } else {
            orderToUpdate.SalesCompany__c = 'Hera Comm S.p.A.';
        }

        if(companyCodeMap.containsKey(orderToUpdate.SalesCompany__c + '_' +  commodity)){
            orderToUpdate.SalesCompanyCode__c = companyCodeMap.get(orderToUpdate.SalesCompany__c + '_' +  commodity);
        }

        //orderToUpdate.Phase__c = 'Comunicazione verso Heroku';
        if(processMatrixMap.containsKey(orderToUpdate.ProcessType__c)){
            orderToUpdate.ProcessCode__c = processMatrixMap.get(orderToUpdate.ProcessType__c);
        }
    }

    private HDT_WRP_OrderItem setRequiredItem(SBQQ__ProductOption__c requiredOption, Id commOffId, Id priceBookId){
        HDT_WRP_OrderItem requiredItem = new HDT_WRP_OrderItem();
        requiredItem = new HDT_WRP_OrderItem();
        requiredItem.itemType = requiredOption.SBQQ__OptionalSKU__r.Name;
        requiredItem.product = new Product2();
        requiredItem.product.ProductCode = requiredOption.SBQQ__OptionalSKU__r.ProductCode;
        requiredItem.orderItem = new OrderItem();

        if(!additionalOrderItemMap.containsKey(commOffId)){
            return null;
        }

        if(!pricebookEntryForOptionalMap.containsKey(priceBookId)){
            return null;
        }

        Map<String, SBQQ__ProductOption__c> tempMap = additionalOrderItemMap.get(commOffId);
        Map<Id, PriceBookEntry> pbeOptionalMap = pricebookEntryForOptionalMap.get(priceBookId);
        
        if(!tempMap.containsKey(requiredItem.product.ProductCode)){
            return null;
        }
        
        requiredItem.product.Id = tempMap.get(requiredItem.product.ProductCode).SBQQ__OptionalSKU__c;
        requiredItem.orderItem.Product2Id = requiredItem.product.Id;
        requiredItem.orderItem.PriceBookEntryId = pbeOptionalMap.get(requiredItem.product.Id).Id;
        requiredItem.orderItem.UnitPrice = pbeOptionalMap.get(requiredItem.product.Id).UnitPrice;
        requiredItem.orderItem.Quantity = 1;

        return requiredItem;
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
        //sale.Channel__c = sale.LowerChannelAgency__c;
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
        parentOrder.Phase__c = 'In Lavorazione';
        parentOrder.ContractSigned__c = true;
        parentOrder.EffectiveDate = Date.today();
        parentOrder.Step__c = 2;
        parentOrder.AccountId = sale.Account__c;
        parentOrder.Sale__c = sale.Id;
        parentOrder.Contact__c = sale.SalesContact__c;
        parentOrder.Channel__c = sale.Channel__c;
        parentOrder.VendorLastName__c = sale.VendorLastName__c;
        parentOrder.VendorFirstName__c = sale.VendorFirstName__C;
        parentOrder.CommercialId__c = sale.CommercialId__c;
        parentOrder.AgencyCode__c = sale.AgencyCode__c;
        parentOrder.Agency__c = sale.Agency__c;
        parentOrder.AreaManager__c = sale.AreaManager__c;
        parentOrder.ServicePoint__c = childOrder.ServicePoint__c;
        parentOrder.SignatureMethod__c = childOrder.SignatureMethod__c;
        parentOrder.DocSendingMethod__c = childOrder.DocSendingMethod__c;
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
        parentOrder.isMassive__c = true;
        parentOrder.LowerChannelAgency__c = sale.LowerChannelAgency__c;
        parentOrder.UpperChannelAgency__c = sale.UpperChannelAgency__c;
        parentOrder.CommercialId__c = sale.CommercialId__c;
        parentOrder.LoginChannel__c = childOrder.LoginChannel__c;
        parentOrder.CreatorGroup__c = childOrder.CreatorGroup__c;
        if(parentOrder.SignatureMethod__c.equalsIgnoreCase('Contratto già firmato')){
            parentOrder.Status = 'Completed';
            parentOrder.Phase__c = 'Documentazione Gestita';
        }

        return parentOrder;
    }

    private HDT_WRP_ChildOrder handleBonus(HDT_WRP_ChildOrder wrpChildOrder, List<String> csvValues){
        HDT_WRP_OrderItem wrpOrderItem;
        String codiceBonus1 = csvValues[mapHeaderForWrapper.get('BONUS_PERC1')];
        String codiceBonusEurMese1 = csvValues[mapHeaderForWrapper.get('BONUS_EURMESE1')];
        String codiceBonusEurGiorno1 = csvValues[mapHeaderForWrapper.get('BONUS_EURGIORNO1')];
        String codiceBonusEurSmc1 = csvValues[mapHeaderForWrapper.get('BONUS_EURSMC1')];
            
        Boolean enableBonusPerc = (String.isNotEmpty(codiceBonus1));
        Boolean enableBonusMese = (String.isNotEmpty(codiceBonusEurMese1));
        Boolean enableBonusGiorno = (String.isNotEmpty(codiceBonusEurGiorno1));
        Boolean enableBonusSmc = (String.isNotEmpty(codiceBonusEurSmc1));
        String codiceBonus = '';
        if(enableBonusPerc){
            for(Integer i=1;i<=4;i++){
                codiceBonus = csvValues[mapHeaderForWrapper.get('BONUS_PERC'+i)];
                if( String.isNotBlank(codiceBonus)){
                    // set wrapper for "bonus"
                    wrpOrderItem = new HDT_WRP_OrderItem();
                    wrpOrderItem.itemType = 'bonus';
                    wrpOrderItem.product = new Product2();
                    wrpOrderItem.product.ProductCode = codiceBonus;
                    wrpOrderItem.orderItem = new OrderItem();
                    wrpChildOrder.orderItemList.add(wrpOrderItem);
                    additionalProduct2.add(wrpOrderItem.product);
                }
            }
        }
        if(enableBonusMese){
            for(Integer j=1;j<=4;j++){
                codiceBonus = csvValues[mapHeaderForWrapper.get('BONUS_EURMESE'+j)];
                if( String.isNotBlank(codiceBonus)){
                    // set wrapper for "bonus"
                    wrpOrderItem = new HDT_WRP_OrderItem();
                    wrpOrderItem.itemType = 'bonus';
                    wrpOrderItem.product = new Product2();
                    wrpOrderItem.product.ProductCode = codiceBonus;
                    wrpOrderItem.orderItem = new OrderItem();
                    wrpChildOrder.orderItemList.add(wrpOrderItem);
                    additionalProduct2.add(wrpOrderItem.product);
                }
            }
        }
        if(enableBonusGiorno){
            for(Integer k=1;k<=4;k++){
                codiceBonus = csvValues[mapHeaderForWrapper.get('BONUS_EURGIORNO'+k)];
                if( String.isNotBlank(codiceBonus)){
                    // set wrapper for "bonus"
                    wrpOrderItem = new HDT_WRP_OrderItem();
                    wrpOrderItem.itemType = 'bonus';
                    wrpOrderItem.product = new Product2();
                    wrpOrderItem.product.ProductCode = codiceBonus;
                    wrpOrderItem.orderItem = new OrderItem();
                    wrpChildOrder.orderItemList.add(wrpOrderItem);
                    additionalProduct2.add(wrpOrderItem.product);
                }
            } 
        }
        if(enableBonusSmc){
            for(Integer z=1;z<=4;z++){
                codiceBonus = csvValues[mapHeaderForWrapper.get('BONUS_EURSMC'+z)];
                if( String.isNotBlank(codiceBonus)){
                    // set wrapper for "bonus"
                    wrpOrderItem = new HDT_WRP_OrderItem();
                    wrpOrderItem.itemType = 'bonus';
                    wrpOrderItem.product = new Product2();
                    wrpOrderItem.product.ProductCode = codiceBonus;
                    wrpOrderItem.orderItem = new OrderItem();
                    wrpChildOrder.orderItemList.add(wrpOrderItem);
                    additionalProduct2.add(wrpOrderItem.product);
                }
            } 
        }
        return wrpChildOrder;

    }

    public String checkRequiredSalesField(Sale__c sale){
        Boolean canale = String.isEmpty(sale.Channel__c);
        Boolean codiceAgenzia = String.isEmpty(sale.AgencyCode__c);
        Boolean agenzia = String.isEmpty(sale.Agency__c);
        Boolean vendutoDa= String.isEmpty(sale.CommercialId__c);
        Boolean nomeAgente = String.isEmpty(sale.VendorFirstName__c);
        Boolean cognomeAgente = String.isEmpty(sale.VendorLastName__c);
        if(canale || codiceAgenzia || agenzia || vendutoDa || nomeAgente || cognomeAgente){
            return 'Verificare che i campi Canale, Agenzia, Codice Agenzia, Venduto da, Nome/Cognome Agente siano valorizzati';
        }
        return '';
    }

    private HDT_WRP_ProcessObjects buildWrapperOrderStructure(HDT_WRP_ProcessObjects processObject, List<String> csvValues, HDT_UTL_ProcessSales.HDT_WRP_NextDataObj nextDataObj){

        String codiceOfferta = csvValues[mapHeaderForWrapper.get('CodiceOfferta')];
        String versione = '';
        try{
            versione = csvValues[mapHeaderForWrapper.get('VersioneOfferta')];
        } catch(Exception e){
            //no error manage needed
        }
            
        //if(String.isNotEmpty(codiceOfferta) && String.isNotEmpty(versione)){
        if(String.isNotEmpty(codiceOfferta)){
            HDT_WRP_ChildOrder wrpChildOrder = new HDT_WRP_ChildOrder();
            wrpChildOrder.orderType = 'Attivazione';
            wrpChildOrder.childOrder = new Order();
            wrpChildOrder.childOrder.RecordTypeId = childOrderRecordTypeId;
            wrpChildOrder.childOrder.IsMassive__c = true;
            wrpChildOrder.childOrder.Status = 'In Lavorazione';
            wrpChildOrder.childOrder.AccountId = nextDataObj.accountId;
            wrpChildOrder.childOrder.ServicePoint__c = nextDataObj.servPointId;
            wrpChildOrder.childOrder.BillingProfile__c = nextDataObj.billProfId;
            wrpChildOrder.childOrder.RateCategory__c = codiceOfferta;
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

            //String itemTypeCsv = csvValues[mapHeaderForWrapper.get('ServicePointServizio')];
            String codicePuntoCsv = csvValues[mapHeaderForWrapper.get('ServicePointCodicePunto')];
            String itemType = '';

            //if(String.isNotEmpty(itemTypeCsv) && itemTypeCsv.equalsIgnoreCase('Energia Elettrica')){
            //    itemType = 'POD';
            //} else if(String.isNotEmpty(itemTypeCsv) && itemTypeCsv.equalsIgnoreCase('Gas')){
            //    itemType = 'PDR';
            //} else if(String.isNotEmpty(codicePuntoCsv)){
            //    if(codicePuntoCsv.isNumeric()){
            //        itemType = 'PDR';
            //    } else {
            //        itemType = 'POD';
            //    }
            //}
            if(String.isNotEmpty(codicePuntoCsv)){
                if(codicePuntoCsv.isNumeric()){
                    itemType = 'PDR';
                } else {
                    itemType = 'POD';
                }
            }

            wrpOrderItem = new HDT_WRP_OrderItem();
            wrpOrderItem.itemType = itemType;
            wrpOrderItem.product = new Product2();
            wrpOrderItem.product.ProductCode = itemType;
            wrpOrderItem.orderItem = new OrderItem();

            if(!processName.equalsIgnoreCase('VolturaNoEnergy')){
                wrpChildOrder.orderItemList.add(wrpOrderItem);
                additionalProduct2.add(wrpOrderItem.product);
            }

            /*String codiceBonus = csvValues[mapHeaderForWrapper.get('CodiceBonus')];
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
            }*/

            if(isDiscountAndBonusProcess){
                processDiscountBonus.handleDiscountAndBonus(wrpChildOrder, csvValues);
            }

            if(!processName.equalsIgnoreCase('VolturaNoEnergy') && !processName.equalsIgnoreCase('Voltura') && !isDiscountAndBonusProcess){
                wrpChildOrder = handleBonus(wrpChildOrder,csvValues);
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
            wrpChildOrder.childOrder.CommercialProductCode__c = codiceOfferta;
            wrpChildOrder.childOrder.CommercialProductVersion__c = versione;

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
        rtNameMap.put('MUC', 'HDT_RT_CambioOfferta');
        rtNameMap.put('TariffeSconti', 'HDT_RT_ScontiBonus');
        rtNameMap.put('VolturaNoEnergy', 'HDT_RT_Voltura');

        String devName = rtNameMap.get(processName);
        return Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get(devName).getRecordTypeId();

    }

    private String buildProductKey(Product2 p){
        if(processName.equalsIgnoreCase('Voltura')){
            return p.ProductCode;
        } else if(processName.equalsIgnoreCase('VolturaNoEnergy')){
            return p.ProductCode;
        } else {
            return p.ProductCode + '-' + p.Version__c;
        }
        
    }

    public class HDT_WRP_ProcessObjects {
        public Opportunity opportunity;
        public Sale__c sale;
        public SaleServiceItem__c saleServiceItem;
        public Order parentOrder;
        public List<HDT_WRP_ChildOrder> childOrderList;
        public MassiveLoaderRequestItem__c requestItem;
        //private Id accountId;
        //private Id contactId;
        //private Id billProfId;
        //private Id servPointId;
        public HDT_UTL_ProcessSales.HDT_WRP_NextDataObj nextDataObj;

        public HDT_WRP_ProcessObjects(){
            opportunity = new Opportunity();
            sale = new Sale__c();
            saleServiceItem = new SaleServiceItem__c();
            parentOrder = new Order();
            childOrderList = new List<HDT_WRP_ChildOrder>();
        }

    }

    private void calculateRateCategory(Order order){
        Boolean res = false;
		String pod = order.ServicePointCode__c;
		String commodity = '';
        String tipoFornitura = order.SupplyType__c;
        String productName = order.CommercialProduct__c;
        String code;
		if(pod != null && pod.isNumeric()){
			commodity = 'Gas';
		}else{
			commodity = 'Energia Elettrica';
		}
		
        for(RateCategory__c rt : rateCategoryList){
            if(rt.Commodity__c == commodity && rt.Fornitura__c ==  tipoFornitura && rt.ProductName__c == productName){            
                if(rt.DistributorCode__c == order.DistributorCode__c && rt.operatore__c == 'Uguale'){
                    code = rt.CalculatedValue__c;
                    res = true;
                    break;
                }
                else if(rt.DistributorCode__c != order.DistributorCode__c && rt.operatore__c == 'Diverso'){
                    code = rt.CalculatedValue__c;
                    res = true;
                    break;
                }
                else if(rt.operatore__c == 'N/A'){
                    code = rt.CalculatedValue__c;
                    res = true;
                    break;
                }
            }
        }
        if(!res){
            for(RateCategory__c r : rateCategoryList){
                if(r.Commodity__c == commodity && r.Fornitura__c ==  tipoFornitura && r.ProductName__c == 'N/A'){
                    if(r.DistributorCode__c == order.DistributorCode__c && r.operatore__c == 'Uguale'){
                        code = r.CalculatedValue__c;
                        res = true;
                        break;
                    }
                    else if(r.DistributorCode__c != order.DistributorCode__c && r.operatore__c == 'Diverso'){
                        code = r.CalculatedValue__c;
                        res = true;
                        break;
                    }
                    else if(r.operatore__c == 'N/A'){
                        code = r.CalculatedValue__c;
                        res = true;
                        break;
                    }
                }
            }
        }
        order.RateCategory__c = code;
    }

    public class HDT_WRP_ChildOrder {
        public String orderType;
        public Order childOrder;
        public String sapContractCode;
        public List<HDT_WRP_OrderItem> orderItemList;
    }

    public class HDT_WRP_OrderItem {
        public String itemType;
        public OrderItem orderItem;
        public Product2 product;
    }

}