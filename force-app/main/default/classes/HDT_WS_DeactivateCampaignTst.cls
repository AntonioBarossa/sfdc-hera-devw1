/**
 * Header of the class "HDT_WS_DeactivateCampaignTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_WS_DeactivateCampaign"
 * @history
 * @Created 20/10/2021
 * Modified By:
 **/
@isTest
public class HDT_WS_DeactivateCampaignTst {
    @isTest static void test1(){
        
        HDT_UTL_DataFactoryTst.createWebServiceConfiguration('arrestocampaign','https://integration-ts.gruppohera.it/dev/salesforce-api-exp/api/data-management/files','POST','MulesoftSalesforceUser');
        
        Test.startTest();
        HDT_WS_DeactivateCampaign.wrapResponseGetData res = HDT_WS_DeactivateCampaign.callDeactivateCampaign('test');
        Test.stopTest();
        
        System.assertEquals(null, res.data, 'HDT_WS_DeactivateCampaign did not work correctly');
        System.assertNotEquals(null, res, 'HDT_WS_DeactivateCampaign did not work correctly');
    }
}