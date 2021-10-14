/**
* @author Luis Bispo (luis.bispo@engdb.com.br)
* @date 14/09/2021
* @description HDT_SRV_ContentVersion for Test Classes
* @history Luis Bispo – 14/09/2021 – Created class
*/
@isTest
public with sharing class HDT_SRV_ContentVersionTst {
    
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();

    @TestSetup
    static void setup(){
        
        Id adminUserProfileId = HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
 
        User internalUser = HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
 
        internalUser.UserPermissionsMarketingUser=true;
 
        insert internalUser;
 
        //System.runAs(internalUser) {
            //seu testSetup  
 
        //}
    }

    @isTest
    static void testCreateRecord() {
        User tUser = [SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1]; 
        System.runAs(tUser){
            Test.startTest();   

            ContentVersion contentVersion = new HDT_SRV_ContentVersion().createRecord('ABC', 'test', 'Unit Test Attachment Body');
            System.assertEquals('ABC', contentVersion.Title, 'Value of parameter is matching');
            System.assertNotEquals('', contentVersion.Title, 'The Title is not correct');
            Test.stopTest();
        }
    }
}
