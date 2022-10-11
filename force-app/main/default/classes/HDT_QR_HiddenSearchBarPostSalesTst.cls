/**
* @author Edoardo Zanatta (luis.bispo@engdb.com.br)
* @date 07/10/2022
* @description Test Class for HDT_QR_HiddenSearchBarPostSales
*/
@isTest
public with sharing class HDT_QR_HiddenSearchBarPostSalesTst {

    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();

    @TestSetup
    static void setup(){
        
        Id adminUserProfileId = HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
 
        User internalUser = HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
 
        internalUser.UserPermissionsMarketingUser=true;
 
        insert internalUser;

    }

    @isTest
    public static void testGetCustomMetadataTwo() {
        User tUser = [SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1]; 

        System.runAs(tUser){
            Test.startTest(); 

            String searchPostSales = HDT_QR_HiddenSearchBarPostSales.getCustomMetadataTwo('Riattivazione Fornitura','Fornitura');
            System.assertEquals('List is populated', searchPostSales);
            String searchPostSalesTwo = HDT_QR_HiddenSearchBarPostSales.getCustomMetadataTwo('','');
            System.assertEquals('List is not populated', searchPostSalesTwo);
            
            Test.stopTest();

        }
    }
}
