/**
 * @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
 * @date 06/09/2021
 * @description HDT_SRV_Contact Test Classes
 * @history Lucas Fernandes 06/09/2021 – Created Class
 */
@isTest
public with sharing class HDT_SRV_ContactTst {
    
    private static HDT_SRV_Contact srvContact = new HDT_SRV_Contact();
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();

    @TestSetup
    static void setup(){
        
        Id adminUserProfileId = HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
 
        User internalUser = HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
 
        internalUser.UserPermissionsMarketingUser=true;
 
        insert internalUser;
 
        System.runAs(internalUser) {
 
            List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
            List<Contact> cttList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);

        }
    }

    @isTest
    public static void testCheckReadAccess() {
 
        User u = [SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            srvContact.checkReadAccess('Id');
 
            Test.stopTest();
        }
    }

    @isTest
    public static void testCheckCreateAccess() {

        User u = [SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){

            Test.startTest();

            Account acc = [SELECT Id FROM Account WHERE CustomerMarking__c = 'Azienda'];
            Contact ctt = new Contact(
                AccountId = acc.Id,
                FirstName = 'first',
                LastName = 'last',
                Company__c='HC+HCM+EENE',
			    CompanyOwner__c='HERA COMM'
            );

            srvContact.checkCreateAccess(ctt);

            test.stopTest();
        }
    }

    @isTest
    public static void testCreateRecord() {

        User u = [SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){

            Test.startTest();

            Account acc = [SELECT Id FROM Account WHERE CustomerMarking__c = 'Azienda'];
            Contact ctt = new Contact(
                AccountId = acc.Id,
                FirstName = 'first',
                LastName = 'last',
                Company__c='HC+HCM+EENE',
			    CompanyOwner__c='HERA COMM'
            );

            srvContact.createRecord(ctt);

            List<Contact> cttList = [SELECT Id FROM Contact WHERE Name = 'first last'];

            Test.stopTest();

            System.assertEquals(false, cttList.isEmpty(), 'Contact successfully created');

            System.assertNotEquals(true, cttList.isEmpty(), 'Contact was not created');
        }
    }

    @isTest
    public static void testCheckUpdateAccess() {

        User u = [SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){

            Test.startTest();

            Contact ctt = [SELECT Id FROM Contact WHERE CompanyOwner__c='HERA COMM'];

            srvContact.checkUpdateAccess(ctt);

            Test.stopTest();
        }
    }

    @isTest
    public static void testUpdateRecord() {

        User u = [SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){

            Test.startTest();

            Contact ctt = [SELECT Id, FirstName FROM Contact WHERE CompanyOwner__c='HERA COMM'];
            ctt.FirstName = 'updateName';

            srvContact.updateRecord(ctt);

            Contact updatedCtt = [SELECT Id, FirstName FROM Contact WHERE FirstName='updateName'];

            Test.stopTest();

            System.assertEquals('updateName', updatedCtt.FirstName, 'Contact successfully updated');

            System.assertNotEquals('test tester', updatedCtt.FirstName, 'Contact was not updated');
        }
    }

    @isTest
    public static void testUpdateRecordList() {

        User u = [SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){

            Test.startTest();

            List<Contact> ctt = [SELECT Id, FirstName FROM Contact WHERE CompanyOwner__c='HERA COMM'];
            ctt[0].FirstName = 'updateName';

            srvContact.updateRecord(ctt);

            Test.stopTest();

            Contact contact = [SELECT Id, FirstName FROM Contact WHERE CompanyOwner__c='HERA COMM'];

            System.assertEquals('updateName', contact.FirstName, 'Contact successfully updated');

            System.assertNotEquals('test tester', contact.FirstName, 'Contact was not updated');
        }
    }
}
