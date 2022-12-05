@isTest
public with sharing class HDT_UTL_DocumentalManagementTst {
    @TestSetup
    static void setup(){
        Id pricebookId = Test.getStandardPricebookId();

        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');

        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, false, accList[0].id, 'Bozza');
        ordList[0].Pricebook2Id=pricebookId;
        ordList[0].ServicePoint__c = servPointList[0].Id;
        ordList[0].SignatureMethod__c = 'OTP Remoto';
        insert ordList;
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Sale__c> sales = HDT_UTL_DataFactoryTst.createSale(1, true, accList[0].id, 'Bozza');
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        List<BillingProfile__c> billingProfileList = HDT_UTL_DataFactoryTst.createBillingProfile(1,true, accList[0].Id);
        HDT_UTL_DataFactoryTst.createChildOrder(1, true, accList[0].Id, sales, ordList[0].Id, contactList[0].Id);
        
        List<DocumentalPayloadAdministration__c> documList = HDT_UTL_DataFactoryTst.createDocumentalPayloadAdm();
        List<DocumentalActivity__c> docActList = HDT_UTL_DataFactoryTst.createDocumentalActivity(1,null,caseList[0].Id);


        
        
        List<Product2> prods = HDT_UTL_DataFactoryTst.createProduct2(1, false);
        prods[0].Family = 'VAS Fatturabili';
        prods[0].DescriptionSAP__c = 'descr';
        insert prods;
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        HDT_UTL_DataFactoryTst.pClickCasePhase();
        List<PricebookEntry> entries = HDT_UTL_DataFactoryTst.createPricebookEntry(prods, true, pricebookId);
        HDT_UTL_DataFactoryTst.createOrderItem(1, true, ordList[0].Id, servPointList[0].id, prods[0].id, entries[0].id);


        HDT_UTL_DataFactoryTst.createJsonPayload();
        HDT_UTL_DataFactoryTst.createDriverJson();
        HDT_UTL_DataFactoryTst.pClickInstance();
        
        HDT_UTL_DataFactoryTst.newPhaseTransition('Attesa conferma preventivo cliente', 'Bozza', caseList[0].Id, 'HDT_RT_Default');

        
    }
    
    @isTest
    static void testManageAmount() {
        Test.startTest();
        
        String originalAmount = '186.38';
        String expectedAmount = '186,38';
        
        String managedAmount = HDT_UTL_DocumentalManagement.manageAmountDot(originalAmount);
        System.assertEquals(expectedAmount, managedAmount,'Manage Amount OK');
        
        originalAmount = '38';
        expectedAmount = '38,00';
        
        managedAmount = HDT_UTL_DocumentalManagement.manageAmountDot(originalAmount);
        System.assertEquals(expectedAmount, managedAmount,'Manage Amount OK');
        
        originalAmount = '';
        expectedAmount = '0,00';
        
        managedAmount = HDT_UTL_DocumentalManagement.manageAmountDot(originalAmount);
        System.assertEquals(expectedAmount, managedAmount,'Manage Amount OK');
        
        Test.stopTest();
    }
    
    
    
    @isTest
    static void testCreateContentLink() {
        Test.startTest();
        ContentVersion cv1 = HDT_UTL_DocumentalManagement.createContectVersion('testBase64','filetest');
        Case ca = [SELECT Id FROM Case LIMIT 1];
        Order ord = [SELECT Id, OrderNumber FROM Order LIMIT 1];
        
        ContentDocumentLink cLink = HDT_UTL_DocumentalManagement.createContentLink(String.valueof(cv1.Id), String.valueof(ca.Id));
        String st1 = HDT_UTL_DocumentalManagement.createContentDistribution(String.valueof(cv1.Id), 'filetest');
        
        
        Test.stopTest();
    }
    
    
    public static HDT_WRP_DocumentalResponse createResponse(){
        
        Order testOrder = [SELECT Id FROM Order LIMIT 1];
        
        HDT_WRP_DocumentalResponse.HDT_WRP_DocumentalResponseAttachment attach;
        attach = new HDT_WRP_DocumentalResponse.HDT_WRP_DocumentalResponseAttachment();
        attach.code = 'Attachment Code';
        attach.type = '';
        attach.version = '1.0';
        attach.mandatory = '1';
        attach.signature = '';
        
        //HDT_WRP_DocumentalResponseServiceItem
        HDT_WRP_DocumentalResponse.HDT_WRP_DocumentalResponseServiceItem servItem;
        servItem = new HDT_WRP_DocumentalResponse.HDT_WRP_DocumentalResponseServiceItem();
        servItem.serviceId = '';//recordId
        servItem.attachId = '';
        servItem.attachName = '';
        servItem.attachVersion = '';
        servItem.attachmentList = new List<HDT_WRP_DocumentalResponse.HDT_WRP_DocumentalResponseAttachment>{attach};
            
            //HDT_WRP_DocumentalResponseRoot
            HDT_WRP_DocumentalResponse.HDT_WRP_DocumentalResponseRoot docRoot;
        docRoot = new HDT_WRP_DocumentalResponse.HDT_WRP_DocumentalResponseRoot();
        docRoot.requestId = testOrder.Id;
        docRoot.composedDocument = '';
        docRoot.packageIds = 'ID_Tracking_Envelope_ID';
        docRoot.archive = 'Y';
        docRoot.result = '000';
        docRoot.message = '';//Pare non sia utilizzato.
        docRoot.serviceList = new List<HDT_WRP_DocumentalResponse.HDT_WRP_DocumentalResponseServiceItem>{servItem};
            
            //HDT_WRP_DocumentalResponse
            HDT_WRP_DocumentalResponse docRes = new HDT_WRP_DocumentalResponse();
        docRes.responseCode = 200;//è IL VERO response.setStatusCode
        docRes.responseStatus = 'Success';//è IL VERO response.setStatus
        docRes.deliverPackageResponse = docRoot;
        return docRes;
    }
    
    @isTest
    static void testCreateDocumentEnvelopmentAttachment() {
        Test.startTest();
        ContentVersion cv1 = HDT_UTL_DocumentalManagement.createContectVersion('testBase64','filetest');
        
        Order ord = [SELECT Id, OrderNumber FROM Order LIMIT 1];
        
        HDT_WRP_DocumentalResponse resp = createResponse();
        HDT_UTL_DocumentalManagement.createDocumentEnvelopeAttachment(resp,'Order');
        SObject processRecord = HDT_UTL_DocumentalManagement.getProcessRecord(ord.OrderNumber, 'Order');
        Boolean res = HDT_UTL_DocumentalManagement.updateDocumentalPhase(processRecord, resp, 'Order');
        
        
        Test.stopTest();
    }
    
    
    @isTest
    static void testCreateDocument() {
        Test.startTest();
        ContentVersion cv1 = HDT_UTL_DocumentalManagement.createContectVersion('testBase64','filetest');
        
        Order ord = [SELECT Id, OrderNumber FROM Order LIMIT 1];
        
        HDT_WRP_DocumentalResponse resp = createResponse();
        HDT_UTL_DocumentalManagement.createDocumentEnvelopeAttachment(resp,'Order');
        SObject processRecordOrder = HDT_UTL_DocumentalManagement.getProcessRecord(ord.OrderNumber, 'Order');
        
        Boolean res = HDT_UTL_DocumentalManagement.updateDocumentalPhase(processRecordOrder, resp, 'Order');
        If (res) System.assertEquals('Plico in firma', processRecordOrder.get('DocumentalPhase__c'), 'Non aggiornato in modo vero');

        Case ca = [SELECT Id, CaseNumber, Phase__c FROM Case LIMIT 1];
        HDT_WRP_DocumentalResponse resp1 = createResponse();
        HDT_UTL_DocumentalManagement.createDocumentEnvelopeAttachment(resp,'Case');
        SObject processRecordCase = HDT_UTL_DocumentalManagement.getProcessRecord(ca.CaseNumber, 'Case');
        
        
        Test.stopTest();
    }


    @isTest
    static void testCreateDocumentSendTracking() {
        Test.startTest();
        
        Order ord = [SELECT Id, OrderNumber FROM Order LIMIT 1];
        Case ca = [SELECT Id, CaseNumber, Phase__c FROM Case LIMIT 1];        
        Account acc = [SELECT Id FROM Account LIMIT 1];

        SObject processRecordOrder = HDT_UTL_DocumentalManagement.getProcessRecord(ord.OrderNumber, 'Order');
        
		 HDT_UTL_DocumentalManagement.createDocumentSendTracking('test', ord.Id, 'test', processRecordOrder);
         DocumentSendTracking__c doct = [SELECT Id, Type__c FROM DocumentSendTracking__c WHERE Order__c =:ord.Id LIMIT 1];
         System.assertEquals(doct.Type__c, 'Plico Contrattuale','createDocumentSendTracking Order went wrong');

         SObject processRecordCase = HDT_UTL_DocumentalManagement.getProcessRecord(ca.CaseNumber, 'Case');
        
		 HDT_UTL_DocumentalManagement.createDocumentSendTracking('test', ca.Id, 'test', processRecordCase);
         DocumentSendTracking__c doctc = [SELECT Id, Type__c FROM DocumentSendTracking__c WHERE Case__c =: ca.Id LIMIT 1];
         System.assertEquals(doctc.Type__c, 'Plico','createDocumentSendTracking Case went wrong');

         SObject processRecordTest = HDT_UTL_DocumentalManagement.getProcessRecord(acc.Id, 'Account');
        
		 HDT_UTL_DocumentalManagement.createDocumentSendTracking('test', acc.Id, 'test', processRecordTest);
         DocumentSendTracking__c doctt = [SELECT Id, Type__c FROM DocumentSendTracking__c WHERE Type__c ='Estratto Conto' LIMIT 1];
         System.assertEquals(doctt.Type__c, 'Estratto Conto','createDocumentSendTracking Account went wrong');
        Test.stopTest();
    }
    @isTest
    static void testCreateDocumentSendTrackingError() {
        Test.startTest();
        
        Order ord = [SELECT Id, OrderNumber FROM Order LIMIT 1];
        Case ca = [SELECT Id, CaseNumber, Phase__c FROM Case LIMIT 1];        
        Account acc = [SELECT Id FROM Account LIMIT 1];

        SObject processRecordOrder = HDT_UTL_DocumentalManagement.getProcessRecord(ord.OrderNumber, 'Order');
        
		 HDT_UTL_DocumentalManagement.createDocumentalActivityForError('testOrder', ord.Id, 'test', processRecordOrder);
         DocumentalActivity__c doct = [SELECT Id, ErrorDescription__c FROM DocumentalActivity__c WHERE OrderId__c =:ord.Id LIMIT 1];
         System.assertEquals(doct.ErrorDescription__c, 'testOrder','testCreateDocumentSendTrackingError Order went wrong');

         HDT_UTL_DocumentalManagement.createDocumentalActivityForError('35', ord.Id, 'test', processRecordOrder);
         wrts_prcgvr__Activity__c act1 = [SELECT DiscardCategory__c FROM  wrts_prcgvr__Activity__c LIMIT 1];
         System.assertEquals(act1.DiscardCategory__c, 'Scarto complesso','testCreateDocumentSendTrackingError Order went wrong');


/*
         SObject processRecordCase = HDT_UTL_DocumentalManagement.getProcessRecord(ca.CaseNumber, 'Case');
        
		 HDT_UTL_DocumentalManagement.createDocumentalActivityForError('testCase', ca.Id, 'test', processRecordCase);
         DocumentalActivity__c doctc = [SELECT Id, ErrorDescription__c FROM DocumentalActivity__c WHERE CaseId__c =: ca.Id LIMIT 1];
         System.assertEquals(doctc.ErrorDescription__c, 'testCase','testCreateDocumentSendTrackingError Case went wrong');

*/
        Test.stopTest();
    }


    @isTest
    static void testCreateRequestOrder() {
        Test.startTest();
        Map<String,Object> formParams = new Map<String,Object>();
        formParams.put('Contesto', 'Order');
        List<Order> ord = [SELECT Id, OrderNumber FROM Order LIMIT 1];
        String res = HDT_SRV_DocumentalManagement.generateRequest((String)ord[0].Id,'Order', JSON.serialize(formParams));
       
        Test.stopTest();
    }

    @isTest
    static void testCreateRequestCase() {
        Test.startTest();
        Map<String,Object> formParams = new Map<String,Object>();
        formParams.put('Contesto', 'Case');
        Case ca = [SELECT Id, CaseNumber, Phase__c FROM Case LIMIT 1]; 
        String res = HDT_SRV_DocumentalManagement.generateRequest((String)ca.Id,'Case', JSON.serialize(formParams));
       
        Test.stopTest();
    }
