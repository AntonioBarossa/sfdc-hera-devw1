/**
 * @author Valere (valere@noeli-it.net)
 * @date 14/10/2021
 * @description HDT_QBL_SIE34CallServiceTst Test Class
 * @history valere - 14/10/2021– Created Class
 */
@istest
public class HDT_QBL_SIE34CallServiceTst {

    @istest
    static void testexecute(){
        String runId='runId';
        String status='status';
        String fileType='fileType';
        String errorMessage='errorMessage';
        List<String> contentVersionIds = new List<String>();
        contentVersionIds.add('content0');  
        contentVersionIds.add('content1');  
        contentVersionIds.add('content2');
        HDT_UTL_DataFactoryTst.createWebServiceConfiguration('SIE34', 'https://integration-ts.gruppohera.it/dev/salesforce-api-exp/api/data-enrichment/entities', 'POST', 'HerokuUser');
        HDT_UTL_DataFactoryTst.createWebServiceConfiguration('SIE34', 'https://integration-ts.gruppohera.it/dev/salesforce-api-exp/api/data-enrichment/entities', 'POST', 'HerokuUser');
        Test.setMock(HttpCalloutMock.class, new HDT_QBL_SIE34CallServiceMck());
        Test.startTest();  
        HDT_QBL_SIE34CallService thisCallService = new HDT_QBL_SIE34CallService(runId,status,fileType,errorMessage,contentVersionIds);
        System.enqueueJob(thisCallService);
        System.assertEquals(true,JSON.serialize(thisCallService).contains('fileType'),'The HDT_QBL_SIE34CallService has been well instantiated with the fileType value');
        Test.stopTest();
    }
}