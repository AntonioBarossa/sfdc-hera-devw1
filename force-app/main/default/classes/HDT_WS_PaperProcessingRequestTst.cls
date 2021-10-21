/**
 * Header of the class "HDT_WS_PaperProcessingRequestTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_WS_PaperProcessingRequest"
 * @history
 * @Created 29/09/2021
 * Modified By:
 **/
@isTest
public class HDT_WS_PaperProcessingRequestTst {
       
	@isTest
    static void test1(){
        
        String filezipname = 'test';
        String type = 'test';
        String contentVersionId = 'TestId';
        List <String> contentsVersionIds = new List<String>();
        contentsVersionIds.add(contentVersionId);
        
        Test.startTest();
        
        HDT_WS_PaperProcessingRequest req1 = new HDT_WS_PaperProcessingRequest(filezipName,type,contentVersionId);
        
        HDT_WS_PaperProcessingRequest req2 = new HDT_WS_PaperProcessingRequest(filezipName,type,contentsVersionIds);
        
        Test.stopTest();
        
        System.assertNotEquals(null, req1, 'A request was not created');
        
        System.assertEquals('test', req1.filezipName, 'Value of the field filezipName not set');
        
        System.assertNotEquals(null, req2, 'A request was not created');
        
        System.assertEquals(1, req2.contentVersion.size(), 'Value of the field contentVersion not set');

    }
}