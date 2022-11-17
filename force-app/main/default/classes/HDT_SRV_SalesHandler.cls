/**
* @author Andrei Necsulescu (andrei.necsulescu@webresults.it)
* @date 13/04/2021
* @description HDT_SRV_SalesHandler - Class that holds business logic for MrrRequest Webservice
* @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
*/

@SuppressWarnings('PMD.CyclomaticComplexity, PMD.NcssMethodCount, PMD.AvoidDeeplyNestedIfStmts')
public with sharing class HDT_SRV_SalesHandler {

    /**@frpanico 25/10/2021
     * Added class instance
     */
    private static HDT_SRV_VoltureChangeManager voltureChangeSrv = new HDT_SRV_VoltureChangeManager();
    private static HDT_SRV_Account accountSrv = new HDT_SRV_Account();
    private static Set<String> moveOutProcesses = new Set<String>{'Cambio Uso','Voltura','Cambio Offerta Ele','Cambio Offerta Gas'};
    private static String erroreLavorazioneSapPhase = 'Errore lavorazione SAP';
    private static String annullatoPhase = 'Annullato';
    private static String annullatoStatus = 'Annullato';

    public  HDT_WRP_MrrResponse.HDT_WRP_Response manageSalesProcessCategory(HDT_WRP_MrrRequest.HDT_WRP_Request request, HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseItem) {
        
        HDT_WRP_MrrResponse.HDT_WRP_Object responseObject = new HDT_WRP_MrrResponse.HDT_WRP_Object();

        HDT_WRP_MrrResponse.HDT_WRP_Field responseField = new HDT_WRP_MrrResponse.HDT_WRP_Field();
        HDT_WRP_MrrResponse.HDT_WRP_Field responseFieldError = new HDT_WRP_MrrResponse.HDT_WRP_Field();

        HDT_QR_Order orderQr = new HDT_QR_Order();
        HDT_SRV_Order orderSrv = new HDT_SRV_Order();
        HDT_WRP_MrrRequest.HDT_WRP_Header header = request.header;
		Map<String,String> mapRequestFields = new Map<String,String>();

        switch on header.requestType {
            when 'NOTIF_ES'{
                String activityName;
                if (request.objects.get(0).fields.get(0) != null) {
				
                    For(HDT_WRP_MrrRequest.HDT_WRP_Field field : request.objects.get(0).fields){
                        if(mapRequestFields.get(field.name) == null){
                            mapRequestFields.put(field.name,field.value);
                        }
                        
                    }

                    if (mapRequestFields.get('ATTIVITA') != null) {
                        activityName = mapRequestFields.get('ATTIVITA');
                        switch on activityName{
                            when 'Gestione Switch in Ripristinatorio'{
                                HDT_UTL_ActivityCustom.createActivityWithParams(new Map<String,String>{
                                    'RecordTypeDeveloperName' => 'HDT_RT_AttivitaGestionali',
                                    'Type__c'                 => 'Gestione Switch in Ripristinatorio',
                                    'wrts_prcgvr__Status__c'               => 'Aperta',
                                    'ServicePointCode__c'     => mapRequestFields.get('COD_PDR'),
                                    'FiscalCode__c'           => mapRequestFields.get('CODICE_FISCALE'),
                                    'VATNumber__c'            => mapRequestFields.get('PIVA'),
                                    'EffectiveDate__c'        => mapRequestFields.get('DATA_DECORRENZA'),
                                    'HerokuPracticeCode__c'   => mapRequestFields.get('COD_PRAT_UTENTE')
                                });
                            }
                        }
                    }
                    if (mapRequestFields.get('METHOD')!= null && mapRequestFields.get('METHOD').equalsIgnoreCase('AggiornaAppuntamento')){
                        HDT_SRV_AppointmentAgenda agendaService = new HDT_SRV_AppointmentAgenda();
                        Map<String,String> clonedMapRequestFields = mapRequestFields.clone();
                        try{
                            clonedMapRequestFields.put('PROCESS_CATEGORY','');
                            for (HDT_WRP_MrrRequest.HDT_WRP_Field field : header.fields){
                                if (field.name.equals('PROCESS_CATEGORY')){
                                    clonedMapRequestFields.put(field.name,field.value);
                                }
                            }
                        }catch (Exception e){
                            throw new HDT_WS_MrrRequest.CustomMessageException(e.getMessage());
                        }
                        String responseMethod = agendaService.handleAppointmentUpdate(clonedMapRequestFields);
                        if (String.isNotEmpty(responseMethod)){
                            throw new HDT_WS_MrrRequest.CustomMessageException(responseMethod);
                        }
                        responseField.fieldType = 'TEXT';
                    	responseField.name = 'ESITO';
                    	responseField.value = 'OK';
                    }else if(mapRequestFields.get('RECORD_ID')!= null && mapRequestFields.get('FASE')!= null){
                        //EVERIS: START ANNULLAMENTO/RIPENSAMENTO
                        String recordId = mapRequestFields.get('RECORD_ID');
                        Order ordRetrieved;
                        if(String.isNotBlank(recordId)){
                            if(recordId instanceOf Id){
                                ordRetrieved = orderQr.getRecordByOrderId(recordId)[0];
                            }
                            else if(recordId.containsIgnoreCase('O-')) {
                                ordRetrieved = orderQr.getRecordByOrderNumber(mapRequestFields.get('RECORD_ID'))[0];
                            }else {
                                responseField.fieldType = 'TEXT';
                                responseField.name = 'ESITO';
                                responseField.value = 'KO';

                                responseFieldError.fieldType = 'TEXT';
                                responseFieldError.name = 'ERROR_MESSAGE';
                                responseFieldError.value = 'Codice Processo inesistente o malformato';

                                responseObject.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>{responseField, responseFieldError};
                                mrrResponseItem.objects.add(responseObject);

                                RestContext.response.statusCode = 400;
                                return mrrResponseItem;
                            }
                        }else {
                            responseField.fieldType = 'TEXT';
                            responseField.name = 'ESITO';
                            responseField.value = 'KO';

                            responseFieldError.fieldType = 'TEXT';
                            responseFieldError.name = 'ERROR_MESSAGE';
                            responseFieldError.value = 'RecordID obbligatorio';

                            responseObject.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>{responseField, responseFieldError};
                            mrrResponseItem.objects.add(responseObject);

                            RestContext.response.statusCode = 400;
                            return mrrResponseItem;
                        }
                        
                        String futurePhase = '';
                        String previousPhase = ordRetrieved.Phase__c;
                        String nextPhase = mapRequestFields.get('FASE');
                        String finalCancellationPhase = '';
                        String csOutcome = mapRequestFields.get('FLUSSO_CS1');
                        String errDescr = mapRequestFields.get('NOTE_ERR')!=null ? mapRequestFields.get('NOTE_ERR') : '';
                        String utenza = mapRequestFields.get('UTENZA')!=null ? mapRequestFields.get('UTENZA') : '';
                        String cmp = mapRequestFields.get('CMP')!=null ? mapRequestFields.get('CMP') : '';
                        String dataElab = mapRequestFields.get('DATA_ELABORAZIONE')!=null ? mapRequestFields.get('DATA_ELABORAZIONE') : 
                            String.isNotBlank(mapRequestFields.get('DATA_EVENTO')) ? mapRequestFields.get('DATA_EVENTO') : '';
                        String oldDescription = ordRetrieved.Description != null ? ordRetrieved.Description : '';
                        Map<String, String> mapActivityField = new Map<String, String>();
                        mapActivityField.put('NOTE_ERR',errDescr);
                        mapActivityField.put('UTENZA',utenza);
                        mapActivityField.put('CMP',cmp);
                        mapActivityField.put('DATA_ELABORAZIONE',dataElab);

                        //EVERIS: EMD ANNULLAMENTO/RIPENSAMENTO
                        //EVERIS: Gestione Scarti SAP
                        HDT_UTL_Scarti.handleHerokuResponse(ordRetrieved.Id, activityName, nextPhase, mapActivityField);
                        Order ord = new Order(); 
                        ord.Id = ordRetrieved.Id;
                        if(String.isNotBlank(csOutcome) && csOutcome.equalsIgnoreCase('Y'))
                        {
                            ord.Cs1Outcome__c = nextPhase;
                        }
                        else
                        {
                            ord.Phase__c = mapRequestFields.get('FASE');
                            //START>> 26/07/2021 costanzo.lomele@webresults.it - nuovi sviluppi cb scarti, attività anonime
                            ord.ExternalUserCompany__c = mapRequestFields.get('CMP');
                            //END>> 26/07/2021 costanzo.lomele@webresults.it - nuovi sviluppi cb scarti, attività anonime
                            Set<String> discardReasonSet = new Set<String>();
                            discardReasonSet.add(HDT_UTL_Accents.removeDiacritics(mapRequestFields.get('DES_ERR_AEEG')));
                            discardReasonSet.add(HDT_UTL_Accents.removeDiacritics(mapRequestFields.get('TESTO_ERRR')));
                            discardReasonSet.add(HDT_UTL_Accents.removeDiacritics(mapRequestFields.get('ANNOTAZIONI')));
                            discardReasonSet.remove('');
                            String discardReasonString = String.join((Iterable<String>)discardReasonSet, ' \n');
                            switch on mapRequestFields.get('FASE') {
                                when 'Ammissibilità KO' {
                                    

                                    ord.DiscardReason__c = String.isNotBlank(discardReasonString) && discardReasonString.length()>255 ? discardReasonString.substring(0,255) : discardReasonString;
                                    ord.CausalCode__c = mapRequestFields.get('CODERR');
                                    //ord.CausalCode__c = mapRequestFields.get('CODERR_AEEG'); campo sostituito
                                    ord.DiscardCodeHeroku__c = mapRequestFields.get('CODERR_AEEG');
                                    ord.HerokuPracticeCode__c = mapRequestFields.get('COD_PRAT_UTENTE');
                                    ord.DistributorPracticeCode__c = mapRequestFields.get('COD_PRAT_DISTR');
                                    ord.Description = writeDescription(mapRequestFields.get('ANNOTAZIONI'), oldDescription);

                                    /*
                                    if((ord.CausalCode__c == '032' || ord.CausalCode__c == '033')
                                        && (ordRetrieved.ProcessType__c == 'Subentro Gas' 
                                            || ordRetrieved.ProcessType__c == 'Prima Attivazione In delibera'
                                            || ordRetrieved.ProcessType__c == 'Prima Attivazione Fuori delibera'
                                    )){
                                        ord.TecnicalPhase__c = 'Annullato';
                                        ord.Status = 'Annullato';
                                    } */
                                }
                                when 'Ammissibilità OK' {



                                    ord.HerokuPracticeCode__c = mapRequestFields.get('COD_PRAT_UTENTE');
                                    ord.DistributorPracticeCode__c = mapRequestFields.get('COD_PRAT_DISTR');
                                    ord.CausalCode__c = mapRequestFields.get('COD_FLUSSO');


                                    if( mapRequestFields.get('DES_ERR_AEEG') != null) {
                                        ord.DiscardReason__c = HDT_UTL_Accents.removeDiacritics(mapRequestFields.get('DES_ERR_AEEG'));
                                        //ord.CausalCode__c = mapRequestFields.get('CODERR_AEEG'); campo sostituito
                                        ord.DiscardCodeHeroku__c = mapRequestFields.get('CODERR_AEEG');
                                    } else {
                                        ord.CausalCode__c = mapRequestFields.get('COD_FLUSSO');
                                    }
                                    //String workExecutionTime =mapRequestFields.get('TEMP_ES_PREV');
                                    if(String.isNotBlank(mapRequestFields.get('TEMP_ES_PREV')) && mapRequestFields.get('TEMP_ES_PREV').isNumeric()){
                                        ord.WorkExecutionTime__c = Decimal.valueOf(mapRequestFields.get('TEMP_ES_PREV'));
                                    }

                                    if (String.isNotBlank(mapRequestFields.get('IMP_PREV_DIST'))) {
                                        HDT_LC_CalculateEstimatedCost calculateAmount = new HDT_LC_CalculateEstimatedCost();
                                        ord.EstimateAmount__c = Decimal.valueOf(mapRequestFields.get('IMP_PREV_DIST'));
                                        Map<String,Decimal> amounts = calculateAmount.getAmounts(ordRetrieved.SupplyType__c, ord.EstimateAmount__c);
                                        ord.AdministrativeBurden__c = amounts.get('fixedAmount');
                                        ord.VariableAmount__c = amounts.get('variableAmount');
                                        Boolean isDispatcherInMtd= HDT_UTL_QuoteManagement.checkLocalDispatcher(ord.ServicePoint__r.Distributor__r.Name);
                                        Integer validityDateDelay=isDispatcherInMtd ? 90 : 30; //ExtraRete? 30 : InRete? 90 : AAA? 180 : null; Manca caso AAA
                                        ord.QuotationType__c='Predeterminabile';
                                        if(ordRetrieved.ProcessType__c.containsIgnoreCase('Prima Attivazione con modifica') 
                                            && !ordRetrieved.PhaseStory__c.containsIgnoreCase('Preventivo Accettato'))
                                        {
                                            futurePhase = 'Attesa conferma preventivo cliente';
                                        }
                                        switch on mapRequestFields.get('TIPO_INTERVENTO') {
                                            when 'Attivazione', 'Lavoro Semplice' {
                                                ord.ValidityDateEstimate__c=Date.today().addDays(validityDateDelay);
                                            }
                                        }
                                        
                                    }else{
                                        switch on mapRequestFields.get('TIPO_INTERVENTO') {
                                            when 'Lavoro Semplice' {
                                                ord.QuotationType__c='Rapido';
                                            }
                                            when 'A Preventivo', 'Lavoro Complesso'{
                                                ord.QuotationType__c='Analitico';
                                            }
                                        }
                                    }
                                }
                                when 'Dati tecnici ricevuti','Dati Tecnici Ricevuti'{
                                    HDT_UTL_HandleTechnicalData utlTechData = new HDT_UTL_HandleTechnicalData();
                                    utlTechData.sp = new ServicePoint__c(Id=ordRetrieved.ServicePoint__c);
                                    /**@frpanico 2022-04-13
                                     * Aggiunto supplytype alla variabile ord
                                     * per il calcolo degli importi fissi e variabili
                                     */
                                    ord.SupplyType__c = ordRetrieved.SupplyType__c;
                                    switch on mapRequestFields.get('COD_FLUSSO'){
                                        when 'E154'{
                                            utlTechData.handleE154Flow(mapRequestFields, ord);
                                        }
                                        when 'E150F'{
                                            utlTechData.handleE150Flow(mapRequestFields, ord);
                                        }
                                        when '0351' {
                                            utlTechData.handle351Flow(mapRequestFields, ord);
                                        }
                                        when '0300' {
                                            utlTechData.handle300Flow(mapRequestFields, ord);
                                        }
                                    }
                                }
                                when 'Errore tecnico invio a SAP', 'Flusso bloccato in assenza del precedente', 'Errore invio a DL/SII' {

                                    String finalPhase = ord.phase__c;
                                    if('Errore tecnico invio a SAP'.equalsIgnoreCase(finalPhase)){
                                        finalPhase = 'Errore comunicazione SAP';
                                    }
                                    ord.TrackingDiscardPhase__c = finalPhase;
                                    ord.phase__c=previousPhase;
                                }
                                when 'Esito KO da DL' {
                                    //Gestione Esito Appuntamento;
                                    HDT_SRV_AppointmentAgenda appService = new HDT_SRV_AppointmentAgenda();
                                    appService.updateExtraSystemAppointment('Esito KO da DL', ord.Id, discardReasonString,mapActivityField);
                                    //fine Gestione Esito Appuntamento;
                                    ord.DiscardReason__c = String.isNotBlank(discardReasonString) && discardReasonString.length()>255 ? discardReasonString.substring(0,255) : discardReasonString;
                                    ord.HerokuPracticeCode__c = mapRequestFields.get('COD_PRAT_UTENTE');
                                    ord.DistributorPracticeCode__c = mapRequestFields.get('COD_PRAT_DISTR');
                                    ord.CausalCode__c = mapRequestFields.get('COD_FLUSSO');
                                    //ord.DiscardReason__c = HDT_UTL_Accents.removeDiacritics(mapRequestFields.get('DES_ERR_AEEG'));
                                    ord.Description = writeDescription(mapRequestFields.get('ANNOTAZIONI'), oldDescription);
                                    ord.HerokuPracticeCode__c = mapRequestFields.get('COD_PRAT_UTENTE');
                                    Datetime nowDate = Datetime.now();
                                    ord.DistributorCancellationReason__c = nowDate.format('dd/MM/yyyy h:mm a') + ': ' + mapRequestFields.get('MOTIVO_ANN');
                                }
                                when 'Esito OK da DL' {
                                    //Gestione Esito Appuntamento;
                                    HDT_SRV_AppointmentAgenda appService = new HDT_SRV_AppointmentAgenda();
                                    appService.updateExtraSystemAppointment('Esito OK da DL', ord.Id, discardReasonString,mapActivityField);
                                    //fine Gestione Esito Appuntamento;
                                    HDT_UTL_HandleTechnicalData utlTechData = new HDT_UTL_HandleTechnicalData();
                                    utlTechData.sp = new ServicePoint__c(Id=ordRetrieved.ServicePoint__c);
                                    ord.DistributorPracticeCode__c = mapRequestFields.get('COD_PRAT_DISTR');
                                    ord.HerokuPracticeCode__c = mapRequestFields.get('COD_PRAT_UTENTE');
                                    ord.CausalCode__c = mapRequestFields.get('COD_FLUSSO');
                                    if(mapRequestFields.get('DT_INIZIO_VERT') != null && String.isNotBlank(mapRequestFields.get('DT_INIZIO_VERT'))){
                                        ord.SapContractActivationDate__c = mapRequestFields.get('DT_INIZIO_VERT') != null ? Date.valueOf(mapRequestFields.get('DT_INIZIO_VERT')) : null;
                                    }
                                    
                                    
                                    //Start HRAWRM-657 21/09/2021
                                    List<Id> listRecType = new List<Id>();
                                    Id rtTemporaryNewActivation        = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_TemporaneaNuovaAtt').getRecordTypeId();
                                    Id rtConnectionwithActivation      = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_ConnessioneConAttivazione').getRecordTypeId();
                                    listRecType.add(rtTemporaryNewActivation);
                                    listRecType.add(rtConnectionwithActivation);
                                    if (listRecType.contains(ordRetrieved.recordtypeId )) {
                                        List<SObject> sobjToUpdate = new List<SObject>();
                                        ord.ServicePointCode__c = mapRequestFields.get('POD');
                                        ServicePoint__c sp = new ServicePoint__c();
                                        sp.Id = ordRetrieved.ServicePoint__c;
                                        sp.Name= mapRequestFields.get('POD');
                                        sp.ServicePointCode__c = mapRequestFields.get('POD');
                                        sobjToUpdate.add(sp);
                                        List<Order> childOrders = updateOrderServicePoint(ordRetrieved.Id, ordRetrieved.ParentOrder__c, mapRequestFields.get('POD'));
                                        if(!childOrders.isEmpty())
                                        {
                                            for(Order o : childOrders)
                                            {
                                                sobjToUpdate.add(o);
                                            }
                                        }
                                        HDT_UTL_DatabaseService.updateSObject(sobjToUpdate);
                                    }
                                    //End HRAWRM-657 21/09/2021
                                    switch on mapRequestFields.get('COD_FLUSSO'){
                                        when 'E150F'{
                                            utlTechData.handleE150Flow(mapRequestFields, ord);
                                        }
                                        when '0300' {
                                            utlTechData.handle300Flow(mapRequestFields, ord);
                                        }
                                    }
                                }
                                when 'Amm. Precheck KO SII' {
                                    ord.PrecheckReasonSII__c = String.isBlank(mapRequestFields.get('DES_ERR_AEEG')) ? 
                                                                        mapRequestFields.get('TESTO_ERRR') : 
                                                                        mapRequestFields.get('DES_ERR_AEEG');
                                    ord.CausalCode__c = String.isBlank(mapRequestFields.get('CODERR_AEEG')) ? 
                                                                        mapRequestFields.get('CODERR_ES') : 
                                                                        mapRequestFields.get('CODERR_AEEG');
                                    ord.DistributorPracticeCode__c = mapRequestFields.get('COD_PRAT_DISTR');
                                    ord.HerokuPracticeCode__c = mapRequestFields.get('COD_PRAT_UTENTE');
                                    ord.DiscardReason__c = (String.isNotBlank(ord.PrecheckReasonSII__c) && String.isNotBlank(ord.CausalCode__c))? ord.CausalCode__c+' - '+ord.PrecheckReasonSII__c 
                                        : (String.isBlank(ord.CausalCode__c))? ord.PrecheckReasonSII__c : ord.CausalCode__c;

                                    if(mapRequestFields.get('CODERR_ES') == '003' || mapRequestFields.get('CODERR_ES') == '103'){
                                        ord.IsTechnicalTransfer__c = true;
                                    }
                                }
                                when 'Amm. Precheck OK SII' {
                                    ord.DistributorPracticeCode__c = mapRequestFields.get('COD_PRAT_DISTR');
                                    ord.HerokuPracticeCode__c = mapRequestFields.get('COD_PRAT_UTENTE');
                                    ord.RemiCode__c = mapRequestFields.get('EXT_CABINA_REMI');
                                    //ord.VATNumberUdb__c = mapRequestFields.get('EXT_PIVA_DISTR');
                                    if (ordRetrieved.PrecheckResultSII__c == null || ordRetrieved.PrecheckResultSII__c == '') {
                                        ord.PrecheckResultSII__c = 'OK';
                                    }
                                }
                                when 'Esito KO da SII' {
                                    ord.DiscardReason__c =  String.isNotBlank(discardReasonString) && discardReasonString.length()>255 ? discardReasonString.substring(0,255) : discardReasonString;
                                    ord.DistributorPracticeCode__c = mapRequestFields.get('COD_PRAT_DISTR');
                                    ord.HerokuPracticeCode__c = mapRequestFields.get('COD_PRAT_UTENTE');
                                    ord.CausalCode__c = mapRequestFields.get('COD_FLUSSO');
                                }
                                when 'Esito OK da SII' {
                                    ord.DistributorPracticeCode__c = mapRequestFields.get('COD_PRAT_DISTR');
                                    ord.HerokuPracticeCode__c = mapRequestFields.get('COD_PRAT_UTENTE');
                                    ord.CausalCode__c = mapRequestFields.get('COD_FLUSSO');
                                }
                                when 'Annullamento - Inviato al DL/SII'{
                                    //EVERIS: START ANNULLAMENTO/RIPENSAMENTO
                                    if(previousPhase.indexOf('Ripensamento') >-1){
                                        nextPhase = 'Ripensamento - Inviato al SII';
                                    }
                                    ord.Phase__c = nextPhase;
                                    //EVERIS: END ANNULLAMENTO/RIPENSAMENTO
                                }
                                when 'Annullamento - Ammissibilità OK', 'Annullamento - Ammissibilità KO' {
                                    //EVERIS: START ANNULLAMENTO/RIPENSAMENTO
                                    ord.CancellationHerokuPracticeCode__c = mapRequestFields.get('COD_PRAT_UTENTE');
                                    Datetime nowDate = Datetime.now();
                                    String nowDateFormat = nowDate.format('dd/MM/yyyy h:mm a');
                                    String cancellationNote = ordRetrieved.CancellationNote__c != null ? ordRetrieved.CancellationNote__c : '';
                                    if(mapRequestFields.get('ANNOTAZIONI_ANN') != null && mapRequestFields.get('ANNOTAZIONI_ANN') != '')
                                    {
                                        ord.CancellationNote__c = nowDateFormat + ': ' + mapRequestFields.get('ANNOTAZIONI_ANN') + '\n' + cancellationNote;
                                        ord.DiscardReason__c = mapRequestFields.get('ANNOTAZIONI_ANN');
                                    }
                                    if(previousPhase.indexOf('Ripensamento') >-1){
                                        nextPhase = nextPhase.replace('Annullamento', 'Ripensamento');
                                    }
                                    ord.Phase__c = nextPhase;
                                    //EVERIS: END ANNULLAMENTO/RIPENSAMENTO
                                }
                                when 'Esito OK da DL/SII'{
                                    
                                    if(previousPhase.indexOf('Annullamento') > -1) {
                                        ord.Phase__c = 'Annullamento - ' + nextPhase;
                                        finalCancellationPhase = 'Annullato';
                                        Datetime nowDate = Datetime.now();
                                        String nowDateFormat = nowDate.format('dd/MM/yyyy h:mm a');
                                        String cancellationNote = ordRetrieved.CancellationNote__c != null ? ordRetrieved.CancellationNote__c : '';
                                        if(mapRequestFields.get('NOTE_ANN') != null && mapRequestFields.get('NOTE_ANN') != ''){
                                            ord.CancellationNote__c = nowDateFormat + ': ' + mapRequestFields.get('NOTE_ANN') + '\n' + cancellationNote;
                                        }
                                    }
                                    else if(previousPhase.indexOf('Ripensamento') > -1) {
                                        ord.Phase__c = 'Ripensamento - Esito OK da SII';
                                        finalCancellationPhase = 'Ripensato';
                                    }
                                }
                                when 'Esito KO da DL/SII', 'Esito KO da DBO' {
                                    if(previousPhase.indexOf('Annullamento') > -1) {
                                        ord.Phase__c = 'Annullamento - ' + nextPhase;
                                        Datetime nowDate = Datetime.now();
                                        String nowDateFormat = nowDate.format('dd/MM/yyyy h:mm a');
                                        String cancellationNote = ordRetrieved.CancellationNote__c != null ? ordRetrieved.CancellationNote__c : '';
                                        if(mapRequestFields.get('NOTE_ANN') != null && mapRequestFields.get('NOTE_ANN') != ''){
                                            ord.CancellationNote__c = nowDateFormat + ': ' + mapRequestFields.get('NOTE_ANN') + '\n' + cancellationNote;
                                            ord.DiscardReason__c = mapRequestFields.get('NOTE_ANN');
                                        }
                                    }
                                    else if(previousPhase.indexOf('Ripensamento') > -1) {
                                        ord.Phase__c = 'Ripensamento - Esito KO da SII';
                                    }
                                }
                                when 'Errore lavorazione SAP' {
                                    ord.DiscardReason__c = String.isNotBlank(discardReasonString) && discardReasonString.length()>255 ? discardReasonString.substring(0,255) : discardReasonString;
                                    ord.HerokuPracticeCode__c = mapRequestFields.get('COD_PRAT_UTENTE');
                                }
                                when 'Dati discordanti'{
                                    ord.phase__c = mapRequestFields.get('FASE');
                                    ord.DiscardReason__c = String.isNotBlank(discardReasonString) && discardReasonString.length()>255 ? discardReasonString.substring(0,255) : discardReasonString;
                                    ord.HerokuPracticeCode__c = mapRequestFields.get('COD_PRAT_UTENTE');
                                }
                                /**@frpanico 2022-05-27
                                 * Aggiunta casistica Dati TIMOE Ricevuti
                                 */
                                when 'Dati TIMOE ricevuti'
                                {
                                    String description = '';
                                    if(mapRequestFields.get('STATO_SOSP') != null && mapRequestFields.get('STATO_SOSP') != '')
                                    {
                                        description += '\n' + '\"' + 'STATO_SOSP' + '\": ' + '\"' + mapRequestFields.get('STATO_SOSP') + '\"'; 
                                    }
                                    if(mapRequestFields.get('DATE_SOSP') != null && mapRequestFields.get('DATE_SOSP') != '')
                                    {
                                        description += '\n' + '\"' + 'DATE_SOSP' + '\": ' + '\"' + mapRequestFields.get('DATE_SOSP') + '\"'; 
                                    }
                                    if(mapRequestFields.get('INDENNIZZO') != null && mapRequestFields.get('INDENNIZZO') != '')
                                    {
                                        description += '\n' + '\"' + 'INDENNIZZO' + '\": ' + '\"' + mapRequestFields.get('INDENNIZZO') + '\"'; 
                                    }
                                    if(mapRequestFields.get('DATE_SOST') != null && mapRequestFields.get('DATE_SOST') != '')
                                    {
                                        description += '\n' + '\"' + 'DATE_SOST' + '\": ' + '\"' + mapRequestFields.get('DATE_SOST') + '\"'; 
                                    }
                                    if(mapRequestFields.get('DATA_SALVAGUARDIA') != null && mapRequestFields.get('DATA_SALVAGUARDIA') != '')
                                    {
                                        description += '\n' + '\"' + 'DATA_SALVAGUARDIA' + '\": ' + '\"' + mapRequestFields.get('DATA_SALVAGUARDIA') + '\"'; 
                                    }
                                    if(mapRequestFields.get('DATA_ULT_SOSP') != null && mapRequestFields.get('DATA_ULT_SOSP') != '')
                                    {
                                        description += '\n' + '\"' + 'DATA_ULT_SOSP' + '\": ' + '\"' + mapRequestFields.get('DATA_ULT_SOSP') + '\"'; 
                                    }
                                    if(mapRequestFields.get('DT_SOSP_ATT') != null && mapRequestFields.get('DT_SOSP_ATT') != '')
                                    {
                                        description += '\n' + '\"' + 'DT_SOSP_ATT' + '\": ' + '\"' + mapRequestFields.get('DT_SOSP_ATT') + '\"'; 
                                    }
                                    if(mapRequestFields.get('MERCATO_PROV') != null && mapRequestFields.get('MERCATO_PROV') != '')
                                    {
                                        description += '\n' + '\"' + 'MERCATO_PROV' + '\": ' + '\"' + mapRequestFields.get('MERCATO_PROV') + '\"'; 
                                    }
                                    ord.Description = writeDescription(description, oldDescription);
                                }
                                when 'Completata','Esito OK da DBO' {
                                    /**@frapnico 01/02/2022
                                     * Aggiunta gestione KO
                                     * Skip Azioni
                                     */
                                    if(previousPhase.indexOf('KO') > -1)
                                    {
                                        ord.Phase__c = previousPhase;
                                        //ord.Status = 'Completed';
                                    }
                                    /*@frpanico 02/02/2022
                                     * Aggiunta gestione 
                                     * Annullato -Errore Lavorazione SAP - Annullato
                                     */
                                    else if((previousPhase.equalsIgnoreCase(erroreLavorazioneSapPhase) || previousPhase.equalsIgnoreCase(annullatoPhase))
                                        && ordRetrieved.Status.equalsIgnoreCase(annullatoStatus))
                                    {
                                        ord.Phase__c = annullatoPhase;
                                    }
                                    /**@frpanico 04/02/2022
                                     * Gestione preventivo Extra Sistema
                                     */
                                    else if(previousPhase.equalsIgnoreCase('Dati Tecnici Ricevuti') && ordRetrieved.ProcessType__c.containsIgnoreCase('Prima Attivazione con modifica'))
                                    {
                                        ord.Phase__c = previousPhase;
                                    }
                                    else
                                    {
                                        Boolean redirectPreventivo = false;
                                        switch on ordRetrieved.ProcessType__c{
                                            when 'Connessione con Attivazione', 'Aggiunta Attacco con Attivazione', 'Temporanea - Nuova Attivazione'{
                                                redirectPreventivo=true;
                                            }
                                        }                            
                                        //Start HRAWRM-657 21/09/2021
                                        List<Id> listRecordType = new List<Id>();
                                        Id rtSwitchIn           = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_SwitchIn').getRecordTypeId();
                                        Id rtChangeOffer        = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_CambioOfferta').getRecordTypeId();
                                        Id rtVultureWithSwitch  = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_VolturaConSwitch').getRecordTypeId();
                                        listRecordType.add(rtSwitchIn);
                                        listRecordType.add(rtChangeOffer);
                                        listRecordType.add(rtVultureWithSwitch);

                                        if (!listRecordType.contains(ordRetrieved.recordtypeId ) && String.isNotBlank(mapRequestFields.get('DT_CREA'))  ) {
                                            ord.EffectiveDate__c = date.valueOf( mapRequestFields.get('DT_CREA'));
                                        }
                                        //End HRAWRM-657 21/09/2021

                                        if(((mapRequestFields.get('FASE') == 'Esito OK da DBO' && !ordRetrieved.CausalCode__c.equalsIgnoreCase('E01')) || ordRetrieved.Phase__c.equalsIgnoreCase('Dati Tecnici Ricevuti')) && redirectPreventivo){
                                            ord.Phase__c = 'Inviare preventivo';
                                        }else{

                                            if(mapRequestFields.get('FASE') == 'Esito OK da DBO'){
                                                futurePhase = 'Completata';
                                                if(mapRequestFields.get('NUMPREV') != null){
                                                    ord.QuotationNumber__c = mapRequestFields.get('NUMPREV');
                                                }
                                            }
                                            /**@frpanico 04/01/2022
                                             * Aggiunto MoveOut
                                            */
                                            if(moveOutProcesses.contains(ordRetrieved.ProcessType__c))
                                            {
                                                HDT_UTL_ContractProcess.moveOut(ordRetrieved.Id, 'ContractReference__c');
                                            }
                                            ord.Description =writeDescription(mapRequestFields.get('NOTA_HK'), oldDescription);
                                            /**@frpanico 2022-05-04
                                             * Prevenzione dello sbiancamento del codice impianto SAP
                                             */
                                            if(!String.isBlank(mapRequestFields.get('ANLAGE')))
                                            {
                                                ord.SAPImplantCode__c = mapRequestFields.get('ANLAGE');
                                            }
                                            ord.OrderODV__c = mapRequestFields.get('VBELN');
                                            ord.SapContractCode__c = mapRequestFields.get('VERTRAG');
                                            ord.HerokuPracticeCode__c = mapRequestFields.get('COD_PRAT_UTENTE');
                                            if(mapRequestFields.get('PARTNER') != null)
                                                ord.CustomerCode__c = mapRequestFields.get('PARTNER');
                                            ord.Status='Activated';
                                            
                                            if(mapRequestFields.get('VKONT') != null) {
                                                ord.ContractAccountCode__c = mapRequestFields.get('VKONT');

                                                BillingProfile__c billingProfile = new BillingProfile__c();
                                                billingProfile.Id = ordRetrieved.BillingProfile__c;
                                                billingProfile.ContractAccountCode__c = mapRequestFields.get('VKONT');
                                                
                                                HDT_SRV_BillingProfile billingProfileSrv = new HDT_SRV_BillingProfile();
                                                try{
                                                    billingProfileSrv.updateRecord(billingProfile);
                                                }
                                                catch(Exception e){
                                                    throw new HDT_WS_MrrRequest.CustomMessageException('Error on Updating Billing Profile, VKONT Already not Unique - '+e.getMessage());
                                                }

                                                //Gestione CodiceCliente/Update Account - HRADTR_GV 31/03/2022
                                                Account accToUpdate = new Account();
                                                accToUpdate.Id = ordRetrieved.AccountId;
                                                if(ord.CustomerCode__c != null)
                                                {
                                                   accToUpdate.CustomerCode__c = ord.CustomerCode__c;
                                                }
                                                    accountSrv.updateRecord(accToUpdate);
                                            }
                                            if(ordRetrieved.ProcessType__c.containsIgnoreCase('Subentro') || (ordRetrieved.ProcessType__c.containsIgnoreCase('Voltura') && !ordRetrieved.PhaseStory__c.containsIgnoreCase('Voltura Rifiutata'))){
                                                mapRequestFields.put('NuovoAccount',ordRetrieved.AccountId);
                                            }
                                            if(ordRetrieved.SupplyType__c != null)
                                            {
                                                mapRequestFields.put('supplyType',ordRetrieved.SupplyType__c);
                                            }
                                            if(ordRetrieved.ImplantType__c != null)
                                            {
                                                mapRequestFields.put('implantType', ordRetrieved.ImplantType__c);
                                            }

                                            HDT_UTL_HandleTechnicalData utlTechData = new HDT_UTL_HandleTechnicalData();
                                            utlTechData.sp = new ServicePoint__c(Id=ordRetrieved.ServicePoint__c);
                                            utlTechData.handleCompletata(mapRequestFields);
                                        }
                                    }
                                }
                                when 'Annullamento SII - Ricezione'{
                                    /*@frpanico 16/12/2021
                                    * Aggiunta CancellationRequestDate__c
                                    * Utilizzato per la determinazione della 
                                    * Funzionalita Clona
                                    */
                                    ord.CancellationRequestDate__c = System.today();
                                    ord.CancellationReasonCode__c = mapRequestFields.get('COD_CAUSALE');
                                    ord.CancellationNote__c = mapRequestFields.get('ANNOTAZIONI_ANN');
                                    ord.CancellationReason__c = 'Annullamento dal SII';
                                    String annotazioni = ord.CancellationNote__c != null? ord.CancellationNote__c:'';
                                    ord.CancellationNote__c = mapRequestFields.get('NOTE_ANN') +'\n' + annotazioni;
                                    HDT_UTL_HerokuPostSalesManager utlClass = new HDT_UTL_HerokuPostSalesManager();
                                    Order cancellationOrder = new Order();
                                    cancellationOrder.Id = ord.Id;
                                    utlClass.handlePassiveCancellation(cancellationOrder, 'Order', mapRequestFields.get('STORNO'), mapRequestFields.get('ATTIVITA'),mapRequestFields.get('ANNOTAZIONI_ANN'));
                                }
                                when 'Annullato'{
                                    if(mapRequestFields.get('NOTE_ANN') != null){
                                        ord.CancellationNote__c = mapRequestFields.get('NOTE_ANN');
                                        //ord.DiscardReason__c = mapRequestFields.get('NOTE_ANN');
                                    }
                                }
                            }
                        }

                        orderSrv.updateRecord(ord);
                    	responseField.fieldType = 'TEXT';
                    	responseField.name = 'ESITO';
                    	responseField.value = 'OK';

                        if(String.isNotBlank(futurePhase))
                        {
                            ord.Phase__c = futurePhase;
                            updateFuture(JSON.serialize(ord));
                        }

                        //EVERIS: START ANNULLAMENTO/RIPENSAMENTO
                        if (String.isNotBlank(finalCancellationPhase)) {
                            ord.Phase__c = finalCancellationPhase;
                            ord.Status = 'Completed';
                            updateFuture(JSON.serialize(ord));
                        }
                        //EVERIS: END ANNULLAMENTO/RIPENSAMENTO  

                        //FIX Annullamento automatico per morosità
                        if(ord.Phase__c != null && ord.Phase__c == 'Ammissibilità OK' && (ord.DiscardCodeHeroku__c == '034' || ord.DiscardCodeHeroku__c == '033' || ord.DiscardCodeHeroku__c == '032')
                                     && (ordRetrieved.ProcessType__c == 'Subentro Gas' 
                                         || ordRetrieved.ProcessType__c == 'Prima Attivazione In delibera'
                                         || ordRetrieved.ProcessType__c == 'Prima Attivazione Fuori delibera'
                                 ))
                                 {
                                     //ord.TecnicalPhase__c = '';
                                     ord.Status = 'Annullato';
                                     ord.Phase__c = 'Annullato'; //HRAWRM-460
                                     updateFuture(JSON.serialize(ord));
                                 }
                        //Annullamento automatico per precheck ko su precedente cliente
                        if(ord.Phase__c != null && ord.Phase__c.equalsIgnoreCase('Dati TIMOE Ricevuti') && ordRetrieved.IsTechnicalTransfer__c){
                            ord.CancellationReason__c = 'Revoca ai sensi del comma 8.2 del TIMG';
                            ord.CancellationReasonDescription__c = 'Revoca ai sensi del comma 8.2 del TIMG';
                            ord.CancellationReasonCode__c = 'SG02';
                            ord.CancellationRequestDate__c = Date.Today();
                            ord.Phase__c = 'Annullamento - Da inviare';
                            orderSrv.updateRecord(ord);
                        }
                    }else if(String.isNotBlank(mapRequestFields.get('RECORD_ID')) && String.isNotBlank(activityName)){
                        //EVERIS: Gestione Scarti SAP Aggiunta logica creazione scarti se viene inviata solo l'attività
                        String recordId = mapRequestFields.get('RECORD_ID');
                        String errDescr = mapRequestFields.get('NOTE_ERR')!=null ? mapRequestFields.get('NOTE_ERR') : '';
                        String utenza = mapRequestFields.get('UTENZA')!=null ? mapRequestFields.get('UTENZA') : '';
                        String cmp = mapRequestFields.get('CMP')!=null ? mapRequestFields.get('CMP') : '';
                        String dataElab = mapRequestFields.get('DATA_ELABORAZIONE')!=null ? mapRequestFields.get('DATA_ELABORAZIONE') : 
                            String.isNotBlank(mapRequestFields.get('DATA_EVENTO')) ? mapRequestFields.get('DATA_EVENTO') : '';
                        Map<String, String> mapActivityField = new Map<String, String>();
                        mapActivityField.put('NOTE_ERR',errDescr);
                        mapActivityField.put('UTENZA',utenza);
                        mapActivityField.put('CMP',cmp);
                        mapActivityField.put('DATA_ELABORAZIONE',dataElab);
                        Order ordRetrieved;
                        if(recordId instanceOf Id){
                            ordRetrieved = orderQr.getRecordByOrderId(recordId)[0];
                        }
                        else {
                            ordRetrieved = orderQr.getRecordByOrderNumber(mapRequestFields.get('RECORD_ID'))[0];
                        }
                        HDT_UTL_Scarti.handleHerokuResponse(ordRetrieved.Id, activityName, '', mapRequestFields);
                        responseField.fieldType = 'TEXT';
                    	responseField.name = 'ESITO';
                    	responseField.value = 'OK';
                    }else{
                        responseField.fieldType = 'TEXT';
                    	responseField.name = 'ESITO';
                    	responseField.value = 'OK';
                    }

                    responseObject.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>{responseField};
                    mrrResponseItem.objects.add(responseObject);
                    
                    RestContext.response.statusCode = 200;
                    
                } else {

                    responseField.fieldType = 'TEXT';
                    responseField.name = 'ESITO';
                    responseField.value = 'KO';

                    responseFieldError.fieldType = 'TEXT';
                    responseFieldError.name = 'ERROR_MESSAGE';
                    responseFieldError.value = 'There was an issue with your request message';

                    responseObject.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>{responseField, responseFieldError};
                    mrrResponseItem.objects.add(responseObject);

                    RestContext.response.statusCode = 400;

                }                        

            }

            when 'NOTIF_VAS'{
                HDT_UTL_NotifVas.handleVasNotify(request, mrrResponseItem);
            }
            when 'RICH_PASS' {

                if (request.objects.get(0).fields.get(0) != null){

                    responseField.fieldType = 'TEXT';
                    responseField.name = 'ESITO';
                    responseField.value = 'OK';
                    responseField.rds = '';
                    responseField.rdo = '';

                    responseObject.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>{responseField};
                    mrrResponseItem.objects.add(responseObject);
                    
                    RestContext.response.statusCode = 200;
                    
                } else {

                    responseField.fieldType = 'TEXT';
                    responseField.name = 'ESITO';
                    responseField.value = 'KO';

                    responseFieldError.fieldType = 'TEXT';
                    responseFieldError.name = 'ERROR_MESSAGE';
                    responseFieldError.value = 'There was an issue with your request message';

                    responseObject.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>{responseField, responseFieldError};
                    mrrResponseItem.objects.add(responseObject);

                    RestContext.response.statusCode = 400;

                }

            }
            when 'WSLead_Callback'{
                try {
                    List<String> listFieldsReq =new List<String>{'NOMEMACROACTIVITYEASYCIM'};
                    requiredFields(listFieldsReq, request);
                    RestContext.response.statusCode = 200; 
                    HDT_UTL_LeadProcess.formCallback(request, mrrResponseItem, responseObject);
                   
                  
                } 
                catch (Exception e) {
                    mapError(e.getMessage(),responseField,responseFieldError,responseObject,mrrResponseItem);
                }
                
            }
            when 'WSLead_Winback'{
                try {
                    List<String> listFieldsReq =new List<String>{'NOMEMACROACTIVITYEASYCIM'};
                    requiredFields(listFieldsReq, request);
                    RestContext.response.statusCode = 200;
                    HDT_UTL_LeadProcess.formWinback(request, mrrResponseItem, responseObject);
                  

                } 
                catch (Exception e) {
                    mapError(e.getMessage(),responseField,responseFieldError,responseObject,mrrResponseItem);
                }
            }
            when 'WSLead_CariBoll'{
                try {
                    List<String> listFieldsReq =new List<String>{'NOMEMACROACTIVITYEASYCIM'};
                    requiredFields(listFieldsReq, request);
                    RestContext.response.statusCode = 200;
                    HDT_UTL_LeadProcess.formCaricBoll(request, mrrResponseItem, responseObject);
                    
                } 
                catch (Exception e) {
                    mapError(e.getMessage(),responseField,responseFieldError,responseObject,mrrResponseItem);
                }
              
            }
            when 'WSLead_HVAC'{
                try {
                    List<String> listFieldsReq =new List<String>{'NOMEMACROACTIVITYEASYCIM'};
                    requiredFields(listFieldsReq, request);
                    RestContext.response.statusCode = 200; 
                    HDT_UTL_LeadProcess.formHvac(request, mrrResponseItem, responseObject);
                     
                } 
                catch (Exception e) {
                    mapError(e.getMessage(),responseField,responseFieldError,responseObject,mrrResponseItem);
                }

            }
            when 'WSLead_SOL'{
                try {
                    List<String> listFieldsReq =new List<String>{'NOMEMACROACTIVITYEASYCIM'};
                    requiredFields(listFieldsReq, request);
                    RestContext.response.statusCode = 200;
                    HDT_UTL_LeadProcess.formSol(request, mrrResponseItem, responseObject);
                  
                } 
                catch (Exception e) {
                    mapError(e.getMessage(),responseField,responseFieldError,responseObject,mrrResponseItem);
                }

            }
            when 'CMPDMP_PRV'{
               
                if (request.objects.get(0).fields.get(0) != null) {
                    List<String> listFieldsReq =new List<String>{'runId'};
                    try {
                        Map<String,String> localMapRequestFields =requiredFields(listFieldsReq, request);
                        HDT_BA_ConsentLead ba = new HDT_BA_ConsentLead(localMapRequestFields.get('runId')); 
                        Database.executeBatch(ba,1000);
                        RestContext.response.statusCode = 200;
                    }
                    catch (Exception e){
                        mapError(e.getMessage(),responseField,responseFieldError,responseObject,mrrResponseItem);
                      //  mapError('runId cannot be empty',responseField,responseFieldError,responseObject,mrrResponseItem);

                    }  
                }
            }

            when 'CMPDMP_ATTR'{
                if (request.objects.get(0).fields.get(0) != null ) {
                    List<String> listFieldsReq =new List<String>{'runId'};
                    Map<String,String> localMapRequestFields =requiredFields(listFieldsReq, request);
                    try {
                        HDT_BA_AttributesLead ba = new HDT_BA_AttributesLead(localMapRequestFields.get('runId')); 
                        Database.executeBatch(ba,1000);
                        RestContext.response.statusCode = 200;
                    }
                     catch (Exception e) {
                        mapError(e.getMessage(),responseField,responseFieldError,responseObject,mrrResponseItem);
                    }
                }
            }

            when 'SIE34_7'{
                if (request.objects.get(0).fields.get(0) != null ) {
                    List<String> listFieldsReq =new List<String>{'runId','updatedFrom'};
                    try {
                        Map<String,String> localMapRequestFields =requiredFields(listFieldsReq, request);
                        System.enqueueJob(new HDT_QBL_SIE34_7(localMapRequestFields.get('runId'),localMapRequestFields.get('updatedFrom'), 'SIE34_7'));
                        RestContext.response.statusCode = 200;
                    } catch (Exception e) {
                        mapError(e.getMessage(),responseField,responseFieldError,responseObject,mrrResponseItem);
                    }
                   
                }
            }
            when 'SIE34_6'{
                if (request.objects.get(0).fields.get(0) != null ) {
                    List<String> listFieldsReq =new List<String>{'runId','updatedFrom'};
                    try {
                        Map<String,String> localMapRequestFields =requiredFields(listFieldsReq, request);
                        System.enqueueJob(new HDT_QBL_SIE34_6(localMapRequestFields.get('runId'),localMapRequestFields.get('updatedFrom'), 'SIE34_6'));
                        RestContext.response.statusCode = 200;
                    } 
                    catch (Exception e) {
                        mapError(e.getMessage(),responseField,responseFieldError,responseObject,mrrResponseItem);

                    }       
                }
            }
            when 'SIE34_3'{
                //System.debug('SIE34');
                if (request.objects.get(0).fields.get(0) != null ) {
                    List<String> listFieldsReq =new List<String>{'runId','updatedFrom'};
                    try {
                        Map<String,String> localMapRequestFields =requiredFields(listFieldsReq, request);
                        System.enqueueJob(new HDT_QBL_SIE34_3(localMapRequestFields.get('runId'),localMapRequestFields.get('updatedFrom'), 'SIE34_3'));
                        RestContext.response.statusCode = 200;
                    } catch (Exception e) {
                        mapError(e.getMessage(),responseField,responseFieldError,responseObject,mrrResponseItem);
                    }
                   
                }
            }
            when 'SIE34_2'{
               
                if (request.objects.get(0).fields.get(0) != null ) {
                    List<String> listFieldsReq =new List<String>{'runId','updatedFrom'};
                    try {
                        Map<String,String> localMapRequestFields =requiredFields(listFieldsReq, request);
                        System.enqueueJob(new HDT_QBL_SIE34_2SME(localMapRequestFields.get('runId'),localMapRequestFields.get('updatedFrom'), 'SIE34_2'));
                        RestContext.response.statusCode = 200;
                    } 
                    catch (Exception e) {
                        mapError(e.getMessage(),responseField,responseFieldError,responseObject,mrrResponseItem);
                    }
                }
            }

            /*when 'SIE34_1'{
              
                if (request.objects.get(0).fields.get(0) != null ) {
                    List<String> listFieldsReq =new List<String>{'runId','updatedFrom'};
                    try {
                        Map<String,String> localMapRequestFields =requiredFields(listFieldsReq, request);
                        System.enqueueJob(new HDT_QBL_SIE34_1Gas(localMapRequestFields.get('runId'),localMapRequestFields.get('updatedFrom'), 'SIE34_1'));
                        RestContext.response.statusCode = 200;
                    } 
                    catch (Exception e) {
                        mapError(e.getMessage(),responseField,responseFieldError,responseObject,mrrResponseItem);

                    } 
                }
            }*/
            when else {

                responseField.fieldType = 'TEXT';
                responseField.name = 'ESITO';
                responseField.value = 'KO';

                responseFieldError.fieldType = 'TEXT';
                responseFieldError.name = 'ERROR_MESSAGE';
                responseFieldError.value = 'Unsupported requestType';

                responseObject.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>{responseField, responseFieldError};
                mrrResponseItem.objects.add(responseObject);

                RestContext.response.statusCode = 400;

            }
        }
        return mrrResponseItem;
    }
    

    @TestVisible
    private static List<Order> updateOrderServicePoint(String orderId, String parentOrderId, String servicePointCode)
    {
        List<Order> childOrders = [SELECT ServicePointCode__c FROM Order WHERE ParentOrder__c = :parentOrderId AND Id != :orderId WITH SECURITY_ENFORCED];
        for(Order o : childOrders)
        {
            o.ServicePointCode__c = servicePointCode;
        }
        return childOrders;
    }

    @Future
    private static void updateFuture(String inputString){
        Order recordOrder = (Order) JSON.deserialize(inputString, Order.class);
        HDT_UTL_DatabaseService.updateSObject(recordOrder);
    }

    @SuppressWarnings('PMD.ExcessiveParameterList')
    private static void mapError(String msg, HDT_WRP_MrrResponse.HDT_WRP_Field responseField,HDT_WRP_MrrResponse.HDT_WRP_Field responseFieldError,HDT_WRP_MrrResponse.HDT_WRP_Object responseObject,HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseItem){
        responseField.fieldType = 'TEXT';
        responseField.name = 'ESITO';
        responseField.value = 'KO';
        responseFieldError.fieldType = 'TEXT';
        responseFieldError.name = 'ERROR_MESSAGE';
        responseFieldError.value = msg;
        responseObject.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>{responseField, responseFieldError};
        mrrResponseItem.objects.add(responseObject);
        RestContext.response.statusCode = 400;

    }

    @TestVisible
    private static void updateServicePoint(ServicePoint__c sp){
        try{
            new HDT_SRV_ServicePoint().updateRecord(sp);
        }
        catch(Exception e){
            throw new HDT_WS_MrrRequest.CustomMessageException('Error on Updating ServicePoint - '+e.getMessage());
        }
    }
    
    @TestVisible
    private static Map<String,String> requiredFields(List<String> listFieldsReq,HDT_WRP_MrrRequest.HDT_WRP_Request request){
        Map<String,String> localMapRequestFields = new Map<String,String>();

        for(HDT_WRP_MrrRequest.HDT_WRP_Field field : request.objects.get(0).fields){ 
                localMapRequestFields.put(field.name,field.value);
        }
        for (String tempString : listFieldsReq) {
            if (localMapRequestFields.get(tempString)==null || String.isBlank(localMapRequestFields.get(tempString))) { 
                throw new HDT_WS_MrrRequest.CustomMessageException('Missing Required Field '+tempString);
            }
        }
        
        return localMapRequestFields;
    }

    private static String writeDescription(String newDescription, String oldDescription)
    {
        String returnDescr = oldDescription != null ? oldDescription : '';

        if(newDescription != null && String.isNotEmpty(newDescription))
        {
            Datetime nowDate = Datetime.now();
            String descr = nowDate.format('dd/MM/yyyy h:mm a') + ': ' + newDescription;
            returnDescr = descr + '\n' + returnDescr;
        }

        return returnDescr;
        
    }

}