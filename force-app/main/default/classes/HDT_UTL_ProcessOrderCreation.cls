@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_UTL_ProcessOrderCreation extends HDT_UTL_ProcessExecution{

    private List<MassiveLoaderRequestItem__c> itemsToSave;
    private List<HDT_WRP_ProcessObjects> processObjList;
    private List<Product2> commOfferForRetrieve;
    private List<Product2> supplyPointForRetrieve;
    private Map<Id, Id> priceBookMap = new Map<Id, Id>();
    private Map<String, Product2> commOfferMap;
    private Map<String, Id> supplyPointMap;

    public override void checks(){

        mapFieldsObject();

        itemsToSave = new List<MassiveLoaderRequestItem__c>();
        commOfferForRetrieve = new List<Product2>();
        supplyPointForRetrieve = new List<Product2>();

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

            processObj.order = new Order();
            processObj.commercialOffer = new OrderItem();
            processObj.supplyPoint = new OrderItem();
            processObj.commercialOfferP2 = new Product2();
            processObj.supplyPointP2 = new Product2();

            processObj.accountId = obj.accountId;
            processObj.billProfId = obj.billProfId;
            processObj.servPointId = obj.servPointId;
            processObj.requestItem = item;

            Integer count = 0;
            String convertionError;
            for (String tempField : tempSplitedFields) {
                // convert csv here and inizializate 
                // order
                // OrderItem commercialOffer
                // OrderItem supplyPoint
                // sale__c ?
            }

            commOfferForRetrieve.add(processObj.commercialOfferP2);
            supplyPointForRetrieve.add(processObj.supplyPointP2);

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

        for(Product2 commOffer : commOfferForRetrieve){
            productCodeList.add(commOffer.ProductCode);
            versionList.add(commOffer.Version__c);
        }

        for(Product2 supplyPoint : supplyPointForRetrieve){
            productCodeList.add(supplyPoint.ProductCode);
            versionList.add(supplyPoint.Version__c);
        }

        product2RetrievedFromDb = [
            SELECT Id, ProductCode, Version__c
            FROM Product2
            WHERE ProductCode IN :productCodeList
            AND Version__c IN :versionList
        ];

        for(Product2 p : product2RetrievedFromDb){
            product2IdList.add(p.Id);
            commOfferMap.put(p.ProductCode + '-' + p.Version__c, p);
        }

        pbeList = [
            SELECT Id, Pricebook2Id, Product2Id
            FROM PricebookEntry
            WHERE Product2Id IN :product2IdList
            AND Pricebook2.IsStandard = false
        ];
        
        for(PriceBookEntry pbe : pbeList){
            priceBookMap.put(pbe.Product2Id, pbe.Pricebook2Id);
        }

        productOptionList = [
            SELECT SBQQ__ConfiguredSKU__c, SBQQ__OptionalSKU__c
            FROM SBQQ__ProductOption__c
            WHERE SBQQ__ConfiguredSKU__c IN :product2IdList
            AND SBQQ__Feature__r.SBQQ__Category__c = 'Punto Fornitura'
        ];

        for(SBQQ__ProductOption__c prodOpt : productOptionList){
            supplyPointMap.put(prodOpt.SBQQ__ConfiguredSKU__c, prodOpt.SBQQ__OptionalSKU__c);
        }
        

    }

    public override void registryCreation(){

    }

    private void mapFieldsObject(){

    }

    private class HDT_WRP_ProcessObjects {
        private Order order;
        private OrderItem commercialOffer;
        private OrderItem supplyPoint;
        private Product2 commercialOfferP2;
        private Product2 supplyPointP2;
        private Id accountId;
        private Id billProfId;
        private Id servPointId;
        private MassiveLoaderRequestItem__c requestItem;
        private List<String> csvSplitted;
    }

}