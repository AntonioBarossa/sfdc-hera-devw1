@isTest
public with sharing class HDT_UTL_PayloadManagementTst {
    
    //DEBUG
    public static final String TEST_NAME = 'HDT_UTL_PayloadManagementTst';
    
    //DATA
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    private static Boolean isSubscriptionSetup = false;
    
    
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
        if(isSubscriptionSetup){
            productList[0].Family = 'Offerta commerciale';
        } else {
            productList[0].Family = 'VAS Fatturabili';
        }
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
        
        //CONTACT AND ACCOUNT RELATIONSHIP
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].id);
        HDT_UTL_DataFactoryTst.createAccountContactRelation(true, partnerList[0].Id, contactList[0].Id);
        
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, false, accList[0].id);
        contractList[0].ServicePoint__c = servPoint.Id;
        contractList[0].StartDate = Date.today();
        insert contractList;
        
        if(isSubscriptionSetup){
            //CODICE REPLICATO
            SBQQ__Subscription__c subs = new SBQQ__Subscription__c(
            SBQQ__Contract__c = contractList[0].Id, 
            SBQQ__Product__c = productList[0].Id, 
            SBQQ__Quantity__c = 10.2, 
            SBQQ__Account__c = accList[0].Id,
            SBQQ__NetPrice__c = 100.2,
            SBQQ__SubscriptionEndDate__c = Date.Today());
            insert subs;
        }
        
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, false, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, orderList[0].id);
        if(isSubscriptionSetup){
            caseList[0].ComplaintType__c = 'Reclamo Scritto';
            caseList[0].FirstLevelComplaintClassification__c = 'Reclamo Scritto';
            caseList[0].IndemnityConfirmed__c = true;
            //caseList[0].IndemnityMotivation__c = '';
            caseList[0].CorrectionRight__c = 'Si';
            caseList[0].SendDate__c = date.today().addDays(35);
            //caseList[0].IndemnityDueSendResponse__c = 5.45;
            //caseList[0].IndemnityDueBilllingCorrection__c = 6.25;
        }
        insert caseList;
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
        String result = myObjectToTest.execute('handleAmountVas', inputs, formParams);
        
        //ASSERTS
        System.debug('result: ' + result);
        System.assert(!'||'.equalsIgnoreCase(result), 'Result identico.');
        
        
        //TESTING objectString (ItemVAS equals null)
        inputs.put('ItemVAS', null);
        String resultNull = myObjectToTest.execute('handleAmountVas', inputs, formParams);
        
        //ASSERTS
        System.debug('resultNull: ' + resultNull);
        System.assert('||'.equalsIgnoreCase(resultNull), 'Result non è identico.');
        
        
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
        String result = myObjectToTest.execute('handleFlagDeliveryAddress', inputs, formParams);
        
        //ASSERTS
        System.debug('result: ' + result);
        System.assert('IF'.equalsIgnoreCase(result), 'Risultato non è IF');
        
        //TODO: TESTARE CASO NON "IF". Attualmente non possibile.
        
        //TESTING Blank Contract Id
        Contract con = [SELECT Id FROM Contract];
        myItem.ContractId = con.Id;
        String resultBlank = myObjectToTest.execute('handleFlagDeliveryAddress', inputs, formParams);
        
        //ASSERTS
        System.debug('resultBlank: ' + resultBlank);
        System.assert(''.equalsIgnoreCase(resultBlank), 'Risultato non è stringa vuota.');
        
        
        
        //TESTING context Not Order
        formParams.put('Contesto', 'Fake');
        String resultFake = myObjectToTest.execute('handleFlagDeliveryAddress', inputs, formParams);
        
        //ASSERTS
        System.debug('resultFake: ' + resultFake);
        System.assert(''.equalsIgnoreCase(resultFake), 'Risultato non è stringa vuota.');
        
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
        String result = myObjectToTest.execute('handleFlagPaperless', inputs, formParams);
        
        //ASSERTS
        System.debug('result: ' + result);
        System.assert('N'.equalsIgnoreCase(result), 'Risultato non è N');
        
        
        
        //TESTING Context Case - Not Paperless
        myItem.Type = 'Paperless';
        String resultPaperless = myObjectToTest.execute('handleFlagPaperless', inputs, formParams);
        
        //ASSERTS
        System.debug('resultPaperless: ' + resultPaperless);
        System.assert('Y'.equalsIgnoreCase(resultPaperless), 'Risultato non è Y');
        
        
        
        //TESTING Blank Type
        myItem.Type = '';
        String resultBlank = myObjectToTest.execute('handleFlagPaperless', inputs, formParams);
        
        //ASSERTS
        System.debug('resultBlank: ' + resultBlank);
        System.assert('N'.equalsIgnoreCase(resultBlank), 'Risultato non è N');
        
        
        
        //TESTING Context Not Case
        formParams.put('Contesto', 'Fake');
        String resultFake = myObjectToTest.execute('handleFlagPaperless', inputs, formParams);
        
        //ASSERTS
        System.debug('resultFake: ' + resultFake);
        System.assert('N'.equalsIgnoreCase(resultFake), 'Risultato non è N');
        
    }
    
    
    
    //calculateCompanyCode
    ///Order
    @isTest
    private static void calculateCompanyCodeTestOrder(){
        
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
        String result = myObjectToTest.execute('calculateCompanyCode', inputs, formParams);//'Hera Comm S.p.A.'
        
        //RETRIEVING DATA
        HDT_HeraCompany__mdt myData = [SELECT CompanyCode__c from HDT_HeraCompany__mdt WHERE Label=:'Hera Comm S.p.A.'];
        
        //ASSERTS
        System.debug('result: ' + result);
        System.assert(myData.CompanyCode__c.equalsIgnoreCase(result), 'Risultato non è ' + myData.CompanyCode__c);
    }
    
    
    ///Case
    @isTest
    private static void calculateCompanyCodeTestCase(){
        
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
        String result = myObjectToTest.execute('calculateCompanyCode', inputs, formParams);
        
        //ASSERTS
        System.debug('result: ' + result);
        System.assert(''.equalsIgnoreCase(result), 'Risultato non è stringa vuota');
        
    }
    
    
    
    ///Account
    @isTest
    private static void calculateCompanyCodeTestAccount(){
        
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
        String result = myObjectToTest.execute('calculateCompanyCode', inputs, formParams);
        
        //RETRIEVING DATA
        HDT_HeraCompany__mdt myData = [SELECT CompanyCode__c from HDT_HeraCompany__mdt WHERE Label=:'Hera Comm S.p.A.'];
        
        //ASSERTS
        System.debug('result: ' + result);
        System.assert(myData.CompanyCode__c.equalsIgnoreCase(result), 'Risultato non è ' + myData.CompanyCode__c);
        
    }
    
    
    
    ///EC GC
    @isTest
    private static void calculateCompanyCodeTestECc(){ 
        
        //SETUP
        mySetup();
        
        Map<String,Object> primolivello = new Map<String,Object>();
        primolivello.put('societa', 'HERA COMM MARCHE');
                
        List<Object> itemVasList = new List<Object>();
        itemVasList.add(primolivello);
        
        Map<String,List<SObject>> inputs = new Map<String,List<SObject>>();
        
        Map<String,Object> formParams = new Map<String,Object>();
        formParams.put('Contesto', 'EC');
        formParams.put('EstrattoConto', JSON.serialize(itemVasList));
        
        
        //TESTING Context EC - 2060
        HDT_UTL_PayloadManagement myObjectToTest = new HDT_UTL_PayloadManagement();
        String result = myObjectToTest.execute('calculateCompanyCode', inputs, formParams);
        
        //ASSERTS
        System.debug('result: ' + result);
        System.assert('2060'.equalsIgnoreCase(result), 'Risultato non è 2060');
        
        
        
        //TESTING Context EC - 7030
        primolivello.put('societa', 'ESTENERGY SPA');
        formParams.put('EstrattoConto', JSON.serialize(itemVasList));
        String resultEst = myObjectToTest.execute('calculateCompanyCode', inputs, formParams);
        
        //ASSERTS
        System.debug('resultEst: ' + resultEst);
        System.assert('7030'.equalsIgnoreCase(resultEst), 'Risultato non è 7030');
        
        
        
        //TESTING Context EC - 7015
        primolivello.put('societa', 'HERA COMM NORDEST');
        formParams.put('EstrattoConto', JSON.serialize(itemVasList));
        String resultHeraComm = myObjectToTest.execute('calculateCompanyCode', inputs, formParams);
        
        //ASSERTS
        System.debug('resultHeraComm: ' + resultHeraComm);
        System.assert('7015'.equalsIgnoreCase(resultHeraComm), 'Risultato non è 7015');
        
        
        
        //TESTING Context EC - 1070
        primolivello.put('societa', '6 USZE TAHAM');
        formParams.put('EstrattoConto', JSON.serialize(itemVasList));
        String resultUsze = myObjectToTest.execute('calculateCompanyCode', inputs, formParams);
        
        //ASSERTS
        System.debug('resultUsze: ' + resultUsze);
        System.assert('1070'.equalsIgnoreCase(resultUsze), 'Risultato non è 1070');
        
        //TODO: POSSIBILE ESTENSIONE CON COPERTURA DEL CATCH SE EstrattoConto PUNTA A NULL
        
    }
    
    
    
    ///else
    @isTest
    private static void calculateCompanyCodeTestElse(){
        
        //SETUP
        mySetup();
        
        Map<String,List<SObject>> inputs = new Map<String,List<SObject>>();
        Map<String,Object> formParams = new Map<String,Object>();
        formParams.put('Contesto', 'Fake');
        
        //TESTING Context Account
        HDT_UTL_PayloadManagement myObjectToTest = new HDT_UTL_PayloadManagement();
        String result = myObjectToTest.execute('calculateCompanyCode', inputs, formParams);
        
        //ASSERTS
        System.debug('result: ' + result);
        System.assert(''.equalsIgnoreCase(result), 'Risultato non è Stringa vuota.');
        
    }
    
    
    
    
    
    
    
    //checkQuotationType
    @isTest
    private static void checkQuotationTypeTest(){
        
        //SETUP
        mySetup();
        
        Case myItem = [SELECT Id, QuotationType__c, DocumentalProcessType__c, Cluster__c FROM Case];
        myItem.Cluster__c = 'Preventivi';
        myItem.QuotationType__c = 'Predeterminabile';
        
        List<SObject> itemVasList = new List<SObject>();
        itemVasList.add(myItem);
        
        Map<String,List<SObject>> inputs = new Map<String,List<SObject>>();
        inputs.put('Case', itemVasList);
        
        
        Map<String,Object> formParams = new Map<String,Object>();
        formParams.put('Contesto', 'Case');
        
        
        //TESTING Context Case - SIP
        HDT_UTL_PayloadManagement myObjectToTest = new HDT_UTL_PayloadManagement();
        String result = myObjectToTest.execute('checkQuotationType', inputs, formParams);
        
        //ASSERTS
        System.debug('result: ' + result);
        System.assert('SIP'.equalsIgnoreCase(result), 'Risultato non è SIP');
        
        //COMMENTATO - FIELD DocumentalProcessType__c NON WRITEABLE.
        /*
        //TESTING Context Case - NOP
        myItem.QuotationType__c = 'Rapido';
        myItem.DocumentalProcessType__c = 'Aumento Potenza';
        String result2 = myObjectToTest.execute('checkQuotationType', inputs, formParams);
        
        //ASSERTS
        System.debug('result2: ' + result2);
        System.assert('NOP'.equalsIgnoreCase(result2), 'Risultato non è NOP');
        
        
        
        //TESTING Context Case - POT
        myItem.QuotationType__c = 'Rapido';
        myItem.DocumentalProcessType__c = 'Diminuzione Potenza';
        String result3 = myObjectToTest.execute('checkQuotationType', inputs, formParams);
        
        //ASSERTS
        System.debug('result3: ' + result3);
        System.assert('POT'.equalsIgnoreCase(result3), 'Risultato non è POT');
        
        
        
        //TESTING Context Case - stringa vuota
        myItem.QuotationType__c = '';
        myItem.DocumentalProcessType__c = '';
        String result4 = myObjectToTest.execute('checkQuotationType', inputs, formParams);
        
        //ASSERTS
        System.debug('result4: ' + result4);
        System.assert(''.equalsIgnoreCase(result4), 'Risultato non è Stringa vuota');
        
        
        
        //TESTING Context Case - stringa vuota
        myItem.Cluster__c = '';
        myItem.QuotationType__c = '';
        myItem.DocumentalProcessType__c = '';
        String result5 = myObjectToTest.execute('checkQuotationType', inputs, formParams);
        
        //ASSERTS
        System.debug('result5: ' + result5);
        System.assert(''.equalsIgnoreCase(result5), 'Risultato non è Stringa vuota');
        */
    }
    
    
    //calculateQuotationAmount
    @isTest
    private static void calculateQuotationAmountTest(){
        
        //SETUP
        mySetup();
        
        Case myItem = [SELECT Id, Amount__c, FixedAmount__c, VariableAmount__c, VATPercentage__c, Type, SupplyType__c, Cluster__c FROM Case];
        myItem.Cluster__c = 'Preventivi';
        myItem.QuotationType__c = 'Predeterminabile';
        
        List<SObject> itemVasList = new List<SObject>();
        itemVasList.add(myItem);
        
        Map<String,List<SObject>> inputs = new Map<String,List<SObject>>();
        inputs.put('Case', itemVasList);
        
        Map<String,Object> formParams = new Map<String,Object>();
        formParams.put('Contesto', 'Case');
        
        
        //TESTING Context Case - Empty Amount
        HDT_UTL_PayloadManagement myObjectToTest = new HDT_UTL_PayloadManagement();
        String result = myObjectToTest.execute('calculateQuotationAmount', inputs, formParams);
        
        //ASSERTS
        System.debug('result: ' + result);
        System.assert('|||||'.equalsIgnoreCase(result), 'Risultato non è |||||');
        formParams.put('Contesto', 'Case');
        
        
        
        //TESTING Context Case - Preventivi
        Case myPreventivo = new Case();
        myPreventivo.Amount__c = 5.0;
        myPreventivo.FixedAmount__c = 2.0;
        myPreventivo.VariableAmount__c = 3.0;
        myPreventivo.VATPercentage__c = 'GENERICI 10%-01';
        myPreventivo.Type = 'Potenza';
        myPreventivo.SupplyType__c = 'Domestico';
        myPreventivo.Cluster__c = 'Preventivi';
        
        itemVasList = new List<SObject>();
        itemVasList.add(myPreventivo);
        inputs.put('Case', itemVasList);
        
        String resultCase = myObjectToTest.execute('calculateQuotationAmount', inputs, formParams);
        
        //ASSERTS
        System.debug('resultCase: ' + resultCase);
        System.assert(!'|||||'.equalsIgnoreCase(resultCase), 'Risultato è |||||, previsto diverso.');
        
    }
    
    
    
    //checkGruppoIva
    @isTest
    private static void checkGruppoIvaTest(){
        
        //SETUP
        Account acc = new Account();
        acc.VATGroup__c = 'Fake_PIVA';
        acc.VATGroupStartDate__c = Date.today().addDays(-1);
        acc.IsVATGroupJoined__c = true;
        acc.VATGroupEndDate__c = Date.today().addDays(10);
        
        List<SObject> itemVasList = new List<SObject>();
        itemVasList.add(acc);
        
        Map<String,List<SObject>> inputs = new Map<String,List<SObject>>();
        inputs.put('Account', itemVasList);
        
        Map<String,Object> formParams = new Map<String,Object>();
        
        //TESTING - REGULAR
        HDT_UTL_PayloadManagement myObjectToTest = new HDT_UTL_PayloadManagement();
        String result = myObjectToTest.execute('checkGruppoIva', inputs, formParams);
        
        //ASSERTS
        System.debug('result: ' + result);
        
        String awaitedResult = acc.VATGroup__c + '|' + HDT_UTL_DocumentalManagement.transformDate(Date.valueOf(acc.VATGroupStartDate__c));
        System.assert(awaitedResult.equalsIgnoreCase(result), 'Risultato non è ' + awaitedResult);
        
        
        
        //TESTING - empty
        acc.VATGroupStartDate__c = Date.today();
        String resultEmpty = myObjectToTest.execute('checkGruppoIva', inputs, formParams);
        
        //ASSERTS
        System.debug('resultEmpty: ' + resultEmpty);
        System.assert(''.equalsIgnoreCase(resultEmpty), 'Risultato non è Stringa vuota');
        
    }
    
    
    
    //checkCommercialOffer
    @isTest
    private static void checkCommercialOfferTest(){
        
        //SETUP
        mySetup();
        
        Order myItem = [SELECT Id, ImplantType__c FROM Order];
        myItem.ImplantType__c = 'Cottura cibi';
        List<SObject> itemVasList = new List<SObject>();
        itemVasList.add(myItem);
        
        Map<String,List<SObject>> inputs = new Map<String,List<SObject>>();
        inputs.put('Order', itemVasList);
        
        
        Map<String,Object> formParams = new Map<String,Object>();
        formParams.put('Contesto', 'Order');
        
        //TESTING - CO|
        HDT_UTL_PayloadManagement myObjectToTest = new HDT_UTL_PayloadManagement();
        String result = myObjectToTest.execute('checkCommercialOffer', inputs, formParams);
        
        //ASSERTS
        System.debug('result: ' + result);
        System.assert('||||CO||'.equalsIgnoreCase(result), 'Risultato non è ||||CO||');
        
        
        
        //TESTING - AC|
        myItem.ImplantType__c = 'acq calda';
        String resultAc = myObjectToTest.execute('checkCommercialOffer', inputs, formParams);
        
        //ASSERTS
        System.debug('resultAc: ' + resultAc);
        System.assert('||||AC||'.equalsIgnoreCase(resultAc), 'Risultato non è ||||AC||');
        
        
        
        //TESTING - RA|
        myItem.ImplantType__c = 'Riscaldamento';
        String resultRa = myObjectToTest.execute('checkCommercialOffer', inputs, formParams);
        
        //ASSERTS
        System.debug('resultRa: ' + resultRa);
        System.assert('||||RA||'.equalsIgnoreCase(resultRa), 'Risultato non è ||||RA||');
        
        
        
        //TESTING - RC|
        myItem.ImplantType__c = 'Risc. centraliz';
        String resultRc = myObjectToTest.execute('checkCommercialOffer', inputs, formParams);
        
        //ASSERTS
        System.debug('resultRc: ' + resultRc);
        System.assert('||||RC||'.equalsIgnoreCase(resultRc), 'Risultato non è ||||RC||');
        
        
        
        //TESTING - |
        myItem.ImplantType__c = 'Fake';
        String resultFake = myObjectToTest.execute('checkCommercialOffer', inputs, formParams);
        
        //ASSERTS
        System.debug('resultFake: ' + resultFake);
        System.assert('||||||'.equalsIgnoreCase(resultFake), 'Risultato non è ||||||');
        
    }
    
    
    
    //generateSection20
    @isTest
    private static void generateSection20Test(){
        
        //SETUP
        isSubscriptionSetup = true;
        mySetup();
        
        Account myItem = [SELECT Id FROM Account WHERE RecordTypeId = :constants.ACCOUNT_RECORDTYPEID_BUSINESS];
        
        List<SObject> itemVasList = new List<SObject>();
        itemVasList.add(myItem);
        
        Map<String,List<SObject>> inputs = new Map<String,List<SObject>>();
        inputs.put('Account', itemVasList);
        
        Map<String,Object> formParams = new Map<String,Object>();
        
        //TESTING - CASO GENERICO
        HDT_UTL_PayloadManagement myObjectToTest = new HDT_UTL_PayloadManagement();
        String result = myObjectToTest.execute('generateSection20', inputs, formParams);
        
        //ASSERTS
        System.debug('result length ' + result.length());
        System.assert(String.isNotBlank(result), 'Risultato è stringa vuota.');
        
    }
    
    
    //generateSection40
    @isTest
    private static void generateSection40Test(){
        
        //SETUP
        mySetup();
        
        List<Case> myItemsCase = [SELECT Id, CreatedDate, Origin, Type, Cluster__c, CaseNumber, Phase__c FROM Case];
        List<Order> myItemsOrder = [SELECT Id, CreatedDate, Channel__c, ProcessType__c, Cluster__c, OrderNumber, Phase__c FROM Order];
        
        Map<String,List<SObject>> inputs = new Map<String,List<SObject>>();
        inputs.put('CaseList', myItemsCase);
        inputs.put('OrderList', myItemsOrder);
        
        Map<String,Object> formParams = new Map<String,Object>();
        
        //TESTING - CASO GENERICO
        HDT_UTL_PayloadManagement myObjectToTest = new HDT_UTL_PayloadManagement();
        String result = myObjectToTest.execute('generateSection40', inputs, formParams);
        
        //ASSERTS
        System.debug('result length ' + result.length());
        //System.assert(String.isBlank(result), 'Risultato non è stringa vuota.');
        System.assert(String.isNotBlank(result), 'Risultato è stringa vuota.');
        
    }
    
    
    
    //generateSection50
    @isTest
    private static void generateSection50Test(){
        
        //SETUP
        mySetup();
        
        List<Case> myItemsCase = [SELECT Id, CreatedDate, Origin, Type, Cluster__c, CaseNumber, Phase__c FROM Case];
        for(Case myCase : myItemsCase){
            myCase.Cluster__c = 'Preventivi';
        }
        
        List<Order> myItemsOrder = [SELECT Id, CreatedDate, Channel__c, ProcessType__c, Cluster__c, OrderNumber, Phase__c FROM Order];
        for(Order myOrder : myItemsOrder){
            myOrder.ProcessType__c = 'Prima Attivazione con modifica';
        }
        
        Map<String,List<SObject>> inputs = new Map<String,List<SObject>>();
        inputs.put('CaseList', myItemsCase);
        inputs.put('OrderList', myItemsOrder);
        
        Map<String,Object> formParams = new Map<String,Object>();
        
        //TESTING - CASO GENERICO
        HDT_UTL_PayloadManagement myObjectToTest = new HDT_UTL_PayloadManagement();
        String result = myObjectToTest.execute('generateSection50', inputs, formParams);
        
        //ASSERTS
        System.debug('result length ' + result.length());
        //System.assert(String.isBlank(result), 'Risultato non è stringa vuota.');
        System.assert(String.isNotBlank(result), 'Risultato è stringa vuota.');
        
    }
    
    
    
    //generateSection70
    @isTest
    private static void generateSection70Test(){
        
        //SETUP
        mySetup();
        
        //NB: ACCOUNT NOT BUSINESS TYPE PER ACR
        Account myItem = [SELECT Id FROM Account WHERE RecordTypeId != :constants.ACCOUNT_RECORDTYPEID_BUSINESS];
        
        List<SObject> itemVasList = new List<SObject>();
        itemVasList.add(myItem);
        
        Map<String,List<SObject>> inputs = new Map<String,List<SObject>>();
        inputs.put('Account', itemVasList);
        
        Map<String,Object> formParams = new Map<String,Object>();
        
        //TESTING - CASO GENERICO
        HDT_UTL_PayloadManagement myObjectToTest = new HDT_UTL_PayloadManagement();
        String result = myObjectToTest.execute('generateSection70', inputs, formParams);
        
        //ASSERTS
        System.debug('result length ' + result.length());
        //System.assert(String.isBlank(result), 'Risultato non è stringa vuota.');
        System.assert(String.isNotBlank(result), 'Risultato è stringa vuota.');
        
        
        //TESTING - CASO senza ACR
        myItem = [SELECT Id FROM Account WHERE RecordTypeId = :constants.ACCOUNT_RECORDTYPEID_BUSINESS];
        itemVasList = new List<SObject>();
        itemVasList.add(myItem);
        inputs = new Map<String,List<SObject>>();
        inputs.put('Account', itemVasList);
        
        String resultNoAcr = myObjectToTest.execute('generateSection70', inputs, formParams);
        System.assert(String.isBlank(resultNoAcr), 'Risultato non è stringa vuota.');
        
    }
    
    
    
    //generateSectionReclami
    @isTest
    private static void generateSectionReclamiTest(){
        
        //SETUP
        isSubscriptionSetup = true;
        mySetup();
        
        Case myItem = [SELECT Id, Cluster__c, ComplaintBodyResponse__c, Note__c, IsContainer__c, FirstLevelComplaintClassification__c, IndemnityConfirmed__c, 
                              IndemnityMotivation__c, IndemnityDueSendResponse__c, IndemnityDueBilllingCorrection__c, CorrectionRight__c, 
                              CorrectionDocumentEmissionDay__c
                       FROM Case];
        
        Map<String,List<SObject>> inputs = new Map<String,List<SObject>>();
        inputs.put('Case', new List<Case>{myItem});
        
        Map<String,Object> formParams = new Map<String,Object>();
        formParams.put('Contesto', 'Case');
        
        //TESTING - CASO cluster not Reclami
        HDT_UTL_PayloadManagement myObjectToTest = new HDT_UTL_PayloadManagement();
        String result = myObjectToTest.execute('generateSectionReclami', inputs, formParams);
        
        //ASSERTS
        System.debug('result length ' + result.length());
        System.assert(String.isBlank(result), 'Risultato NON è stringa vuota.');
        
        
        
        //TESTING - Caso HTML Response Blank
        myItem.Cluster__c = 'Reclami';
        myObjectToTest = new HDT_UTL_PayloadManagement();
        String resultBlank = myObjectToTest.execute('generateSectionReclami', inputs, formParams);
        
        //ASSERTS
        System.debug('resultBlank length ' + resultBlank.length());
        System.assert(String.isBlank(resultBlank), 'Risultato NON è stringa vuota.');
        
        
        
        //TESTING - caso normale
        myItem.ComplaintBodyResponse__c = 'Body Response Fake';//TODO: SPLITTER PATTERN TESTING
        //myItem.IsContainer__c = true;
        myObjectToTest = new HDT_UTL_PayloadManagement();
        String resultNormale = myObjectToTest.execute('generateSectionReclami', inputs, formParams);
        
        //ASSERTS
        System.debug('resultNormale length ' + resultNormale.length());
        System.assert(String.isNotBlank(resultNormale), 'Risultato è stringa vuota.');
        
    }
    
    
    
    //calculateSignModeDriver
    @isTest
    private static void calculateSignModeDriverTest(){
        
        //SETUP
        mySetup();
        
        List<Order> orderList = [SELECT Id, SignatureMethod__c FROM Order];
        for(Order o: orderList){
            o.SignatureMethod__c = 'Vocal Order';
        }
        
        Map<String,List<SObject>> inputs = new Map<String,List<SObject>>();
        inputs.put('Order', orderList);
        
        Map<String,Object> formParams = new Map<String,Object>();
        formParams.put('Contesto', 'Order');
        
        //TESTING - CASO INPUTS
        HDT_UTL_PayloadManagement myObjectToTest = new HDT_UTL_PayloadManagement();
        String result = myObjectToTest.execute('calculateSignModeDriver', inputs, formParams);
        
        //ASSERTS
        System.debug('result length ' + result.length());
        System.assert('Vocal Order'.equalsIgnoreCase(result), 'Risultato non è Vocal order.');
        
        
        
        //TESTING - CASO FORMPARAMS
        formParams.put('signMode', 'Vocal Order');
        String resultForm = myObjectToTest.execute('calculateSignModeDriver', inputs, formParams);
        
        //ASSERTS
        System.debug('resultForm length ' + resultForm.length());
        System.assert('Vocal Order'.equalsIgnoreCase(resultForm), 'Risultato non è Vocal order.');
        
    }
    
    
    
    //calculateDriverCatalogo
    @isTest
    private static void calculateDriverCatalogoTest(){
        
        //SETUP
        mySetup();
        
        List<Order> orderList = [SELECT Id, SignatureMethod__c FROM Order];
        for(Order o: orderList){
            o.SignatureMethod__c = 'Vocal Order';
        }
        
        Map<String,List<SObject>> inputs = new Map<String,List<SObject>>();
        inputs.put('Order', orderList);
        
        Map<String,Object> formParams = new Map<String,Object>();
        formParams.put('Contesto', 'Fake');
        
        //TESTING - CASO Contesto Not Order
        HDT_UTL_PayloadManagement myObjectToTest = new HDT_UTL_PayloadManagement();
        String result = myObjectToTest.execute('calculateDriverCatalogo', inputs, formParams);
        
        //ASSERTS
        System.debug('result length ' + result.length());
        System.assert(String.isBlank(result), 'Risultato non è stringa vuota.');
        
        
        
        //TESTING - CASO Pricebook Blank
        formParams.put('Contesto', 'Order');
        String resultBlank = myObjectToTest.execute('calculateDriverCatalogo', inputs, formParams);
        
        //ASSERTS
        System.debug('resultBlank length ' + resultBlank.length());
        System.assert(String.isBlank(resultBlank), 'Risultato non è stringa vuota.');
        
        
    }
    
    
    
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
        System.assertEquals('1', boxType, 'Indemnity Box Test OK');

        complaintClassification = 'Reclamo Scritto';
        indemnityConfirmed = True;
        indemnityMotivation = null;
        correctionRight = 'Si';
        expiredCorrection = False;
        correctionDocumentEmissionDate = String.valueOf(Date.today());
        boxType = HDT_UTL_PayloadManagement.calculateIndemnityBox(complaintClassification, indemnityConfirmed, indemnityMotivation, correctionRight, expiredCorrection, correctionDocumentEmissionDate, indemnityDueSendResponse);
        System.assertEquals('1', boxType, 'Indemnity Box Test OK');

        complaintClassification = 'Reclamo Scritto';
        indemnityConfirmed = True;
        indemnityMotivation = null;
        correctionRight = 'Si';
        expiredCorrection = True;
        correctionDocumentEmissionDate = String.valueOf(Date.today());
        boxType = HDT_UTL_PayloadManagement.calculateIndemnityBox(complaintClassification, indemnityConfirmed, indemnityMotivation, correctionRight, expiredCorrection, correctionDocumentEmissionDate, indemnityDueSendResponse);
        System.assertEquals('2', boxType, 'Indemnity Box Test OK');

        complaintClassification = 'Reclamo Scritto';
        indemnityConfirmed = True;
        indemnityMotivation = null;
        correctionRight = 'Si';
        expiredCorrection = True;
        correctionDocumentEmissionDate = String.valueOf(Date.today());
        boxType = HDT_UTL_PayloadManagement.calculateIndemnityBox(complaintClassification, indemnityConfirmed, indemnityMotivation, correctionRight, expiredCorrection, correctionDocumentEmissionDate, 25);
        System.assertEquals('4', boxType, 'Indemnity Box Test OK');

        complaintClassification = 'Reclamo Scritto';
        indemnityConfirmed = True;
        indemnityMotivation = null;
        correctionRight = 'Si';
        expiredCorrection = True;
        correctionDocumentEmissionDate = null;
        boxType = HDT_UTL_PayloadManagement.calculateIndemnityBox(complaintClassification, indemnityConfirmed, indemnityMotivation, correctionRight, expiredCorrection, correctionDocumentEmissionDate, indemnityDueSendResponse);
        System.assertEquals('5', boxType, 'Indemnity Box Test OK');

        complaintClassification = 'Reclamo Scritto';
        indemnityConfirmed = True;
        indemnityMotivation = null;
        correctionRight = 'Si';
        expiredCorrection = False;
        correctionDocumentEmissionDate = null;
        boxType = HDT_UTL_PayloadManagement.calculateIndemnityBox(complaintClassification, indemnityConfirmed, indemnityMotivation, correctionRight, expiredCorrection, correctionDocumentEmissionDate, indemnityDueSendResponse);
        System.assertEquals('1', boxType, 'Indemnity Box Test OK');

        complaintClassification = 'Rettifica Doppia Fatturazione';
        indemnityConfirmed = True;
        indemnityMotivation = null;
        correctionRight = 'Si';
        expiredCorrection = True;
        correctionDocumentEmissionDate = null;
        boxType = HDT_UTL_PayloadManagement.calculateIndemnityBox(complaintClassification, indemnityConfirmed, indemnityMotivation, correctionRight, expiredCorrection, correctionDocumentEmissionDate, indemnityDueSendResponse);
        System.assert(String.isBlank(boxType), 'Indemnity Box Test OK');

        complaintClassification = 'Rettifica Doppia Fatturazione';
        indemnityConfirmed = True;
        indemnityMotivation = null;
        correctionRight = 'Si';
        expiredCorrection = False;
        correctionDocumentEmissionDate = String.valueOf(Date.today());
        boxType = HDT_UTL_PayloadManagement.calculateIndemnityBox(complaintClassification, indemnityConfirmed, indemnityMotivation, correctionRight, expiredCorrection, correctionDocumentEmissionDate, indemnityDueSendResponse);
        System.assert(String.isBlank(boxType), 'Indemnity Box Test OK');

        complaintClassification = 'Rettifica Doppia Fatturazione';
        indemnityConfirmed = True;
        indemnityMotivation = null;
        correctionRight = 'Si';
        expiredCorrection = True;
        correctionDocumentEmissionDate = String.valueOf(Date.today());
        boxType = HDT_UTL_PayloadManagement.calculateIndemnityBox(complaintClassification, indemnityConfirmed, indemnityMotivation, correctionRight, expiredCorrection, correctionDocumentEmissionDate, indemnityDueSendResponse);
        System.assertEquals('8', boxType, 'Indemnity Box Test OK');

        complaintClassification = 'Rettifica Doppia Fatturazione';
        indemnityConfirmed = False;
        indemnityMotivation = 'Altro indennizzo stesso anno solare';
        correctionRight = 'Si';
        expiredCorrection = True;
        correctionDocumentEmissionDate = String.valueOf(Date.today());
        boxType = HDT_UTL_PayloadManagement.calculateIndemnityBox(complaintClassification, indemnityConfirmed, indemnityMotivation, correctionRight, expiredCorrection, correctionDocumentEmissionDate, indemnityDueSendResponse);
        System.assertEquals('6', boxType, 'Indemnity Box Test OK');

        Test.stopTest();
    }
    
}
