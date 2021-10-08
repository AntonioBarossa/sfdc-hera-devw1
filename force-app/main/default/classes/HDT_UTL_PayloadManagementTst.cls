@isTest
public with sharing class HDT_UTL_PayloadManagementTst {
    
    //DEBUG
    public static final String TEST_NAME = 'HDT_UTL_PayloadManagementTst';
    
    //DATA
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    
    
    //TEST SETUP
    private static void mySetup(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - mySetup';
        
        //ACCOUNT - BUSINESS
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        
        //ACCOUNT - PARTNER
        List<Account> partnerList = HDT_UTL_DataFactoryTst.createAccountPartner(1, false, 'DIRETTO EDISON-10R0000051');
        partnerList[0].CompanyOwner__c = 'HERA COMM';
        insert partnerList;
        
        //SERVICE POINT
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, false);
        ServicePoint__c servPoint = servPointList[0];
        servPoint.Distributor__c = partnerList[0].Id;
        servPoint.CommoditySector__c = 'Gas';
        insert servPoint;
        
        
        //SALE
        List<Sale__c> saleList = HDT_UTL_DataFactoryTst.createSale(1, true, accList[0].Id, 'Bozza');
        
        //PRODUCT
        List<Product2> productList = HDT_UTL_DataFactoryTst.createProduct2(1, false);
        productList[0].Name = 'POD';
        productList[0].Family = 'VAS Fatturabili';
        insert productList;
        
        //PRICE BOOK
        Id pricebookId=Test.getStandardPricebookId();
		List<PricebookEntry> pricebookEntry=HDT_UTL_DataFactoryTst.createPricebookEntry(productList, true, pricebookId);
        
        //ORDER
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        List<Order> orderList = HDT_UTL_DataFactoryTst.createOrderWithPricebook(1, false, accList[0].Id, saleList, pricebookId);
        orderList[0].ServicePoint__c = servPoint.Id;
        insert orderList;
        
        
        //ORDER ITEMS
        List<OrderItem> orderItems = HDT_UTL_DataFactoryTst.createOrderItem(1, true, orderList[0].Id, servPointList[0].Id, productList[0].Id, pricebookEntry[0].Id);
        System.debug(debugString + ' - orderItems: ' + orderItems);
        
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, orderList[0].id);
    }

    
    //TESTS
    
    //execute - TESTATO VIA IMPIEGO DI ALTRI METODI
    
    
    //handleAmountVas
    @isTest
    private static void handleAmountVasTest(){
        
        //SETUP
        mySetup();
        
        OrderItem myItem = [SELECT Id, UnitPrice, PriceNetDiscounted__c, Quantity FROM OrderItem];
        List<SObject> itemVasList = new List<SObject>();
        itemVasList.add(myItem);
        
        Map<String,List<SObject>> inputs = new Map<String,List<SObject>>();
        inputs.put('ItemVAS', itemVasList);

        
        Map<String,Object> formParams = new Map<String,Object>();
        
        
        //TESTING objectString (ItemVAS not null)
        HDT_UTL_PayloadManagement myObjectToTest = new HDT_UTL_PayloadManagement();
        String result1 = myObjectToTest.execute('handleAmountVas', inputs, formParams);
        
        //ASSERTS
        System.debug('result1: ' + result1);
        System.assert(!'||'.equalsIgnoreCase(result1), 'Result identico.');
        
        
        //TESTING objectString (ItemVAS equals null)
        inputs.put('ItemVAS', null);
        String result2 = myObjectToTest.execute('handleAmountVas', inputs, formParams);
        
        //ASSERTS
        System.debug('result2: ' + result2);
        System.assert('||'.equalsIgnoreCase(result2), 'Result non è identico.');
        
        
    }
    
    
    
    //handleFlagDeliveryAddress
    @isTest
    private static void handleFlagDeliveryAddressTest(){
        
        //SETUP
        mySetup();
        
        Order myItem = [SELECT Id, ContractId, ResidentialStreetName__c, ShippingStreetName__c, SupplyStreetName__c FROM Order];
        List<SObject> itemVasList = new List<SObject>();
        itemVasList.add(myItem);
        itemVasList.add(myItem);//INDICE 1 - TODO: AGGIORNARE TEST NEL CASO SI PRESENTINO PROBLEMATICHE O AGGIORNAMENTI AL PUNTAMENTO INDICE HARDCODED
        
        Map<String,List<SObject>> inputs = new Map<String,List<SObject>>();
        inputs.put('Order', itemVasList);
        
        
        Map<String,Object> formParams = new Map<String,Object>();
        formParams.put('Contesto', 'Order');
        
        //TESTING Regular
        HDT_UTL_PayloadManagement myObjectToTest = new HDT_UTL_PayloadManagement();
        String result1 = myObjectToTest.execute('handleFlagDeliveryAddress', inputs, formParams);
        
        //ASSERTS
        System.debug('result1: ' + result1);
        System.assert('IF'.equalsIgnoreCase(result1), 'Risultato non è IF');
        
        //TODO: TESTARE CASO NON "IF". Attualmente non possibile.
        
        //TESTING Blank Contract Id
        Contract con = [SELECT Id FROM Contract];
        myItem.ContractId = con.Id;
        String result2 = myObjectToTest.execute('handleFlagDeliveryAddress', inputs, formParams);
        
        //ASSERTS
        System.debug('result2: ' + result2);
        System.assert(''.equalsIgnoreCase(result2), 'Risultato non è stringa vuota.');
        
        
        
        //TESTING context Not Order
        formParams.put('Contesto', 'Fake');
        String result3 = myObjectToTest.execute('handleFlagDeliveryAddress', inputs, formParams);
        
        //ASSERTS
        System.debug('result3: ' + result3);
        System.assert(''.equalsIgnoreCase(result3), 'Risultato non è stringa vuota.');
        
    }
    
    
    
    //handleFlagPaperless
    @isTest
    private static void handleFlagPaperlessTest(){
        
        //SETUP
        mySetup();
        
        Case myItem = [SELECT Id, Type, DepositPaymentMode__c FROM Case];
        List<SObject> itemVasList = new List<SObject>();
        itemVasList.add(myItem);
        
        Map<String,List<SObject>> inputs = new Map<String,List<SObject>>();
        inputs.put('Case', itemVasList);
        
        
        Map<String,Object> formParams = new Map<String,Object>();
        formParams.put('Contesto', 'Case');
        
        //TESTING Context Case - Not Paperless
        HDT_UTL_PayloadManagement myObjectToTest = new HDT_UTL_PayloadManagement();
        String result1 = myObjectToTest.execute('handleFlagPaperless', inputs, formParams);
        
        //ASSERTS
        System.debug('result1: ' + result1);
        System.assert('N'.equalsIgnoreCase(result1), 'Risultato non è N');
        
        
        
        //TESTING Context Case - Not Paperless
        myItem.Type = 'Paperless';
        String result2 = myObjectToTest.execute('handleFlagPaperless', inputs, formParams);
        
        //ASSERTS
        System.debug('result2: ' + result2);
        System.assert('Y'.equalsIgnoreCase(result2), 'Risultato non è Y');
        
        
        
        //TESTING Blank Type
        myItem.Type = '';
        String result3 = myObjectToTest.execute('handleFlagPaperless', inputs, formParams);
        
        //ASSERTS
        System.debug('result3: ' + result3);
        System.assert('N'.equalsIgnoreCase(result3), 'Risultato non è N');
        
        
        
        //TESTING Context Not Case
        formParams.put('Contesto', 'Fake');
        String result4 = myObjectToTest.execute('handleFlagPaperless', inputs, formParams);
        
        //ASSERTS
        System.debug('result4: ' + result4);
        System.assert('N'.equalsIgnoreCase(result4), 'Risultato non è N');
        
    }
    
    
    
    //calculateCompanyCode
    ///Order
    @isTest
    private static void calculateCompanyCodeTest_Order(){
        
        //SETUP
        mySetup();
        
        Order myItem = [SELECT Id, SalesCompany__c, SupplyCity__c, DistributorFormula__c, CommodityFormula__c FROM Order];
        myItem.SupplyCity__c = 'COLBORDOLO';
        
        List<SObject> itemVasList = new List<SObject>();
        itemVasList.add(myItem);
        
        Map<String,List<SObject>> inputs = new Map<String,List<SObject>>();
        inputs.put('Order', itemVasList);
        
        
        Map<String,Object> formParams = new Map<String,Object>();
        formParams.put('Contesto', 'Order');
        
        //TESTING Context Order
        HDT_UTL_PayloadManagement myObjectToTest = new HDT_UTL_PayloadManagement();
        String result1 = myObjectToTest.execute('calculateCompanyCode', inputs, formParams);//'Hera Comm S.p.A.'
        
        //RETRIEVING DATA
        HDT_HeraCompany__mdt myData = [SELECT CompanyCode__c from HDT_HeraCompany__mdt WHERE Label=:'Hera Comm S.p.A.'];
        
        //ASSERTS
        System.debug('result1: ' + result1);
        System.assert(myData.CompanyCode__c.equalsIgnoreCase(result1), 'Risultato non è ' + myData.CompanyCode__c);
    }
    
    
    ///Case
    @isTest
    private static void calculateCompanyCodeTest_Case(){
        
        //SETUP
        mySetup();
        
        Case myItem = [SELECT Id, SalesCompany__c, SupplyCity__c, DistributorName__c, CommodityFormula__c FROM Case];
        
        List<SObject> itemVasList = new List<SObject>();
        itemVasList.add(myItem);
        
        Map<String,List<SObject>> inputs = new Map<String,List<SObject>>();
        inputs.put('Case', itemVasList);
        
        
        Map<String,Object> formParams = new Map<String,Object>();
        formParams.put('Contesto', 'Case');
        
        //TESTING Context Case
        HDT_UTL_PayloadManagement myObjectToTest = new HDT_UTL_PayloadManagement();
        String result1 = myObjectToTest.execute('calculateCompanyCode', inputs, formParams);
        
        //ASSERTS
        System.debug('result1: ' + result1);
        System.assert(''.equalsIgnoreCase(result1), 'Risultato non è stringa vuota');
        
    }
    
    
    
    ///Account
    @isTest
    private static void calculateCompanyCodeTest_Account(){
        
        //SETUP
        mySetup();
        
        Account myItem = [SELECT Id, CompanyOwner__c FROM Account WHERE RecordTypeId = :constants.ACCOUNT_RECORDTYPEID_BUSINESS];
        
        List<SObject> itemVasList = new List<SObject>();
        itemVasList.add(myItem);
        
        Map<String,List<SObject>> inputs = new Map<String,List<SObject>>();
        inputs.put('Account', itemVasList);
        
        
        Map<String,Object> formParams = new Map<String,Object>();
        formParams.put('Contesto', 'Account');
        
        //TESTING Context Account
        HDT_UTL_PayloadManagement myObjectToTest = new HDT_UTL_PayloadManagement();
        String result1 = myObjectToTest.execute('calculateCompanyCode', inputs, formParams);
        
        //RETRIEVING DATA
        HDT_HeraCompany__mdt myData = [SELECT CompanyCode__c from HDT_HeraCompany__mdt WHERE Label=:'Hera Comm S.p.A.'];
        
        //ASSERTS
        System.debug('result1: ' + result1);
        System.assert(myData.CompanyCode__c.equalsIgnoreCase(result1), 'Risultato non è ' + myData.CompanyCode__c);
        
    }
    
    
    
    ///EC GC
    @isTest
    private static void calculateCompanyCodeTest_Account(){
        
        //SETUP
        mySetup();
        
        Map<String,Object> primolivello = new Map<String,Object>();
        primolivello.put('societa', 'HERA COMM MARCHE');
                
        List<SObject> itemVasList = new List<SObject>();
        itemVasList.add(primolivello);
        
        Map<String,List<SObject>> inputs = new Map<String,List<SObject>>();
        inputs.put('EstrattoConto', itemVasList);
        
        
        Map<String,Object> formParams = new Map<String,Object>();
        formParams.put('Contesto', 'EC');
        
        //TESTING Context Account
        HDT_UTL_PayloadManagement myObjectToTest = new HDT_UTL_PayloadManagement();
        String result1 = myObjectToTest.execute('calculateCompanyCode', inputs, formParams);
        
        //RETRIEVING DATA
        HDT_HeraCompany__mdt myData = [SELECT CompanyCode__c from HDT_HeraCompany__mdt WHERE Label=:'Hera Comm S.p.A.'];
        
        //ASSERTS
        System.debug('result1: ' + result1);
        System.assert(myData.CompanyCode__c.equalsIgnoreCase(result1), 'Risultato non è ' + myData.CompanyCode__c);
        
    }
    
    
    
    
    ///else
    
    
    
    
    
    
    
    //checkQuotationType
    
    
    
    //calculateQuotationAmount
    
    
    
    //checkGruppoIva
    
    
    
    //checkCommercialOffer
    
    
    
    //generateSection20
    
    
    
    //generateSection40
    
    
    
    //generateSection50
    
    
    
    //generateSection70
    
    
    
    //generateSectionReclami
    
    
    
    //calculateSignModeDriver
    
    
    
    //calculateDriverCatalogo
    
    
    
    //calculateIndemnityBox
    @isTest
    static void calculateIndemnityBoxTest() {
        
        //SETUP
        Test.startTest();
        
        String complaintClassification = 'Reclamo Scritto';
        Boolean indemnityConfirmed = True;
        String indemnityMotivation = null;
        String correctionRight = 'No';
        Boolean expiredCorrection = False;
        String correctionDocumentEmissionDate = null;
        Decimal indemnityDueSendResponse = 0;
        String boxType = HDT_UTL_PayloadManagement.calculateIndemnityBox(complaintClassification, indemnityConfirmed, indemnityMotivation, correctionRight, expiredCorrection, correctionDocumentEmissionDate, indemnityDueSendResponse);
        System.assertEquals('1', boxType);

        complaintClassification = 'Reclamo Scritto';
        indemnityConfirmed = True;
        indemnityMotivation = null;
        correctionRight = 'Si';
        expiredCorrection = False;
        correctionDocumentEmissionDate = String.valueOf(Date.today());
        boxType = HDT_UTL_PayloadManagement.calculateIndemnityBox(complaintClassification, indemnityConfirmed, indemnityMotivation, correctionRight, expiredCorrection, correctionDocumentEmissionDate, indemnityDueSendResponse);
        System.assertEquals('1', boxType);

        complaintClassification = 'Reclamo Scritto';
        indemnityConfirmed = True;
        indemnityMotivation = null;
        correctionRight = 'Si';
        expiredCorrection = True;
        correctionDocumentEmissionDate = String.valueOf(Date.today());
        boxType = HDT_UTL_PayloadManagement.calculateIndemnityBox(complaintClassification, indemnityConfirmed, indemnityMotivation, correctionRight, expiredCorrection, correctionDocumentEmissionDate, indemnityDueSendResponse);
        System.assertEquals('2', boxType);

        complaintClassification = 'Reclamo Scritto';
        indemnityConfirmed = True;
        indemnityMotivation = null;
        correctionRight = 'Si';
        expiredCorrection = True;
        correctionDocumentEmissionDate = String.valueOf(Date.today());
        boxType = HDT_UTL_PayloadManagement.calculateIndemnityBox(complaintClassification, indemnityConfirmed, indemnityMotivation, correctionRight, expiredCorrection, correctionDocumentEmissionDate, 25);
        System.assertEquals('4', boxType);

        complaintClassification = 'Reclamo Scritto';
        indemnityConfirmed = True;
        indemnityMotivation = null;
        correctionRight = 'Si';
        expiredCorrection = True;
        correctionDocumentEmissionDate = null;
        boxType = HDT_UTL_PayloadManagement.calculateIndemnityBox(complaintClassification, indemnityConfirmed, indemnityMotivation, correctionRight, expiredCorrection, correctionDocumentEmissionDate, indemnityDueSendResponse);
        System.assertEquals('5', boxType);

        complaintClassification = 'Reclamo Scritto';
        indemnityConfirmed = True;
        indemnityMotivation = null;
        correctionRight = 'Si';
        expiredCorrection = False;
        correctionDocumentEmissionDate = null;
        boxType = HDT_UTL_PayloadManagement.calculateIndemnityBox(complaintClassification, indemnityConfirmed, indemnityMotivation, correctionRight, expiredCorrection, correctionDocumentEmissionDate, indemnityDueSendResponse);
        System.assertEquals('1', boxType);

        complaintClassification = 'Rettifica Doppia Fatturazione';
        indemnityConfirmed = True;
        indemnityMotivation = null;
        correctionRight = 'Si';
        expiredCorrection = True;
        correctionDocumentEmissionDate = null;
        boxType = HDT_UTL_PayloadManagement.calculateIndemnityBox(complaintClassification, indemnityConfirmed, indemnityMotivation, correctionRight, expiredCorrection, correctionDocumentEmissionDate, indemnityDueSendResponse);
        System.assert(String.isBlank(boxType));

        complaintClassification = 'Rettifica Doppia Fatturazione';
        indemnityConfirmed = True;
        indemnityMotivation = null;
        correctionRight = 'Si';
        expiredCorrection = False;
        correctionDocumentEmissionDate = String.valueOf(Date.today());
        boxType = HDT_UTL_PayloadManagement.calculateIndemnityBox(complaintClassification, indemnityConfirmed, indemnityMotivation, correctionRight, expiredCorrection, correctionDocumentEmissionDate, indemnityDueSendResponse);
        System.assert(String.isBlank(boxType));

        complaintClassification = 'Rettifica Doppia Fatturazione';
        indemnityConfirmed = True;
        indemnityMotivation = null;
        correctionRight = 'Si';
        expiredCorrection = True;
        correctionDocumentEmissionDate = String.valueOf(Date.today());
        boxType = HDT_UTL_PayloadManagement.calculateIndemnityBox(complaintClassification, indemnityConfirmed, indemnityMotivation, correctionRight, expiredCorrection, correctionDocumentEmissionDate, indemnityDueSendResponse);
        System.assertEquals('8', boxType);

        complaintClassification = 'Rettifica Doppia Fatturazione';
        indemnityConfirmed = False;
        indemnityMotivation = 'Altro indennizzo stesso anno solare';
        correctionRight = 'Si';
        expiredCorrection = True;
        correctionDocumentEmissionDate = String.valueOf(Date.today());
        boxType = HDT_UTL_PayloadManagement.calculateIndemnityBox(complaintClassification, indemnityConfirmed, indemnityMotivation, correctionRight, expiredCorrection, correctionDocumentEmissionDate, indemnityDueSendResponse);
        System.assertEquals('6', boxType);

        Test.stopTest();
    }
    
}
