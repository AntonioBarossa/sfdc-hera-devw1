@isTest
public with sharing class HDT_LC_CaseDocumentValidationTst {
    
    //DEBUG
    public static final String TEST_NAME = 'HDT_LC_CaseDocumentValidationTstTst';
    
    
    //TEST SETUP
    @TestSetup
    static void setup(){
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        
    }
    
    //TESTS
    
    //isValidPhase
    @isTest
    private static void isValidPhaseTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'isValidPhaseTest';
        System.debug(debugString);
        
        //TESTING
        Case myCase = [SELECT Id FROM Case];
        Boolean result = HDT_LC_CaseDocumentValidation.isValidPhase(myCase.Id);
        
        //ASSERTS
        System.assert(result);
        
    }
    
    
    //saveValidation
    @isTest
    private static void saveValidationTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'saveValidationTest';
        System.debug(debugString);
        
        //TESTING
        Case myCase = [SELECT Id FROM Case];
        
        
        //TODO: ANALIZZARE IL TRIGGER HANDLER HDT_TRH_Case, POSSIBILE INTERVENTO LEGATO A METADATO MANCANTE PhaseManagerIntegration
        
        //IN ATTESA
        HDT_LC_CaseDocumentValidation.saveValidation(myCase.Id, 'Accise - Energia Elettrica', false);
        Case myCase_Check1 = [SELECT Id, Phase__c FROM Case WHERE Id = :myCase.Id];
        System.assertEquals('In attesa Documentazione', myCase_Check1.Phase__c);
        
        
        //ELAB MANUALE
        HDT_LC_CaseDocumentValidation.saveValidation(myCase.Id, 'Accise - Energia Elettrica', true);
        Case myCase_Check2 = [SELECT Id, Phase__c FROM Case WHERE Id = :myCase.Id];
        System.assertEquals('Elaborazione Manuale', myCase_Check2.Phase__c);
        
        
        //DA INVIARE
        HDT_LC_CaseDocumentValidation.saveValidation(myCase.Id, 'Test', true);
        Case myCase_Check3 = [SELECT Id, Phase__c FROM Case WHERE Id = :myCase.Id];
        System.assertEquals('Da Inviare', myCase_Check3.Phase__c);
        
    }
    
}
