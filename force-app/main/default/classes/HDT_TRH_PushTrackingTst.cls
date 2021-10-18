/**
* @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
* @date 10/08/2021
* @description Test Class for HDT_TRH_PushTracking
* @history Lucas da Silva Fernandes – 10/08/2021 – Created class
* !history Lucas da Silva Fernandes - 23/08/2021 - Added TestSetup
*/
@isTest
public with sharing class HDT_TRH_PushTrackingTst {
    
    @TestSetup
    static void setup(){

        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
        
        PushTracking__c pt = new PushTracking__c(CompanyOwner__c = 'HERA COMM');
        pt.ContactID__c = contactList[0].ID;
        insert pt;

    }

    @isTest
    public static void testPushTrackingBeforeInsert() {

        Test.startTest();

        PushTracking__c ptTest = [SELECT Id, CompanyOwner__c FROM PushTracking__c WHERE CompanyOwner__c = 'HERA COMM' LIMIT 1];

        System.assertEquals('HERA COMM', ptTest.CompanyOwner__c, 'CompanyOwner match.');

        System.assertNotEquals('', ptTest.CompanyOwner__c, 'Company Owner does not match.');

        Test.stopTest();
    }
}
