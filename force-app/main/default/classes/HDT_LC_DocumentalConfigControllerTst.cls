@isTest
public with sharing class HDT_LC_DocumentalConfigControllerTst {
    
    //DEBUG
    public static final String TEST_NAME = 'HDT_LC_DocumentalConfigControllerTst';
    
    
    //SETUP
    
    
    //TESTS
    
    //getDocument
    @isTest
    private static void getDocumentTest() {
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'isValidPhaseTest';
        System.debug(debugString);
        
        //SETUP
        Id folderId = [SELECT Id FROM Folder WHERE DeveloperName  =: 'DocumentalPayloadAdministration' LIMIT 1].Id;
        System.debug(debugString + ' - folderId: ' + folderId);
        
        Document myDoc = new Document();
        myDoc.Name = 'TestDoc';
        myDoc.FolderId = folderId;
        
        insert myDoc;
        
        Document myDoc2 = new Document();
        myDoc2.Name = 'Driver3';
        myDoc2.FolderId = folderId;
        
        insert myDoc2;
        
        //TESTING
        List<Document> docList = HDT_LC_DocumentalConfigController.getDocument();
        
        //ASSERTS
        System.assertEquals(1, docList.size());
        System.assertEquals('TestDoc', docList[0].name);
        
    }
    
}
