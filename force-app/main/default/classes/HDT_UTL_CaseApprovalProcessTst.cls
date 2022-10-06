/*
    @Author:        Francesco Vitiello
    CreatedDate:    15/09/2021
*/

@isTest
public with sharing class HDT_UTL_CaseApprovalProcessTst {
    
    //DEBUG
    public static final String TEST_NAME = 'HDT_UTL_CaseApprovalProcessTst';
    
    //DATA
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    
    //TEST SETUP
    @TestSetup
    static void setup() {
        
        //SETUP
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);

        //CASE PHASE MANAGEMENT ENABLE
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickCasePhase();
        
        String rtId = constants.CASE_RECORDTYPEID_PAG_PIANORATEIZZAZIONE;
        String rtName = constants.CASE_RECORDTYPE_DEVELOPERNAME_PAG_PIANORATEIZZAZIONE;
        HDT_UTL_DataFactoryTst.newPhaseTransition('In Attesa Approvazione', 'Bozza', rtId, rtName);
            
        
        //CASE - INSERT - PAGAMENTI - PIANO RATEIZZAZIONE
        Case myCase = HDT_UTL_DataFactoryTst.createCase(1, false, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id)[0];
        myCase.salesCompany__c='Hera Comm Marche';
        myCase.RecordTypeId = constants.CASE_RECORDTYPEID_PAG_PIANORATEIZZAZIONE;
        insert myCase;
        
        //CASE UPDATING
        myCase.Phase__c = 'In Attesa Approvazione';
        update myCase;
    }
    
    
    //TESTS
    
    //submitForApproval
    @isTest
    private static void submitForApprovalTst(){
    
        Case myCase = [SELECT Id, SalesCompany__c FROM Case][0];

        Test.startTest();
            try{
                HDT_UTL_CaseApprovalProcess.submitForApproval(new List<Case>{myCase});
            } catch (DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
            }
        Test.stopTest();

        Boolean check = false;
        Id selectedUserId = [SELECT Id, ActorId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :myCase.Id ][0].ActorId;
        Group approvalGroup = [SELECT Id, (SELECT Id, UserOrGroupId FROM GroupMembers) FROM Group WHERE DeveloperName = 'HDT_PG_ApprovatoriPianoRataHCM'][0]; 

        for( Integer i=0; i< approvalGroup.GroupMembers.size(); i++ ){
            check = approvalGroup.GroupMembers[i].UserOrGroupId == selectedUserId ? true : check;
        }

        System.assert(check, 'Test su approver fallito');
        
    }


}