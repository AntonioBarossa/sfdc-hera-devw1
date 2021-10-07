@isTest
public with sharing class HDT_TRH_SelfReadingEventTst {
    
    //DEBUG
    
    
    //DATA
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    private static Boolean largeSetup = false;
    
    
    //TEST SETUP
    private static void mySetup(){
        List<Account> acc = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<BillingProfile__c> bpf = HDT_UTL_DataFactoryTst.createBillingProfile(1, true, acc[0].Id);
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, acc[0].Id, 'Bozza');
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, acc[0].Id);
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, acc[0].id);
        
        if(largeSetup){
            List<Case> caseList = HDT_UTL_DataFactoryTst.createCaseAutolettura(55, true, acc[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        } else {
            List<Case> caseList = HDT_UTL_DataFactoryTst.createCaseAutolettura(1, true, acc[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        }
        HDT_UTL_DataFactoryTst.pClickCasePhase();
    }
    
    
    //TESTS
    
    //COVERAGE INCREASE TEST
    @isTest
    private static void coverageIncreaseTest_SingleCase() {
        
        //SETUP
        mySetup();
        
        Case myCaseForHeroku = [SELECT Id FROM Case];
        myCaseForHeroku.Phase__c = 'Esito OK da SAP';
        
        //PHASE ENABLE
        String rtName = constants.CASE_RECORDTYPE_DEVELOPERNAME_AUTOLETTURA;
        String rtId = constants.CASE_RECORDTYPEID_AUTOLETTURA;
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Esito OK da SAP', 'Bozza', rtId, rtName,'A','','','');
        
        //PREPARING EVENT
        HDT_PEV_SelfReading__e event = new HDT_PEV_SelfReading__e();
        event.SerializedCase__c = JSON.serialize(myCaseForHeroku);
        
        //TESTING
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(event);
        Test.stopTest();
        
        //RETRIEVING DATA
        Case myUpdatedCase = [SELECT Id, Phase__c FROM Case];
        
        //ASSERTS
        System.assert('Esito OK da SAP'.equalsIgnoreCase(myUpdatedCase.Phase__c), 'Phase non aggiornata da Job.');
        
    }
    
    
    @isTest
    private static void coverageIncreaseTest_TooManyCases() {
        
        //SETUP
        largeSetup = true;
        mySetup();
        
        List<Case> myCasesForHeroku = [SELECT Id FROM Case];
        for (Case myCase : myCasesForHeroku){
            myCase.Phase__c = 'Esito OK da SAP';
        }
        
        //PHASE ENABLE
        String rtName = constants.CASE_RECORDTYPE_DEVELOPERNAME_AUTOLETTURA;
        String rtId = constants.CASE_RECORDTYPEID_AUTOLETTURA;
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Esito OK da SAP', 'Bozza', rtId, rtName,'A','','','');
        
        //PREPARING EVENT
        HDT_PEV_SelfReading__e event = new HDT_PEV_SelfReading__e();
        event.SerializedCases__c = JSON.serialize(myCasesForHeroku);
        
        //TESTING
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(event);
        Test.stopTest();
        
        //RETRIEVING DATA
        List<Case> myUpdatedCases = [SELECT Id, Phase__c FROM Case WHERE Phase__c = :'Esito OK da SAP'];
        
        //ASSERTS
        System.assertEquals(49, myUpdatedCases.size(), 'Errore nello scheduling dei case da aggiornare e degli eccessi.');
        
        
    }
    
    
}
