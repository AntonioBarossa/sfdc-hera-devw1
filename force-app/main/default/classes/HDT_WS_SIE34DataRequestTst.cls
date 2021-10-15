@isTest
public with sharing class HDT_WS_SIE34DataRequestTst {

    @isTest
    public static void testDataRequest () {

        String runId = '123';
        String status = 'test status';
        String errorMsg = 'error message';
        

        List<FileTemplate__c> fileTemp = HDT_UTL_DataFactoryTst.createFileTemplate(1,true);
        String fileType = fileTemp[0].FileType__c;

        List<ContentVersion> contVers = HDT_UTL_DataFactoryTst.createContentVers(1,true);
        List<ContentVersion> contVersId = [SELECT id FROM ContentVersion WHERE id IN:contVers];
        

        list<string> contId = new list<string>();

        for(ContentVersion  c : contVersId ){

            contId.add(c.id);
        }

        Test.startTest();
        
        HDT_WS_SIE34DataRequest dataReq = new HDT_WS_SIE34DataRequest(runId, status, fileType, errorMsg, contId);
        
        Test.stopTest();

        System.assertEquals(true, dataReq != null ,'Data Request is not created (Empty)');
        System.assertNotEquals('', dataReq.status ,'Value of the Status is not set');

    }
}