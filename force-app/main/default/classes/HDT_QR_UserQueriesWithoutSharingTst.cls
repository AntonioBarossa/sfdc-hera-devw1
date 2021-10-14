/**
* @author Luis Bispo (luis.bispo@engdb.com.br)
* @date 01/09/2021
* @description HDT_QR_UserQueriesWithoutSharing for Test Classes
* @history Luis Bispo – 01/09/2021 – Created class
*/
@isTest
public with sharing class HDT_QR_UserQueriesWithoutSharingTst {
    
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();

    @TestSetup
    static void setup(){
        
        Id adminUserProfileId = HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
        User internalUser = HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
        internalUser.UserPermissionsMarketingUser=true;
        insert internalUser;
        System.runAs(internalUser) {
            //your testSetup       
        }
    }

    @isTest
    static void testGetRoleAndProfile() {
        User tUser = [SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1]; 
        System.runAs(tUser){
            Test.startTest(); 
            List<User> testUser = HDT_QR_UserQueriesWithoutSharing.getRoleAndProfile(tUser.Id);
            System.assertEquals(false, testUser == null, 'testUser not populated correctly');
            System.assertNotEquals(true, testUser == null, 'Value of parameter is not matching');
            Test.stopTest();
        }
    }
}
