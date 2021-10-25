/**

Header of the class "HDT_WS_SIE34Tst"
@author Pooyan Ghadiri Abkenar, pooyan.ghadiriabkenar@webresults.it
@Version 1.0
@description: Apex Test Class of the relative Apex Class "HDT_WS_SIE34"
@history
@created 15/10/2021
Modified By:
**/

@isTest
public with sharing class HDT_WS_SIE34Tst {

    @isTest
    public static void testDataRequest () {

        String runId = '123';
        String status = 'test status';
        String errorMsg = 'error message';
        
        
       HDT_UTL_DataFactoryTst.createWebServiceConfiguration('SIE34', 'testUser', 'method', 'end');
       HDT_UTL_DataFactoryTst.createWebServiceCredential('FirstName LastName', 'pass321', 'myUser');

        List<FileTemplate__c> fileTemp = HDT_UTL_DataFactoryTst.createFileTemplate(1,true);
        String fileType = fileTemp[0].FileType__c;

        List<ContentVersion> contVers = HDT_UTL_DataFactoryTst.createContentVers(1,true);
        List<ContentVersion> contVersId = [SELECT id FROM ContentVersion WHERE id IN:contVers];
        

        list<string> contId = new list<string>();

        for(ContentVersion  c : contVersId ){

            contId.add(c.id);
        }

        Test.setMock(HttpCalloutMock.class, new HDT_WS_HTTPServiceCallMock());

       // HDT_WS_RicCreBpCaRequest req = new HDT_WS_RicCreBpCaRequest(runId, status, fileType, errorMsg, contId);

        Test.startTest();

        HDT_WS_SIE34DataResponse res =  HDT_WS_SIE34.callService(runId, status, fileType, errorMsg, contId);

        Test.stopTest();

        System.assertEquals(true, res != null ,'Data Response is not created (Empty)');
        System.assertNotEquals('', res.Status ,'Value of the Status is not set');
    }
}