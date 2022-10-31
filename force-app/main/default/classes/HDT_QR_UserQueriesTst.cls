/**
* @author Luis Bispo (luis.bispo@engdb.com.br)
* @date 02/09/2021
* @description HDT_QR_UserQueriesTst for Test Classes
* @history Luis Bispo – 02/09/2021 – Created class
*/
@isTest
public with sharing class HDT_QR_UserQueriesTst {
    
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();

    @TestSetup
    static void setup(){
        Id adminUserProfileId = HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
        User internalUser = HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
        internalUser.UserPermissionsMarketingUser=true;
        insert internalUser;
    }

    @isTest
    static void testGetRoleAndProfile() {
        User tUser = [SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1]; 
        System.runAs(tUser){
            Test.startTest(); 
            List<User> testUser = HDT_QR_UserQueries.getRoleAndProfile(tUser.Id);
            System.assertEquals(false, testUser == null, 'testUser not populated correctly');
            System.assertNotEquals(true, testUser == null, 'Value of parameter is not matching');
            Test.stopTest();
        }
    }
    @isTest
    static void testGetCurrentUserSucess() {
        User tUser = [SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1]; 
        System.runAs(tUser){
            Test.startTest(); 

            User testUser = HDT_QR_UserQueries.getCurrentUser(tUser.Id);
            System.assertEquals(false, testUser == null, 'testUser not populated correctly');
            System.assertNotEquals(true, testUser == null, 'Value of parameter is not matching');
            
            Test.stopTest();
        }
    }
    @isTest
    static void testGetCurrentUserFail() {
        User tUser = [SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
        System.runAs(tUser){
            Test.startTest(); 

            User testUser = HDT_QR_UserQueries.getCurrentUser('tUserTestId');
            System.assertEquals(true, testUser == null, 'testUser not populated correctly');
            System.assertNotEquals(false, testUser == null, 'Value of parameter is not matching');
            Test.stopTest();
        }
    }
    @isTest
    static void testGetUserList() {
        User tUser = [SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
        Set<Id> idUserSet = new Set<Id>();
        System.runAs(tUser){
            Test.startTest(); 
            idUserSet.add(tUser.Id);
            List<User> userList = HDT_QR_UserQueries.getUsersStatus(idUserSet);
            System.assertEquals(userList.isEmpty(), false);
            Test.stopTest();
        }
    }

}