@isTest
    static void testgeneratePayloadGestioneCredito() {
        Test.startTest();
        Map<String,Object> primolivello = new Map<String,Object>();
        primolivello.put('societa', 'HERA COMM MARCHE');
        primolivello.put('testt', 'HERA COMM MARCHE');
        PrimoLivello.put('secondoLivelloInformativo', 'secondoLivelloList');
        PrimoLivello.put('residuo', '10.5');
        PrimoLivello.put('importo', '21.0');
        PrimoLivello.put('numeroFattura', '10203040');
        PrimoLivello.put('recuperoCrediti', '10203040');
        PrimoLivello.put('residuo', '112');
        
        PrimoLivello.put('dataScadenza', JSON.serialize(Date.today().addDays(10)));
        List<Object> itemVasList = new List<Object>();
        itemVasList.add(primolivello);
        Map<String,Object> formParams = new Map<String,Object>();
        formParams.put('Contesto', 'EC');
        formParams.put('EstrattoConto', JSON.serialize(itemVasList));
        Case ca = [SELECT Id, CaseNumber, Phase__c FROM Case LIMIT 1]; 
        String res = HDT_SRV_DocumentalManagement.generatePayloadGestioneCredito(formParams);
       
        Test.stopTest();
    }
@isTest
    static void testcreateLandRegistryRecord(){
        Test.startTest();
        Map<String, String> docusignData = new Map<String, String>();
        docusignData.put('DTC_radiocat_1', 'arg1');
        docusignData.put('DTC_comune_amm_1', 'arg1');
        docusignData.put('DTC_comune_cat_1', 'arg1');
        docusignData.put('DTC_cod_comune_1', 'arg1');
        docusignData.put('DTC_tipo_uni_1', 'arg1');
        docusignData.put('DTC_sezione_1', 'arg1');
        docusignData.put('DTC_foglio_1', 'arg1');
        docusignData.put('DTC_partic_1', 'arg1');
        docusignData.put('DTC_estens_partic_1', 'arg1');
        docusignData.put('DTC_tipo_partic_1', 'arg1');
        docusignData.put('DTC_sub_1', 'arg1');
        docusignData.put('DTC_sezione_1', 'arg1');


        Map<String, String> docusignRadioGroups = new Map<String, String>();

        docusignRadioGroups.put('DTC_qualitadi_1','arg1');
        Order ord = [Select Id, OrderNumber, ServicePoint__c, EffectiveDate__c,SupplyState__c, SurfaceServed__c,SupplyType__C  From Order Limit 1];
        LandRegistry__c res = HDT_UTL_DocumentalManagement.createLandRegistryRecord(docusignData,docusignRadioGroups,  ord, 1);
        Test.stopTest();
    }
