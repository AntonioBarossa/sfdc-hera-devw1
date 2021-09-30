@isTest
public with sharing class HDT_WS_SelfReadingsTst {
    
    //DEBUG
    
    
    //DATA
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    private static Boolean skipError_ACR = true;//USATO PER INDURRE ERRORE MISSING PRIMARY CONTACT ON ACCOUNT
    
    //TODO: UNCOMMENT IN CLASSI TESTATE DEI DEBUG COME PREVISTO DA MERGE COMMIT
    
    
    //TEST SETUP
    private static void mySetup(){
        
        //ACCOUNT
        List<Account> acc = HDT_UTL_DataFactoryTst.createAccountBusiness(2, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        
        List<BillingProfile__c> bpf = HDT_UTL_DataFactoryTst.createBillingProfile(1, true, acc[0].Id);
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, acc[0].Id, 'Bozza');
        
        //CONTACTS
        Contact contactOne = HDT_UTL_DataFactoryTst.createContact(1, true, acc[0].Id)[0];
        Contact contactTwo = HDT_UTL_DataFactoryTst.createContact(1, true, acc[1].Id)[0];
        
        if (skipError_ACR){
            AccountContactRelation acr = HDT_UTL_DataFactoryTst.createAccountContactRelation(true, acc[0].Id, contactTwo.Id);
        }
        
        ServicePoint__c servPoint = HDT_UTL_DataFactoryTst.createServicePoint(1, true)[0];
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, acc[0].Id);
        
        //CASE
        Case myCase = HDT_UTL_DataFactoryTst.createCaseAutolettura(1, false, acc[0].id, contactOne.Id, servPoint.Id, contractList[0].id, ordList[0].id)[0];
        myCase.Type = 'Paperless';
        insert myCase;
        
        HDT_UTL_DataFactoryTst.pClickCasePhase();
    }
    
    
    //TESTS
    
    //
    @isTest
    private static void doPostTest() {
        
        //SETUP
        mySetup();
        Case myCase = [SELECT Id, Cluster__c , Type FROM Case];
        Contract myContract = [SELECT Id, SAPContractCode__c FROM Contract];
        
        HDT_WRP_SelfReadings.HDT_WRP_SelfReadingsData reading = new HDT_WRP_SelfReadings.HDT_WRP_SelfReadingsData();
        //reading.id;
        reading.mru = 'TEST_MRU';
        reading.sendTo = 'TEST_SENDTO';
        
        reading.digits1 = 'T1';
        reading.digits2 = 'T2';
        
        reading.date1 = Date.today();
        reading.date2 = Date.today();
        
        reading.band1 = 'B1';
        reading.band2 = 'B2';
        
        reading.value1 = 10.1;
        reading.value2 = 10.2;
        
        reading.serialNumber1 = 'TEST_SER_NUM_1';
        reading.serialNumber2 = 'TEST_SER_NUM_2';
        
        reading.register1 = 'TR1';
        reading.register2 = 'TR2';
        
        reading.type1 = 'TEST_type1';
        reading.type2 = 'TEST_type2';
        
        reading.unit1 = 'TU1';
        reading.unit2 = 'TU2';
        
        
        HDT_WRP_SelfReadings.HDT_WRP_SelfReadingsRequest srr = new HDT_WRP_SelfReadings.HDT_WRP_SelfReadingsRequest();
        srr.readings = reading;
        srr.Id = myCase.Id;
        srr.commodity = 'Gas';
        srr.contractCode = myContract.SAPContractCode__c;
        srr.origin = 'Sportello';
        srr.integrationId = '';
        srr.serialNumber = '';
        srr.readingDate = Date.today();
        srr.outcome = 'OK';
        srr.cluster = myCase.Cluster__c;
        srr.type = myCase.Type;
        
        
        //REST CONTEXT
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueof(JSON.serialize(srr));
        
        RestContext.request =req;
        RestContext.response = res;
        
        //CASE PHASE
        String rtName = constants.CASE_RECORDTYPE_DEVELOPERNAME_AUTOLETTURA;
        String rtId = constants.CASE_RECORDTYPEID_AUTOLETTURA;
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Check preliminari OK', 'Bozza', rtId, rtName,'A','','','');
        
        
        //TESTING
        HDT_WS_SelfReadings.doPost();
        
        //ASSERTS
        System.assertEquals(201, RestContext.response.statusCode);
        
    }
    
    
    //TODO: CASO DI TEST COMMODITY ENERGIA ELETTRICA
    
    
    ///THROW 1
    @isTest
    private static void doPostTest_Exception1() {
        
        //SETUP
        HDT_WRP_SelfReadings.HDT_WRP_SelfReadingsData reading = new HDT_WRP_SelfReadings.HDT_WRP_SelfReadingsData();
        
        HDT_WRP_SelfReadings.HDT_WRP_SelfReadingsRequest srr = new HDT_WRP_SelfReadings.HDT_WRP_SelfReadingsRequest();
        srr.commodity = '';
        
        //REST CONTEXT
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueof(JSON.serialize(srr));
        
        RestContext.request =req;
        RestContext.response = res;
        
        //TESTING
        HDT_WS_SelfReadings.doPost();
        
        //ASSERTS
        System.assertEquals(400, RestContext.response.statusCode);
        
        String responseWrap = RestContext.response.responseBody.toString();
        HDT_WRP_SelfReadings.HDT_WRP_SelfReadingsResponse resp;
        resp = (HDT_WRP_SelfReadings.HDT_WRP_SelfReadingsResponse) JSON.deserialize(responseWrap, HDT_WRP_SelfReadings.HDT_WRP_SelfReadingsResponse.class);
        
        System.assert('KO'.equalsIgnoreCase(resp.outcome));
        System.assert('Required field missing: commodity'.equalsIgnoreCase(resp.outcomeDescription));
        
    }
    
    
    ///THROW 2
    @isTest
    private static void doPostTest_Exception2() {
        
        //SETUP
        HDT_WRP_SelfReadings.HDT_WRP_SelfReadingsData reading = new HDT_WRP_SelfReadings.HDT_WRP_SelfReadingsData();
        
        HDT_WRP_SelfReadings.HDT_WRP_SelfReadingsRequest srr = new HDT_WRP_SelfReadings.HDT_WRP_SelfReadingsRequest();
        srr.commodity = 'Gas';
        srr.contractCode = '';
        
        //REST CONTEXT
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueof(JSON.serialize(srr));
        
        RestContext.request =req;
        RestContext.response = res;
        
        //TESTING
        HDT_WS_SelfReadings.doPost();
        
        //ASSERTS
        System.assertEquals(400, RestContext.response.statusCode);
        
        String responseWrap = RestContext.response.responseBody.toString();
        HDT_WRP_SelfReadings.HDT_WRP_SelfReadingsResponse resp;
        resp = (HDT_WRP_SelfReadings.HDT_WRP_SelfReadingsResponse) JSON.deserialize(responseWrap, HDT_WRP_SelfReadings.HDT_WRP_SelfReadingsResponse.class);
        
        System.assert('KO'.equalsIgnoreCase(resp.outcome));
        System.assert('Required field missing: contractCode'.equalsIgnoreCase(resp.outcomeDescription));
        
    }
    
    
    ///THROW 3
    @isTest
    private static void doPostTest_Exception3() {
        
        //SETUP
        HDT_WRP_SelfReadings.HDT_WRP_SelfReadingsData reading = new HDT_WRP_SelfReadings.HDT_WRP_SelfReadingsData();
        
        HDT_WRP_SelfReadings.HDT_WRP_SelfReadingsRequest srr = new HDT_WRP_SelfReadings.HDT_WRP_SelfReadingsRequest();
        srr.commodity = 'Gas';
        srr.contractCode = 'ContactCodeFake';
        srr.readings = null;
        
        //REST CONTEXT
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueof(JSON.serialize(srr));
        
        RestContext.request =req;
        RestContext.response = res;
        
        //TESTING
        HDT_WS_SelfReadings.doPost();
        
        //ASSERTS
        System.assertEquals(400, RestContext.response.statusCode);
        
        String responseWrap = RestContext.response.responseBody.toString();
        HDT_WRP_SelfReadings.HDT_WRP_SelfReadingsResponse resp;
        resp = (HDT_WRP_SelfReadings.HDT_WRP_SelfReadingsResponse) JSON.deserialize(responseWrap, HDT_WRP_SelfReadings.HDT_WRP_SelfReadingsResponse.class);
        
        System.assert('KO'.equalsIgnoreCase(resp.outcome));
        System.assert('Required field missing: readings'.equalsIgnoreCase(resp.outcomeDescription));
        
    }
    
    
    //TODO: POSSIBILE CHE VADA TESTATA A MANO PARTE DI HDT_UTL_SelfReadings
    ///TODO: CASI CON REQUEST OUTCOME NON 'OK' DI DEFAULT per upsertInboundSelfReading
    
    
}
