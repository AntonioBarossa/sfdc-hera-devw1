/**
* @author Luis Bispo (luis.bispo@engdb.com.br)
* @date 15/09/2021
* @description HDT_QR_FiltriProcessi for Test Classes
* @history Luis Bispo – 15/09/2021 – Created class
*/
@isTest
public with sharing class HDT_QR_FiltriProcessiTst {
    
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();

    @TestSetup
    static void setup(){
        
        Id adminUserProfileId = HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
 
        User internalUser = HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
 
        internalUser.UserPermissionsMarketingUser=true;
 
        insert internalUser;
 
        System.runAs(internalUser) {
            //seu testSetup       
        }
    }

    @isTest
    static void testGetCustomMetadata() {
        User tUser = [SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1]; 
        System.runAs(tUser){
            Test.startTest();    

            new HDT_QR_FiltriProcessi();
            HDT_FiltriProcessiSelFornitura__mdt filtriProcess = HDT_QR_FiltriProcessi.getCustomMetadata('Gestione Bonus Sociale');
            System.assertEquals(true, filtriProcess.Id != null, 'value of parameter is matching'); 
            System.assertNotEquals(false, filtriProcess.Id != null , 'value of parameter is not matching');
            Test.stopTest();
        }
    }
}
