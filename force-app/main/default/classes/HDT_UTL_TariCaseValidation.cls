/**
 * @description       : 
 * @author            : Giacinto Florio
 * @group             : 
 * @last modified on  : 26-05-2022
 * @last modified by  : Giacinto Florio
**/
public with sharing class HDT_UTL_TariCaseValidation implements HDT_UTL_CaseValidationInterface {
    
	HDT_QR_CaseValidations caseValidationQr = new HDT_QR_CaseValidations();
    
    public String validate(String fields, String recordId){
        Case currentCase = caseValidationQr.getCaseById(recordId);
		Integer countAttachments = [Select Count() FROM ContentDocumentLink WHERE LinkedEntityId =:recordId WITH SECURITY_ENFORCED];

        if(currentCase.Type=='Sconti Collettivi Pap'){
            if(getFieldValue(fields, 'Description') == '' || getFieldValue(fields, 'Description') == null){
                return JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Popolare il campo descrizione'));
            }
        }
        if((currentCase.Type=='Formulari Richiesta Sconto' || currentCase.Type=='Riduzione Superficie rifiuti spec promiscui') && countAttachments<1){
            return JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Caricare almeno un allegato'));
        }
        return JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK', 'Success'));
    }

    public String getFieldValue(String fields, String fieldToGet){
        Map<String, Object> fieldsMap = (Map<String, Object>) JSON.deserializeUntyped(fields);
        return String.valueOf(fieldsMap.get(fieldToGet));
    }
}