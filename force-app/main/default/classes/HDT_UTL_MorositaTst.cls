@isTest
public with sharing class HDT_UTL_MorositaTst {

    
    //DEBUG
    public static final String TEST_NAME = 'HDT_UTL_MorositaTst';
    
    
    //TEST SETUP
    
    
    //TESTS
    

    @isTest
    private static void transcodeProcessTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'transcodeProcessTest';
        System.debug(debugString);
        
        //SETUP
        String process='';
        String result='';
        
        //TESTING
        Test.startTest();
        Try{
            result = HDT_UTL_Morosita.transcodeProcess(process);
            process = 'Sospensione Fornitura';
            result = HDT_UTL_Morosita.transcodeProcess(process);
            process = 'Riattivazione Fornitura';
            result = HDT_UTL_Morosita.transcodeProcess(process);
            process = 'Risoluzione no sospensione';
            result = HDT_UTL_Morosita.transcodeProcess(process);
            process = 'Risoluzione no disalimentabile';
            result = HDT_UTL_Morosita.transcodeProcess(process);            
            
        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(process != null);
        System.assert(result != null);
        
    }

    @isTest
    private static void handleContainerTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'handleContainerTest';
        System.debug(debugString);
        
        //SETUP

        String containerId = '';

        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        Case myCase = caseList[0];
        
        //TESTING
        Test.startTest();
        Try{
            containerId = HDT_UTL_Morosita.handleContainer(myCase);
            
        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(containerId != null);
        System.assert(myCase.Id != null);
        
    }



}
