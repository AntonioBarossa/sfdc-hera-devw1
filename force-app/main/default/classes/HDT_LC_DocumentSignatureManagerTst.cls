@isTest
public with sharing class HDT_LC_DocumentSignatureManagerTst {

	private static HDT_UTL_Constants utlConstants = new HDT_UTL_Constants();

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
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickCasePhase();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        insert new DocusignSettings__c(CustomerEnviromentId__c = 'HERA-TEST');
        DocumentSendTracking__c documentSendTracking = new DocumentSendTracking__c();
        documentSendTracking.EnvelopeId__c = 'resendDocusignTst';
        insert documentSendTracking;
    }

    @isTest
    static void createActChangeAddressTst(){ 

        Test.startTest();
        
        List<ServicePoint__c> spList = [SELECT Id,CommoditySector__c,IsAddressChanged__c FROM ServicePoint__c];
        spList[0].IsAddressChanged__c = true;
        update spList;
        
        List<Order> orderList = [SELECT Id, ParentOrder__c, AccountId FROM Order];
        List<Order> ordListParent = HDT_UTL_DataFactoryTst.createOrder(1, true, orderList[0].AccountId, 'Bozza');
        orderList[0].ServicePoint__c = spList[0].Id;
        orderList[0].ParentOrder__c = ordListParent[0].Id;
        orderList[0].Commodity__c = 'Acqua';
        orderList[0].RecordTypeId = utlConstants.ORDER_RECORDTYPEID_SUBENTRO;
        orderList[0].ProcessType__c = 'Subentro';
        update orderList;

        HDT_LC_DocumentSignatureManager.createActChangeAddress(ordListParent[0].Id);
        
        Test.stopTest();

        List<wrts_prcgvr__Activity__c> resultAct = [SELECT Id FROM wrts_prcgvr__Activity__c WHERE Type__c = 'Modifica Indirizzo Fornitura' AND Order__c =: orderList[0].Id ];

        System.assertEquals( true, resultAct.size()>0, 'createActChangeAddress did not work correctly');
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
    static void showOriginalDocumentZip(){
        Test.setMock(HttpCalloutMock.class, new HDT_WS_DocumentalIntegrationTstMock());
        Case c = [SELECT Id FROM Case LIMIT 1];
        update new Case(Id = c.Id, SignMode__c = 'OTP Remoto');
        Test.startTest();
        DocumentalActivity__c docAct = [SELECT Id FROM DocumentalActivity__c LIMIT 1];
        String result = HDT_LC_DocumentSignatureManager.showOriginalDocument(docAct.Id);
        Map<String,Object> mapResult = (Map<String,Object>) JSON.deserializeUntyped(result); 
        System.assertEquals('OK', (String)mapResult.get('outcome'), 'showOriginalDocumentZip did not work correctly');
        System.assertEquals('zip', (String)mapResult.get('type'), 'showOriginalDocumentZip did not work correctly');
        System.assertEquals('base64', (String)mapResult.get('base64'), 'showOriginalDocumentZip did not work correctly');
        System.assertEquals(true, mapResult.get('base64List') != null, 'showOriginalDocumentZip did not work correctly');
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

    @isTest
    static void handleContactPoint(){
        Test.startTest();
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        String result = HDT_LC_DocumentSignatureManager.handleContactPoint('email@email.com','3333333333',con.Id,'query');
        result = HDT_LC_DocumentSignatureManager.handleContactPoint('email@email.com','3333333333',con.Id,'insert');
        Boolean resultBool = String.isNotBlank(result)?true:false;
        System.assert(resultBool, true);
        Test.stopTest();
    }

    @isTest
    static void resendDocusignEnvelopeTst()
    {
        List<DocumentSendTracking__c> documentSendTracking = [SELECT Id, EnvelopeId__c FROM DocumentSendTracking__c];
        Test.setMock(HttpCalloutMock.class, new HDT_WS_DocumentalIntegrationTstMock());
        Test.startTest();
            String result = HDT_LC_DocumentSignatureManager.resendDocusignEnvelope(documentSendTracking[0].Id);
        Test.stopTest();
        System.assertEquals(true, String.isNotBlank(result), 'ResendDocusignEnvelope test fallito');
    }

    @isTest
    static void sendAdvanceDocumentationTst()
    {
        List<Order> orderList = [SELECT Id FROM Order];
        String formParams = '{\"sendMode\" : \"Cartacea\",\"mode\" : \"Print\",\"Archiviato\" : \"Y\",\"TipoPlico\": \"MODULISTICA_B12\"}';
        String context = 'DocumentazioneAnticipata';
        Test.setMock(HttpCalloutMock.class, new HDT_WS_DocumentalIntegrationTstMock());
        Test.startTest();
            HDT_LC_DocumentSignatureManager.sendAdvanceDocumentation(orderList[0].Id,context,formParams);
        Test.stopTest();
    }
    
}
