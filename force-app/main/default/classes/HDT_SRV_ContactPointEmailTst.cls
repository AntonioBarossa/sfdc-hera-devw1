/**
 * @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
 * @date 08/09/2021
 * @description HDT_SRV_ContactPointPhone Test Classes
 * @history Lucas Fernandes 08/09/2021 – Created Class
 */

@isTest
public with sharing class HDT_SRV_ContactPointEmailTst {

    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
	
	@TestSetup
    static void setup(){
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
 
        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
 
        internalUser.UserPermissionsMarketingUser=true;
 
        insert internalUser;
 
        System.runAs(internalUser) {
 
            List<Individual> ind = HDT_UTL_DataFactoryTst.createIndividual(1, true);
            List<ContactPointEmail> cpeList = HDT_UTL_DataFactoryTst.createContactPointEmail(1, true, ind[0].Id);   
        }
    }
	
	@isTest
    public static void testCheckCreateAccess() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            ContactPointEmail cpe = [SELECT Id FROM ContactPointEmail WHERE EmailAddress = 'sales@force.com'];

            HDT_SRV_ContactPointEmail.checkCreateAccess(cpe);
 
            Test.stopTest();
        }
    }

    @isTest
    public static void testCreateRecord() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            Individual ind = [SELECT Id FROM Individual WHERE LastName = 'Guzzo'];

            ContactPointEmail cpe = new ContactPointEmail(
                ParentId = ind.Id,
                EmailAddress = 'nuclear@ssault.com'
            );

            ContactPointEmail contact = HDT_SRV_ContactPointEmail.createRecord(cpe);
 
            Test.stopTest();

            System.assertEquals(cpe.EmailAddress, contact.EmailAddress, 'Contact Point Email created.');
            System.assertNotEquals('', contact.EmailAddress, 'Contact Point Email failed to create.');
        }
    }
	
    @isTest
    public static void testUpsertRecord() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            List<ContactPointEmail> cpe = [SELECT Id, EmailAddress FROM ContactPointEmail WHERE EmailAddress = 'sales@force.com'];
            cpe[0].EmailAddress = 'orange@goblin.com';

            HDT_SRV_ContactPointEmail.upsertRecord(cpe);

            ContactPointEmail contact = [SELECT Id, EmailAddress FROM ContactPointEmail WHERE EmailAddress = 'orange@goblin.com'];
 
            Test.stopTest();

            System.assertEquals(cpe[0].EmailAddress, contact.EmailAddress, 'Contact Point Phone successfully updated');
            System.assertNotEquals('sales@force.com', contact.EmailAddress, 'Contact Point Phone failed to update');
        }
    }
	
    @isTest
    public static void testCheckUpsertAccess() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            ContactPointEmail cpe = [SELECT Id, EmailAddress FROM ContactPointEmail WHERE EmailAddress = 'sales@force.com'];

            HDT_SRV_ContactPointEmail.checkUpsertAccess(cpe);
 
            Test.stopTest();
        }
    }
	
    @isTest
    public static void testCheckUpdateAccess() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            ContactPointEmail cpe = [SELECT Id, EmailAddress FROM ContactPointEmail WHERE EmailAddress = 'sales@force.com'];

            HDT_SRV_ContactPointEmail.checkUpdateAccess(cpe);
 
            Test.stopTest();
        }
    }
	
    @isTest
    public static void testUpdateRecord() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            List<ContactPointEmail> cpe = [SELECT Id, EmailAddress FROM ContactPointEmail WHERE EmailAddress = 'sales@force.com'];
            cpe[0].EmailAddress = 'orange@goblin.com';

            HDT_SRV_ContactPointEmail.updateRecord(cpe);

            ContactPointEmail contact = [SELECT Id, EmailAddress FROM ContactPointEmail WHERE EmailAddress = 'orange@goblin.com'];
 
            Test.stopTest();

            System.assertEquals(cpe[0].EmailAddress, contact.EmailAddress, 'Contact Point Phone successfully updated');
            System.assertNotEquals('sales@force.com', contact.EmailAddress, 'Contact Point Phone failed to update');
        }
    }
	
    @isTest
    public static void testUpdateRecord2() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            ContactPointEmail cpe = [SELECT Id, EmailAddress FROM ContactPointEmail WHERE EmailAddress = 'sales@force.com'];
            cpe.EmailAddress = 'orange@goblin.com';

            HDT_SRV_ContactPointEmail.updateRecord(cpe);

            ContactPointEmail contact = [SELECT Id, EmailAddress FROM ContactPointEmail WHERE EmailAddress = 'orange@goblin.com'];
 
            Test.stopTest();

            System.assertEquals(cpe.EmailAddress, contact.EmailAddress, 'Contact Point Phone successfully updated');
            System.assertNotEquals('sales@force.com', contact.EmailAddress, 'Contact Point Phone failed to update');
        }
    }
}
