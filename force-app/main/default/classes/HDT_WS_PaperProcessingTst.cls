/**
 * Header of the class "HDT_WS_PaperProcessingTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_WS_PaperProcessing"
 * @history
 * @Created 29/09/2021
 * Modified By:
 **/
@isTest
public class HDT_WS_PaperProcessingTst {
    
    @TestSetup
    static void makedata(){
        
        HDT_UTL_DataFactoryTst.createWebServiceConfiguration('postPaperProcessing','https://integration-ts.gruppohera.it/dev/salesforce-api-exp/api/data-management/files','POST','MulesoftSalesforceUser');
        
    }
    
	@isTest
    static void test1(){
        
        String filezipname = 'test';
        String type = 'test';
        String contentVersionId = 'TestId';
        List <String> contentsVersionIds = new List<String>();
        contentsVersionIds.add(contentVersionId);
        
        Test.startTest();
        
        HDT_WS_Response res1 = HDT_WS_PaperProcessing.postPaperProcessing(filezipName,type,contentVersionId);
        
        HDT_WS_Response res2 = HDT_WS_PaperProcessing.postPaperProcessing(filezipName,type,contentsVersionIds);
        
        Test.stopTest();
        
        System.assertNotEquals(null, res1, 'A response was not created');
        
        System.assertEquals(null, res1.body, 'The respose fields should be set to null since the mock is not instantiated');
        
        System.assertNotEquals(null, res2, 'A response was not created');
        
        System.assertEquals(null, res2.body, 'The respose fields should be set to null since the mock is not instantiated');

    }
}