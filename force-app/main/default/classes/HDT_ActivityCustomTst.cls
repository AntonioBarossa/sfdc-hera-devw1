@isTest
public with sharing class HDT_ActivityCustomTst {

    @isTest
    public static void HDT_ActivityCustomTst() {
        
        HDT_UTL_DataFactoryTst.pClickInstanceActivityIntegration();

        List<Account> testAcc = HDT_UTL_DataFactoryTst.createAccountPartner(1,false, 'Pooyan');
        testAcc[0].CompanyOwner__c = 'HERA COMM';

        insert testAcc;

        Account acct = [SELECT id,Name FROM Account WHERE id =: testAcc[0].id ];


        List<wrts_prcgvr__Activity__c> testActCust = HDT_UTL_DataFactoryTst.createActivityCustom(1,true, acct.id);

        system.assertNotEquals('', testActCust[0].id , 'ActivityCustom is not created correctly (ActivityCustom id is not available)');

    }
}