/**
 * Header of the class "HDT_WS_CampagenDmDmpTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_WS_CampagenDmDmp"
 * @history
 * @Created 21/09/2021
 * Modified By:
 **/
@isTest
public class HDT_WS_CampagenDmDmpTst {
    @TestSetup
    static void makedata(){
        
        HDT_UTL_DataFactoryTst.createWebServiceConfiguration('CampagenDmDmpData','https://integration-ts.gruppohera.it/dev/salesforce-api-exp/api/data-management/files','POST','MulesoftSalesforceUser');
        
    }
    
	@isTest
    static void test1(){
        
        String runId = 'someid';
        String status = '';
        String fileType ='';
        String errorMessage = 'some error message';
        List<String> contentVersionIds = new List<String>();
        
        HDT_WS_CampagenDmDmpDataResponse res = HDT_WS_CampagenDmDmp.callService(runId,status,fileType,errorMessage,contentVersionIds);
        
        System.assertNotEquals(null, res, 'A response was not successfully created');
        System.assertEquals(null, res.data.testata, 'The respose fields should be set to null since the mock is not instantiated');

    }
}