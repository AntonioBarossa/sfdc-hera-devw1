@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_UTL_ProcessOrderCreation extends HDT_UTL_ProcessExecution{

    private List<MassiveLoaderRequestItem__c> itemsToSave;
    private List<HDT_WRP_ProcessObjects> processObjList;
    private List<Product2> commOfferForRetrieve;
    private List<Product2> orderItemSupplyPointForRetrieve;
    private Map<Id, PricebookEntry> priceBookEntryMap = new Map<Id, PricebookEntry>();
    private Map<Id, PricebookEntry> priceBookEntry2Map = new Map<Id, PricebookEntry>();
    private Map<String, Product2> commOfferMap;
    private Map<String, Id> orderItemSupplyPointMap;
    List<PricebookEntry> pbeOptionalSkuList = new List<PricebookEntry>();

    public override void checks(){

        mapFieldsObject();

        itemsToSave = new List<MassiveLoaderRequestItem__c>();
        commOfferForRetrieve = new List<Product2>();
        orderItemSupplyPointForRetrieve = new List<Product2>();

        HDT_WRP_ProcessObjects processObj;
        processObjList = new List<HDT_WRP_ProcessObjects>();
        List<String> tempSplitedFields;
        HDT_UTL_ProcessSales.HDT_WRP_NextDataObj obj;
        for(MassiveLoaderRequestItem__c item : requestItemList){

            tempSplitedFields = item.Data__c.split(splitCharacter, -1);
            if(!String.isEmpty(item.NextStepData__c)){
                obj = (HDT_UTL_ProcessSales.HDT_WRP_NextDataObj)JSON.deserialize(item.NextStepData__c, HDT_UTL_ProcessSales.HDT_WRP_NextDataObj.class);
            }

            //checkRequiredFields(item, tempSplitedFields);
            //System.debug(LoggingLevel.DEBUG, '>>> itemStatus' + item.Status__c);

            //if(item.Status__c.equalsIgnoreCase('Errore')){
            //    itemsToSave.add(item);
            //    continue;
            //}

            processObj = new HDT_WRP_ProcessObjects();

            processObj.opportunity = new Opportunity();
            processObj.sale = new Sale__c();
            processObj.parentOrder = new Order();
            processObj.childOrder = new Order();
            processObj.orderItemCommOff = new OrderItem();
            processObj.orderItemSupplyPoint = new OrderItem();
            processObj.prodCommOff = new Product2();
            processObj.prodSupplyPoint = new Product2();

            processObj.accountId = obj.accountId;
            processObj.billProfId = obj.billProfId;
            processObj.servPointId = obj.servPointId;
            processObj.requestItem = item;

            Integer count = 0;
            String convertionError;
            for (String tempField : tempSplitedFields) {
                // convert csv here and inizializate 
                // order
                // OrderItem orderItemCommOff
                // OrderItem orderItemSupplyPoint
                // sale__c ?
            }

            processObj.sale = setSaleObject(processObj.sale);
            processObj.opportunity = setOpportunityObj(processObj.opportunity);

            processObj.prodCommOff.ProductCode = tempSplitedFields[0];
            processObj.prodCommOff.Version__c = tempSplitedFields[1];

            processObj.prodSupplyPoint.ProductCode = tempSplitedFields[2];
            //processObj.prodSupplyPoint.Version__c = tempSplitedFields[0];

            commOfferForRetrieve.add(processObj.prodCommOff);
            orderItemSupplyPointForRetrieve.add(processObj.prodSupplyPoint);

            processObjList.add(processObj);

        }
    }

    public override void getRecords(){

        List<String> productCodeList = new List<String>();
        List<String> versionList = new List<String>();
        List<Product2> product2RetrievedFromDb = new List<Product2>();
        List<Id> product2IdList = new List<Id>();
        List<PriceBookEntry> pbeList = new List<PriceBookEntry>();
        List<SBQQ__ProductOption__c> productOptionList = new List<SBQQ__ProductOption__c>();
        commOfferMap = new Map<String, Product2>();
        orderItemSupplyPointMap = new Map<String, Id>();

        Map<Id, Id> skuMap = new Map<Id, Id>();

        for(Product2 commOffer : commOfferForRetrieve){
            productCodeList.add(commOffer.ProductCode);
            versionList.add(commOffer.Version__c);
        }

        for(Product2 orderItemSupplyPoint : orderItemSupplyPointForRetrieve){
            productCodeList.add(orderItemSupplyPoint.ProductCode);
        }

        product2RetrievedFromDb = [
            SELECT Id, ProductCode, Version__c
            FROM Product2
            WHERE ProductCode IN :productCodeList AND ProductCode != null
            AND Version__c IN :versionList AND Version__c != null
            AND Family = 'Offerta commerciale'
        ];

        for(Product2 p : product2RetrievedFromDb){
            product2IdList.add(p.Id);
            commOfferMap.put(p.ProductCode + '-' + p.Version__c, p);
        }

        pbeList = [
            SELECT Id, Pricebook2Id, Product2Id, UnitPrice
            FROM PricebookEntry
            WHERE Product2Id IN :product2IdList
            AND Pricebook2.IsStandard = false
        ];
        
        for(PriceBookEntry pbe : pbeList){
            priceBookEntryMap.put(pbe.Product2Id, pbe);
        }

        productOptionList = [
            SELECT SBQQ__ConfiguredSKU__c, SBQQ__OptionalSKU__c
            FROM SBQQ__ProductOption__c
            WHERE SBQQ__ConfiguredSKU__c IN :product2IdList
            AND SBQQ__OptionalSKU__r.ProductCode IN :productCodeList
            //AND SBQQ__Feature__r.SBQQ__Category__c = 'Punto Fornitura'
        ];

        for(SBQQ__ProductOption__c prodOpt : productOptionList){
            orderItemSupplyPointMap.put(prodOpt.SBQQ__ConfiguredSKU__c, prodOpt.SBQQ__OptionalSKU__c);
        }
        
        
        pbeOptionalSkuList = [
            SELECT Id, Pricebook2Id, Product2Id, UnitPrice
            FROM PricebookEntry
            WHERE Product2Id IN :orderItemSupplyPointMap.values()
            AND Pricebook2.IsStandard = false
        ];


        System.debug('>>> product2RetrievedFromDb: ' + product2RetrievedFromDb);
        System.debug('>>> priceBookEntryMap: ' + priceBookEntryMap);
        System.debug('>>> orderItemSupplyPointMap: ' + orderItemSupplyPointMap);

    }

    public override void registryCreation(){

        List<Order> parentOrderToInsert = new List<Order>();
        List<Order> childOrderToInsert = new List<Order>();
        List<OrderItem> orderItemToInsert = new List<OrderItem>();

        for(HDT_WRP_ProcessObjects processObj : processObjList){
            processObj.prodCommOff = commOfferMap.get(processObj.prodCommOff.ProductCode + '-' + processObj.prodCommOff.Version__c);
            processObj.prodSupplyPoint.Id = orderItemSupplyPointMap.get(processObj.prodCommOff.Id);
            
            // order creation
            processObj.childOrder.EffectiveDate = Date.today();
            processObj.childOrder.Status = 'Draft';
            processObj.childOrder.Pricebook2Id = priceBookEntryMap.get(processObj.prodCommOff.Id).Pricebook2Id;
            processObj.childOrder.AccountId = processObj.accountId;

            // orderItem creation for "Offerta commerciale"
            processObj.orderItemCommOff.Product2Id = processObj.prodCommOff.Id;

            // orderItem creation for "Punto fornitura"
            processObj.orderItemSupplyPoint.Product2Id = orderItemSupplyPointMap.get(processObj.prodCommOff.Id);

            System.debug('>>> current processObj: ' + JSON.serialize(processObj));

            processObj.parentOrder = createFatherOrder(processObj.childOrder, processObj.parentOrder);

            parentOrderToInsert.add(processObj.parentOrder);
            childOrderToInsert.add(processObj.childOrder);

        }

        System.debug(String.valueOf(parentOrderToInsert));
        insert childOrderToInsert;
        
        for(HDT_WRP_ProcessObjects processObj : processObjList){

            processObj.orderItemCommOff.OrderId = processObj.childOrder.Id;
            processObj.orderItemCommOff.PricebookEntryId = priceBookEntryMap.get(processObj.prodCommOff.Id).Id;
            processObj.orderItemCommOff.Quantity = 1;
            processObj.orderItemCommOff.UnitPrice = priceBookEntryMap.get(processObj.prodCommOff.Id).UnitPrice;
            orderItemToInsert.add(processObj.orderItemCommOff);

            processObj.orderItemSupplyPoint.OrderId = processObj.childOrder.Id;

            for(PricebookEntry pbeSku : pbeOptionalSkuList){

                if(pbeSku.Product2Id == processObj.prodSupplyPoint.Id && pbeSku.Pricebook2Id == priceBookEntryMap.get(processObj.prodCommOff.Id).Pricebook2Id){
                    processObj.orderItemSupplyPoint.PricebookEntryId = pbeSku.Id;
                    processObj.orderItemSupplyPoint.UnitPrice = pbeSku.UnitPrice;
                    break;
                }

            }
            
            processObj.orderItemSupplyPoint.Quantity = 1;
            orderItemToInsert.add(processObj.orderItemSupplyPoint);
        }

        insert orderItemToInsert;

        System.debug('>>> order created: ' + childOrderToInsert);

    }

    private void mapFieldsObject(){

    }

    private Sale__c setSaleObject(Sale__c sale){
        return sale;
    }

    private Opportunity setOpportunityObj(Opportunity opportunity){
        return opportunity;
    }

    private Order createFatherOrder(Order childOrder, Order parentOrder){
        parentOrder.AccountId = childOrder.AccountId;
        parentOrder.Sale__c = childOrder.Sale__c;
        parentOrder.ServicePoint__c = childOrder.ServicePoint__c;
        parentOrder.RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_OrderDossier').getRecordTypeId();
        parentOrder.ContractSigned__c = childOrder.ContractSigned__c;
        parentOrder.SignatureMethod__c = childOrder.SignatureMethod__c;
        parentOrder.DocSendingMethod__c = childOrder.DocSendingMethod__c;
        parentOrder.Status = childOrder.Status;
        parentOrder.EffectiveDate = childOrder.EffectiveDate;
        return parentOrder;
    }

    private class HDT_WRP_ProcessObjects {
        private Opportunity opportunity;
        private Sale__c sale;
        private Order parentOrder;
        private Order childOrder;
        private OrderItem orderItemCommOff;
        private OrderItem orderItemSupplyPoint;
        private Product2 prodCommOff;
        private Product2 prodSupplyPoint;
        private Id accountId;
        private Id billProfId;
        private Id servPointId;
        private MassiveLoaderRequestItem__c requestItem;
        private List<String> csvSplitted;
    }

}