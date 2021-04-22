public inherited sharing class HDT_UTL_CaseValidations implements HDT_UTL_CaseValidationInterface {

    public String validate(String fields, String recordId){

        Case currentCase = [SELECT Type, Subprocess__c FROM Case WHERE Id = :recordId WITH SECURITY_ENFORCED];
        System.debug('HDT_UTL_CaseValidations: validating Case ' + currentCase);

        String caseType = currentCase.Type;

        String result;

        if(caseType == 'Reclamo Scritto/Rich. Info' || caseType == 'Richiesta Parere'){

            result = validateReclamoScritto(fields, recordId);

        } else if(caseType == 'Doppi Pagamenti/Incassi' || caseType == 'Piano Rateizzazione' || caseType == 'Richiesta Domiciliazione'
        || caseType == 'Variazione Domiciliazione' || caseType == 'Rimborso' || caseType == 'Attivazione Click&Pay' ||
        caseType == 'Storno Rateizzazione'){

            result = validatePagamenti(fields, caseType);


        } else if (caseType == 'Variazione Anagrafica Cliente') {
            if (currentCase.Subprocess__c == 'Modifica Dati di Contatto') {
                result = validateModificaDatiContatto(fields);
            } else if (currentCase.Subprocess__c == 'Modifica Dati di Recapito') {
                result = validateModificaDatiRecapito(fields);
            }
        } else if (caseType == 'Inversione del Contatore') {
            result = validateInversioneContatore(recordId, fields, caseType);
        } else if(caseType == 'Gestione Disalimentabilità' || caseType == 'Riattivazione Fornitura'){

            result = validateMorosita(fields, recordId, caseType);

        } else if(caseType == 'Marcatura/Uso PdR' 
        || caseType == 'Condizioni Contrattuali Errate' 
        || caseType == 'BP/CA - errata categoria'
        || caseType == 'Modifica/Azzeramento Consumo Annuo'){

            result = validateVariazioni(fields,recordId,caseType);

        } else if(caseType == 'Chiusura Contatore'){

            result = validateDisattivazioni(fields);

        }

        return result;

    }

    public String validatePagamenti(String fields, string caseType){

        String result;

        System.debug(caseType);

        System.debug(getFieldValue(fields, 'Type'));

        if(caseType != getFieldValue(fields, 'Type')){

            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Impossibile modificare tipo processo'));

        } else if(caseType == 'Piano Rateizzazione'){
            
            Boolean applicationInterests = Boolean.valueOf(getFieldValue(fields, 'ApplicationInterests__c'));
            Integer requestedInstall = Integer.valueOf(getFieldValue(fields, 'InstallmentNumberRequired__c'));
            String clientCategory = getFieldValue(fields, 'ClientCategory__c');
            String reason = getFieldValue(fields, 'Reason__c');
            Double amountInstall = Double.valueOf(getFieldValue(fields, 'AmountToPayInInstallments__c'));
            Date expDate = getFieldValue(fields, 'DepositExpirationDate__c') == null 
            ? System.today() + 365
            : Date.valueOf(getFieldValue(fields, 'DepositExpirationDate__c'));

            if(clientCategory.contains('SME')){

                if(!applicationInterests && requestedInstall > 6){

                    result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Numero rate richieste non deve essere maggiore di 6'));

                } else if(applicationInterests && requestedInstall > 2){

                    result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Numero rate richieste non deve essere maggiore di 2'));

                } else {

                    result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK','Success'));

                }
            
            }else{

                if(reason.contains('Disagio Rconomico') && ( amountInstall < 50 || expDate < (System.today() + 5))){

                    result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'L\'importo non deve essere inferiore a 50 ' + 
                    'o la data scadenza acconto non deve essere inferiore ai 5 giorni'));
                    
                } else {

                    result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK','Success'));

                }


            }
    
        
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
        String result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK', 'Success'));

        String pecInvioBolletta = getFieldValue(fields, 'InvoiceCertifiedEmailAddress__c');
        String dataConsensoPec = getFieldValue(fields, 'SendCertifiedEmailConsentDate__c');
        String modInvioFatturazioneElettronica = getFieldValue(fields, 'ElectronicInvoicingMethod__c');
        String codiceUfficio = getFieldValue(fields, 'OfficeSubjectCode__c');
        String pecFatturazioneElettronica = getFieldValue(fields, 'ElectronicInvoiceCertifiedEmailAddress__c');
        String tipoXml = getFieldValue(fields, 'XMLType__c');

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
        
        String delegateName = getFieldValue(fields,'DelegateName__c');

        String sendDate = getFieldValue(fields, 'SendDate__c') == null ? String.valueOf(System.today()) : getFieldValue(fields, 'SendDate__c');

        System.debug('SendDate value:' +sendDate);

        if((getFieldValue(fields, 'ComplaintEntryChannel__c') == 'Email' || getFieldValue(fields, 'ComplaintEntryChannel__c') == 'PEC')
        && (getFieldValue(fields, 'CompliantOriginEmail__c') == null || getFieldValue(fields, 'CompliantOriginEmail__c') == '')){

            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Inserire indirizzo Email provenienza reclamo'));
        }else if(delegateName != null && delegateName != ''){
            
            List<ContentDocumentLink> attachedDocument = [SELECT Id FROM ContentDocumentLink 
            WHERE LinkedEntityId = :recordId 
            WITH SECURITY_ENFORCED];
            
            if(attachedDocument.size() == 0){
            
                   result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Necessario inserire allegato'));
                
            }else{
            
                 result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK', 'Success'));
                 
            }
       
        } else if((getFieldValue(fields,'FithLevelComplaintClassification__c') == null || getFieldValue(fields,'FithLevelComplaintClassification__c') == '')
        && (getFieldValue(fields, 'SoldBy__c') != null && getFieldValue(fields, 'SoldBy__c') != '')){

            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Venduto Da non deve essere valorizzato se 5° Livello non é valorizzato'));

        }else if(date.valueOf(sendDate) > System.today()){

            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Impossibile inserire una data futura'));

        } else if(getFieldValue(fields, 'OpinionRequest__c') != null){

            String opinionRequest = getFieldValue(fields, 'OpinionRequest__c');

            String currentOpinionRequest = [SELECT OpinionRequest__c FROM Case WHERE Id = :recordId WITH SECURITY_ENFORCED].OpinionRequest__c;

            if(opinionRequest.trim() == currentOpinionRequest.trim()){

                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Inserire una richiesta parere differente da quella precedente'));
            
            } else {

                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK', 'Success'));

            }

        } else {

            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK', 'Success'));

        }

        System.debug('Result: '+result);

        return result;

    }

    
    public String validateMorosita(String fields, string recordId, String caseType){

        String result;

        String disconnectable = getFieldValue(fields, 'Disconnectable__c');

        String disconnectableCategory = getFieldValue(fields, 'NotDisconnectableCategory__c');

        String phonePesse = getFieldValue(fields, 'MobilePhonePersonalizedNoticePesse__c');



        if(caseType == 'Riattivazione Fornitura'){

            Date paymentDate = date.ValueOf(getFieldValue(fields, 'PaymentDate__c'));

            if(paymentDate > System.today()){

                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Impossibile inserire una data futura'));

            } else {

                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK','Success'));

            }


        }else if(caseType == 'Gestione Disalimentabilità'){

            List<ContentDocumentLink> attachedDocument = [SELECT Id FROM ContentDocumentLink 
            WHERE LinkedEntityId = :recordId 
            WITH SECURITY_ENFORCED];



            if(disconnectable == 'false' 
            && ((disconnectableCategory == 'null' || disconnectableCategory == '') 
            || (phonePesse == 'null' || phonePesse == '') 
            || (attachedDocument.size() == 0))){

                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 
                    'Se Disalimentabilità è NO bisogna valorizzare:\nCategoria Disalimentabilità\n'+
                    'Il telefono Pesse\nEd è necessario inserire un allegato'));

            } else {

                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK','Success'));

            }
        } else {

            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK','Success'));

        }

        return result;

    }

    public String validateVariazioni(String fields, String recordId, String caseType){

        String supplyType = getFieldValue(fields, 'SupplyType__c');
        String useCategory = getFieldValue(fields, 'UseCategory__c');
        String servicePointType = getFieldValue(fields, 'ServicePointType__c');

        

        String result;

        if(caseType == 'Marcatura/Uso PdR'){

            if(HDT_UTL_Variations.consistencyCheck(recordId, useCategory, supplyType, servicePointType)){

                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK','Success'));

            } else {

                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error','Controllo di coerenza non superato, correggere i dati'));

            }
        
        }else if(caseType == 'BP/CA - errata categoria'){

            String billingProblem = getFieldValue(fields, 'BillingProblem__c');
            String bill = getFieldValue(fields, 'Bill__c');
            String dlNote = getFieldValue(fields, 'Note__c');
            String customerAggreement = getFieldValue(fields, 'CustomerAggreement__c');

            if(billingProblem == 'Si' 
            && (
                (bill == null || bill == '')
                ||(dlNote == null || dlNote == '')
                ||(customerAggreement == null || customerAggreement == '')
                )
            ){

                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error','Valorizzare: Fattura, Note al DL e Accordi con il Cliente'));

            } else {

                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK','Success'));

            }

        } else if(caseType == 'Modifica/Azzeramento Consumo Annuo'){

            Date validityDate = Date.valueOf(getFieldValue(fields, 'EndValidityDate__c'));

            Date effectiveDate = Date.valueOf(getFieldValue(fields, 'EffectiveDate__c'));

            if((validityDate > System.today().addYears(3)) || (validityDate <= effectiveDate)){

                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error','Data Fine Validità incorretta'));

            } else if(effectiveDate < System.today()){

                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error','Data Decorrenza incorretta'));

            }else{

                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK','Success'));

            }

        } else if(getFieldValue(fields, 'BillingProblem__c') == 'Si' && 
        (getFieldValue(fields, 'CustomerAggreement__c') == null || getFieldValue(fields, 'CustomerAggreement__c') == '')){

            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error','Controllo di coerenza non superato, correggere i dati'));

        } else {

            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK','Success'));

        }

        return result;

    }

    public String validateDisattivazioni(String fields){

        String result;

        Date notBeforeDate = Date.valueOf(getFieldValue(fields, 'NotPerformedBefore__c'));
        Date requestDate = Date.valueOf(getFieldValue(fields, 'WrittenReceiptRequestDate__c'));

        if(notBeforeDate < System.today()){

            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error','La data non può essere nel passato'));

        } else if(requestDate > System.today()){

            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error','La data non può essere nel futuro'));

        } else {

            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK','Success'));

        }


        return result;

    }

    public String getFieldValue(String fields, String fieldToGet){
        Map<String, Object> fieldsMap = (Map<String, Object>) JSON.deserializeUntyped(fields);
        return String.valueOf(fieldsMap.get(fieldToGet));
    }

}