/**
 * @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
 * @date 08/09/2021
 * @description HDT_SRV_ContactPointPhone Test Classes
 * @history Lucas Fernandes 08/09/2021 – Created Class
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
@isTest
public with sharing class HDT_SRV_ContactPointPhoneTst {
    
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
	
	@TestSetup
    static void setup(){
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
 
        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
 
        internalUser.UserPermissionsMarketingUser=true;
 
        insert internalUser;
 
        System.runAs(internalUser) {
 
            List<Individual> ind = HDT_UTL_DataFactoryTst.createIndividual(1, true);
            HDT_UTL_DataFactoryTst.createContactPointPhone(1, true, ind[0].Id);
        }
    }
	
	@isTest
    public static void testCheckCreateAccess() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            ContactPointPhone cpp = [SELECT Id FROM ContactPointPhone WHERE TelephoneNumber = '982591380'];

            HDT_SRV_ContactPointPhone.checkCreateAccess(cpp);
 
            Test.stopTest();
        }
    }

    @isTest
    public static void testCreateRecord() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            Individual ind = [SELECT Id FROM Individual WHERE LastName = 'Guzzo'];

            ContactPointPhone cpp = new ContactPointPhone(
                ParentId = ind.Id,
                TelephoneNumber = '234567890'
            );

            ContactPointPhone contact = HDT_SRV_ContactPointPhone.createRecord(cpp);
 
            Test.stopTest();

            System.assertEquals(cpp.TelephoneNumber, contact.TelephoneNumber, 'Contact Point Phone successfully created');
            System.assertNotEquals(null, contact.TelephoneNumber, 'Contact Point Phone failed to create');
        }
    }

    @isTest
    public static void testUpsertRecord() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            Individual ind = [SELECT Id FROM Individual WHERE LastName = 'Guzzo'];

            List<ContactPointPhone> cppList = new List<ContactPointPhone>();

            ContactPointPhone cpp = new ContactPointPhone(
                ParentId = ind.Id,
                TelephoneNumber = '234567890'
            );
            cppList.add(cpp);

            HDT_SRV_ContactPointPhone.upsertRecord(cppList);
 
            List<ContactPointPhone> contacts = [SELECT Id FROM ContactPointPhone WHERE TelephoneNumber = '234567890'];

            Test.stopTest();

            System.assertEquals(false, contacts.isEmpty(), 'Contact Point Phone successfully upserted');
            System.assertNotEquals(true, contacts.isEmpty(), 'Contact Point Phone failed to upsert');
        }
    }

    @isTest
    public static void testCheckUpsertAccess() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            ContactPointPhone cpp = [SELECT Id FROM ContactPointPhone WHERE TelephoneNumber = '982591380'];

            HDT_SRV_ContactPointPhone.checkUpsertAccess(cpp);
 
            Test.stopTest();
        }
    }

    @isTest
    public static void testUpdateRecord() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            ContactPointPhone cpp = [SELECT Id, TelephoneNumber FROM ContactPointPhone WHERE TelephoneNumber = '982591380'];
            cpp.TelephoneNumber = '981516381';

            ContactPointPhone contact = HDT_SRV_ContactPointPhone.updateRecord(cpp);
 
            Test.stopTest();

            System.assertEquals(cpp.TelephoneNumber, contact.TelephoneNumber, 'Contact Point Phone successfully updated');
            System.assertNotEquals('982591380', contact.TelephoneNumber, 'Contact Point Phone failed to update');
        }
    }

    @isTest
    public static void testUpdateRecord2() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            List<ContactPointPhone> cpp = [SELECT Id, TelephoneNumber FROM ContactPointPhone WHERE TelephoneNumber = '982591380'];
            cpp[0].TelephoneNumber = '981516381';

            HDT_SRV_ContactPointPhone.updateRecord(cpp);

            ContactPointPhone contact = [SELECT Id, TelephoneNumber FROM ContactPointPhone WHERE TelephoneNumber = '981516381'];
 
            Test.stopTest();

            System.assertEquals(cpp[0].TelephoneNumber, contact.TelephoneNumber, 'Contact Point Phone successfully updated');
            System.assertNotEquals('982591380', contact.TelephoneNumber, 'Contact Point Phone failed to update');
        }
    }
}
