/*
    @Author:        Francesco Vitiello
    CreatedDate:    17/09/2021
*/

@isTest
public with sharing class HDT_UTL_CaseTst {
    
    //TEST SETUP
    @TestSetup
    static void makeData()
    {
        HDT_UTL_DataFactoryTst.pClickCasePhase();

        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        ServicePoint__c myServicePoint = servPointList[0];
        myServicePoint.CommoditySector__c = 'Energia Elettrica';
        update myServicePoint;
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        contractList[0].StartDate = Date.today();
        update contractList;
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);

        
        wrts_prcgvr__ActivityTemplate__c myactivityTemplate = new wrts_prcgvr__ActivityTemplate__c();
        myactivityTemplate.Name = 'myPClickTestTemplate';
        myactivityTemplate.wrts_prcgvr__Assignees__c = 'my text Assignee';
        myactivityTemplate.wrts_prcgvr__Subject__c = 'my text Subject';
        myactivityTemplate.wrts_prcgvr__DueDateField__c = 'my text Due Date Field';
        insert myactivityTemplate;

        List<City__c> cityList = new List<City__c>();
        cityList.add(new City__c(Name='TEST',Province__c='TS',SDV__C='HCM'));
        cityList.add(new City__c(Name='TESTHC',Province__c='TA',SDV__C='HC'));
        cityList.add(new City__c(Name='TESTEENE',Province__c='TE',SDV__C='EENE'));
        insert cityList;

        List<AtecoMatrix__c>matrixEntries=new List<atecoMatrix__c>();
        matrixEntries.add(new AtecoMatrix__c(AtecoCode__c='9999',City__c='TEST'));
        matrixEntries.add(new AtecoMatrix__c(AtecoCode__c='9998',City__c='TESTHC'));
        matrixEntries.add(new AtecoMatrix__c(AtecoCode__c='9997',City__c='TESTEENE'));
        insert matrixEntries;

        AllineamentoGAA__c gaaAlignment1 = new AllineamentoGAA__c();
        gaaAlignment1.Rate_Category__c = 'ACDOMRESP0';
        insert gaaAlignment1;


    }
    
    //TESTS

    @isTest
    private static void caseFlowPredefaultsTest(){

        List<Case> caseList = [SELECT Id, Note__c, Type,Distributor__r.Code__c, ParentId, PODPDRFormula__c FROM Case];

        Case myCase = caseList[0];
        myCase.Note__c = 'Note';
        myCase.type = 'Nuovo Impianto';
        myCase.Commodity__c='Acqua';
        myCase.SupplyCity__c='TEST';
        update myCase;



        List<HDT_UTL_Case.HDT_UTL_FlowInputs> inputs = new List<HDT_UTL_Case.HDT_UTL_FlowInputs>();
        HDT_UTL_Case.HDT_UTL_FlowInputs myInput = new HDT_UTL_Case.HDT_UTL_FlowInputs();

        Date myDate = Date.newInstance(2021, 09, 16);
        myInput.cluster = 'Preventivi';
        myInput.process = '';
        myInput.effectiveDate = myDate;
        myInput.implantType = '13CB-Non domestici in BT';
        myInput.powerRequested = 5.5;
        myInput.salesCompany = 'mySalesCompany';
        myInput.currentCase = myCase;
        myInput.genericInputString = '';

        inputs.add(myInput);
        
        //TESTING
        Test.startTest();
        Try{

            HDT_UTL_Case.caseFlowPredefaults(inputs);

            myInput.powerRequested = 0;
            HDT_UTL_Case.caseFlowPredefaults(inputs);
            myInput.powerRequested = 0.9;
            HDT_UTL_Case.caseFlowPredefaults(inputs);
            myInput.powerRequested = 2.5;
            HDT_UTL_Case.caseFlowPredefaults(inputs);
            myInput.powerRequested = 7.5;
            HDT_UTL_Case.caseFlowPredefaults(inputs);
            myInput.powerRequested = 12.5;
            HDT_UTL_Case.caseFlowPredefaults(inputs);
            myInput.powerRequested = 18.5;
            HDT_UTL_Case.caseFlowPredefaults(inputs);

            myInput.implantType = '13EM-Non domestici MT';
            HDT_UTL_Case.caseFlowPredefaults(inputs);
            myInput.powerRequested = 0;
            HDT_UTL_Case.caseFlowPredefaults(inputs);
            myInput.powerRequested = 108.5;
            HDT_UTL_Case.caseFlowPredefaults(inputs);
            myInput.powerRequested = 508.5;
            HDT_UTL_Case.caseFlowPredefaults(inputs);

            myInput.implantType = '13DM-Illuminazione pubblica MT';
            HDT_UTL_Case.caseFlowPredefaults(inputs);

            myInput.implantType = '13FM-Non domestici AT';
            HDT_UTL_Case.caseFlowPredefaults(inputs);

            myInput.implantType = '13A0-Usi di Abitazione BT';
            HDT_UTL_Case.caseFlowPredefaults(inputs);

            myInput.implantType = '13BB-Illuminazione pubblica BT';
            HDT_UTL_Case.caseFlowPredefaults(inputs);

        
            myInput.process = 'Voltura Tecnica';
            HDT_UTL_Case.caseFlowPredefaults(inputs);

            myInput.cluster = 'myCluster';        
            myInput.process = 'Compatibilita';
            HDT_UTL_Case.caseFlowPredefaults(inputs);

            myInput.process = 'Contenitore';
            HDT_UTL_Case.caseFlowPredefaults(inputs);

          /*   myInput.process = 'CreaBpCa';
            HDT_UTL_Case.caseFlowPredefaults(inputs); */

            myInput.process = 'CheckIsCommunity';
            HDT_UTL_Case.caseFlowPredefaults(inputs);

            myInput.process = 'Annullamento';
            HDT_UTL_Case.caseFlowPredefaults(inputs);

            myInput.process = 'getServicePointFromContract';
            HDT_UTL_Case.caseFlowPredefaults(inputs);


            /* myInput.process = 'calculateExpirationDate';
            myInput.cluster = 'Reclami';
            HDT_UTL_Case.caseFlowPredefaults(inputs); */
            

            myInput.process = 'Adesione Rinuncia Fondo Fughe';
            myInput.cluster = 'Variazioni';
            //myInput.joinBottomAdhesion = 'Y';
            HDT_UTL_Case.caseFlowPredefaults(inputs);

            myInput.process = 'Modifica Unita Immobiliari Componenti';
            myInput.cluster = 'Variazioni';
            myCase.RateCategory__c = 'ACDOMRESP0';
            update myCase;
            HDT_UTL_Case.caseFlowPredefaults(inputs);
        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(caseList != null, 'Attenzione, caseList non può essere null!');
        System.assert(inputs != null,  'Attenzione, inputs non può essere null!');
        
    }

    @isTest
    static void removeFacilityBundle(){

        Test.startTest();
        List<Account> accs = [Select id FROM Account];
        HDT_UTL_DataFactoryTst.pClickInstance();
		HDT_UTL_DataFactoryTst.pClickOrderPhase();
        Id pricebookId = Test.getStandardPricebookId();
        
        List<Sale__c> sales = HDT_UTL_DataFactoryTst.createSale(1, true, accs[0].id, 'Bozza');
        
        List<ServicePoint__c> points = HDT_UTL_DataFactoryTst.createServicePoint(1, false);
        points[0].CommoditySector__c = 'Gas';
        insert points;
        Test.stopTest();
        
        List<Order> orders = HDT_UTL_DataFactoryTst.createOrderWithPricebook(1, false, accs[0].id, sales, pricebookId);
        orders[0].ServicePointCode__c = 'servicepointcode';
        orders[0].HerokuPracticeCode__c = 'herokucode';
        orders[0].SupplyType__c = 'Domestico';
        orders[0].ServicePoint__c = points[0].id;
        insert orders;
        
        List<Product2> prods = HDT_UTL_DataFactoryTst.createProduct2(1, false);
        prods[0].Family = 'Bonus Percentuale';
        prods[0].Name = 'Bonus Percentuale GAS Pippo';
        prods[0].Version__c = 'V1';
        insert prods;
        
        List<PricebookEntry> entries = HDT_UTL_DataFactoryTst.createPricebookEntry(prods, true, pricebookId);
        
        HDT_UTL_DataFactoryTst.createOrderItem(1, true, orders[0].id, points[0].id, prods[0].id, entries[0].id);

        List<HDT_UTL_Case.HDT_UTL_FlowInputs> inputs = new List<HDT_UTL_Case.HDT_UTL_FlowInputs>();
        HDT_UTL_Case.HDT_UTL_FlowInputs myInput = new HDT_UTL_Case.HDT_UTL_FlowInputs();

        myInput.process = 'RemoveFacilityBundle';
        myInput.quoteId='';
        inputs.add(myInput);
        System.assert(HDT_UTL_Case.caseFlowPredefaults(inputs) != null, 'Attenzione, result non può essere null!');
    }
    
    @isTest
    private static void createActivityTest(){
        
        List<Case> caseList = [SELECT Id FROM Case];
        String idCase = caseList[0].Id;


        //TESTING
        Test.startTest();
        Try{

            HDT_UTL_Case.createActivity(idCase, 'my Test', 'myPClickTestTemplate', '');
            
            
        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(caseList != null, 'Attenzione, caseList non può essere null!');
        System.assert(idCase != null, 'Attenzione, idCase non può essere null!');
        
    }


    @IsTest
    static void createServiceRequestFromCasesTst()
    {
        List<Case> caseList = [SELECT Id,CommodityFormula__c,PODPDRFormula__c,ServicePoint__c FROM Case];

        Test.startTest();
            List<ServiceRequest__c> result = HDT_UTL_Case.createServiceRequestFromCases(caseList);
        Test.stopTest();

        System.assertEquals(true, !result.isEmpty(), 'Service Request create con successo');

    }

    @IsTest
    static void calculateTransitionTst()
    {
        List<Case> caseList = [SELECT Id, Type, SupplyCity__c, Commodity__c, Distributor__r.Code__c FROM Case];
        caseList[0].SupplyCity__c = 'TEST';
        caseList[0].Commodity__c = 'Energia Elettrica';
        caseList[0].Type = 'Nuovo Impianto';

        List<HDT_UTL_Case.HDT_UTL_FlowInputs> inputs = new List<HDT_UTL_Case.HDT_UTL_FlowInputs>();
        HDT_UTL_Case.HDT_UTL_FlowInputs input = new HDT_UTL_Case.HDT_UTL_FlowInputs();

        input.implantType = '';
        input.powerRequested = 0;
        input.cluster = 'Preventivi';
        input.currentCase = caseList[0];

        inputs.add(input);
        Test.startTest();
            List<HDT_UTL_Case.HDT_UTL_FlowOutputs> result = HDT_UTL_Case.caseFlowPredefaults(inputs);
            inputs[0].currentCase.SupplyCity__c='TESTHC';
            result.addAll(HDT_UTL_Case.caseFlowPredefaults(inputs));
            inputs[0].currentCase.SupplyCity__c='TESTEENE';
            result.addAll(HDT_UTL_Case.caseFlowPredefaults(inputs));
        Test.stopTest();
        System.assertEquals(true, !result.isEmpty(), 'Test Fallito');
    }

    /**​
    * @author Elvin Iluca
    * @date 02/11/2022
    * @description HDT_UTL_CaseTst – Test Class for HDT_UTL_Case.cls
    */

    @isTest
    static void calculateSalesCompanyCodeHcTst(){
        String ret;
        Test.startTest();
        ret = HDT_UTL_Case.calculateSalesCompanyCode('HC');
        Test.stopTest();
        System.assertEquals('13V0000000', ret, 'Error calculate sales company');
    }

    @isTest
    static void calculateSalesCompanyCodeHcmTst(){
        String ret;
        Test.startTest();
        ret = HDT_UTL_Case.calculateSalesCompanyCode('HCM');
        Test.stopTest();
        System.assertEquals('10V0000160', ret, 'Error calculate sales company');
    }

    @isTest
    static void calculateSalesCompanyCodeElseTst(){
        String ret;
        Test.startTest();
        ret = HDT_UTL_Case.calculateSalesCompanyCode('Else');
        Test.stopTest();
        System.assertEquals('13V0000000', ret, 'Error calculate sales company');
    }
}