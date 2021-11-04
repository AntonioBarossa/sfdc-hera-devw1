/**
 * @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
 * @date 06/09/2021
 * @description HDT_SRV_Account Test Classes
 * @history Lucas Fernandes 06/09/2021 – Created Class
 */
@isTest
public with sharing class HDT_SRV_AccountTst {
    
    private static HDT_SRV_Account srvAccount = new HDT_SRV_Account();
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();

    @TestSetup
    static void setup(){
        
        Id adminUserProfileId = HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
 
        User internalUser = HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
 
        internalUser.UserPermissionsMarketingUser = true;
 
        insert internalUser;
 
        System.runAs(internalUser) {
 
            HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');

        }
    }

    @isTest
    public static void testCheckReadAccess() {
 
        User u = [SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            srvAccount.checkReadAccess('Id');
 
            Test.stopTest();
        }
    }

    @isTest
    public static void testCheckCreateAccess() {

        User u = [SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){

            Test.startTest();

            List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, false, 'HERA COMM', 'Azienda', 'Aziende SME');
            accList[0].FirstName__c = 'firstName';

            srvAccount.checkCreateAccess(accList[0]);

            test.stopTest();
        }
    }

    @isTest
    public static void testCreateRecord() {

        User u = [SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){

            Test.startTest();

            List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, false, 'HERA COMM', 'Azienda', 'Aziende SME');
            accList[0].FirstName__c = 'Raul';
            accList[0].LastName__c = 'Seixas';
            accList[0].CustomerCode__c = '10036162999';

            srvAccount.createRecord(accList[0]);

            Account acc = [SELECT Id, Name FROM Account WHERE FirstName__c = 'Raul'];

            Test.stopTest();

            System.assertEquals(accList[0].Name, acc.Name, 'Account successfully created');

            System.assertNotEquals(null, acc.Name, 'Account was not created');
        }
    }

    @isTest
    public static void testCheckUpdateAccess() {

        User u = [SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){

            Test.startTest();

            srvAccount.checkUpdateAccess('Name');

            Test.stopTest();
        }
    }

    @isTest
    public static void testUpdateRecord() {

        User u = [SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){

            Test.startTest();

            Account acc = [SELECT Id, BillingCityCode__c FROM Account WHERE CustomerMarking__c = 'Azienda'];
            acc.BillingCityCode__c = 'Cartago';

            srvAccount.updateRecord(acc);

            Account account = [SELECT Id, BillingCityCode__c FROM Account WHERE CustomerMarking__c = 'Azienda'];

            Test.stopTest();

            System.assertEquals('Cartago', account.BillingCityCode__c, 'Account successfully updated');

            System.assertNotEquals('Roma', account.BillingCityCode__c, 'Account was not updated');
        }
    }

    @isTest
    public static void testUpdateRecords() {

        User u = [SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){

            Test.startTest();

            List<Account> acc = [SELECT Id, BillingCityCode__c FROM Account WHERE CustomerMarking__c = 'Azienda'];
            acc[0].BillingCityCode__c = 'Cartago';

            srvAccount.updateRecords(acc);

            Account account = [SELECT Id, BillingCityCode__c FROM Account WHERE CustomerMarking__c = 'Azienda'];

            Test.stopTest();

            System.assertEquals('Cartago', account.BillingCityCode__c, 'Account successfully updated');

            System.assertNotEquals('Roma', account.BillingCityCode__c, 'Account was not updated');
        }
    }

    @isTest
    public static void testUpdateRecordsNoShare() {

        User u = [SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){

            Test.startTest();

            List<Account> acc = [SELECT Id, BillingCityCode__c FROM Account WHERE CustomerMarking__c = 'Azienda'];
            acc[0].BillingCityCode__c = 'Cartago';

            srvAccount.updateRecordsNoShare(acc);

            Account account = [SELECT Id, BillingCityCode__c FROM Account WHERE CustomerMarking__c = 'Azienda'];

            Test.stopTest();

            System.assertEquals('Cartago', account.BillingCityCode__c, 'Account successfully updated');

            System.assertNotEquals('Roma', account.BillingCityCode__c, 'Account was not updated');
        }
    }
}
