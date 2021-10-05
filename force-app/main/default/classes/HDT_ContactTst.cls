@isTest
public with sharing class HDT_ContactTst {

    @isTest
    public static void HDT_ContactTst() {

        List<Account> testAcc = HDT_UTL_DataFactoryTst.createAccountPartner(1,false, 'Pooyan');
        testAcc[0].CompanyOwner__c = 'HERA COMM';

        insert testAcc;

        Account acct = [SELECT id,Name FROM Account WHERE id =: testAcc[0].id ];

       List<Contact> ConTest = HDT_UTL_DataFactoryTst.createContact(1, true, acct.id);

       Contact con = [SELECT id FROM Contact WHERE id =: ConTest[0].id ];


       
        system.assertNotEquals('',  con.id , 'Contact is not created correctly  (Trigger on Contact)');
        system.assertEquals(true, con.id != null , 'Contact is empty(Trigger on Contact)');

    }
}
