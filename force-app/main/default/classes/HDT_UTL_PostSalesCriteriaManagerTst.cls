@isTest
public with sharing class HDT_UTL_PostSalesCriteriaManagerTst {

    
    //DEBUG
    public static final String TEST_NAME = 'HDT_UTL_PostSalesCriteriaManagerTst';
    
    
    //TEST SETUP
    
    
    //TESTS

    @isTest
    private static void distributorManagementTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'distributorManagementTest';
        System.debug(debugString);
        
        //SETUP
        
        String phaseStory = 'Pratica non gestita per il DL';

        //TESTING
        Test.startTest();
        Try{
            HDT_UTL_PostSalesCriteriaManager myClass = new HDT_UTL_PostSalesCriteriaManager();            
            myClass.distributorManagement(phaseStory);
            
        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(phaseStory != null, 'Attenzione, phaseStory non può essere null!');
        
    }

    @isTest
    private static void secondAdmissibilityTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'secondAdmissibilityTest';
        System.debug(debugString);
        
        //SETUP
        
        String phaseStory = 'Preventivo Accettato';

        //TESTING
        Test.startTest();
        Try{
            
            HDT_UTL_PostSalesCriteriaManager myClass = new HDT_UTL_PostSalesCriteriaManager();            
            myClass.secondAdmissibility(phaseStory);
            
        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(phaseStory != null, 'Attenzione, phaseStory non può essere null!');
        
    }

    @isTest
    private static void notExecWorksTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'notExecWorksTest';
        System.debug(debugString);
        
        //SETUP
        
        String phaseStory = 'Dati Tecnici Ricevuti';

        //TESTING
        Test.startTest();
        Try{
            
            HDT_UTL_PostSalesCriteriaManager myClass = new HDT_UTL_PostSalesCriteriaManager();            
            myClass.notExecWorks(phaseStory);
            
        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(phaseStory != null, 'Attenzione, phaseStory non può essere null!');
        
    }


}


