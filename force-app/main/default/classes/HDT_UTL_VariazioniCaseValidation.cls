public with sharing class HDT_UTL_VariazioniCaseValidation implements HDT_UTL_CaseValidationInterface {
    
    HDT_QR_CaseValidations caseValidationQr = new HDT_QR_CaseValidations();

    public String validate(String fields, String recordId){

        Case currentCase = caseValidationQr.getCaseById(recordId);
        String caseType = currentCase.Type;
        List<ContentDocumentLink> attachedDocument = new List<ContentDocumentLink>();
        String result;
        Set<String> processesWithRequiredAttachment = new Set<String>{'Adesione Rinuncia Fondo Fughe', 'Esenzione Modifica Fognatura Depurazione'};

        attachedDocument = caseValidationQr.getDocumentByCaseId(recordId);

        if(attachedDocument.size() == 0 && processesWithRequiredAttachment.contains(caseType)){

            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 
                        'Attenzione! Per il processo di ' + caseType + ' è necessario inserire un allegato obbligatorio.'));

        }else{
            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK','Success'));
        }

        return result;

    }
}
