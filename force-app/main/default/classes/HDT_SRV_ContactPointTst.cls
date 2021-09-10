/**
 * @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
 * @date 06/09/2021
 * @description HDT_SRV_Contact Test Classes
 * @history Lucas Fernandes 06/09/2021 – Created Class
 */
@isTest
public with sharing class HDT_SRV_ContactPointTst {
    
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();

    @TestSetup
    static void setup(){
        
        Id adminUserProfileId = HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
 
        User internalUser = HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
 
        internalUser.UserPermissionsMarketingUser=true;
 
        insert internalUser;
 
        System.runAs(internalUser) {
 
            List<Individual> ind = HDT_UTL_DataFactoryTst.createIndividual(1, true);
            List<ContactPointPhone> cppList = HDT_UTL_DataFactoryTst.createContactPointPhone(1, true, ind[0].Id);
            List<ContactPointEmail> cpeList = HDT_UTL_DataFactoryTst.createContactPointEmail(1, true, ind[0].Id);
        }
    }

    @isTest
    public static void testUpsertContactPointEmail() {
 
        User u = [SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            List<ContactPointEmail> cpeList = [SELECT Id, EmailAddress FROM ContactPointEmail WHERE EmailAddress = 'sales@force.com'];
            cpeList[0].EmailAddress = 'iron@maiden.com';

            HDT_SRV_ContactPoint.upsertContactPointEmail(cpeList);

            List<ContactPointEmail> contacts = [SELECT Id, EmailAddress FROM ContactPointEmail WHERE EmailAddress = 'iron@maiden.com'];

            Test.stopTest();

            System.assertEquals(cpeList[0].EmailAddress, contacts[0].EmailAddress, 'Contact Point Email updated');

            System.assertNotEquals('sales@force.com', contacts[0].EmailAddress, 'Contact Point Email update failed');
        }
    }

    @isTest
    public static void testUpsertContactPointPhone() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            List<ContactPointPhone> cpp = [SELECT Id, TelephoneNumber FROM ContactPointPhone WHERE TelephoneNumber = '982591380'];
            cpp[0].TelephoneNumber = '981516381';

            HDT_SRV_ContactPoint.upsertContactPointPhone(cpp);

            ContactPointPhone contact = [SELECT Id, TelephoneNumber FROM ContactPointPhone WHERE TelephoneNumber = '981516381'];
 
            Test.stopTest();

            System.assertEquals(cpp[0].TelephoneNumber, contact.TelephoneNumber, 'Contact Point Phone successfully updated');
            System.assertNotEquals('982591380', contact.TelephoneNumber, 'Contact Point Phone failed to update');
        }
    }
	
    @isTest
    public static void testUpdateContactPointEmail() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            List<ContactPointEmail> cpe = [SELECT Id, EmailAddress FROM ContactPointEmail WHERE EmailAddress = 'sales@force.com'];
            cpe[0].EmailAddress = 'orange@goblin.com';

            HDT_SRV_ContactPoint.updateContactPointEmail(cpe);

            ContactPointEmail contact = [SELECT Id, EmailAddress FROM ContactPointEmail WHERE EmailAddress = 'orange@goblin.com'];
 
            Test.stopTest();

            System.assertEquals(cpe[0].EmailAddress, contact.EmailAddress, 'Contact Point Phone successfully updated');
            System.assertNotEquals('sales@force.com', contact.EmailAddress, 'Contact Point Phone failed to update');
        }
    }
	
    @isTest
    public static void testUpdateContactPointPhone() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            List<ContactPointPhone> cpp = [SELECT Id, TelephoneNumber FROM ContactPointPhone WHERE TelephoneNumber = '982591380'];
            cpp[0].TelephoneNumber = '981516381';

            HDT_SRV_ContactPoint.updateContactPointPhone(cpp);

            ContactPointPhone contact = [SELECT Id, TelephoneNumber FROM ContactPointPhone WHERE TelephoneNumber = '981516381'];
 
            Test.stopTest();

            System.assertEquals(cpp[0].TelephoneNumber, contact.TelephoneNumber, 'Contact Point Phone successfully updated');
            System.assertNotEquals('982591380', contact.TelephoneNumber, 'Contact Point Phone failed to update');
        }
    }
}
