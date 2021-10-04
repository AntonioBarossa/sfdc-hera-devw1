/**
 * Header of the class "HDT_WS_CampaignBollettaTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_WS_CampaignBolletta"
 * @history
 * @Created 28/09/2021
 * Modified By:
 **/
@isTest
public class HDT_WS_CampaignBollettaTst {
    
    @TestSetup
    static void makedata(){
        
        HDT_UTL_DataFactoryTst.createWebServiceConfiguration('campaignBolletta','https://integration-ts.gruppohera.it/dev/salesforce-api-exp/api/data-management/files','POST','MulesoftSalesforceUser');
        
    }
    
	@isTest
    static void test1(){
        
        String contentversionid = 'test';
        String surveyType = 'test';
        
        Test.startTest();
        
        List<HDT_WS_CampaignBolletta.HDT_WS_CampaignBollettaRequest> requests = new List<HDT_WS_CampaignBolletta.HDT_WS_CampaignBollettaRequest>();
        HDT_WS_CampaignBolletta.HDT_WS_CampaignBollettaRequest req = new HDT_WS_CampaignBolletta.HDT_WS_CampaignBollettaRequest();
        req.campaignDescription = 'test';
        req.campaignId = 'test';
        req.campaignName = 'test';
        req.comunicationText = 'test';
        req.contractCode = 'test';
        requests.add(req);
        
        HDT_WS_CampaignBolletta.HDT_WS_CampaignBollettaRequestWrap reqWrap = new HDT_WS_CampaignBolletta.HDT_WS_CampaignBollettaRequestWrap();
        reqWrap.campaignDescription = 'test';
        reqWrap.campaignId = 'test';
        reqWrap.campaignName = 'test';
        reqWrap.comunicationText = 'test';
        reqWrap.contractCode = 'test';
        
        HDT_WS_Response res = HDT_WS_CampaignBolletta.channelBolletta(requests);
        
        Test.stopTest();
        
        System.assertNotEquals(null, res, 'A response was not created');
        
        System.assertEquals(null, res.body, 'The respose fields should be set to null since the mock is not instantiated');

    }
}