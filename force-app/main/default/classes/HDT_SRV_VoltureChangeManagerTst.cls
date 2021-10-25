/**@frpanico 12/10/2021
 * Test Class for the class HDT_SRV_VoltureChangeManager
 */
@IsTest
public with sharing class HDT_SRV_VoltureChangeManagerTst {
    
    /**@frpanico 12/10/2021
     * Covers only one test case to achieve target coverage
     */

    @TestSetup
    static void setup()
    {
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        //Create 1 order one for the parent and one for the child 1
        //Create 2 OrderItems (to test loop with more than one item)
        List<Account> accList=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'D1 - Persona fisica', 'Enti');
		List<Sale__c> saleList=HDT_UTL_DataFactoryTst.createSale(1, true, accList[0].Id, 'Attiva');
		List<Order> orderList=HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].Id, 'Bozza');
        List<ServicePoint__c> spList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList=HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);  
        spList[0].CommoditySector__c = 'Energia Elettrica';
        update spList;
		
        List<OrderItem> orderItemList = new List<OrderItem>();
        List<Order> childOrderList = HDT_UTL_DataFactoryTst.createChildOrder(1, true, accList[0].Id, saleList, orderList[0].Id, contactList[0].Id);
        List<Product2> productList = HDT_UTL_DataFactoryTst.createProduct2(1, true);
        //List<Pricebook2> priceBookList = HDT_UTL_DataFactoryTst.createPricebook(1, true);
        Id priceBookId = Test.getStandardPriceBookId();
        PricebookEntry pbEntry = new PriceBookEntry(Pricebook2Id = priceBookId, Product2Id = productList[0].Id, UnitPrice = 10000, IsActive = true);
        insert pbEntry;
        //List<PricebookEntry> priceBookEntryList = HDT_UTL_DataFactoryTst.createPricebookEntry(productList, true, priceBookList[0].Id);
        childOrderList[0].Pricebook2Id = priceBookId;
        childOrderList[0].ProcessType__c = 'Switch in Ele';
        update childOrderList;
        orderItemList = HDT_UTL_DataFactoryTst.createOrderItem(2, true, childOrderList[0].Id, spList[0].Id,productList[0].Id,pbEntry.Id);
        
        String recordTypeNameVolturaConSwitch = 'HDT_RT_VolturaConSwitch';
        String recordTypeIdVolturaConSwitch = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get(recordTypeNameVolturaConSwitch).getRecordTypeId();

        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Comunicazione verso Heroku', 'Bozza', recordTypeIdVolturaConSwitch, recordTypeNameVolturaConSwitch,'A','','','');
    }

    @IsTest
    static void cloneOrderAndUpdateTst()
    {
        HDT_SRV_VoltureChangeManager voltureManager = new HDT_SRV_VoltureChangeManager();
        HDT_QR_VoltureChangeManager voltureChangeQr = new HDT_QR_VoltureChangeManager();

        List<Order> orderList = [SELECT Id, 
        ParentOrder__c,
        Name,
        EffectiveDate,
        EffectiveDate__c,
        RecessNotice__c,
        AccountId,
        EstimateAmount__c,
        PowerQuote__c,
        AdministrativeBurden__c,
        EstimatedVAT__c,
        ValidityDateEstimate__c,
        CIAccoutn__c,
        QuickQuote__c,
        ChamberCommerceRegistration__c,
        Instance326__c,
        DocumentLow80__c,
        ContractSigned__c,
        SignedDate__c,
        SignatureMethod__c,
        DocSendingMethod__c,
        Sale__c,
        Pricebook2Id,
        Contact__c 
        FROM Order WHERE ParentOrder__c != null];
        List<OrderItem> orderItemList = voltureChangeQr.getOrderItemByOrderId(orderList[0].Id);

        System.assertEquals(1, orderList.size(),'Order non trovato');
        System.assertEquals(2, orderItemList.size(),'OrderItmes non trovati');

        Test.startTest();
        voltureManager.cloneOrderAndUpdate(orderList[0]);
        Test.stopTest();

        List<Order> newOrderList = [SELECT Id, ParentOrder__c, Phase__c FROM Order WHERE (ProcessType__c = 'Voltura con Switch' OR Phase__c = 'Annullato') AND ParentOrder__c != NULL];
        List<OrderItem> newOrderItemList = [SELECT Id FROM OrderItem];
        System.assertEquals(2, newOrderList.size(),'Order non trovati');
        System.Assert(orderList[0].ParentOrder__c == newOrderList[0].ParentOrder__c, 'Parent order non associato correttamente');
        System.Assert(orderList[0].ParentOrder__c == newOrderList[1].ParentOrder__c, 'Parent order non associato correttamente');
        System.assertEquals(4, newOrderItemList.size(),'OrderItem non correttamente clonati');
        System.assert(newOrderList[0].Phase__c == 'Annullato' || newOrderList[0].Phase__c == 'Comunicazione verso Heroku', 'Fase non aggiornata correttamente');
        System.assert(newOrderList[1].Phase__c == 'Annullato' || newOrderList[1].Phase__c == 'Comunicazione verso Heroku', 'Fase non aggiornata correttamente');

    }

    @IsTest
    static void handleResponseTst()
    {
        HDT_SRV_VoltureChangeManager voltureManager = new HDT_SRV_VoltureChangeManager();

        List<Order> orderList = [SELECT Id, 
        ParentOrder__c,
        Name,
        EffectiveDate,
        EffectiveDate__c,
        RecessNotice__c,
        AccountId,
        EstimateAmount__c,
        PowerQuote__c,
        AdministrativeBurden__c,
        EstimatedVAT__c,
        ValidityDateEstimate__c,
        CIAccoutn__c,
        QuickQuote__c,
        ChamberCommerceRegistration__c,
        Instance326__c,
        DocumentLow80__c,
        ContractSigned__c,
        SignedDate__c,
        SignatureMethod__c,
        DocSendingMethod__c,
        Sale__c,
        Pricebook2Id,
        Contact__c 
        FROM Order WHERE ParentOrder__c != null];

        wrts_prcgvr.MRR_1_0.MultiResponse responseMrr= new wrts_prcgvr.MRR_1_0.MultiResponse();
        List<wrts_prcgvr.MRR_1_0.Response> responses = new List<wrts_prcgvr.MRR_1_0.Response>();
        wrts_prcgvr.MRR_1_0.Response singleResponse = new wrts_prcgvr.MRR_1_0.Response();
        wrts_prcgvr.MRR_1_0.Header header = new wrts_prcgvr.MRR_1_0.Header();
        List<wrts_prcgvr.MRR_1_0.WObject> objects = new List<wrts_prcgvr.MRR_1_0.WObject>();
        List<wrts_prcgvr.MRR_1_0.WObject> otherObjects = new List<wrts_prcgvr.MRR_1_0.WObject>();
        wrts_prcgvr.MRR_1_0.WObject singleObject = new wrts_prcgvr.MRR_1_0.WObject();
        List<wrts_prcgvr.MRR_1_0.Field> headerFields = new List<wrts_prcgvr.MRR_1_0.Field>();
        wrts_prcgvr.MRR_1_0.Field headerField = new wrts_prcgvr.MRR_1_0.Field();
        List<wrts_prcgvr.MRR_1_0.Field> bodyFields = new List<wrts_prcgvr.MRR_1_0.Field>();
        wrts_prcgvr.MRR_1_0.Field bodyField = new wrts_prcgvr.MRR_1_0.Field();    
        
        headerField.fieldType = 'TEXT';
        headerField.name = 'requestType';
        headerField.value = 'CREA_RIC';
        headerFields.add(headerField);

        header.fields = headerFields;
        header.requestId = 'asiojadisdj';
        header.requestTimestamp = '120-39123';
        header.requestType = 'asjdioajsdoi';

        bodyField.fieldType = 'TEXT';
        bodyField.name = 'FASE';
        bodyField.value = 'Comunicazione verso Heroku';

        bodyFields.add(bodyField);

        singleObject.fields = bodyFields;
        singleObject.id = 'ajsidj';
        singleObject.name = 'objName';
        singleObject.objects = otherObjects;
        singleObject.objectType = 'objType';

        objects.add(singleObject);

        singleResponse.code = 'code';
        singleResponse.description = 'description';
        singleResponse.header = header;
        singleResponse.objects = objects;

        responses.add(singleResponse);

        responseMrr.responses = responses;

        Test.startTest();
        voltureManager.handleResponse(responseMrr, orderList[0]);
        Test.stopTest();

        List<Order> orderListUpdate = [SELECT Id, TecnicalPhase__c FROM Order WHERE Id = :orderList[0].Id];

        System.assertEquals('Comunicazione verso Heroku', orderListUpdate[0].TecnicalPhase__c, 'Fase non aggiornata correttamente');
    }

    @IsTest
    static void handleAmmissibilityCheckTst()
    {
        HDT_SRV_VoltureChangeManager voltureManager = new HDT_SRV_VoltureChangeManager();

        List<Order> orderList = [SELECT Id, 
        ParentOrder__c,
        Name,
        EffectiveDate,
        EffectiveDate__c,
        RecessNotice__c,
        AccountId,
        EstimateAmount__c,
        PowerQuote__c,
        AdministrativeBurden__c,
        EstimatedVAT__c,
        ValidityDateEstimate__c,
        CIAccoutn__c,
        QuickQuote__c,
        ChamberCommerceRegistration__c,
        Instance326__c,
        DocumentLow80__c,
        ContractSigned__c,
        SignedDate__c,
        SignatureMethod__c,
        DocSendingMethod__c,
        Sale__c,
        Pricebook2Id,
        Contact__c,
        VoltageLevel__c,
        PowerAvailable__c,
        PowerCommitted__c
        FROM Order WHERE ParentOrder__c != null];

        orderList[0].VoltageLevel__c = 'MT';
        orderList[0].PowerAvailable__c = HDT_UTL_VoltureChangeUtilities.lowerThreshold;
        orderList[0].PowerCommitted__c = HDT_UTL_VoltureChangeUtilities.lowerThreshold;
        

        Map<String,Object> paramsMap = new Map<String,Object>
        {
            'TENSIONE' => HDT_UTL_VoltureChangeUtilities.mtLimit,
            'POTDISP' => HDT_UTL_VoltureChangeUtilities.lowerThreshold,
            'POTCONTRIMP' => HDT_UTL_VoltureChangeUtilities.lowerThreshold
        };

        Test.startTest();
        voltureManager.handleAmmissibilityCheck(paramsMap, orderList[0]);
        Test.stopTest();

        List<wrts_prcgvr__Activity__c> activities = [SELECT Id FROM wrts_prcgvr__Activity__c WHERE Order__c = :orderList[0].Id];

        System.assertEquals(0, activities.size(),'Activity create incorrettamente');
    }

    @IsTest
    static void handleAmmissibilityCheckActivityCreationTst()
    {
        HDT_SRV_VoltureChangeManager voltureManager = new HDT_SRV_VoltureChangeManager();

        List<Order> orderList = [SELECT Id, 
        ParentOrder__c,
        Name,
        EffectiveDate,
        EffectiveDate__c,
        RecessNotice__c,
        AccountId,
        EstimateAmount__c,
        PowerQuote__c,
        AdministrativeBurden__c,
        EstimatedVAT__c,
        ValidityDateEstimate__c,
        CIAccoutn__c,
        QuickQuote__c,
        ChamberCommerceRegistration__c,
        Instance326__c,
        DocumentLow80__c,
        ContractSigned__c,
        SignedDate__c,
        SignatureMethod__c,
        DocSendingMethod__c,
        Sale__c,
        Pricebook2Id,
        Contact__c,
        VoltageLevel__c,
        PowerAvailable__c,
        PowerCommitted__c
        FROM Order WHERE ParentOrder__c != null];

        orderList[0].VoltageLevel__c = 'MT';
        orderList[0].PowerAvailable__c = HDT_UTL_VoltureChangeUtilities.lowerThreshold;
        orderList[0].PowerCommitted__c = HDT_UTL_VoltureChangeUtilities.lowerThreshold;
        

        Map<String,Object> paramsMap = new Map<String,Object>
        {
            'TENSIONE' => HDT_UTL_VoltureChangeUtilities.mtLimit,
            'POTDISP' => HDT_UTL_VoltureChangeUtilities.higherThreshold,
            'POTCONTRIMP' => HDT_UTL_VoltureChangeUtilities.higherThreshold
        };

        Test.startTest();
        voltureManager.handleAmmissibilityCheck(paramsMap, orderList[0]);
        Test.stopTest();

        List<wrts_prcgvr__Activity__c> activities = [SELECT Id FROM wrts_prcgvr__Activity__c WHERE Order__c = :orderList[0].Id];

        System.assertEquals(1, activities.size(),'Activity non create incorrettamente');
    }

    @IsTest
    static void handlePublishUpdateTst()
    {
        HDT_SRV_VoltureChangeManager voltureManager = new HDT_SRV_VoltureChangeManager();

        List<Order> orderList = [SELECT Id, Phase__c FROM Order WHERE ParentOrder__c != null];
        String recordTypeNameVolturaConSwitch = 'HDT_RT_VolturaConSwitch';
        String recordTypeIdVolturaConSwitch = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get(recordTypeNameVolturaConSwitch).getRecordTypeId();
        orderList[0].RecordTypeId = recordTypeIdVolturaConSwitch;
        update orderList;
        
        Test.startTest();
        voltureManager.handlePublishUpdate(orderList[0]);
        Test.stopTest();

        List<Order> orderListUpdated = [Select Id,Phase__c FROM Order WHERE Id = :orderList[0].Id];

        System.assertEquals(HDT_SRV_VoltureChangeManager.publishUpdatePhase, orderListUpdated[0].Phase__c,'Fase non correttamente aggiornata');
    }

}
