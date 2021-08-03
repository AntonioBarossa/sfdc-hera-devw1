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
        HDT_UTL_DataFactoryTst.createJsonPayload();
        HDT_UTL_DataFactoryTst.createDriverJson();
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
        System.assertEquals('000', (String)resultMap.get('result'));
        Test.stopTest();
    }
}
