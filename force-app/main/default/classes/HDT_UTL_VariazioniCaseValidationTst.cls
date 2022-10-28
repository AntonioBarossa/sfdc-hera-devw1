@isTest
public with sharing class HDT_UTL_VariazioniCaseValidationTst {
    
    //DEBUG
    public static final String TEST_NAME = 'HDT_UTL_VariazioniCaseValidationTst';

    private static HDT_UTL_VariazioniCaseValidation caseAttachmentUtl = new HDT_UTL_VariazioniCaseValidation();

    @TestSetup
    static void setup(){
        Case myCase = new Case();
        myCase.Type = 'Adesione Rinuncia Fondo Fughe';
        myCase.Cluster__c = 'Variazioni';
        insert myCase; 

        Case myCaseModUnitImm = new Case();
        myCaseModUnitImm.Type = 'Modifica Unita Immobiliari Componenti';
        myCaseModUnitImm.Cluster__c = 'Variazioni';
        myCaseModUnitImm.RateCategory__c = 'ACPROMIBI0';
        myCaseModUnitImm.Unita_Abitative__c = 3;
        myCaseModUnitImm.ResidentMembers__c = 0;
        insert myCaseModUnitImm;

        AmministrazioneSottotipologiaUso__c newTypology = new AmministrazioneSottotipologiaUso__c();
        newTypology.TipologiaUso__c = 'Uso domestico';
        newTypology.DataFineValidita__c = Date.today().addDays(10);
        insert newTypology;

    }

    private static void mySetup(){

        HDT_UTL_DataFactoryTst.pClickCasePhase();

        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountResidenziale(1, true, 'HERA COMM', 'D1 - Persona fisica', 'Enti');

        List<Attachment> attacchmentsList = HDT_UTL_DataFactoryTst.createAttachment(1, true, accList.get(0).Id);

    }

    @SuppressWarnings('PMD.AvoidDebugStatements')
    @isTest
    private static void validateAttachment(){

        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateAttachment';
        System.debug(LoggingLevel.DEBUG, debugString);

        //SETUP
        mySetup();

        Case myCase1 = [Select Id, Type from Case where Type = 'Adesione Rinuncia Fondo Fughe'];

        String recordId1 = myCase1.Id;
        HDT_UTL_VariazioniCaseValidation attachValidation = new HDT_UTL_VariazioniCaseValidation();

        String result = attachValidation.validate(null, recordId1);
        
        System.assertNotEquals(null, result, 'Si è verificato un errore in fase di validazione.');

    }

    @SuppressWarnings('PMD.AvoidDebugStatements')
    @isTest
    private static void validateProcessoModificaUnitaImm(){

        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateProcessoModificaUnitaImm';
        System.debug(LoggingLevel.DEBUG, debugString);

        //SETUP
        mySetup();

        Case myCase1 = [Select Id, Type from Case where Type = 'Modifica Unita Immobiliari Componenti'];

        String recordId1 = myCase1.Id;
        HDT_UTL_VariazioniCaseValidation validation = new HDT_UTL_VariazioniCaseValidation();

        String result = validation.validate(null, recordId1);
        
        System.assertNotEquals(null, result, 'Si è verificato un errore in fase di validazione.');

    }


}
