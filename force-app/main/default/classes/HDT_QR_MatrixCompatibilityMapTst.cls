/**
* @author Luis Bispo (luis.bispo@engdb.com.br)
* @date 16/09/2021
* @description HDT_QR_MatrixCompatibilityMap for Test Classes
* @history Luis Bispo – 16/09/2021 – Created class
*/
@isTest
public with sharing class HDT_QR_MatrixCompatibilityMapTst {
    
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();

    @TestSetup
    static void setup(){
        
        Id adminUserProfileId = HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
 
        User internalUser = HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
 
        internalUser.UserPermissionsMarketingUser=true;
 
        insert internalUser;
 
        // System.runAs(internalUser) {
        //     //seu testSetup  

        // }
    }

    @isTest
    static void testGetProcessTypeMap() {
        User tUser = [SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1]; 
        System.runAs(tUser){
            Test.startTest();

            List<HDT_MatrixCompatibilityMap__mdt> newMatrix = HDT_QR_MatrixCompatibilityMap.getProcessTypeMap('Rimozione Impianto','Case');
            System.assertEquals(true, newMatrix[0].Id != null,'The Matrix is empty'); 
            System.assertNotEquals(false, newMatrix[0].Id != null, 'The Matrix has no records');

            Test.stopTest();
        }
    }
}
