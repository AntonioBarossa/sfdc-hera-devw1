public with sharing class HDT_UTL_VariazioniCaseValidation implements HDT_UTL_CaseValidationInterface {
    
    HDT_QR_CaseValidations caseValidationQr = new HDT_QR_CaseValidations();

    public String validate(String fields, String recordId){

        Case currentCase = caseValidationQr.getCaseById(recordId);
        String caseType = currentCase.Type;
        String rateCategory = currentCase.RateCategory__c;
        List<ContentDocumentLink> attachedDocument = new List<ContentDocumentLink>();
        String result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK','Success'));
        Set<String> processesWithRequiredAttachment = new Set<String>{'Adesione Rinuncia Fondo Fughe', 'Esenzione Modifica Fognatura Depurazione'};

        attachedDocument = caseValidationQr.getDocumentByCaseId(recordId);

        if(attachedDocument.size() == 0 && processesWithRequiredAttachment.contains(caseType)){
            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 
                        'Attenzione! Per il processo di ' + caseType + ' è necessario inserire un allegato obbligatorio.'));
        }
        
        if ('Modifica Unita Immobiliari Componenti'.equals(caseType) && !'ACDOMRESP0'.equals(rateCategory)){

            Integer unitDomRes = Integer.valueOf(getFieldValue(fields, 'ResidentDomesticHousingUnit__c'));
            Integer unitDomNonRes = Integer.valueOf(getFieldValue(fields, 'NotResidentDomesticHousingUnit__c'));
            Integer unitNonDom = Integer.valueOf(getFieldValue(fields, 'Unita_Abitative__c'));
            Integer unitNonDomComm = Integer.valueOf(getFieldValue(fields, 'CommercialHousingUnit__c'));
            Integer numCompDomRes = Integer.valueOf(getFieldValue(fields, 'ResidentMembers__c'));
            if (unitDomRes > 0 && numCompDomRes <= 0){
                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 
                        'Attenzione! Il numero dei Componenti Domestici Residenti deve essere maggiore di 0.'));
            }else if (numCompDomRes < unitDomRes) {
                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 
                        'Attenzione! Il numero dei Componenti Domestici Residenti deve essere maggiore o uguale al numero di Unità abitative domestico residente.'));
            }else if (unitDomRes + unitDomNonRes + unitNonDom + unitNonDomComm < 2) {
                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 
                        'Attenzione! La somma delle unità abitative deve essere maggiore o uguale a 2.'));
            }
        }else if ('Variazione indirizzo di fornitura'.equals(caseType) && 'Acqua'.equalsIgnoreCase(currentCase.Commodity__c)){
            if(String.isBlank(currentCase.ShipmentAddressAssign__c)){
                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Inserire Indirizzo di Fornitura.'));
            } 
        }

        return result;

    }

    public String getFieldValue(String fields, String fieldToGet){
        Map<String, Object> fieldsMap = (Map<String, Object>) JSON.deserializeUntyped(fields);
        if(fieldsMap.get(fieldToGet) != null)
            return String.valueOf(fieldsMap.get(fieldToGet));
        else {
            return '';
        }
    }
}
