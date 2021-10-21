/**
 * Header of the class "HDT_WS_HerokuAddressSearchTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_WS_HerokuAddressSearch"
 * @history
 * @Created 04/10/2021
 * Modified By:
 **/

@isTest
public class HDT_WS_HerokuAddressSearchTst {
    
    @isTest
    static void test1(){
        
        HDT_UTL_DataFactoryTst.createWebServiceConfiguration('VerifIndirizzo','https://integration-ts.gruppohera.it/dev/salesforce-api-exp/api/data-management/files','POST','MulesoftSalesforceUser');
        
        Test.startTest();
        
        HDT_WS_HerokuAddressSearch h = new HDT_WS_HerokuAddressSearch();
        HDT_WS_HerokuAddressSearch.HDT_WS_HerokuAddressSearchResponse res1 = HDT_WS_HerokuAddressSearch.callServiceCom('city');
        HDT_WS_HerokuAddressSearch.HDT_WS_HerokuAddressSearchResponse res2 = HDT_WS_HerokuAddressSearch.callServiceInd('street','citycode');
        HDT_WS_HerokuAddressSearch.HDT_WS_HerokuAddressSearchResponse res3 = HDT_WS_HerokuAddressSearch.callServiceVer('modality','cityCode','streetCode','houseNumCode');

        HDT_WS_HerokuAddressSearch.HDT_WS_PrestazioneObj hPrestazione = new HDT_WS_HerokuAddressSearch.HDT_WS_PrestazioneObj();
        List<HDT_WS_HerokuAddressSearch.HDT_WS_PrestazioneObj> hPrestazioneList = new List<HDT_WS_HerokuAddressSearch.HDT_WS_PrestazioneObj>();
		hPrestazioneList.add(hPrestazione);        
        res1.prestazione = hPrestazioneList;
        hPrestazione.city1 = 'city1';
        hPrestazione.street='street';
        hPrestazione.streetcode='streetcode';
        hPrestazione.region='region';
        hPrestazione.postCode1='postCode1';
        hPrestazione.strTypeAB='strTypeAB';
        hPrestazione.houseNum1='houseNum1';
        hPrestazione.modality='modality';
        hPrestazione.citycode='citycode';
        hPrestazione.houseNumCOde='houseNumCode';
        hPrestazione.cityPCode='cityPCode';
        hPrestazione.cityPName='cityPName';
       
        Test.stopTest();
        
    	System.assertEquals('region', res1.prestazione[0].region, 'Value of the field region not correctly set');
        
    	System.assertNotEquals(null, res3, 'callServiceVer did not work correctly');
        System.assertNotEquals(null, res2, 'callServiceInd did not work correctly');
        System.assertNotEquals(null, res1, 'callServiceCom did not work correctly');
        
    }
}