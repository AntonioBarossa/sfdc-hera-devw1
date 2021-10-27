/**
 * Header of the class "HDT_TRH_AssetTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_TRH_Asset"
 * @history
 * @Created 11/10/2021
 * Modified By:
 **/

@isTest
public with sharing class HDT_TRH_AssetTst {
        
    @isTest public static void test() {

        Test.startTest();
        
        List<Asset> assetList = HDT_UTL_DataFactoryTst.createAsset(1, true);

        Asset assetTest = [SELECT Id FROM Asset WHERE Name = 'testAsset0' LIMIT 1];
        
        assetTest.Campaign__c = 'testvalue';
        
        update assetTest;

        System.assertEquals('testvalue', assetTest.Campaign__c, 'Asset not updated correctly');

        System.assertNotEquals(null, assetTest.Campaign__c, 'Asset not updated correctly');

        Test.stopTest();
    }
}