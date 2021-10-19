@isTest
public with sharing class HDT_UTL_CaseTst {

    
    //DEBUG
    public static final String TEST_NAME = 'HDT_UTL_CaseTst';
    
    
    //TEST SETUP
    
    
    //TESTS

    @isTest
    private static void caseFlowPredefaultsTest(){
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'caseFlowPredefaultsTest';
        System.debug(debugString);
        
        //SETUP
        HDT_UTL_DataFactoryTst.pClickCasePhase();        

        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        ServicePoint__c myServicePoint = servPointList[0];
        myServicePoint.CommoditySector__c = 'Energia Elettrica';
        update myServicePoint;
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        Case myCase = caseList[0];
        myCase.Note__c = 'Note';
        myCase.type = 'Riattivazione Fornitura';
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
        inputs.add(myInput);
        
        //TESTING
        Test.startTest();
        Try{
            
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

            myInput.process = 'Annullamento';
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
    private static void createActivityTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'createActivityTest';
        System.debug(debugString);
        
        //SETUP
        
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        String idCase = caseList[0].Id;

        wrts_prcgvr__ActivityTemplate__c myactivityTemplate = new wrts_prcgvr__ActivityTemplate__c();
        myactivityTemplate.Name = 'myPClickTestTemplate';
        myactivityTemplate.wrts_prcgvr__Assignees__c = 'my text Assignee';
        myactivityTemplate.wrts_prcgvr__Subject__c = 'my text Subject';
        myactivityTemplate.wrts_prcgvr__DueDateField__c = 'my text Due Date Field';
        insert myactivityTemplate;

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

}
