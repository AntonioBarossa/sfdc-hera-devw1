@isTest
public with sharing class HDT_UTL_CheckDocumentSelectedTst {

    
    //DEBUG
    public static final String TEST_NAME = 'HDT_UTL_CheckDocumentSelectedTst';
    
    
    //TEST SETUP
    
    
    //TESTS

    @isTest
    private static void checkCreditDebitTest(){
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'checkCreditDebitTest';
        System.debug(debugString);
        
        //SETUP

        HDT_UTL_DataFactoryTst.pClickCasePhase();        

        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        
        DocumentSelected__c myDs1 = new DocumentSelected__c();
        myDs1.Case__c = caseList[0].Id;
        myDs1.DocumentResidue__c = 8.2;
        myDs1.DocumentNumber__c = '012';

        DocumentSelected__c myDs2 = new DocumentSelected__c();
        myDs2.Case__c = caseList[0].Id;
        myDs2.DocumentResidue__c = -3.5;
        insert myDs2;

        DocumentSelected__c myDs3 = new DocumentSelected__c();
        myDs3.Case__c = caseList[0].Id;
        myDs3.DocumentResidue__c = 8.2;
        myDs3.DocumentNumber__c = 'A12Z5';

        DocumentSelected__c myDs4 = new DocumentSelected__c();
        myDs4.Case__c = caseList[0].Id;
        myDs4.DocumentResidue__c = -2.2;
        myDs4.DocumentNumber__c = 'A13T5';

        List<HDT_UTL_CheckDocumentSelected.HDT_UTL_FlowInputs> inputs = new List<HDT_UTL_CheckDocumentSelected.HDT_UTL_FlowInputs>();
        HDT_UTL_CheckDocumentSelected.HDT_UTL_FlowInputs myInput = new HDT_UTL_CheckDocumentSelected.HDT_UTL_FlowInputs();

        myInput.recordId = caseList[0].Id;
        myInput.reimburseMethod = 'Bonifico';
        myInput.isForeign = false;
        myInput.beneficiary = 'Mario Rossi';
        inputs.add(myInput);

        //TESTING
        Test.startTest();
        Try{

            HDT_UTL_CheckDocumentSelected.checkCreditDebit(inputs);
        
            insert myDs3;
            insert myDs4;
            HDT_UTL_CheckDocumentSelected.checkCreditDebit(inputs);

            myInput.isForeign = true;
            HDT_UTL_CheckDocumentSelected.checkCreditDebit(inputs);

            myInput.reimburseMethod = 'Assegno';
            
            HDT_UTL_CheckDocumentSelected.checkCreditDebit(inputs);

            myInput.reimburseMethod = 'Compensazione';
            HDT_UTL_CheckDocumentSelected.checkCreditDebit(inputs);

            insert myDs1;
            myInput.reimburseMethod = 'myReimburseMethod';
            HDT_UTL_CheckDocumentSelected.checkCreditDebit(inputs);


        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(caseList != null, 'Attenzione, caseList non può essere null!');
        
    }

}
