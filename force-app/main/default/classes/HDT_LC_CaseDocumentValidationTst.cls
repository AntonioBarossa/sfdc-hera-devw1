@isTest
public with sharing class HDT_LC_CaseDocumentValidationTst {
    
    //DEBUG
    public static final String TEST_NAME = 'HDT_LC_CaseDocumentValidationTstTst';
    
    
    //TEST SETUP
    //NOTA: skipping @testSetup per ragioni di flessibilità del setup
    
    //SETUP WITH CASE MOROSITà
    private static void setupMorosita(){
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        
    }
    
    //SETUP WITH CASE DOCUMENTALE
    private static void setupDocumentale(){
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCaseDocumentale(1, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        
    }
    
    
    
    //TESTS
    
    //isValidPhase
    @isTest
    private static void isValidPhaseTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'isValidPhaseTest';
        System.debug(debugString);
        
        //SETUP
        setupMorosita();
        
        //TESTING
        Case myCase = [SELECT Id FROM Case];
        Boolean result = HDT_LC_CaseDocumentValidation.isValidPhase(myCase.Id);
        
        //ASSERTS
        System.assert(result,'value of parameter is matching');
        
    }
    
    
    //saveValidation
    @isTest
    private static void saveValidationTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'saveValidationTest';
        System.debug(debugString);
        
        //SETUP
        setupDocumentale();
        
        //TESTING
        Case myCase = [SELECT Id FROM Case];
        
        //PROCESS CLICK
        HDT_UTL_DataFactoryTst.pClickCasePhase();
        
        //PHASE TRANSITION
        HDT_UTL_Constants constantsUtl = new HDT_UTL_Constants();
        String rtName = constantsUtl.CASE_RECORDTYPE_DEVELOPERNAME_DOCUMENTALECOPIACONTRATTO;
        String rtId = constantsUtl.CASE_RECORDTYPEID_DOCUMENTALECOPIACONTRATTO;
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'In attesa Documentazione', 'Bozza', rtId, rtName,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Elaborazione Manuale', 'In attesa Documentazione', rtId, rtName,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Da Inviare', 'Elaborazione Manuale', rtId, rtName,'A','','','');
        
        //TODO: ANALIZZARE IL TRIGGER HANDLER HDT_TRH_Case, POSSIBILE INTERVENTO LEGATO A METADATO MANCANTE PhaseManagerIntegration
        
        //IN ATTESA
        HDT_LC_CaseDocumentValidation.saveValidation(myCase.Id, 'Accise - Energia Elettrica', false);
        Case myCase_Check1 = [SELECT Id, Phase__c FROM Case WHERE Id = :myCase.Id];
        System.assertEquals('In attesa Documentazione', myCase_Check1.Phase__c,'value of parameter is matching');
        
        //ELAB MANUALE
        HDT_LC_CaseDocumentValidation.saveValidation(myCase.Id, 'Accise - Energia Elettrica', true);
        Case myCase_Check2 = [SELECT Id, Phase__c FROM Case WHERE Id = :myCase.Id];
        System.assertEquals('Elaborazione Manuale', myCase_Check2.Phase__c,'value of parameter is matching');
        
        //DA INVIARE
        HDT_LC_CaseDocumentValidation.saveValidation(myCase.Id, 'Test', true);
        Case myCase_Check3 = [SELECT Id, Phase__c FROM Case WHERE Id = :myCase.Id];
        System.assertEquals('Da Inviare', myCase_Check3.Phase__c,'value of parameter is matching');
        
    }
    
}
