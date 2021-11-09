/**
 * @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
 * @date 13/09/2021
 * @description HDT_SRV_ServiceRequest Test Classes
 * @history Lucas da Silva Fernandes – 13/09/2021 – Created Class
 */
@isTest
public with sharing class HDT_SRV_ServiceRequestTst {
    
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
	
	@TestSetup
    static void setup(){
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
 
        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
 
        internalUser.UserPermissionsMarketingUser=true;
 
        insert internalUser;
 
        System.runAs(internalUser) {
 
            List<ServiceRequest__c> stList = HDT_UTL_DataFactoryTst.createServiceRequest(1, false);
            stList[0].ServicePointCode__c = 'testServicePointCode';
            insert stList;

        }
    }
	
	@isTest
    public static void testCheckReadAccess() {

        Boolean finished = false;
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            HDT_SRV_ServiceRequest.checkReadAccess('ProcessType__c');

            finished = true;
 
            Test.stopTest();

            System.assertEquals(true, finished, 'Test Finished');
        }
    }

    @isTest
    public static void testCheckCreateAccess() {

        Boolean finished = false;
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            ServiceRequest__c sr = [SELECT ProcessType__c, ServicePointCode__c FROM ServiceRequest__c WHERE ProcessType__c = 'Alert'];

            HDT_SRV_ServiceRequest.checkCreateAccess(sr);

            finished = true;
 
            Test.stopTest();

            System.assertEquals(true, finished, 'Test Finished');
        }
    }

    @isTest
    public static void testCheckDeleteAccess() {

        Boolean finished = false;
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            ServiceRequest__c sr = [SELECT ProcessType__c, ServicePointCode__c FROM ServiceRequest__c WHERE ProcessType__c = 'Alert'];

            HDT_SRV_ServiceRequest.checkDeleteAccess(sr);

            finished = true;
 
            Test.stopTest();

            System.assertEquals(true, finished, 'Test Finished');
        }
    }

    @isTest
    public static void testCheckUpdateAccess() {

        Boolean finished = false;
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            ServiceRequest__c sr = [SELECT ProcessType__c, ServicePointCode__c FROM ServiceRequest__c WHERE ProcessType__c = 'Alert'];

            HDT_SRV_ServiceRequest.checkUpdateAccess(sr);

            finished = true;
 
            Test.stopTest();

            System.assertEquals(true, finished, 'Test Finished');
        }
    }

    @isTest
    public static void testCreateRecord() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            ServiceRequest__c sr = new ServiceRequest__c(
                ProcessType__c = 'Informative',
                ServicePointCode__c = 'servicePointCodeTest'
            );

            HDT_SRV_ServiceRequest.createRecord(sr);

            List<ServiceRequest__c> srList = [SELECT Id FROM ServiceRequest__c WHERE ProcessType__c = 'Informative'];
 
            Test.stopTest();

            System.assertEquals(false, srList.isEmpty(), 'Service Request created.');
            System.assertNotEquals(true, srList.isEmpty(), 'Service Request creation failed.');
        }
    }

    @isTest
    public static void testDeleteRecord() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            ServiceRequest__c sr = [SELECT Id FROM ServiceRequest__c WHERE ProcessType__c = 'Alert'];

            HDT_SRV_ServiceRequest.deleteRecord(sr);

            List<ServiceRequest__c> srList = [SELECT Id FROM ServiceRequest__c WHERE ProcessType__c = 'Alert'];
 
            Test.stopTest();

            System.assertEquals(true, srList.isEmpty(), 'Service Request deleted.');
            System.assertNotEquals(false, srList.isEmpty(), 'Service Request deletion failed.');
        }
    }

    @isTest
    public static void testUpdateRecord() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            List<ServiceRequest__c> srList = [SELECT Id, ServicePointCode__c FROM ServiceRequest__c WHERE ProcessType__c = 'Alert'];
            srList[0].ServicePointCode__c = 'newServicePointCode';

            List<ServiceRequest__c> testSrList = HDT_SRV_ServiceRequest.updateRecord(srList);
 
            Test.stopTest();

            System.assertEquals(false, testSrList.isEmpty(), 'Service Request updated.');
            System.assertNotEquals(true, testSrList.isEmpty(), 'Service Request update failed.');
        }
    }
}
