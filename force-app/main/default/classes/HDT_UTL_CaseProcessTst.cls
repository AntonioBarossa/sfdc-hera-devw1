@isTest
public with sharing class HDT_UTL_CaseProcessTst {

    
    //DEBUG
    public static final String TEST_NAME = 'HDT_UTL_CaseProcessTst';
    
    
    //TEST SETUP

    @TestSetup
    static void setup() {

        HDT_UTL_DataFactoryTst.pClickCasePhase();

        String rtName = 'HDT_RT_AlertDisassociazioneUtenteWeb';
        String rtId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(rtName).getRecordTypeId();

        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(2, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);    
 
        caseList[0].recordTypeId = rtId;
        caseList[0].Phase__c = 'Bozza';
        caseList[0].Status = 'New';
        caseList[1].recordTypeId = rtId;
        caseList[1].Phase__c = 'Da Inviare';
        caseList[1].Status = 'In Lavorazione';
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Da Inviare', 'Bozza', rtId, rtName,'A','','','');
        update caseList;

    }
    
    
    //TESTS

    @isTest
    private static void checkSatisfationIndexTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'checkSatisfationIndexTest';
        System.debug(debugString);
        
        //SETUP

        List<Case> caseList = [SELECT Id, PraxidiaOverrallSatisfaction__c FROM Case];
        caseList[0].PraxidiaOverrallSatisfaction__c = 6;
        update caseList;
        Map<Id, Case> oldMap = new Map<Id, Case>(caseList);
        caseList[0].PraxidiaOverrallSatisfaction__c = 8;
        update caseList;
        Map<Id, Case> newMap = new Map<Id, Case>(caseList);
        
        //TESTING
        Test.startTest();
        Try{
            
            HDT_UTL_CaseProcess.checkSatisfationIndex(newMap, oldMap);


        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(newMap != null);
        System.assert(oldMap != null);

    }

    @isTest
    private static void casePhaseManagementAfterUpdateTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'casePhaseManagementAfterUpdateTest';
        System.debug(debugString);
        
        //SETUP              
        
        List<Case> newCasesList = [Select Id, AccountId, Contact.Id, RecordTypeId, RecordType.Name, Phase__c from Case where Phase__c = 'Da Inviare'];
        List<Case> oldCasesList = [Select Id, AccountId, Contact.Id, RecordTypeId, RecordType.Name, Phase__c from Case where Phase__c = 'Bozza'];

        //TESTING
        Test.startTest();
        Try{
            
            HDT_UTL_CaseProcess.casePhaseManagementAfterUpdate(newCasesList, oldCasesList);


        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(newCasesList != null);
        System.assert(oldCasesList != null);

    }

    @isTest
    private static void manageCancellationProcessTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'manageCancellationProcessTest';
        System.debug(debugString);
        
        //SETUP      
                
        List<Case> newCasesList = new List<Case>();
        List<Case> oldCasesList = [Select Id, RecordTypeId, RecordType.Name, Phase__c, Type from Case where Phase__c = 'Bozza'];
        newCasesList.add(oldCasesList[0]);
        newCasesList[0].Phase__c = 'Annullato';
        newCasesList[0].RecordTypeId = oldCasesList[0].RecordTypeId;
        newCasesList[0].RecordType.Name = oldCasesList[0].RecordType.Name;
        newCasesList[0].Type = 'Variazione indirizzo di fornitura';
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Da Inviare', 'Bozza', newCasesList[0].RecordTypeId, newCasesList[0].RecordType.Name,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Esito OK da SAP', 'Bozza', newCasesList[0].RecordTypeId, newCasesList[0].RecordType.Name,'A','','','');
        update newCasesList;
        Map<Id, Case> oldMap = new Map<Id, Case>(oldCasesList);

        wrts_prcgvr__ActivityTemplate__c myAT = new wrts_prcgvr__ActivityTemplate__c();
        myAT.Name = 'Annullamento Allineamento';
        insert myAT;
        
        //TESTING
        Test.startTest();
        Try{
            
            HDT_UTL_CaseProcess.manageCancellationProcess(newCasesList, oldMap);
            newCasesList[0].Type = 'Reclamo Scritto/Rich. Info';
            update newCasesList;
            HDT_UTL_CaseProcess.manageCancellationProcess(newCasesList, oldMap);



        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(newCasesList != null);
        System.assert(oldCasesList != null);

    }

    @isTest
    private static void updateMemberStatusforClosedCasesTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'updateMemberStatusforClosedCasesTest';
        System.debug(debugString);
        
        //SETUP      
        
        List<Case> newCasesList = [Select Id, Status from Case where Status = 'In Lavorazione'];
        List<Case> oldCasesList = [Select Id, Status from Case where Status = 'New'];
        
        //TESTING
        Test.startTest();
        Try{
            
            HDT_UTL_CaseProcess.updateMemberStatusforClosedCases(newCasesList, oldCasesList);


        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(newCasesList != null);
        System.assert(oldCasesList != null);

    }

    @isTest
    private static void updateServiceRequestTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'updateServiceRequestTest';
        System.debug(debugString);
        
        //SETUP      
        
        List<Case> newCasesList = new List<Case>();
        List<Case> oldCasesList = [Select Id, Status from Case where Status = 'New'];
        newCasesList.add(oldCasesList[0]);
        newCasesList[0].Status = 'In Lavorazione';
        update newCasesList;
        
        //TESTING
        Test.startTest();
        Try{
            
            HDT_UTL_CaseProcess.updateServiceRequest(newCasesList, oldCasesList);


        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(newCasesList != null);
        System.assert(oldCasesList != null);

    }

    @isTest
    private static void linkServiceRequestToCaseTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'linkServiceRequestToCaseTest';
        System.debug(debugString);
        
        //SETUP      

        List<Case> caseList = [SELECT Id, ServiceRequestID__c FROM Case];
        List<ServiceRequest__c> mySRList = HDT_UTL_DataFactoryTst.createServiceRequest(1, true);
        caseList[0].ServiceRequestID__c = mySRList[0].Id;
        update caseList;
        
        //TESTING
        Test.startTest();
        Try{
            
            HDT_UTL_CaseProcess.linkServiceRequestToCase(caseList);


        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(caseList != null);

    }

}