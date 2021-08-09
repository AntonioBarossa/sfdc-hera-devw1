/**
 * @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
 * @date 06/08/2021
 * @description HDT_TRH_Asset Test Classes
 * @history Lucas Fernandes 06/08/2021 – Created class
 */

@isTest
public with sharing class HDT_TRH_AssetTst {

    @isTest
    public static void testAssetBeforeInsert() {

        Test.startTest();

        List<Asset> assetList = new List<Asset>();

        Asset asset = new Asset(
            Name = 'testAssetList',
            CompanyOwner__c = 'HERA COMM'
        );

        assetList.add(asset);

        insert assetList;

        Test.stopTest();
    }
}