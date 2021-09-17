@isTest
public with sharing class HDT_SRV_DocumentalManagementFacadeTst {
    
    //DEBUG
    public static final String TEST_NAME = 'HDT_SRV_DocumentalManagementFacadeTst';
    
    //DATA
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    
    
    
    //TEST SETUP
    //TODO: SETUP DEVE CONTENERE FINO A ORDINE PERCHé USATO DA CUSTOM METADATA Documentale_Context5
    private static void mySetup(){
        
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        
        //NOTA: CUSTOM METADATA RIPORTA ANCHE RELATION RELATIVE AI TIPI:
        
        //OrderItems
        //Account
        //Contact__r
        //SaleBy__r
        //ParentOrder__r
        
    }
    
    
    
    //TESTS
    
    //sendDocument
    @isTest
    public static void sendDocumentTest(){
        
        //DEBUG
        
        
        //SETUP
        mySetup();
        
        
        //TODO: SCORPORARE IN UTILITY DI CREAZIONE OGGETTO AD HOC
        
        //docRecord
        HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalRecord docRecord;
        docRecord = new HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalRecord();
        //fields docRecord
        
        
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
        
        //Documento Driver3
        Document myDocDriver3 = new Document();
        myDocDriver3.name = 'Driver3';
        myDocDriver3.FolderId = folderId;
        myDocDriver3.Body = Blob.valueOf(JSON.serialize(docStructure));//TODO: POSSIBILE SI DEBBA SCORPORARE IN UN SECONDO ITEM
        insert myDocDriver3;
        
        
        //PREPARAZIONE ARGOMENTI
        String context = 'DocumentazioneAnticipata';//se non lo è, cambia codice
        
        Map<String,Object> formParams = new Map<String,Object>();
        String formParamsJSON = JSON.serialize(formParams);
        
        
        Order myOrder = [SELECT Id FROM Order];
        String orderId = myOrder.Id;
        
        //TODO: IMPLEMENT MOCK
        
        //TESTING
        Test.startTest();
        HDT_SRV_DocumentalManagementFacade.sendDocument(orderId, context, formParamsJSON);
        Test.stopTest();
        
        //RETRIEVING DATA
        
        
        
        //ASSERTS
        
        
        
        
    }
    
    
    //sendDocumentAsync
    
    
    
    //sendAdvanceDocumentation
    /*
    @isTest
    private static void sendAdvanceDocumentation() {
        //MOCK TEST
        
    }
    */
    
    
    //getSignSendMode
    
    
    
    //getInfoAccountStatement
    
    
    
    //showOriginalDocument
    
    
    
    //showArchivedAttachment
    
    
    
    //resendDocusignEnvelope
    
    
    
    //discardDocusignEnvelope
    
    
    
    //handleDocusignNotify
    
    
    
    //HTTP MOCKS
    public class HDT_SRV_DocumentalManagementFacade_HTTP_MOCK implements HttpCalloutMock {
        
        global HTTPResponse respond(HTTPRequest request) {
            
            //TODO: IMPLEMENT
            return new HttpResponse();
            /*
            HttpResponse response = new HttpResponse();
            String body = request.getBody();
            HDT_WRP_DocumentalRequest requestWrp = (HDT_WRP_DocumentalRequest) JSON.deserialize(body, HDT_WRP_DocumentalRequest.class);
            String requestId = requestWrp.deliverPackageRequest.requestId;
            String responseStr = '{"status": "success","correlationId": "92293250-df3b-11eb-a73c-0200a41fc6da","timestamp": "2021-07-07T17:54:13","data": {"deliverPackageResponse":{"serviceList":[{"attachmentList":[{"signature":"0","mandatory":"0","version":"21_09","type":"ATT","code":"MOD_H40"},{"signature":"0","mandatory":"0","version":"21_09","type":"ATT","code":"MOD_I40"},{"signature":"0","mandatory":"0","version":"21_09","type":"ATT","code":"MOD_ALL_TEC"}],"serviceId":"'+requestId+'"}],"message":"Composizione eseguita con successo. Totale pagine: 8","result":"000","archive":null,"packageIds":"Aa71teQHAl","requestId":"'+requestId+'","composedDocument":"JVBERi0xLjcKJeLjz9MKNSAwIG9iago"}}}';
            response.setHeader('Content-Type', 'application/json');
            response.setBody(responseStr);
            response.setStatusCode(200);
            response.setStatus('OK');
            return response;
            */
            
        }
    }
    
}
