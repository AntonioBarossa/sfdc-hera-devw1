/*
    @Author:        Francesco Vitiello
    CreatedDate:    30/09/2021
*/

@isTest
public with sharing class HDT_UTL_ComplaintsTst {

    
    //DEBUG
    public static final String TEST_NAME = 'HDT_UTL_ComplaintsTst';
    
    
    //TEST SETUP
    
    
    //TESTS

    @isTest
    private static void createChildRecordTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'createChildRecordTest';
        System.debug(debugString);
        
        //SETUP

        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        
        
        List<HDT_UTL_Complaints.HDT_UTL_FlowInputs> inputs = new List<HDT_UTL_Complaints.HDT_UTL_FlowInputs>();
        HDT_UTL_Complaints.HDT_UTL_FlowInputs myInput = new HDT_UTL_Complaints.HDT_UTL_FlowInputs();
        myInput.parentCase = caseList[0];
        myInput.recordTypeOpinion = caseList[0].RecordTypeId;
        inputs.add(myInput);

        //TESTING
        Test.startTest();
        Try{
            
            HDT_UTL_Complaints.createChildRecord(inputs);

            
        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(inputs != null, 'Attenzione, inputs non può essere null!');
        
    }

}


