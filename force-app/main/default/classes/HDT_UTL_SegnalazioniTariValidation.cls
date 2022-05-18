public inherited sharing class HDT_UTL_SegnalazioniTariValidation implements HDT_UTL_CaseValidationInterface{

    HDT_QR_CaseValidations caseValidationQr = new HDT_QR_CaseValidations();

    @SuppressWarnings('PMD.AvoidDebugStatements')
    public String validate(String fields, String recordId){
        Case currentCase = caseValidationQr.getCaseById(recordId);
        System.debug(LoggingLevel.DEBUG,'HDT_UTL_CaseValidations: validating Case ' + currentCase);

        String caseType = currentCase.Type;
        //String subprocess = currentCase.Subprocess__c;
        //String cluster = currentCase.Cluster__c;

        String result;
        system.debug('ivaste'+caseType);
        if(caseType=='Segnalazioni Ambientali')   result = segnalazioniAmbienteValidate(currentCase);
        system.debug('ivaste'+result);
        if(STRING.isBlank(result))  {result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK', 'Success'));}
        return result;
    }

    private static String segnalazioniAmbienteValidate(Case currCase){
        if(STRING.isBlank(currCase.InvoicingCity__c) && STRING.isBlank(currCase.AlternativeAddress__c)) return JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Inserire Indirizzo!'));
        return null;
    }
}
