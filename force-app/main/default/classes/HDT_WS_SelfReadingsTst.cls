@isTest
public with sharing class HDT_WS_SelfReadingsTst {
    
    //DEBUG
    
    
    //DATA
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    private static Boolean skipError_ACR = true;//USATO PER INDURRE ERRORE MISSING PRIMARY CONTACT ON ACCOUNT
    
    
    //TEST SETUP
    private static void mySetup(){
        
        List<Account> acc = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<BillingProfile__c> bpf = HDT_UTL_DataFactoryTst.createBillingProfile(1, true, acc[0].Id);
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, acc[0].Id, 'Bozza');
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, null);
        
        if (skipError_ACR){
            AccountContactRelation acr = HDT_UTL_DataFactoryTst.createAccountContactRelation(true, acc[0].Id, contactList[0].Id);
        }
        
        ServicePoint__c servPoint = HDT_UTL_DataFactoryTst.createServicePoint(1, true)[0];
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, acc[0].Id);
        
        //CASE
        Case myCase = HDT_UTL_DataFactoryTst.createCaseAutolettura(1, false, acc[0].id, contactList[0].Id, servPoint.Id, contractList[0].id, ordList[0].id)[0];
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
        
        reading.digits1 = 'TEST_digits1';
        reading.digits2 = 'TEST_digits2';
        
        reading.date1 = Date.today();
        reading.date2 = Date.today();
        
        reading.band1 = 'TEST_band1';
        reading.band2 = 'TEST_band2';
        
        reading.value1 = 10.1;
        reading.value2 = 10.2;
        
        reading.serialNumber1 = 'TEST_serialNumber1';
        reading.serialNumber2 = 'TEST_serialNumber2';
        
        reading.register1 = 'TEST_register1';
        reading.register2 = 'TEST_register2';
        
        reading.type1 = 'TEST_type1';
        reading.type2 = 'TEST_type2';
        
        reading.unit1 = 'TEST_unit1';
        reading.unit2 = 'TEST_unit2';
        
        
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
    
    
    
    ///THROW 2
    
    
    
    ///THROW 3
    
    
    //TODO: POSSIBILE CHE VADA TESTATA A MANO PARTE DI HDT_UTL_SelfReadings
    ///TODO: CASI CON REQUEST OUTCOME NON 'OK' DI DEFAULT per upsertInboundSelfReading
    
    
}
