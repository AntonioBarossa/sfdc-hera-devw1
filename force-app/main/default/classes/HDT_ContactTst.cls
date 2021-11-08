@isTest
public with sharing class HDT_ContactTst {

    @isTest
    public static void contactTest() {

        List<Account> testAcc = HDT_UTL_DataFactoryTst.createAccountPartner(1,false, 'Pooyan');
        testAcc[0].CompanyOwner__c = 'HERA COMM';

        insert testAcc;

        id acctId =  testAcc[0].id;

       List<Contact> conTest = HDT_UTL_DataFactoryTst.createContact(1, true, acctId);

       id contId =  conTest[0].id;


       
        system.assertNotEquals('',  contId , 'Contact is not created correctly  (Trigger on Contact)');
        system.assertEquals(true, contId != null , 'Contact is empty(Trigger on Contact)');

    }
}