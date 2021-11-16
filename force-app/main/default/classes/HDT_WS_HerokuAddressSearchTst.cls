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
    static void test(){
        
        HDT_UTL_DataFactoryTst.createWebServiceConfiguration('VerifIndirizzo','https://integration-ts.gruppohera.it/dev/salesforce-api-exp/api/data-management/files','POST','MulesoftSalesforceUser');
        
        Test.startTest();
        
        HDT_WS_HerokuAddressSearch.HDT_WS_HerokuAddressSearchResponse resCom = HDT_WS_HerokuAddressSearch.callServiceCom('city');
        HDT_WS_HerokuAddressSearch.HDT_WS_HerokuAddressSearchResponse resInd = HDT_WS_HerokuAddressSearch.callServiceInd('street','citycode');
        HDT_WS_HerokuAddressSearch.HDT_WS_HerokuAddressSearchResponse resVer = HDT_WS_HerokuAddressSearch.callServiceVer('modality','cityCode','streetCode','houseNumCode');
        HDT_WS_HerokuAddressSearch.HDT_WS_HerokuAddressSearchResponse resMass = HDT_WS_HerokuAddressSearch.callServiceMass('city1' , 'street', 'houseNum1');

        HDT_WS_HerokuAddressSearch.HDT_WS_PrestazioneObj hPrestazione = new HDT_WS_HerokuAddressSearch.HDT_WS_PrestazioneObj();
        List<HDT_WS_HerokuAddressSearch.HDT_WS_PrestazioneObj> hPrestazioneList = new List<HDT_WS_HerokuAddressSearch.HDT_WS_PrestazioneObj>();
		hPrestazioneList.add(hPrestazione);        
        resCom.prestazione = hPrestazioneList;
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
        
    	System.assertEquals('region', resCom.prestazione[0].region, 'Value of the field region not correctly set');
        
    	System.assertNotEquals(null, resVer, 'callServiceVer did not work correctly');
        System.assertNotEquals(null, resInd, 'callServiceInd did not work correctly');
        System.assertNotEquals(null, resCom, 'callServiceCom did not work correctly');
        System.assertNotEquals(null, resMass, 'callServiceCom did not work correctly');
        
    }
}