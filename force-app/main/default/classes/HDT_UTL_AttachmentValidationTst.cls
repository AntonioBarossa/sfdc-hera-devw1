@isTest
@SuppressWarnings('PMD.UnusedLocalVariable')
public with sharing class HDT_UTL_AttachmentValidationTst {
   
    //DEBUG
    public static final String TEST_NAME = 'HDT_UTL_AttachmentValidationTst';

    private static HDT_UTL_AttachmentValidation caseAttachmentUtl = new HDT_UTL_AttachmentValidation();

    @TestSetup
    static void setup(){
        Case myCase = new Case();
        myCase.Type = 'Adesione Rinuncia Fondo Fughe';
        myCase.Cluster__c = 'Variazioni';
        insert myCase; 
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
        HDT_UTL_AttachmentValidation attachValidation = new HDT_UTL_AttachmentValidation();

        String result = attachValidation.validate(null, recordId1);
        
        System.assertNotEquals(null, result, 'Si è verificato un errore in fase di validazione.');

    }

}
