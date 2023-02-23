@isTest
public with sharing class HDT_WS_SelfReadingsTst {
    
    //DEBUG
    
    
    //DATA
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    private static Boolean skipError_ACR = true;//USATO PER INDURRE ERRORE MISSING PRIMARY CONTACT ON ACCOUNT
    private static Boolean isGas = true;
    private static Boolean isRegularOrder = true;
	private static HDT_WS_PostSalesTstMock mock=new HDT_WS_PostSalesTstMock();

    
    
    
    //TEST SETUP
    @TestSetup
    static void mySetup(){
        
        //ACCOUNT
        List<Account> acc = HDT_UTL_DataFactoryTst.createAccountBusiness(2, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<BillingProfile__c> bpf = HDT_UTL_DataFactoryTst.createBillingProfile(1, true, acc[0].Id);
        
        //CONTACTS
        Contact contactOne = HDT_UTL_DataFactoryTst.createContact(1, true, acc[0].Id)[0];
        Contact contactTwo = HDT_UTL_DataFactoryTst.createContact(1, true, acc[1].Id)[0];
        
        ServicePoint__c servPoint = HDT_UTL_DataFactoryTst.createServicePoint(1, true)[0];
        
        //ORDER
        List<Order> ordList;
        //if(isRegularOrder){
            ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, acc[0].Id, 'Bozza');
            
        //} else {
            Order myOrder = HDT_UTL_DataFactoryTst.createOrder(1, false, acc[0].Id, 'Bozza')[0];
            myOrder.recordTypeId = constants.ORDER_RECORDTYPEID_SWITCHIN;
            myOrder.Contact__c = contactOne.Id;
            myOrder.ServicePoint__c = servPoint.Id;
            // ordList = new List<Order>{myOrder};
            // insert ordList;
            insert myOrder;
            
        //}
        
        if (skipError_ACR){
            AccountContactRelation acr = HDT_UTL_DataFactoryTst.createAccountContactRelation(true, acc[0].Id, contactTwo.Id);
        }
        
        
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, acc[0].Id);
        
        //CASE
        Case myCase = HDT_UTL_DataFactoryTst.createCaseAutolettura(1, false, acc[0].id, contactOne.Id, servPoint.Id, contractList[0].id, ordList[0].id)[0];
        myCase.Type = 'Paperless';
        insert myCase;
        
        HDT_UTL_DataFactoryTst.pClickCasePhase();
    }
    
    
    
    
    //TESTS
    
    //doPost
    @isTest
    private static void doPostTest() {
        
        //SETUP
        //mySetup();
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
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        HDT_WS_SelfReadings.doPost();
        Test.stopTest();
        
        //ASSERTS
        System.assertEquals(201, RestContext.response.statusCode);
        
    }
    
    
    //KO DEFAULT
    @isTest
    private static void doPostTest_ResponseKO() {
        
        //SETUP
        //mySetup();
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
        srr.outcome = 'KO';//KO INTENZIONALE
        srr.cluster = myCase.Cluster__c;
        srr.type = myCase.Type;
        
        
        //REST CONTEXT
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueof(JSON.serialize(srr));
        
        RestContext.request = req;
        RestContext.response = res;
        
        //CASE PHASE
        String rtName = constants.CASE_RECORDTYPE_DEVELOPERNAME_AUTOLETTURA;
        String rtId = constants.CASE_RECORDTYPEID_AUTOLETTURA;
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Check preliminari KO', 'Bozza', rtId, rtName,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'KO Definitivo', 'Check preliminari KO', rtId, rtName,'A','','','');
        
        
        //TESTING
        //HDT_WS_SelfReadings.doPost();

        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        HDT_WS_SelfReadings.doPost();
        Test.stopTest();
        
        //ASSERTS
        System.assertEquals(201, RestContext.response.statusCode);
        
    }
    
    //COMMODITY ELETTRICITà
    @isTest
    private static void doPostTest_NotGas() {
        
        //SETUP
        //mySetup();
        Case myCase = [SELECT Id, Cluster__c , Type FROM Case];
        Contract myContract = [SELECT Id, SAPContractCode__c FROM Contract];
        
        HDT_WRP_SelfReadings.HDT_WRP_SelfReadingsData reading = new HDT_WRP_SelfReadings.HDT_WRP_SelfReadingsData();
        //reading.id;
        reading.mru = 'TEST_MRU';
        //reading.sendTo = 'TEST_SENDTO';
        
        reading.digits1 = 'T1';
        reading.digits2 = 'T2';
        reading.digits3 = 'T3';
        reading.digits4 = 'T4';
        reading.digits5 = 'T5';
        reading.digits6 = 'T6';
        reading.digits7 = 'T7';
        reading.digits8 = 'T8';
        reading.digits9 = 'T9';
        
        reading.date1 = Date.today();
        reading.date2 = Date.today();
        reading.date3 = Date.today();
        reading.date4 = Date.today();
        reading.date5 = Date.today();
        reading.date6 = Date.today();
        reading.date7 = Date.today();
        reading.date8 = Date.today();
        reading.date9 = Date.today();
        
        reading.band1 = 'B1';
        reading.band2 = 'B2';
        reading.band3 = 'B3';
        reading.band4 = 'B4';
        reading.band5 = 'B5';
        reading.band6 = 'B6';
        reading.band7 = 'B7';
        reading.band8 = 'B8';
        reading.band9 = 'B9';
        
        reading.value1 = 10.1;
        reading.value2 = 10.2;
        reading.value3 = 10.3;
        reading.value4 = 10.4;
        reading.value5 = 10.5;
        reading.value6 = 10.6;
        reading.value7 = 10.7;
        reading.value8 = 10.8;
        reading.value9 = 10.9;
        
        reading.serialNumber1 = 'TEST_SER_NUM_1';
        reading.serialNumber2 = 'TEST_SER_NUM_2';
        reading.serialNumber3 = 'TEST_SER_NUM_3';
        reading.serialNumber4 = 'TEST_SER_NUM_4';
        reading.serialNumber5 = 'TEST_SER_NUM_5';
        reading.serialNumber6 = 'TEST_SER_NUM_6';
        reading.serialNumber7 = 'TEST_SER_NUM_7';
        reading.serialNumber8 = 'TEST_SER_NUM_8';
        reading.serialNumber9 = 'TEST_SER_NUM_9';
        
        reading.register1 = 'TR1';
        reading.register2 = 'TR2';
        reading.register3 = 'TR3';
        reading.register4 = 'TR4';
        reading.register5 = 'TR5';
        reading.register6 = 'TR6';
        reading.register7 = 'TR7';
        reading.register8 = 'TR8';
        reading.register9 = 'TR9';
        
        reading.type1 = 'TEST_type1';
        reading.type2 = 'TEST_type2';
        reading.type3 = 'TEST_type3';
        reading.type4 = 'TEST_type4';
        reading.type5 = 'TEST_type5';
        reading.type6 = 'TEST_type6';
        reading.type7 = 'TEST_type7';
        reading.type8 = 'TEST_type8';
        reading.type9 = 'TEST_type9';
        
        reading.unit1 = 'TU1';
        reading.unit2 = 'TU2';
        reading.unit3 = 'TU3';
        reading.unit4 = 'TU4';
        reading.unit5 = 'TU5';
        reading.unit6 = 'TU6';
        reading.unit7 = 'TU7';
        reading.unit8 = 'TU8';
        reading.unit9 = 'TU9';
        
        
        HDT_WRP_SelfReadings.HDT_WRP_SelfReadingsRequest srr = new HDT_WRP_SelfReadings.HDT_WRP_SelfReadingsRequest();
        srr.readings = reading;
        srr.Id = myCase.Id;
        srr.commodity = 'Energia Elettrica';
        srr.contractCode = myContract.SAPContractCode__c;
        srr.origin = 'Sportello';
        srr.integrationId = '';
        srr.serialNumber = '';
        srr.readingDate = Date.today();
        srr.outcome = 'KO';//KO INTENZIONALE
        srr.cluster = myCase.Cluster__c;
        srr.type = myCase.Type;
        
        
        //REST CONTEXT
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueof(JSON.serialize(srr));
        
        RestContext.request = req;
        RestContext.response = res;
        
        //CASE PHASE
        String rtName = constants.CASE_RECORDTYPE_DEVELOPERNAME_AUTOLETTURA;
        String rtId = constants.CASE_RECORDTYPEID_AUTOLETTURA;
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Check preliminari KO', 'Bozza', rtId, rtName,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'KO Definitivo', 'Check preliminari KO', rtId, rtName,'A','','','');
        
        
        //TESTING
        //HDT_WS_SelfReadings.doPost();

        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        HDT_WS_SelfReadings.doPost();
        Test.stopTest();
        
        //ASSERTS
        System.assertEquals(201, RestContext.response.statusCode);
        
    }
    
    
    
    
    
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
        System.assert('Required child object missing: readings'.equalsIgnoreCase(resp.outcomeDescription));
        
    }
    
    ///ERRORE 500
    @isTest
    private static void doPostTest_Error500() {
        
        //SETUP
        String myErrorString = '{Test';
        
        //REST CONTEXT
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueof(myErrorString);
        
        RestContext.request =req;
        RestContext.response = res;
        
        //TESTING
        HDT_WS_SelfReadings.doPost();
        
        //ASSERTS
        System.assertEquals(500, RestContext.response.statusCode);
        
        String responseWrap = RestContext.response.responseBody.toString();
        HDT_WRP_SelfReadings.HDT_WRP_SelfReadingsResponse resp;
        resp = (HDT_WRP_SelfReadings.HDT_WRP_SelfReadingsResponse) JSON.deserialize(responseWrap, HDT_WRP_SelfReadings.HDT_WRP_SelfReadingsResponse.class);
        
        System.assert('KO'.equalsIgnoreCase(resp.outcome));
        System.assert(resp.outcomeDescription.contains('Error while parsing JSON body: '));
        
    }
    
    
    //HDT_UTL_SelfReadings.isProcessReading
    @isTest
    private static void utl_isProcessReadingTest(){
        
        //SETUP
        isRegularOrder = false;
        //mySetup();
        
        ServicePoint__c servPoint = [SELECT Id FROM ServicePoint__c];
        
        //ORDER (Record Type for Test: Switch In)
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        
        String rtId = constants.ORDER_RECORDTYPEID_SWITCHIN;
        String rtName = constants.ORDER_RECORDTYPE_DEVELOPERNAME_SWITCHIN;
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Da Inviare', 'Bozza', rtId, rtName,'A','','','');
        
        Order myOrder = [SELECT Id, AccountId, ServicePoint__c, RecordTypeId, RecordType.DeveloperName, Phase__c, Status FROM Order WHERE RecordTypeId =: constants.ORDER_RECORDTYPEID_SWITCHIN];
        myOrder.Phase__c = 'Da Inviare';
        system.debug('myOrder.RecordType.DeveloperName --> '+myOrder.RecordType.DeveloperName);
        update myOrder;
        
        System.debug('utl_isProcessReadingTest Order: ' + myOrder);
        
        
        Date myDate = Date.Today();
        Time myTime = Time.newInstance(3, 3, 3, 0);
        DateTime dt = DateTime.newInstance(myDate, myTime);
        
        List<HDT_UTL_SelfReadings.HDT_UTL_SelfReadingsFlowInputs> inputs = new List<HDT_UTL_SelfReadings.HDT_UTL_SelfReadingsFlowInputs>();
        HDT_UTL_SelfReadings.HDT_UTL_SelfReadingsFlowInputs myInput = new HDT_UTL_SelfReadings.HDT_UTL_SelfReadingsFlowInputs();
        myInput.servicePointId = servPoint.Id;
        myInput.accountId = myOrder.AccountId;
        myInput.caseCreatedDateTime = dt;
        myInput.metadataRecordName = 'Autolettura_da_processo';//TODO: ALTERNATIVE TEST
        inputs.add(myInput);
        
        //TESTING
        List<HDT_UTL_SelfReadings.HDT_UTL_SelfReadingsFlowOutputs> resultList = HDT_UTL_SelfReadings.isProcessReading(inputs);
        
        HDT_UTL_SelfReadings.HDT_UTL_SelfReadingsFlowOutputs result = resultList[0];
        
        
        //ASSERTS
        System.assert(result.isProcessReading, 'Asserzione fallita: result.isProcessReading non è true.');
        
    }
    
    //TODO: TEST CON METADATO NON TROVATO (metadataRecordName empty)
    
    
    
}