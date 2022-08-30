/*
    @Author:        Francesco Vitiello
    CreatedDate:    07/10/2021
*/

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
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);    
 
        caseList[0].recordTypeId = rtId;
        caseList[0].Phase__c = 'Bozza';
        caseList[0].Status = 'New';
        caseList[0].Type = 'Variazione indirizzo di fornitura';

        Case child = new Case();
        child.parentId = caseList[0].Id;
        String rtName2 = 'HDT_RT_RichiestaParere';
        String rtId2 = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(rtName2).getRecordTypeId();
        child.recordTypeId = rtId2;
        child.Phase__c = 'Annullato';
        insert child;

        List<wrts_prcgvr__Activity__c> myActivityList = HDT_UTL_DataFactoryTst.createActivityCustom(1, true, accList[0].Id);
        myActivityList[0].wrts_prcgvr__Status__c  = 'Aperta';
        myActivityList[0].Case__c = child.Id;
        update myActivityList;

        List<Campaign> myCampaignList = HDT_UTL_DataFactoryTst.createCampaign(1, true);
        myCampaignList[0].Category__c = 'Campagna Outbound';
        myCampaignList[0].Channel__c = 'Bolletta';
        update myCampaignList;
        List<Lead> myLeadList = HDT_UTL_DataFactoryTst.createLead(1, true);
        List<CampaignMember> myCampaignMemberList = HDT_UTL_DataFactoryTst.createCampaignMember(true, myCampaignList[0].Id, myLeadList, contactList);
        update myCampaignMemberList;

        caseList[0].recordTypeId = rtId;
        caseList[0].Phase__c = 'Bozza';
        caseList[0].Status = 'New';
        caseList[0].Type = 'Variazione indirizzo di fornitura';
        caseList[0].Campaign__c = myCampaignList[0].Id;


        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Da Inviare', 'Bozza', rtId, rtName,'A','','','');
        update caseList;

        Case nonReqContr = new Case();
        nonReqContr.recordTypeId = caseList[0].RecordTypeId;
        nonReqContr.RelatedCase__c = caseList[0].Id;
        nonReqContr.Type = 'Contratto Non Richiesto';
        insert nonReqContr;

        //START MODIFICA marco.arci@webresults.it
        List<Contract> fakeContracts = HDT_UTL_DataFactoryTst.createContract(2, false, accList[0].id);
        fakeContracts[0].BillingCity = 'casaVar';
        fakeContracts[0].BillingStreet = 'via testVar';

        fakeContracts[1].BillingCity = 'casaCes';
        fakeContracts[1].BillingStreet = 'via testCes';
        insert fakeContracts;

        list<Case> listFakeCases = HDT_UTL_DataFactoryTst.createCase(2, false, accList[0].Id, null, null, null, null);
        listFakeCases[0].Type = 'Modifica post accertamento';
        listFakeCases[0].SupplyCity__c = 'casaVar';
        listFakeCases[0].SupplyStreetName__c = 'via testVar';

        listFakeCases[1].Type = 'Cessazione post accertamento';
        listFakeCases[1].SupplyCity__c = 'casaCes';
        listFakeCases[1].SupplyStreetName__c = 'via testCes';
        insert listFakeCases;
        //END MODIFICA marco.arci@webresults.it
    }
    
    
    //TESTS

    @isTest
    private static void skipForSie(){
        Test.startTest();
        List<Case> caseList = [SELECT Id, isExportCMOR__c,Type FROM Case];
        caseList[0].isExportCMOR__c = true;
        update caseList;
        Test.stopTest();
        System.assert(caseList[0].isExportCMOR__c, true);
    }

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
        System.assert(newMap != null, 'Attenzione, la mappa non può essere vuota!');
        System.assert(oldMap != null, 'Attenzione, la mappa non può essere vuota!');

    }

    @isTest
    private static void casePhaseManagementAfterUpdateTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'casePhaseManagementAfterUpdateTest';
        System.debug(debugString);
        
        //SETUP              
        List<Case> newCasesList = new List<Case>();
        List<Case> oldCasesList = [Select Id, AccountId, Contact.Id, RecordTypeId, RecordType.Name, Phase__c from Case where Phase__c = 'Bozza'];
        newCasesList.add(oldCasesList[0]);
        newCasesList[0].Phase__c = 'Annullato';
        newCasesList[0].RecordTypeId = oldCasesList[0].RecordTypeId;
        newCasesList[0].RecordType.Name = oldCasesList[0].RecordType.Name;
        update newCasesList;

        //TESTING
        Test.startTest();
        Try{
             
            HDT_UTL_CaseProcess.casePhaseManagementAfterUpdate(newCasesList, oldCasesList);


        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(newCasesList != null, 'Attenzione, la lista non può essere vuota!');
        System.assert(oldCasesList != null, 'Attenzione, la lista non può essere vuota!');

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
        Map<Id, Case> oldMap = new Map<Id, Case>(oldCasesList);

        List<wrts_prcgvr__ActivityTemplate__c> myATList = new List<wrts_prcgvr__ActivityTemplate__c>();
        wrts_prcgvr__ActivityTemplate__c myAt = new wrts_prcgvr__ActivityTemplate__c();
        myAT.Name = 'Annullamento Allineamento';
        myAT.wrts_prcgvr__Assignees__c = 'Mario Rossi';
        myAT.wrts_prcgvr__Subject__c = 'Annullamento Allineamento';
        myAT.wrts_prcgvr__DueDateField__c = 'myDueDateField';
        myATList.add(myAt);

        insert myATList;
        
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
        System.assert(newCasesList != null, 'Attenzione, la lista non può essere vuota!');
        System.assert(oldCasesList != null, 'Attenzione, la lista non può essere vuota!');

    }

    @isTest
    private static void updateMemberStatusforClosedCasesTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'updateMemberStatusforClosedCasesTest';
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
            
            HDT_UTL_CaseProcess.updateMemberStatusforClosedCases(newCasesList, oldCasesList);


        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(newCasesList != null, 'Attenzione, la lista non può essere vuota!');
        System.assert(oldCasesList != null, 'Attenzione, la lista non può essere vuota!');

    }

    @isTest
    private static void updateServiceRequestTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'updateServiceRequestTest';
        System.debug(debugString);
        
        //SETUP

        List<ServiceRequest__c> mySRList = HDT_UTL_DataFactoryTst.createServiceRequest(1, true);
        List<Case> newCasesList = new List<Case>();
        List<Case> oldCasesList = [Select Id, Status from Case where Status = 'New'];
        newCasesList.add(oldCasesList[0]);
        newCasesList[0].Status = 'In Lavorazione';
        mySRList[0].Case__c = newCasesList[0].Id;
        update mySRList;
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
        System.assert(newCasesList != null, 'Attenzione, la lista non può essere vuota!');
        System.assert(oldCasesList != null, 'Attenzione, la lista non può essere vuota!');

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
        System.assert(caseList != null, 'Attenzione, la lista non può essere vuota!');

    }

    //START MODIFICA marco.arci@webresults.it
    @isTest
    private static void createActivityFromContractTest(){
        list<Case> testCases = [SELECT Id, AccountId, ServicePoint__c, SupplyCity__c, SupplyStreetName__c, Type FROM Case WHERE Type IN ('Modifica post accertamento','Cessazione post accertamento')];
        Test.startTest();
            HDT_UTL_CaseProcess.createActivityFromContract(testCases);
        Test.stopTest();
    }
    //END MODIFICA marco.arci@webresults.it
}