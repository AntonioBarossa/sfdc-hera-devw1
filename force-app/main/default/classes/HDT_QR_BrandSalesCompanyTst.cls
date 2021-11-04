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
            List<BrandSalesCompany__c> brandSalesCo=HDT_UTL_DataFactoryTst.createBrandSalesCompany(1, false);
            brandSalesCo[0].CommonSupply__c='testCommomSupply';
            brandSalesCo[0].Service__c='testService';
            brandSalesCo[0].SalesCompany__c='testSalesCo';
            brandSalesCo[0].MarketType__c='testMarketType';
            brandSalesCo[0].ActiveFlgforACR__c=true;
            brandSalesCo[0].ActiveFlgforBrand__c=true;
            brandSalesCo[0].CorporateBrand__c='testCorpBrand';
 
            insert brandSalesCo;

        }
    }

    @isTest
    static void testGetMatriceBrandById() {
        User tUser = [SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
        System.runAs(tUser){
            Test.startTest();   
            BrandSalesCompany__c tBrandSalesCompany = [SELECT Id, CommonSupply__c, Service__c, SalesCompany__c, MarketType__c FROM BrandSalesCompany__c WHERE CommonSupply__c = 'testCommomSupply' LIMIT 1]; 
            new HDT_QR_BrandSalesCompany().getMatriceBrandById(tBrandSalesCompany.CommonSupply__c, tBrandSalesCompany.Service__c, tBrandSalesCompany.SalesCompany__c, tBrandSalesCompany.MarketType__c);
            Test.stopTest();
            System.assertEquals('testCommomSupply', tBrandSalesCompany.CommonSupply__c, 'CommonSupply__c   not returned');
            System.assertNotEquals('', tBrandSalesCompany.CommonSupply__c, 'CommonSupply__c   not returned');
        }
    }
}
