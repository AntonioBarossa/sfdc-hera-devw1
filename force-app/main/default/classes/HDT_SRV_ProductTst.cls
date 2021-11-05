/**
 * @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
 * @date 13/09/2021
 * @description HDT_SRV_Sale Test Classes
 * @history Lucas da Silva Fernandes – 13/09/2021 – Created Class
 */
@isTest
public with sharing class HDT_SRV_ProductTst {

    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    private static HDT_SRV_Product srvProd = new HDT_SRV_Product();
	
	@TestSetup
    static void setup(){
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
 
        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
 
        internalUser.UserPermissionsMarketingUser=true;
 
        insert internalUser;
 
        System.runAs(internalUser) {
 
            HDT_UTL_DataFactoryTst.createProduct2(1, true);
        }
    }
	
	@isTest
    public static void testCheckReadAccess() {

        Boolean finished = false;
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            srvProd.checkReadAccess('Name');

            finished = true;
 
            Test.stopTest();
        }

        System.assertEquals(true, finished, 'Test Not Ended');
    }

    @isTest
    public static void testCheckCreateAccess() {

        Boolean finished = false;
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            srvProd.checkCreateAccess('Name');

            finished = true;
 
            Test.stopTest();
        }

        System.assertEquals(true, finished, 'Test Not Ended');
    }

    @isTest
    public static void testCreateRecord() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            Product2 prod = new Product2(
                Name = 'prodTest'
            );

            srvProd.createRecord(prod);

            List<Product2> testProd = [SELECT Id FROM Product2 WHERE Name = 'prodTest'];
 
            Test.stopTest();

            System.assertEquals(false, testProd.isEmpty(), 'Product created.');
            System.assertNotEquals(true, testProd.isEmpty(), 'Product creation failed.');
        }
    }

    @isTest
    public static void testCheckUpdateAccess() {

        Boolean finished = false;
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            srvProd.checkUpdateAccess('Name');

            finished = true;
 
            Test.stopTest();
        }

        System.assertEquals(true, finished, 'Test Not Ended');
    }

    @isTest
    public static void testUpdateRecord() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            List<Product2> prodList = [SELECT Id, Name FROM Product2 WHERE Name = 'testProduct2Name0'];
            prodList[0].Name = 'newTestName';

            srvProd.updateRecord(prodList[0]);

            List<Product2> testProd = [SELECT Id FROM Product2 WHERE Name = 'newTestName'];
 
            Test.stopTest();

            System.assertEquals(false, testProd.isEmpty(), 'Product updated.');
            System.assertNotEquals(true, testProd.isEmpty(), 'Product update failed.');
        }
    }

    @isTest
    public static void testUpdateRecords() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            List<Product2> prodList = [SELECT Id, Name FROM Product2 WHERE Name = 'testProduct2Name0'];
            prodList[0].Name = 'newTestName';

            srvProd.updateRecords(prodList);

            List<Product2> testProd = [SELECT Id FROM Product2 WHERE Name = 'newTestName'];
 
            Test.stopTest();

            System.assertEquals(false, testProd.isEmpty(), 'Product updated.');
            System.assertNotEquals(true, testProd.isEmpty(), 'Product update failed.');
        }
    }
}
