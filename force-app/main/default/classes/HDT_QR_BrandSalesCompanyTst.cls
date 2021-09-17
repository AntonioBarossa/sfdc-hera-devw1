/**
* @author Luis Bispo (luis.bispo@engdb.com.br)
* @date 16/09/2021
* @description HDT_QR_BrandSalesCompany for Test Classes
* @history Luis Bispo – 16/09/2021 – Created class
*/
@isTest
public with sharing class HDT_QR_BrandSalesCompanyTst {
    
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
    static void testGetMatriceBrandById() {
        User tUser = [SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1]; 
        System.runAs(tUser){
            Test.startTest();   

            List<BrandSalesCompany__c> newBrandSalesCom = new HDT_QR_BrandSalesCompany().getMatriceBrandById('test','test','test','test');
            System.assertEquals(true, newBrandSalesCom != null); 
            System.assertNotEquals(false, newBrandSalesCom != null);
            Test.stopTest();
        }
    }
}
