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

    private Map<String, HDT_MassiveFieldsObjectMap__mdt> sobjectMap;
    private List<MassiveLoaderRequestItem__c> itemsToSave;
    private List<HDT_WRP_ProcessObjects> processObjList;
    private List<Product2> commOfferForRetrieve;
    private List<Product2> additionalProduct2;
    private Map<Id, PricebookEntry> priceBookEntryMap = new Map<Id, PricebookEntry>();
    private Map<Id, PricebookEntry> priceBookEntry2Map = new Map<Id, PricebookEntry>();
    private Map<String, Product2> commOfferMap;
    private Map<String, Map<String, String>> additionalOrderItemMap;
    List<PricebookEntry> pbeOptionalSkuList = new List<PricebookEntry>();
    private Map<String, String> mapAllFields;

    Map<String, String> product2ForActivationMap;
    Map<String, HDT_MassiveFieldsObjectMap__mdt> product2ForAdditionalMap;
    Map<String, HDT_MassiveFieldsObjectMap__mdt> wrpForStructureMap;
    Map<Id, Map<Id, Id>> pricebookEntryForOptionalMap;

    public override void checks(){

        mapFieldsObject();

        System.debug('>>> mapHeaderByPosition ' + mapHeaderByPosition);
        System.debug('>>> product2ForActivationMap ' + product2ForActivationMap);

        itemsToSave = new List<MassiveLoaderRequestItem__c>();
        commOfferForRetrieve = new List<Product2>();
        additionalProduct2 = new List<Product2>();

        HDT_WRP_ProcessObjects processObj;
        processObjList = new List<HDT_WRP_ProcessObjects>();
        List<String> tempSplitedFields;
        HDT_UTL_ProcessSales.HDT_WRP_NextDataObj obj;
        for(MassiveLoaderRequestItem__c item : requestItemList){

            tempSplitedFields = item.Data__c.split(splitCharacter, -1);
            if(!String.isEmpty(item.NextStepData__c)){
                obj = (HDT_UTL_ProcessSales.HDT_WRP_NextDataObj)JSON.deserialize(item.NextStepData__c, HDT_UTL_ProcessSales.HDT_WRP_NextDataObj.class);
            }

            processObj = new HDT_WRP_ProcessObjects();
            processObj.requestItem = item;

            System.debug('>>> ' + obj.accountId);
            System.debug('>>> ' + obj.billProfId);
            System.debug('>>> ' + obj.servPointId);

            processObj.sale = setSaleObject(processObj.sale);
            processObj.opportunity = setOpportunityObj(processObj.opportunity);
            processObj = buildWrapperOrderStructure(processObj, tempSplitedFields, obj);

            String csvHeader;
            String convertionError;
            String tempValue;
            String objField;
            for(Integer count=0; count < tempSplitedFields.size(); count++){
                tempValue = tempSplitedFields[count];
                csvHeader = mapHeaderByPosition.get(count);
                objField = mapAllFields.get(csvHeader);

                if(String.isNotBlank(objField) && String.isNotBlank(tempValue)){
                    continue;
                }

                if(sobjectMap.containsKey(csvHeader)){
                    switch on sobjectMap.get(csvHeader).objectType__c {
                        when 'Sale__c' {
                            //convertionError = mapTypeField(processObj.account, mapAllFields, count, tempValue);
                        }
                        when 'Opportunity' {

                        }
                        when 'ServicePoint__c' {

                        }
                    }
                }

                if(String.isNotEmpty(convertionError)){
                    // error happened -> exit
                    System.debug(LoggingLevel.DEBUG, '>>> break for loop...' + csvHeader + ' - ' + tempValue);
                    break;
                }


            }


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
        additionalOrderItemMap = new Map<String, Map<String, String>>();
        pricebookEntryForOptionalMap = new Map<Id, Map<Id, Id>>();

        Map<Id, Id> skuMap = new Map<Id, Id>();

        for(Product2 commOffer : commOfferForRetrieve){
            productCodeList.add(commOffer.ProductCode);
            versionList.add(commOffer.Version__c);
        }

        for(Product2 orderItemSupplyPoint : additionalProduct2){
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
            additionalOrderItemMap.put(p.Id, new Map<String, String>());
        }

        pbeList = [
            SELECT Id, Pricebook2Id, Product2Id, UnitPrice
            FROM PricebookEntry
            WHERE Product2Id IN :product2IdList
            AND Pricebook2.IsStandard = false
        ];
        
        for(PriceBookEntry pbe : pbeList){
            priceBookEntryMap.put(pbe.Product2Id, pbe);

            if(!pricebookEntryForOptionalMap.containsKey(pbe.Pricebook2Id)){
                pricebookEntryForOptionalMap.put(pbe.Pricebook2Id, new Map<Id, Id>());
            }

        }

        productOptionList = [
            SELECT SBQQ__ConfiguredSKU__c, SBQQ__OptionalSKU__c, SBQQ__OptionalSKU__r.ProductCode
            FROM SBQQ__ProductOption__c
            WHERE SBQQ__ConfiguredSKU__c IN :product2IdList
        ];

        List<Id> optnionalSkuIdList = new List<Id>();
        
        for(SBQQ__ProductOption__c prodOpt : productOptionList){
            Map<String, String> tempMap = additionalOrderItemMap.get(prodOpt.SBQQ__ConfiguredSKU__c);
            tempMap.put(prodOpt.SBQQ__OptionalSKU__r.ProductCode, prodOpt.SBQQ__OptionalSKU__c);
            additionalOrderItemMap.put(prodOpt.SBQQ__ConfiguredSKU__c, tempMap);
            optnionalSkuIdList.add(prodOpt.SBQQ__OptionalSKU__c);
        }
        
        
        pbeOptionalSkuList = [
            SELECT Id, Pricebook2Id, Product2Id, UnitPrice
            FROM PricebookEntry
            WHERE Product2Id IN :optnionalSkuIdList
            AND Pricebook2.IsStandard = false
        ];

        for(PricebookEntry pbe : pbeOptionalSkuList){
            Map<Id, Id> tempMap = pricebookEntryForOptionalMap.get(pbe.Pricebook2Id);
            tempMap.put(pbe.Product2Id, pbe.Id);
            pricebookEntryForOptionalMap.put(pbe.Pricebook2Id, tempMap);
        }

        System.debug('>>> commOfferMap: ' + commOfferMap);
        System.debug('>>> product2RetrievedFromDb: ' + product2RetrievedFromDb);
        System.debug('>>> priceBookEntryMap: ' + priceBookEntryMap);
        //System.debug('>>> additionalOrderItemMap: ' + additionalOrderItemMap);

    }

    public override void registryCreation(){

        List<Order> parentOrderToInsert = new List<Order>();
        List<Order> childOrderToInsert = new List<Order>();
        List<OrderItem> orderItemToInsert = new List<OrderItem>();

        Id commOffId;
        Id priceBookId;

        for(HDT_WRP_ProcessObjects processObj : processObjList){

            for(HDT_WRP_ChildOrder childOrder : processObj.childOrderList){
                if(childOrder.orderType.equalsIgnoreCase('Attivazione')){
                    System.debug('>>> activation');
                    for(HDT_WRP_OrderItem orderItem : childOrder.orderItemList){
                        if(orderItem.itemType.equalsIgnoreCase('offertaComm')){
                            System.debug('>>> offertaComm');
                            orderItem.product = commOfferMap.get(orderItem.product.ProductCode + '-' + orderItem.product.Version__c);
                            commOffId = orderItem.product.Id;
                            orderItem.orderItem.PriceBookEntryId = priceBookEntryMap.get(commOffId).Id;
                            orderItem.orderItem.Product2Id = commOffId;
                            priceBookId = priceBookEntryMap.get(commOffId).Pricebook2Id;
                            System.debug('>>> pbeId offComm ' + orderItem.orderItem.PriceBookEntryId);
                        }

                    }
                }

            }

            for(HDT_WRP_ChildOrder childOrder : processObj.childOrderList){

                Map<Id, Id> pbeOptionalMap = pricebookEntryForOptionalMap.get(priceBookId);

                if(childOrder.orderType.equalsIgnoreCase('Attivazione')){
                    System.debug('>>> activation');

                    childOrder.childOrder.Pricebook2Id = priceBookId;
                    childOrder.childOrder.EffectiveDate = Date.today();
                    childOrder.childOrder.Status = 'Draft';

                    for(HDT_WRP_OrderItem orderItem : childOrder.orderItemList){

                        if(orderItem.itemType.equalsIgnoreCase('POD') || orderItem.itemType.equalsIgnoreCase('PDR')){
                            Map<String, String> tempMap = additionalOrderItemMap.get(commOffId);
                            if(tempMap.containsKey(orderItem.product.ProductCode)){
                                orderItem.product.Id = tempMap.get(orderItem.product.ProductCode);
                                orderItem.orderItem.Product2Id = orderItem.product.Id;
                                orderItem.orderItem.PriceBookEntryId = pbeOptionalMap.get(orderItem.product.Id);
                                System.debug('>>> pbeId pod-pdr ' + orderItem.orderItem.PriceBookEntryId);
                            } else {
                                orderItem = null;
                            }
                            
                        }

                    }

                    processObj.parentOrder = createFatherOrder(childOrder.childOrder, processObj.parentOrder);
                    parentOrderToInsert.add(processObj.parentOrder);
                }

                if(childOrder.orderType.equalsIgnoreCase('Aggiuntivo')){

                    childOrder.childOrder.Pricebook2Id = priceBookId;
                    childOrder.childOrder.EffectiveDate = Date.today();
                    childOrder.childOrder.Status = 'Draft';

                    for(HDT_WRP_OrderItem orderItem : childOrder.orderItemList){
                        Map<String, String> tempMap = additionalOrderItemMap.get(commOffId);
                        if(tempMap.containsKey(orderItem.product.ProductCode)){
                            orderItem.product.Id = tempMap.get(orderItem.product.ProductCode);
                            orderItem.orderItem.Product2Id = orderItem.product.Id;
                            orderItem.orderItem.PriceBookEntryId = pbeOptionalMap.get(orderItem.product.Id);
                            System.debug('>>> pbeId aggint ' + orderItem.orderItem.PriceBookEntryId);
                        } else {
                            orderItem = null;
                        }
                        
                    }
                }

                childOrderToInsert.add(childOrder.childOrder);

            }

            System.debug(JSON.serializePretty(processObj));

        }

        insert parentOrderToInsert;

        for(HDT_WRP_ProcessObjects processObj : processObjList){
            for(HDT_WRP_ChildOrder childOrder : processObj.childOrderList){
                childOrder.childOrder.ParentOrder__c = processObj.parentOrder.Id;            
            }
        }

        insert childOrderToInsert;
        
        for(Order o : childOrderToInsert){
            System.debug('>>> order Id ' + o.Id);
        }

        for(HDT_WRP_ProcessObjects processObj : processObjList){

            for(HDT_WRP_ChildOrder childOrder : processObj.childOrderList){

                for(HDT_WRP_OrderItem orderItem : childOrder.orderItemList){
                    orderItem.orderItem.OrderId = childOrder.childOrder.Id;
                    orderItem.orderItem.Quantity = 1;
                    orderItem.orderItem.UnitPrice = 1;
                    orderItemToInsert.add(orderItem.orderItem);
                }
            
            }
            
        }

        insert orderItemToInsert;

    }

    private void mapFieldsObject(){

        product2ForAdditionalMap = new Map<String, HDT_MassiveFieldsObjectMap__mdt>();
        product2ForActivationMap = new Map<String, String>();
        mapAllFields = new Map<String, String>();
        wrpForStructureMap = new Map<String, HDT_MassiveFieldsObjectMap__mdt>();
        List<HDT_MassiveFieldsObjectMap__mdt> allFieldForThisProcess;

        sobjectMap = new Map<String, HDT_MassiveFieldsObjectMap__mdt>();
        allFieldForThisProcess = HDT_QR_ProcessPostSales.getMapFieldsObjectByDeveloperName('Sales%');

        for(HDT_MassiveFieldsObjectMap__mdt temp : allFieldForThisProcess){

            if(temp.objectType__c.equalsIgnoreCase('OrderWrapper')){

            } else {
                mapAllFields.put(temp.MasterLabel, temp.nameField__c);
            }
            sobjectMap.put(temp.MasterLabel, temp);
        }

        List<HDT_MassiveFieldsObjectMap__mdt> product2MdtList = [
            SELECT MasterLabel, labelField__c, nameField__c, objectType__c, processType__c
            FROM HDT_MassiveFieldsObjectMap__mdt 
            WHERE processType__c = 'SwitchIn'
            AND objectType__c = 'Product2'
            WITH SECURITY_ENFORCED
        ];

        for(HDT_MassiveFieldsObjectMap__mdt mdt : product2MdtList){
            if(mdt.labelField__c.equalsIgnoreCase('Attivazione')){
                product2ForActivationMap.put(mdt.MasterLabel, mdt.nameField__c);
            }

            if(mdt.labelField__c.equalsIgnoreCase('Aggiuntivi')){
                product2ForAdditionalMap.put(mdt.MasterLabel, mdt);
            }
            
        }

        List<HDT_MassiveFieldsObjectMap__mdt> structureMdtList = [
            SELECT MasterLabel, labelField__c, nameField__c, objectType__c, processType__c
            FROM HDT_MassiveFieldsObjectMap__mdt 
            WHERE processType__c = 'SwitchIn'
            AND objectType__c = 'OrderWrapper'
            WITH SECURITY_ENFORCED
        ];

        for(HDT_MassiveFieldsObjectMap__mdt mdt : structureMdtList){
            wrpForStructureMap.put(mdt.MasterLabel, mdt);
        }

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

    private HDT_WRP_ProcessObjects buildWrapperOrderStructure(HDT_WRP_ProcessObjects processObject, List<String> csvValues, HDT_UTL_ProcessSales.HDT_WRP_NextDataObj nextDataObj){

        String codiceOfferta = csvValues[mapHeaderForWrapper.get('CodiceOfferta')];
        String versione = csvValues[mapHeaderForWrapper.get('VersioneOfferta')];

        if(String.isNotEmpty(codiceOfferta) && String.isNotEmpty(versione)){
            HDT_WRP_ChildOrder wrpChildOrder = new HDT_WRP_ChildOrder();
            wrpChildOrder.orderType = 'Attivazione';
            wrpChildOrder.childOrder = new Order();
            wrpChildOrder.childOrder.AccountId = nextDataObj.accountId;
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

            // for pod or pdr
            String pod = csvValues[mapHeaderForWrapper.get('POD')];
            String pdr = csvValues[mapHeaderForWrapper.get('PDR')];
            String itemType = '';

            if(String.isNotEmpty(pod)){
                itemType = 'POD';
            } else if(String.isNotEmpty(pdr)){
                itemType = 'PDR';
            }

            wrpOrderItem = new HDT_WRP_OrderItem();
            wrpOrderItem.itemType = itemType;
            wrpOrderItem.product = new Product2();
            wrpOrderItem.product.ProductCode = itemType;
            wrpOrderItem.orderItem = new OrderItem();
            wrpChildOrder.orderItemList.add(wrpOrderItem);
            additionalProduct2.add(wrpOrderItem.product);

            processObject.childOrderList.add(wrpChildOrder);
        }

        String codiceAnalisiConsumi = csvValues[mapHeaderForWrapper.get('CodiceAnalisiConsumi')];
        String codiceBonus = csvValues[mapHeaderForWrapper.get('CodiceBonus')];
        String codicePromo = csvValues[mapHeaderForWrapper.get('CodicePromo')];
        
        Boolean enableCodiceAnalisiConsumi = (String.isNotEmpty(codiceAnalisiConsumi));
        Boolean enableCodiceBonus = (String.isNotEmpty(codiceBonus));
        Boolean enableCodicePromo = (String.isNotEmpty(codicePromo));

        if(enableCodiceAnalisiConsumi || enableCodiceBonus || enableCodicePromo){

            HDT_WRP_ChildOrder wrpChildOrder = new HDT_WRP_ChildOrder();
            wrpChildOrder.orderType = 'Aggiuntivo';
            wrpChildOrder.childOrder = new Order();
            wrpChildOrder.childOrder.AccountId = nextDataObj.accountId;
            wrpChildOrder.orderItemList = new List<HDT_WRP_OrderItem>();

            HDT_WRP_OrderItem wrpOrderItem;

            if(enableCodiceAnalisiConsumi){
                // set wrapper for "Analisi consumi"
                wrpOrderItem = new HDT_WRP_OrderItem();
                wrpOrderItem.itemType = 'analisiConsumi';
                wrpOrderItem.product = new Product2();
                wrpOrderItem.product.Name = 'Analisi Consumi';
                wrpOrderItem.product.ProductCode = codiceAnalisiConsumi;
                wrpOrderItem.orderItem = new OrderItem();
                wrpChildOrder.orderItemList.add(wrpOrderItem);
            }

            if(enableCodiceBonus){
                // set wrapper for "bonus"
                wrpOrderItem = new HDT_WRP_OrderItem();
                wrpOrderItem.itemType = 'bonus';
                wrpOrderItem.product = new Product2();
                wrpOrderItem.product.ProductCode = codiceBonus;
                wrpOrderItem.orderItem = new OrderItem();
                wrpChildOrder.orderItemList.add(wrpOrderItem);
            }

            if(enableCodicePromo){
                // set wrapper for "promo"
                wrpOrderItem = new HDT_WRP_OrderItem();
                wrpOrderItem.itemType = 'promo';
                wrpOrderItem.product = new Product2();
                wrpOrderItem.product.ProductCode = codicePromo;
                wrpOrderItem.orderItem = new OrderItem();
                wrpChildOrder.orderItemList.add(wrpOrderItem);
            }

            processObject.childOrderList.add(wrpChildOrder);

        }

        return processObject;

    }

    private class HDT_WRP_ProcessObjects {
        private Opportunity opportunity;
        private Sale__c sale;
        private SaleServiceItem__c saleServiceItem;
        private Order parentOrder;
        private List<HDT_WRP_ChildOrder> childOrderList;
        private MassiveLoaderRequestItem__c requestItem;

        private HDT_WRP_ProcessObjects(){
            opportunity = new Opportunity();
            sale = new Sale__c();
            saleServiceItem = new SaleServiceItem__c();
            parentOrder = new Order();
            childOrderList = new List<HDT_WRP_ChildOrder>();
        }

    }

    private class HDT_WRP_ChildOrder {
        private String orderType; // "Attivazione" or "Aggiunta sconti" or "Bonus VAS"
        private Order childOrder;
        private List<HDT_WRP_OrderItem> orderItemList;
    }

    private class HDT_WRP_OrderItem {
        private String itemType;//"Offerta commerciale", "POD", PDR", "Bonus", "VAS"
        private OrderItem orderItem;
        private Product2 product;
    }

}