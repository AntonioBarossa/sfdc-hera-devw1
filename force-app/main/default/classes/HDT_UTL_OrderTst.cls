/*
    @Author:        Francesco Vitiello (francesco.vitiello@nttdata.com)
    CreatedDate:    13/05/2022
*/
@isTest
public with sharing class HDT_UTL_OrderTst {

    @TestSetup
    static void setup(){

        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        HDT_UTL_DataFactoryTst.pClickCasePhase();


        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountDistributore(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        accList[0].FirstName__c = 'Mario';
        accList[0].LastName__c = 'Rossi';
        accList[0].BirthDate__c = Date.today();
        accList[0].ShippingCity = 'Bologna';
        accList[0].ShippingCountry = 'Italia';
        accList[0].ShippingPostalCode = '40124';
        accList[0].ShippingState = 'BO';
        accList[0].ShippingStreet = 'Piazza Maggiore';
        accList[0].Code__c = '13D1900000';
        update accList;

        //Contact
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(2, true, accList[0].Id);
        contactList[0].FiscalCode__c = 'VLPDNC71H27H861F';
        contactList[0].VATNumber__c = '21926200615';
        contactList[1].Email = 'mrossi@libero.com';
        contactList[1].MobilePhone = '3331231231';
        contactList[1].VATNumber__c = '91008490442';
        contactList[1].FiscalCode__c = 'RNNMRC00A19H501D';
        update contactList;

        //SALE
        List<Sale__c> saleList = HDT_UTL_DataFactoryTst.createSale(1, true, accList[0].Id, 'Bozza');
        saleList[0].SalesContact__c = contactList[0].Id;
        saleList[0].Ecid__c = 'myTestEcid';
        saleList[0].Channel__c = 'Sportello';
        update saleList;

        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);


        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        servPointList[0].Account__c = accList[0].Id;
        servPointList[0].Distributor__c = accList[0].Id;
        servPointList[0].ServicePointCode__c = 'IT001E46371811';
        servPointList[0].CommoditySector__c = 'Energia Elettrica';
        servPointList[0].isReseller__c = false;
        servPointList[0].MeterClass__c = 'G4';
        servPointList[0].MeterStatus__c = 'Attivo';
        servPointList[0].PlugPresence__c = 'Si';
        servPointList[0].UseTypeEnergy__c = 'Ordinaria (Perm)';
        servPointList[0].UseCategory__c = '001-Uso cottura cibi';
        servPointList[0].Vat__c = '02';
        servPointList[0].ExciseEle__c = 'E_IE_M04';
        //servPointList[0].ExciseGas__c = '';
        //servPointList[0].SapContractStatus__c = '';
        update servPointList;

        List<BillingProfile__c> billingProfileList = HDT_UTL_DataFactoryTst.createBillingProfile(1,true, accList[0].Id);
        /*billingProfileList[0].InvoicingStreetName__c = 'Roma';
        billingProfileList[0].InvoicingStreetNumber__c = '15';
        billingProfileList[0].InvoicingStreetNumberExtension__c = '20100 ITALIA';
        billingProfileList[0].InvoicingCity__c = 'ROMA';
        billingProfileList[0].InvoicingProvince__c = 'RM';
        billingProfileList[0].InvoicingPostalCode__c = '10190';
        billingProfileList[0].InvoicingCountry__c = 'ITALIA';*/
        //update billingProfileList;

        List<Product2> productList = HDT_UTL_DataFactoryTst.createProduct2(1, true);
        productList[0].Family = 'Offerta commerciale';
        productList[0].Version__c = 'V1.0';
        productList[0].ProductCode = 'HIZLA_SERV';
        productList[0].Name = 'HERA LED 1 KIT V2';
        update productList;

        Id priceBookId = Test.getStandardPriceBookId();

        List<PricebookEntry> stdpriceBookEntryList = HDT_UTL_DataFactoryTst.createPricebookEntry(productList, true, priceBookId);

        List<Pricebook2> pbList = HDT_UTL_DataFactoryTst.createPricebook(1, true);

        List<PricebookEntry> priceBookEntryList = HDT_UTL_DataFactoryTst.createPricebookEntry(productList, true, pbList[0].Id);

        String rtOrder = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_SwitchIn').getRecordTypeId();        
        String rtParentOrder = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_OrderDossier').getRecordTypeId();        
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(3, true, accList[0].id, 'Bozza');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Annullamento - Dati discordanti', 'Bozza', rtOrder, 'HDT_RT_VAS','A','','','');
        ordList[0].RecordTypeId = rtOrder;
        ordList[0].Sale__c = saleList[0].Id;
        ordList[0].Contact__c = contactList[0].Id;
        ordList[0].SalesContact__c = contactList[1].Id;
        ordList[0].ServicePoint__c = servPointList[0].Id;
        ordList[0].ContractId = contractList[0].Id;
        ordList[0].BillingProfile__c = billingProfileList[0].Id;
        ordList[1].RecordTypeId = rtParentOrder;
        ordList[0].ParentOrder__c = ordList[1].Id;
        ordList[0].Pricebook2Id = pbList[0].Id;
        ordList[0].CommercialProduct__c = 'Hera Impronta Zero Casa Luce 24 + AC';
        ordList[0].SupplyType__c = 'Domestico';
        ordList[2].RecordTypeId = rtOrder;
        ordList[2].Sale__c = saleList[0].Id;
        ordList[2].Contact__c = contactList[0].Id;
        ordList[2].SalesContact__c = contactList[1].Id;
        ordList[2].ServicePoint__c = servPointList[0].Id;
        ordList[2].ContractId = contractList[0].Id;
        ordList[2].BillingProfile__c = billingProfileList[0].Id;
        ordList[2].ParentOrder__c = ordList[1].Id;
        ordList[2].Pricebook2Id = pbList[0].Id;
        ordList[2].CommercialProduct__c = 'Hera Impronta Zero Casa Luce 24 + AC';
        ordList[2].SupplyType__c = 'Domestico';
        ordList[2].Phase__c = 'Annullamento - Dati discordanti';
        /*ordList[0].Username__c = '';
        ordList[0].SwitchOutDate__c = Date.today();
        ordList[0].Vat__c = 'Iva 22% (Cod. 02)';
        ordList[0].ExciseGas__c = '';
        ordList[0].ExciseEle__c = 'Imposta usi domestici';
        ordList[0].ContractSigned__c = false;
        ordList[0].SignedDate__c = Date.today();
        ordList[0].SignatureMethod__c = 'Cartacea';
        ordList[0].DocSendingMethod__c = 'Stampa Cartacea';
        ordList[0].Step__c = 2;
        ordList[0].PowerAvailable__c = 251;
        ordList[0].UseTypeEnergy__c = 'Ordinaria (Perm)';
        ordList[0].Deliberation__c = 'In Delibera';
        ordList[0].RequestOption__c = 'AEEG Op MTA2 >100 <=500-E_MTA2';
        ordList[0].WaiverRightAfterthought__c = 'Si';
        ordList[0].MaxAfterthoughtDate__c = Date.today();
        ordList[0].PreviousTrader__c = '';
        ordList[0].VolturaThirdTrader__c = false;*/        
        update ordList;

        List<OrderItem> ordersItems = HDT_UTL_DataFactoryTst.createOrderItem(1, true, ordList[0].id, servPointList[0].id, productList[0].id, priceBookEntryList[0].id);
        ordersItems[0].BillingProfile__c = billingProfileList[0].Id;
        ordersItems[0].VASBillingMode__c = 'A-Rate fisse';
        ordersItems[0].DelayEffectiveDate__c = Date.today();

        update ordersItems;

        List<Opportunity> oppList = HDT_UTL_DataFactoryTst.createOpportunity(1, True);

        List<SBQQ__Quote__c> quoteList = HDT_UTL_DataFactoryTst.createQuote(1, true, ordList[0].Id, oppList[0].Id, saleList[0].Id, 'Quote');
        quoteList[0].IsVAS__c = false;
        quoteList[0].IsBillableVas__c = false;
        quoteList[0].AmendmentAllowed__c = false;
        quoteList[0].ContractReference__c = contractList[0].Id;
        quoteList[0].OrderReference__c = ordList[0].Id;
        quoteList[0].AllowChangeUse__c = false;
        quoteList[0].SBQQ__Type__c = 'Quote';
        update quoteList;

        ordList[0].SBQQ__Quote__c = quoteList[0].Id;      
        update ordList;

        List<RateCategory__c> myCatList = HDT_UTL_DataFactoryTst.createRateCategoty(1, true);
        myCatList[0].Commodity__c =  'Energia Elettrica';
        myCatList[0].ProductName__c = 'Hera Impronta Zero Casa Luce 24 + AC';
        myCatList[0].DistributorCode__c = '13D1900000';
        myCatList[0].Commodity__c = 'Energia Elettrica';
        myCatList[0].Fornitura__c = 'Domestico';
        myCatList[0].operatore__c = 'Uguale';
        update myCatList;

        String rtCase = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_VolturaTecnica').getRecordTypeId();        
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        caseList[0].Order__c = ordList[0].Id;
        caseList[0].RecordTypeId = rtCase;
        update caseList;


        String rtActivity = Schema.SObjectType.wrts_prcgvr__Activity__c.getRecordTypeInfosByDeveloperName().get('HDT_RT_Scarto').getRecordTypeId();
        List<wrts_prcgvr__Activity__c> actList = HDT_UTL_DataFactoryTst.createActivityCustom(1, true, accList[0].Id);
        actList[0].RecordTypeId = rtActivity;
        actList[0].Type__c = 'Gestione dati discordanti';
        actList[0].Order__c = ordList[2].Id;
        actList[0].Contact__c = contactList[0].Id;
        actList[0].Distributor__c = accList[0].Id;
        actList[0].AppointmentDate__c = Date.today();
        update actList;
        
    }
    

    @IsTest
    static void calculateRateCategoryOperatoreUgualeTest(){

        Order myOrder = [SELECT Id FROM Order where Name = 'testOrderName0'];

        Test.startTest();
        Boolean result = HDT_UTL_Order.calculateRateCategory(myOrder);
        Test.stopTest();

        System.assertEquals(true, result, 'result è false');
        
    }

    @IsTest
    static void calculateRateCategoryOperatoreDiversoTest(){

        Order myOrder = [SELECT Id FROM Order where Name = 'testOrderName0'];
        Account myAcc = [Select Id, Code__c from Account];
        RateCategory__c myRatCat = [Select Id, operatore__c from RateCategory__c];

        myAcc.Code__c = '34739564';
        update myAcc;
        myRatCat.operatore__c = 'Diverso';
        update myRatCat;

        Test.startTest();
        Boolean result = HDT_UTL_Order.calculateRateCategory(myOrder);
        Test.stopTest();

        System.assertEquals(true, result, 'result è false');
        
    }

    @IsTest
    static void calculateRateCategoryNATest(){

        Order myOrder = [SELECT Id FROM Order where Name = 'testOrderName0'];
        RateCategory__c myRatCat = [Select Id, operatore__c from RateCategory__c];

        myRatCat.operatore__c = 'N/A';
        update myRatCat;

        Test.startTest();
        Boolean result = HDT_UTL_Order.calculateRateCategory(myOrder);
        Test.stopTest();

        System.assertEquals(true, result, 'result è false');
        
    }

    @IsTest
    static void calculateRateCategoryNotResOperatoreUgualeTest(){

        Order myOrder = [SELECT Id FROM Order where Name = 'testOrderName0'];
        RateCategory__c myRatCat = [Select Id, operatore__c, ProductName__c from RateCategory__c];

        myRatCat.ProductName__c = 'N/A';
        update myRatCat;

        Test.startTest();
        Boolean result = HDT_UTL_Order.calculateRateCategory(myOrder);
        Test.stopTest();

        System.assertEquals(true, result, 'result è false');
        
    }

    @IsTest
    static void calculateRateCategoryNotResOperatoreDiversoTest(){

        Order myOrder = [SELECT Id FROM Order where Name = 'testOrderName0'];
        Account myAcc = [Select Id, Code__c from Account];
        RateCategory__c myRatCat = [Select Id, operatore__c, ProductName__c from RateCategory__c];

        myAcc.Code__c = '34739564';
        update myAcc;
        myRatCat.ProductName__c = 'N/A';
        myRatCat.operatore__c = 'Diverso';
        update myRatCat;

        Test.startTest();
        Boolean result = HDT_UTL_Order.calculateRateCategory(myOrder);
        Test.stopTest();

        System.assertEquals(true, result, 'result è false');
        
    }

    @IsTest
    static void calculateRateCategoryNotResNATest(){

        Order myOrder = [SELECT Id FROM Order where Name = 'testOrderName0'];
        RateCategory__c myRatCat = [Select Id, operatore__c, ProductName__c from RateCategory__c];

        myRatCat.ProductName__c = 'N/A';
        myRatCat.operatore__c = 'N/A';
        update myRatCat;

        Test.startTest();
        Boolean result = HDT_UTL_Order.calculateRateCategory(myOrder);
        Test.stopTest();

        System.assertEquals(true, result, 'result è false');
        
    }

    /*@IsTest
    static void travasaOrderTest(){

        List<Order> myOrderList = [SELECT Id, ExciseGas__c, ExciseEle__c, Vat__c, AnnualConsumption__c, MarketOrigin__c, ConnectionMandate__c,
        RecordTypeId, Market__c, PowerAvailable__c, VoltageLevel__c, recordType.DeveloperName, AllowSwitchInDummy__c, RequestOption__c,
        DisconnectibilityPhone__c, processType__c, MaxRequiredPotential__c, HerokuPracticeCode__c, UseTypeEnergy__c, SelfCertificationConnection__c,
        UseCategory__c, MeterSN__c, Resident__c, RemiCode__c, SupplyCity__c, CommercialProductVersion__c, CommercialProductCode__c,
        CommercialProduct__c, SupplyStreetName__c, SupplyStreetNumber__c, SupplyStreetNumberExtension__c, SupplyPlace__c,
        SupplyPostalCode__c, SupplyCountry__c, PowerCommitted__c, ServicePointCode__c, SAPImplantCode__c, ImplantType__c,
        SupplyCityCode__c, SupplyState__c, Disconnectable__c, DisconnectibilityType__c, ConnectionType__c, InstanceSelfCertification__c,
        MeterClass__c, PrecheckResultSII__c, Step__c, ProcessCode__c, WaiverRightAfterthought__c, HerAteco__c, AtecoCode__c,
        CommentForDL__c, PhoneNumber__c, RateCategory__c, WithdrawalClass__c, SupplyType__c, DistributorCode__c, PressureLevel__c,
        RequestPhase__c, PowerRequested__c, EnergyService__c, LiftingPeople__c, MeterType__c, IsRemoteManaged__c, CustomerRequestDate__c,
        Commodity__c, SubjectCode__c, InvoiceCertifiedEmailAddress__c, ElectronicInvoicingMethod__c, XMLType__c, CIG__c, CUP__c,
        IbanIsForeign__c, IbanCIN_IBAN__c, IbanCIN__c, IbanABI__c, IbanCAB__c, IbanCodeNumber__c, BankAccountSignatoryFiscalCode__c,
        BankAccountSignatoryFirstName__c, BankAccountSignatoryLastName__c, BillSendMode__c, PaymentMode__c, InvoiceEmailAddress__c,
        BillingCity__c, BillingCountry__c, BillingProvince__c, BillingStreetName__c, BillingStreetNumber__c, BillingStreetNumberExtension__c,
        BillingPostalCode__c, BillingCityCode__c, SignatoryType__c, SendCertifiedEmailConsentDate__c, CreateContractAccount__c,
        IbanCountry__c, isDatoDiscordante__c, Contact__c, OrderReference__c, AggregateBilling__c  FROM Order];

        Test.startTest();
        HDT_UTL_Order.travasaOrder(myOrderList[0], myOrderList[1]);
        Test.stopTest();

        System.assertNotEquals(0, myOrderList.size(), 'la lista non ha record');
        
    }*/

    @IsTest
    static void annullaContrattiTest(){

        Order myOrder = [SELECT Id, Status, Phase__c, CancellationReason__c FROM Order where Name = 'testOrderName0'];

        Test.startTest();
        Boolean result = HDT_UTL_Order.annullaContratti(myOrder.Id);
        Test.stopTest();

        System.assertEquals(true, result, 'result è false');
        
    }

    @IsTest
    static void checkToDiscordantiTest(){

        Order myOrder = [SELECT Id, ExciseGas__c, ExciseEle__c, Vat__c, AnnualConsumption__c, MarketOrigin__c, ConnectionMandate__c,
        RecordTypeId, Market__c, PowerAvailable__c, VoltageLevel__c, recordType.DeveloperName, AllowSwitchInDummy__c, RequestOption__c,
        DisconnectibilityPhone__c, processType__c, MaxRequiredPotential__c, HerokuPracticeCode__c, UseTypeEnergy__c, SelfCertificationConnection__c,
        UseCategory__c, MeterSN__c, Resident__c, RemiCode__c, SupplyCity__c, CommercialProductVersion__c, CommercialProductCode__c,
        CommercialProduct__c, SupplyStreetName__c, SupplyStreetNumber__c, SupplyStreetNumberExtension__c, SupplyPlace__c,
        SupplyPostalCode__c, SupplyCountry__c, PowerCommitted__c, ServicePointCode__c, SAPImplantCode__c, ImplantType__c,
        SupplyCityCode__c, SupplyState__c, Disconnectable__c, DisconnectibilityType__c, ConnectionType__c, InstanceSelfCertification__c,
        MeterClass__c, PrecheckResultSII__c, Step__c, ProcessCode__c, WaiverRightAfterthought__c, HerAteco__c, AtecoCode__c,
        CommentForDL__c, PhoneNumber__c, RateCategory__c, WithdrawalClass__c, SupplyType__c, DistributorCode__c, PressureLevel__c,
        RequestPhase__c, PowerRequested__c, EnergyService__c, LiftingPeople__c, MeterType__c, IsRemoteManaged__c, CustomerRequestDate__c,
        Commodity__c, SubjectCode__c, InvoiceCertifiedEmailAddress__c, ElectronicInvoicingMethod__c, XMLType__c, CIG__c, CUP__c,
        IbanIsForeign__c, IbanCIN_IBAN__c, IbanCIN__c, IbanABI__c, IbanCAB__c, IbanCodeNumber__c, BankAccountSignatoryFiscalCode__c,
        BankAccountSignatoryFirstName__c, BankAccountSignatoryLastName__c, BillSendMode__c, PaymentMode__c, InvoiceEmailAddress__c,
        BillingCity__c, BillingCountry__c, BillingProvince__c, BillingStreetName__c, BillingStreetNumber__c, BillingStreetNumberExtension__c,
        BillingPostalCode__c, BillingCityCode__c, SignatoryType__c, SendCertifiedEmailConsentDate__c, CreateContractAccount__c,
        IbanCountry__c, isDatoDiscordante__c, Contact__c, OrderReference__c, AggregateBilling__c FROM Order where Name = 'testOrderName0' LIMIT 1];

        Test.startTest();
        Boolean result = HDT_UTL_Order.checkToDiscordanti(myOrder.Id);
        Test.stopTest();

        System.assertEquals(true, result, 'result è false');
        
    }



}
