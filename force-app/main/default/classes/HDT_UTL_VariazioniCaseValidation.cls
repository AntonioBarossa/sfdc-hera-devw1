public with sharing class HDT_UTL_VariazioniCaseValidation implements HDT_UTL_CaseValidationInterface {
    
    HDT_QR_CaseValidations caseValidationQr = new HDT_QR_CaseValidations();

    public String validate(String fields, String recordId){

        Case currentCase = caseValidationQr.getCaseById(recordId);
        String caseType = currentCase.Type;
        String caseSubProcess = currentCase.Subprocess__c;
        List<ContentDocumentLink> attachedDocument = new List<ContentDocumentLink>();
        String result;
        Set<String> processesWithRequiredAttachment = new Set<String>{'Adesione Rinuncia Fondo Fughe', 'Esenzione Modifica Fognatura Depurazione'};

        attachedDocument = caseValidationQr.getDocumentByCaseId(recordId);

        if(attachedDocument.size() == 0 && processesWithRequiredAttachment.contains(caseType)){

            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 
                        'Attenzione! Per il processo di ' + caseType + ' è necessario inserire un allegato obbligatorio.'));

        }if ('Modifica Unita Immobiliari Componenti'.equals(caseType) && 'Promiscuo'.equals(caseSubProcess)){

            Case newCurrentCase = [SELECT Unita_Abitative__c, ResidentMembers__c , RateCategory__c  FROM Case WHERE Id =: recordId WITH SECURITY_ENFORCED LIMIT 1];
            List<AmministrazioneSottotipologiaUso__c> categoriesList = [SELECT Id FROM AmministrazioneSottotipologiaUso__c WHERE Attivo__c = true AND TipologiaUso__c = 'Uso domestico' AND CodiceCategoriaTariffa__c =: newCurrentCase.RateCategory__c];
            if (categoriesList.size() > 0 && newCurrentCase.Unita_Abitative__c > 0 && newCurrentCase.ResidentMembers__c <= 0){
                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 
                        'Attenzione! Il numero dei Componenti Domestici Residenti deve essere maggiore di 0.'));
            }else{
                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK','Success'));
            }
        }else{
            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK','Success'));
        }

        return result;

    }
}
