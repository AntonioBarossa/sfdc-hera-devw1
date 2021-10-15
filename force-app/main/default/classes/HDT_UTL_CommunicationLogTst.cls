/**
* @author Luis Bispo (luis.bispo@engdb.com.br)
* @date 27/07/2021
* @description HDT_UTL_CommunicationLog for Test Classes
* @history Luis Bispo – 27/07/2021 – Created class
*/
@isTest
public with sharing class HDT_UTL_CommunicationLogTst {
    @TestSetup
    static void setup(){
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        List<Account> acc = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, acc[0].Id, 'Bozza');
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, acc[0].Id);
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, acc[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, acc[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
    }

    @isTest
    public static void testInstanceCommunicationLog(){
        Case tCase = [SELECT Id FROM Case LIMIT 1];
        Contact tContact = [SELECT Id FROM Contact LIMIT 1];
        Order tOrder = [SELECT Id FROM Order LIMIT 1];
        Account tAccount = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        CommunicationLog__c communicationLog = new HDT_UTL_CommunicationLog().instanceCommunicationLog('cluster', 'process', 'phase', 'status', 'motivazioneCausale', tOrder.Id, tCase.Id,  tContact.Id, tAccount.Id, 'company', 'companyOwner');
        System.assertEquals(communicationLog != null, true,'Instance Communication Log OK');
        System.assertNotEquals(communicationLog == null, true,'Instance Communication Log OK');
        Test.stopTest();
    }
}
