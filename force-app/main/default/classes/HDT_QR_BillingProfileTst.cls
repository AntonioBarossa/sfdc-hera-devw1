/**
* @author Luis Bispo (luis.bispo@engdb.com.br)
* @date 22/07/2021
* @description HDT_QR_BillingProfile for Test Classes
* @history Luis Bispo – 22/07/2021 – Created class
*/

@isTest
public with sharing class HDT_QR_BillingProfileTst {

    @TestSetup
    static void setup(){
        BillingProfile__c bp = new BillingProfile__c();
        bp.ContractAccountCode__c = 'test';
        insert bp;
    }

    @isTest
    public static void testGetRecordById(){
        BillingProfile__c billingProfile = [SELECT Id FROM BillingProfile__c LIMIT 1];
        Test.startTest();
        BillingProfile__c testBp = new HDT_QR_BillingProfile().getRecordById(billingProfile.Id);

		System.assert(testBp != null, 'getRecordById did not work correctly');
		System.assertNotEquals(null, testBp, 'getRecordById did not work correctly');

        Test.stopTest();
    }

    @isTest
    public static void testGetRecordsByAccount(){
        Test.startTest();
        List<BillingProfile__c> testBp = new HDT_QR_BillingProfile().getRecordsByAccount('accountId Test');

        System.assert(testBp.isEmpty(), 'getRecordsByAccount did not work correctly');
		System.assertNotEquals(new List<BillingProfile__c>{new BillingProfile__c()}, testBp, 'getRecordsByAccount did not work correctly');
        Test.stopTest();
    }

    @isTest
    public static void testGetRecordByContractAccountSucess(){
        BillingProfile__c billingProfile = [SELECT Id,ContractAccountCode__c FROM BillingProfile__c LIMIT 1];

        Test.startTest();
        BillingProfile__c testBp = new HDT_QR_BillingProfile().getRecordByContractAccount(billingProfile.ContractAccountCode__c);
        System.assert(testBp != null, 'getRecordByContractAccountSucess did not work correctly');
		System.assertNotEquals(null, testBp, 'getRecordByContractAccountSucess did not work correctly');

        Test.stopTest();
    }

    @isTest
    public static void testGetRecordByContractAccountFail(){
        Test.startTest();
        BillingProfile__c testBp = new HDT_QR_BillingProfile().getRecordByContractAccount('Test Fail');
        System.assert(testBp == null, 'getRecordByContractAccountFail did not work correctly');
		System.assertNotEquals(new BillingProfile__c(), testBp, 'getRecordByContractAccountFail did not work correctly');
        Test.stopTest();
    }
    
}
