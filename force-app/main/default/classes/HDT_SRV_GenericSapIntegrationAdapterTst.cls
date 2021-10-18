@isTest
public with sharing class HDT_SRV_GenericSapIntegrationAdapterTst {
    
    @TestSetup
    static void setup(){

        HDT_UTL_DataFactoryTst.pClickCasePhase();
        List<Account> acc = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<BillingProfile__c> bpf = HDT_UTL_DataFactoryTst.createBillingProfile(1, true, acc[0].Id);
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, acc[0].Id, 'Bozza');
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, acc[0].Id);
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, acc[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, acc[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
    }

    @IsTest
    static void testGenerateJson(){
        
        //query required entity
        Case cs = [SELECT Id FROM Case WITH SECURITY_ENFORCED LIMIT 1];

        //setup for test
        HDT_WRP_GenericSapIntegration sapIntegrationWrapper = new HDT_WRP_GenericSapIntegration();
        sapIntegrationWrapper.requestType = 'TestSapWsConfiguration';
        sapIntegrationWrapper.recordId = cs.Id;

        //test
        Test.startTest();
        
        HDT_WRP_GenericSapIntegration result = HDT_SRV_GenericSapIntegrationAdapter.generateJson(sapIntegrationWrapper);

        //assertions
        System.assertEquals('TestSapWsConfiguration', result.requestType, 'requestType != TestSapWsConfiguration');
        System.assertNotEquals(null, result.requestBody, 'requestBody == null');
        System.assertEquals(null, result.responseBody, 'responseBody != null');
        Test.stopTest();
        
    }
}
