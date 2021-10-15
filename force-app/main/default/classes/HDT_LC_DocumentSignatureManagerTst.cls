@isTest
public with sharing class HDT_LC_DocumentSignatureManagerTst {
    @TestSetup
    static void setup(){

        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        List<DocumentalPayloadAdministration__c> documList = HDT_UTL_DataFactoryTst.createDocumentalPayloadAdm();
        List<DocumentalActivity__c> docActList = HDT_UTL_DataFactoryTst.createDocumentalActivity(1,null,caseList[0].Id);
        HDT_UTL_DataFactoryTst.createJsonPayload();
        HDT_UTL_DataFactoryTst.createDriverJson();
    }

    @isTest
    static void showOriginalDocumentPdf(){
        Test.setMock(HttpCalloutMock.class, new HDT_WS_DocumentalIntegrationTstMock());
        Test.startTest();
        DocumentalActivity__c docAct = [SELECT Id FROM DocumentalActivity__c LIMIT 1];
        String result = HDT_LC_DocumentSignatureManager.showOriginalDocument(docAct.Id);
        Map<String,Object> mapResult = (Map<String,Object>) JSON.deserializeUntyped(result); 
        System.assertEquals('OK', (String)mapResult.get('outcome'), 'showOriginalDocumentPdf did not work correctly');
        System.assertEquals('pdf', (String)mapResult.get('type'), 'showOriginalDocumentPdf did not work correctly');
        System.assertEquals('base64', (String)mapResult.get('base64'), 'showOriginalDocumentPdf did not work correctly');
    }
    @isTest
    static void showArchivedAttachmentPdf(){
        Test.setMock(HttpCalloutMock.class, new HDT_WS_DocumentalIntegrationTstMock());
        Test.startTest();
        DocumentalActivity__c docAct = [SELECT Id FROM DocumentalActivity__c LIMIT 1];
        String result = HDT_LC_DocumentSignatureManager.showArchivedAttachment(docAct.Id);
        Map<String,Object> mapResult = (Map<String,Object>) JSON.deserializeUntyped(result); 
        System.assertEquals('OK', (String)mapResult.get('outcome'), 'showArchivedAttachmentPdf did not work correctly');
        System.assertEquals('base64', (String)mapResult.get('base64'), 'showArchivedAttachmentPdf did not work correctly');    
    }
    @isTest
    static void previewDocumentFileCase() {
        Test.setMock(HttpCalloutMock.class, new HDT_WS_DocumentalIntegrationTstMock());
        Test.startTest();
        Case tCase = [SELECT Id, Status FROM Case WHERE Status = 'In Lavorazione' LIMIT 1];
        Map<String,String> formParams = new Map<String,String>();
        Map<String,Object> resultMap = new Map<String,Object>();
        String mappa = HDT_LC_DocumentSignatureManager.previewDocumentFile(tCase.Id, 'Case', JSON.serialize(formParams));
        resultMap = (Map<String,Object>) JSON.deserializeUntyped(mappa);
        System.assertEquals('000', (String)resultMap.get('result'), 'previewDocumentFileCase did not work correctly');
        Test.stopTest();
    }

    @isTest
    static void sendDocumentFile() {
        Test.setMock(HttpCalloutMock.class, new HDT_WS_DocumentalIntegrationTstMock());
        Test.startTest();
        Case tCase = [SELECT Id, Status FROM Case WHERE Status = 'In Lavorazione' LIMIT 1];
        Map<String,String> formParams = new Map<String,String>();
        Map<String,Object> resultMap = new Map<String,Object>();
        HDT_LC_DocumentSignatureManager.sendDocumentFile(tCase.Id, 'Case', JSON.serialize(formParams));
        System.assertEquals('000', '000', 'sendDocumentFile did not work correctly');
        Test.stopTest();
    }

    @isTest
    static void getSignSendMode() {
        Test.startTest();
        Case tCase = [SELECT Id, Status FROM Case WHERE Status = 'In Lavorazione' LIMIT 1];
        Map<String,String> formParams = new Map<String,String>();
        String result = HDT_LC_DocumentSignatureManager.getSignSendMode('Variazione Potenza','Sportello');
        System.assert(String.isNotBlank(result), 'getSignSendMode did not work correctly');
        Test.stopTest();
    }

    @isTest
    static void getInfoAccountStatement() {
        Test.startTest();
        Account tAccount = [SELECT Id FROM Account LIMIT 1];
        Map<String,String> formParams = new Map<String,String>();
        String result = HDT_LC_DocumentSignatureManager.getInfoAccountStatement(tAccount.Id);
        System.assert(String.isNotBlank(result), 'getInfoAccountStatement did not work correctly');
        Test.stopTest();
    }

    
}
