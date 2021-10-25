/**
 * Header of the class "HDT_AssetTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative trigger "HDT_Asset"
 * @history
 * @Created 11/10/2021
 * Modified By:
 **/

@isTest
public class HDT_AssetTst {
    
    @isTest static void test(){
        
        Test.startTest();
        
        List<Asset> assetList = HDT_UTL_DataFactoryTst.createAsset(1, true);

        System.assertEquals(1, assetList.size(), 'Asset not inserted correctly');

        System.assertNotEquals(null, assetList, 'Asset not inserted correctly');

        Test.stopTest();
        
    }

}