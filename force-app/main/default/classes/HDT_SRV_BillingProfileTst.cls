/**
* Header of the class "HDT_SRV_BillingProfileTst"
* @author: Luca Belometti WR (luca.belometti@webresults.it)
* @version 1.0
* @description: Test Class for the Creation and update of the BillingProfile records and its CRUD for fields
* @history
* Created: 2021-08-04
* Modified By:
**/

@isTest
public with sharing class HDT_SRV_BillingProfileTst {
	@TestSetup
	static void setup(){
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        HDT_UTL_DataFactoryTst.createBillingProfile(1, true, accList[0].Id);
    }


    @isTest
    static void testCreateRecord() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        BillingProfile__c bProfileTest = new BillingProfile__c();
        bProfileTest.Account__c =acc.Id;
        HDT_SRV_BillingProfile billingProfileClass = new HDT_SRV_BillingProfile();
        Test.startTest(); 
        billingProfileClass.createRecord(bProfileTest);
        List<BillingProfile__c> billingProfileList = [SELECT Id FROM BillingProfile__c];
        
        System.assertEquals(billingProfileList.size(), 2, 'There are 2 BillingProfile in the ORG in this moment, becasue we insert another record (the other is old from setup)');
        System.assertEquals(billingProfileList.size(), 1, 'Value of parameter is not matching');
        Test.stopTest();
    }

    
    @isTest
    static void testUpdateRecord() {
        BillingProfile__c bProfile = [SELECT Account__c FROM BillingProfile__c LIMIT 1];
        HDT_SRV_BillingProfile billingProfileClass = new HDT_SRV_BillingProfile();
        Test.startTest(); 
        billingProfileClass.checkAccessInit('Account__c','update');
        billingProfileClass.updateRecord(bProfile); 
        List<BillingProfile__c> billingProfileList = [SELECT Id FROM BillingProfile__c];
        System.assertEquals(billingProfileList.size(), 1, 'There are 1 BillingProfile in the ORG in this moment, because we just update the record');
        System.assertEquals(billingProfileList.size(), 0, 'Value of parameter is not matching');
        Test.stopTest();
    }

    
    @isTest
    static void testCrudUpdate() {
        HDT_SRV_BillingProfile billingProfileClass = new HDT_SRV_BillingProfile();
        Test.startTest(); 
        billingProfileClass.checkAccessInit('Account__c','update'); 
        Test.stopTest();
    }

    @isTest
    static void testCrudRead() {
        HDT_SRV_BillingProfile billingProfileClass = new HDT_SRV_BillingProfile();
        Test.startTest(); 
        billingProfileClass.checkAccessInit('Account__c','read');
        Test.stopTest();
    }


    @isTest
    static void testCheckReadAccess() {
        HDT_SRV_BillingProfile billingProfileClass = new HDT_SRV_BillingProfile();
        Test.startTest(); 
        billingProfileClass.checkReadAccess('BankAgency__c');
        Test.stopTest();
    }

    @isTest
    static void testCheckUpdateAccess() {
        HDT_SRV_BillingProfile billingProfileClass = new HDT_SRV_BillingProfile();
        Test.startTest(); 
        billingProfileClass.checkUpdateAccess('BankAgency__c');
        Test.stopTest();
    }

    @isTest
    static void testCheckCreateAccess() {
        HDT_SRV_BillingProfile billingProfileClass = new HDT_SRV_BillingProfile();
        Test.startTest(); 
        billingProfileClass.checkCreateAccess('BankAgency__c');
        Test.stopTest();
    }
}
