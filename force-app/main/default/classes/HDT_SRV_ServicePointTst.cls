/**
 * @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
 * @date 13/09/2021
 * @description HDT_SRV_ServicePoint Test Classes
 * @history Lucas da Silva Fernandes – 13/09/2021 – Created Class
 */
@isTest
public with sharing class HDT_SRV_ServicePointTst {
    
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    private static HDT_SRV_ServicePoint srvPoint = new HDT_SRV_ServicePoint();
	
	@TestSetup
    static void setup(){
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
 
        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
 
        internalUser.UserPermissionsMarketingUser=true;
 
        insert internalUser;
 
        System.runAs(internalUser) {
 
            HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        }
    }
	
	@isTest
    public static void testCheckReadAccess() {

        Boolean finished = false;
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            srvPoint.checkReadAccess('ServicePointCode__c, Name');

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

            srvPoint.checkCreateAccess('ServicePointCode__c, Name');

            finished = true;
 
            Test.stopTest();

            System.assertEquals(true, finished, 'Test Not Ended');
        }
    }

    @isTest
    public static void testCheckUpdateAccess() {

        Boolean finished = false;
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            srvPoint.checkUpdateAccess('ServicePointCode__c, Name');

            finished = true;
 
            Test.stopTest();

            System.assertEquals(true, finished, 'Test Ended');
        }
    }

    @isTest
    public static void testCreateRecord() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            ServicePoint__c sp = new ServicePoint__c(
                Name = 'Esquina',
                ServicePointCode__c = 'codigoSecreto'
            );

            try {

                ServicePoint__c spException = new ServicePoint__c(
                    ServicePointCode__c='testServicePointCode',
                    Name = 'testServicePoint0'
                );
                
                srvPoint.createRecord(spException);

            } catch (Exception e) {
                
                System.debug(e);
            }

            srvPoint.createRecord(sp);
 
            List<ServicePoint__c> spList = [SELECT Id FROM ServicePoint__c WHERE Name = 'Esquina'];

            Test.stopTest();

            System.assertEquals(false, spList.isEmpty(), 'Service Point created');
            System.assertNotEquals(true, spList.isEmpty(), 'Service Point creation failed');
        }
    }

    @isTest
    public static void testUpdateRecord() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            ServicePoint__c spException = new ServicePoint__c(
                    ServicePointCode__c='testServicePointCode',
                    Name = 'testServicePoint0',
                    SupplyStreet__c = 'testSupplyStreet1'
            );
            insert spException;

            List<ServicePoint__c> spList = [SELECT Id, Name, ServicePointCode__c FROM ServicePoint__c WHERE Name='testServicePoint0'];

            try {
                spList[0].SupplyStreet__c = 'testSupplyStreet2';            
                srvPoint.updateRecord(spList[0]);

            } catch (Exception e) {

                System.debug(e);
            }

            List<ServicePoint__c> spCheckList = [SELECT Id FROM ServicePoint__c WHERE SupplyStreet__c = 'testSupplyStreet2'];
 
            Test.stopTest();

            System.assertEquals(spList[0].Id, spCheckList[0].Id, 'Service Point updated.');
            System.assertNotEquals(null, spCheckList[0].Id, 'Service Point update failed.');
        }
    }

    @isTest
    public static void testUpdateRecordRemiCode() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            ServicePoint__c spException = new ServicePoint__c(
                    ServicePointCode__c='testServicePointCode',
                    Name = 'testServicePoint0'
            );
            insert spException;

            List<ServicePoint__c> spList = [SELECT Id, RemiCode__c FROM ServicePoint__c WHERE Name='testServicePoint0'];
            spList[0].RemiCode__c = 'idclip';

            srvPoint.updateRecordRemiCode(spList);
 
            List<ServicePoint__c> testSpList = [SELECT Id FROM ServicePoint__c WHERE RemiCode__c = 'idclip'];
            
            Test.stopTest();

            System.assertEquals(false, testSpList.isEmpty(), 'Service Point updated');
            System.assertNotEquals(true, testSpList.isEmpty(), 'Service Point update failed');
        }
    }
}
