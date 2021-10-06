@isTest
public with sharing class HDT_BillingProfileTst {
    @isTest
    public static void billingProfileTstInsert() {

        List<Account> testAcc = HDT_UTL_DataFactoryTst.createAccountPartner(1,false, 'Pooyan');
        testAcc[0].CompanyOwner__c = 'HERA COMM';

        insert testAcc;

        List<BillingProfile__c> billTest = HDT_UTL_DataFactoryTst.createBillingProfile( 1, true, testAcc.get(0).Id);


        system.assertNotEquals('', billTest[0].id , 'BillingProfile__c is not created correctly (BillingProfile__c id is not available)');
        system.assertEquals(true, billTest[0].id != null , 'BillingProfile__c was not created correctly');

    }
}
