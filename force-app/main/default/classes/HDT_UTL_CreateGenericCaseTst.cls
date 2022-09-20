/*
    @Author:        Francesco Vitiello
    CreatedDate:    05/10/2021
*/
@SuppressWarnings('PMD.AvoidDebugStatements')
@isTest
public with sharing class HDT_UTL_CreateGenericCaseTst {

    
    //DEBUG
    public static final String TEST_NAME = 'HDT_UTL_CreateGenericCaseTst';
    
    
    //TEST SETUP

    @TestSetup
    static void setup() {

        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
            
    }
    
    
    //TESTS

    @isTest
    private static void createCaseFromCaseTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'createCaseFromCaseTest';
        System.debug(debugString);
        
        //SETUP      

        Map<String, Object> myMap = new Map<String, Object>();
        Case testCase = [SELECT Id, recordTypeId, type, Cluster__c FROM Case LIMIT 1];
        myMap.put('recordTypeId', testCase.recordTypeId);
        myMap.put('type', testCase.type);
        myMap.put('cluster', testCase.Cluster__c);
        myMap.put('inputSObj', testCase);

        
        //TESTING
        Test.startTest();
        Try{
            
            HDT_UTL_CreateGenericCase myClass = new HDT_UTL_CreateGenericCase();
            myClass.createCaseFromCase(myMap);


        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(myMap != null, 'Attenzione, myMap non può essere null!');
        System.assert(testCase != null, 'Attenzione, testCase non può essere null!');

    }

    @isTest
    private static void createCaseFromOrderTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'createCaseFromCaseTest';
        System.debug(debugString);
        
        //SETUP      

        Map<String, Object> myMap = new Map<String, Object>();
        Case testCase = [Select Id, recordTypeId, type, Cluster__c from Case LIMIT 1];
        Order testOrder = [Select Id, AccountId, Contact__c, CompanyOwner__c, ResidentialCity__c, ResidentialCityCode__c,
         ResidentialCountry__c, ResidentialIsAddressVerified__c, ResidentialPlace__c, ResidentialPostalCode__c,
         ResidentialState__c, ResidentialStreetName__c, ResidentialStreetNumber__c, BillingProfile__c,
         BillingCity__c, BillingCityCode__c, BillingCountry__c, BillingIsAddressVerified__c, BillingPlace__c,
         BillingPostalCode__c, BillingProvince__c, BillingStreetName__c, BillingStreetNumber__c,
         SupplyCity__c, SupplyCityCode__c, SupplyCountry__c, SupplyIsAddressVerified__c, SupplyPlace__c,
         SupplyPlaceCode__c, SupplyPostalCode__c, SupplyState__c, SupplyStreetName__c, SupplyStreetNumber__c,
         SupplyType__c, VAT__c, AtecoCode__c, Market__c, ContractId, ServicePoint__c, Disconnectable__c, SubjectCode__c,
         DistributorCode__c, CustomerName__c, CustomerLastName__c, CustomerVATNumber__c,CustomerFiscalCode__c, Resident__c from Order LIMIT 1];
        myMap.put('recordTypeId', testCase.recordTypeId);
        myMap.put('type', testCase.type);
        myMap.put('cluster', testCase.Cluster__c);
        myMap.put('inputSObj', testOrder);

        
        //TESTING
        Test.startTest();
        Try{
            
            HDT_UTL_CreateGenericCase myClass = new HDT_UTL_CreateGenericCase();
            myClass.createCaseFromOrder(myMap);


        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(myMap != null, 'Attenzione, myMap non può essere null!');
        System.assert(testCase != null, 'Attenzione, testCase non può essere null!');

    }

    @isTest
    private static void createCaseTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'createCaseFromCaseTest';
        System.debug(debugString);
        
        //SETUP      

        Map<String, Object> myMap = new Map<String, Object>();
        Case testCase = [Select Id, recordTypeId, type, Cluster__c, AccountId, Contact.Id, CompanyOwner__c, ServicePoint__r.Id, HerokuPracticeCode__c from Case LIMIT 1];
        myMap.put('recordTypeId', testCase.recordTypeId);
        myMap.put('type', testCase.type);
        myMap.put('cluster', testCase.Cluster__c);
        myMap.put('accountId', testCase.AccountId);
        myMap.put('contactId', testCase.Contact.Id);
        myMap.put('companyOwner', testCase.CompanyOwner__c);
        myMap.put('servicePointId', testCase.ServicePoint__r.Id);
        myMap.put('HerokuPracticeCode__c', testCase.HerokuPracticeCode__c);

        
        //TESTING
        Test.startTest();
        Try{
            
            HDT_UTL_CreateGenericCase myClass = new HDT_UTL_CreateGenericCase();
            myClass.createCase(myMap);


        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(myMap != null, 'Attenzione, myMap non può essere null!');
        System.assert(testCase != null, 'Attenzione, testCase non può essere null!');

    }

    @isTest
    private static void createCaseFromFlowCaseTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'createCaseFromFlowCaseTest';
        System.debug(LoggingLevel.DEBUG, debugString);
        
        //SETUP      

        Case testCase = [SELECT Id, recordTypeId, type, Cluster__c FROM Case LIMIT 1];

        List<HDT_UTL_CreateGenericCase.HDT_UTL_FlowInputsCreaCase> inputs = new List<HDT_UTL_CreateGenericCase.HDT_UTL_FlowInputsCreaCase>();
        HDT_UTL_CreateGenericCase.HDT_UTL_FlowInputsCreaCase input = new HDT_UTL_CreateGenericCase.HDT_UTL_FlowInputsCreaCase();
        input.caseCluster = testCase.Cluster__c;
        input.caseType = testCase.type;
        input.inputSObj = testCase;
        input.recordTypeId = testCase.recordTypeId;
        inputs.add(input);

        List<HDT_UTL_CreateGenericCase.HDT_UTL_FlowOutputsCreaCase> outputResults = new List<HDT_UTL_CreateGenericCase.HDT_UTL_FlowOutputsCreaCase>();
        
        //TESTING
        Test.startTest();
        try{
            outputResults = HDT_UTL_CreateGenericCase.createCaseFromCaseForFlow(inputs);
        }catch(DmlException e) {
            System.debug(LoggingLevel.DEBUG, 'The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(outputResults != null, 'Attenzione, myMap non può essere null!');
        System.assert(testCase != null, 'Attenzione, testCase non può essere null!');

    }

}