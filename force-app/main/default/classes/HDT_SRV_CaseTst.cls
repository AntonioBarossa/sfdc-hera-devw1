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
		List<Case> listCase =  HDT_UTL_DataFactoryTst.createCase(1, false, accList[0].Id, contactList[0].Id, servPointList[0].Id, contractList[0].Id, ordListInc[0].Id);
        listCase[0].Phase__c = 'Da Inviare';
        insert listCase;
        HDT_UTL_DataFactoryTst.pClickCasePhase();

        HDT_UTL_Constants constantsUtl = new HDT_UTL_Constants();
        String rtName = constantsUtl.CASE_RECORDTYPE_DEVELOPERNAME_DOCUMENTALECOPIACONTRATTO;
        String rtId = constantsUtl.CASE_RECORDTYPEID_DOCUMENTALECOPIACONTRATTO;
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'In attesa Documentazione', 'Bozza', rtId, rtName,'A','','','');
	}

    @IsTest
    static void testCheckAccessInitCreat(){
        HDT_SRV_Case testingCrudCreate = new HDT_SRV_Case();
        
        try{
            Test.startTest();
            testingCrudCreate.checkAccessInit('IbanABI__c','create');
            Test.stopTest();
        }
        catch(exception e){
            system.assertEquals(true, string.isBlank(e.getMessage()), 'The user does not have create access');
        }
    }

    @IsTest
    static void testCheckAccessInitRead(){
        HDT_SRV_Case testingCrudRead = new HDT_SRV_Case();
        
        try{
            Test.startTest();
        testingCrudRead.checkReadAccess('IbanABI__c');
        Test.stopTest();
        }
        catch(exception e){
            system.assertEquals(true, string.isBlank(e.getMessage()), 'The user does not have read access');
        }
    }

    @IsTest
    static void testCheckAccessInitUpdate(){
        HDT_SRV_Case testingCrudUpdate = new HDT_SRV_Case();
        
        try{
            Test.startTest();
            testingCrudUpdate.checkUpdateAccess('IbanABI__c');
            Test.stopTest();
        }
        catch(exception e){
            system.assertEquals(true, string.isBlank(e.getMessage()), 'The user does not have update access');
        }
        
        
    }

    @IsTest
    static void testCheckAccessInitDelete(){
        HDT_SRV_Case testingCrudDelete = new HDT_SRV_Case();
        
        try{
            Test.startTest();
            testingCrudDelete.checkAccessInit('IbanABI__c','Delete');
            Test.stopTest();
        }
        catch(exception e){
            system.assertEquals(true, string.isBlank(e.getMessage()), 'The user does not have Delete access');
        }
    }

    @IsTest
    static void testCheckCreateAccess(){
        HDT_SRV_Case testingCrudDelete = new HDT_SRV_Case();
        
        try{
            Test.startTest();
            testingCrudDelete.checkCreateAccess('IbanABI__c');
            Test.stopTest();
        }
        catch(exception e){
            system.assertEquals(true, string.isBlank(e.getMessage()), 'The user does not have Create access');
        }
        
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

        System.assertEquals(true, String.isNotBlank(listCase[0].Id), 'Just Created a record of Case');
        System.assertNotEquals(false, String.isNotBlank(listCase[0].Id), 'ListCase Contains the record just created');
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

        List<Case> listCase =  HDT_UTL_DataFactoryTst.createCaseDocumentale(1, false, listaAcc[0].Id, listaContact[0].Id, listaServicePoint[0].Id, listaContract[0].Id, listaOrder[0].Id);
        listCase[0].SuppliedName = 'TestName';
        insert listCase;
        Test.startTest();
        listCase[0].SuppliedName = 'UpdatedTestName';
        methodToTest.updateRecord(listCase[0]);
        List<Case> updatedCase = [SELECT Id, SuppliedName FROM Case WHERE Id = :listCase[0].Id];
        System.AssertEquals('UpdatedTestName',updatedCase[0].SuppliedName,'Case SuppliedName is UpdatedTestName, correctly updated from the TestName --Old Name.');
        System.AssertNotEquals('TestName',updatedCase[0].SuppliedName,'Case SuppliedName is UpdatedTestName, correctly updated from the TestName --Old Name.');
        Test.stopTest();
    }
    
}