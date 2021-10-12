/**
 * @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
 * @date 13/09/2021
 * @description HDT_SRV_Sale Test Classes
 * @history Lucas da Silva Fernandes – 13/09/2021 – Created Class
 */
@isTest
public with sharing class HDT_SRV_SaleTst {
    
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    private static HDT_SRV_Sale srvSale = new HDT_SRV_Sale();
	
	@TestSetup
    static void setup(){
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
 
        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
 
        internalUser.UserPermissionsMarketingUser=true;
 
        insert internalUser;
 
        System.runAs(internalUser) {
 
            List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
            List<Sale__c> saleList = HDT_UTL_DataFactoryTst.createSale(1, true, accList[0].Id, 'Bozza');
        }
    }
	
	@isTest
    public static void testCheckReadAccess() {

        Boolean finished = false;
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            srvSale.checkReadAccess('Status__c');

            finished = true;
 
            Test.stopTest();

            System.assertEquals(true, finished, 'Test Ended');
        }
    }

    @isTest
    public static void testCheckCreateAccess() {

        Boolean finished = false;
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            srvSale.checkCreateAccess('Status__c');

            finished = true;
 
            Test.stopTest();

            System.assertEquals(true, finished, 'Test Ended');
        }
    }

    @isTest
    public static void testCheckUpdateAccess() {

        Boolean finished = false;
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            srvSale.checkUpdateAccess('Status__c');

            finished =  true;
 
            Test.stopTest();

            System.assertEquals(true, finished, 'Test Ended');
        }
    }

    @isTest
    public static void testCreateRecord() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            Account acc = [SELECT Id FROM Account WHERE CustomerMarking__c = 'Azienda'];

            Sale__c sale = new Sale__c(
                Name = 'srvSaleTest',
                Status__c = 'Attiva',
                Account__c = acc.Id
            );

            Sale__c testSale = srvSale.createRecord(sale);

            List<Sale__c> sales = [SELECT Id FROM Sale__c WHERE Status__c = 'Attiva'];
 
            Test.stopTest();

            System.assertEquals(false, sales.isEmpty(), 'Sale created.');
            System.assertNotEquals(true, sales.isEmpty(), 'Sale creation failed.');
        }
    }

    @isTest
    public static void testUpdateRecord() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            List<Sale__c> sales = [SELECT Id, Name FROM Sale__c WHERE Status__c = 'Bozza'];
            sales[0].Name = 'newTestName';

            srvSale.updateRecord(sales[0]);

            List<Sale__c> assertSales = [SELECT Id FROM Sale__c WHERE Name = 'newTestName'];
 
            Test.stopTest();

            System.assertEquals(false, assertSales.isEmpty(), 'Sale updated.');
            System.assertNotEquals(true, assertSales.isEmpty(), 'Sale update failed.');
        }
    }

    @isTest
    public static void testUpdateRecords() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            List<Sale__c> sales = [SELECT Id, Name FROM Sale__c WHERE Status__c = 'Bozza'];
            sales[0].Name = 'newTestName';

            srvSale.updateRecords(sales);

            List<Sale__c> assertSales = [SELECT Id FROM Sale__c WHERE Name = 'newTestName'];
 
            Test.stopTest();

            System.assertEquals(false, assertSales.isEmpty(), 'Sale updated.');
            System.assertNotEquals(true, assertSales.isEmpty(), 'Sale update failed.');
        }
    }
}
