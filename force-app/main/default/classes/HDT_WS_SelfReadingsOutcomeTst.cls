@isTest
public with sharing class HDT_WS_SelfReadingsOutcomeTst {
    
    //DEBUG
    
    
    //DATA
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    
    
    //NOTA: non è stato possibile testare scarti automatici a causa di mancanza di record custom metadata appositi.
    
    
    //TEST SETUP
    private static void mySetup(){
        List<Account> acc = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, acc[0].Id, 'Bozza');
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, acc[0].Id);
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, acc[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCaseAutolettura(1, false, acc[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        for (Case c : caseList){
            c.Cluster__c = 'Autolettura';
            c.Type= 'Autolettura da cliente';
        }
        insert caseList;
        HDT_UTL_DataFactoryTst.pClickCasePhase();
    }
    
    
    //TESTS
    //doPost
    @isTest
    private static void doPostTest() {
        
        //SETUP
        mySetup();
        
        //CASE & PHASE
        Case myCase = [SELECT Id FROM Case];
        
        String rtName = constants.CASE_RECORDTYPE_DEVELOPERNAME_AUTOLETTURA;
        String rtId = constants.CASE_RECORDTYPEID_AUTOLETTURA;
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Esito OK da SAP', 'Bozza', rtId, rtName,'A','','','');
        
        
        //MANAGING BODY RESPONSE
        HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeRequest myOutcomeRequest;
        myOutcomeRequest = new HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeRequest();
        
        List<HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeData> data = new List<HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeData>();
        for (Integer i = 0; i < 3; i++){
            HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeData singleData;
            singleData = new HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeData();
            singleData.caseId = myCase.Id;
            singleData.activityType = 'Esito OK da SAP';
            singleData.errorCode = '';
            singleData.errorDescription = '';
            data.add(singleData);
        }
        
        myOutcomeRequest.data = data;
        
        
        //REST CONTEXT
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestBody = Blob.valueOf(JSON.serialize(myOutcomeRequest));
        
        RestContext.request = req;
        RestContext.response = res;
        
        //TESTING
        Test.startTest();
        HDT_WS_SelfReadingsOutcome.doPost();
        Test.stopTest();
        
        //RETRIEVING DATA
        Case myCaseUpdated = [SELECT Id, Phase__c FROM Case];
        
        //ASSERTS
        HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeResponse responseWrap;
        responseWrap = new HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeResponse();
        
        System.assertEquals(201, RestContext.response.statusCode, 'Status code errato.');
        System.assertEquals('Esito OK da SAP', myCaseUpdated.Phase__c, 'Fase del Case Errata.');
        System.assertEquals(2, [SELECT id FROM SelfReadingOutcomeRequest__c WHERE Status__c = 'ERROR' AND StatusDescription__c = 'In presenza di più esiti è stato lavorato l\'ultimo inviato.'].size(), 'Gestione degli errori non funzionante');
        
    }
    
    //TESTS Case con Phase = Annullato
    @isTest
    private static void doPostTest_ANNULLATO() {
        
        //SETUP
        mySetup();
        
        //CASE & PHASE
        Case myCase = [SELECT Id FROM Case];

        myCase.Phase__c = 'Annullato';
        update myCase;
        
        String rtName = constants.CASE_RECORDTYPE_DEVELOPERNAME_AUTOLETTURA;
        String rtId = constants.CASE_RECORDTYPEID_AUTOLETTURA;
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Esito OK da SAP', 'Bozza', rtId, rtName,'A','','','');
        
        
        //MANAGING BODY RESPONSE
        HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeRequest myOutcomeRequest;
        myOutcomeRequest = new HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeRequest();
        
        List<HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeData> data = new List<HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeData>();
        for (Integer i = 0; i < 3; i++){
            HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeData singleData;
            singleData = new HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeData();
            singleData.caseId = myCase.Id;
            singleData.activityType = 'Esito OK da SAP';
            singleData.errorCode = '';
            singleData.errorDescription = '';
            data.add(singleData);
        }
        
        myOutcomeRequest.data = data;
        
        
        //REST CONTEXT
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestBody = Blob.valueOf(JSON.serialize(myOutcomeRequest));
        
        RestContext.request = req;
        RestContext.response = res;
        
        //TESTING
        Test.startTest();
        HDT_WS_SelfReadingsOutcome.doPost();
        Test.stopTest();
        
        //RETRIEVING DATA
        Case myCaseUpdated = [SELECT Id, Phase__c FROM Case];
        List<wrts_prcgvr__Activity__c> activities = [SELECT Id, Type__c FROM wrts_prcgvr__Activity__c WHERE Case__c = :myCaseUpdated.Id AND Type__c = 'Gestione Manuale SAP'];
        
        //ASSERTS
        HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeResponse responseWrap;
        responseWrap = new HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeResponse();
        
        System.assertEquals(201, RestContext.response.statusCode, 'Status code errato.');
        System.assertEquals('Annullato', myCaseUpdated.Phase__c, 'Fase del Case Errata.');
        System.assert((activities != null && !activities.isEmpty()), 'Attività Gestione Manuale SAP non creata');
        System.assertEquals(2, [SELECT id FROM SelfReadingOutcomeRequest__c WHERE Status__c = 'ERROR' AND StatusDescription__c = 'In presenza di più esiti è stato lavorato l\'ultimo inviato.'].size(), 'Gestione degli errori non funzionante');
    }

    //TODO: TEST DEL METODO doPost CON CASISTICHE CON KO
    @isTest
    private static void doPostTest_ESITO_KO_SAP() {
        
        //SETUP
        mySetup();
        
        //CASE & PHASE
        Case myCase = [SELECT Id FROM Case];
        
        String rtName = constants.CASE_RECORDTYPE_DEVELOPERNAME_AUTOLETTURA;
        String rtId = constants.CASE_RECORDTYPEID_AUTOLETTURA;
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Esito KO da SAP', 'Bozza', rtId, rtName,'A','','','');
        
        
        //MANAGING BODY RESPONSE
        HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeRequest myOutcomeRequest;
        myOutcomeRequest = new HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeRequest();
        
        List<HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeData> data = new List<HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeData>();
        for (Integer i = 0; i < 3; i++){
            HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeData singleData;
            singleData = new HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeData();
            singleData.caseId = myCase.Id;
            singleData.activityType = 'Esito KO da SAP';
            singleData.errorCode = 'ErrorCode Fittizio per Test';
            singleData.errorDescription = '';
            data.add(singleData);
        }
        
        myOutcomeRequest.data = data;
        
        
        //REST CONTEXT
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestBody = Blob.valueOf(JSON.serialize(myOutcomeRequest));
        
        RestContext.request = req;
        RestContext.response = res;
        
        //TESTING
        Test.startTest();
        HDT_WS_SelfReadingsOutcome.doPost();
        Test.stopTest();
        
        //RETRIEVING DATA
        Case myCaseUpdated = [SELECT Id, Phase__c FROM Case];
        
        //ASSERTS
        HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeResponse responseWrap;
        responseWrap = new HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeResponse();
        
        System.assertEquals(201, RestContext.response.statusCode, 'Status code errato.');
        System.assertEquals('Esito KO da SAP', myCaseUpdated.Phase__c, 'Fase del Case Errata.');
        System.assertEquals(2, [SELECT id FROM SelfReadingOutcomeRequest__c WHERE Status__c = 'ERROR' AND StatusDescription__c = 'In presenza di più esiti è stato lavorato l\'ultimo inviato.'].size(), 'Gestione degli errori non funzionante');

    }
    
    
    @isTest
    private static void doPostTest_ESITO_KO_SAP_AutomaticDiscard() {
        insert new DiscardAnnullmentRule__c(
            ActivityType__c = 'Esito KO da SAP',
            ControllingValue__c = 'ErrorCode Fittizio per Test',
            DiscardNoteReliability__c = 'Alta',
            ProcessValue__c = 'Autolettura da cliente',
            IsActive__c = true
        );
        //SETUP
        mySetup();
        
        //CASE & PHASE
        Case myCase = [SELECT Id FROM Case];
        
        String rtName = constants.CASE_RECORDTYPE_DEVELOPERNAME_AUTOLETTURA;
        String rtId = constants.CASE_RECORDTYPEID_AUTOLETTURA;
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Esito KO da SAP', 'Bozza', rtId, rtName,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Annullato', 'Esito KO da SAP', rtId, rtName,'A','','','');
        
        
        //MANAGING BODY RESPONSE
        HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeRequest myOutcomeRequest;
        myOutcomeRequest = new HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeRequest();
        
        List<HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeData> data = new List<HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeData>();
        for (Integer i = 0; i < 3; i++){
            HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeData singleData;
            singleData = new HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeData();
            singleData.caseId = myCase.Id;
            singleData.activityType = 'Esito KO da SAP';
            singleData.errorCode = '';
            singleData.errorDescription = 'ErrorCode Fittizio per Test';
        
            data.add(singleData);
        }
        
        myOutcomeRequest.data = data;
        
        
        //REST CONTEXT
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestBody = Blob.valueOf(JSON.serialize(myOutcomeRequest));
        
        RestContext.request = req;
        RestContext.response = res;
        
        //TESTING
        Test.startTest();
        HDT_WS_SelfReadingsOutcome.doPost();
        Test.stopTest();
        
        //RETRIEVING DATA
        Case myCaseUpdated = [SELECT Id, Phase__c FROM Case];
        
        //ASSERTS
        HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeResponse responseWrap;
        responseWrap = new HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeResponse();
        
        System.assertEquals(201, RestContext.response.statusCode, 'Status code errato.');
        System.assertEquals('Annullato', myCaseUpdated.Phase__c, 'Fase del Case Errata.');
        System.assertEquals(2, [SELECT id FROM SelfReadingOutcomeRequest__c WHERE Status__c = 'ERROR' AND StatusDescription__c = 'In presenza di più esiti è stato lavorato l\'ultimo inviato.'].size(), 'Gestione degli errori non funzionante');

    }
    
    @isTest
    private static void doPostTest_ESITO_KO_PREMDM() {
        
        //SETUP
        mySetup();
        
        //CASE & PHASE
        Case myCase = [SELECT Id FROM Case];
        
        String rtName = constants.CASE_RECORDTYPE_DEVELOPERNAME_AUTOLETTURA;
        String rtId = constants.CASE_RECORDTYPEID_AUTOLETTURA;
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Esito KO pre-MDM', 'Bozza', rtId, rtName,'A','','','');
        
        
        //MANAGING BODY RESPONSE
        HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeRequest myOutcomeRequest;
        myOutcomeRequest = new HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeRequest();
        
        List<HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeData> data = new List<HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeData>();
        for (Integer i = 0; i < 3; i++){
            HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeData singleData;
            singleData = new HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeData();
            singleData.caseId = myCase.Id;
            singleData.activityType = 'KO Pre-MDM';
            singleData.errorCode = '';
            singleData.errorDescription = 'errorDescription Fittizia per Test';
            data.add(singleData);
        }
        
        myOutcomeRequest.data = data;
        
        
        //REST CONTEXT
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestBody = Blob.valueOf(JSON.serialize(myOutcomeRequest));
        
        RestContext.request = req;
        RestContext.response = res;
        
        //TESTING
        Test.startTest();
        HDT_WS_SelfReadingsOutcome.doPost();
        Test.stopTest();
        
        //RETRIEVING DATA
        Case myCaseUpdated = [SELECT Id, Phase__c FROM Case];
        
        //ASSERTS
        HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeResponse responseWrap;
        responseWrap = new HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeResponse();
        
        System.assertEquals(201, RestContext.response.statusCode, 'Status code errato.');
        System.assertEquals('Esito KO pre-MDM', myCaseUpdated.Phase__c, 'Fase del Case Errata.');
        System.assertEquals(2, [SELECT id FROM SelfReadingOutcomeRequest__c WHERE Status__c = 'ERROR' AND StatusDescription__c = 'In presenza di più esiti è stato lavorato l\'ultimo inviato.'].size(), 'Gestione degli errori non funzionante');

    }
    
    
    //CASISTICHE ECCEZIONE
    ///ERROR 400
    @isTest
    private static void doPostTest_Error_400() {
        
        //SETUP
        mySetup();
        
        //CASE & PHASE
        Case myCase = [SELECT Id FROM Case];
        
        //MANAGING BODY RESPONSE
        HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeRequest myOutcomeRequest;
        myOutcomeRequest = new HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeRequest();
        
        myOutcomeRequest.data = null;
        
        
        //REST CONTEXT
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestBody = Blob.valueOf(JSON.serialize(myOutcomeRequest));
        
        RestContext.request = req;
        RestContext.response = res;
        
        //TESTING
        Test.startTest();
        HDT_WS_SelfReadingsOutcome.doPost();
        Test.stopTest();
        
        //RETRIEVING DATA
        Case myCaseUpdated = [SELECT Id, Phase__c FROM Case];
        
        //ASSERTS
        HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeResponse responseWrap;
        responseWrap = new HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeResponse();
        
        System.assertEquals(400, RestContext.response.statusCode, 'Status code errato.');
        
    }
    
    
    
    ///ERROR 500
    @isTest
    private static void doPostTest_Error_500() {
        
        //SETUP
        mySetup();
        
        //CASE & PHASE
        Case myCase = [SELECT Id FROM Case];
        
        //MANAGING BODY RESPONSE
        String myOutcomeRequest = '{Object';
        
        
        //REST CONTEXT
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestBody = Blob.valueOf(myOutcomeRequest);
        
        RestContext.request = req;
        RestContext.response = res;
        
        //TESTING
        Test.startTest();
        HDT_WS_SelfReadingsOutcome.doPost();
        Test.stopTest();
        
        //RETRIEVING DATA
        Case myCaseUpdated = [SELECT Id, Phase__c FROM Case];
        
        //ASSERTS
        HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeResponse responseWrap;
        responseWrap = new HDT_WRP_SelfReadingsOutcome.HDT_WRP_SelfReadingsOutcomeResponse();
        
        System.assertEquals(500, RestContext.response.statusCode, 'Status code errato.');
        
    }
    
    
    
    
}
