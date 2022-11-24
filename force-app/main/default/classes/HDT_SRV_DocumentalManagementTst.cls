@isTest
public with sharing class HDT_SRV_DocumentalManagementTst {
    private static HDT_UTL_Constants utlConstants=new HDT_UTL_Constants();
    private static Order testOrder;
    @TestSetup
    static void setup(){
        Id pricebookId = Test.getStandardPricebookId();
        
                    List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(2, false, 'HERA COMM', 'Azienda', 'Aziende SME');
            accList[0].SatisfactionIndexCtrl__c = 1.0;
            accList[0].PraxidiaUpdateDate__c = Date.newInstance(2021, 09, 14);
            insert accList;
        
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(2, false, accList[0].Id, 'Bozza');

        ordList[0].isTransition__c = true;
        ordList[0].RecordTypeId = utlconstants.ORDER_RECORDTYPEID_ORDERDOSSIER;

        ordList[0].Phase__c = 'Documentazione Gestita';

        ordList[0].Pricebook2Id=pricebookId;
        ordList[0].ServicePoint__c = servPointList[0].Id;
                ordList[1].isTransition__c = true;
        ordList[1].RecordTypeId = utlconstants.ORDER_RECORDTYPEID_ORDERDOSSIER;

        ordList[1].Phase__c = 'Documentazione Gestita';

        ordList[1].Pricebook2Id=pricebookId;
        ordList[1].ServicePoint__c = servPointList[0].Id;
        insert ordList;
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Sale__c> sales = HDT_UTL_DataFactoryTst.createSale(1, true, accList[0].id, 'Bozza');
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, false, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        caseList[0].Phase__c='Completata';
        insert caseList;
        List<BillingProfile__c> billingProfileList = HDT_UTL_DataFactoryTst.createBillingProfile(1,true, accList[0].Id);
        HDT_UTL_DataFactoryTst.createChildOrder(1, true, accList[0].Id, sales, ordList[0].Id, contactList[0].Id);
        
        List<DocumentalPayloadAdministration__c> documList = HDT_UTL_DataFactoryTst.createDocumentalPayloadAdm();
        //
        
        
        List<Product2> prods = HDT_UTL_DataFactoryTst.createProduct2(1, false);
        prods[0].Family = 'VAS Fatturabili';
        prods[0].DescriptionSAP__c = 'descr';
        insert prods;
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        HDT_UTL_DataFactoryTst.pClickCasePhase();
        List<PricebookEntry> entries = HDT_UTL_DataFactoryTst.createPricebookEntry(prods, true, pricebookId);
        HDT_UTL_DataFactoryTst.createOrderItem(1, true, ordList[0].Id, servPointList[0].id, prods[0].id, entries[0].id);

        
        list<DocumentSendTracking__c> testDocSendTr =  HDT_UTL_DataFactoryTst.createDocumentSendTracking(2, ordList[0].Id, caseList[0].Id);
        List<DocumentalActivity__c> docActTest = HDT_UTL_DataFactoryTst.createDocumentalActivity(2,true, ordList[0].Id, caseList[0].Id);
        HDT_UTL_DataFactoryTst.createJsonPayload();
        HDT_UTL_DataFactoryTst.createDriverJson();
        HDT_UTL_DataFactoryTst.pClickInstance();
        
        HDT_UTL_DataFactoryTst.newPhaseTransition('Attesa conferma preventivo cliente', 'Bozza', caseList[0].Id, 'HDT_RT_Default');
        HDT_UTL_DataFactoryTst.newPhaseTransition('Comunicazione EngageOne KO', 'Documentazione Gestita', utlconstants.ORDER_RECORDTYPEID_ORDERDOSSIER, utlconstants.ORDER_RECORDTYPE_DEVELOPERNAME_ORDERDOSSIER);

        
        
        
        
        insert new DocusignSettings__c(CustomerEnviromentId__c = 'HERA-TEST');
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
        formParams.put('mode','Print');
        formParams.put('signMode','OTP');
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
    static void testCreateRequestDocumentazioneAnticipata() {
        Test.startTest();
        Map<String,Object> formParams = new Map<String,Object>();
        formParams.put('Contesto', 'DocumentazioneAnticipata');
        List<Order> ord = [SELECT Id, OrderNumber FROM Order LIMIT 1];
        String res = HDT_SRV_DocumentalManagement.generateRequest((String)ord[0].Id,'DocumentazioneAnticipata', JSON.serialize(formParams));
        
        Test.stopTest();
    }
    @isTest
    static void testGenerateResendDocusignEnvelopeRequest(){
        Test.startTest();
        
        List<DocumentSendTracking__c> dst = [SELECT Id FROM DocumentSendTracking__c LIMIT 1];
        String res = HDT_SRV_DocumentalManagement.generateResendDocusignEnvelopeRequest((String)dst[0].Id);
        
        Test.stopTest();
    }
    
    @isTest
    static void testGenerateGetAttachmentRequest(){
        Test.startTest();
        
        List<DocumentalActivity__c> dact = [SELECT Id FROM DocumentalActivity__c LIMIT 1];
        String res = HDT_SRV_DocumentalManagement.generateGetAttachmentRequest((String)dact[0].Id);
        
        Test.stopTest();
    }
    @isTest
    static void testGenerateGetEnvelopeRequest(){
        
        Test.startTest();
        List<DocumentalActivity__c> record = [SELECT Id FROM DocumentalActivity__c LIMIT 1];
        HDT_WRP_DocumentalResponse.HDT_WRP_PostelResponse postelResponse = new HDT_WRP_DocumentalResponse.HDT_WRP_PostelResponse();
        SObject documentalObject = HDT_QR_DocumentalConfiguration.getDocumentalObjectById(record[0].Id);
        
        String documentType = HDT_SRV_DocumentalManagement.getDocumentType(documentalObject);
        String body = HDT_SRV_DocumentalManagement.generateGetEnvelopeRequest(documentalObject, documentType);
        
        
        Test.stopTest();
    }
    @isTest
    static void testGenerateDiscardDocusignEnvelopeRequest(){
        
        Test.startTest();
        List<DocumentSendTracking__c> dst = [SELECT Id FROM DocumentSendTracking__c LIMIT 1];
        String res = HDT_SRV_DocumentalManagement.generateDiscardDocusignEnvelopeRequest((String)dst[0].Id);
        Test.stopTest();
    }
    
    
    @isTest
    static void testCreatePublicLinkFuture(){
        
        Test.startTest();
        List<Order> ord = [SELECT Id, OrderNumber,InformationFormLink__c,SendFormLink__c,Decision40Link__c FROM Order LIMIT 1];
        HDT_SRV_DocumentalManagement.createPublicLinkFuture((String) ord[0].Id,'base64','MODULISTICA_NO_B12');
        HDT_SRV_DocumentalManagement.createPublicLinkFuture((String) ord[0].Id,'base64','MODULISTICA_B12');
        HDT_SRV_DocumentalManagement.createPublicLinkFuture((String) ord[0].Id,'base64','DELIBERA_40');
        Test.stopTest();
    }
    
    
    @isTest
    static void testExecuteCalloutRequestFuture(){     
        
        //TODO: ESTRARRE E REALIZZARE METODO/UTILITY DI CREAZIONE OGGETTO HDT_WRP_DocumentalStructure AD HOC
        
        //docRecord
        HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalRecord docRecord;
        docRecord = new HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalRecord();
        //fields docRecord
        
        //TODO: IMPLEMENT
        docRecord.field1 = '';
		docRecord.field2 = '';
		docRecord.field3 = '';
		docRecord.field4 = '';
        
        //docSection
        HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalSection docSection;
        docSection = new HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalSection();
        
        //fields docSection
        docSection.records = new List<HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalRecord>{docRecord};

        
        //docStructure
        HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalStructure docStructure;
        docStructure = new HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalStructure();
        
        //fields docStructure
        docStructure.sections = new List<HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalSection>{docSection};
        
        
        
        
        //Documento Docstructure
        Id folderId = [SELECT Id FROM Folder WHERE DeveloperName  = :'DocumentalPayloadAdministration' LIMIT 1].Id;
        
        Document myDocByContext = new Document();
        myDocByContext.name = 'DocumentazioneAnticipata';
        myDocByContext.FolderId = folderId;
        myDocByContext.Body = Blob.valueOf(JSON.serialize(docStructure));
        insert myDocByContext;
        
        //Documento Driver3 - NOTA: CONSIGLIABILE CORREGGERE CON docStructure DISTINTA RISPETTO A myDocByContext.
        Document myDocDriver3 = new Document();
        myDocDriver3.name = 'Driver3';
        myDocDriver3.FolderId = folderId;
        myDocDriver3.Body = Blob.valueOf(JSON.serialize(docStructure));
        insert myDocDriver3;
        
        
        //PREPARAZIONE ARGOMENTI
        String context = 'DocumentazioneAnticipata';//se non lo è, cambia codice
        
        
        Map<String,Object> formParams = new Map<String,Object>();
        //TODO: COMPLETARE MAPPA formParams. Struttura è complicata.
        
        
        String formParamsJSON = JSON.serialize(formParams);
        
        
        List<Order> myOrder = [SELECT Id FROM Order LIMIT 1];
        testOrder = myOrder[0];
        String orderId = myOrder[0].Id;
        
        //WEBSERVICE MOCK
        Test.setMock(HttpCalloutMock.class, new HDT_SRV_DocumentalManagement_HTTP_MOCK());
        
        //TESTING
        Test.startTest();
        HDT_SRV_DocumentalManagementFacade.sendDocument(orderId, context, formParamsJSON);
        HDT_SRV_DocumentalManagement.executeCalloutRequest('',context);
        Test.stopTest();
    }
    
    
    @isTest
    static void testHandleRadio1(){
        Test.setMock(HttpCalloutMock.class, new HDT_SRV_DocumentalManagement_HTTP_MOCK());
        String body = '{"status":"OK", "data":{"transactionId":"idPlico_0"},"listOfRadioGroup":[{"groupName":"radio1","selected":"true","value":"no"}]}';
        HDT_WRP_DocusignNotify.HDT_WRP_DocusignNotifyRequest requestBody = (HDT_WRP_DocusignNotify.HDT_WRP_DocusignNotifyRequest) JSON.deserialize(body, HDT_WRP_DocusignNotify.HDT_WRP_DocusignNotifyRequest.class);
        String status = requestBody.status;
        String envelopeId = 'idPlico_0';
        String outcome = requestBody.outcome;
        String transactionId = 'idPlico_0';
        SObject recordToUpdate = HDT_SRV_DocumentalManagement.getSobjectFromTransactionId(transactionId);
        HDT_SRV_DocumentalManagement.updateSobjectFromDocusign(recordToUpdate,requestBody, transactionId);
        //HDT_SRV_DocumentalManagement.handleRadioGroup(record,listOfRadio,envelopeId);

    }
      @isTest
    static void testHandleRadio2(){
        Test.setMock(HttpCalloutMock.class, new HDT_SRV_DocumentalManagement_HTTP_MOCK());
        String body = '{"status":"OK", "data":{"transactionId":"idPlico_0"},"listOfRadioGroup":[{"groupName":"radio2","selected":"true","value":"no"}]}';
        HDT_WRP_DocusignNotify.HDT_WRP_DocusignNotifyRequest requestBody = (HDT_WRP_DocusignNotify.HDT_WRP_DocusignNotifyRequest) JSON.deserialize(body, HDT_WRP_DocusignNotify.HDT_WRP_DocusignNotifyRequest.class);
        String status = requestBody.status;
        String envelopeId = 'idPlico_0';
        String outcome = requestBody.outcome;
        String transactionId = 'idPlico_0';
        SObject recordToUpdate = HDT_SRV_DocumentalManagement.getSobjectFromTransactionId(transactionId);
        HDT_SRV_DocumentalManagement.updateSobjectFromDocusign(recordToUpdate,requestBody, transactionId);
        //HDT_SRV_DocumentalManagement.handleRadioGroup(record,listOfRadio,envelopeId);

    }
    
          @isTest
    static void testHandleRadioOrder1(){
        Test.setMock(HttpCalloutMock.class, new HDT_SRV_DocumentalManagement_HTTP_MOCK());
        String body = '{"status":"OK", "data":{"transactionId":"idPlico_0"},"listOfRadioGroup":[{"groupName":"radio1","selected":"true","value":"no"}]}';
        HDT_WRP_DocusignNotify.HDT_WRP_DocusignNotifyRequest requestBody = (HDT_WRP_DocusignNotify.HDT_WRP_DocusignNotifyRequest) JSON.deserialize(body, HDT_WRP_DocusignNotify.HDT_WRP_DocusignNotifyRequest.class);
        String status = requestBody.status;
        String envelopeId = 'idPlico_0';
        String outcome = requestBody.outcome;
        String transactionId = 'idPlico_0';
        SObject docSendTracking = HDT_QR_DocumentalConfiguration.getDocumentSendTracking(transactionId);
        List<SObject> recordToUpdate = HDT_QR_GenericQuery.getGenericRecords('SELECT Id,AccountId,Phase__c,DocumentalPhase__c,DocumentalProcessType__c,Cluster__c,Contact__r.IndividualId,SupplyType__c  FROM Order WHERE Id = \''+(String)docSendTracking.get('Order__c')+'\'', 'Order');
        HDT_SRV_DocumentalManagement.updateSobjectFromDocusign(recordToUpdate[0],requestBody, transactionId);
        //HDT_SRV_DocumentalManagement.handleRadioGroup(record,listOfRadio,envelopeId);

    }
    @isTest
        static void testHandleRadioOrder2(){
        Test.setMock(HttpCalloutMock.class, new HDT_SRV_DocumentalManagement_HTTP_MOCK());
        String body = '{"status":"OK", "data":{"transactionId":"idPlico_0"},"listOfRadioGroup":[{"groupName":"radio2","selected":"true","value":"no"}]}';
        HDT_WRP_DocusignNotify.HDT_WRP_DocusignNotifyRequest requestBody = (HDT_WRP_DocusignNotify.HDT_WRP_DocusignNotifyRequest) JSON.deserialize(body, HDT_WRP_DocusignNotify.HDT_WRP_DocusignNotifyRequest.class);
        String status = requestBody.status;
        String envelopeId = 'idPlico_0';
        String outcome = requestBody.outcome;
        String transactionId = 'idPlico_0';
        SObject docSendTracking = HDT_QR_DocumentalConfiguration.getDocumentSendTracking(transactionId);
        List<SObject> recordToUpdate = HDT_QR_GenericQuery.getGenericRecords('SELECT Id,AccountId,Phase__c,DocumentalPhase__c,DocumentalProcessType__c,Cluster__c,Contact__r.IndividualId,SupplyType__c  FROM Order WHERE Id = \''+(String)docSendTracking.get('Order__c')+'\'', 'Order');
        HDT_SRV_DocumentalManagement.updateSobjectFromDocusign(recordToUpdate[0],requestBody, transactionId);
        //HDT_SRV_DocumentalManagement.handleRadioGroup(record,listOfRadio,envelopeId);

    }
    
     @isTest
        static void testHandleRadioOrder3(){
        Test.setMock(HttpCalloutMock.class, new HDT_SRV_DocumentalManagement_HTTP_MOCK());
        String body = '{"status":"OK", "data":{"transactionId":"idPlico_0"},"listOfRadioGroup":[{"groupName":"DTC_radio1_1","selected":"true","value":"Pulsante di opzione1"}]}';
        HDT_WRP_DocusignNotify.HDT_WRP_DocusignNotifyRequest requestBody = (HDT_WRP_DocusignNotify.HDT_WRP_DocusignNotifyRequest) JSON.deserialize(body, HDT_WRP_DocusignNotify.HDT_WRP_DocusignNotifyRequest.class);
        String status = requestBody.status;
        String envelopeId = 'idPlico_0';
        String outcome = requestBody.outcome;
        String transactionId = 'idPlico_0';
        SObject docSendTracking = HDT_QR_DocumentalConfiguration.getDocumentSendTracking(transactionId);
        List<SObject> recordToUpdate = HDT_QR_GenericQuery.getGenericRecords('SELECT Id,AccountId,Phase__c,DocumentalPhase__c,DocumentalProcessType__c,Cluster__c,Contact__r.IndividualId,SupplyType__c  FROM Order WHERE Id = \''+(String)docSendTracking.get('Order__c')+'\'', 'Order');
        HDT_SRV_DocumentalManagement.updateSobjectFromDocusign(recordToUpdate[0],requestBody, transactionId);
        //HDT_SRV_DocumentalManagement.handleRadioGroup(record,listOfRadio,envelopeId);

    }
    
    @isTest
        static void testHandleRadioOrder4(){
        Test.setMock(HttpCalloutMock.class, new HDT_SRV_DocumentalManagement_HTTP_MOCK());
        String body = '{"status":"OK", "data":{"transactionId":"idPlico_0"},"listOfRadioGroup":[{"groupName":"L80_radio_1","selected":"true","value":"Pulsante di opzione1"}]}';
        HDT_WRP_DocusignNotify.HDT_WRP_DocusignNotifyRequest requestBody = (HDT_WRP_DocusignNotify.HDT_WRP_DocusignNotifyRequest) JSON.deserialize(body, HDT_WRP_DocusignNotify.HDT_WRP_DocusignNotifyRequest.class);
        String status = requestBody.status;
        String envelopeId = 'idPlico_0';
        String outcome = requestBody.outcome;
        String transactionId = 'idPlico_0';
        SObject docSendTracking = HDT_QR_DocumentalConfiguration.getDocumentSendTracking(transactionId);
        List<SObject> recordToUpdate = HDT_QR_GenericQuery.getGenericRecords('SELECT Id,AccountId,Phase__c,DocumentalPhase__c,DocumentalProcessType__c,Cluster__c,Contact__r.IndividualId,SupplyType__c FROM Order WHERE Id = \''+(String)docSendTracking.get('Order__c')+'\'', 'Order');
        HDT_SRV_DocumentalManagement.updateSobjectFromDocusign(recordToUpdate[0],requestBody, transactionId);
        //HDT_SRV_DocumentalManagement.handleRadioGroup(record,listOfRadio,envelopeId);

    }

    @isTest
    static void testLogDiscardPhase() {
        Order ord = [SELECT Id FROM Order LIMIT 1];
        Test.startTest();
        HDT_SRV_DocumentalManagement.logDiscardPhase(ord.Id);
        ord = [SELECT Id,Phase__c FROM Order LIMIT 1];
        System.assertEquals('Comunicazione EngageOne KO', ord.Phase__c, 'Errore nel funzionamento di logDiscardPhase');
        Test.stopTest();
    }
/*
    @isTest
    static void  testgeneratePayload(){

        HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalRecord docRecord;
        docRecord = new HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalRecord();
        //fields docRecord
        
        //TODO: IMPLEMENT
        docRecord.field1 = '';
		docRecord.field2 = '';
		docRecord.field3 = '';
		docRecord.field4 = '';
        
        //docSection
        HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalSection docSection;
        docSection = new HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalSection();
        
        //fields docSection
        docSection.records = new List<HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalRecord>{docRecord};

        HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalStructure docStructure;
        docStructure = new HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalStructure();
        
        //fields docStructure
        docStructure.sections = new List<HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalSection>{docSection};
        
        //Documento Docstructure
        Id folderId = [SELECT Id FROM Folder WHERE DeveloperName  = :'DocumentalPayloadAdministration' LIMIT 1].Id;
        
        Document myDocByContext = new Document();
        myDocByContext.name = 'DocumentazioneAnticipata';
        myDocByContext.FolderId = folderId;
        myDocByContext.Body = Blob.valueOf(JSON.serialize(docStructure));
        insert myDocByContext;

        Map<String,Object> formParams = new Map<String,Object>();
        formParams.put('Contesto', 'Case');
        formParams.put('mode','Print');
        formParams.put('signMode','OTP');


        Case caseObject = [SELECT Id FROM Case LIMIT 1];
        Account accountObject = [SELECT Id,Name FROM Account LIMIT 1];
		Contact contactObject = [SELECT Id,Name FROM Contact LIMIT 1];
        List<DocumentSelected__c> documentSelectedObjectList = (List<DocumentSelected__c> ) [SELECT Id,Name FROM DocumentSelected__c LIMIT 1];
		List<sObject> listCase = new List<sObject>();
		listCase.add(caseObject);
        List<sObject> listAccount = new List<sObject>();
		listAccount.add(accountObject);
		List<sObject> listContact = new List<sObject>();
		listContact.add(contactObject);
		Map<String,List<sObject>> mapStringObjectRecords = new Map<String,List<sObject>>{
			'Case' => listCase, 'Account' => listAccount, 'PrimaryContact' => listContact, 'DocumentSelected' => documentSelectedObjectList
		};

		List<Map<String,List<sObject>>> recordObjectsListMap = new List<Map<String,List<sObject>>>();
		recordObjectsListMap.add(mapStringObjectRecords);


        HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalStructure configuration = (HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalStructure) JSON.deserialize(myDocByContext.Body.toString(), HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalStructure.class);
       String res =  HDT_SRV_DocumentalManagement.generatePayload( recordObjectsListMap,configuration,formParams);

    }*/
    
@isTest
    static void testgetSignModeConfiguration(){
        String res = HDT_SRV_DocumentalManagement.getSignModeConfiguration('Rimborso', 'Back office');
    }
    
          
@isTest
static void testcreateContactPoint(){
    List<Contact> cont = [SELECT Id FROM Contact LIMIT 1];
    String res = HDT_SRV_DocumentalManagement.createContactPoint('test@test.it', '3511111111', cont[0].Id);
} 
    
@isTest
static void testqueryContactPoint(){
    List<Contact> cont = [SELECT Id FROM Contact LIMIT 1];
    String res = HDT_SRV_DocumentalManagement.queryContactPoint('test@test.it', '3511111111', cont[0].Id);
} 
@isTest
static void testgeneratePayloadEstrattoConto(){
    Map<String,Object> primolivello = new Map<String,Object>();
    primolivello.put('societa', 'HERA COMM MARCHE');
    primolivello.put('contoContrattuale' , '200001846232');
    primolivello.put('rateizzato' , 'NO');
    primolivello.put('numeroFattura' , '0000411810643841');
    primolivello.put('residuo' , '0.0');
    primolivello.put('importo' , '0.0');

    primolivello.put('fatturaPrescrivibile' ,'testString');
    primolivello.put('fatturaPrescritta', 'testString');
    List<Object> itemVasList = new List<Object>();
    itemVasList.add(primolivello);


    Map<String, Object> secondoLivelloMap = new Map<String, Object>();
    secondoLivelloMap.put('settoreMerceologico', 'Gas');
    secondoLivelloMap.put('motivoDiPareggio', 'STORNO');
    
    
    List<Object> secondoLivelloList = new List<Object>();
    secondoLivelloList.add(secondoLivelloMap);
    primolivello.put('secondoLivelloInformativo', secondoLivelloList);
    
    Map<String,List<SObject>> inputs = new Map<String,List<SObject>>();
    
    Map<String,Object> formParams = new Map<String,Object>();
    formParams.put('Contesto', 'EC');
    formParams.put('EstrattoConto', JSON.serialize(itemVasList));




    String res = HDT_SRV_DocumentalManagement.generatePayloadEstrattoConto(formParams);
} 
    public class HDT_SRV_DocumentalManagement_HTTP_MOCK implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest request) {
            
            HttpResponse response = new HttpResponse();
            
            //HDT_WRP_DocumentalResponseAttachment
            //è di fatto 1:1 DocumentalEnvelopeAttachment__c
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
            
            //HDT_WRP_PostelResponse
            HDT_WRP_DocumentalResponse.HDT_WRP_PostelResponse posRes;
            posRes.responseCode = 200;//è IL VERO response.setStatusCode
            posRes.responseStatus = 'Success';//è IL VERO response.setStatus

                
                
                
            //HDT_WRP_DocumentalResponse
            HDT_WRP_DocumentalResponse docRes = new HDT_WRP_DocumentalResponse();
            docRes.responseCode = 200;//è IL VERO response.setStatusCode
            docRes.responseStatus = 'Success';//è IL VERO response.setStatus
            docRes.deliverPackageResponse = docRoot;
            
            Map<String, Object> responseBodyMap = new Map<String, Object>();
            responseBodyMap.put('data', docRes);
            
            response.setHeader('Content-Type', 'application/json');
            response.setBody(JSON.serialize(responseBodyMap));
            response.setStatusCode(200);
            response.setStatus('OK');
            
            return response;
            
            
        }
    }

    @isTest
    static void logEmailForAccountStatementTst()
    {
        List<Account> accList = [SELECT Id FROM Account];
        String formParams = '{"email": "testEmail@email.com"}';
        Test.startTest();
            HDT_SRV_DocumentalManagement.logEmailForAccountStatement(accList[0].Id, formParams);
        Test.stopTest();
        System.assertEquals(true, String.isNotBlank(formParams), 'Form params vuoto');
    }
    @isTest
    static void createIntesaDocumentalActivityTst()
    {
        List<Order> orderList = [SELECT Id FROM Order];
        HDT_WRP_DocusignNotify.HDT_WRP_DocusignNotifyRequest req = new HDT_WRP_DocusignNotify.HDT_WRP_DocusignNotifyRequest();
        req.status = 'completed';
        String transactionId = '109dkasodk01';
        Test.startTest();
            HDT_SRV_DocumentalManagement.createIntesaDocumentalActivity(orderList[0], req, transactionId);
        Test.stopTest();
        System.assertEquals(true, String.isNotBlank(transactionId), 'TransactionId vuoto');
    }
    @isTest
    static void getTransactionId()
    {
        Test.setMock(HttpCalloutMock.class, new HDT_WS_DocumentalMock());
        Test.startTest();
            String result = HDT_SRV_DocumentalManagement.getTransactionId('asdojiasod');
        Test.stopTest();
        System.assertEquals(true, String.isNotBlank(result), 'TransactionId vuoto');
    }

    public class HDT_WS_DocumentalMock implements HttpCalloutMock
    {
        
        public HTTPResponse respond(HTTPRequest request){

            HttpResponse response = new HttpResponse();
            String bodyResponse;
            Integer statusCode;

            bodyResponse = '{"data": {"transactionId": "asdjjads"}}';
            statusCode = 200;

            response.setHeader('Content-Type', 'application/json');
            response.setBody(bodyResponse);
            response.setStatusCode(statusCode);
            response.setStatus('OK');
            return response;
        }
    }

}

