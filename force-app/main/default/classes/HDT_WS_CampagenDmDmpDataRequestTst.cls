/**
 * Header of the class "HDT_WS_CampagenDmDmpDataRequestTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_WS_CampagenDmDmpDataRequest"
 * @history
 * @Created 21/09/2021
 * Modified By:
 **/
@isTest
public class HDT_WS_CampagenDmDmpDataRequestTst {
    @TestSetup
    static void makedata(){
        HDT_UTL_DataFactoryTst.createWebServiceConfiguration('CampagenDmDmpData','https://integration-ts.gruppohera.it/dev/salesforce-api-exp/api/data-management/files','POST','MulesoftSalesforceUser');
    }
    @isTest
    static void test1(){
        String runId = 'someid';
        String status = 'expected status';
        String fileType ='';
        String errorMessage = 'some error message';
        List<String> contentVersionIds = new List<String>();
        
        Test.startTest();
        HDT_WS_CampagenDmDmpDataRequest req = new HDT_WS_CampagenDmDmpDataRequest(runId,status,fileType,errorMessage,contentVersionIds);
        Test.stopTest();
        
        System.assertEquals('expected status', req.status, 'Value of the field status not set');
        System.assertNotEquals(null, req.runId, 'Value of the field runId not set');
        
    }

}