/**
 * @description       : 
 * @author            : Giacinto Florio
 * @group             : 
 * @last modified on  : 09-07-2022
 * @last modified by  : Giacinto Florio
**/
@SuppressWarnings('PMD.CyclomaticComplexity')
public inherited sharing class HDT_UTL_CaseValidations implements HDT_UTL_CaseValidationInterface {

    HDT_QR_CaseValidations caseValidationQr = new HDT_QR_CaseValidations();

    /*
    * @Author: Salvatore A. Sarà 19/10/2021
    * Risoluzione "Debug Should Use Logging Level"
    * Risoluzione "Avoid debug statements since they impact on performance"
    */
    @SuppressWarnings('PMD.AvoidDebugStatements')
    public String validate(String fields, String recordId){

        Case currentCase = caseValidationQr.getCaseById(recordId);
        System.debug(LoggingLevel.DEBUG,'HDT_UTL_CaseValidations: validating Case ' + currentCase);

        String caseType = currentCase.Type;
        String subprocess = currentCase.Subprocess__c;
        String cluster = currentCase.Cluster__c;

        String result;

        if(caseType == 'Reclamo Scritto/Rich. Info' || caseType == 'Richiesta Parere'){

            result = validateReclamoScritto(fields, recordId, currentCase);

        } else if(caseType == 'Doppi Pagamenti/Incassi' || caseType == 'Piano Rateizzazione' || caseType == 'Richiesta Domiciliazione'
        || caseType == 'Variazione Domiciliazione' || caseType == 'Rimborso' || caseType == 'Attivazione Click&Pay' ||
        caseType == 'Storno Rateizzazione' || caseType == 'Blocco Sollecito/Interessi' || caseType == 'Paperless'){

            result = validatePagamenti(fields, caseType, currentCase);


        } else if (caseType == 'Variazione Anagrafica Cliente') {
            if (currentCase.Subprocess__c == 'Modifica Dati di Contatto') {
                result = validateModificaDatiContatto(fields, currentCase);
            } else if (currentCase.Subprocess__c == 'Modifica Dati di Recapito') {
                result = validateModificaDatiRecapito(fields, currentCase);
            } else if (currentCase.Subprocess__c == 'Modifica Dati Fiscali') {
                result = validateModificaDatiFiscali(fields, currentCase);
            } else if (currentCase.Subprocess__c == 'Variazione Gruppo IVA') {
                result = validateVariazioneGruppoIva(fields, currentCase.AccountId);
            }
        } else if (caseType == 'Esercizio Diritti Privacy') {
            result = validateEsercizioDirittiPrivacy(fields);
        } else if (caseType == 'Modifica Privacy') {
            result = validateModificaPrivacy(fields, recordId);
        } else if (caseType == 'Inversione del Contatore') {
            result = validateInversioneContatore(recordId, fields, caseType);
        } else if (caseType == 'Gestione Bonus Sociale') {
            result = validateGestioneBonusSociale(currentCase, fields);
        } else if(caseType == 'Gestione Disalimentabilità' || caseType == 'Riattivazione Fornitura'){

            result = validateMorosita(fields, recordId, caseType, currentCase);

        } else if(caseType == 'Marcatura/Uso PdR' 
        || caseType == 'Condizioni Contrattuali Errate' 
        || caseType == 'BP/CA - errata categoria'
        || caseType == 'Modifica/Azzeramento Consumo Annuo'
        || caseType == 'Modifica Tariffa Residente/Non Residente'
        || caseType == 'Modifica Layout di dettaglio'
        || caseType == 'Mancata Telelettura/lettura'
        || caseType == 'Cambio contatore non registrato'
        || caseType == 'Fiscale'){

            System.debug(LoggingLevel.DEBUG,'Inside Variazioni Validations');

            result = validateVariazioni(fields,recordId,caseType, subprocess, currentCase);

        } else if(caseType == 'Chiusura Contatore'){

            result = validateDisattivazioni(fields);

        } else if(caseType == 'Contratto Non Richiesto'){

            result = validateAnnullamento(fields);

        } else if(caseType == 'Unificazione/Separazione BP-CA-Bolletta') {

            result = validateUnificazioneSeparazione(fields, currentCase);

        }else if(caseType == 'Votive Modena Contestazione Fattura' || caseType.equalsIgnoreCase('Spostamento Votive Modena')){

            result= validateVotiveModena(fields, caseType);
        } else if (caseType == 'Verifica Titolarità POD/PDR') {

            result = validateVerificaTitolarita(currentCase);

        /*} else if (caseType == 'Nuovo Impianto - Aggiunta Attacco'){

            result = validateVariazioni(fields, caseType)*/
        
        } else if(caseType == 'Voltura Tecnica'){

            result = validateVolturaTecnica(fields);
 
        }else if(currentCase.Cluster__c.equalsIgnoreCase('Preventivi'))
        {
            result = validatePreventivi(fields, currentCase);
        
        }else if(caseType == 'Proroga Conn Temp')
        {
            Date currentEndDate = currentCase.TemporaryConnectionEndDate__c;
            result = validateEndDate(fields, currentEndDate, currentCase);
        
        }else if(caseType == 'Promessa di Pagamento Ente')
        {
            result = validatePromessaDiPagamentoENte(currentCase);
           
        }else if(cluster.equalsIgnoreCase('Attivazioni'))
        {
            result = validateAttivazioniPostSales(fields);
        }else if(caseType=='Cessazione' || caseType=='Cessazione post accertamento')   
        {
            result = cessazioneValidate(currentCase, fields);
        }else if(caseType=='Errore di Fatturazione'){
            result = validateErroreFatturazione(currentCase, fields);
        }else {

            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK', 'Success'));

        }

        return result;

    }

    private String cessazioneValidate(Case currCase, String fields){
        //system.debug('init validate');
        String result = '';
        HDT_UTL_CityDataTariValidation cityDataTariValidation = new HDT_UTL_CityDataTariValidation();
        if( getFieldValue(fields, 'EffectiveDate__c') > getFieldValue(fields, 'DeclarationDate__c') || getFieldValue(fields, 'EffectiveDate__c') > String.valueOf(Date.today())) {
            //system.debug('Attenzione! La data di decorrenza non può essere maggiore della data dichiarazione e non può essere maggiore della data odierna');
            return JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Attenzione! La data di decorrenza non può essere maggiore della data dichiarazione e non può essere maggiore della data odierna'));
        }
        //system.debug('preClass');
        result = cityDataTariValidation.validate(fields, currCase.Id);
        //system.debug('end validate');
        return result == null ? JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK', 'Success')) : result;
    }
    
    /*
    * @Author: Salvatore A. Sarà 19/10/2021
    * Risoluzione "Debug Should Use Logging Level"
    * Risoluzione "Avoid debug statements since they impact on performance"
    */
    @SuppressWarnings('PMD.AvoidDebugStatements')
    public String validatePagamenti(String fields, string caseType, Case currentCase){

        String result;

        System.debug(LoggingLevel.DEBUG,caseType);

        System.debug(LoggingLevel.DEBUG,getFieldValue(fields, 'Type'));

        if(caseType == 'Piano Rateizzazione'){
            
            String reason = getFieldValue(fields, 'Reason__c');

            if(String.isNotBlank(reason) && reason.equals('Assistenza sociale (ente)')){
                List<PermissionSetAssignment> psa = [SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId= :UserInfo.getUserId() AND PermissionSet.Name = 'HDT_AssistenzaSocialeEnte'];
                if(psa.size()==0) return JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Utente non abilitato ad Assistenza sociale (ente)'));
                String depositPaymentMode = getFieldValue(fields, 'DepositPaymentMode__c');
                if(String.isBlank(result) && String.isNotBlank(depositPaymentMode) && depositPaymentMode.equals('Promessa di pagamento')) {
                    List<PermissionSetAssignment> psas = [SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId= :UserInfo.getUserId() AND PermissionSet.Name = 'HDT_PromessaPagamentoEnte'];
                    if(psas.size()==0) return JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Utente non abilitato a promessa di pagamento'));
                }
            }     

            Boolean attachmentManagement = (getFieldValue(fields, 'AttachmentManagement__c') != null && getFieldValue(fields, 'AttachmentManagement__c') != '')
                ? Boolean.valueOf(getFieldValue(fields, 'AttachmentManagement__c'))
                : null;

            if(attachmentManagement != null ){
                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK', 'Success'));
                /* if(attachmentManagement){
                    List<ContentDocumentLink> attachedDocument = caseValidationQr.getDocumentByCaseId(currentCase.Id);
                    if(attachedDocument.size() == 0){
                        result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Necessario inserire allegato'));
                    }else{
                        result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK', 'Success'));
                    }
                }else{
                    result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK', 'Success'));
                } */

            } else {
            

                Boolean deposit = getFieldValue(fields, 'Deposit__c') != null 
                    ? Boolean.valueOf(getFieldValue(fields, 'Deposit__c'))
                    : null;
                String depositPaymentMode = getFieldValue(fields, 'DepositPaymentMode__c');
                Decimal depositAmount = getFieldValue(fields, 'DepositAmount__c') != null && getFieldValue(fields, 'DepositAmount__c') != ''
                    ? Decimal.valueOf(getFieldValue(fields, 'DepositAmount__c'))
                    : null;
                Boolean applicationInterests = getFieldValue(fields, 'ApplicationInterests__c') != null
                    ? Boolean.valueOf(getFieldValue(fields, 'ApplicationInterests__c'))
                    : null;
                Integer requestedInstall = getFieldValue(fields, 'InstallmentNumberRequired__c')!= null && getFieldValue(fields, 'InstallmentNumberRequired__c')!= ''
                    ? Integer.valueOf(getFieldValue(fields, 'InstallmentNumberRequired__c'))
                    : null;
                String clientCategory = getFieldValue(fields, 'ClientCategory__c');
                /*
                * @Author: Salvatore A. Sarà 19/10/2021
                * Risoluzione "Local variable is declared and-or assigned but not used"
                */
                // String reason = getFieldValue(fields, 'Reason__c');
                String typeInstallmentPlans = getFieldValue(fields, 'TypeInstallmentPlan__c	');
                String sendPaperlessMode = getFieldValue(fields, 'SendPaperlessCodeMode__c');

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
                
                }else if(typeInstallmentPlans == 'Straordinario'){

                    if(caseValidationQr.getUserSessionRole() != 'CEO'){

                        result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Permessi insufficienti per selezionare il Tipo Piano Rata'));

                    }else{

                        result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK','Success'));

                    }

                }else if(depositPaymentMode!= null && depositPaymentMode == 'Paperless' && (sendPaperlessMode == null || sendPaperlessMode == '')){

                    result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error','Valorizza Modalita invio Codice Paperless'));
                
                }else if(sendPaperlessMode!= null && sendPaperlessMode.containsIgnoreCase('SMS') && (currentCase.PhoneNumber__c == null || currentCase.PhoneNumber__c == '')){

                    result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Impossibile selezionare \"' + sendPaperlessMode + '\" se Recapito Telefonico non valorizzato'));

                }else if(sendPaperlessMode!= null && sendPaperlessMode.containsIgnoreCase('Email') && (currentCase.Email__c == null || currentCase.Email__c == '')){

                    result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Impossibile selezionare \"'+ sendPaperlessMode + '\" se Email non valorizzata'));

                }else if(reason != null && reason.equalsIgnoreCase('Bolletta Fuga H2O')){
                    List<Case> caseToCheck;
                    caseToCheck = caseValidationQr.getCaseByTypeBillingProfile('Consumo Anomalo Idrico',currentCase.AccountId,currentCase.ContractAccountCode__c);
                    if(caseToCheck != null && caseToCheck.isEmpty()){
                        result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Non è presente alcun processo di Consumo Anomalo Idrico in corso per il cliente'));
                    }else {
                        result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK','Success'));
                    }
                }else if( reason != null && reason.equalsIgnoreCase('Malfunzione Gruppo di misura')){
                    List<Case> caseToCheck;
                    caseToCheck = caseValidationQr.getCaseByTypeBillingProfile('Verifica GDM',currentCase.AccountId,currentCase.ContractAccountCode__c);
                    if(caseToCheck != null && caseToCheck.isEmpty()){
                        result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Non è presente alcun processo di Verifica GdM in corso per il cliente'));
                    }else {
                        result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK','Success'));
                    }
                } 
                 else {

                    result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK','Success'));

                }
                
            }        
        }else if (caseType == 'Blocco Sollecito/Interessi'){

            String blockType = getFieldValue(fields, 'BlockType__c');

                if(!(blockType.containsIgnoreCase('W')) && !(blockType.containsIgnoreCase('1'))){

                    result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Tipo blocco può essere 1 o W'));

                } else {

                    result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK','Success'));

                }

        }else if(caseType == 'Paperless'){

            String sendMode = getFieldValue(fields, 'SendPaperlessCodeMode__c');

            if(sendMode.containsIgnoreCase('SMS') && (currentCase.PhoneNumber__c == null || currentCase.PhoneNumber__c == '')){

                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Impossibile selezionare \"SMS\" se Recapito Telefonico non valorizzato'));

            } else if(sendMode.containsIgnoreCase('Email') && (currentCase.Email__c == null || currentCase.Email__c == '')){

                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Impossibile selezionare \"Email\" se Email non valorizzata'));

            } else {

                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK','Success'));

            }
        }else if(caseType == 'Richiesta Domiciliazione' || caseType == 'Attivazione Click&Pay' || caseType == 'Variazione Domiciliazione')
        {
            String fiscalCode =  getFieldValue(fields, 'BankAccountSignatoryFiscalCode__c');
            String lastName = getFieldValue(fields, 'BankAccountSignatoryLastName__c');
            String firstName = getFieldValue(fields, 'BankAccountSignatoryFirstName__c');
            String beneficiaryType = getFieldValue(fields, 'AccountholderTypeBeneficiary__c');
            BillingProfile__c billingProfile = caseValidationQr.getBillingProfileInfo(currentCase.BillingProfile__c);
            String reason = getFieldValue(fields, 'Reason__c');
            if(billingProfile.PaymentMethod__c != 'RID' && reason != null && !(reason.equalsIgnoreCase('Domiciliazione non attiva')) && caseType == 'Variazione Domiciliazione'){
                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Per Billing Profile non domiciliati è possibile inseire soltanto \'Domiciliazione Non Attiva\''));
            }
            if(!String.isEmpty(fiscalCode)){
                string outcome = validateFiscalCode(fiscalCode);
                if(!String.isEmpty(outcome))
                {
                    result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', outcome));
                }
                if(!HDT_UTL_CalculateFiscalCode.checkFirstLastNameFromFiscalCode(fiscalCode, firstName, lastName))
                {
                    result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Codice Fiscale non coerente con i dati inseriti'));
                }
                else
                {
                    result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK','Success'));
                }
            }
            else if(!String.isEmpty(beneficiaryType))
            {
                System.debug(LoggingLevel.DEBUG,'Payments_BeneficiaryType ' + beneficiaryType);
                System.debug(LoggingLevel.DEBUG,'Payments_ClientCategory ' + currentCase.ClientCategory__c);
                if(beneficiaryType.equalsIgnoreCase('Rappresentante Legale') && 
                    (currentCase.ClientCategory__c.equalsIgnoreCase('Famiglie')
                    || currentCase.ClientCategory__c.equalsIgnoreCase('Parti Comuni')
                    || currentCase.ClientCategory__c.equalsIgnoreCase('Ditta Individuale')
                    )
                )
                {
                    result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Impossibile selezionare la tipologia \"'
                    + beneficiaryType +'\" per la categoria \"'
                    + currentCase.ClientCategory__c+'\"'));
                }
                else if(beneficiaryType.equalsIgnoreCase('Stesso Sottoscrittore') 
                && !currentCase.ClientCategory__c.equalsIgnoreCase('Famiglie')
                && !currentCase.ClientCategory__c.equalsIgnoreCase('Parti Comuni')
                && !currentCase.ClientCategory__c.equalsIgnoreCase('Ditta Individuale')
                )
                {
                    result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Impossibile selezionare la tipologia \"'
                    + beneficiaryType +'\" per la categoria \"'
                    + currentCase.ClientCategory__c+'\"'));
                //STESSO SOTTOSCRITTORE  per non famiglie, Parti Comuni o ditta individuale
                //Rappresentante Legale per Famiglie, Parti Comuni o ditta individuale
                } else {
                    result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK','Success'));
                }
            }else{
            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK','Success'));
            }
        }
        else if(caseType == 'Rimborso')
        {
            String beneficiaryType = getFieldValue(fields,'AccountholderTypeBeneficiary__c');
            String beneficiary = getFieldValue(fields,'BeneficiaryAccount__c');
            if(beneficiaryType != null && beneficiaryType != '' 
            && (beneficiaryType.equalsIgnoreCase('Beneficiario Alternativo') || beneficiaryType.equalsIgnoreCase('Erede')) 
            && (beneficiary == null || beneficiary == ''))
            {
                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Per "Erede" o "Beneficiario Alternativo" è necessario indicare il "Beneficiario"'));
            }
            else 
            {
                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK','Success'));
            }
        }
        else
        {
            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK','Success'));
        }

        return result;

    }

    /*
    * @Author: Salvatore A. Sarà 19/10/2021
    * Risoluzione "Debug Should Use Logging Level"
    * Risoluzione "Avoid debug statements since they impact on performance"
    */
    @SuppressWarnings('PMD.AvoidDebugStatements')
    private String validateModificaDatiContatto(String fields, Case currentCase) {

        String result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK', 'Success'));

        String newEmail = getFieldValue(fields, 'Email__c') != null ? getFieldValue(fields, 'Email__c') : '';
        String newMobile = getFieldValue(fields, 'Mobile__c') != null ? getFieldValue(fields, 'Mobile__c') : '';
        String newPhone = getFieldValue(fields, 'PhoneNumber__c') != null ? getFieldValue(fields, 'PhoneNumber__c') : '';
        String newPec = getFieldValue(fields, 'CertifiedEmail__c') != null ? getFieldValue(fields, 'CertifiedEmail__c') : '';
        String newFax = getFieldValue(fields, 'Fax__c') != null ? getFieldValue(fields, 'Fax__c') : '';
        String newMarking = getFieldValue(fields, 'CustomerMarking__c') != null ? getFieldValue(fields, 'CustomerMarking__c') : '';

        HDT_QR_Contact queryHandler = new HDT_QR_Contact();
        Contact c = queryHandler.getRecordById(currentCase.ContactId);
        HDT_QR_Account accountQueryHandler = new HDT_QR_Account();
        String queryFields = 'FirstName__c,LastName__c,FiscalCode__c,VATNumber__c,CustomerMarking__c';
        Account a = accountQueryHandler.getRecordById(currentCase.AccountId, queryFields);

        String currentEmail = c.Email != null ? c.Email : '';
        String currentMobile = c.MobilePhone != null ? c.MobilePhone : '';
        String currentPhone = c.Phone != null ? c.Phone : '';
        String currentPec = c.CertifiedEmail__c != null ? c.CertifiedEmail__c : '';
        String currentFax = c.Fax != null ? c.Fax : '';
        String currentMarking = a.CustomerMarking__c != null ? a.CustomerMarking__c : '';
        String currentFiscalCode = a.FiscalCode__c != null ? a.FiscalCode__c : '';
        String currentVatNumber = a.VATNumber__c != null ? a.VATNumber__c : '';

        System.debug(LoggingLevel.DEBUG,'validateModificaDatiContatto: current ' + c);

        if (String.isBlank(newMarking)) {
            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Valorizzare la Marcatura del cliente.'));
            return result;
        }

        if (newEmail.equals(currentEmail) && newMobile.equals(currentMobile) && newPhone.equals(currentPhone) && newMarking.equals(currentMarking)
            && newPec.equals(currentPec) && newFax.equals(currentFax)) {
            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'È necessario modificare almeno un campo per poter proseguire.'));
            return result;
        }

        if (String.isNotBlank(newMarking) && !newMarking.equals(currentMarking)) {
            String marking = newMarking;
            if ((marking.contains('Persona fisica') || marking.contains('Condominio') || marking.contains('Parti comuni')) && String.isBlank(currentFiscalCode)) {
                return JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Il campo Codice Fiscale è vuoto ed è obbligatorio per poter modificare la marcatura in: ' + marking));
            }

            if ((marking.contains('Azienda') || marking.contains('Ditta individuale')) && String.isBlank(currentVatNumber)) {
                return JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Il campo Partita IVA è vuoto ed è obbligatorio per poter modificare la marcatura in: ' + marking));
            }

            // Marcature che prevedono CF alfanumerico e PIVA blank.
            if (marking.contains('Persona fisica') || marking.contains('Parti comuni')) {
                String fiscalCodeValidation = validateFiscalCode(currentFiscalCode);
                if (String.isNotBlank(fiscalCodeValidation)) {
                    return JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Il campo Codice Fiscale deve essere alfanumerico per poter modificare la marcatura in: ' + marking));
                }

                if (String.isNotBlank(currentVatNumber)) {
                    return JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Il campo Partita IVA deve essere vuoto per poter modificare la marcatura in: ' + marking));
                }
            }
            // Ditta individuale prevede CF alfanumerico ma PIVA valorizzata.
            else if (marking.contains('Ditta individuale')) {
                String fiscalCodeValidation = validateFiscalCode(currentFiscalCode);
                if (String.isNotBlank(fiscalCodeValidation)) {
                    return JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Il campo Codice Fiscale deve essere alfanumerico per poter modificare la marcatura in: ' + marking));
                }
            }
            // Marcature che prevedono CF numerico
            else if (marking.contains('Azienda') || marking.contains('Condominio')) {
                String fiscalCodeValidation = validateNumericFiscalCode(currentFiscalCode);
                if (String.isNotBlank(fiscalCodeValidation)) {
                    return JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Il campo Codice Fiscale deve essere numerico per poter modificare la marcatura in: ' + marking));
                }
            }
            // Associazione prevede CF numerico ma PIVA blank.
            else if (marking.contains('Associazione')) {
                String fiscalCodeValidation = validateNumericFiscalCode(currentFiscalCode);
                if (String.isNotBlank(fiscalCodeValidation)) {
                    return JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Il campo Codice Fiscale deve essere numerico per poter modificare la marcatura in: ' + marking));
                }

                if (String.isNotBlank(currentVatNumber)) {
                    return JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Il campo Partita IVA deve essere vuoto per poter modificare la marcatura in: ' + marking));
                }
            }

            return result;
        }

        Boolean noEmail = String.isBlank(newEmail) || newEmail.equalsIgnoreCase('null');
        Boolean noMobile = String.isBlank(newMobile) || newMobile.equalsIgnoreCase('null');
        Boolean noPhone = String.isBlank(newPhone) || newPhone.equalsIgnoreCase('null');

        if (noEmail && noMobile && noPhone) {
            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'È necessario inserire almeno un riferimento telefonico o un indirizzo Email.'));
            return result;
        }

        if (String.isNotBlank(newMobile)) {
            String mobileValidationError = HDT_UTL_PhoneNumbers.validateMobileNumber(newMobile);
            if (String.isNotBlank(mobileValidationError)) {
                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', mobileValidationError));
                return result;
            }
        }

        if (String.isNotBlank(newPhone)) {
            String phoneValidationError = HDT_UTL_PhoneNumbers.validatePhoneNumber(newPhone);
            if (String.isNotBlank(phoneValidationError)) {
                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', phoneValidationError));
                return result;
            }
        }

        return result;
    }

    private String validateModificaDatiRecapito(String fields, Case currentCase) {
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
            electronicInvoicing.accountRecordTypeName = currentCase.Account.RecordType.DeveloperName;

            String electronicInvoicingError = HDT_UTL_ElectronicInvoicing.validate(electronicInvoicing);
            if (!String.isEmpty(electronicInvoicingError)) {
                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', electronicInvoicingError));
            }
        }

        return result;
    }

    private String validateModificaDatiFiscali(String fields, Case currentCase) {
        String result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK', 'Success'));

        String newFirstName = getFieldValue(fields, 'FirstName__c') != null ? getFieldValue(fields, 'FirstName__c') : '';
        String newLastName = getFieldValue(fields, 'LastName__c') != null ? getFieldValue(fields, 'LastName__c') : '';
        String newFiscalCode = getFieldValue(fields, 'FiscalCode__c') != null ? getFieldValue(fields, 'FiscalCode__c') : '';
        String newVatNumber = getFieldValue(fields, 'VatNumber__c') != null ? getFieldValue(fields, 'VatNumber__c') : '';
        // Il nuovo indirizzo non è presente nel json, ma è già committato sul Case.
        String newAddress = currentCase.AlternativeAddress__c;
        String marking = currentCase.Account.CustomerMarking__c;

        HDT_QR_Account queryHandler = new HDT_QR_Account();
        String queryFields = 'FirstName__c,LastName__c,BillingAddressFormula__c,FiscalCode__c,VATNumber__c,CustomerMarking__c';
        Account a = queryHandler.getRecordById(currentCase.AccountId, queryFields);
        String currentFirstName = a.FirstName__c != null ? a.FirstName__c : '';
        String currentLastName = a.LastName__c != null ? a.LastName__c : '';
        String currentFiscalCode = a.FiscalCode__c != null ? a.FiscalCode__c : '';
        String currentVatNumber = a.VATNumber__c != null ? a.VATNumber__c : '';
        String currentAddress = a.BillingAddressFormula__c != null ? a.BillingAddressFormula__c : '';

        if (String.isBlank(newLastName)) {
            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Il campo Cognome/Ragione sociale non può essere vuoto.'));
            return result;
        }
        
        if (newFirstName.equals(currentFirstName) && newLastName.equals(currentLastName) && newFiscalCode.equals(currentFiscalCode)
            && newVatNumber.equals(currentVatNumber) && newAddress.equals(currentAddress)) {
            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'È necessario modificare almeno un dato fiscale del cliente.'));
            return result;
        }

        if (marking != null) {
            if ((marking.contains('Persona fisica') || marking.contains('Condominio') || marking.contains('Parti comuni')) && String.isBlank(newFiscalCode)) {
                return JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Il campo Codice Fiscale è obbligatorio per la marcatura ' + marking));
            }

            if ((marking.contains('Azienda') || marking.contains('Ditta individuale')) && String.isBlank(newVatNumber)) {
                return JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Il campo Partita IVA è obbligatorio per la marcatura ' + marking));
            }

            // Marcature che prevedono CF alfanumerico e PIVA blank.
            if (marking.contains('Persona fisica') || marking.contains('Parti comuni')) {
                String fiscalCodeValidation = validateFiscalCodeAgainstOld(currentFiscalCode, newFiscalCode);
                if (String.isNotBlank(fiscalCodeValidation)) {
                    return JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', fiscalCodeValidation));
                }

                if (String.isNotBlank(newVatNumber)) {
                    return JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Impossibile inserire una Partita IVA per la marcatura ' + marking));
                }
            }
            // Ditta individuale prevede CF alfanumerico ma PIVA valorizzata.
            else if (marking.contains('Ditta individuale')) {
                String fiscalCodeValidation = validateFiscalCodeAgainstOld(currentFiscalCode, newFiscalCode);
                if (String.isNotBlank(fiscalCodeValidation)) {
                    return JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', fiscalCodeValidation));
                }
            }
            // Marcature che prevedono CF numerico
            else if (marking.contains('Azienda') || marking.contains('Condominio')) {
                String fiscalCodeValidation = validateNumericFiscalCode(newFiscalCode);
                if (String.isNotBlank(fiscalCodeValidation)) {
                    return JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', fiscalCodeValidation));
                }
            }
            // Associazione prevede CF numerico ma PIVA blank.
            else if (marking.contains('Associazione')) {
                String fiscalCodeValidation = validateNumericFiscalCode(newFiscalCode);
                if (String.isNotBlank(fiscalCodeValidation)) {
                    return JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', fiscalCodeValidation));
                }

                if (String.isNotBlank(newVatNumber)) {
                    return JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Impossibile inserire una Partita IVA per la marcatura ' + marking));
                }
            }
        }
        
        return result;
    }

    /*
    * @Author: Salvatore A. Sarà 19/10/2021
    * Risoluzione "Debug Should Use Logging Level"
    * Risoluzione "Avoid debug statements since they impact on performance"
    */
    @SuppressWarnings('PMD.AvoidDebugStatements')
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

        System.debug(LoggingLevel.DEBUG,'validateVariazioneGruppoIva: current ' + currentIsJoined + ';' + currentGroup + ';' + currentStartDate + ';' + currentEndDate);
        System.debug(LoggingLevel.DEBUG,'validateVariazioneGruppoIva: new ' + newIsJoined + ';' + newGroup + ';' + newStartDate + ';' + newEndDate);

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

    public String validateEsercizioDirittiPrivacy(String fields) {

        String result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK', 'Success'));
        Date requestDate = Date.valueOf(getFieldValue(fields, 'WrittenReceiptRequestDate__c'));

        if(requestDate > Date.today()){
            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error','La data inserita non può essere nel futuro.'));
        }

        return result;
    }

    public String validateInversioneContatore(String caseId, String fields, String caseType) {

        String result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK', 'Success'));

        String relatedCaseId = getFieldValue(fields, 'RelatedCase__c');
        String customerSelfReading = getFieldValue(fields, 'CustomerSelfReading__c');
        String readingDate = getFieldValue(fields, 'ReadingDate__c');

        Case currentCase = caseValidationQr.getCaseById(caseId);
        
        if('Acqua'.equals(currentCase.CommodityFormula__c) && !String.isBlank(customerSelfReading) && (readingDate == null || String.isBlank(readingDate) || String.isEmpty(readingDate) || readingDate.equalsIgnoreCase('null'))){
            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Inserire la data di lettura nell\'apposito campo.'));
        }
        
        if (relatedCaseId == null || String.isBlank(relatedCaseId) || String.isEmpty(relatedCaseId) || relatedCaseId.equalsIgnoreCase('null')) {
            return result;
        }
        
        Case relatedCase = caseValidationQr.getCaseById(relatedCaseId);

        if (!relatedCase.CommodityFormula__c.equalsIgnoreCase(currentCase.CommodityFormula__c)) {
            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Servizio incompatibile. Case attuale: ' + currentCase.CommodityFormula__c + ', Case correlato: ' + relatedCase.CommodityFormula__c));
        } else if (relatedCase.ServicePoint__r.ServicePointCode__c.equalsIgnoreCase(currentCase.ServicePoint__r.ServicePointCode__c)) {
            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Non è possibile correlare due processi di Inversione Contatore sullo stesso impianto'));
        } 
        
        return result;
    }

    /*
    * @Author: Salvatore A. Sarà 19/10/2021
    * Risoluzione "Debug Should Use Logging Level"
    * Risoluzione "Avoid debug statements since they impact on performance"
    */
    @SuppressWarnings('PMD.AvoidDebugStatements')
    public String validateReclamoScritto(String fields, string recordId, Case currentCase){

        String result;

        List<ContentDocumentLink> attachedDocument = new List<ContentDocumentLink>();
        
        String delegateName = getFieldValue(fields,'DelegateName__c');

        String sendDate = getFieldValue(fields, 'SendDate__c') == null ? String.valueOf(System.today()) : getFieldValue(fields, 'SendDate__c');

        System.debug(LoggingLevel.DEBUG,'SendDate value:' +sendDate);

        if((getFieldValue(fields, 'ComplaintEntryChannel__c') == 'Email' || getFieldValue(fields, 'ComplaintEntryChannel__c') == 'PEC')
        && (getFieldValue(fields, 'CompliantOriginEmail__c') == null || getFieldValue(fields, 'CompliantOriginEmail__c') == '')){

            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Inserire indirizzo Email provenienza reclamo'));
        /*}else if(delegateName != null && delegateName != ''){
            
            attachedDocument = caseValidationQr.getDocumentByCaseId(recordId); 
            
            if(attachedDocument.size() == 0){
            
                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Necessario inserire allegato'));
                
            }else{
            
                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK', 'Success'));
                 
            }
        */
        }else if((getFieldValue(fields,'FithLevelComplaintClassification__c') == null || getFieldValue(fields,'FithLevelComplaintClassification__c') == '')
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

        System.debug(LoggingLevel.DEBUG,'Result: '+result);

        return result;

    }

    /*
    * @Author: Salvatore A. Sarà 19/10/2021
    * Risoluzione "Debug Should Use Logging Level"
    * Risoluzione "Avoid debug statements since they impact on performance"
    */
    @SuppressWarnings('PMD.AvoidDebugStatements')
    public String validateMorosita(String fields, string recordId, String caseType, Case currentCase){

        String result;

        String disconnectable = getFieldValue(fields, 'Disconnectable__c');

        String disconnectableCategory = getFieldValue(fields, 'DisconnectibilityType__c');

        String phonePesse = getFieldValue(fields, 'MobilePhoneNoticePesse__c');
        
        String autocertAsl = getFieldValue(fields, 'SelfCertificationAcquisitionAsl__c');

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

            if(disconnectable != null && disconnectable != ''){
                System.debug(LoggingLevel.DEBUG,'DisconnectableLWC -> ' + disconnectable);
                System.debug(LoggingLevel.DEBUG,'DisconnectableRecord -> ' + currentCase.Disconnectable__c);
                if(disconnectable == currentCase.Disconnectable__c){
                    result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Necessario modificare il campo Disalimentabile'));
                }else if(disconnectable.equalsIgnoreCase('No')
                && ((disconnectableCategory == null || disconnectableCategory == '') 
                || (phonePesse == null || phonePesse == '') 
                || (attachedDocument.size() == 0))){
                    result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 
                        'Se Disalimentabilità è NO bisogna valorizzare:\nCategoria Disalimentabilità\n'+
                        'Il telefono Pesse\nEd è necessario inserire un allegato'));
                }else if(autocertAsl != null && autocertAsl != '' && !autocertAsl.equalsIgnoreCase('SI') && !autocertAsl.equalsIgnoreCase('NO'))
                {
                    result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 
                    'Per "Autocert. di acq. da cliente cert. ASL" i valori ammessi sono "SI", "NO".'));
                }
                else if(disconnectableCategory.equalsIgnoreCase('01- App. medico terapeutiche') && (autocertAsl == null || autocertAsl == '' || !autocertAsl.equalsIgnoreCase('SI')))
                {
                    result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 
                        'Se Categoria Disalimentabilità è "01- App. medico terapeutiche" bisogna valorizzare a SI "Autocert. di acq. da cliente cert. ASL"'));
                }
                else if(String.isNotBlank(disconnectableCategory) 
                && !disconnectableCategory.equalsIgnoreCase('01- App. medico terapeutiche')
                && !disconnectableCategory.equalsIgnoreCase('02- Pubblica utilità'))
                {
                    result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 
                    'Impossibile selezionare valori differenti da "01- App. medico terapeutiche" o "02- Pubblica utilità" per Categoria Disalimentabilità'));
                }
                else {
                    result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK','Success'));
                }
            } else {
                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK','Success'));
            }
        }

        return result;

    }

    public String validateVariazioni(String fields, String recordId, String caseType, String subprocess, Case currentCase){

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
                || (String.IsBlank(dlNote) || String.isEmpty(dlNote) || dlNote == '' || dlNote == null)
            	)
               )
            {

                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error','Valorizzare: Accordi con il Cliente e Note'));

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

        /*}else if(caseType == 'Cambio contatore non registrato'){

            String reading = getFieldValue(fields, 'Reading__c');

            if(!reading.isNumeric()){

                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error','Valore inserito non corretto'));

            } else {

                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK','Success'));

            }*/
        }else if(caseType == 'Modifica Layout di dettaglio'){

            Boolean detail = Boolean.valueOf(getFieldValue(fields, 'ElementDetail__c'));

            if(detail == currentCase.ElementDetail__c){
                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error','Necessario modificare i dati per poter procedere con la pratica.'));
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
    private String validateUnificazioneSeparazione(String fields, Case currentCase) {

        return validateModificaDatiRecapito(fields, currentCase);

    }

    private String validateVotiveModena(String fields, String process){

        String result;

        if(process.equalsIgnoreCase('Spostamento Votive Modena')){

            String outcome = validateFiscalCode(getFieldValue(fields,'FiscalCode__c'));
            if(!String.isBlank(outcome)){
                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error',outcome));
            } else {
                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK','Success'));
            }

        } else if(process.equalsIgnoreCase('Votive Modena Contestazione Fattura')){

            String billingProfile = getFieldValue(fields, 'BillingProfile__c');
            String reason = getFieldValue(fields, 'Reason__c');

            if(reason == 'Errata Emissione' && (billingProfile == null || billingProfile == '')){
                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error','Necessario Valorizzare Billing Profile'));
            } else {
                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK','Success'));
            }

        }

        return result;

    }

    private String validateVerificaTitolarita(Case currentCase) {

        /**@frpanico 2022-07-08
         * TK 904342C
         * Rimuovere obbligatorieta allegato
         */
        
        /*
        List<ContentDocumentLink> attachedDocument = caseValidationQr.getDocumentByCaseId(currentCase.Id);

        if(attachedDocument.size() == 0){
            return JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Necessario inserire allegato'));
        }
        */    
        return JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK', 'Success'));
    }

    private String validateGestioneBonusSociale(Case currentCase, String fields) {

        List<ContentDocumentLink> attachedDocument = caseValidationQr.getDocumentByCaseId(currentCase.Id);
        String reason = getFieldValue(fields, 'Reason__c');
        String sendMode = getFieldValue(fields, 'SendMode__c');
        String email = getFieldValue(fields, 'Email__c');

        if(reason != null && reason.equals('Permanenza condizioni di disagio') && attachedDocument.size() == 0){
            return JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Necessario allegare autocertificazione del cliente.'));
        }
        
        if (sendMode != null && sendMode.equalsIgnoreCase('E-mail') && String.isBlank(email)) {
            return JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'È necessario inserire una Email a cui inviare la documentazione.'));
        }
            
        return JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK', 'Success'));
    }

    /*private String validateVariazioni(String fields, String caseType){

        String commodity = getFieldValue(fields, 'Commodity__c');
        String supplyType = getFieldValue(fields, 'SupplyType__c');

        if(caseType == 'Nuovo Impianto - Aggiunta Attacco'){
            if(commodity.containsIgnoreCase('Energia Elettrica')
                && supplyType != 'Domestico' && supplyType != 'Non Domestico'){
                    return JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Valore ' + '\"' + supplyType + '\" ' 
                        +'Non selezionabile per il servizio ' + commodity));
            } else if(commodity.containsIgnoreCase('Gas')
                && (supplyType == 'Domestico' || supplyType == 'Non Domestico')){
                    return JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Valore ' + '\"' + supplyType + '\" ' 
                    +'Non selezionabile per il servizio ' + commodity));
            }else{
                return JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK', 'Success'));
            }
        } else {
            return JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK', 'Success'));
        }


    }*/

    public String validateVolturaTecnica(String fields){

        String result;

        Date effectiveDate = getFieldValue(fields, 'EffectiveDate__c') != null
            ? Date.valueOf(getFieldValue(fields, 'EffectiveDate__c'))
            : null;
        
        if(effectiveDate < HDT_UTL_Case.addBusinessDay(System.today(), 3)){
            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Impossibile inserire una data inferiore a 3 giorni lavorativi'));
        } else {
            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK', 'Success'));
        }

        return result;

    }

    public string validatePreventivi(string fields, Case currentCase)
    {
        String result;
        String supplyType = getFieldValue(fields, 'SupplyType__c');
        String taxes = getFieldValue(fields, 'Taxes__c');
        String servicePointType = getFieldValue(fields, 'ServicePointType__c');
        if(currentCase.Type.equalsIgnoreCase('Nuovo Impianto') || currentCase.Type.equalsIgnoreCase('Aggiunta Attacco') || currentCase.Type.equalsIgnoreCase('Istruttoria')){
            if(currentCase.ShipmentAddressAssign__c == null){
                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Inserire Indirizzo di Fornitura'));
            } 
            else if(currentCase.Commodity__c == null){
                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Inserire Servizio mancante'));
            }
            else if(currentCase.Commodity__c != null){
                if(currentCase.Commodity__c == 'Gas' && 
                (String.isNotBlank(supplyType))
                ){
                    String taxesFormatted = taxes.substringBetween('(Cod. ',')');
                    List<FieldCoerenceServicePoint__c> coerenceList = [SELECT Id, 
                                                                              AccountCategory__c, 
                                                                              UseCategory__c, 
                                                                              Commodity__c, 
                                                                              SupplyType__c, 
                                                                              ImplantType__c, 
                                                                              IsActive__c, 
                                                                              Taxes__c 
                                                                        FROM FieldCoerenceServicePoint__c
                                                                        WHERE Commodity__c =: currentCase.Commodity__c AND
                                                                              SupplyType__c =: supplyType AND
                                                                              ImplantType__c =: servicePointType AND
                                                                              (Taxes__c =: taxesFormatted OR Taxes__c = null) AND
                                                                              AccountCategory__c = 'Famiglie' WITH SECURITY_ENFORCED];
                    //Boolean isCoerence = HDT_SRV_FieldCoerenceServicePoint.checkCoerence(inputFieldMap);
                    if(coerenceList.isEmpty()){
                        result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Assenza coerenza campi'));
                    }
                    else{
                        result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK', 'Success'));
                    }
                }else{
                    result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK', 'Success'));
                }
            }            
            else {
                result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK', 'Success'));
            }
        }

        return result;
    }

    /*
    * @Author: Salvatore A. Sarà 19/10/2021
    * Risoluzione "Debug Should Use Logging Level"
    * Risoluzione "Avoid debug statements since they impact on performance"
    */
    @SuppressWarnings('PMD.AvoidDebugStatements')
    public String validateModificaPrivacy(String fields, String recordId){

        String fieldq = 'Id,MarketingPrivacy__c,ProfilingPrivacy__c,HasOptedOutSoftSpam__c,HasOptedOutOfEmail__c';
        String fromq = 'Case';
        String whereq = 'Id = \''+recordId+'\'';
        String queryString = 'SELECT ' + fieldq + ' FROM ' + fromq + ' WHERE ' +  whereq;
        List<SObject> sobjectRecordList = HDT_QR_GenericQuery.getGenericRecords(queryString, fromQ);
        Case c = (Case) sobjectRecordList[0];

        System.debug(LoggingLevel.DEBUG,'Validating case: ' + c);
        System.debug(LoggingLevel.DEBUG,'Fields modified: ' + fields);

        String result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK', 'Success'));

        Boolean currentHasOptedOutOfEmail = (Boolean) c.get('HasOptedOutOfEmail__c');
        Boolean newHasOptedOutOfEmail = Boolean.valueOf(getFieldValue(fields, 'HasOptedOutOfEmail__c'));
        if (newHasOptedOutOfEmail && !currentHasOptedOutOfEmail) {
            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Non è possibile disiscrivere il cliente dalle liste di distribuzione.'));
            return result;
        }

        String newMarketingPrivacy = getFieldValue(fields, 'MarketingPrivacy__c') != null ? getFieldValue(fields, 'MarketingPrivacy__c') : '';
        String newProfilingPrivacy = getFieldValue(fields, 'ProfilingPrivacy__c') != null ? getFieldValue(fields, 'ProfilingPrivacy__c') : '';
        Boolean newHasOptedOutSoftSpam = Boolean.valueOf(getFieldValue(fields, 'HasOptedOutSoftSpam__c'));

        Boolean currentHasOptedOutSoftSpam = (Boolean) c.get('HasOptedOutSoftSpam__c');
        String currentMarketingPrivacy = (String) c.get('MarketingPrivacy__c') != null ? (String) c.get('MarketingPrivacy__c') : '';
        String currentProfilingPrivacy = (String) c.get('ProfilingPrivacy__c') != null ? (String) c.get('ProfilingPrivacy__c') : '';

        if (newHasOptedOutOfEmail == currentHasOptedOutOfEmail && newHasOptedOutSoftSpam == currentHasOptedOutSoftSpam && 
            newMarketingPrivacy.equals(currentMarketingPrivacy) && newProfilingPrivacy.equals(currentProfilingPrivacy)) {
            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'È necessario modificare almeno un consenso privacy per poter proseguire.'));
        }

        return result;
    }

    public String validateEndDate(String fields, Date currentEndDate, Case currentCase){

        String endDateString = getFieldValue(fields, 'TemporaryConnectionEndDate__c');

        String result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK', 'Success'));

        Date endDate = Date.valueOf(endDateString);

        List<ContentDocumentLink> attachedDocument = caseValidationQr.getDocumentByCaseId(currentCase.Id);

        if ( currentEndDate > endDate) {
            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'È necessario che la data fine connessione temporanea sia successiva a quella già esistente sul contratto.'));
        }
        if(attachedDocument.size() == 0)
        {
            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'È necessario inserire allegati'));
        }

        return result;
    }

    public String validateAttivazioniPostSales(String fields)
    {
        String result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK', 'Success'));
        String fiscalCode = getFieldValue(fields, 'DeceasedFiscalCode__c');
        String firstName = getFieldValue(fields, 'DeceasedName__c');
        String lastName = getFieldValue(fields, 'DeceasedSurname__c');
        Date deceasedDate = getFieldValue(fields, 'DeceasedDate__c') != null ? Date.valueOf(getFieldValue(fields, 'DeceasedDate__c')) : null;
        String outcome = validateFiscalCode(fiscalCode);
        if(deceasedDate != null && deceasedDate > System.today())
        {
            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Impossibile inserire una data decesso nel futuro'));
        }
        if(!String.isBlank(outcome))
        {
            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', outcome));
        }
        if(!HDT_UTL_CalculateFiscalCode.checkFirstLastNameFromFiscalCode(fiscalCode, firstName, lastName))
        {
            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Codice Fiscale non coerente con i dati inseriti'));
        }
        
        return result;
    }

    // Validazione CF. Se il CF è vuoto lo consideriamo valido.
    public String validateFiscalCode(String fiscalCode) {
        if (String.isBlank(fiscalCode)) {
            return '';
        }

        Pattern pattern = Pattern.compile('^[a-zA-Z]{6}[0-9]{2}[abcdehlmprstABCDEHLMPRST]{1}[0-9]{2}([a-zA-Z]{1}[0-9]{3})[a-zA-Z]{1}$');
        Matcher matcher = pattern.matcher(fiscalCode);

        return matcher.matches() ? '' : 'Il Codice Fiscale inserito non è valido.';
    }

    // Validazione CF, considerando anche variazioni rispetto al vecchio CF. Se il nuovo CF è vuoto lo consideriamo valido.
    /*
    * @Author: Salvatore A. Sarà 19/10/2021
    * Risoluzione "Debug Should Use Logging Level"
    * Risoluzione "Avoid debug statements since they impact on performance"
    */
    @SuppressWarnings('PMD.AvoidDebugStatements')
    public String validateFiscalCodeAgainstOld(String oldFiscalCode, String newfiscalCode) {
        if (String.isBlank(newfiscalCode)) {
            return '';
        }

        String outcome = validateFiscalCode(newfiscalCode);

        if (String.isBlank(outcome) && String.isNotBlank(oldFiscalCode)) {
            List<Integer> oldChars = oldFiscalCode.toLowerCase().getChars();
            List<Integer> newChars = newfiscalCode.toLowerCase().getChars();
            Integer minLength = Math.min(oldChars.size(), newChars.size());
            Integer changedChars = 0;
            for(Integer i = 0; i < minLength; i++) {
                if (newChars[i] != oldChars[i]) {
                    changedChars++;
                }
            }
            System.debug(LoggingLevel.DEBUG,'Numero caratteri modificati sul nuovo CF: ' + changedChars);
            if (changedChars > 2) {
                outcome = 'Per modifiche sostanziali (più di 2 caratteri) al Codice Fiscale è necessario innescare una Voltura.';
            }
        }

        return outcome;
    }

    // Validazione CF numerico. Se il CF è vuoto lo consideriamo valido.
    public String validateNumericFiscalCode(String fiscalCode) {
        if (String.isBlank(fiscalCode)) {
            return '';
        }

        Pattern pattern = Pattern.compile('^[0-9]{11}$');
        Matcher matcher = pattern.matcher(fiscalCode);

        return matcher.matches() ? '' : 'Il Codice Fiscale deve contenere 11 cifre numeriche.';
    }


    public String getFieldValue(String fields, String fieldToGet){
        Map<String, Object> fieldsMap = (Map<String, Object>) JSON.deserializeUntyped(fields);
        return String.valueOf(fieldsMap.get(fieldToGet));
    }

    public String validatePromessaDiPagamentoENte(Case currentCase){
        String result='';
        List<ContentDocumentLink> attachedDocument = caseValidationQr.getDocumentByCaseId(currentCase.Id);
        if(attachedDocument.size() == 0){
            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Necessario inserire allegato'));
        }else{
            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK', 'Success'));
        }
        return result;
    }

    public String validateErroreFatturazione(Case currentCase, String fields) {
        String result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK', 'Success'));
        Set<String> argSet = new Set<String>{'Richiesta di ricalcolo fuga acqua', 'Rimborso retroattivo importo fognatura e depurazione'};
        String argument = getFieldValue(fields, 'BillingErrorArgument__c');
        String customerSelfReading = getFieldValue(fields, 'CustomerSelfReading__c');
        String readingDate = getFieldValue(fields, 'ReadingDate__c');
        String note = getFieldValue(fields, 'Note__c');

        if('Acqua'.equals(currentCase.CommodityFormula__c) && !String.isBlank(customerSelfReading) && (readingDate == null || String.isBlank(readingDate) || String.isEmpty(readingDate) || readingDate.equalsIgnoreCase('null'))){
            return result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Inserire la data di lettura nell\'apposito campo.'));
        }
        
        if ('Acqua'.equalsIgnoreCase(currentCase.CommodityFormula__c) && argSet.contains(argument)){
            List<ContentDocumentLink> attachedDocument = caseValidationQr.getDocumentByCaseId(currentCase.Id);
            if(attachedDocument.size() == 0){
                return result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Necessario inserire allegato.'));
            }
        }
        
        if ('Acqua'.equalsIgnoreCase(currentCase.CommodityFormula__c) && 'Rimborso retroattivo importo fognatura e depurazione'.equals(argument) && String.isBlank(note)){
            return result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Per l\'argomento selezionato occorre specificare sul campo note la Data di Inizio Rimborso.'));
        }

        return result;
    }

}