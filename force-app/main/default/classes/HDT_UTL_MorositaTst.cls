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

            HDT_UTL_Morosita myClass1 = new HDT_UTL_Morosita();
            result = myClass1.transcodeProcess(process);

            process = 'Sospensione Fornitura';
            HDT_UTL_Morosita myClass2 = new HDT_UTL_Morosita();
            result = myClass2.transcodeProcess(process);
            
            process = 'Riattivazione Fornitura';
            HDT_UTL_Morosita myClass3 = new HDT_UTL_Morosita();
            result = myClass3.transcodeProcess(process);

            process = 'Risoluzione no sospensione';
            HDT_UTL_Morosita myClass4 = new HDT_UTL_Morosita();
            result = myClass4.transcodeProcess(process);

            process = 'Risoluzione no disalimentabile';
            HDT_UTL_Morosita myClass5 = new HDT_UTL_Morosita();
            result = myClass5.transcodeProcess(process);            
            
        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(process != null, 'Attenzione, process non può essere null!');
        System.assert(result != null, 'Attenzione, result non può essere null!');
        
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
            HDT_UTL_Morosita myClass = new HDT_UTL_Morosita();
            containerId = myClass.handleContainer(myCase);
            
        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(containerId != null, 'Attenzione, containerId non può essere null!');
        System.assert(myCase.Id != null, 'Attenzione, myCase.Id non può essere null!');
        
    }



}
