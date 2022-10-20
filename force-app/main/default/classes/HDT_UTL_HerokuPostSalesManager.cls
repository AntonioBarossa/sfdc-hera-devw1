@SuppressWarnings('PMD.AvoidDebugStatements, PMD.ExcessiveParameterList')
public inherited sharing class HDT_UTL_HerokuPostSalesManager {

    private static HDT_QR_HerokuPostSalesManager hpsmQr = new HDT_QR_HerokuPostSalesManager();
    private static String typeAcc ='Acconto scaduto non pagato da gestire';

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

    //Metodo Deprecato
    /* public HDT_WRP_HerokuPostSalesProva.HDT_WRP_MultiResponse createFakeResponse(Case currentCase){
        HDT_UserInputFlow__mdt cl = [SELECT FieldsJSON__c 
        FROM HDT_UserInputFlow__mdt 
        WHERE ProcessType__c = 'prova callout' 
        WITH SECURITY_ENFORCED
        LIMIT 1 ];
        String c = cl.FieldsJSON__c;
        HDT_WRP_HerokuPostSalesProva.HDT_WRP_MultiResponse mrrResponse = 
            (HDT_WRP_HerokuPostSalesProva.HDT_WRP_MultiResponse) JSON.deserialize(c,HDT_WRP_HerokuPostSalesProva.HDT_WRP_MultiResponse.class);
        System.debug(LoggingLevel.DEBUG, 'Case Phase --> '+currentCase.TecnicalPhase__c);
        if(currentCase.TecnicalPhase__c == 'Da Inviare'){
            return mrrResponse;
        } else {
            return null;
        }
    } */

    public List<HDT_WRP_HerokuPostSalesManager> manipulateResponse(wrts_prcgvr.MRR_1_0.MultiResponse responseMrr){

        List<HDT_WRP_HerokuPostSalesManager> responseResults = new List<HDT_WRP_HerokuPostSalesManager>();
        
        try{
            responseResults.add(new HDT_WRP_HerokuPostSalesManager(responseMrr.responses[0].objects[0].fields, responseMrr.responses[0].header.requestType));
        }catch(Exception ex){
            System.debug(LoggingLevel.DEBUG, 'Error in Heroku Response');
        }
        return responseResults;
    }

    public HDT_WRP_HerokuPostSalesManager manipulateRequest(HDT_WRP_MrrRequest.HDT_WRP_Request request){
        
        System.debug(LoggingLevel.DEBUG, 'UTL_CLASS_Request--> '+request);
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
                    System.debug(LoggingLevel.DEBUG, 'SRV_Class_result--> '+responseResult.responseMap.get('result'));
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
                    System.debug(LoggingLevel.DEBUG, 'Error non existing request');
                    return null;
                }
            }
        }
        if(responseResults.size()<=0){
            phase = 'Comunicazione verso Heroku KO';
            errorMessage = 'Errore nella risposta da Heroku';
        }
        if(currentCase.Phase__c  == 'Da Inviare'
        || currentCase.Phase__c  == 'Inviata a SAP'
        || currentCase.Phase__c == 'Preventivo accettato' 
        || currentCase.Phase__c == 'Esito OK da SAP' // per le autoletture da cliente.
        || currentCase.Phase__c == 'Comunicazione verso Heroku KO'
        || currentCase.Phase__c == 'Annullamento - Da inviare'
        || currentCase.Phase__c == 'In Lavorazione' /* Disattivazioni VAS */){

            System.debug(LoggingLevel.DEBUG, 'SRV_Class_Phase--> '+phase);
            System.debug(LoggingLevel.DEBUG, 'SRV_Class_HerokuPracticeCode--> '+herokuCode);

            caseNew.Id = currentCase.Id;
            caseNew.TecnicalPhase__c = phase;
            caseNew.Description = errorMessage;
            if(herokuCode != null && herokuCode != ''){
                caseNew.HerokuPracticeCode__c = herokuCode;
            }
            if(dlCode != null && dlCode != ''){
                caseNew.DistributorPracticeCode__c = dlCode;
            }
            /*if(sendDlDate != null && sendDlDate != ''){
                caseNew.SendToDistributorDate__c = Date.valueOf(sendDlDate);
            }*/
            if(herokuCancellationCode != null && herokuCancellationCode != ''){
                caseNew.CancellationHerokuPracticeCode__c = herokuCancellationCode;
            }

            caseUpdate.add(caseNew);
            HDT_UTL_DatabaseService.updateSObject(caseUpdate);
            if(currentCase.Type == 'Allineamento Anagrafica' && phase == 'Esito OK da SII'){
                caseNew.TecnicalPhase__c = '';
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
        // String codPrestazione = reqWrp.requestMap.get('COD_PRESTAZIONE');
        String codPresa = reqWrp.requestMap.get('COD_PRESA');
        String codPraticaDl = reqWrp.requestMap.get('COD_PRAT_DISTR');
        String numPrev = reqWrp.requestMap.get('NUMPREV');
        String expectedExec = reqWrp.requestMap.get('TEMP_ES_PREV');
        String codErrAeeg = reqWrp.requestMap.get('CODERR_AEEG');
        HDT_QR_HerokuPostSalesManager qrClass = new HDT_QR_HerokuPostSalesManager();
        //CHECK CROSS MINIMUM FIELD
        if(String.isBlank(method)){
            throw new HDT_UTL_RichPassException('Required Field Missing: Method');
        }
        
        //START>> 27/07/2021 costanzo.lomele@webresults.it - campo company
        if(!String.isBlank(reqWrp.requestMap.get('CMP'))){
            currentCase.ExternalUserCompany__c = reqWrp.requestMap.get('CMP');
        }
        //END>> 27/07/2021 costanzo.lomele@webresults.it - campo company
        //START>> 23/08/2021 costanzo.lomele@webresults.it - nuovi sviluppi cb scarti, ricezione fasi monitorate su reports
        if(!String.isBlank(reqWrp.requestMap.get('FASE'))){
            currentCase.TrackingDiscardPhase__c = reqWrp.requestMap.get('FASE');
        }
        //END>> 23/08/2021 costanzo.lomele@webresults.it - nuovi sviluppi cb scarti, ricezione fasi monitorate su reports
        if(String.isBlank(reqWrp.requestMap.get('FASE'))  && String.isBlank(reqWrp.requestMap.get('ATTIVITA')) && !method.equalsIgnoreCase('AddAttivita') && !method.equalsIgnoreCase('aggiornaRCU') && !method.equalsIgnoreCase('AggiornaAppuntamento')){
            //gestione scarti
            return caseUpdate;
        }
        //INIT VARIABLE FOR NOTIFICATION ON CASE
        if(method.equalsIgnoreCase('esito_intermedio') || method.equalsIgnoreCase('esito_finale') || method.equalsIgnoreCase('AddAttivita')){
            
            if(String.isBlank(recordId) && String.isBlank(caseNumber)) {
                throw new HDT_UTL_RichPassException('Required Field Missing: RecordId OR CaseNumber');
            }
            
            if(caseNumber != null && String.isNotBlank(caseNumber)){
                caseNumber = caseNumber.replace('/','');
            }
            caseParam = recordId != null? recordId:caseNumber;
            recordCase = hpsmQr.getCaseRecord(caseParam);
            currentCase.Id = recordCase.Id;
            currentCase.Type = recordCase.Type;
            currentPhase = recordCase.Phase__c;
            quotationType = recordCase.QuotationType__c;
            nextPhase = reqWrp.requestMap.get('FASE');
            storno = reqWrp.requestMap.get('STORNO');
            activity = reqWrp.requestMap.get('ATTIVITA');
            String errDescr = reqWrp.requestMap.get('NOTE_ERR')!=null ? reqWrp.requestMap.get('NOTE_ERR') : '';
            String testoErr = reqWrp.requestMap.get('TESTO_ERRR')!=null ? reqWrp.requestMap.get('TESTO_ERRR') : '';
            String utenza = reqWrp.requestMap.get('UTENZA')!=null ? reqWrp.requestMap.get('UTENZA') : '';
            String cmp = reqWrp.requestMap.get('CMP')!=null ? reqWrp.requestMap.get('CMP') : '';
            String dataElab = reqWrp.requestMap.get('DATA_ELABORAZIONE')!=null ? reqWrp.requestMap.get('DATA_ELABORAZIONE') :  
                String.isNotBlank(reqWrp.requestMap.get('DATA_EVENTO')) ? reqWrp.requestMap.get('DATA_EVENTO') : '';
            Map<String, String> mapActivityField = new Map<String, String>();
            mapActivityField.put('NOTE_ERR',errDescr);
            mapActivityField.put('UTENZA',utenza);
            mapActivityField.put('CMP',cmp);
            mapActivityField.put('DATA_ELABORAZIONE',dataElab);
            //EVERIS: Gestione Scarti SAP
            if(errDescr.containsIgnoreCase('Pratica in attesa') && 
               nextPhase.equalsIgnoreCase('Errore Lavorazione SAP') &&
               String.valueOf(recordCase.get('Type')).equalsIgnoreCase('Rettifica Consumi') && 
               String.valueOf(recordCase.get('Subprocess__c')).equalsIgnoreCase('Errore Stima Consumi')){
                nextPhase = 'Pratica In Attesa';
                currentCase.Description = errDescr;
            }else if(String.valueOf(recordCase.get('Type')).containsIgnoreCase('Autolettura') && String.isNotBlank(activity) && (activity.equalsIgnoreCase('Esito ricevuto su richiesta chiusa') || activity.equalsIgnoreCase('Eliminato esito in scarto'))){
                String description = String.isNotBlank(recordCase.Description)?recordCase.Description:'';
                currentCase.Description = errDescr + '\n' + description;
            }
            else{
                HDT_UTL_Scarti.handleHerokuResponse(recordCase.Id, activity, nextPhase,mapActivityField);
            }
            //Gestione Esito Appuntamento;
            HDT_SRV_AppointmentAgenda appService = new HDT_SRV_AppointmentAgenda();
            appService.updateExtraSystemAppointment(nextPhase, recordCase.Id, testoErr,mapActivityField);
            //fine Gestione Esito Appuntamento;
        }
        if(method.equalsIgnoreCase('aggiornaRCU')){
            // if(String.isBlank(codServizio) || String.isBlank(codPrestazione)){
            //     throw new HDT_UTL_RichPassException('Required Field Missing: Codice Servizio or Codice Prestazione');
            // }

            if(String.isBlank(codServizio)){
                throw new HDT_UTL_RichPassException('Required Field Missing: Codice Servizio');
            }
            
            if(String.isBlank(codPresa) && String.isBlank(codPraticaDl)) {
                throw new HDT_UTL_RichPassException('Required Field Missing: Codice Presa or Codice Pratica DL');
            }
            
            currentCase = HDT_SRV_AnagAlignment.handleAnagAlignmentHeroku(reqWrp);
            currentCase = qrClass.getCaseRecord(currentCase.Id);
            caseUpdate.add(currentCase);
            return caseUpdate;
        }else if(method.equalsIgnoreCase('esito_intermedio')){
            if(nextPhase != null && nextPhase != ''){
                //Gestione ad hoc per E150 Annullamento - Esito OK/KO da DL/SII
                // if((nextPhase.equalsIgnoreCase('Esito OK da DL/SII') || nextPhase.equalsIgnoreCase('Esito KO da DL/SII')) && currentPhase.indexOf('Annullamento') > -1){
                Set<String> nextPhaseSet = new Set<String>{'Esito OK da DL/SII','Esito KO da DL/SII','Esito OK da DBO', 'Esito KO da DBO'};
                if(nextPhaseSet.contains(nextPhase) && currentPhase.indexOf('Annullamento') > -1){
                        nextPhase = 'Annullamento - ' + nextPhase;
                }
                currentCase.Phase__c = nextPhase;
            }
            if(reqWrp.requestMap.get('COD_PRAT_DISTR') != null && reqWrp.requestMap.get('COD_PRAT_DISTR') != '' 
                && !(currentPhase.indexOf('Annull') > -1)){
                currentCase.DistributorPracticeCode__c = reqWrp.requestMap.get('COD_PRAT_DISTR');
            }
            /*if(reqWrp.requestMap.get('DT_INVIO_DL') != null && reqWrp.requestMap.get('DT_INVIO_DL') != ''){
                currentCase.SendToDistributorDate__c = Date.valueOf(reqWrp.requestMap.get('DT_INVIO_DL'));
            }*/
            //@frpanico aggiunto DATA_EVENTO poiche DT_INVIO_DL sembra non venir inviato
            if(reqWrp.requestMap.get('DATA_EVENTO') != null && reqWrp.requestMap.get('DATA_EVENTO') != '' && nextPhase != null && nextPhase.equalsIgnoreCase('Inviato al DL'))
            {
                currentCase.SendToDistributorDate__c = DateTime.valueOf(reqWrp.requestMap.get('DATA_EVENTO'));
            }
            if(reqWrp.requestMap.get('IMP_PREV_DIST') != null && reqWrp.requestMap.get('IMP_PREV_DIST') != ''){
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
            if(reqWrp.requestMap.get('ANNOTAZIONI') != null && reqWrp.requestMap.get('ANNOTAZIONI') != ''){
                String description = recordCase.Description != null?recordCase.Description:'';
                currentCase.Description = nowDateFormat + ': ' + reqWrp.requestMap.get('ANNOTAZIONI') + '\n' + description;
            }
            if(reqWrp.requestMap.get('COD_CAUSALE') != null && reqWrp.requestMap.get('COD_CAUSALE') != ''){
                currentCase.CancellationReasonCode__c = reqWrp.requestMap.get('COD_CAUSALE');
            }
            String noteAnn = recordCase.CancellationNote__c != null?recordCase.CancellationNote__c:'';
            if(reqWrp.requestMap.get('ANNOTAZIONI_ANN') != null && reqWrp.requestMap.get('ANNOTAZIONI_ANN') != ''){
                noteAnn = nowDateFormat + ': ' + reqWrp.requestMap.get('ANNOTAZIONI_ANN') + '\n' + noteAnn;
            }
            if(reqWrp.requestMap.get('NOTE_ANN') != null && reqWrp.requestMap.get('NOTE_ANN') != ''){
                noteAnn = nowDateFormat + ': ' + reqWrp.requestMap.get('NOTE_ANN') + '\n' + noteAnn;
            }
            System.debug(LoggingLevel.DEBUG, 'NoteAnn: '  + noteAnn);
            currentCase.CancellationNote__c = noteAnn;
            if(STRING.isNotBlank(reqWrp.requestMap.get('NOTE_ERR'))){
                currentCase.DiscardDescription__c=HDT_UTL_Accents.removeDiacritics(reqWrp.requestMap.get('NOTE_ERR')) + '\n';
            }
            if(STRING.isNotBlank(reqWrp.requestMap.get('DES_ERR_AEEG'))){
                String discardDescription = currentCase.DiscardDescription__c != null?currentCase.DiscardDescription__c:'';
                currentCase.DiscardDescription__c= discardDescription + HDT_UTL_Accents.removeDiacritics(reqWrp.requestMap.get('DES_ERR_AEEG')) +  '\n';
            }
            if(STRING.isNotBlank(reqWrp.requestMap.get('TESTO_ERRR'))){
                String discardDescription = currentCase.DiscardDescription__c != null?currentCase.DiscardDescription__c:'';
                currentCase.DiscardDescription__c = discardDescription + HDT_UTL_Accents.removeDiacritics(reqWrp.requestMap.get('TESTO_ERRR'));
            }
            if(STRING.isNotBlank(reqWrp.requestMap.get('ANNOTAZIONI'))){
                String discardDescription = currentCase.DiscardDescription__c != null?currentCase.DiscardDescription__c:'';
                currentCase.DiscardDescription__c = discardDescription + HDT_UTL_Accents.removeDiacritics(reqWrp.requestMap.get('ANNOTAZIONI'));
            }
            if(currentPhase.indexOf('Annull') > -1 && reqWrp.requestMap.get('COD_PRAT_UTENTE') != null && reqWrp.requestMap.get('COD_PRAT_UTENTE')!= ''){
                if(String.isBlank(recordCase.CancellationHerokuPracticeCode__c)){
                    currentCase.CancellationHerokuPracticeCode__c = reqWrp.requestMap.get('COD_PRAT_UTENTE');
                }
            }
            if(reqWrp.requestMap.get('FATTIB_TEC') != null && reqWrp.requestMap.get('FATTIB_TEC') != ''){
                if(reqWrp.requestMap.get('FATTIB_TEC').equalsIgnoreCase('SI')){
                    currentCase.TechnicalFeasibility__c = 'Si';
                } else {
                    currentCase.TechnicalFeasibility__c = 'No';
                }
            }
            if(reqWrp.requestMap.get('NOTE') != null && reqWrp.requestMap.get('NOTE') != ''){
                String note = recordCase.Note__c != null?recordCase.Note__c:'';
                currentCase.Note__c =  nowDateFormat + ': ' + reqWrp.requestMap.get('NOTE') + '\n' + note;
            }
            if(reqWrp.requestMap.get('DT_MAX_PREV') != null && reqWrp.requestMap.get('DT_MAX_PREV') != ''){
                HDT_SRV_DataEnrichmentPostSales enrichSrv = new HDT_SRV_DataEnrichmentPostSales();
                Date dtMaxPrev = null;
                try{
                    dtMaxPrev = Date.valueOf(reqWrp.requestMap.get('DT_MAX_PREV'));
                } catch(Exception e) {
                     System.debug(LoggingLevel.DEBUG, 'DT_MAX_PREV Exception -> ' + e.getMessage());
                }
                
                if(dtMaxPrev == null){
                    try{
                       dtMaxPrev = enrichSrv.getDateFromString(reqWrp.requestMap.get('DT_MAX_PREV'));
                    }
                    catch(Exception e){
                         System.debug(LoggingLevel.DEBUG, 'DT_MAX_PREV Exception -> ' + e.getMessage());
                    }
                }
                try{
                    if(recordCase.Cluster__c == 'Preventivi'){
                    	currentCase.QuotationValidityDate__c = dtMaxPrev;
                    } else if(nextPhase.equalsIgnoreCase('Esito OK Riduzione Potenza')){
                        currentCase.PowerReductionDate__c = dtMaxPrev;
                    } else if((nextPhase.equalsIgnoreCase('Esito OK da DL') || nextPhase.equalsIgnoreCase('Esito KO da DL')) && recordCase.Cluster__c.equalsIgnoreCase('Morosità')){
                        currentCase.ExecutionDate__c = dtMaxPrev;
                        if(recordCase.Type.equalsIgnoreCase('Riattivazione Fornitura')){
                        	currentCase.PaymentDate__c	= dtMaxPrev;
                        }
                    }
                } catch(Exception e) {
                    System.debug(LoggingLevel.DEBUG, 'DT_MAX_PREV assignment Exception -> ' + e.getMessage());
                }
            }
            
            //Data Annullamento
            if(reqWrp.requestMap.get('DATA') != null){
                try{
                    currentCase.CancellationRequestDate__c	= Date.valueOf(reqWrp.requestMap.get('DATA'));
                } catch (Exception e){
                    System.debug(LoggingLevel.DEBUG, 'DATA Exception -> ' + e.getMessage());
                }
            }
            
            // Esito dal DL ricevuto su autolettura chiusa, non prevediamo un cambio di fase ma solo una nota sul Case.
            if(currentPhase.equalsIgnoreCase('Validazione OK DL simulata') && activity != null && activity.equalsIgnoreCase('Esito ricevuto su richiesta chiusa')){
                currentCase.Phase__c = currentPhase; // non sono previsti cambi di fase.
                String currentDescription = recordCase.Description != null?recordCase.Description:'';
                String newDescription = nowDateFormat + ': ' + activity + '\n';
                currentCase.Description = newDescription + '\n' + currentDescription;
            }

            //Creare attività solo se esito successivo ad annullato
            if(('Validazione OK DL simulata'.equalsIgnoreCase(currentCase.Phase__c) || 'Validazione OK da DL'.equalsIgnoreCase(currentCase.Phase__c)) && 'Annullato'.equalsIgnoreCase(currentPhase)){
                createActivity(currentCase.Id,null, 'Gestione M01/M02', 'Gestione M01/M02', 'Gestione M01/M02');
                //Se la fase è in Annullato allora non viene cambiata.
                if ('Annullato'.equalsIgnoreCase(currentPhase)){
                    currentCase.Phase__c = currentPhase; 
                }
            }

        }else if(method.equalsIgnoreCase('esito_finale')){
            //HDT_SRV_DataEnrichmentPostSales enrichSrv = new HDT_SRV_DataEnrichmentPostSales();
            String noteSap = reqWrp.requestMap.get('NOTA_HK');
            String odv = reqWrp.requestMap.get('VBELN');
            String fatturaSap = reqWrp.requestMap.get('FATTURA');
            //String contractCode = reqWrp.requestMap.get('VERTRAG');
            String paymentDate = reqWrp.requestMap.get('DT_CREA');
            String currentDescription = recordCase.Description != null?recordCase.Description:'';
            String contractAccount = reqWrp.requestMap.get('VKONT');
            //START>>>marco.arci@webresults.it Gestione Risposta per postSales Ambiente
            String implant = reqWrp.requestMap.get('ANLAGE');
            //String implantStatus = reqWrp.requestMap.get('ANLAGE_ST');
            String contractCode = reqWrp.requestMap.get('VERTRAG');
            String contractStatus = reqWrp.requestMap.get('VERTRAG_ST');
            //END>>>marco.arci@webresults.it Gestione Risposta per postSales Ambiente
            String newDescription = '';
            
            Boolean noActionNeeded = false;
            if(currentPhase.indexOf('KO') > -1 && nextPhase.equalsIgnoreCase('Completata')){
                noActionNeeded = true;//no action needed
            }else if(currentPhase.equalsIgnoreCase('Annullato') && nextPhase.equalsIgnoreCase('Completata')){
                noActionNeeded = true;//no action needed
            }else if(currentPhase.equalsIgnoreCase('Dati Tecnici Ricevuti') && nextPhase.equalsIgnoreCase('Completata')){
                currentCase.Phase__c = 'Inviare preventivo';
            }else if(recordCase.Type.equalsIgnoreCase('Fiscale') && nextPhase.equalsIgnoreCase('Completata') && recordCase.CalculationBlock__c){
                currentCase.Phase__c = 'Elaborazione Manuale';
            /**@frpanico 2022-04-06
             * Nel caso del processo Rimborso
             * Vi e' uno step di gestione manuale alla ricezione del completata da Heroku
             * nelle casistiche
             * - Iban Estero
             * - Modalita' di rimborso "Assegno"
             * - Modalita' di rimboso "Compensazione" e residuo delle partite selezionate diverso da 0
             * In queste casistiche la fase viene impostata a "Elaborazione Manuale"
             */
            }else if(recordCase.Type.equalsIgnoreCase('Rimborso') && nextPhase.equalsIgnoreCase('Completata') 
                && (recordCase.IbanIsForeign__c 
                || recordCase.RefundMethod__c.equalsIgnoreCase('Assegno')
                || (recordCase.RefundMethod__c.equalsIgnoreCase('Compensazione') && recordCase.TotalResidue__c != 0))){
                currentCase.Phase__c = 'Elaborazione Manuale';
            }else if(recordCase.Type.equalsIgnoreCase('Allineamento Anagrafica') && nextPhase.equalsIgnoreCase('Completata') && (!recordCase.Phase__c.equalsIgnoreCase('Esito OK da SII') && !recordCase.Phase__c.equalsIgnoreCase('Errore Lavorazione SAP'))){
                noActionNeeded = true;//no action needed
            }
            else{
                currentCase.Phase__c = nextPhase;
                Map<String, Object> extraParams = new Map<String,Object>();
                extraParams.put('oldContractCode',recordCase?.ContractCode__c); 
                handleEntityUpdate(reqWrp, extraParams);
            }
            System.debug(LoggingLevel.DEBUG, 'handleRequest - no Action Needed');

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
            if(paymentDate != null && paymentDate != '' && recordCase.Type.equalsIgnoreCase('Riattivazione Fornitura')){
                try{
                    Date payDate = Date.valueOf(paymentDate);
                    currentCase.PaymentDate__c = payDate;
                } catch(Exception e) {
                    System.debug(LoggingLevel.DEBUG, 'Exception: ' + e.getMessage() + ' at line: ' + e.getLineNumber());
                }
            }
            /**@frpanico 2022-05-31
             * Aggiornamento CA
             */
            if(contractAccount != null && String.isNotBlank(contractAccount))
            {
                BillingProfile__c ca = new BillingProfile__c();
                ca.Id = recordCase.BillingProfile__c;
                ca.ContractAccountCode__c = contractAccount;
                HDT_UTL_DatabaseService.updateSObject(ca);
            }
            //START>>>marco.arci@webresults.it Gestione Risposta per postSales Ambiente
            if('Ambiente'.equalsIgnoreCase(recordCase.Commodity__c)){
                Contract contractAmb = new Contract();
                ServicePoint__c spAmb = new ServicePoint__c();
                if(implant != null && implant != recordCase.ServicePoint__r.SAPImplantCode__c){
                    spAmb.Id = recordCase.ServicePoint__c;
                    spAmb.SAPImplantCode__c = implant;
                }
                /*
                if(implantStatus != null && implantStatus != recordCase.ServicePoint__r.Status__c ){
                    spAmb.Id = recordCase.ServicePoint__c;
                    spAmb.Status__c = implantStatus;
                }
                */
                if(contractCode != null && contractCode != recordCase.Contract__r.SAPContractCode__c ){
                    contractAmb.Id = recordCase.Contract__c;
                    contractAmb.SAPContractCode__c = contractCode;
                }
                if(contractStatus != null && 
                (contractStatus != recordCase.servicePoint__r.SapContractStatus__c ||
                contractStatus != recordCase.Contract__r.Status)){
                    contractAmb.Id = recordCase.Contract__c;
                    spAmb.Id = recordCase.ServicePoint__c;
                    contractAmb.Status = contractStatus;
                    spAmb.SapContractStatus__c = contractStatus;
                }
                DateTime endDateTimeContractAmb = DateTime.valueOf(reqWrp.requestMap.get('DATA_EVENTO'));
                Date endDateContractAmb = date.newinstance(endDateTimeContractAmb.year(), endDateTimeContractAmb.month(), endDateTimeContractAmb.day()); 
                if( endDateContractAmb != null && 'Cessazione'.equalsIgnoreCase(recordCase.Type) ){
                    contractAmb.Id = recordCase.Contract__c;
                    contractAmb.EndDate = endDateContractAmb; 
                }
                if(contractAmb.Id != null){
                    HDT_UTL_DatabaseService.updateSObject(contractAmb);
                }
                if(spAmb.Id != null){
                    HDT_UTL_DatabaseService.updateSObject(spAmb);
                }
            }
            //END>>>marco.arci@webresults.it Gestione Risposta per postSales Ambiente

        }else if(method.equalsIgnoreCase('AddAttivita')){
            String type = reqWrp.requestMap.get('TIPO_ATTIVITA');
            String message = reqWrp.requestMap.get('MESSAGGIO');
            if(String.isNotBlank(type) 
                && String.isNotBlank(recordCase.Type) 
                && (recordCase.Type.equals('Prescrizione Fatture') || recordCase.Type.equalsIgnoreCase('Piano Rateizzazione') || recordCase.Type.equalsIgnoreCase('Comunicazione Pagamento')) 
                && !(type.containsIgnoreCase('Esito Rateizzazione OK'))){
                    if(type.equalsIgnoreCase('Piano rate OK Acc. pagato')){
                        type = 'Acconto paperless pagato';
                    }
                    else if(type.equalsIgnoreCase('KO Acc No pag rate Annullate')){
                        type = 'Acconto Paperless Non Pagato';
                        //close activity Acconto scaduto non pagato da gestire if exist
                        List<wrts_prcgvr__Activity__c> existingAct = [SELECT Id, Approved__c, case__c, owner.name, wrts_prcgvr__Description__c, Name FROM wrts_prcgvr__Activity__c WHERE Case__c = :currentcase.Id AND wrts_prcgvr__Description__c=:typeAcc];
                        if(existingAct.size()>0){
                            HDT_UTL_Scarti.updateCloseDiscardActivity(existingAct[0].Id);
                        }
                    }
                currentCase.Phase__c = type; 
            }
            if(String.isNotBlank(type) && (recordCase.Type.equalsIgnoreCase('Comunicazione Pagamento') || recordCase.Type.equalsIgnoreCase('Promessa di Pagamento Ente')) && type.equalsIgnoreCase('Pratica Gestita')){
                currentCase.Phase__c = 'Completata';
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
            if(currentCase.Phase__c == 'Acconto Paperless Non Pagato'){
                HDT_UTL_DatabaseService.updateSObject(currentCase);
                currentCase.Phase__c = 'Piano Rata Annullato';  
            }
            updateFuture(JSON.serialize(currentCase));
            return caseUpdate;
        }else if (method.equalsIgnoreCase('AggiornaAppuntamento')){
            currentCase.Id = recordId;
            HDT_SRV_AppointmentAgenda agendaService = new HDT_SRV_AppointmentAgenda();
            Map<String,String> clonedRequestMap = reqWrp.requestMap.clone();
            clonedRequestMap.put('PROCESS_CATEGORY','postsales');
            String responseMethod = agendaService.handleAppointmentUpdate(clonedRequestMap);
            if (String.isNotEmpty(responseMethod)){
                throw new HDT_UTL_RichPassException(responseMethod);
            }
        }else{
            throw new HDT_UTL_RichPassException('Method non definito');
        }
        if(numPrev != null && numPrev != ''){
            currentCase.QuotationNumber__c = numPrev;
        }
        if(expectedExec != null && expectedExec != ''){
            System.debug(LoggingLevel.DEBUG, '#QUOTATIONTYPE -> ' + quotationType);
            System.debug(LoggingLevel.DEBUG, '#NEXTPHASE -> ' +nextPhase);
            if(quotationType != null && quotationType.equalsIgnoreCase('Analitico') && (nextPhase.containsIgnoreCase('Dati Tecnici Ricevuti') || nextPhase.containsIgnoreCase('Ammissibilità OK'))){
                currentCase.ExpectedExecutionTime__c = expectedExec;
            }else if(quotationType != null && !quotationType.equalsIgnoreCase('Analitico')){
                currentCase.ExpectedExecutionTime__c = expectedExec;
            }
        }
        if (String.isNotBlank(codErrAeeg)){
            currentCase.DiscardCodeHeroku__c = codErrAeeg;
        }
        caseUpdate.add(currentCase);
        HDT_UTL_DatabaseService.updateSObject(caseUpdate);
        handleAfterNotify(currentCase,storno,activity,reqWrp.requestMap.get('ANNOTAZIONI_ANN'));
        return caseUpdate;
    }
    private void handleAfterNotify(Case currentCase, String storno, String activity,String discardReason){
        currentCase = hpsmQr.getCaseRecord(currentCase.Id);
        if(currentCase.Phase__c == 'Annullamento - Esito OK da DL/SII' || (currentCase.Phase__c == 'Annullato' && !'Closed'.equalsIgnoreCase(currentCase.Status))){
            currentCase.Phase__c = 'Annullato';
            currentCase.Status = 'Closed';
            updateFuture(JSON.serialize(currentCase));
        }else if(currentCase.Phase__c == 'Annullamento SII - Ricezione') {
            handlePassiveCancellation(currentCase, 'Case', storno, activity,discardReason);
        }else if(currentCase.Type == 'Allineamento Anagrafica' && currentCase.Phase__c == 'Esito OK da SII'){
            currentCase.Phase__c = 'Completata';
            currentCase.Status = 'Closed';
            updateFuture(JSON.serialize(currentCase));
        }else if(currentCase.Phase__c == 'Preventivo rifiutato – Amm OK'){
            currentCase.Phase__c = 'Completata';
            currentCase.Status = 'Closed';
            updateFuture(JSON.serialize(currentCase));
        }else if(currentCase.Phase__c.equalsIgnoreCase('Dati Tecnici Ricevuti') 
                && currentCase.Type.equalsIgnoreCase('Variazione Fase')
                && currentCase.CausalCode__c.equalsIgnoreCase('E02')){
            currentCase.Phase__c = 'Inviare preventivo';
            updateFuture(JSON.serialize(currentCase));
        }else if(currentCase.Phase__c.equalsIgnoreCase('Validazione KO da DL')){
            currentCase.Phase__c = 'Annullato';
            currentCase.Status = 'Closed';
            updateFuture(JSON.serialize(currentCase));
        /**@frpanico 21/01/2022
         * Aggiunto completamento automatico
         * per il processo di "Verifica dati al DL"
         */
        }else if(currentCase.Type.equalsIgnoreCase('Verifica Dati al DL') && currentCase.Phase__c.equalsIgnoreCase('Esito OK da DL'))
        {
            currentCase.Phase__c = 'Completata';
            currentCase.Status = 'Closed';
            updateFuture(JSON.serialize(currentCase));
        }else if(currentCase.Phase__c.equalsIgnoreCase('Esito OK da DBO')){
            //per i preventivi alla ricezione dell'esito da DBO è necessario inviare il preventivo al cliente
            if(currentCase.Cluster__c.equalsIgnoreCase('Preventivi') && !currentCase.CausalCode__c.equalsIgnoreCase('E01')){
                //DBO non invia mai il completata
                currentCase.Phase__c = 'Inviare preventivo';
            }else{
                //DBO non invia mai il completata
                currentCase.Phase__c = 'Completata';
                currentCase.Status = 'Closed';
            }
            
            updateFuture(JSON.serialize(currentCase));
        }
    }
    //se Annullamento SII - Ricezione e Storno N --> Aggiornare in Annullamento SII e dopo in Annullato SII
    //se Annullamento SII - Ricezione e Attivita Eseguire Gestione Manuale SAP --> Creazione Activity
    //se Annullamento SII - Ricezione e Storno null --> No action
    public void handlePassiveCancellation(SObject recordObj, String objectType, String storno, String activity){
        this.handlePassiveCancellation(recordObj, objectType, storno, activity,'');
    }
    public void handlePassiveCancellation(SObject recordObj, String objectType, String storno, String activity , String discardReason){
        
        if(String.isNotBlank(storno) && storno.equalsIgnoreCase('N')) {
            recordObj.put('Phase__c', 'Annullato SII');
            String status = recordObj.getSObjectType().getDescribe().getName() == 'Order' ? 'Annullato' : 'Closed';
            recordObj.put('Status',status);
            updateFutureSobject(JSON.serialize(recordObj));
        }else if(String.isNotBlank(activity) && activity.equalsIgnoreCase('Eseguire Gestione Manuale SAP')){
            /* switch on objectType {
                when 'Case' {
                    createActivity((String)recordObj.get('Id'),null, '', activity, activity);  
                }
                when else {
                    createActivity(null,(String)recordObj.get('Id'), '', activity, activity);
                }
            } */
            wrts_prcgvr__Activity__c act  = HDT_UTL_Scarti.createActivityByObjectIdAndTemplateName((String)recordObj.get('Id'),activity,objectType);
            if (act != null){
                act.wrts_prcgvr__Description__c = discardReason;
                HDT_UTL_DatabaseService.insertSObject(act);
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
        String tipoProcesso = '';
        String source = '';
        String codiceCliente = '';
        String pod = '';
        String dataDecorrenza = '';
        String recapito = '';
        String ufficioCompetente = '';
        String codiceContratto = '';
        String contoContrattuale = '';
        String sapContractCode = null;
        String containerCaseNumber = '';
        String herokuCode = '';
        String containerId = '';
        String priorita = '';
        String pivaDistr = '';
        String codFisDistr = '';
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
            tipoProcesso = reqWrp.requestMap.get('TIPO_PROCESSO');
            source = reqWrp.requestMap.get('CANALE');
            codiceCliente = reqWrp.requestMap.get('CODICE_CLIENTE');
            pod = reqWrp.requestMap.get('CODICE_PRESA');
            dataDecorrenza = reqWrp.requestMap.get('DATA_DECORRENZA');
            recapito = reqWrp.requestMap.get('RECAPTIO');
            ufficioCompetente = reqWrp.requestMap.get('UFFICIO_COMPETENTE');
            codiceContratto = reqWrp.requestMap.get('CODICE_CONTRATTO');
            contoContrattuale = reqWrp.requestMap.get('CONTO_CONTRATTUALE');
            containerCaseNumber = reqWrp.requestMap.get('SALESFORCE_KEY');
            herokuCode = reqWrp.requestMap.get('COD_PRAT_UTENTE');
            priorita = String.valueOf(reqWrp.requestMap.get('PRIORITA'));
            codFisDistr = String.valueOf(reqWrp.requestMap.get('PARTITA_IVA'));
            pivaDistr = String.valueOf(reqWrp.requestMap.get('CODICE_FISCALE'));
            if(String.isNotBlank(tipoProcesso)){
                processType = tipoProcesso;
            }
            if(String.isNotBlank(pod)){
                if(String.isNotBlank(codiceCliente)){
                    account = qrClass.getAccount(codiceCliente);
                } else {
                    account = qrClass.getAccountFromSp(pod);
                }
                if(account != null){
                    Boolean morosita = false;
                    if(String.isNotBlank(tipo) && String.isNotBlank(sottotipo)){
                        //REQUEST FROM SAP - MOROSITA
                        morosita = true;
                        
                    } else if(String.isNotBlank(cluster) && String.isNotBlank(processType)){
                        //REQUEST FROM HEROKU - SWITCH OUT - ANNULLAMENTO
                        currentCase.Cluster__c = cluster;
                        currentCase.Type = processType;
                        currentCase.Origin = source;
                        
                    } else {
                        throw new HDT_UTL_RichPassException('Non è stato possibile determinare il processo da creare');
                    }
                    System.debug(LoggingLevel.DEBUG, 'Morosità: ' + morosita);
                    
                    currentCase.Origin = source;
                    Contact contact = qrClass.getContact(account.Id);
                    currentCase.AccountId = account.Id;
                    currentCase.FiscalCode__c = account.FiscalCode__c;
                    currentCase.VatNumber__c = account.VATNumber__c;
                    currentCase.ContactId = contact?.Id;
                    currentCase.Mobile__c = contact?.MobilePhone;
                    currentCase.Email__c = contact?.Email;
                    currentCase.CompanyOwner__c = contact?.CompanyOwner__c;
                    if(String.isNotBlank(herokuCode) && herokuCode != null){
                        currentCase.HerokuPracticeCode__c = herokuCode;
                    }
                    //Aggiunto PhoneNumber
                    currentCase.PhoneNumber__c = contact.MobilePhone != null 
                        ? contact.MobilePhone
                        : contact.Phone != null 
                        ? contact.Phone
                        : '123';
                    sp = qrClass.getServicePoint(pod);
                    if(sp != null){
                        contract = qrClass.getContract(sp.Id);
                        currentCase.Contract__c = contract?.Id;
                        currentCase.ServicePoint__c = sp.Id;
                        currentCase.BillingProfile__c = Contract?.BillingProfile__c;
                        currentCase.Commodity__c = sp.CommoditySector__c;
                        sapContractCode = contract?.SAPContractCode__c;
                    }else {
                        throw new HDT_UTL_RichPassException('Non è stato possibile recuperare il Service Point', '04');
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
                            currentCase.DistributorFiscalCode__c = codFisDistr;
                            currentCase.DistributorVatNumber__c = pivaDistr;
                            //Campo riutilizzato per indicare a SAP che la pratica è stata creata da cruscotto
                            currentCase.PartialOutcome__c = 'Y';
                            if(dataDecorrenza != null){
                                try{
                                    HDT_SRV_DataEnrichmentPostSales enrichSrv = new HDT_SRV_DataEnrichmentPostSales();
                                    currentCase.EffectiveDate__c = enrichSrv.getDateFromString(dataDecorrenza);
                                } catch(Exception e){
                                    System.debug(LoggingLevel.DEBUG, 'DATA_DECORRENZA Exception -> ' + e.getMessage());
                                }
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
                            //@frpanico Added "PRIORITA"
                            if(String.isNotBlank(priorita))
                            {
                                currentCase.Priority = priorita;
                            }
                            //If SALESFORCE_KEY (aka containerCaseNumber) is not null the container exists
                            if(String.isNotBlank(containerCaseNumber)){
                                //get container case
                                containerCase = qrClass.getCaseRecord(containerCaseNumber);
                                currentCase.ParentId = containerCase.Id;
                                //get most recently created and not close related record
                                relatedCase = qrClass.getRelatedCase(containerCase.Id);
                                if(relatedCase != null){
                                    currentCase.RelatedCase__c = relatedCase.Id;
                                }
                            } else { //SALESFORCE_KEY (aka contaienrCaseNumber) is null the container does not exist
                                containerId = morUtl.handleContainer(currentCase);
                                if(String.isNotBlank(containerId)){
                                    containerCase = (Case) JSON.deserialize(containerId, Case.class);
                                    caseInsertList.add(containerCase);
                                }
                            }
                            currentCase.Phase__c = 'Bozza';
                            currentCase.Status = 'New';
                            
                            if(currentCase.Type.equalsIgnoreCase('Sospensione Fornitura'))
                            {
                                currentCase.NotCancellable__c = true;
                            }
                        }when 'Volture'{
                            currentCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_VolturaTecnica').getRecordTypeId();
                            currentCase.Cluster__c = 'Voltura';
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
                        }
                        when else{
                            throw new HDT_UTL_RichPassException('Errore tecnico nella definizione del RecordType', '04');
                        }
                    }
                }else {
                    throw new HDT_UTL_RichPassException('Non è stato possibile recuperare l\'Account di riferimento', '04');
                }
                
            }else {
                throw new HDT_UTL_RichPassException('POD non valorizzato', '01');
            }

            //It is not possible to perform DML operations before a callout
            try{
                currentCase = dataEnrichment(pod,sapContractCode,currentCase);
            }catch(Exception e){
                System.debug(LoggingLevel.DEBUG, 'Impossibile arrichire dati: ' + e.getMessage());
            }
            //add causal code
            causalCodeMdt = qrClass.getCausalCode(currentCase.Cluster__c, currentCase.Type, sp.CommoditySector__c);
            if(causalCodeMdt != null){
                currentCase.CausalCode__c = causalCodeMdt.CausalCode__c;
            }
            caseInsertList.add(currentCase);           
            HDT_UTL_DatabaseService.insertSObject(caseInsertList);
            if(currentCase.EarlyRecess__c){
                createActivity(currentCase.Id,null, '', 'Recesso Anticipato', 'Recesso Anticipato');
            }
            currentCase = qrClass.getCaseRecord(currentCase.Id);
            System.debug(LoggingLevel.DEBUG, 'Commodity: ' + currentCase.CommodityFormula__c);
            //CompatibilityCheck
            String compatibility = '';
            //checkCompatibility Method Call
            try
            {
                compatibility = HDT_UTL_MatrixCompatibility.checkCompatibilityPostSales(currentCase);
            }
            catch(Exception e)
            {
                throw new HDT_UTL_RichPassException('Errore nella verifica della compatibilita', '04');
            }
            //Check Compatibility Output
            if(String.isEmpty(compatibility))
            {
                System.debug(LoggingLevel.DEBUG, 'Compatibilita superata con successo ' + compatibility);
            }
            else
            {
                System.debug(LoggingLevel.DEBUG, 'Compatibilita non superata ' + compatibility);
                for(Case c : caseInsertList){
                    c.Phase__c = 'Bozza Annullata';
                    c.Status = 'Closed';
                    c.CancellationReason__c = 'Processo incompatibile';
                }
                HDT_UTL_DatabaseService.updateSObject(caseInsertList);
                throw new HDT_UTL_RichPassException('Processo Incompatibile', '04');
            }
            if(cluster == 'Morosita'){
                if(currentCase.ParentId == null){
                    currentCase.ParentId = containerCase.Id;
                }
                currentCase.Phase__c = 'Da Inviare';
                currentCase.Status = 'In Lavorazione';
                caseUpdateList.add(currentCase);
                HDT_UTL_DatabaseService.updateSObject(caseUpdateList);
            }
        } catch (Exception ex) {
            if(ex instanceof HDT_UTL_HerokuPostSalesManager.HDT_UTL_RichPassException)
            {
                HDT_UTL_HerokuPostSalesManager.HDT_UTL_RichPassException customEx = (HDT_UTL_HerokuPostSalesManager.HDT_UTL_RichPassException) ex;
                throw new HDT_UTL_RichPassException(customEx.getMessage(), customEx.code);
            }
            else 
            {
                throw new HDT_UTL_RichPassException('Errore nella gestione della richiesta', '04');
            }
        }
        //FinalQuery to get parentCase
        if(currentCase.Id != null){
            currentCase = qrClass.getCaseRecord(currentCase.Id);
        }
        return currentCase;
    }

    public static Case dataEnrichment(String pod, String contractCOde, Case currentCase){
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
        /*
        wrts_prcgvr__AsyncJob__c asyncJobRec = new wrts_prcgvr__AsyncJob__c();
        String result;

        asyncJobRec = hpsmQr.getAsyncJobByJobItem(recordId);

        if(asyncJobRec != null){
            if(asyncJobRec.wrts_prcgvr__Status__c == 'Chiusa'){

                result = 'OK';

            }else if(asyncJobRec.wrts_prcgvr__Status__c == 'Queued' && asyncJobRec.wrts_prcgvr__Details__c != null){
                
                result = 'Error';

            } else {

                result = 'KO';

            }
        } else {

            result = 'KO';

        }
        */

        String result = 'KO';
        List<Case> caseList = [SELECT Id,Phase__c FROM Case WHERE Id = :recordId WITH SECURITY_ENFORCED];
        if(!caseList.isEmpty() && (!caseList[0].Phase__c.equalsIgnoreCase('Da Inviare') && !caseList[0].Phase__c.equalsIgnoreCase('In Lavorazione')))
        {
            result = 'OK';
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

    private void handleEntityUpdate(HDT_WRP_HerokuPostSalesManager wrapper, Map<String, Object> extraParams){
        String contractCode = wrapper.requestMap.get('VERTRAG');
        String contractStatus = wrapper.requestMap.get('VERTRAG_ST');
        String oldContractCode = (String) extraParams.get('oldContractCode');
        Date contractEndDate;
        try{
            contractEndDate = Date.valueOf(wrapper.requestMap.get('DT_FINE_VERT'));
        }catch(Exception e){
            System.debug(LoggingLevel.DEBUG, 'UTL_CLASS_ContractEndDate_error--> '+e.getMessage());
        }
        if(contractCode != null){
           handleContractUpdate(contractCode, oldContractCode,contractStatus,contractEndDate);
        }
    }

    private void handleContractUpdate(String contractCode, String oldContractCode,String contractStatus, Date contractEndDate){
        try{
            String queryString = '';
            if(oldContractCode != null && oldContractCode != contractCode){
                queryString = 'SELECT Id, Status, SAPContractCode__c FROM Contract WHERE SAPContractCode__c = \''+oldContractCode+'\'';
            } else{
                queryString = 'SELECT Id, Status, SAPContractCode__c FROM Contract WHERE SAPContractCode__c = \''+contractCode+'\'';
            }
            String objectq = 'Contract';
            List<SObject> recordList = HDT_QR_GenericQuery.getGenericRecords(queryString, objectq);
            Contract contracRecord = (Contract) recordList[0];
            if(contractCode != contracRecord.SAPContractCode__c){
                contracRecord.SAPContractCode__c = contractCode;
            }
            if(contractStatus != null && contractStatus != ''){
                contracRecord.Status = contractStatus;
            }
            if(contractEndDate != null){
                contracRecord.EndDate = contractEndDate;
            }
            HDT_UTL_DatabaseService.updateSObject(contracRecord);
            
        }catch(Exception ex){
            System.debug(LoggingLevel.WARN, ex.getMessage() + ' at line ' + ex.getLineNumber() + ' of HDT_UTL_HerokuPostSalesManager.handleContractUpdate method');
        }
    }
    private static void createActivity(String caseId,String orderId, String description, String templateName, String type){
        String queryString = 'Select id,wrts_prcgvr__Assignees__c, wrts_prcgvr__Subject__c, wrts_prcgvr__DueDateField__c,Name from wrts_prcgvr__ActivityTemplate__c  where Name = \''+ templateName +'\'';
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
            activity.Type__c = type;
            HDT_UTL_DatabaseService.insertSObject(activity);
        }
    }
    public class HDT_UTL_RichPassException extends Exception {
        
        public String code;
        
        public HDT_UTL_RichPassException(String message, String code){
            this(message);
            this.code = code;
        }

    }
}