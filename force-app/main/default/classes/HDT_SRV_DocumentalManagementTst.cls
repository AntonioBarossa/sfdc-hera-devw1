@isTest
public with sharing class HDT_SRV_DocumentalManagementTst {
    @TestSetup
    static void setup(){
        Id pricebookId = Test.getStandardPricebookId();

        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');

        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, false, accList[0].id, 'Bozza');
        ordList[0].Pricebook2Id=pricebookId;
        ordList[0].ServicePoint__c = servPointList[0].Id;
        insert ordList;
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Sale__c> sales = HDT_UTL_DataFactoryTst.createSale(1, true, accList[0].id, 'Bozza');
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        List<BillingProfile__c> billingProfileList = HDT_UTL_DataFactoryTst.createBillingProfile(1,true, accList[0].Id);
        HDT_UTL_DataFactoryTst.createChildOrder(1, true, accList[0].Id, sales, ordList[0].Id, contactList[0].Id);
        
        List<DocumentalPayloadAdministration__c> documList = HDT_UTL_DataFactoryTst.createDocumentalPayloadAdm();
        


        
        
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
}
