@IsTest
public with sharing class HDT_LC_PaperCampaignGetFileTst {
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();

    @TestSetup
	static void setup(){

        HDT_UTL_DataFactoryTst.createPaperCommunication(1, true); 
    }

    @isTest
    private static void checkPaperFileTst()
    {
        List<PaperCommunication__c> pCList = [ SELECT Id, Name FROM PaperCommunication__c WITH SECURITY_ENFORCED ];

        Test.startTest();
        HDT_LC_PaperCampaignGetFile.createPaperFile('dGhpcyBpcyBhIHRlc3Q=', pCList[0].Id, pCList[0].Name);
        Boolean result = HDT_LC_PaperCampaignGetFile.checkPaperFile(pCList[0].Id, pCList[0].Name);
        Test.stopTest();
        
        System.assertEquals( true, result, 'Not correctly calculate');
    }

    @isTest
    private static void createPaperFileTst()
    {
        List<PaperCommunication__c> pCList = [ SELECT Id, Name FROM PaperCommunication__c WITH SECURITY_ENFORCED ];

        Test.startTest();
        String result = HDT_LC_PaperCampaignGetFile.createPaperFile('dGhpcyBpcyBhIHRlc3Q=', pCList[0].Id, pCList[0].Name);
        Test.stopTest();
        List<ContentDocumentLink> cdlList = [ SELECT Id FROM ContentDocumentLink WHERE ContentDocumentId = :result ];
        System.assertEquals( true, !cdlList.isEmpty() , 'Not correctly calculate');
    }

    @isTest
    private static void getPaperCommunicationRecordTst()
    {
        List<PaperCommunication__c> pCList = [ SELECT Id FROM PaperCommunication__c WITH SECURITY_ENFORCED ];

        Test.startTest();
        PaperCommunication__c pC = HDT_LC_PaperCampaignGetFile.getPaperCommunicationRecord(pCList[0].Id);
        Test.stopTest();

        System.assertEquals( true, pC != null , 'Not correctly calculate');
    }

    @isTest
    private static void getIdByNameTst()
    {
        Test.setMock(HTTPCalloutMock.class, new HDT_WS_TestMock());

        List<PaperCommunication__c> pCList = [ SELECT Id, Name FROM PaperCommunication__c WITH SECURITY_ENFORCED ];

        Test.startTest();
        String result = HDT_LC_PaperCampaignGetFile.getIdByName(pCList[0].Name);
        Test.stopTest();

        System.assertEquals( true, result.containsIgnoreCase('success') , 'Not correctly calculate');
    }

    @isTest
    private static void getFileByIdTst()
    {
        Test.setMock(HTTPCalloutMock.class, new HDT_WS_TestMock());

        List<PaperCommunication__c> pCList = [ SELECT Id FROM PaperCommunication__c WITH SECURITY_ENFORCED ];

        Test.startTest();
        String result = HDT_LC_PaperCampaignGetFile.getFileById(pCList[0].Id);
        Test.stopTest();

        System.assertEquals( true, result.containsIgnoreCase('success') , 'Not correctly calculate');
    }

    class HDT_WS_TestMock implements HTTPCalloutMock
    {
        public HttpResponse respond(HttpRequest request)
        {
            String body = '{"status": "success","correlationId": "0060ea20-37f5-11ed-ba57-0233fc6d39bc","timestamp": "2022-09-19T10:28:13","data": {}}';
            
            HttpResponse result = new HttpResponse();
            result.setStatusCode(200);
            result.setStatus('success');
            result.setBody(body);
            result.setHeader('Content-Type', 'application/json');

            return result;
        }
    }
}