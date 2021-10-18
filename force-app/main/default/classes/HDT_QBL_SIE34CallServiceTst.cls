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
        System.assertNotEquals(false,JSON.serialize(thisCallService).contains('fileType'),'The value fileType has been provided during the instantiation');
        Test.stopTest();
    }
}