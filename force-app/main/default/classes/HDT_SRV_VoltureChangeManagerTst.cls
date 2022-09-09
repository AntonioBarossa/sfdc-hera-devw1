/**@frpanico 12/10/2021
 * Test Class for the class HDT_SRV_VoltureChangeManager
 */
@IsTest
public with sharing class HDT_SRV_VoltureChangeManagerTst {
    
    /**@frpanico 12/10/2021
     * Covers only one test case to achieve target coverage
     */

    private static HDT_SRV_VoltureChangeManager voltureManager = new HDT_SRV_VoltureChangeManager();
    private static HDT_QR_VoltureChangeManager voltureChangeQr = new HDT_QR_VoltureChangeManager();

    @TestSetup
    static void setup()
    {
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        HDT_UTL_DataFactoryTst.pClickCasePhase();//

        List<wrts_prcgvr__ActivityTemplate__c> templates =  HDT_UTL_DataFactoryTst.createActivityTemplate(1, false);
        templates[0].Name = 'Valori non corrispondenti';
        templates[0].wrts_prcgvr__ObjectType__c = 'Order';
        insert templates;

        //Create 1 order one for the parent and one for the child 1
        //Create 2 OrderItems (to test loop with more than one item)
        List<Account> accList=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'D1 - Persona fisica', 'Enti');
		List<Sale__c> saleList=HDT_UTL_DataFactoryTst.createSale(1, true, accList[0].Id, 'Attiva');
		List<Order> orderList=HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].Id, 'Bozza');
        List<Contract> contractList=HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].Id);//
        List<BillingProfile__c> billingProfileList = HDT_UTL_DataFactoryTst.createBillingProfile(1, true, accList[0].Id);//
        List<ServicePoint__c> spList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList=HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);  
        spList[0].CommoditySector__c = 'Energia Elettrica';
        update spList;

        orderList[0].Commodity__c = 'Energia Elettrica';
        update orderList;
		
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
        
        childOrderList[0].AccountId = accList[0].Id;
        childOrderList[0].Contact__c = contactList[0].Id;
        childOrderList[0].ContractReference__c = contractList[0].Id;
        childOrderList[0].CreatorGroup__c = 'HCM_BACK';
        childOrderList[0].PhoneNumber__c = '1112233444';
        childOrderList[0].Channel__c = 'Agenzie';
        childOrderList[0].ServicePoint__c = spList[0].Id;
        childOrderList[0].LoginWorkstation__c = 'CC_LT_Staff';
        //childOrderList[0].Email__c = 'assistenza@servizioclienti.com';
        childOrderList[0].BillingProfile__c = billingProfileList[0].Id;
        childOrderList[0].ServicePointCode__c = 'IT001E00032928';
        childOrderList[0].SapContractCode__c = '3001002003';
        childOrderList[0].Commodity__c = 'Energia Elettrica';
        childOrderList[0].EffectiveDate__c = Date.newInstance(2022, 3, 1);
        childOrderList[0].CustomerCategory__c = 'Famiglie';
        
        update childOrderList;
        orderItemList = HDT_UTL_DataFactoryTst.createOrderItem(2, true, childOrderList[0].Id, spList[0].Id,productList[0].Id,pbEntry.Id);
        

        List<wrts_prcgvr__ActivityTemplate__c> myActTemp = HDT_UTL_DataFactoryTst.createActivityTemplate(1, false);
        myActTemp[0].Name = 'Controlli Ammissibilità';
        insert myActTemp;


        String recordTypeNameVolturaConSwitch = 'HDT_RT_VolturaConSwitch';
        String recordTypeIdVolturaConSwitch = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get(recordTypeNameVolturaConSwitch).getRecordTypeId();

        String recordTypeNameVolturaTecnica = 'HDT_RT_VolturaTecnica';
        String recordTypeIdVolturaTecnica = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(recordTypeNameVolturaTecnica).getRecordTypeId();

        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Comunicazione verso Heroku', 'Bozza', recordTypeIdVolturaConSwitch, recordTypeNameVolturaConSwitch,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'In attesa Data Decorrenza', 'Bozza', recordTypeIdVolturaTecnica, recordTypeNameVolturaTecnica,'A','','','');//

    }

    @IsTest
    static void cloneOrderAndUpdateTst()
    {
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
        Email__c 
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
        List<Order> orderList = [SELECT Id, 
        ParentOrder__c,
        Name,
        TecnicalPhase__c,
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
        SupplyStreetName__c,
        SupplyStreetNumber__c,
        SupplyPostalCode__c,
        SupplyCity__c,
        SupplyState__c,
        SupplyCountry__c
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
        wrts_prcgvr.MRR_1_0.Field bodyField1 = new wrts_prcgvr.MRR_1_0.Field();
        
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
        
        bodyField1.fieldType = 'TEXT';
        bodyField1.name = 'result';
        bodyField1.value = 'OK';

        bodyFields.add(bodyField);
		bodyFields.add(bodyField1);
        
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
        System.debug('@@@ ' + orderList + '### ' + responseMrr);
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
        orderList[0].SupplyStreetName__c = 'A';
        orderList[0].SupplyStreetNumber__c = 'B';
        orderList[0].SupplyPostalCode__c = 'C';
        orderList[0].SupplyCityCode__c = 'D';
        orderList[0].SupplyCity__c = 'E';
        orderList[0].SupplyState__c = 'F';
        orderList[0].SupplyCountry__c = 'G';
        

        Map<String,Object> paramsMap = new Map<String,Object>
        {
            'TENSIONE' => HDT_UTL_VoltureChangeUtilities.mtLimit,
            'POTDISP' => HDT_UTL_VoltureChangeUtilities.lowerThreshold,
            'POTCONTRIMP' => HDT_UTL_VoltureChangeUtilities.lowerThreshold,
            'VIA' => 'A',
            'CIV' => 'B',
            'CAP' => 'C',
            'ISTAT' => 'D',
            'LOCALITA' => 'E',
            'PROV' => 'F',
            'NAZIONE' => 'G'
        };

        Test.startTest();
        voltureManager.handleAmmissibilityCheck(paramsMap, orderList[0]);
        Test.stopTest();

        List<wrts_prcgvr__Activity__c> activities = [SELECT Id FROM wrts_prcgvr__Activity__c WHERE Order__c = :orderList[0].Id];

        System.assertEquals(1, activities.size(),'Activity non creata');
    }

    @IsTest
    static void handleAmmissibilityCheckActivityCreationTst()
    {
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
        orderList[0].SupplyStreetName__c = 'A';
        orderList[0].SupplyStreetNumber__c = 'B';
        orderList[0].SupplyPostalCode__c = 'C';
        orderList[0].SupplyCityCode__c = 'D';
        orderList[0].SupplyCity__c = 'E';
        orderList[0].SupplyState__c = 'F';
        orderList[0].SupplyCountry__c = 'G';

        Map<String,Object> paramsMap = new Map<String,Object>
        {
            'TENSIONE' => HDT_UTL_VoltureChangeUtilities.mtLimit,
            'POTDISP' => HDT_UTL_VoltureChangeUtilities.higherThreshold,
            'POTCONTRIMP' => HDT_UTL_VoltureChangeUtilities.higherThreshold,
            'VIA' => 'A',
            'CIV' => 'B',
            'CAP' => 'C',
            'ISTAT' => 'D',
            'LOCALITA' => 'E',
            'PROV' => 'F',
            'NAZIONE' => 'G'
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
        System.debug('@@@@' + orderList);
        Test.stopTest();

        List<Order> orderListUpdated = [SELECT Id,Phase__c FROM Order WHERE Id = :orderList[0].Id];
        System.debug('@@@@' + orderListUpdated);

        System.assertEquals(HDT_SRV_VoltureChangeManager.publishUpdatePhase, orderListUpdated[0].Phase__c,'Fase non correttamente aggiornata');
    }

    @IsTest
    static void handleResponseDataEnrichmentTst()
    {
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
        PowerCommitted__c,
        CommodityFormula__c
        FROM Order WHERE ParentOrder__c != null];

        List<HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni> posizioni = new  List<HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni>();
        HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni posImposte = new HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni();
        HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni posAteco = new HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni();
        HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni posAddReg = new HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni();
        HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni posAnnCons = new HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni();
        posImposte.campo = 'IMPOSTE';
        posImposte.valore = 'E_IMPOST';
        posAteco.campo = 'CODICE_ATECO';
        posAteco.valore = '9999';
        posAddReg.campo = 'ADDIZIONALEREGIONALE';
        posAddReg.valore = '0.34';
        posAnnCons.campo = 'CONSUMOANNUOEE';
        posAnnCons.valore = '1000';
        posizioni.add(posImposte);
        posizioni.add(posAteco);
        posizioni.add(posAddReg);
        posizioni.add(posAnnCons);


        Map<String,List<Object>> inputMap = new Map<String,List<Object>>
        {
            'posizioni' => posizioni,
            'sobjList' => orderList
        };

        Test.startTest();
        orderList = voltureManager.handleResponseDataEnrichment(inputMap);
        Test.stopTest();

        System.assertEquals(0.34, orderList[0].RegionalAdditional__c, 'Arricchimento fallito');
        System.assertEquals('9999', orderList[0].AtecoCode__c, 'Arricchimento fallito');
        System.assertEquals('Imposta usi domestici', orderList[0].ExciseEle__c, 'Arricchimento fallito');
        System.assertEquals(1000, orderList[0].AnnualConsumption__c, 'Arricchimento fallito');
    }

    @IsTest
    static void testcreateCaseFromOrder()
    {
        List<Order> orderList = [SELECT Id, Phase__c, AccountId, CompanyOwner__c, Contact__c, BillingProfile__c, ContractReference__c,
                                 CreatorGroup__c, PhoneNumber__c, Channel__c, ServicePoint__c, LoginWorkstation__c, Email__c, ServicePointCode__c, 
                                 SapContractCode__c, Commodity__c, EffectiveDate__c, FlagServizio26__c, SupplyCity__c, SupplyCityCode__c,SupplyState__c, SupplyCountry__c, SupplyPostalCode__c,
                                 SupplyStreetName__c,SupplyStreetNumber__c, BillingCity__c,BillingCityCode__c,BillingCountry__c, BillingPostalCode__c, BillingProvince__c,
                                 BillingStreetName__c, ResidentialCity__c, ResidentialCityCode__c, ResidentialCountry__c, ResidentialPostalCode__c,ResidentialState__c,
                                 ResidentialStreet__c, ResidentialStreetName__c, SalesCompany__c, SalesCompanyCode__c, DistributorCode__c, ExciseGAS__c, VAT__c,
                                 Resident__c, Market__c, SupplyType__c, AnnualConsumption__c, Caliber__c,WithdrawalClass__c,EnergyService__c,UseCategory__c
        FROM Order 
        WHERE ParentOrder__c != null
        AND ProcessType__c = 'Switch in Ele'];
        
        String recordTypeNameVolturaConSwitch = 'HDT_RT_VolturaConSwitch';
        String recordTypeIdVolturaConSwitch = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get(recordTypeNameVolturaConSwitch).getRecordTypeId();
        orderList[0].RecordTypeId = recordTypeIdVolturaConSwitch;
        update orderList;

        Test.setMock(HttpCalloutMock.class, new HDT_UTL_TestMockVolturaTecnica());
        
        Test.startTest();
        voltureManager.createCaseFromOrder(orderList[0]);
        Test.stopTest();

        List<Case> caseListUpdated = [Select Id,Phase__c, Order__c FROM Case WHERE Order__c = :orderList[0].Id];

        System.assertEquals(HDT_SRV_VoltureChangeManager.volturaTecnicaPhase, caseListUpdated[0].Phase__c,'Fase non correttamente aggiornata');
    }

    @isTest
    static void calloutVoltureTst()
    {
        List<Order> childOrder = [SELECT Id, ParentOrder__r.OrderNumber, OrderNumber, ServicePointCode__c, SapContractCode__c,HerokuPracticeCode__c,DocumentalProcessType__c FROM Order WHERE ParentOrder__c != NULL];
        Test.setMock(HttpCalloutMock.class, new HDT_UTL_TestMockBloccoVoltura());
        Test.startTest();
            String result = HDT_SRV_VoltureChangeManager.calloutVolture(childOrder[0], 'B0');
        Test.stopTest();
        System.assertEquals(true, String.isNotBlank(result), 'test callout volture fallito');
    }

    public class HDT_UTL_TestMockVolturaTecnica implements HTTPCalloutMock{

        public HTTPResponse respond(HTTPRequest request){

            HttpResponse response = new HttpResponse();
            String bodyResponse;
            Integer statusCode;

            bodyResponse = '{"status": "success","correlationId": "2a0c1340-f6b5-11eb-bb88-068530f44c42","timestamp": "2021-08-06T14:52:33",'
            +'"data": {"testata": {"esito": "OK"},"posizioni": ['
            +'{"campo": "DATACESSAZIONE","valore": "99991231"},'
            +'{"campo": "ALIQUOTAIVA","valore": "01"},'
            +'{"campo": "CA","valore": "200008867681"},'
            +'{"campo": "DESCRFATTURAZCOLL","valore": "Il contratto può essere fatturato con altri contratti"},'
            +'{"campo": "ANNOFABBRCONT","valore": "2000"},'
            +'{"campo": "CALIBRO1","valore": "GRT003"},'
            +'{"campo": "PRESENZACORRETTORE","valore": "NO"},'
            +'{"campo": "OPZIONE","valore": "E_UD_TDR"},'
            +'{"campo": "MOTIVOBLOCCOCALCOLO","valore": "T1"},'
            +'{"campo": "ACCISE","valore": "0.02270000"},'
            +'{"campo": "CODICE_ATECO","valore": "999999"}'
            +']}}';
            statusCode = 200;

            response.setHeader('Content-Type', 'application/json');
            response.setBody(bodyResponse);
            response.setStatusCode(statusCode);
            response.setStatus('OK');
            return response;
        }
    }
    public class HDT_UTL_TestMockBloccoVoltura implements HttpCalloutMock
    {
        public HTTPResponse respond(HTTPRequest request){

            HttpResponse response = new HttpResponse();
            String bodyResponse;
            Integer statusCode;

            bodyResponse = '{"status": "success","correlationId": "f4e2fdd0-f7b9-11ec-bb2a-069652b1ba9e","timestamp": "2022-06-29T16:44:20","prestazione": {"rds": "O-00000804","rdo": "O-00000803","pod": "10110000280279","contratto": "3019583323","tipoAttivita": "Blocco inserito","note": "Blocco richiesto L8 ma il contratto 3019583323 risulta già bloccato"}}';
            statusCode = 200;

            response.setHeader('Content-Type', 'application/json');
            response.setBody(bodyResponse);
            response.setStatusCode(statusCode);
            response.setStatus('OK');
            return response;
        }
    }

}