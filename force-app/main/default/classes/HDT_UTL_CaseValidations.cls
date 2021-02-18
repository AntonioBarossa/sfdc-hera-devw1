public inherited sharing class HDT_UTL_CaseValidations implements HDT_UTL_CaseValidationInterface {

    public String validate(String fields, String recordId){

        Case currentCase = [SELECT Type, Subprocess__c FROM Case WHERE Id = :recordId WITH SECURITY_ENFORCED];
        System.debug('HDT_UTL_CaseValidations: validating Case ' + currentCase);

        String caseType = currentCase.Type;

        String result;

        if(caseType == 'Reclamo Scritto/Rich. Info'){

            //result = validateReclamoScritto(fields, recordId);

        } else if(caseType == 'Doppi Pagamenti/Incassi' || caseType == 'Piano Rateizzazione' || caseType == 'Richiesta Domiciliazione'
        || caseType == 'Variazione Domiciliazione' || caseType == 'Rimborso' || caseType == 'Attivazione Click&Pay' ||
        caseType == 'Storno Rateizzazione'){

            result = validatePagamenti(fields, caseType);

        } else if (caseType == 'Variazione Anagrafica Cliente' && currentCase.Subprocess__c == 'Modifica Dati di Contatto') {
            if (currentCase.Subprocess__c == 'Modifica Dati di Contatto') {
                result = validateModificaDatiContatto(fields);
            } else if (currentCase.Subprocess__c == 'Modifica Dati di Recapito') {
                result = validateModificaDatiRecapito(fields);
            }
        }

        return result;

    }

    public String validatePagamenti(String fields, string caseType){

        String result;

        if(caseType != getFieldValue(fields, 'Type')){

            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Impossibile modificare tipo processo'));

        } else {

            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK','Success'));

        }

        return result;

    }

    private String validateModificaDatiContatto(String fields) {
        String result;

        String newEmail = getFieldValue(fields, 'Email__c');
        String newMobile = getFieldValue(fields, 'Mobile__c');
        String newPhone = getFieldValue(fields, 'PhoneNumber__c');
        System.debug('validateModificaDatiContatto: ' + newEmail + ' - ' + newPhone + ' - ' + newMobile);

        Boolean noEmail = String.isBlank(newEmail) || newEmail.equalsIgnoreCase('null');
        Boolean noMobile = String.isBlank(newMobile) || newMobile.equalsIgnoreCase('null');
        Boolean noPhone = String.isBlank(newPhone) || newPhone.equalsIgnoreCase('null');
        System.debug('validateModificaDatiContatto: ' + noEmail + ' - ' + noMobile + ' - ' + noPhone);

        if (noEmail && noMobile && noPhone) {
            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'È necessario inserire almeno un riferimento telefonico o un indirizzo Email.'));
        } else {
            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK', 'Success'));
        }

        return result;
    }

    private String validateModificaDatiRecapito(String fields) {
        String result;

        String pecInvioBolletta = getFieldValue(fields, 'InvoiceCertifiedEmailAddress__c');
        String dataConsensoPec = getFieldValue(fields, 'SendCertifiedEmailConsentDate__c');
        String modInvioFatturazioneElettronica = getFieldValue(fields, 'ElectronicInvoicingMethod__c');
        String codiceUfficio = getFieldValue(fields, 'OfficeSubjectCode__c');
        String pecFatturazioneElettronica = getFieldValue(fields, 'ElectronicInvoiceCertifiedEmailAddress__c');
        String tipoXml = getFieldValue(fields, 'XMLType__c');

        

/*         String newEmail = getFieldValue(fields, 'Email__c');
        String newMobile = getFieldValue(fields, 'Mobile__c');
        String newPhone = getFieldValue(fields, 'PhoneNumber__c');
        System.debug('validateModificaDatiContatto: ' + newEmail + ' - ' + newPhone + ' - ' + newMobile);

        Boolean noEmail = String.isBlank(newEmail) || newEmail.equalsIgnoreCase('null');
        Boolean noMobile = String.isBlank(newMobile) || newMobile.equalsIgnoreCase('null');
        Boolean noPhone = String.isBlank(newPhone) || newPhone.equalsIgnoreCase('null');
        System.debug('validateModificaDatiContatto: ' + noEmail + ' - ' + noMobile + ' - ' + noPhone);

        if (noEmail && noMobile && noPhone) {
            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'È necessario inserire almeno un riferimento telefonico o un indirizzo Email.'));
        } else {
            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK', 'Success'));
        } */

        return result;
    }


    /*public String validateReclamoScritto(String fields, string recordId){

        String result;

        Case c = [SELECT evr_PrimoLivello__c, evr_TipologiaReclamo__c, evr_QuintoLivello__c FROM Case WHERE Id = :recordId];

        if(c.evr_PrimoLivello__c != getFieldValue(fields, 'evr_PrimoLivello__c') || c.evr_TipologiaReclamo__c != getFieldValue(fields, 'evr_TipologiaReclamo__c')){

            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Tipologia Reclamo e/o Primo Livello non Modificabile'));

        } else if((c.evr_QuintoLivello__c == null || c.evr_QuintoLivello__c == '') &&
                    (getFieldValue(fields, 'evr_VendutoDa__c') == null || getFieldValue(fields, 'evr_VendutoDa__c') == '')){

            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Venduto da è valorizzabile solo se è valorizzato il 5° Livello'));

        } else {

            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK','Success'));

        }

        return result;

    }*/


    public String getFieldValue(String fields, String fieldToGet){
        Map<String, Object> fieldsMap = (Map<String, Object>) JSON.deserializeUntyped(fields);
        return String.valueOf(fieldsMap.get(fieldToGet));
    }

}