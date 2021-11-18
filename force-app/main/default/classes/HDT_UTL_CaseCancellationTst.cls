/*
    @Author:        Francesco Vitiello
    CreatedDate:    21/09/2021
*/

@isTest
public with sharing class HDT_UTL_CaseCancellationTst {

    
    //DEBUG
    public static final String TEST_NAME = 'HDT_UTL_CaseCancellationTst';
    
    
    //TEST SETUP
    @TestSetup
    static void makeData(){
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.createActivityTemplate(1,true);
        List<Account> acc = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, acc[0].Id, 'Bozza');
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, acc[0].Id);
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, acc[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCaseAutolettura(1, true, acc[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
    }
    
    //TESTS

    @isTest
    private static void dispatchMethodTest(){
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'dispatchMethodTest';
        System.debug(debugString);
        
        //SETUP

        List<HDT_UTL_CaseCancellation.HDT_UTL_RequestCancellationReason> inputs = new List<HDT_UTL_CaseCancellation.HDT_UTL_RequestCancellationReason>();
        HDT_UTL_CaseCancellation.HDT_UTL_RequestCancellationReason myInput = new HDT_UTL_CaseCancellation.HDT_UTL_RequestCancellationReason();
        
        
        List<HDT_ProcessCancellationReason__mdt> myProcessInputList = [select id, RecordType__c, Commodity__c, Process_Type__c, Process_Type_to_Cancell__c from HDT_ProcessCancellationReason__mdt where Process_Type__c = 'Annullamento prestazione'];
        HDT_ProcessCancellationReason__mdt myProcessInput = myProcessInputList[0]; 
        String myString = JSON.serialize(myProcessInput);
        HDT_UTL_CaseCancellation.getListCanellationReasonLwc(myString);
        
        HDT_UTL_CaseCancellation.dispatchMethod(inputs);
        inputs.add(myInput);

        //TESTING
        Test.startTest();
        try{
            
            //TESTING - getCancellationReason
            myInput.method = 'getCancellationReason';
            myInput.causalCode = 'SE1';
            myInput.processCancellationReason = '';
            
            HDT_UTL_CaseCancellation.HDT_UTL_ResponseCancellationReason result1 = HDT_UTL_CaseCancellation.dispatchMethod(inputs)[0];
            
            //ASSERTS
            System.assertEquals('AN1', result1.causalCode, 'Result 1 causalCode errato.');
            
            
            //TESTING - getListCancellationReason
            myInput = new HDT_UTL_CaseCancellation.HDT_UTL_RequestCancellationReason();
            myInput.method = 'getListCancellationReason';
            myInput.recordType = 'HDT_RT_ComportamentoVenditori';
            myInput.commodity = 'Energia Elettrica';
            myInput.processType = 'Annullamento prestazione';
            myInput.processTypeToCancell = '';
            inputs = new List<HDT_UTL_CaseCancellation.HDT_UTL_RequestCancellationReason>{myInput};
            
            HDT_UTL_CaseCancellation.HDT_UTL_ResponseCancellationReason result2 = HDT_UTL_CaseCancellation.dispatchMethod(inputs)[0];
            
            //ASSERTS
            System.assertEquals(null, result2.causalCode, 'Result 2 causalCode errato.');
            System.assertEquals('OK', result2.outcome, 'Result 2 Outcome errato.');
            
            
            //TESTING - else
            myInput = new HDT_UTL_CaseCancellation.HDT_UTL_RequestCancellationReason();
            myInput.method = 'myMethod';
            inputs = new List<HDT_UTL_CaseCancellation.HDT_UTL_RequestCancellationReason>{myInput};
            
            HDT_UTL_CaseCancellation.HDT_UTL_ResponseCancellationReason result3 = HDT_UTL_CaseCancellation.dispatchMethod(inputs)[0];
            
            //ASSERTS
            System.assertEquals('KO', result3.outcome, 'Result 3 Outcome errato.');
            

            HDT_UTL_CaseCancellation.HDT_UTL_Option myClass = new HDT_UTL_CaseCancellation.HDT_UTL_Option('myLabel');

            //TESTING - createActivityForCase
            Case c = [SELECT id FROM Case];
            myInput = new HDT_UTL_CaseCancellation.HDT_UTL_RequestCancellationReason();
            myInput.recordId = c.Id;
            myInput.method = 'createActivityForCase';
            myInput.description = 'Gestione Manuale SAP';
            myInput.type = 'Gestione Manuale SAP';
            myInput.templateName = 'testActivityTemplate0';
            inputs = new List<HDT_UTL_CaseCancellation.HDT_UTL_RequestCancellationReason>{myInput};
            
            HDT_UTL_CaseCancellation.dispatchMethod(inputs);
            

            //ASSERTS
            List<wrts_prcgvr__Activity__c> activities = [SELECT Id FROM wrts_prcgvr__Activity__c WHERE Case__c =: c.Id AND CausalError__c = :myInput.description AND Type__c =:myInput.type];
            System.assert(!activities.isEmpty(), 'L\'attivity non è stata creata.');

        } catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        Test.stopTest();
        
        
    }

}

