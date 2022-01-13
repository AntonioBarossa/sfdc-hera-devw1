/**
* @author Andrei Necsulescu (andrei.necsulescu@webresults.it)
* @date 13/04/2021
* @description HDT_SRV_SalesHandler - Class that holds business logic for MrrRequest Webservice
* @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
*/

public with sharing class HDT_SRV_SalesHandler {

    /**​
    * @author Andrei Necsulescu (andrei.necsulescu@webresults.it)​
    * @date 13/04/2021
    * @description HDT_SRV_SalesHandler.manageSalesProcessCategory() – manage the requests of process category "sales"
    * @param request The request to be processed
    * @param mrrResponseItem the already initialized response item that needs to be returned at the end of the execution
    * @return the response item containing the result of the executed operations
    */

    /**@frpanico 25/10/2021
     * Added class instance
     */
    private static HDT_SRV_VoltureChangeManager voltureChangeSrv = new HDT_SRV_VoltureChangeManager();
    private static Set<String> moveOutProcesses = new Set<String>{'Cambio Uso','Voltura','Cambio Offerta'};

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
                                    'Status__c'               => 'Creata',
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
                        if(recordId instanceOf Id){
                            ordRetrieved = orderQr.getRecordByOrderId(recordId)[0];
                        }
                        else {
                            ordRetrieved = orderQr.getRecordByOrderNumber(mapRequestFields.get('RECORD_ID'))[0];
                        }

                        String previousPhase = ordRetrieved.Phase__c;
                        String nextPhase = mapRequestFields.get('FASE');
                        String finalCancellationPhase = '';
                        //EVERIS: EMD ANNULLAMENTO/RIPENSAMENTO
                        //EVERIS: Gestione Scarti SAP
                        HDT_UTL_Scarti.handleHerokuResponse(ordRetrieved.Id, activityName, nextPhase);
                        Order ord = new Order();
                        ord.Id = ordRetrieved.Id;
                        ord.Phase__c = mapRequestFields.get('FASE');
                        //START>> 26/07/2021 costanzo.lomele@webresults.it - nuovi sviluppi cb scarti, attività anonime
                        ord.ExternalUserCompany__c = mapRequestFields.get('CMP');
                        //END>> 26/07/2021 costanzo.lomele@webresults.it - nuovi sviluppi cb scarti, attività anonime

                        switch on mapRequestFields.get('FASE') {
                            when 'Ammissibilità KO' {
                                ord.DiscardReason__c = mapRequestFields.get('DES_ERR_AEEG');
                                ord.CausalCode__c = mapRequestFields.get('CODERR');
                                ord.CausalCode__c = mapRequestFields.get('CODERR_AEEG');
                                ord.HerokuPracticeCode__c = mapRequestFields.get('COD_PRAT_UTENTE');
                                ord.DistributorPracticeCode__c = mapRequestFields.get('COD_PRAT_DISTR');
                                ord.Description = mapRequestFields.get('ANNOTAZIONI');

                                 if((ord.CausalCode__c == '032' || ord.CausalCode__c == '033')
                                     && (ordRetrieved.ProcessType__c == 'Subentro Gas' 
                                         || ordRetrieved.ProcessType__c == 'Prima Attivazione In delibera'
                                         || ordRetrieved.ProcessType__c == 'Prima Attivazione Fuori delibera'
                                 )){
                                     ord.TecnicalPhase__c = 'Annullato';
                                     ord.Status = 'Annullato';
                                 }
                            }
                            when 'Ammissibilità OK' {

                                /**@frpanico 26/10/2021
                                 * Cambio Voltura - RN008 "Voltura con Switch"
                                 */
                                if(ordRetrieved.ProcessType__c.equalsIgnoreCase('Voltura con Switch'))
                                {
                                    voltureChangeSrv.handleAmmissibilityCheck(mapRequestFields, ordRetrieved);
                                }

                                ord.HerokuPracticeCode__c = mapRequestFields.get('COD_PRAT_UTENTE');
                                ord.DistributorPracticeCode__c = mapRequestFields.get('COD_PRAT_DISTR');
                                ord.CausalCode__c = mapRequestFields.get('COD_FLUSSO');


                                if( mapRequestFields.get('DES_ERR_AEEG') != null) {
                                    ord.DiscardReason__c = mapRequestFields.get('DES_ERR_AEEG');
                                    ord.CausalCode__c = mapRequestFields.get('CODERR_AEEG');
                                } else {
                                    ord.CausalCode__c = mapRequestFields.get('COD_FLUSSO');
                                }
                                //String workExecutionTime =mapRequestFields.get('TEMP_ES_PREV');
                                if(String.isNotBlank(mapRequestFields.get('TEMP_ES_PREV')) && mapRequestFields.get('TEMP_ES_PREV').isNumeric()){
                                    ord.WorkExecutionTime__c = Decimal.valueOf(mapRequestFields.get('TEMP_ES_PREV'));
                                }

                                if (String.isNotBlank(mapRequestFields.get('IMP_PREV_DIST'))) {
                                    ord.EstimateAmount__c = Decimal.valueOf(mapRequestFields.get('IMP_PREV_DIST'));
                                    Boolean isDispatcherInMtd= HDT_UTL_QuoteManagement.checkLocalDispatcher(ord.ServicePoint__r.Distributor__r.Name);
                                    Integer validityDateDelay=isDispatcherInMtd ? 90 : 30; //ExtraRete? 30 : InRete? 90 : AAA? 180 : null; Manca caso AAA
                                    ord.QuotationType__c='Predeterminabile';
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

                                 if(ord.CausalCode__c == '034' 
                                     && (ordRetrieved.ProcessType__c == 'Subentro Gas' 
                                         || ordRetrieved.ProcessType__c == 'Prima Attivazione In delibera'
                                         || ordRetrieved.ProcessType__c == 'Prima Attivazione Fuori delibera'
                                 )){
                                     ord.TecnicalPhase__c = 'Annullato';
                                     ord.Status = 'Annullato';
                                     ord.Phase__c = 'Annullato'; //HRAWRM-460
                                 }
                            }
                            when 'Dati Tecnici Ricevuti'{
                                HDT_UTL_HandleTechnicalData utlTechData = new HDT_UTL_HandleTechnicalData();
                                utlTechData.sp = new ServicePoint__c(Id=ordRetrieved.ServicePoint__c);
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
                                system.debug('previousPhase '+previousPhase);
                                String finalPhase = ord.phase__c;
                                if('Errore tecnico invio a SAP'.equalsIgnoreCase(finalPhase)){
                                     finalPhase = 'Errore comunicazione SAP';
                                }
                            	ord.TrackingDiscardPhase__c = finalPhase;
                                ord.phase__c=previousPhase; //perchè queste 3 non sono ammesse nel campo phase__c
                                system.debug('phase__c '+ord.phase__c);
                                system.debug('TrackingDiscardPhase__c '+ord.TrackingDiscardPhase__c);
                            }
                            when 'Esito KO da DL' {
                                ord.DiscardReason__c = mapRequestFields.get('TESTO_ERRR');
                                ord.HerokuPracticeCode__c = mapRequestFields.get('COD_PRAT_UTENTE');
                                ord.DistributorPracticeCode__c = mapRequestFields.get('COD_PRAT_DISTR');
                                ord.CausalCode__c = mapRequestFields.get('COD_FLUSSO');
                                ord.DiscardReason__c = mapRequestFields.get('DES_ERR_AEEG');
                                ord.Description = mapRequestFields.get('ANNOTAZIONI');
                            }
                            when 'Esito OK da DL' {
                                HDT_UTL_HandleTechnicalData utlTechData = new HDT_UTL_HandleTechnicalData();
                                utlTechData.sp = new ServicePoint__c(Id=ordRetrieved.ServicePoint__c);
                                ord.DistributorPracticeCode__c = mapRequestFields.get('COD_PRAT_DISTR');
                                ord.SapContractActivationDate__c = mapRequestFields.get('DT_INIZIO_VERT') != null ? Date.valueOf(mapRequestFields.get('DT_INIZIO_VERT')) : null;
                                ord.HerokuPracticeCode__c = mapRequestFields.get('COD_PRAT_UTENTE');
                                ord.CausalCode__c = mapRequestFields.get('COD_FLUSSO');
                                
                                //Start HRAWRM-657 21/09/2021
                                List<Id> listRecType = new List<Id>();
                                Id rtTemporaryNewActivation        = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_TemporaneaNuovaAtt').getRecordTypeId();
                                Id rtConnectionwithActivation      = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_ConnessioneConAttivazione').getRecordTypeId();
                                listRecType.add(rtTemporaryNewActivation);
                                listRecType.add(rtConnectionwithActivation);
                                if (listRecType.contains(ord.recordtypeId )   ) {
                                    ord.ServicePointCode__c = mapRequestFields.get('POD');
                                    ord.ServicePoint__r.Name= mapRequestFields.get('POD');
                                    ord.ServicePoint__r.ServicePointCode__c = mapRequestFields.get('POD');
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
                                ord.PrecheckReasonSII__c = mapRequestFields.get('DES_ERR_ES');
                                ord.CausalCode__c = mapRequestFields.get('CODERR_ES');
                                ord.DistributorPracticeCode__c = mapRequestFields.get('COD_PRAT_DISTR');
                                ord.HerokuPracticeCode__c = mapRequestFields.get('COD_PRAT_UTENTE');

                                if(mapRequestFields.get('CODERR_ES') == '003' || mapRequestFields.get('CODERR_ES') == '103'){
                                    ord.IsTechnicalTransfer__c = true;
                                }
                            }
                            when 'Amm. Precheck OK SII' {
                                ord.DistributorPracticeCode__c = mapRequestFields.get('COD_PRAT_DISTR');
                                ord.HerokuPracticeCode__c = mapRequestFields.get('COD_PRAT_UTENTE');
                                ord.RemiCode__c = mapRequestFields.get('EXT_CABINA_REMI');
                                ord.VATNumberUdb__c = mapRequestFields.get('EXT_PIVA_DISTR');
                                if (ordRetrieved.PrecheckResultSII__c == null || ordRetrieved.PrecheckResultSII__c == '') {
                                    ord.PrecheckResultSII__c = 'OK';
                                }
                            }
                            when 'Esito KO da SII' {
                                ord.PrecheckReasonSII__c = mapRequestFields.get('TESTO_ERRR');
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
                                }
                                if(previousPhase.indexOf('Ripensamento') >-1){
                                    nextPhase = nextPhase.replace('Annullamento', 'Ripensamento');
                                }
                                ord.Phase__c = nextPhase;
                                //EVERIS: END ANNULLAMENTO/RIPENSAMENTO
                            }
                            when 'Esito OK da DL/SII'{
                                //EVERIS: START ANNULLAMENTO/RIPENSAMENTO
                                if(previousPhase.indexOf('Annullamento') > -1) {
                                    ord.Phase__c = 'Annullamento - ' + nextPhase;
                                    finalCancellationPhase = 'Annullato';
                                    Datetime nowDate = Datetime.now();
                                    String nowDateFormat = nowDate.format('dd/MM/yyyy h:mm a');
                                    String cancellationNote = ordRetrieved.CancellationNote__c != null ? ordRetrieved.CancellationNote__c : '';
                                    if(mapRequestFields.get('NOTE_ANN') != null && mapRequestFields.get('NOTE_ANN') != '')
                                    {
                                        ord.CancellationNote__c = nowDateFormat + ': ' + mapRequestFields.get('NOTE_ANN') + '\n' + cancellationNote;
                                    }
                                }else if(previousPhase.indexOf('Ripensamento') > -1) {
                                   	ord.Phase__c = 'Ripensamento - Esito OK da SII';
                                    finalCancellationPhase = 'Ripensato';
                                }
                                //EVERIS: END ANNULLAMENTO/RIPENSAMENTO
                            }
                            when 'Esito KO da DL/SII' {
                                //EVERIS: START ANNULLAMENTO/RIPENSAMENTO
                                if(previousPhase.indexOf('Annullamento') > -1) {
                                    ord.Phase__c = 'Annullamento - ' + nextPhase;
                                    Datetime nowDate = Datetime.now();
                                    String nowDateFormat = nowDate.format('dd/MM/yyyy h:mm a');
                                    String cancellationNote = ordRetrieved.CancellationNote__c != null ? ordRetrieved.CancellationNote__c : '';
                                    if(mapRequestFields.get('NOTE_ANN') != null && mapRequestFields.get('NOTE_ANN') != '')
                                    {
                                        ord.CancellationNote__c = nowDateFormat + ': ' + mapRequestFields.get('NOTE_ANN') + '\n' + cancellationNote;
                                    }
                                }else if(previousPhase.indexOf('Ripensamento') > -1) {
                                    ord.Phase__c = 'Ripensamento - Esito KO da SII';
                                }
                                //EVERIS: END ANNULLAMENTO/RIPENSAMENTO
                            }
                            when 'Errore lavorazione SAP' {
                                ord.DiscardReason__c = mapRequestFields.get('NOTE_ERR');
                                ord.HerokuPracticeCode__c = mapRequestFields.get('COD_PRAT_UTENTE');
                            }
                            when 'Dati discordanti'{
                                ord.phase__c = mapRequestFields.get('FASE');
                                ord.DiscardReason__c = mapRequestFields.get('TESTO_ERR');
                                ord.HerokuPracticeCode__c = mapRequestFields.get('COD_PRAT_UTENTE');
                            }
                            when 'Completata' {

                                Boolean redirectPreventivo = false;
                                switch on ordRetrieved.ProcessType__c{
                                    when 'Connessione con Attivazione', 'Temporanea - Nuova Attivazione', 'Attivazione con Modifica'{
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

                                if (!listRecordType.contains(ord.recordtypeId ) && String.isNotBlank(mapRequestFields.get('DT_CREA'))  ) {
                                    ord.EffectiveDate__c = date.valueOf( mapRequestFields.get('DT_CREA')); //? per tutti i processi tranne RecordType.Name in ('SwitchIn','Cambio Offerta','Voltura Con Switch')
                                }
                                //End HRAWRM-657 21/09/2021

                                if(ordRetrieved.Phase__c.equalsIgnoreCase('Dati Tecnici Ricevuti') && redirectPreventivo){
                                    ord.Phase__c = 'Inviare preventivo';
                                }else{
                                    /**@frpanico 04/01/2022
                                     * Aggiunto MoveOut
                                    */
                                    if(moveOutProcesses.contains(ordRetrieved.ProcessType__c))
                                    {
                                        HDT_UTL_ContractProcess.moveOut(ordRetrieved.Id, 'ContractReference__c');
                                    }
                                    ord.Description = mapRequestFields.get('NOTA_HK');
                                    ord.SAPImplantCode__c = mapRequestFields.get('ANLAGE');
                                    ord.OrderODV__c = mapRequestFields.get('VBELN');
                                    ord.SapContractCode__c = mapRequestFields.get('VERTRAG');
                                    ord.HerokuPracticeCode__c = mapRequestFields.get('COD_PRAT_UTENTE');
                                    ord.Status='Activated';
                                    
                                    if(mapRequestFields.get('VKONT') != null) {
                                        ord.ContractAccountCode__c = mapRequestFields.get('VKONT');

                                        BillingProfile__c billingProfile = new BillingProfile__c();
                                        billingProfile.Id = ordRetrieved.BillingProfile__c;
                                        billingProfile.ContractAccountCode__c = mapRequestFields.get('VKONT');
                                        
                                        HDT_SRV_BillingProfile billingProfileSrv = new HDT_SRV_BillingProfile();
                                        try{
                                            billingProfileSrv.updateRecord(billingProfile);
                                        }catch(Exception e){
                                            system.debug('Exception Update Billing Profile');
                                            throw new HDT_WS_MrrRequest.CustomMessageException('Error on Updating Billing Profile, VKONT Already not Unique - '+e.getMessage());
                                        }
                                    }
                                    HDT_UTL_HandleTechnicalData utlTechData = new HDT_UTL_HandleTechnicalData();
                                    utlTechData.sp = new ServicePoint__c(Id=ordRetrieved.ServicePoint__c);
                                    utlTechData.handleCompletata(mapRequestFields);
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
                                String annotazioni = ord.CancellationNote__c != null? ord.CancellationNote__c:'';
                                ord.CancellationNote__c = mapRequestFields.get('NOTE_ANN') +'\n' + annotazioni;
                                HDT_UTL_HerokuPostSalesManager utlClass = new HDT_UTL_HerokuPostSalesManager();
                                Order cancellationOrder = new Order();
                                cancellationOrder.Id = ord.Id;
                                utlClass.handlePassiveCancellation(cancellationOrder, 'Order', mapRequestFields.get('STORNO'), mapRequestFields.get('ATTIVITA'));
                            }
                        }

                        system.debug('cost2 '+ord.phase__c);
                        orderSrv.updateRecord(ord);
                    	responseField.fieldType = 'TEXT';
                    	responseField.name = 'ESITO';
                    	responseField.value = 'OK';

                        //EVERIS: START ANNULLAMENTO/RIPENSAMENTO
                        if (String.isNotBlank(finalCancellationPhase)) {
                            ord.Phase__c = finalCancellationPhase;
                            ord.Status = 'Completed';
                            updateFuture(JSON.serialize(ord));
                        }
                        //EVERIS: END ANNULLAMENTO/RIPENSAMENTO  
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

            when 'SIE34_1'{
              
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
            }
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
    
    //EVERIS: START ANNULLAMENTO/RIPENSAMENTO
    @Future
    private static void updateFuture(String inputString){
        Order recordOrder = (Order) JSON.deserialize(inputString, Order.class);
        HDT_UTL_DatabaseService.updateSObject(recordOrder);
    }
    //EVERIS: END ANNULLAMENTO/RIPENSAMENTO
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
        }catch(Exception e){
           // system.debug('Exception Update ServicePoint');
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

}