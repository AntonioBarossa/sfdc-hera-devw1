public inherited sharing class HDT_UTL_HerokuPostSalesManager {

    private static HDT_QR_HerokuPostSalesManager hpsmQr = new HDT_QR_HerokuPostSalesManager();

    public String getCodeFromPhaseTransition(Case currentCase){
        String code;
        Map<Id, List<wrts_prcgvr__PhaseTransition__c>> result = new Map<Id, List<wrts_prcgvr__PhaseTransition__c>>();
        List<wrts_prcgvr__PhaseTransition__c> ptList = new List<wrts_prcgvr__PhaseTransition__c>();
        wrts_prcgvr.Interfaces_1_0.IPhaseManagerUtils pMUtils = 
            ((wrts_prcgvr.Interfaces_1_0.IPhaseManagerUtils) wrts_prcgvr.VersionManager.newClassInstance('PhaseManagerUtils'));
        result = (Map<Id, List<wrts_prcgvr__PhaseTransition__c>>) 
            pMUtils.getTransitionCalloutsForObjects(new Map<String, Object> {'triggerNew' => new List<Case>{currentCase}});
        ptList = result.get(currentCase.Id);
        code = ptList[0].wrts_prcgvr__CalloutTemplate__c;
        return code;
    }

    public HDT_WRP_HerokuPostSalesProva.HDT_WRP_MultiResponse createFakeResponse(Case currentCase){
        HDT_UserInputFlow__mdt cl = [SELECT FieldsJSON__c 
        FROM HDT_UserInputFlow__mdt 
        WHERE ProcessType__c = 'prova callout' 
        WITH SECURITY_ENFORCED
        LIMIT 1 ];
        String c = cl.FieldsJSON__c;
        HDT_WRP_HerokuPostSalesProva.HDT_WRP_MultiResponse mrrResponse = 
            (HDT_WRP_HerokuPostSalesProva.HDT_WRP_MultiResponse) JSON.deserialize(c,HDT_WRP_HerokuPostSalesProva.HDT_WRP_MultiResponse.class);
        System.debug('Case Phase --> '+currentCase.TecnicalPhase__c);
        if(currentCase.TecnicalPhase__c == 'Da Inviare'){
            return mrrResponse;
        } else {
            return null;
        }
    }

    public List<HDT_WRP_HerokuPostSalesManager> manipulateResponse(wrts_prcgvr.MRR_1_0.MultiResponse responseMrr){

        List<HDT_WRP_HerokuPostSalesManager> responseResults = new List<HDT_WRP_HerokuPostSalesManager>();

        String requestType;
        String result;
        String errorMessage;
        String refReq;
        String communicationChannel;
        String reqId;
        String herokuCode;
        String dlCode;
        try{
            responseResults.add(new HDT_WRP_HerokuPostSalesManager(responseMrr.responses[0].objects[0].fields, responseMrr.responses[0].header.requestType));
        }catch(Exception ex){
            System.debug('Error in Heroku Response');
        }
        return responseResults;
    }

    public HDT_WRP_HerokuPostSalesManager manipulateRequest(HDT_WRP_MrrRequest.HDT_WRP_Request request){

        String flowType;
        String phase;
        String recordId;
        String herokuCode;
        String contractCode;
        String contractStatus;
        String dlCode;
        System.debug('UTL_CLASS_Request--> '+request);
        HDT_WRP_HerokuPostSalesManager toReturn = new HDT_WRP_HerokuPostSalesManager(request.objects[0].fields);
        toReturn.requestMap.put('requestId', request.header.requestId);
        return toReturn; 
    }


    public List<Case> handleResponse(List<HDT_WRP_HerokuPostSalesManager> responseResults, Case currentCase){

        String phase;
        String herokuCode = '';
        String dlCode = '';
        String sendDlDate = '';
        String errorMessage = '';
        String comunicationChannel='';
        String responseStatus='';
        String herokuCancellationCode = '';
        Case caseNew = new Case();


        List<Case> caseUpdate = new List<Case>();

        for(HDT_WRP_HerokuPostSalesManager responseResult : responseResults){
            switch on responseResult.responseMap.get('REQUEST_TYPE'){
                when 'CREA_RIC'{
                    herokuCode = responseResult.responseMap.get('requestId');
                    dlCode = responseResult.responseMap.get('COD_PRAT_DISTR');
                    sendDlDate = responseResult.responseMap.get('DT_INVIO_DL');
                    errorMessage = responseResult.responseMap.get('errorMessage');
                    comunicationChannel = responseResult.responseMap.get('comunicationChannel');
                    responseStatus = responseResult.responseMap.get('result');
                    switch on responseStatus{
                        when 'OK'{
                            switch on comunicationChannel{
                                when 'ATOA'{
                                    phase = responseResult.responseMap.get('FASE');
                                    if(String.isEmpty(phase) || String.isBlank(phase)){
                                        phase = 'Comunicazione verso Heroku OK';
                                    }
                                } 
                                when else{
                                    phase = 'Comunicazione verso Heroku OK';
                                }
                            }
                        } 
                        when else{
                            phase = 'Comunicazione verso Heroku KO';
                        }
                    }                    
                } when 'ANNULL'{
                    herokuCancellationCode = responseResult.responseMap.get('COD_PRAT_UTENTE');
                    errorMessage = responseResult.responseMap.get('errorMessage');
                    System.debug('SRV_Class_result--> '+responseResult.responseMap.get('result'));
                    switch on responseResult.responseMap.get('result'){
                        when 'OK'{
                            phase = 'Annullamento - Comunicazione verso Heroku OK';
                        } 
                        when else{
                            phase = 'Annullamento - Comunicazione verso Heroku KO';
                        }
                    }
                } 
                when else {
                    System.debug('Error non existing request');
                    return null;
                }
            }
        }
        if(responseResults.size()<=0){
            phase = 'Comunicazione verso Heroku KO';
            errorMessage = 'Errore nella risposta da Heroku';
        }
        if(currentCase.Phase__c  == 'Da Inviare' 
        || currentCase.Phase__c == 'Preventivo accettato' 
        || currentCase.Phase__c == 'Comunicazione verso Heroku KO'
        || currentCase.Phase__c == 'Annullamento - Da inviare'){

            System.debug('SRV_Class_Phase--> '+phase);
            System.debug('SRV_Class_HerokuPracticeCode--> '+herokuCode);

            caseNew.Id = currentCase.Id;
            caseNew.TecnicalPhase__c = phase;
            caseNew.Description = errorMessage;
            if(herokuCode != null && herokuCode != ''){
                caseNew.HerokuPracticeCode__c = herokuCode;
            }
            if(dlCode != null && dlCode != ''){
                caseNew.DistributorPracticeCode__c = dlCode;
            }
            if(sendDlDate != null && sendDlDate != ''){
                caseNew.SendToDistributorDate__c = Date.valueOf(sendDlDate);
            }
            if(herokuCancellationCode != null && herokuCancellationCode != ''){
                caseNew.CancellationHerokuPracticeCode__c = herokuCancellationCode;
            }

            caseUpdate.add(caseNew);
            HDT_UTL_DatabaseService.updateSObject(caseUpdate);
            if(currentCase.Type == 'Allineamento Anagrafica' && phase == 'Esito OK da SII'){
                caseNew.Phase__c = 'Completata';
                caseNew.Status = 'Closed';
                updateFuture(JSON.serialize(caseNew));
            }
        }

        return caseUpdate;

    }

    public List<Case> handleRequest(HDT_WRP_HerokuPostSalesManager reqWrp){
        List<Case> caseUpdate = new List<Case>();
        Case currentCase = new Case();
        String recordId = reqWrp.requestMap.get('RECORD_ID');
        String caseNumber = reqWrp.requestMap.get('SALESFORCE_KEY');
        String method = reqWrp.requestMap.get('METHOD');
        String caseParam = '';
        String storno = '';
        String activity='';
        Case recordCase;
        Datetime nowDate = Datetime.now();
        String nowDateFormat = nowDate.format('dd/MM/yyyy h:mm a');
        String currentPhase = '';
        String nextPhase = '';
        String quotationType = '';
        String codServizio = reqWrp.requestMap.get('COD_SERVIZIO');
        String codPrestazione = reqWrp.requestMap.get('COD_PRESTAZIONE');
        String codPresa = reqWrp.requestMap.get('COD_PRESA');
        String codPraticaDl = reqWrp.requestMap.get('COD_PRAT_DISTR');
        String numPrev = reqWrp.requestMap.get('NUMPREV');
        String expectedExec = reqWrp.requestMap.get('TEMP_ES_PREV');
        HDT_QR_HerokuPostSalesManager qrClass = new HDT_QR_HerokuPostSalesManager();
        //CHECK CROSS MINIMUM FIELD
        if(String.isBlank(method)) throw new HDT_UTL_RichPassException('Required Field Missing: Method');
        
        if(String.isBlank(reqWrp.requestMap.get('FASE')) && String.isBlank(reqWrp.requestMap.get('ATTIVITA')) && !method.equalsIgnoreCase('AddAttivita')){
            //gestione scarti
            return caseUpdate;
        }
        //INIT VARIABLE FOR NOTIFICATION ON CASE
        if(method.equalsIgnoreCase('esito_intermedio') || method.equalsIgnoreCase('esito_finale') || method.equalsIgnoreCase('AddAttivita')){
            if(String.isBlank(recordId) && String.isBlank(caseNumber)) throw new HDT_UTL_RichPassException('Required Field Missing: RecordId OR CaseNumber');
            caseParam = recordId != null? recordId:caseNumber;
            recordCase = hpsmQr.getCaseRecord(caseParam);
            currentCase.Id = recordCase.Id;
            currentPhase = recordCase.Phase__c;
            quotationType = recordCase.QuotationType__c;
            nextPhase = reqWrp.requestMap.get('FASE');
            storno = reqWrp.requestMap.get('STORNO');
            activity = reqWrp.requestMap.get('ATTIVITA');
        }
        if(method.equalsIgnoreCase('aggiornaRCU')){
            if(String.isBlank(codServizio) || String.isBlank(codPrestazione)) throw new HDT_UTL_RichPassException('Required Field Missing: Codice Servizio or Codice Prestazione');
            if(String.isBlank(codPresa) && String.isBlank(codPraticaDl)) throw new HDT_UTL_RichPassException('Required Field Missing: Codice Presa or Codice Pratica DL');
            currentCase = HDT_SRV_AnagAlignment.handleAnagAlignmentHeroku(reqWrp);
            currentCase = qrClass.getCaseRecord(currentCase.Id);
            caseUpdate.add(currentCase);
            return caseUpdate;
        }else if(method.equalsIgnoreCase('esito_intermedio')){
            if(nextPhase != null && nextPhase != ''){
                //Gestione ad hoc per E150 Annullamento - Esito OK/KO da DL/SII
                if((nextPhase.equalsIgnoreCase('Esito OK da DL/SII') || nextPhase.equalsIgnoreCase('Esito KO da DL/SII')) &&
                    currentPhase.indexOf('Annullamento') > -1){
                        nextPhase = 'Annullamento - ' + nextPhase;
                }
                currentCase.Phase__c = nextPhase;
            }
            if(reqWrp.requestMap.get('COD_PRAT_DISTR') != null && reqWrp.requestMap.get('COD_PRAT_DISTR') != '' && !(currentPhase.indexOf('Annullamento') > -1)){
                currentCase.DistributorPracticeCode__c = reqWrp.requestMap.get('COD_PRAT_DISTR');
            }
            if(reqWrp.requestMap.get('DT_INVIO_DL') != null && reqWrp.requestMap.get('DT_INVIO_DL') != ''){
                currentCase.SendToDistributorDate__c = Date.valueOf(reqWrp.requestMap.get('DT_INVIO_DL'));
            }if(reqWrp.requestMap.get('IMP_PREV_DIST') != null && reqWrp.requestMap.get('IMP_PREV_DIST') != ''){
                String importo = reqWrp.requestMap.get('IMP_PREV_DIST');
                if(importo.indexOf(',')>-1){
                    importo = importo.replace(',', '.');
                }
                currentCase.Amount__c = Decimal.valueOf(importo);
            }
            if(reqWrp.requestMap.get('TESTO_ERRR') != null && reqWrp.requestMap.get('TESTO_ERRR') != ''){
                String description = recordCase.Description != null?recordCase.Description:'';
                currentCase.Description = nowDateFormat + ': ' + reqWrp.requestMap.get('TESTO_ERRR') + '\n' + description;
            }
            if(reqWrp.requestMap.get('COD_CAUSALE') != null && reqWrp.requestMap.get('COD_CAUSALE') != ''){
                currentCase.CancellationReasonCode__c = reqWrp.requestMap.get('COD_CAUSALE');
            }
            if(reqWrp.requestMap.get('ANNOTAZIONI_ANN') != null && reqWrp.requestMap.get('ANNOTAZIONI_ANN') != ''){
                currentCase.CancellationNote__c = nowDateFormat + ': ' + reqWrp.requestMap.get('ANNOTAZIONI_ANN');
            }
            if(reqWrp.requestMap.get('NOTE_ANN') != null && reqWrp.requestMap.get('NOTE_ANN') != ''){
                String noteAnn = currentCase.CancellationNote__c != null?currentCase.CancellationNote__c:'';
                currentCase.CancellationNote__c = nowDateFormat + ': ' + reqWrp.requestMap.get('NOTE_ANN') + '\n' + noteAnn;
            }
            if(currentPhase.indexOf('Annullamento') > -1 && reqWrp.requestMap.get('COD_PRAT_UTENTE') != null && reqWrp.requestMap.get('COD_PRAT_UTENTE')!= ''){
                currentCase.CancellationHerokuPracticeCode__c = reqWrp.requestMap.get('COD_PRAT_UTENTE');
            }
            if(nextPhase.equalsIgnoreCase('Pratica Riclassificata') && reqWrp.requestMap.get('NOTE') != null){
                currentCase.ComplexCategory__c = reqWrp.requestMap.get('NOTE');
            }
            if(reqWrp.requestMap.get('DT_MAX_PREV') != null){
                try{
                    currentCase.QuotationValidityDate__c = Date.valueOf(reqWrp.requestMap.get('DT_MAX_PREV'));
                } catch(Exception e){
                    System.debug('DT_MAX_PREV Exception -> ' + e.getMessage());
                }
            }
            
        }else if(method.equalsIgnoreCase('esito_finale')){
            String noteSap = reqWrp.requestMap.get('NOTA_HK');
            String odv = reqWrp.requestMap.get('VBELN');
            String fatturaSap = reqWrp.requestMap.get('FATTURA');
            String currentDescription = recordCase.Description != null?recordCase.Description:'';
            String newDescription = '';
            if(currentPhase.indexOf('KO') > -1 && nextPhase.equalsIgnoreCase('Completata')){
                //no action needed
            }else if(currentPhase.equalsIgnoreCase('Dati Tecnici Ricevuti') && nextPhase.equalsIgnoreCase('Completata')){
                currentCase.Phase__c = 'Inviare preventivo';
            }else{
                currentCase.Phase__c = nextPhase;
                handleEntityUpdate(reqWrp);
            }

            if(noteSap != null && noteSap != ''){
                newDescription = nowDateFormat + ': ' + noteSap + '\n';
            }
            if(odv != null && odv != ''){
                newDescription =  nowDateFormat + ': ' + odv + '\n' + newDescription;
            }
            if(fatturaSap != null && fatturaSap != ''){
                newDescription = nowDateFormat + ': ' + fatturaSap + '\n' + newDescription;
            }
            if(String.isNotBlank(newDescription)){
                currentCase.Description = newDescription + '\n' + currentDescription;
            }
        }else if(method.equalsIgnoreCase('AddAttivita')){
            String type = reqWrp.requestMap.get('TIPO_ATTIVITA');
            String message = reqWrp.requestMap.get('MESSAGGIO');
            // Al momento solo la Prescrizione Fattura prevede un cambio fase da esito async da SAP.
            if(String.isNotBlank(type) 
                && String.isNotBlank(recordCase.Type) 
                && (recordCase.Type.equals('Prescrizione Fatture') || recordCase.Type.equalsIgnoreCase('Piano Rateizzazione'))
                && !(type.containsIgnoreCase('Esito Rateizzazione OK'))){
                    if(type.equalsIgnoreCase('Piano rate OK Acc. pagato')){
                        type = 'Acconto paperless pagato';
                    }
                currentCase.Phase__c = type; 
            }
            if(String.isNotBlank(message)){
                // Per il piano rate SAP manda TIPO_ATTIVITA=Paperless generato quando genera il codice bollettino paperless.
                if(type.equalsIgnoreCase('Paperless generato')){
                    currentCase.Phase__c = 'Paperless Generato';
                    currentCase.PaperlessCode__c = message;
                }else{
                    String description = recordCase.Description != null?recordCase.Description:'';
                    currentCase.Description = nowDateFormat + ': ' + message + '\n' + description;
                }
            }
        }else{
            throw new HDT_UTL_RichPassException('Method non definito');
        }
        if(numPrev != null && numPrev != ''){
            currentCase.QuotationNumber__c = numPrev;
        }
        if(expectedExec != null && expectedExec != ''){
            if(quotationType.equalsIgnoreCase('Analitico') && nextPhase.containsIgnoreCase('Dati Tenici Ricevuti')){
                currentCase.ExpectedExecutionTime__c = expectedExec;
            }else if(!quotationType.equalsIgnoreCase('Analitico')){
                currentCase.ExpectedExecutionTime__c = expectedExec;
            }else{
                //not saving
            }
        }
        caseUpdate.add(currentCase);
        HDT_UTL_DatabaseService.updateSObject(caseUpdate);
        handleAfterNotify(currentCase,storno,activity);
        return caseUpdate;
    }
    private void handleAfterNotify(Case currentCase, String storno, String activity){
        if(currentCase.Phase__c == 'Annullamento - Esito OK da DL/SII' || currentCase.Phase__c == 'Annullato'){
            currentCase.Phase__c = 'Annullato';
            currentCase.Status = 'Closed';
            updateFuture(JSON.serialize(currentCase));
        }else if(currentCase.Phase__c == 'Annullamento SII - Ricezione') {
            handlePassiveCancellation(currentCase, 'Case', storno, activity);
        }else if(currentCase.Type == 'Allineamento Anagagrafica' && currentCase.Phase__c == 'Esito OK da SII'){
            currentCase.Phase__c = 'Completata';
            currentCase.Status = 'Closed';
            updateFuture(JSON.serialize(currentCase));
        }else if(currentCase.Phase__c == 'Preventivo rifiutato – Amm OK'){
            currentCase.Phase__c = 'Completata';
            currentCase.Status = 'Closed';
            updateFuture(JSON.serialize(currentCase));
        }
    }
    //se Annullamento SII - Ricezione e Storno N --> Aggiornare in Annullamento SII e dopo in Annullato SII
    //se Annullamento SII - Ricezione e Attivita Eseguire Gestione Manuale SAP --> Creazione Activity
    //se Annullamento SII - Ricezione e Storno null --> No action
    public void handlePassiveCancellation(SObject recordObj, String objectType, String storno, String activity){
        Case recordCase;
        Order recordOrder;
        
        if(String.isNotBlank(storno) && storno.equalsIgnoreCase('N')) {
            recordObj.put('Phase__c', 'Annullato SII');
            updateFutureSobject(JSON.serialize(recordObj));
        }else if(String.isNotBlank(activity) && activity.equalsIgnoreCase('Eseguire Gestione Manuale SAP')){
            switch on objectType {
                when 'Case' {
                    createActivity((String)recordObj.get('Id'),null, '', activity);
                }
                when else {
                    createActivity(null,(String)recordObj.get('Id'), '', activity);
                }
            }
        }
    }

    public Case handleRequestRichPass(HDT_WRP_HerokuPostSalesManager reqWrp){
        Case currentCase = new Case();
        Case relatedCase = new Case();
        Case containerCase = new Case();
        List<Case> caseInsertList = new List<Case>();
        List<Case> caseUpdateList = new List<Case>();
        HDT_CausalCodeCalculation__mdt causalCodeMdt = new HDT_CausalCodeCalculation__mdt();
        String tipo = '';
        String sottotipo = '';
        String cluster = '';
        String processType = '';
        String source = '';
        String codiceCliente = '';
        String pod = '';
        String dataDecorrenza = '';
        String recapito = '';
        String ufficioCompetente = '';
        String codiceContratto = '';
        String contoContrattuale = '';
        String sapContractCode = null;
        String relatedRecordId = '';
        Contract contract;
        ServicePoint__c sp;
        Account account;
        HDT_QR_HerokuPostSalesManager qrClass = new HDT_QR_HerokuPostSalesManager();
        HDT_UTL_Morosita morUtl = new HDT_UTL_Morosita();
        try {
            tipo = reqWrp.requestMap.get('TIPO_SIEBEL');
            sottotipo = reqWrp.requestMap.get('SOTTOTIPO_SIEBEL');
            cluster = reqWrp.requestMap.get('CLUSTER');
            processType = reqWrp.requestMap.get('PROCESS_TYPE');
            source = reqWrp.requestMap.get('CANALE');
            codiceCliente = reqWrp.requestMap.get('CODICE_CLIENTE');
            pod = reqWrp.requestMap.get('CODICE_PRESA');
            dataDecorrenza = reqWrp.requestMap.get('DATA_DECORRENZA');
            recapito = reqWrp.requestMap.get('RECAPTIO');
            ufficioCompetente = reqWrp.requestMap.get('UFFICIO_COMPETENTE');
            codiceContratto = reqWrp.requestMap.get('CODICE_CONTRATTO');
            contoContrattuale = reqWrp.requestMap.get('CONTO_CONTRATTUALE');
            relatedRecordId = reqWrp.requestMap.get('SALESFORCE_KEY');
            if(String.isNotBlank(pod)){
                if(String.isNotBlank(codiceCliente))
                    account = qrClass.getAccount(codiceCliente);
                else {
                    account = qrClass.getAccountFromSp(pod);
                }
                if(account != null){
                    if(String.isNotBlank(tipo) && String.isNotBlank(sottotipo)){
                        //REQUEST FROM SAP - MOROSITA
                    }else if(String.isNotBlank(cluster) && String.isNotBlank(processType)){
                        //REQUEST FROM HEROKU - SWITCH OUT - ANNULLAMENTO
                        currentCase.Cluster__c = cluster;
                        currentCase.Type = processType;
                        currentCase.Origin = source;
                    }else {
                        throw new HDT_UTL_RichPassException('Non è stato possibile determinare il processo da creare');
                    }
                    if(cluster != null && String.isNotBlank(cluster)){
                        
                    }
                    currentCase.Origin = source;
                    Contact contact = qrClass.getContact(account.Id);
                    currentCase.AccountId = account.Id;
                    currentCase.FiscalCode__c = account.FiscalCode__c;
                    currentCase.VatNumber__c = account.VATNumber__c;
                    currentCase.ContactId = contact?.Id;
                    currentCase.Mobile__c = contact?.MobilePhone;
                    currentCase.Email__c = contact?.Email;
                    //Aggiunto PhoneNumber
                    currentCase.PhoneNumber__c = contact?.MobilePhone;
                    sp = qrClass.getServicePoint(pod);
                    if(sp != null){
                        contract = qrClass.getContract(sp.Id);
                        currentCase.Contract__c = contract?.Id;
                        currentCase.ServicePoint__c = sp.Id;
                        currentCase.BillingProfile__c = Contract?.BillingProfile__c;
                        sapContractCode = contract?.SAPContractCode__c;
                    }else {
                        throw new HDT_UTL_RichPassException('Non è stato possibile recuperare il Service Point');
                    }
                    if(String.isBlank(cluster)){
                        cluster = sottotipo;
                    }
                    switch on cluster{
                        when 'Disattivazioni'{
                            currentCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_Disattivazioni').getRecordTypeId();
                            if(dataDecorrenza != null){
                                currentCase.SwitchOutDate__c = Date.valueOf(dataDecorrenza);
                                if(contract != null && contract.EndDate !=null) {
                                    Date dataSwitchOut =  Date.valueOf(dataDecorrenza);
                                    if(dataSwitchOut < contract.EndDate){
                                        currentCase.EarlyRecess__c = true;
                                    }
                                }
                            }
                            currentCase.Status = 'In Lavorazione';
                            currentCase.Phase__c = 'In Lavorazione SAP';
                        }when 'Morosita'{
                            currentCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_Morosita').getRecordTypeId();
                            currentCase.Cluster__c = 'Morosità';
                            if(dataDecorrenza != null){
                                currentCase.EffectiveDate__c = Date.valueOf(dataDecorrenza);
                            }
                            if(String.isNotBlank(processType)){
                                currentCase.Type = morUtl.transcodeProcess(processType);
                            }
                            if(currentCase.PhoneNumber__c != null && String.isNotBlank(currentCase.PhoneNumber__c) && String.isNotBlank(recapito)){
                                currentCase.PhoneNumber__c = recapito;
                            }
                            if(String.isNotBlank(ufficioCompetente)){
                                currentCase.CompetentOffice__c = ufficioCompetente;
                            }
                            if(String.isNotBlank(relatedRecordId)){
                                String containerId;
                                relatedCase = qrClass.getCaseRecord(relatedRecordId);
                                if(relatedCase != null){
                                    currentCase.RelatedCase__c = relatedCase.Id;
                                    containerId = morUtl.handleContainer(relatedCase);
                                    //Se c'e il container
                                    if(String.isNotBlank(containerId)){
                                        if(containerId instanceOf Id){
                                            currentCase.ParentId = containerId;
                                        }else{
                                            containerCase = (Case) JSON.deserialize(containerId, Case.class);
                                            caseInsertList.add(containerCase);
                                        }
                                    }
                                }else {
                                    throw new HDT_UTL_RichPassException('Nessun riferimento SALESFORCE_KEY presente a sistema');
                                }
                            }
                            currentCase.Phase__c = 'Bozza';
                            currentCase.Status = 'New';
                        }when else{
                            throw new HDT_UTL_RichPassException('Errore tecnico nella definizione del RecordType');
                        }
                    }
                }else {
                    throw new HDT_UTL_RichPassException('Non è stato possibile recuperare l\'Account di riferimento');
                }
                
            }else {
                throw new HDT_UTL_RichPassException('POD non valorizzato');
            }
            //It is not possible to perform DML operations before a callout
            try{
                currentCase = dataEnrichment(pod,sapContractCode,currentCase);
            }catch(Exception e){
                System.debug('Impossibile arrichire dati: ' + e.getMessage());
            }
            //add causal code
            causalCodeMdt = qrClass.getCausalCode(currentCase.Cluster__c, currentCase.Type, sp.CommoditySector__c);
            if(causalCodeMdt != null){
                currentCase.CausalCode__c = causalCodeMdt.CausalCode__c;
            }
            caseInsertList.add(currentCase);           
            HDT_UTL_DatabaseService.insertSObject(caseInsertList);
            if(currentCase.EarlyRecess__c){
                createActivity(currentCase.Id,null, '', 'Recesso Anticipato');
            }
            currentCase = qrClass.getCaseRecord(currentCase.Id);
            if(cluster == 'Morosita'){
                //caso in cui c'e anche il case contenitore quindi serve legare al case referenziato il container creato
                if(caseInsertList.size() > 1){
                    relatedCase.ParentId = containerCase.Id;
                    caseUpdateList.add(relatedCase);
                }
                if(currentCase.ParentId == null){
                    currentCase.ParentId = containerCase.Id;
                }
                currentCase.Phase__c = 'Da Inviare';
                currentCase.Status = 'In Lavorazione';
                caseUpdateList.add(currentCase);
                HDT_UTL_DatabaseService.updateSObject(caseUpdateList);
            }
        } catch (Exception ex) {
            throw ex;
        }
        return currentCase;
    }

    private static Case dataEnrichment(String pod, String contractCOde, Case currentCase){
        String serializedResponse = HDT_WS_ArricchimentoDatiTemp.submitRequest(pod, contractCode);
        return HDT_UTL_DataEnrichmentPostSales.handleResponse(serializedResponse, currentCase);
    }

    /*@future(callout=true)
    private static void dataEnrichment(String pod, String contractCode,String caseId, String cluster){
        Case currentCase = new Case();
        Case updateCase = new Case();
        currentCase.Id = caseId;
        updateCase.Id = caseId;
        try{
            String response = HDT_WS_ArricchimentoDatiTemp.submitRequest(pod, contractCode);
            updateCase = HDT_UTL_DataEnrichmentPostSales.handleResponse(response, currentCase);
        }catch(Exception e){
            System.debug(e.getMessage());
        }
        if (updateCase != null) {
            if(cluster.containsIgnoreCase('Morosità')){
                updateCase.Phase__c = 'Da Inviare';
                updateCase.Status = 'In Lavorazione';
            }
           
        } else {
            if(cluster.containsIgnoreCase('Morosità')){
                updateCase.Phase__c = 'Da Inviare';
                updateCase.Status = 'In Lavorazione';
            }

        }
        HDT_UTL_DatabaseService.updateSObject(updateCase); 
    }*/

    @AuraEnabled
    public static String getAsyncJobByJobItem(String recordId){

        wrts_prcgvr__AsyncJob__c asyncJobRec = new wrts_prcgvr__AsyncJob__c();
        String result;

        asyncJobRec = hpsmQr.getAsyncJobByJobItem(recordId);

        if(asyncJobRec != null){
            if(asyncJobRec.wrts_prcgvr__Status__c == 'Completed'){

                result = 'OK';

            }else if(asyncJobRec.wrts_prcgvr__Status__c == 'Queued' && asyncJobRec.wrts_prcgvr__Details__c != null){
                
                result = 'Error';

            } else {

                result = 'KO';

            }
        } else {

            result = 'KO';

        }

        return result;

    }

    @Future
    private static void updateFuture(String inputString){

        Case c = (Case) JSON.deserialize(inputString, Case.class);

        HDT_UTL_DatabaseService.updateSObject(c);

    }

    @Future
    private static void updateFutureSobject(String inputString){

        SObject record = (SObject) JSON.deserialize(inputString, SObject.class);

        HDT_UTL_DatabaseService.updateSObject(record);

    }

    private void handleEntityUpdate(HDT_WRP_HerokuPostSalesManager wrapper){
        String contractCode = wrapper.requestMap.get('VERTRAG');
        String contractStatus = wrapper.requestMap.get('VERTRAG_ST');
        Date contractEndDate;
        try{
            contractEndDate = Date.valueOf(wrapper.requestMap.get('DT_FINE_VERT'));
        }catch(Exception e){
            System.debug('UTL_CLASS_ContractEndDate_error--> '+e.getMessage());
        }
        if(contractCode != null){
           handleContractUpdate(contractCode,contractStatus,contractEndDate);
        }
    }

    private void handleContractUpdate(String contractCode,String contractStatus, Date contractEndDate){
        try{
            String queryString = 'SELECT Id, Status FROM Contract WHERE SAPContractCode__c = \''+contractCode+'\'';
            String objectq = 'Contract';
            List<SObject> recordList = HDT_QR_GenericQuery.getGenericRecords(queryString, objectq);
            Contract contracRecord = (Contract) recordList[0];
            contracRecord.Status = contractStatus;
            contracRecord.EndDate = contractEndDate;
            Boolean result = HDT_UTL_DatabaseService.updateSObject(contracRecord);
        }catch(Exception ex){
            System.debug(LoggingLevel.WARN, ex.getMessage() + ' at line ' + ex.getLineNumber() + ' of HDT_UTL_HerokuPostSalesManager.handleContractUpdate method');
        }
    }
    private static void createActivity(String caseId,String orderId, String description, String type){
        String queryString = 'Select id,wrts_prcgvr__Assignees__c, wrts_prcgvr__Subject__c, wrts_prcgvr__DueDateField__c,Name from wrts_prcgvr__ActivityTemplate__c  where Name = \''+ type +'\'';
        String objectName = 'wrts_prcgvr__ActivityTemplate__c';
        List<SObject> listRecord = HDT_QR_GenericQuery.getGenericRecords(queryString, objectName);
        wrts_prcgvr__ActivityTemplate__c template = new wrts_prcgvr__ActivityTemplate__c();
        if(listRecord.size()>0){
            template = (wrts_prcgvr__ActivityTemplate__c) listRecord[0];
            wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c();
            activity.wrts_prcgvr__ActivityTemplate__c = template.Id;
            activity.Case__c = caseId;
            activity.Order__c = orderId;
            activity.CausalError__c = description;
            activity.wrts_prcgvr__Description__c = description;
            Boolean insertAct = HDT_UTL_DatabaseService.insertSObject(activity);
        }
    }
    public class HDT_UTL_RichPassException extends Exception {}
}