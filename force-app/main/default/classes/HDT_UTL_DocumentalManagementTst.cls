@isTest
public with sharing class HDT_UTL_DocumentalManagementTst {
    @TestSetup
    static void setup(){

         List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
         List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
         List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
         List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].id);
         List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
         List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
         List<BillingProfile__c> billingProfileList = HDT_UTL_DataFactoryTst.createBillingProfile(1,true, accList[0].Id);
         
         List<DocumentalPayloadAdministration__c> documList = HDT_UTL_DataFactoryTst.createDocumentalPayloadAdm();
         List<DocumentalActivity__c> docActList = HDT_UTL_DataFactoryTst.createDocumentalActivity(1,null,caseList[0].Id);
         HDT_UTL_DataFactoryTst.createJsonPayload();
         HDT_UTL_DataFactoryTst.createDriverJson();


         HDT_UTL_DataFactoryTst.pClickOrderPhase();

         DocumentSendTracking__c sendTracking = HDT_UTL_DataFactoryTst.createDocumentSendTracking(1,ordList[0].Id,null)[0];

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
        Order ord = [SELECT Id FROM Order LIMIT 1];
        ContentDocumentLink cLink = HDT_UTL_DocumentalManagement.createContentLink(String.valueof(cv1.Id), String.valueof(ca.Id));
        String st1 = HDT_UTL_DocumentalManagement.createContentDistribution(String.valueof(cv1.Id), 'filetest');
        HDT_WRP_DocumentalResponse resp = createResponse();
        HDT_UTL_DocumentalManagement.createDocumentEnvelopeAttachment(resp,'Order');
        System.debug('@@@' + ca.Id);

        
        
        Test.stopTest();
    }
    @isTest
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

}