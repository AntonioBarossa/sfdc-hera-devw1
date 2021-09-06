/**
* Header of the class "HDT_SRV_CaseTst"
* @author: Luca Belometti 
* @version 1.0
* @description: Test class of the HDT_SRV_Case (CRUD and creation of case)
* @history
* Created: 2021-09-06
* Modified By:
**/

@IsTest
public with sharing class HDT_SRV_CaseTst {
@TestSetup
static void makeData(){
        List<Account> accList  = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].id);
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true); 
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Order> ordListInc = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].Id, 'Bozza');
		List<Case> listCase =  HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].Id, contactList[0].Id, servPointList[0].Id, contractList[0].Id, ordListInc[0].Id);
        HDT_UTL_DataFactoryTst.pClickCasePhase();

        HDT_UTL_Constants constantsUtl = new HDT_UTL_Constants();
        String rtName = constantsUtl.CASE_RECORDTYPE_DEVELOPERNAME_DOCUMENTALECOPIACONTRATTO;
        String rtId = constantsUtl.CASE_RECORDTYPEID_DOCUMENTALECOPIACONTRATTO;
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'In attesa Documentazione', 'Bozza', rtId, rtName,'A','','','');
	}

    @IsTest
    static void testCheckAccessInitCreat(){
        HDT_SRV_Case testingCrudCreate = new HDT_SRV_Case();
        Test.startTest();
        testingCrudCreate.checkAccessInit('IbanABI__c','create');
        Test.stopTest();
    }

    @IsTest
    static void testCheckAccessInitRead(){
        HDT_SRV_Case testingCrudRead = new HDT_SRV_Case();
        Test.startTest();
        testingCrudRead.checkReadAccess('IbanABI__c');
        Test.stopTest();
    }

    @IsTest
    static void testCheckAccessInitUpdate(){
        HDT_SRV_Case testingCrudUpdate = new HDT_SRV_Case();
        Test.startTest();
        testingCrudUpdate.checkUpdateAccess('IbanABI__c');
        Test.stopTest();
    }

    @IsTest
    static void testCheckAccessInitDelete(){
        HDT_SRV_Case testingCrudDelete = new HDT_SRV_Case();
        Test.startTest();
        testingCrudDelete.checkAccessInit('IbanABI__c','Delete');
        Test.stopTest();
    }

    @IsTest
    static void testCheckCreateAccess(){
        HDT_SRV_Case testingCrudDelete = new HDT_SRV_Case();
        Test.startTest();
        testingCrudDelete.checkCreateAccess('IbanABI__c');
        Test.stopTest();
    }

    @IsTest
    static void testCreateRecord(){
        HDT_SRV_Case methodToTest = new HDT_SRV_Case();
        List<Account> listaAcc = [SELECT Id FROM Account];
        List<Contact> listaContact = [SELECT Id FROM Contact];
        List<ServicePoint__c> listaServicePoint = [SELECT Id FROM ServicePoint__c];
        List<Contract> listaContract = [SELECT Id FROM Contract];
        List<Order> listaOrder = [SELECT Id FROM Order];

        List<Case> listCase =  HDT_UTL_DataFactoryTst.createCase(1, false, listaAcc[0].Id, listaContact[0].Id, listaServicePoint[0].Id, listaContract[0].Id, listaOrder[0].Id);
        Test.startTest();
        methodToTest.createRecord(listCase[0]);

        System.assertEquals(1, listCase.size(), 'Just Created a record of Case');
        System.assertNotEquals(2, listCase.size(), 'ListCase Contains the record just created');
        Test.stopTest();
    }

    @IsTest
    static void testUpdateRecord(){
        HDT_SRV_Case methodToTest = new HDT_SRV_Case();
        List<Account> listaAcc = [SELECT Id FROM Account];
        List<Contact> listaContact = [SELECT Id FROM Contact];
        List<ServicePoint__c> listaServicePoint = [SELECT Id FROM ServicePoint__c];
        List<Contract> listaContract = [SELECT Id FROM Contract];
        List<Order> listaOrder = [SELECT Id FROM Order];

        List<Case> listCase =  HDT_UTL_DataFactoryTst.createCaseDocumentale(1, true, listaAcc[0].Id, listaContact[0].Id, listaServicePoint[0].Id, listaContract[0].Id, listaOrder[0].Id);
        Test.startTest();
        methodToTest.updateRecord(listCase[0]);
        System.AssertEquals('Bozza',listCase[0].Phase__c,'Case Status is Bozza, taken also from the Phase.');
        System.AssertNotEquals(null,listCase[0].Phase__c,'Case Status is Bozza, taken also from the Phase, not null');
        Test.stopTest();
    }
    
}