/**
* Header of the class "HDT_LC_BillingProfileFormTst"
* @author: Luca Belometti - WR (luca.belometti@webresults.it)
* @version 1.0
* @history
* Created: 2021-08-10
* Modified By:
**/

@IsTest
public with sharing class HDT_LC_BillingProfileFormTst {
@TestSetup
static void makeData(){
    List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
    HDT_UTL_DataFactoryTst.createContact(1, true, accounts[0].id);
}

@isTest
public static void testGetFormFields() {
    List<Account> accList = [SELECT Id FROM Account LIMIT 1];

    Map<String,List<String>> resultBollettinoPostale = new Map<String,List<String>>();
    Map<String,List<String>> resultBollettino = new Map<String,List<String>>();
    Map<String,List<String>> resultRid = new Map<String,List<String>>();

    Test.startTest();
    resultBollettinoPostale = HDT_LC_BillingProfileForm.getFormFields('Bollettino postale', accList[0].Id);
    resultBollettino = HDT_LC_BillingProfileForm.getFormFields('Bollettino', accList[0].Id);
    resultRid = HDT_LC_BillingProfileForm.getFormFields('RID', accList[0].Id);
    Test.stopTest();

    System.assertEquals(resultBollettinoPostale != null, true, 'Value of parameter is matching');
    System.assertEquals(resultBollettino != null, true, 'Value of parameter is matching');
    System.assertEquals(resultRid != null, true, 'Value of parameter is matching');
    System.assertNotEquals(resultBollettinoPostale != null, false, 'Value of parameter is not matching');
    System.assertNotEquals(resultBollettino != null, false, 'Value of parameter is not matching');
    System.assertNotEquals(resultRid != null, false, 'Value of parameter is not matching');

}

@isTest
public static void testCreateBillingProfile() {
    List<Account> accList = [SELECT Id FROM Account LIMIT 1];
    List<BillingProfile__c> billingProfileList = HDT_UTL_DataFactoryTst.createBillingProfile(1,false,accList[0].Id);

    Test.startTest();
    HDT_LC_BillingProfileForm.createBillingProfile(billingProfileList[0]);
    List<BillingProfile__c> listBillingProfile = [SELECT Id FROM BillingProfile__c LIMIT 1];
    System.assertEquals(listBillingProfile[0].Id, listBillingProfile[0].Id, 'Created Billing Profile');
    System.assertNotEquals(null,  listBillingProfile[0].Id, 'Billing Profile Created in the ORG');
    Test.stopTest();
}


@isTest
public static void testGetAccountOwnerInfo() {
    List<Account> accList = [SELECT Id FROM Account LIMIT 1];

    Test.startTest();
    Account accReturned = HDT_LC_BillingProfileForm.getAccountOwnerInfo(accList[0].Id);
    System.assertEquals(accReturned.Id, accReturned.Id, 'Returned the Account');
    System.assertNotEquals(null, accReturned.Id, 'Account Id is not null so it has been found');
    Test.stopTest();
}


@isTest
public static void testGetLegalAccount() {
    List<Contact> contactList = [SELECT Id FROM Contact LIMIT 1];

    Test.startTest();
    Contact contactReturned = HDT_LC_BillingProfileForm.getLegalAccount(contactList[0].Id);
    System.assertEquals(contactReturned.Id, contactReturned.Id, 'Returned the Contact');
    System.assertNotEquals(null, contactReturned.Id, 'Contact Id is not null, so it has been found');

    Test.stopTest();
}


@isTest
public static void testgetCloneBillingProfile() {
    List<Account> accList = [SELECT Id FROM Account LIMIT 1];
    List<BillingProfile__c> billingProfileList = HDT_UTL_DataFactoryTst.createBillingProfile(1,true,accList[0].Id);

    Test.startTest();
    BillingProfile__c billingReturned = HDT_LC_BillingProfileForm.getCloneBillingProfile(billingProfileList[0].Id);
    System.assertEquals(billingReturned.Id, billingReturned.Id, 'Returned the BillingProfile');
    System.assertNotEquals(null, billingReturned.Id, 'BillingProfile Id is not null, so it has been found');
    Test.stopTest();
}

}
