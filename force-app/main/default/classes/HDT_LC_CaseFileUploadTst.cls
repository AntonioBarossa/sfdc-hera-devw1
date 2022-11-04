@isTest
public class HDT_LC_CaseFileUploadTst {

    @TestSetup
    static void makedata(){

        List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'MMS','MMS Azienda','Aziende SME');
        Id accId = accs[0].id;
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1,true,accId,null,null,null,null);

        List<ContentVersion> listContent = HDT_UTL_DataFactoryTst.createContentVersion(1,true,'test','body','path');
        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: listContent[0].id].ContentDocumentId;
        Database.update(new ContentDocument(Id = contentDocumentId, Description = 'testCaseFileUpload'));
        HDT_UTL_DataFactoryTst.createContentDocumentLink(1,true,caseList[0].id,contentDocumentId);

    }

    @isTest
	static void testGetFiles(){

        Test.startTest();

        List<Case> cases = [SELECT Id FROM Case WITH SECURITY_ENFORCED];

        String recId = cases[0].Id;

        List<ContentDocument> cdList = HDT_LC_CaseFileUpload.getFiles(recId);

        System.assertEquals(true, cdList != null && !cdList.isEmpty(), 'NESSUN CONTENT DOCUMENT TROVATO.');

        Test.stopTest();

    }

    @isTest
	static void testDeleteFile(){

        Test.startTest();

        List<ContentDocument> cds = [SELECT Id FROM ContentDocument WITH SECURITY_ENFORCED];

        String recId = cds[0].Id;

        HDT_LC_CaseFileUpload.deleteFile(recId);

        System.assertEquals(true, cds != null && !cds.isEmpty(), 'NESSUN CONTENT DOCUMENT TROVATO.');

        Test.stopTest();

    }

}
