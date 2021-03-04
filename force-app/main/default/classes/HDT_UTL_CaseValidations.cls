public inherited sharing class HDT_UTL_CaseValidations implements HDT_UTL_CaseValidationInterface {

    public String validate(String fields, String recordId){

        Case currentCase = [SELECT Type, Subprocess__c FROM Case WHERE Id = :recordId WITH SECURITY_ENFORCED];
        System.debug('HDT_UTL_CaseValidations: validating Case ' + currentCase);

        String caseType = currentCase.Type;

        String result;

        if(caseType == 'Reclamo Scritto/Rich. Info'){

            result = validateReclamoScritto(fields, recordId);

        } else if(caseType == 'Doppi Pagamenti/Incassi' || caseType == 'Piano Rateizzazione' || caseType == 'Richiesta Domiciliazione'
        || caseType == 'Variazione Domiciliazione' || caseType == 'Rimborso' || caseType == 'Attivazione Click&Pay' ||
        caseType == 'Storno Rateizzazione'){

            result = validatePagamenti(fields, caseType);

        } else if (caseType == 'Inversione del Contatore') {
            result = validateInversioneContatore(recordId, fields, caseType);
        } else if (caseType == 'Variazione Anagrafica Cliente' && currentCase.Subprocess__c == 'Modifica Dati di Contatto') {
            result = validateModificaDatiContatto(fields);
        }

        return result;

    }

    public String validatePagamenti(String fields, string caseType){

        String result;

        System.debug(caseType);

        System.debug(getFieldValue(fields, 'Type'));

        if(caseType != getFieldValue(fields, 'Type')){

            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Impossibile modificare tipo processo'));

        } else {

            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK','Success'));

        }

        return result;

    }

    public String validateInversioneContatore(String caseId, String fields, string caseType) {

        String result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK', 'Success'));

        String relatedCaseId = getFieldValue(fields, 'RelatedCase__c');

        if (relatedCaseId == null || String.isBlank(relatedCaseId) || String.isEmpty(relatedCaseId) || relatedCaseId.equalsIgnoreCase('null')) {
            return result;
        }

        Case currentCase = [SELECT Id, CommodityFormula__c, ServicePoint__r.ServicePointCode__c FROM Case WHERE Id = :caseId WITH SECURITY_ENFORCED];
        Case relatedCase = [SELECT Id, CommodityFormula__c, ServicePoint__r.ServicePointCode__c FROM Case WHERE Id = :relatedCaseId WITH SECURITY_ENFORCED];

        if (!relatedCase.CommodityFormula__c.equalsIgnoreCase(currentCase.CommodityFormula__c)) {
            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Servizio incompatibile. Case attuale: ' + currentCase.CommodityFormula__c + ', Case correlato: ' + relatedCase.CommodityFormula__c));
        } else if (relatedCase.ServicePoint__r.ServicePointCode__c.equalsIgnoreCase(currentCase.ServicePoint__r.ServicePointCode__c)) {
            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Non è possibile correlare due processi di Inversione Contatore sullo stesso impianto'));
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


    public String validateReclamoScritto(String fields, string recordId){

        String result;

        String sendDate = getFieldValue(fields, 'SendDate__c') == null ? String.valueOf(System.today()) : getFieldValue(fields, 'SendDate__c');

        System.debug('SendDate value:' +sendDate);

        if((getFieldValue(fields, 'ComplaintEntryChannel__c') == 'Email' || getFieldValue(fields, 'ComplaintEntryChannel__c') == 'PEC')
        && (getFieldValue(fields, 'CompliantOriginEmail__c') == null || getFieldValue(fields, 'CompliantOriginEmail__c') == '')){

            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Inserire indirizzo Email provenienza reclamo'));

        } else if((getFieldValue(fields,'FithLevelComplaintClassification__c') == null || getFieldValue(fields,'FithLevelComplaintClassification__c') == '')
        && (getFieldValue(fields, 'SoldBy__c') != null && getFieldValue(fields, 'SoldBy__c') != '')){

            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Venduto Da non deve essere valorizzato se 5° Livello non é valorizzato'));

        }else if(date.valueOf(sendDate) > System.today()){

            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Impossibile inserire una data futura'));

        } else {

            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK', 'Success'));

        }

        System.debug('Result: '+result);

        return result;

    }


    public String getFieldValue(String fields, String fieldToGet){
        Map<String, Object> fieldsMap = (Map<String, Object>) JSON.deserializeUntyped(fields);
        return String.valueOf(fieldsMap.get(fieldToGet));
    }

}