@isTest
    static void testinitDocumentalActivity(){
        Test.startTest();
        Order ord = [SELECT Id, OrderNumber FROM Order LIMIT 1];
        
        HDT_WRP_DocumentalResponse resp = createResponse();
        HDT_UTL_DocumentalManagement.createDocumentEnvelopeAttachment(resp,'Order');

        HDT_UTL_DocumentalManagement.initDocumentalActivity(ord, '12121212');

        Test.stopTest();
    }

    @isTest
    static void testCalculateDocumentStatus(){
        Test.startTest();
        String res = HDT_UTL_DocumentalManagement.calculateDocumentStatus(12, 4,true);
        String res1 = HDT_UTL_DocumentalManagement.calculateDocumentStatus(12, 0,false);
        String res2 = HDT_UTL_DocumentalManagement.calculateDocumentStatus(-12, 0,false);
        String res3 = HDT_UTL_DocumentalManagement.calculateDocumentStatus(-12, -16,false);
        String res4 = HDT_UTL_DocumentalManagement.calculateDocumentStatus(12, 4,false);

        Test.stopTest();
    }

    @isTest
    static void testContext3(){
        Test.startTest();
        List<Account> acc = [SELECT Id FROM Account];
        List<Map<String, List<sObject>>> recordObjectsListMap = HDT_UTL_DocumentalManagement.getRecordObjectsList(acc, 'Context3');
        Test.stopTest();
}

@isTest
static void testContext4(){
    Test.startTest();
    List<Account> acc = [SELECT Id FROM Account];
    List<Map<String, List<sObject>>> recordObjectsListMap = HDT_UTL_DocumentalManagement.getRecordObjectsList(acc, 'Context4');
    Test.stopTest();
}

@isTest
static void testgetConcatValueFromObject(){
    Test.startTest();
    Map<String,List<sObject>> inputs = new Map<String,List<sObject>>();
    HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalRecord docRecord;
    docRecord = new HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalRecord();
    String res = HDT_UTL_DocumentalManagement.getConcatValueFromObject(inputs, docRecord);
Test.stopTest();
}

@isTest
static void testCreateRequestDocumentazioneAnticipata() {
    Test.startTest();
    Map<String,Object> formParams = new Map<String,Object>();
    formParams.put('Contesto', 'DocumentazioneAnticipata');
    List<Order> ord = [SELECT Id, OrderNumber FROM Order LIMIT 1];
    String res = HDT_SRV_DocumentalManagement.generateRequest((String)ord[0].Id,'DocumentazioneAnticipata', JSON.serialize(formParams));
   
    Test.stopTest();
}
}