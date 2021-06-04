public inherited sharing class HDT_UTL_CaseValidations implements HDT_UTL_CaseValidationInterface {

    HDT_QR_CaseValidations caseValidationQr = new HDT_QR_CaseValidations();

    public String validate(String fields, String recordId){

        Case currentCase = caseValidationQr.getCaseById(recordId);
        System.debug('HDT_UTL_CaseValidations: validating Case ' + currentCase);

        String caseType = currentCase.Type;
        String subprocess = currentCase.Subprocess__c;

        String result;

        if(caseType == 'Reclamo Scritto/Rich. Info' || caseType == 'Richiesta Parere'){

            result = validateReclamoScritto(fields, recordId, currentCase);

        } else if(caseType == 'Doppi Pagamenti/Incassi' || caseType == 'Piano Rateizzazione' || caseType == 'Richiesta Domiciliazione'
        || caseType == 'Variazione Domiciliazione' || caseType == 'Rimborso' || caseType == 'Attivazione Click&Pay' ||
        caseType == 'Storno Rateizzazione' || caseType == 'Blocco Sollecito/Interessi'){

            result = validatePagamenti(fields, caseType, currentCase);


        } else if (caseType == 'Variazione Anagrafica Cliente') {
            if (currentCase.Subprocess__c == 'Modifica Dati di Contatto') {
                result = validateModificaDatiContatto(fields, currentCase.ContactId);
            } else if (currentCase.Subprocess__c == 'Modifica Dati di Recapito') {
                result = validateModificaDatiRecapito(fields);
            } else if (currentCase.Subprocess__c == 'Modifica Dati Fiscali') {
                result = validateModificaDatiFiscali(fields, currentCase.AccountId);
            } else if (currentCase.Subprocess__c == 'Variazione Gruppo IVA') {
                result = validateVariazioneGruppoIva(fields, currentCase.AccountId);
            }
        } else if (caseType == 'Inversione del Contatore') {
            result = validateInversioneContatore(recordId, fields, caseType);
        } else if (caseType == 'Gestione Bonus Sociale') {
            result = validateGestioneBonusSociale(currentCase, fields);
        } else if(caseType == 'Gestione Disalimentabilità' || caseType == 'Riattivazione Fornitura'){

            result = validateMorosita(fields, recordId, caseType);

        } else if(caseType == 'Marcatura/Uso PdR' 
        || caseType == 'Condizioni Contrattuali Errate' 
        || caseType == 'BP/CA - errata categoria'
        || caseType == 'Modifica/Azzeramento Consumo Annuo'
        || caseType == 'Modifica Tariffa Residente/Non Residente'
        || caseType == 'Mancata Telelettura/lettura'
        || caseType == 'Cambio contatore non registrato'
        || caseType == 'Fiscale'){

            System.debug('Inside Variazioni Validations');

            result = validateVariazioni(fields,recordId,caseType, subprocess);

        } else if(caseType == 'Chiusura Contatore'){

            result = validateDisattivazioni(fields);

        } else if(caseType == 'Contratto Non Richiesto'){

            result = validateAnnullamento(fields);

        } else if(caseType == 'Unificazione/Separazione BP-CA-Bolletta') {

            result = validateUnificazioneSeparazione(fields);

        }else if(caseType == 'Votive Modena Contestazione Fattura'){

            result= validateVotiveModena(fields);
        } else if (caseType == 'Verifica Titolarità POD/PDR') {

            result = validateVerificaTitolarita(currentCase);

        } else {

            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK', 'Success'));

        }

        return result;

    }

    public String validatePagamenti(String fields, string caseType, Case currentCase){

        String result;

        System.debug(caseType);

        System.debug(getFieldValue(fields, 'Type'));

        if(caseType == 'Piano Rateizzazione'){

            Boolean attachmentManagement = (getFieldValue(fields, 'AttachmentManagement__c') != null && getFieldValue(fields, 'AttachmentManagement__c') != '')
                ? Boolean.valueOf(getFieldValue(fields, 'AttachmentManagement__c'))
                : null;

            if(attachmentManagement != null ){

                if(attachmentManagement){

                    List<ContentDocumentLink> attachedDocument = caseValidationQr.getDocumentByCaseId(currentCase.Id);

                    if(attachedDocument.size() == 0){
                    
                        result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Necessario inserire allegato'));
                        
                    }else{
                    
                        result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK', 'Success'));
                        
                    }
                }else{

                    result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK', 'Success'));
                
                }

            } else {
            

                Boolean deposit = getFieldValue(fields, 'Deposit__c') != null 
                    ? Boolean.valueOf(getFieldValue(fields, 'Deposit__c'))
                    : null;
                String depositPaymentMode = getFieldValue(fields, 'DepositPaymentMode__c');
                Decimal depositAmount = getFieldValue(fields, 'DepositAmount__c') != null 
                    ? Decimal.valueOf(getFieldValue(fields, 'DepositAmount__c'))
                    : null;
                Boolean applicationInterests = getFieldValue(fields, 'ApplicationInterests__c') != null
                    ? Boolean.valueOf(getFieldValue(fields, 'ApplicationInterests__c'))
                    : null;
                Integer requestedInstall = getFieldValue(fields, 'InstallmentNumberRequired__c')!= null
                    ? Integer.valueOf(getFieldValue(fields, 'InstallmentNumberRequired__c'))
                    : null;
                String clientCategory = getFieldValue(fields, 'ClientCategory__c');
                String reason = getFieldValue(fields, 'Reason__c');
                Double amountInstall = getFieldValue(fields, 'AmountToPayInInstallments__c') != null 
                    ? Double.valueOf(getFieldValue(fields, 'AmountToPayInInstallments__c'))
                    : null;
                Date expDate = getFieldValue(fields, 'DepositExpirationDate__c') == null 
                    ? System.today() + 365
                    : Date.valueOf(getFieldValue(fields, 'DepositExpirationDate__c'));
                String typeInstallmentPlans = getFieldValue(fields, 'TypeInstallmentPlan__c	');

                if(deposit && (depositPaymentMode == null || depositPaymentMode == '' || depositAmount == null)){

                    result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error','Valorizza Modalita Pagamento Acconto e Importo Acconto'));

                }else if(clientCategory != null && clientCategory.contains('SME')){

                    if(applicationInterests == false && requestedInstall > 6){

                        result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Numero rate richieste non deve essere maggiore di 6'));

                    } else if(applicationInterests == true && requestedInstall > 2){

                        result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Numero rate richieste non deve essere maggiore di 2'));

                    } else {

                        result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK','Success'));

                    }
                
                }else if(reason.contains('Disagio Rconomico') && ( amountInstall < 50 || expDate < (System.today() + 5))){

                        result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'L\'importo non deve essere inferiore a 50 ' + 
                        'o la data scadenza acconto non deve essere inferiore ai 5 giorni'));

                }else if(typeInstallmentPlans == 'Straordinario'){

                    if(caseValidationQr.getUserSessionRole() != 'CEO'){

                        result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Permessi insufficienti per selezionare il Tipo Piano Rata'));

                    }else{

                        result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK','Success'));

                    }

                } else {

                    result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK','Success'));

                }
        }
        
        
        } else if(caseType == 'Variazione Domiciliazione'){
            
            BillingProfile__c billingProfile = caseValidationQr.getBillingProfileInfo(currentCase.BillingProfile__c);
            String reason = getFieldValue(fields, 'Reason__c');


            if(billingProfile.PaymentMethod__c != 'RID' && reason != 'Domiciliazione Non Attiva'){
                
                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Per Billing Profile non domiciliati è possibile inseire soltanto \'Domiciliazione Non Attiva\''));

            }else{

                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK','Success'));

            }
        
        
        }else if (caseType == 'Blocco Sollecito/Interessi'){

            String blockType = getFieldValue(fields, 'BlockType__c');

                if(blockType.trim() != 'W' && blockType.trim() != '1'){

                    result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Tipo blocco può essere 1 o W'));

                } else {

                    result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK','Success'));

                }

        }else{

            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK','Success'));

        }

        return result;

    }

    private String validateModificaDatiContatto(String fields, String contactId) {
        String result;

        String newEmail = getFieldValue(fields, 'Email__c') != null ? getFieldValue(fields, 'Email__c') : '';
        String newMobile = getFieldValue(fields, 'Mobile__c') != null ? getFieldValue(fields, 'Mobile__c') : '';
        String newPhone = getFieldValue(fields, 'PhoneNumber__c') != null ? getFieldValue(fields, 'PhoneNumber__c') : '';
        String newPec = getFieldValue(fields, 'CertifiedEmail__c') != null ? getFieldValue(fields, 'CertifiedEmail__c') : '';
        String newFax = getFieldValue(fields, 'Fax__c') != null ? getFieldValue(fields, 'Fax__c') : '';

        HDT_QR_Contact queryHandler = new HDT_QR_Contact();
        Contact c = queryHandler.getRecordById(contactId);
        String currentEmail = c.Email != null ? c.Email : '';
        String currentMobile = c.MobilePhone != null ? c.MobilePhone : '';
        String currentPhone = c.Phone != null ? c.Phone : '';
        String currentPec = c.CertifiedEmail__c != null ? c.CertifiedEmail__c : '';
        String currentFax = c.Fax != null ? c.Fax : '';

        System.debug('validateModificaDatiContatto: current ' + c);
        System.debug('validateModificaDatiContatto: new ' + newEmail + ';' + newPhone + ';' + newMobile + ';' + newFax + ';' + newPec);

        if (newEmail.equals(currentEmail) && newMobile.equals(currentMobile) && newPhone.equals(currentPhone)
            && newPec.equals(currentPec) && newFax.equals(currentFax)) {
            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'È necessario modificare almeno un dato di contatto.'));
            return result;
        }

        Boolean noEmail = String.isBlank(newEmail) || newEmail.equalsIgnoreCase('null');
        Boolean noMobile = String.isBlank(newMobile) || newMobile.equalsIgnoreCase('null');
        Boolean noPhone = String.isBlank(newPhone) || newPhone.equalsIgnoreCase('null');

        if (noEmail && noMobile && noPhone) {
            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'È necessario inserire almeno un riferimento telefonico o un indirizzo Email.'));
        } else {
            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK', 'Success'));
        }

        // TODO: integrare i controlli definiti sulla CB Lead

        return result;
    }

    private String validateModificaDatiRecapito(String fields) {
        String result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK', 'Success'));

        String modInvioBolletta = getFieldValue(fields, 'BillSendingMethod__c');
        String emailInvioBolletta = getFieldValue(fields, 'InvoiceEmail__c');
        String pecInvioBolletta = getFieldValue(fields, 'InvoiceCertifiedEmailAddress__c');
        //String dataConsensoPec = getFieldValue(fields, 'SendCertifiedEmailConsentDate__c');
        String modInvioFatturazioneElettronica = getFieldValue(fields, 'ElectronicInvoicingMethod__c');
        String codiceUfficio = getFieldValue(fields, 'OfficeSubjectCode__c');
        String pecFatturazioneElettronica = getFieldValue(fields, 'ElectronicInvoiceCertifiedEmailAddress__c');
        String tipoXml = getFieldValue(fields, 'XMLType__c');

        if (modInvioBolletta.contains('Bolletta per e-mail') && String.isBlank(emailInvioBolletta)) {
            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'È necessario inserire una Email a cui inviare la bolletta.'));
        } else if (modInvioBolletta.equals('Invio tramite PEC') && String.isBlank(pecInvioBolletta)) {
            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'È necessario inserire un indirizzo PEC a cui inviare la bolletta.'));
        }

        if (!String.isBlank(modInvioFatturazioneElettronica)) {
            HDT_UTL_ElectronicInvoicing.HDT_WRP_ElectronicInvoicing electronicInvoicing = new HDT_UTL_ElectronicInvoicing.HDT_WRP_ElectronicInvoicing();
            electronicInvoicing.sendMode = modInvioFatturazioneElettronica;
            electronicInvoicing.billSendMode = modInvioBolletta;
            electronicInvoicing.certifiedEmail = pecFatturazioneElettronica;
            electronicInvoicing.officeCode = codiceUfficio;
            electronicInvoicing.xmlType = tipoXml;

            String electronicInvoicingError = HDT_UTL_ElectronicInvoicing.validate(electronicInvoicing);
            if (!String.isEmpty(electronicInvoicingError)) {
                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', electronicInvoicingError));
            }
        }

        return result;
    }

    private String validateModificaDatiFiscali(String fields, String accountId) {
        String result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK', 'Success'));

        String newFirstName = getFieldValue(fields, 'FirstName__c') != null ? getFieldValue(fields, 'FirstName__c') : '';
        String newLastName = getFieldValue(fields, 'LastName__c') != null ? getFieldValue(fields, 'LastName__c') : '';
        String newFiscaleCode = getFieldValue(fields, 'FiscalCode__c') != null ? getFieldValue(fields, 'FiscalCode__c') : '';
        String newVatNumber = getFieldValue(fields, 'VatNumber__c') != null ? getFieldValue(fields, 'VatNumber__c') : '';
        String newMarking = getFieldValue(fields, 'CustomerMarking__c') != null ? getFieldValue(fields, 'CustomerMarking__c') : '';

        HDT_QR_Account queryHandler = new HDT_QR_Account();
        String queryFields = 'FirstName__c,LastName__c,FiscalCode__c,VATNumber__c,CustomerMarking__c';
        Account a = queryHandler.getRecordById(accountId, queryFields);
        String currentFirstName = a.FirstName__c != null ? a.FirstName__c : '';
        String currentLastName = a.LastName__c != null ? a.LastName__c : '';
        String currentFiscaleCode = a.FiscalCode__c != null ? a.FiscalCode__c : '';
        String currentVatNumber = a.VATNumber__c != null ? a.VATNumber__c : '';
        String currentMarking = a.CustomerMarking__c != null ? a.CustomerMarking__c : '';

        if (String.isBlank(newLastName)) {
            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Il campo Cognome/Ragione sociale non può essere vuoto.'));
        } else if (newFirstName.equals(currentFirstName) && newLastName.equals(currentLastName) && newFiscaleCode.equals(currentFiscaleCode)
            && newVatNumber.equals(currentVatNumber) && newMarking.equals(currentMarking)) {
            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'È necessario modificare almeno un dato fiscale del cliente.'));
        }

        return result;
    }

    private String validateVariazioneGruppoIva(String fields, String accountId) {
        String result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK', 'Success'));

        Boolean newIsJoined = Boolean.valueOf(getFieldValue(fields, 'IsVATGroupJoined__c'));
        String newGroup = getFieldValue(fields, 'VATGroup__c') != null ? getFieldValue(fields, 'VATGroup__c') : '';
        String newStartDate = getFieldValue(fields, 'VATGroupStartDate__c') != null ? getFieldValue(fields, 'VATGroupStartDate__c') : '';
        String newEndDate = getFieldValue(fields, 'VATGroupEndDate__c') != null ? getFieldValue(fields, 'VATGroupEndDate__c') : '';

        HDT_QR_Account queryHandler = new HDT_QR_Account();
        String queryFields = 'IsVATGroupJoined__c,VATGroup__c,VATGroupStartDate__c,VATGroupEndDate__c,VATNumber__c';
        Account a = queryHandler.getRecordById(accountId, queryFields);
        Boolean currentIsJoined = a.IsVATGroupJoined__c;
        String currentGroup = a.VATGroup__c != null ? a.VATGroup__c : '';
        String currentStartDate = String.valueOf(a.VATGroupStartDate__c) != null ? String.valueOf(a.VATGroupStartDate__c) : '';
        String currentEndDate = String.valueOf(a.VATGroupEndDate__c) != null ? String.valueOf(a.VATGroupEndDate__c) : '';

        System.debug('validateVariazioneGruppoIva: current ' + currentIsJoined + ';' + currentGroup + ';' + currentStartDate + ';' + currentEndDate);
        System.debug('validateVariazioneGruppoIva: new ' + newIsJoined + ';' + newGroup + ';' + newStartDate + ';' + newEndDate);

        if (newIsJoined == currentIsJoined && newGroup.equals(currentGroup) && newStartDate.equals(currentStartDate) && newEndDate.equals(currentEndDate)) {
            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'È necessario modificare almeno un campo per poter proseguire.'));
            return result;
        }

        if (newIsJoined) {
            if (String.isBlank(newGroup)) {
                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Se si abilita il Flag Adesione Gruppo IVA è necessario valorizzare il campo Partita IVA di Gruppo.'));
            } else if (String.isBlank(newStartDate)) {
                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Se si abilita il Flag Adesione Gruppo IVA è necessario valorizzare il campo Data Inizio Piva di Gruppo.'));
            } else if (String.isBlank(newEndDate)) {
                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Se si abilita il Flag Adesione Gruppo IVA è necessario valorizzare il campo Data Fine Piva di Gruppo.'));
            } else if (!String.isBlank(newGroup) && newGroup.equals(a.VATNumber__c)) {
                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Inserire una Partita IVA di Gruppo diversa dalla Partita IVA del cliente.'));
            } else if (!String.isBlank(newStartDate) && !String.isBlank(newEndDate)) {
                Date startDate = Date.valueOf(newStartDate);
                Date endDate = Date.valueOf(newEndDate);
                if (endDate <= startDate) {
                    result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'La Data Fine Piva di Gruppo deve essere successiva alla  Data Inizio Piva di Gruppo.'));
                }
            }
        }

        return result;
    }

    public String validateInversioneContatore(String caseId, String fields, string caseType) {

        String result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK', 'Success'));

        String relatedCaseId = getFieldValue(fields, 'RelatedCase__c');

        if (relatedCaseId == null || String.isBlank(relatedCaseId) || String.isEmpty(relatedCaseId) || relatedCaseId.equalsIgnoreCase('null')) {
            return result;
        }

        Case currentCase = caseValidationQr.getCaseById(caseId);
        Case relatedCase = caseValidationQr.getCaseById(relatedCaseId);

        if (!relatedCase.CommodityFormula__c.equalsIgnoreCase(currentCase.CommodityFormula__c)) {
            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Servizio incompatibile. Case attuale: ' + currentCase.CommodityFormula__c + ', Case correlato: ' + relatedCase.CommodityFormula__c));
        } else if (relatedCase.ServicePoint__r.ServicePointCode__c.equalsIgnoreCase(currentCase.ServicePoint__r.ServicePointCode__c)) {
            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Non è possibile correlare due processi di Inversione Contatore sullo stesso impianto'));
        } 

        return result;
    }

    public String validateReclamoScritto(String fields, string recordId, Case currentCase){

        String result;

        List<ContentDocumentLink> attachedDocument = new List<ContentDocumentLink>();
        
        String delegateName = getFieldValue(fields,'DelegateName__c');

        String sendDate = getFieldValue(fields, 'SendDate__c') == null ? String.valueOf(System.today()) : getFieldValue(fields, 'SendDate__c');

        System.debug('SendDate value:' +sendDate);

        if((getFieldValue(fields, 'ComplaintEntryChannel__c') == 'Email' || getFieldValue(fields, 'ComplaintEntryChannel__c') == 'PEC')
        && (getFieldValue(fields, 'CompliantOriginEmail__c') == null || getFieldValue(fields, 'CompliantOriginEmail__c') == '')){

            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Inserire indirizzo Email provenienza reclamo'));
        }else if(delegateName != null && delegateName != ''){
            
            attachedDocument = caseValidationQr.getDocumentByCaseId(recordId); 
            
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

            String currentOpinionRequest = currentCase.OpinionRequest__c;

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

            List<ContentDocumentLink> attachedDocument = new List<ContentDocumentLink>();

            attachedDocument = caseValidationQr.getDocumentByCaseId(recordId); 

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

    public String validateVariazioni(String fields, String recordId, String caseType, String subprocess){

        String result;

        if(caseType == 'Marcatura/Uso PdR'){

            String supplyType = getFieldValue(fields, 'SupplyType__c');
            String useCategory = getFieldValue(fields, 'UseCategory__c');
            String servicePointType = getFieldValue(fields, 'ServicePointType__c');

            if(HDT_UTL_Variations.consistencyCheck(recordId, useCategory, supplyType, servicePointType)){

                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK','Success'));

            } else {

                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error','Controllo di coerenza non superato, correggere i dati'));

            }
        
        }else if(caseType == 'BP/CA - errata categoria'){

            String billingProblem = getFieldValue(fields, 'BillingProblem__c');
            String dlNote = getFieldValue(fields, 'Note__c');
            String customerAggreement = getFieldValue(fields, 'CustomerPaymentAgreements__c');

            if(billingProblem == 'Si' 
            && (
                (customerAggreement == null || customerAggreement == '')
                )
            ){

                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error','Valorizzare: Accordi con il Cliente'));

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

        } else if(caseType == 'Fiscale'){

            if(subprocess != 'IVA - Errata applicazione' && subprocess != 'Accise - Errata applicazione'){

                List<ContentDocumentLink> attachedDocument = new List<ContentDocumentLink>();

                attachedDocument = caseValidationQr.getDocumentByCaseId(recordId);
                
                if(attachedDocument.size() == 0){

                    result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error','Necessario inserire allegato'));

                } else{

                    result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK','Success'));

                }

            } else {

                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK','Success'));

            }

        }else if(caseType == 'Modifica Tariffa Residente/Non Residente'){

            Date residenceChangeDate = Date.valueOf(getFieldValue(fields, 'ResidenceChangeDate__c'));

            if(HDT_UTL_Variations.modifyRate(recordId)){

                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK','Success'));

            } else {

                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error','Vi sono più forniture con Residente a SI'));

            }

            if(residenceChangeDate < System.today()){

                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error','La data non può essere nel passato'));
            
            } else {

                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK','Success'));

            }
 
        } else if(caseType == 'Condizioni Contrattuali Errate'){ 

            String billingProblem = getFieldValue(fields, 'BillingProblem__c');
            String customerAggreement = getFieldValue(fields, 'CustomerPaymentAgreements__c');
        
            if(billingProblem == 'Si' && (customerAggreement == null || customerAggreement == '')){

                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error','Valorizzare Accordi con il Cliente'));

            } else{

                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK','Success'));
                
            }

        }else if(caseType == 'Mancata Telelettura/lettura'){

            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK','Success'));

        }else if(caseType == 'Cambio contatore non registrato'){

            String reading = getFieldValue(fields, 'Reading__c');

            if(!reading.isNumeric()){

                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error','Valore inserito non corretto'));

            } else {

                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK','Success'));

            }

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

    public String validateAnnullamento(String fields){

        Date effectiveDate = Date.valueOf(getFieldValue(fields, 'EffectiveDate__c'));
        Date todayDate = System.today();

        String result;

        if(todayDate.day() > 10 && effectiveDate > todayDate.addMonths(2).toStartOfMonth().addDays(-1)){

            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error','La data decorrenza non è coerente con la data inserimento'));

        } else {

            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK','Success'));

        }

        return result;

    }

    // Validazione campi Billing Profile per processo Unificazione/Separazione CA
    private String validateUnificazioneSeparazione(String fields) {

        return validateModificaDatiRecapito(fields);

    }

    private String validateVotiveModena(String fields){

        String billingProfile = getFieldValue(fields, 'BillingProfile__c');
        String reason = getFieldValue(fields, 'Reason__c');
        String result;

        if(reason == 'Errata Emissione' && (billingProfile == null || billingProfile == '')){

            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error','Necessario Valorizzare Billing Profile'));

        } else {

            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK','Success'));

        }

        return result;

    }

    private String validateVerificaTitolarita(Case currentCase) {

        List<ContentDocumentLink> attachedDocument = caseValidationQr.getDocumentByCaseId(currentCase.Id);

        if(attachedDocument.size() == 0){
            return JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Necessario inserire allegato'));
        }
            
        return JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK', 'Success'));
    }

    private String validateGestioneBonusSociale(Case currentCase, String fields) {

        List<ContentDocumentLink> attachedDocument = caseValidationQr.getDocumentByCaseId(currentCase.Id);
        String reason = getFieldValue(fields, 'Reason__c');

        if(reason != null && reason.equals('Permanenza condizioni di disagio') && attachedDocument.size() == 0){
            return JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Necessario allegare autocertificazione del cliente.'));
        }
            
        return JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK', 'Success'));
    }


    public String getFieldValue(String fields, String fieldToGet){
        Map<String, Object> fieldsMap = (Map<String, Object>) JSON.deserializeUntyped(fields);
        return String.valueOf(fieldsMap.get(fieldToGet));
    }

}