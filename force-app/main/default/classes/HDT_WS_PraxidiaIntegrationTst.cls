/**
 * Header of the class "HDT_WS_PraxidiaIntegrationTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_WS_PraxidiaIntegration"
 * @history
 * @Created 28/09/2021
 * Modified By:
 **/
@isTest
public class HDT_WS_PraxidiaIntegrationTst {
    
    @TestSetup
    static void makedata(){
        
        HDT_UTL_DataFactoryTst.createWebServiceConfiguration('PraxidiaIntegration','https://integration-ts.gruppohera.it/dev/salesforce-api-exp/api/data-management/files','POST','MulesoftSalesforceUser');
        
    }
    
	@isTest
    static void test1(){
        
        String contentversionid = 'test';
        String surveyType = 'test';
        
        Test.startTest();
        
        HDT_WS_Response res = HDT_WS_PraxidiaIntegration.callService(contentversionid, surveyType);
        
        Test.stopTest();
        
        System.assertNotEquals(null, res, 'A response was not successfully created');
        
        System.assertEquals(null, res.body, 'The respose fields should be set to null since the mock is not instantiated');

    }
}