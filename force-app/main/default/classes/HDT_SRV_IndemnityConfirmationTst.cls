@isTest
public with sharing class HDT_SRV_IndemnityConfirmationTst 
{
    private static HDT_UTL_Constants utlConstants = new HDT_UTL_Constants();
    
    @TestSetup
    static void setup()
    {

        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickCasePhase();

        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(4, false, accList[0].Id, contactList[0].Id, servPointList[0].Id, contractList[0].Id, null);
        caseList[0].Cluster__c = 'Reclami';
        caseList[0].Type = 'Contenitore Reclami';
        caseList[0].RecordTypeId = utlConstants.CASE_RECORDTYPEID_MOROSITA;
        caseList[0].IsContainer__c = true;
        caseList[1].Cluster__c = 'Reclami';
        caseList[1].Type = 'Reclamo Scritto/Rich. Info';
        caseList[1].ComplaintType__c = 'Reclamo Scritto';
        caseList[1].FirstLevelComplaintClassification__c = 'Reclamo Scritto';
        caseList[1].SecondLevelComplaintClassification__c = 'Misura';
        caseList[1].RecordTypeId = utlConstants.CASE_RECORDTYPEID_MOROSITA;
        caseList[2].Cluster__c = 'Reclami';
        caseList[2].Type = 'Reclamo Scritto/Rich. Info';
        caseList[2].ComplaintType__c = 'Reclamo Scritto';
        caseList[2].FirstLevelComplaintClassification__c = 'Reclamo Scritto';
        caseList[2].SecondLevelComplaintClassification__c = 'Misura';
        caseList[2].IndemnityConfirmed__c = true;
        caseList[2].RecordTypeId = utlConstants.CASE_RECORDTYPEID_MOROSITA;
        caseList[3].Cluster__c = 'Indennizzi';
        caseList[3].RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_Indennizzo').getRecordTypeId();
        insert caseList;

        caseList[0].Note__c = caseList[1].Id + ';';
        caseList[1].ParentId = caseList[0].Id;
        caseList[3].ParentId = caseList[2].Id;

        update caseList;

    }

    
    //TESTS
    @isTest
    private static void checkIndemnityConfirmationTestContainer() {

        List<HDT_SRV_IndemnityConfirmation.HDT_UTL_FlowInputs> inputs = new List<HDT_SRV_IndemnityConfirmation.HDT_UTL_FlowInputs>();
        HDT_SRV_IndemnityConfirmation.HDT_UTL_FlowInputs input = new HDT_SRV_IndemnityConfirmation.HDT_UTL_FlowInputs();
        

        List<Case> caseList = [SELECT Id, AccountId, Note__c, IsContainer__c FROM Case WHERE Type = 'Contenitore Reclami'];

        input.recordId = caseList[0].Id;
        input.accountId = caseList[0].AccountId;
        input.servicePointId = '';
        input.firstLevel = '';
        input.note = caseList[0].Note__c;
        input.isContainer = caseList[0].IsContainer__c;
        
        inputs.add(input);
        
        List<HDT_SRV_IndemnityConfirmation.HDT_UTL_FlowOutputs> outputs;

        Test.startTest();
            outputs = HDT_SRV_IndemnityConfirmation.checkIndemnityConfirmation(inputs);
        Test.stopTest();
        
        System.assertEquals(true, outputs.isEmpty(), 'Conferma Indennizzo non calcolata');
    }

    @isTest
    private static void checkIndemnityConfirmationTestNonContainer()
    {
        List<HDT_SRV_IndemnityConfirmation.HDT_UTL_FlowInputs> inputs = new List<HDT_SRV_IndemnityConfirmation.HDT_UTL_FlowInputs>();
        HDT_SRV_IndemnityConfirmation.HDT_UTL_FlowInputs input = new HDT_SRV_IndemnityConfirmation.HDT_UTL_FlowInputs();

        List<Case> caseList = [SELECT Id, AccountId, ServicePoint__c, FirstLevelComplaintClassification__c, SecondLevelComplaintClassification__c, IsContainer__c FROM Case WHERE ParentId != NULL AND Cluster__c = 'Reclami'];
        input.recordId = caseList[0].Id;
        input.accountId = caseList[0].AccountId;
        input.servicePointId = caseList[0].ServicePoint__c;
        input.firstLevel = caseList[0].FirstLevelComplaintClassification__c;
        input.secondLevel = caseList[0].SecondLevelComplaintClassification__c;
        input.note = '';
        input.isContainer = caseList[0].IsContainer__c;
        
        inputs.add(input);
        List<HDT_SRV_IndemnityConfirmation.HDT_UTL_FlowOutputs> outputs;

        Test.startTest();
            outputs = HDT_SRV_IndemnityConfirmation.checkIndemnityConfirmation(inputs);
        Test.stopTest();

        System.assertEquals(true, !outputs.isEmpty(), 'Conferma Indennizzo non calcolata');
    }
    
}