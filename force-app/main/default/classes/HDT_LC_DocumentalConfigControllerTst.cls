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
        System.assertEquals(1, docList.size(), 'getDocument did not work correctly');
        System.assertEquals('TestDoc', docList[0].name, 'getDocument did not work correctly');
        
    }
    
    //controllerHandler
    @isTest
    private static void controllerHandlerTest() {
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'controllerHandlerTest';
        System.debug(debugString);
        
        //SETUP
        Id folderId = [SELECT Id FROM Folder WHERE DeveloperName  =: 'DocumentalPayloadAdministration' LIMIT 1].Id;
        System.debug(debugString + ' - folderId: ' + folderId);
        
        Document myDoc = new Document();
        myDoc.Name = 'TestDoc';
        myDoc.FolderId = folderId;
        
        insert myDoc;
        
        
        //(no insert)
        DocumentalPayloadAdministration__c docPA1 = new DocumentalPayloadAdministration__c();
        docPA1.Context1__c = true;
        docPA1.IsData__c = true;
        docPA1.Type__C = 'Test_Type';
        DocumentalPayloadAdministration__c docPA2 = new DocumentalPayloadAdministration__c();
        docPA2.Context1__c = true;
        docPA2.Iterative__c = 'Fill';
        docPA2.Type__C = 'Test_Type';
        
        DocumentalPayloadAdministration__c docPA3 = new DocumentalPayloadAdministration__c();
        docPA3.Context2__c = true;
        docPA1.IsData__c = true;
        docPA3.Type__C = 'Test_Type';
        DocumentalPayloadAdministration__c docPA4 = new DocumentalPayloadAdministration__c();
        docPA4.Context2__c = true;
        docPA4.Iterative__c = 'Fill';
        docPA4.Type__C = 'Test_Type';
        
        DocumentalPayloadAdministration__c docPA5 = new DocumentalPayloadAdministration__c();
        docPA5.Context3__c = true;
        docPA1.IsData__c = false;
        docPA5.Type__C = 'Test_Type';
        DocumentalPayloadAdministration__c docPA6 = new DocumentalPayloadAdministration__c();
        docPA6.Context3__c = true;
        docPA6.Iterative__c = 'Fill';
        docPA6.Type__C = 'Test_Type';
        
        DocumentalPayloadAdministration__c docPA7 = new DocumentalPayloadAdministration__c();
        docPA7.Context4__c = true;
        docPA1.IsData__c = false;
        docPA7.Type__C = 'Test_Type';
        DocumentalPayloadAdministration__c docPA8 = new DocumentalPayloadAdministration__c();
        docPA8.Context4__c = true;
        docPA8.Iterative__c = 'Fill';
        docPA8.Type__C = 'Test_Type';
        
        
        DocumentalPayloadAdministration__c docPATDRV = new DocumentalPayloadAdministration__c();
        docPATDRV.Type__C = 'TDRV';
        
        //TESTING NO RECORDS
        HDT_WRP_DocumentalConfiguration.HDT_WRP_DatabaseResult result = HDT_LC_DocumentalConfigController.controllerHandler();
        
        //ASSERTS
        System.assertNotEquals(true, result.success, 'controllerHandler did not work correctly');
        System.assertEquals('No records found', result.message, 'controllerHandler did not work correctly');
        
        //TESTING WITH RECORDS
        insert new List<SObject>{docPA1, docPA2, docPA3, docPA4, docPA5, docPA6, docPA7, docPA8, docPATDRV};
        result = HDT_LC_DocumentalConfigController.controllerHandler();
        
        //RETRIEVING DATA
        List<Document> docOld = [SELECT Id FROM Document WHERE Id = :myDoc.Id];
        List<Document> docs = [SELECT Id FROM Document];
        
        //ASSERTS
        System.assertEquals(0, docOld.size(), 'controllerHandler did not work correctly');
        System.assertEquals(4, result.docIdList.size(), 'controllerHandler did not work correctly');
        
    }
    
    
}
