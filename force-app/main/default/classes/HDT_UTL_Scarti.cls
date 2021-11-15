/**
 * @author Marco Arci (marco.arci@webresults.it)
 * @date 22/07/2021
 * @description HDT_UTL_Scarti - Utility scarti
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class HDT_UTL_Scarti implements wrts_prcgvr.Interfaces_1_2.IApexCriteria, Queueable{
    private List<wrts_prcgvr__Activity__c> newActivities;
    private List<wrts_prcgvr__Activity__c> oldActivities;

    static final string CANONERAITEMPLATENAME='CBS_CAR002__CANONE_RAI';
    static final string BONUSSOCIALETEMPLATENAME='CBS_FAT011__BONUS_SOCIALE';
    static final string SCARTODOCUMENTALEPOSTSALESTEMPLATENAME='CBS_CRP004__SCARTI_DOCUMENTALI_POST_SALES';
    static final string SCARTODOCUMENTALESALESTEMPLATENAME='CBS_CRP003__SCARTI_DOCUMENTALI_SALES';
    
    private Static final Set<String> TRACCIATURATYPES = new Set<String>{'Richiesta non identificata',
                                                                                 'Esito ricevuto su richiesta chiusa',
                                                                                 'Esito non elaborato',
                                                                                 'Errore invio a SAP',
                                                                                 'Eliminato esito in scarto',
                                                                                 'Errore determinazione variante SAP',
                                                                                 'Errore Lavorazione SAP'};

    static final Map<String, String> TRACCIAMENTOHEROKUSALES = new Map<String, String>{ 'Esito ricevuto su richiesta chiusa' => 'CBS_HER007__ESITO_RICEVUTO_SU_RICHIESTA_CHIUSA_SALES',
                                                                                        'Esito non elaborato' => 'CBS_HER006__ESITO_NON_ELABORATO_DA_DLSII_SALES',
                                                                                        'Eliminato esito in scarto' => 'CBS_HER008__ELIMINATO_ESITO_IN_SCARTO_SALES',
                                                                                        'Errore invio a SAP' => 'CBS_HER009__ERRORE_INVIO_A_SAP_SALES',
                                                                                        'Errore determinazione variante SAP' => 'CBS_HER010__ERRORE_DETERMINAZIONE_VARIANTE_SAP_SALES' };

    static final Map<String, String> TRACCIAMENTOHEROKUPOSTSALES = new Map<String, String>{'Esito ricevuto su richiesta chiusa' => 'CBS_HER002__ESITO_RICEVUTO_SU_RICHIESTA_CHIUSA_POSTSALES',
                                                                                           'Esito non elaborato' => 'CBS_HER001__ESITO_NON_ELABORATO_DA_DLSII_POSTSALES',
                                                                                           'Eliminato esito in scarto' => 'CBS_HER003__ELIMINATO_ESITO_IN_SCARTO_POSTSALES',
                                                                                           'Errore invio a SAP' => 'CBS_HER004__ERRORE_INVIO_A_SAP_POSTSALES',
                                                                                           'Errore determinazione variante SAP' => 'CBS_HER005__ERRORE_DETERMINAZIONE_VARIANTE_SAP_POSTSALES' };

    private Static final Map<String, String> TRACCIAMENTOKOSAPSALES = new Map<String, String>{'HDT_RT_TemporaneaNuovaAtt' => 'CBS_ATT001__ESITO_KO_DA_SAP',
                                                                                            'HDT_RT_Subentro' => 'CBS_ATT001__ESITO_KO_DA_SAP',
                                                                                            'HDT_RT_SwitchIn' => 'CBS_ATT001__ESITO_KO_DA_SAP',
                                                                                            'HDT_RT_AttivazioneConModifica' => 'CBS_ATT001__ESITO_KO_DA_SAP',
                                                                                            'HDT_RT_Attivazione' => 'CBS_ATT001__ESITO_KO_DA_SAP',
                                                                                            'HDT_RT_ConnessioneConAttivazione' => 'CBS_ATT001__ESITO_KO_DA_SAP',
                                                                                            'HDT_RT_ScontiBonus' => 'CBS_ATT001__ESITO_KO_DA_SAP',
                                                                                            'HDT_RT_CambioOfferta' => 'CBS_ATT001__ESITO_KO_DA_SAP',
                                                                                            'HDT_RT_VolturaConSwitch' => 'CBS_ATT001__ESITO_KO_DA_SAP'};
                                                                             
    private Static final Map<String, String> TRACCIAMENTOKOSAPPOSTSALES = new Map<String, String>{'HDT_RT_PreventiviEle' => 'CBS_PRE003__ESITO_KO_DA_SAP',
                                                                                                'HDT_RT_PreventiviGas' => 'CBS_PRE003__ESITO_KO_DA_SAP',
                                                                                                'HDT_RT_PianoRateizzazione' => 'CBS_PAG002__ESITO_KO_DA_SAP',
                                                                                                'HDT_RT_Domiciliazione' => 'CBS_PAG002__ESITO_KO_DA_SAP',
                                                                                                'HDT_RT_ComunicazionePagamento' => 'CBS_PAG002__ESITO_KO_DA_SAP',
                                                                                                'HDT_RT_VariazioniGas' => 'CBS_VAR001__ESITO_KO_DA_SAP',
                                                                                                'HDT_RT_VariazioniEle' => 'CBS_VAR001__ESITO_KO_DA_SAP',
                                                                                                'HDT_RT_Annullamento' => 'CBS_ANN001__ESITO_KO_DA_SAP',
                                                                                                'HDT_RT_FatturazioneConsumi' => 'CBS_FAT010__ESITO_KO_DA_SAP',
                                                                                                'HDT_RT_Disattivazioni' => 'CBS_DIS001__ESITO_KO_DA_SAP',
                                                                                                'HDT_RT_PostSalesVAS' => 'CBS_DIS001__ESITO_KO_DA_SAP',
                                                                                                'HDT_RT_Autolettura' => 'CBS_AUT002__ESITO_KO_DA_SAP',
                                                                                                'HDT_RT_VerificheEle' => 'CBS_VER001__ESITO_KO_DA_SAP',
                                                                                                'HDT_RT_Morosita' => 'CBS_MOR001__ESITO_KO_DA_SAP'};

    static final Map<String, String> ANONIMAMAPPING = new Map<String, String>{'Type__c' => 'ATTIVITA',
                                                                              'CreatedByUsername__c' => 'UTENZA',
                                                                              'StartDate__c' => 'DATA_EVENTO',
                                                                              'DiscardDescription__c' => 'ERROR_MESSAGE'};

    static final Map<String, String> TRACCIAMENTOMAPPING = new Map<String, String>{'DiscardCount__c' => 'COUNTER',
                                                                                   'HerokuPracticeCode__c' => 'COD_PRAT_UTENTE',
                                                                                   'ExternalUserCompany__c' => 'CMP',
                                                                                   'ExternalErrorDescription__c' => 'NOTE_ERR',
                                                                                   'ExternalErrorStep__c' => 'STEP_ERR',
                                                                                   'Note__c' => 'NOTA_HK',
                                                                                   'CreatedByUsername__c' => 'UTENZA',
                                                                                   'StartDate__c' => 'DATA_EVENTO',
                                                                                   'wrts_prcgvr__Description__c' => 'ERROR_MESSAGE'};
    /*
    global Object execute(Object args){
        Map<String, Object> argsMap = (Map<String, Object>) args;
        SObject transition = (SObject) argsMap.get('transition');
        SObject action = (SObject) argsMap.get('action');
        String method = (String) argsMap.get('method');
        SObject sender = (SObject) argsMap.get('sender');		
		
    }
	*/
    global HDT_UTL_Scarti(){}//need empty constructor for Dynamically creating instance of this class

    public HDT_UTL_Scarti(List<wrts_prcgvr__Activity__c> newActs, List<wrts_prcgvr__Activity__c> oldActs) {
        this.newActivities = newActs;
        this.oldActivities = oldActs;
    }

    public void execute(QueueableContext context) {
        system.debug('HDT_UTL_Scarti execute start QueueableContext: ' + context);
        updatePraticaForScartoDocumentaleQueue(newActivities, oldActivities);
    }


    /**
    * @author Marco Arci (marco.arci@webresults.it)
    * @date 10/09/2021
    * @description evaluate - method dell'intefaccia di pclick
    * @param args - Object
    * @return boolean
    */
    global boolean evaluate(Object args){
		Map<String, Object> argsMap = (Map<String, Object>) args;
        String method = (String) argsMap.get('method');
        SObject record = (SObject) argsMap.get('record');
		
		//c'è annullamento automatico a partire dal singolo scarto, per singolo processo, per singolo cluster
        //non si riescono a passare tutte queste info tramite method, servirebbero una marea di method
        //non sembra esserci un modo per passare i dati tramite "parametri" alla action
        //l'unica via, per ora, sembra quella di mettere il nome del template nel method. ES: 'checkActivityCreation___CBS_ATT006__AMMISSIBILITA_KO'
        //di conseguenza lo switch è poco funzionale, perchè bisognerebbe scrivere n righe per quanti template vengono rigchiesti... è anche poco manutenibile
        //dinamicamente, con substring, si vede il prefisso (checkActivityCreation) e poi si estrae il nome del template dalle parentesi tonde
		boolean activityCreationOutcome;
        try{
            activityCreationOutcome = checkActivityCreation((Id)record.get('Id'), method.substringAfter('___'));
        } catch(Exception e){
            system.debug(e.getMessage());
            system.debug(e.getStackTraceString());
        }
		
		if(method.startsWith('checkActivityCreation')){
            return activityCreationOutcome;
        }
        if(method.startsWith('checkAnnullment')){
            return !activityCreationOutcome;
        }
        return null;
	}

    /**
    * @author Marco Arci (marco.arci@webresults.it)
    * @date 27/08/2021
    * @description HDT_UTL_Scarti.HDT_UTL_FlowInputs - Wrapper FlowInputs
    */
    public class HDT_UTL_FlowInputs{
        @InvocableVariable
        public String methodName;
        @InvocableVariable
        public String objectId;
        @InvocableVariable
        public String templateName;
    }

    /**
    * @author Marco Arci (marco.arci@webresults.it)
    * @date 27/08/2021
    * @description HDT_UTL_Scarti.HDT_UTL_FlowOutputs - Wrapper FlowOutputs
    */
    public class HDT_UTL_FlowOutputs{
        @InvocableVariable
        public String esito;
        @InvocableVariable
        public String dettaglioEsito;
        @InvocableVariable
        public String recordId;
    }

    /**
    * @author Marco Arci (marco.arci@webresults.it)
    * @date 27/08/2021
    * @description HDT_UTL_Scarti.invokeScartiAction - chiamata da flow verso metodi di questa classe
    * @param inputParam - list<HDT_UTL_FlowInputs>
    * @return list<HDT_UTL_FlowOutputs>
    */
    @InvocableMethod(label='invokeScartiAction')
    public static list<HDT_UTL_FlowOutputs> invokeScartiAction(list<HDT_UTL_FlowInputs> inputParam){
      list<HDT_UTL_FlowOutputs> listOutputs= new list<HDT_UTL_FlowOutputs>();
      HDT_UTL_FlowOutputs output= new HDT_UTL_FlowOutputs();
        try{
            Id outputRecordId;
            switch on inputParam[0].methodName{
                when 'chiudiAttivita'{
                    chiudiAttivita(inputParam[0].objectId);
                }
                when 'annullaPratica'{
                    annullaPratica(inputParam[0].objectId);
                }
                when 'annullaContratti'{
                    HDT_UTL_Order.annullaContratti(inputParam[0].objectId);
                }
                when 'createActivityByObjectIdAndTemplateName'{
                    wrts_prcgvr__Activity__c act= createActivityByObjectIdAndTemplateName(inputParam[0].objectId, inputParam[0].templateName);
                    HDT_UTL_DatabaseService.insertSObject(act);
                    outputRecordId = act.Id;
                }
            }
            output.recordId=outputRecordId;
            output.esito='OK';
            output.dettaglioEsito='OK';
        }catch(Exception e){
            System.debug('ERROR: ' + e.getMessage() + ' @@ ' + e.getStackTraceString());
            output.esito='KO';
            output.dettaglioEsito= e.getMessage() + ' @@ ' + e.getStackTraceString();
        }
        listOutputs.add(output);
        return listOutputs;  
    }

    /**
    * @author Costanzo Lo Mele (costanzo.lomele@webresults.it)
    * @date 22/07/2021
    * @description HDT_UTL_Scarti.handleMRRInboundRequest
    * @param requests - List<HDT_WRP_MrrRequest.HDT_WRP_Request>
    */
    public static void handleMRRInboundRequest(List<HDT_WRP_MrrRequest.HDT_WRP_Request> inboundRequests){
        Set<String> orderNameSet = new Set<String>();
        List<Map<String,String>> dataForAttivitaTracciaturaCreation = new List<Map<String,String>>();
        List<wrts_prcgvr__Activity__c> dataForCheckEsitiIntermedi = new List<wrts_prcgvr__Activity__c>();
        for (HDT_WRP_MrrRequest.HDT_WRP_Request request : inboundRequests) {
            HDT_WRP_MrrResponse.HDT_WRP_Response parsedResponseItem = (HDT_WRP_MrrResponse.HDT_WRP_Response) JSON.deserialize(JSON.serialize(request), HDT_WRP_MrrResponse.HDT_WRP_Response.class);
            for(HDT_WRP_MrrResponse.HDT_WRP_Object curObj : parsedResponseItem.objects){
                for(HDT_WRP_MrrResponse.HDT_WRP_Field curField : curObj.fields){
                    system.debug('handleMRRInboundRequest curField: ' + curField.name + ' ' + curField.value);
                    if('ATTIVITA'.equalsIgnoreCase(curField.name) && TRACCIATURATYPES.contains(curField.value)){
                        Map<String,String> newData = new Map<String,String>();
                        for(HDT_WRP_MrrResponse.HDT_WRP_Field curField2 : curObj.fields){ newData.put(curField2.name, curField2.value); }
                        for(HDT_WRP_MrrRequest.HDT_WRP_Field curField3 : request.header.fields){ newData.put(curField3.name, curField3.value); }
                        dataForAttivitaTracciaturaCreation.add(newData);
                    }
                    if('FASE'.equalsIgnoreCase(curField.name) && new List<String>{'Completata', 'Ammissibilità OK'}.contains(curField.value)){
                    	system.debug('handleMRRInboundRequest curField: ' + curField.name + ' ' + curField.value);
                        for(HDT_WRP_MrrResponse.HDT_WRP_Field curField2 : curObj.fields){
                            if('RECORD_ID'.equalsIgnoreCase(curField2.name)){
                                if(curField2.value.length() == 18 ){
                                    if(Schema.Case.SObjectType == Id.valueOf(curField2.value).getSobjectType()){
                                        wrts_prcgvr__Activity__c tempAct = new wrts_prcgvr__Activity__c(DiscardCategory__c = 'Tracciatura');
                                        tempAct.Case__c = curField2.value;
                                        tempAct.wrts_prcgvr__ObjectId__c = curField2.value;
                                        dataForCheckEsitiIntermedi.add(tempAct);
                                    }
                                }
                                else if(curField2.value.startsWith('O-') ){
                                    orderNameSet.add(curField2.value);
                                }
                            }
                        }
                    }
                }
            }
        }
        System.debug('MRREQUEST orderNameSet' + JSON.serializePretty(orderNameSet));
        if(!orderNameSet.isEmpty()){
            for(Order curOrder : [SELECT Id FROM Order WHERE OrderNumber IN :orderNameSet]){
                wrts_prcgvr__Activity__c tempAct = new wrts_prcgvr__Activity__c(DiscardCategory__c = 'Tracciatura');
                tempAct.Order__c = curOrder.Id;
                tempAct.wrts_prcgvr__ObjectId__c = curOrder.Id;
                dataForCheckEsitiIntermedi.add(tempAct);
            }
        }
        System.debug('MRREQUEST dataForAttivitaTracciaturaCreation' + JSON.serializePretty(dataForAttivitaTracciaturaCreation));
        System.debug('MRREQUEST dataForCheckEsitiIntermedi' + JSON.serializePretty(dataForCheckEsitiIntermedi));
        if(!dataForAttivitaTracciaturaCreation.isEmpty()){ createAttivitaTracciaturaHeroku(dataForAttivitaTracciaturaCreation); }
        if(!dataForCheckEsitiIntermedi.isEmpty()){ checkForEsitiIntermedi(dataForCheckEsitiIntermedi); }
    }


    /**
    * @author Costanzo Lo Mele (costanzo.lomele@webresults.it)
    * @date 22/07/2021
    * @description HDT_UTL_Scarti.getTemplatesMapByName - returns a map <templateName, templateObj>
    * @param names - Set<String>
    * @return Map<String, wrts_prcgvr__ActivityTemplate__c> name per template
    */
    public static Map<String, wrts_prcgvr__ActivityTemplate__c> getTemplatesMapByName(Set<String> names){
        Map<String, wrts_prcgvr__ActivityTemplate__c> returnMap = new Map<String, wrts_prcgvr__ActivityTemplate__c>();
        List<wrts_prcgvr__ActivityTemplate__c> queryResult = [SELECT Name,
                                                                     wrts_prcgvr__Assignees__c,
                                                                     wrts_prcgvr__Code__c,
                                                                     wrts_prcgvr__DueDateField__c,
                                                                     wrts_prcgvr__DueDateUnit__c,
                                                                     wrts_prcgvr__DueDateValue__c,
                                                                     wrts_prcgvr__FieldsTemplate__c,
                                                                     wrts_prcgvr__IsRequired__c,
                                                                     wrts_prcgvr__ObjectType__c,
                                                                     wrts_prcgvr__Priority__c,
                                                                     wrts_prcgvr__Subject__c
                                                              FROM wrts_prcgvr__ActivityTemplate__c
                                                              WHERE Name IN :names
                                                              WITH SECURITY_ENFORCED];

        for(wrts_prcgvr__ActivityTemplate__c curTemplate : queryResult){
            returnMap.put(curTemplate.Name, curTemplate);
        }
        return returnMap;
    }

    /**
    * @author Costanzo Lo Mele (costanzo.lomele@webresults.it)
    * @date 22/07/2021
    * @description HDT_UTL_Scarti.createAttivitaTracciaturaHeroku - Creates attività di tracciamento Heroku
    * @param sourceData - List<Map<String,String>>
    */
    public static void createAttivitaTracciaturaHeroku(List<Map<String,String>> sourceData){
        System.debug('createAttivitaTracciaturaHeroku start' + sourceData);
        List<wrts_prcgvr__Activity__c> toInsert = new List<wrts_prcgvr__Activity__c>();
        Map<String, Map<String,String>> dataForSalesHandlingByRecordIdField = new Map<String, Map<String,String>>();
        Map<String, Map<String,String>> dataForKOSAPHandling = new Map<String, Map<String,String>>();

        for(Map<String,String> curData : sourceData){
            if('Richiesta non identificata'.equalsIgnoreCase(curData.get('ATTIVITA'))){
                system.debug('anonima' + JSON.serializePretty(curData));
                wrts_prcgvr__Activity__c newAct = new wrts_prcgvr__Activity__c();
                for(String curActField : ANONIMAMAPPING.keySet()){
                    if('StartDate__c'.equalsIgnoreCase(curActField)){
                        newAct.put(curActField, Date.valueOf(curData.get(ANONIMAMAPPING.get(curActField))));
                    }else{
                        newAct.put(curActField, curData.get(ANONIMAMAPPING.get(curActField)));
                    }
                }
                toInsert.add(newAct);
            }else if(TRACCIAMENTOHEROKUSALES.keySet().contains(curData.get('ATTIVITA')) && String.isNotBlank(curData.get('RECORD_ID'))){//va bene controllare solo su una mappa, tanto i keyset sono uguali
                system.debug('scarto transitorio' + JSON.serializePretty(curData));
                if('sales'.equalsIgnoreCase(curData.get('PROCESS_CATEGORY'))){
                    dataForSalesHandlingByRecordIdField.put(curData.get('RECORD_ID'), curData);
                }else if('postsales'.equalsIgnoreCase(curData.get('PROCESS_CATEGORY'))){
                    wrts_prcgvr__Activity__c newAct;
                    newAct = createActivityByObjectIdAndTemplateName(curData.get('RECORD_ID'), TRACCIAMENTOHEROKUPOSTSALES.get(curData.get('ATTIVITA')));
                    for(String curActField : TRACCIAMENTOMAPPING.keySet()){
                        if(curData.get(TRACCIAMENTOMAPPING.get(curActField)) != null){
                            switch on curActField{
                                when 'StartDate__c'{ newAct.put(curActField, Date.valueOf(curData.get(TRACCIAMENTOMAPPING.get(curActField)))); }
                                when 'DiscardCount__c'{ newAct.put(curActField, Decimal.valueOf(curData.get(TRACCIAMENTOMAPPING.get(curActField)))); }
                                when else{ newAct.put(curActField, curData.get(TRACCIAMENTOMAPPING.get(curActField))); }
                            }
                        }
                    }
                    toInsert.add(newAct);
                }
            }
            else if('Errore lavorazione SAP'.equalsIgnoreCase(curData.get('ATTIVITA')) && String.isNotBlank(curData.get('RECORD_ID'))){
                system.debug('ko sap' + JSON.serializePretty(curData));
                dataForKOSAPHandling.put(curData.get('RECORD_ID'), curData);
            }
        }
        
        System.debug('createAttivitaTracciaturaHeroku dataForSalesHandlingByRecordIdField' + dataForSalesHandlingByRecordIdField);
        if(!dataForSalesHandlingByRecordIdField.keySet().isEmpty()){
            Map<String, Map<String,String>> filanCollection = new Map<String, Map<String,String>>();

            Set<String> orderNumbers = new Set<String>();
            for(String curValue : dataForSalesHandlingByRecordIdField.keySet()){
                if(curValue.startsWithIgnoreCase('O-')){
                    orderNumbers.add(curValue);
                } else{
                    filanCollection.put(curValue, dataForSalesHandlingByRecordIdField.get(curValue));
                }
            }
            Map<Id, Order> orders = new Map<Id, Order>([SELECT Id, OrderNumber
                                                        FROM Order 
                                                        WHERE OrderNumber IN :orderNumbers]);
            for(Order curOrder : orders.values()){
                filanCollection.put(curOrder.Id, dataForSalesHandlingByRecordIdField.get(curOrder.OrderNumber));
            }
            for(String curId : filanCollection.keySet()){
                Map<String,String> curData = filanCollection.get(curId);
                wrts_prcgvr__Activity__c newAct = createActivityByObjectIdAndTemplateName(curId, TRACCIAMENTOHEROKUSALES.get(curData.get('ATTIVITA')));
                for(String curActField : TRACCIAMENTOMAPPING.keySet()){
                    if(curData.get(TRACCIAMENTOMAPPING.get(curActField)) != null){
                        switch on curActField{
                            when 'StartDate__c'{ newAct.put(curActField, Date.valueOf(curData.get(TRACCIAMENTOMAPPING.get(curActField)))); }
                            when 'DiscardCount__c'{ newAct.put(curActField, Decimal.valueOf(curData.get(TRACCIAMENTOMAPPING.get(curActField)))); }
                            when else{ newAct.put(curActField, curData.get(TRACCIAMENTOMAPPING.get(curActField))); }
                        }
                    }
                }
                toInsert.add(newAct);
            }
        }
        
        System.debug('createAttivitaTracciaturaHeroku dataForKOSAPHandling' + dataForKOSAPHandling);
        if(!dataForKOSAPHandling.keySet().isEmpty()){
            Map<String,String> requestData;
            Set<String> orderNumbers = new Set<String>();
            Set<String> caseNumbers = new Set<String>();
            Set<Id> orderIds = new Set<Id>();
            Set<Id> caseIds = new Set<Id>();
            for(String curRecordId : dataForKOSAPHandling.keySet()){
                if(curRecordId.startsWithIgnoreCase('O-')){ orderNumbers.add(curRecordId); }
                else if(curRecordId.startsWithIgnoreCase('C-')){caseNumbers.add(curRecordId);}
                else if(Schema.Order.SObjectType == Id.valueOf(curRecordId).getSobjectType()){ orderIds.add(curRecordId); }
                else if(Schema.Case.SObjectType == Id.valueOf(curRecordId).getSobjectType()){ caseIds.add(curRecordId); }
            }
            if(!orderNumbers.isEmpty() || !orderIds.isEmpty()){
                Map<Id, Order> ordersMap = new Map<Id, Order>([SELECT Id, RecordType.DeveloperName, OrderNumber
                                                                FROM Order
                                                                WHERE Id IN :orderIds
                                                                OR OrderNumber IN :orderNumbers]);
                for(Id curId : ordersMap.keySet()){
                    if(dataForKOSAPHandling.get(curId) != null){ requestData = dataForKOSAPHandling.get(curId); }
                    else { requestData = dataForKOSAPHandling.get(ordersMap.get(curId).OrderNumber); }
                    wrts_prcgvr__Activity__c newAct = createActivityByObjectIdAndTemplateName(curId, TRACCIAMENTOKOSAPSALES.get(ordersMap.get(curId).RecordType.DeveloperName));
                    for(String curActField : TRACCIAMENTOMAPPING.keySet()){
                        if(requestData.get(TRACCIAMENTOMAPPING.get(curActField)) != null){
                            switch on curActField{
                                when 'StartDate__c'{ newAct.put(curActField, Date.valueOf(requestData.get(TRACCIAMENTOMAPPING.get(curActField)))); }
                                when 'DiscardCount__c'{ newAct.put(curActField, Decimal.valueOf(requestData.get(TRACCIAMENTOMAPPING.get(curActField)))); }
                                when else{ newAct.put(curActField, requestData.get(TRACCIAMENTOMAPPING.get(curActField))); }
                            }
                        }
                    }
                    toInsert.add(newAct);
                }
            }
            if(!(caseIds.isEmpty() && caseNumbers.isEmpty())){
                Map<Id, Case> casesMap = new Map<Id, Case>([SELECT Id, RecordType.DeveloperName, CaseNumber
                                                            FROM Case
                                                            WHERE Id IN :caseIds OR CaseNumber IN :caseNumbers]);
                for(Id curId : casesMap.keySet()){
                    //requestData = dataForKOSAPHandling.get(curId);
                    if(dataForKOSAPHandling.get(curId) != null){ requestData = dataForKOSAPHandling.get(curId); }
                    else { requestData = dataForKOSAPHandling.get(casesMap.get(curId).CaseNumber); }
                    wrts_prcgvr__Activity__c newAct = createActivityByObjectIdAndTemplateName(curId, TRACCIAMENTOKOSAPPOSTSALES.get(casesMap.get(curId).RecordType.DeveloperName));
                    for(String curActField : TRACCIAMENTOMAPPING.keySet()){
                        if(requestData.get(TRACCIAMENTOMAPPING.get(curActField)) != null){
                            switch on curActField{
                                when 'StartDate__c'{ newAct.put(curActField, Date.valueOf(requestData.get(TRACCIAMENTOMAPPING.get(curActField)))); }
                                when 'DiscardCount__c'{ newAct.put(curActField, Decimal.valueOf(requestData.get(TRACCIAMENTOMAPPING.get(curActField)))); }
                                when else{ newAct.put(curActField, requestData.get(TRACCIAMENTOMAPPING.get(curActField))); }
                            }
                        }
                    }
                    toInsert.add(newAct);
                }
            }
        }
        
        System.debug('createAttivitaTracciaturaHeroku end' + toInsert);
        HDT_UTL_DatabaseService.insertSObject(toInsert);
    }

    /**
    * @author Costanzo Lo Mele (costanzo.lomele@webresults.it)
    * @date 06/08/2021
    * @description HDT_UTL_Scarti.createActivityByObjectIdAndTemplateName 
    * @param objectId - String Id of the parent record of the activity
    * @param templateName - String name of an activityTemplate
    * @return wrts_prcgvr__Activity__c
    */
    public static wrts_prcgvr__Activity__c createActivityByObjectIdAndTemplateName(String objectId, String templateName){
        system.debug('HDT_UTL_Scarti objectId ' + objectId);
        system.debug('HDT_UTL_Scarti templateName ' + templateName);
        try{
            Map<String, wrts_prcgvr__ActivityTemplate__c> template = getTemplatesMapByName(new Set<String>{templateName});
            system.debug('HDT_UTL_Scarti template ' + template);
            if(template.values().size() > 0){
                wrts_prcgvr.Interfaces_1_1.IActivityIntegration activityIntegration = (wrts_prcgvr.Interfaces_1_1.IActivityIntegration) wrts_prcgvr.VersionManager.newClassInstance('ActivityIntegration');
                List<wrts_prcgvr__Activity__c> activities = (List<wrts_prcgvr__Activity__c>) activityIntegration.createFromTemplate(template.values().get(0).wrts_prcgvr__Code__c, new Map<String,Object>{'objectId'=>objectId});
                if(activities.get(0).Account__c == null && Schema.Account.SObjectType == Id.valueOf(objectId).getSobjectType()){
                    activities.get(0).Account__c = objectId;
                }
                if(activities.get(0).Case__c == null && Schema.Case.SObjectType == Id.valueOf(objectId).getSobjectType()){
                    activities.get(0).Case__c = objectId;
                }
                if(activities.get(0).Order__c == null && Schema.Order.SObjectType == Id.valueOf(objectId).getSobjectType()){
                    activities.get(0).Order__c = objectId;
                }
                system.debug('HDT_UTL_Scarti end ' + activities.get(0));
                return activities.get(0);
            }
            system.debug('HDT_UTL_Scarti end');
            return null;
        }
        catch(Exception e){
            system.debug('HDT_UTL_Scarti catch ' + e);
            return null;
        }
    }

    /**
    * @author Marco Arci (marco.arci@webresults.it)
    * @date 24/08/2021
    * @description HDT_UTL_Scarti.createActivityByObjectIdAndTemplateNameBulk
    * @param objectIds - list<String> list of Ids of the parent records of the activity
    * @param templateName - String name of an activityTemplate
    * @return list<wrts_prcgvr__Activity__c>
    */
    public static list<wrts_prcgvr__Activity__c> createActivityByObjectIdAndTemplateNameBulk(list<String> objectIds, String templateName){
        system.debug('HDT_UTL_Scarti objectIds ' + objectIds);
        system.debug('HDT_UTL_Scarti templateName ' + templateName);
        try{
            Map<String, wrts_prcgvr__ActivityTemplate__c> template = getTemplatesMapByName(new Set<String>{templateName});
            system.debug('HDT_UTL_Scarti template ' + template);
            if(template.values().size() > 0){
                wrts_prcgvr.Interfaces_1_1.IActivityIntegration activityIntegration = (wrts_prcgvr.Interfaces_1_1.IActivityIntegration) wrts_prcgvr.VersionManager.newClassInstance('ActivityIntegration');
                List<wrts_prcgvr__Activity__c> resultActivities = new List<wrts_prcgvr__Activity__c>();
                for(String singleObjectId: objectIds){
                    List<wrts_prcgvr__Activity__c> activities = (List<wrts_prcgvr__Activity__c>) activityIntegration.createFromTemplate(template.values().get(0).wrts_prcgvr__Code__c, new Map<String,Object>{'objectId'=>singleObjectId});
                    system.debug('HDT_UTL_Scarti single activity ' + activities.get(0));
                    resultActivities.add(activities.get(0));
                }
                system.debug('HDT_UTL_Scarti end ' + resultActivities);
                return resultActivities;
            }
            system.debug('HDT_UTL_Scarti end');
            return null;
        }
        catch(Exception e){
            system.debug('HDT_UTL_Scarti catch ' + e);
            return null;
        }
    }

    /**
    * @author Costanzo Lo Mele (costanzo.lomele@webresults.it)
    * @date 22/07/2021
    * @description HDT_UTL_Scarti.checkActivityCreation - Check on activity creation
    * @param recordId - Id of a record
    * @param templateName - String
    * @return Boolean
    */
    public static Boolean checkActivityCreation(Id recordId, String templateName){
        System.debug('checkActivityCreation start recordId: ' + recordId + '; templateName: ' + templateName);
        Map<String, wrts_prcgvr__ActivityTemplate__c> templateMap = getTemplatesMapByName(new Set<String>{templateName});
        if(!templateMap.isEmpty()){
            List<wrts_prcgvr__ActivityAction__c> actions = [SELECT Id, wrts_prcgvr__Field__c, wrts_prcgvr__Value__c 
                                                            FROM wrts_prcgvr__ActivityAction__c 
                                                            WHERE wrts_prcgvr__ActivityTemplate__c = :templateMap.get(templateName).Id
                                                            AND wrts_prcgvr__Field__c = '{!Type__c}'
                                                            WITH SECURITY_ENFORCED];
            if(!actions.isEmpty()){
            	String activityType  = actions.get(0).wrts_prcgvr__Value__c;
            	return !checkDiscardAnnullmentRule(recordId, activityType);
            }
        }
        return false;
    }

    /**
    * @author Costanzo Lo Mele (costanzo.lomele@webresults.it)
    * @date 22/07/2021
    * @description HDT_UTL_Scarti.checkDiscardAnnullmentRule - Check on pratica annullment
    * @param recordId - Id of a record
    * @param activityType - String
    * @return boolean : true if it has to do annullment; false instead
    */
    public static boolean checkDiscardAnnullmentRule(Id recordId, String activityType){
        System.debug('checkDiscardAnnullmentRule start recordId: ' + recordId + '; activityType: ' + activityType);
        Boolean outcome = false;
        String parentObj;
        if(Schema.Case.SObjectType == recordId.getSobjectType()){ 
            parentObj = 'Case';
        }
        if(Schema.Order.SObjectType == recordId.getSobjectType()){
            parentObj = 'Order';
        }

        List<DiscardAnnullmentRule__c> rules = [SELECT ControllingField__c, ControllingValue__c, ProcessField__c, ProcessValue__c 
                                                FROM DiscardAnnullmentRule__c
                                                WHERE ParentObject__c = :parentObj
                                                AND ActivityType__c = :activityType
                                                WITH SECURITY_ENFORCED];
		
        System.debug('checkDiscardAnnullmentRule rules: ' + JSON.serializePretty(rules));
        if(!rules.isEmpty()){
            String logicFields = '';
            //START>>>modifica marco.arci@webresults.it
            set<string> logicFieldsSet = new set<String>();
            for(DiscardAnnullmentRule__c curRule : rules){
                logicFieldsSet.add(curRule.ControllingField__c);
                logicFieldsSet.add(curRule.ProcessField__c);
            }
            for(string currString : logicFieldsSet){
                logicFields += ','+currString;
            }
			//END>>>modifica modifica marco.arci@webresults.it
            system.debug('logicFields: '+logicFields);
            if(Schema.Case.SObjectType == recordId.getSobjectType()){
                String queryString = 'SELECT Id' + logicFields + ' FROM Case WHERE Id = \'' + recordId + '\'';
                system.debug('queryString: '+queryString);
                List<Case> parentCase = Database.query(queryString);
                if(!parentCase.isEmpty()){
                    for(DiscardAnnullmentRule__c curRule : rules){
                        String parentCaseProcField = String.valueOf(parentCase.get(0).get(curRule.ProcessField__c));
                        String parentCaseContrField = String.valueOf(parentCase.get(0).get(curRule.ControllingField__c));
                        if(String.isNotBlank(parentCaseProcField) && String.isNotBlank(parentCaseContrField)){
                            if(curRule.ProcessValue__c.equalsIgnoreCase(parentCaseProcField) && parentCaseContrField.containsIgnoreCase(curRule.ControllingValue__c)){
                                System.debug('checkDiscardAnnullmentRule found rule parentCaseProcField: ' + parentCaseProcField);
                                System.debug('checkDiscardAnnullmentRule found rule parentCaseContrField: ' + parentCaseContrField);
                                System.debug('checkDiscardAnnullmentRule found rule curRule.ProcessValue__c: ' + curRule.ProcessValue__c);
                                System.debug('checkDiscardAnnullmentRule found rule curRule.ControllingField__c: ' + curRule.ControllingField__c);
                                outcome = true;
                                break;
                            }
                        }
                    }
                }
            }
            if(Schema.Order.SObjectType == recordId.getSobjectType()){
                String queryString = 'SELECT Id' + logicFields + ' FROM Order WHERE Id = \'' + recordId + '\'';
                system.debug('queryString: '+queryString);
                List<Order> parentOrder = Database.query(queryString);
                if(!parentOrder.isEmpty()){
                    for(DiscardAnnullmentRule__c curRule : rules){
                        String parentOrderProcField = String.valueOf(parentOrder.get(0).get(curRule.ProcessField__c));
                        String parentOrderContrField = String.valueOf(parentOrder.get(0).get(curRule.ControllingField__c));
                        if(curRule.ProcessValue__c.equalsIgnoreCase(parentOrderProcField) && parentOrderContrField.containsIgnoreCase(curRule.ControllingValue__c)){
                            System.debug('checkDiscardAnnullmentRule found rule parentOrderProcField: ' + parentOrderProcField);
        					System.debug('checkDiscardAnnullmentRule found rule parentOrderContrField: ' + parentOrderContrField);
        					System.debug('checkDiscardAnnullmentRule found rule curRule.ProcessValue__c: ' + curRule.ProcessValue__c);
        					System.debug('checkDiscardAnnullmentRule found rule curRule.ControllingField__c: ' + curRule.ControllingField__c);
                            outcome = true;
                            break;
                        }
                    }
                }
            }
        }
        System.debug('checkDiscardAnnullmentRule outcome: ' + outcome);
        return outcome;
    }


    /**
    * @author Costanzo Lo Mele (costanzo.lomele@webresults.it)
    * @date 22/07/2021
    * @description HDT_UTL_Scarti.updatePraticaForScartoDocumentale - updates case/order with new data
   * @param newActivities - List<wrts_prcgvr__Activity__c>
    * @param oldActivities - List<wrts_prcgvr__Activity__c>
    */
    //////////////////////////////////////////////////////////////////////////
    @AuraEnabled
    public static void updatePraticaForScartoDocumentale(List<wrts_prcgvr__Activity__c> newActivities, List<wrts_prcgvr__Activity__c> oldActivities){
        HDT_UTL_Scarti updateJob = new HDT_UTL_Scarti(newActivities, oldActivities);
        System.enqueueJob(updateJob);
    }

    /**
    * @author Costanzo Lo Mele (costanzo.lomele@webresults.it)
    * @date 22/07/2021
    * @description HDT_UTL_Scarti.updatePraticaForScartoDocumentaleQueue - updates case/order with new data
   * @param newActivities - List<wrts_prcgvr__Activity__c>
    * @param oldActivities - List<wrts_prcgvr__Activity__c>
    */
    //////////////////////////////////////////////////////////////////////////
    @AuraEnabled
    public static void updatePraticaForScartoDocumentaleQueue(List<wrts_prcgvr__Activity__c> newActivities, List<wrts_prcgvr__Activity__c> oldActivities){
        System.debug('updatePraticaForScartoDocumentale start newActivities: ' + JSON.serializePretty(newActivities));
        System.debug('updatePraticaForScartoDocumentale start oldActivities: ' + JSON.serializePretty(oldActivities));
        try{
        Map<id,wrts_prcgvr__Activity__c> oldMapActivities = new Map<Id,wrts_prcgvr__Activity__c>(oldActivities);
        String oldPhone; 
        String oldEmail;
        List<wrts_prcgvr__Activity__c> activities = new list<wrts_prcgvr__Activity__c>();
        List<id> relatedIds = new list<id>();
        list<SObject> relatedObjectsToUpdate = new list<SObject>();

        for(wrts_prcgvr__Activity__c currActivity : newActivities){
            if((currActivity.NewMobile__c!=oldMapActivities.get(currActivity.Id).NewMobile__c && currActivity.NewMobile__c!=null)
                || (currActivity.NewEmail__c!=oldMapActivities.get(currActivity.Id).NewEmail__c && currActivity.NewEmail__c!=null)){
                activities.add(currActivity);
                if(currActivity.Case__c != null){
                    relatedIds.add(currActivity.Case__c);
                }else if(currActivity.Order__c != null){
                    relatedIds.add(currActivity.Order__c);
                }
            }
        }

        Map<Id,Case> relatedCases = new Map<Id,Case>([SELECT Id, PhoneNumber__c, Email__c, AccountId
                                   FROM Case
                                   WHERE Id in :relatedIds
                                   WITH SECURITY_ENFORCED]);
        Map<Id,Order> relatedOrders = new Map<Id,Order>([SELECT Id, PhoneNumber__c, Email__c, AccountId
                                     FROM Order
                                     WHERE Id in :relatedIds
                                     WITH SECURITY_ENFORCED]);

        System.debug('updatePraticaForScartoDocumentale relatedCases: ' + JSON.serializePretty(relatedCases));
        System.debug('updatePraticaForScartoDocumentale relatedOrders: ' + JSON.serializePretty(relatedOrders));
        
        for(wrts_prcgvr__Activity__c currActivity : activities){
                if(currActivity.Case__c != null){
                    oldPhone = relatedCases.get(currActivity.Case__c).PhoneNumber__c;
                    oldEmail = relatedCases.get(currActivity.Case__c).Email__c;
                    relatedCases.get(currActivity.Case__c).PhoneNumber__c = currActivity.NewMobile__c;
                    relatedCases.get(currActivity.Case__c).Email__c = currActivity.NewEmail__c;
                    relatedObjectsToUpdate.add(relatedCases.get(currActivity.Case__c));
                    updateContactForScartoDocumentale(relatedCases.get(currActivity.Case__c).AccountId, oldPhone, oldEmail, currActivity.NewMobile__c, currActivity.NewEmail__c);
                }
                if(currActivity.Order__c != null){
                    oldPhone = relatedOrders.get(currActivity.Order__c).PhoneNumber__c;
                    oldEmail = relatedOrders.get(currActivity.Order__c).Email__c;
                    relatedOrders.get(currActivity.Order__c).PhoneNumber__c = currActivity.NewMobile__c;
                    relatedOrders.get(currActivity.Order__c).Email__c = currActivity.NewEmail__c;
                    relatedObjectsToUpdate.add(relatedOrders.get(currActivity.Order__c));
                    updateContactForScartoDocumentale(relatedOrders.get(currActivity.Order__c).AccountId, oldPhone, oldEmail, currActivity.NewMobile__c, currActivity.NewEmail__c);
                }
        }
        System.debug('updatePraticaForScartoDocumentale end relatedObjectsToUpdate: ' + JSON.serializePretty(relatedObjectsToUpdate));
        if(!relatedObjectsToUpdate.isEmpty()){
            HDT_UTL_DatabaseService.updateSObject(relatedObjectsToUpdate);
        }
        }
        catch(Exception e){
            System.debug('updatePraticaForScartoDocumentale errorMessage: ' + e.getMessage());
            System.debug('updatePraticaForScartoDocumentale errorStackTraceString: ' + e.getStackTraceString());
        }
    }

    /**
    * @author Costanzo Lo Mele (costanzo.lomele@webresults.it)
    * @date 22/07/2021
    * @description HDT_UTL_Scarti.updateContactForScartoDocumentale - updates contact points with new data
    * @param oldPhone - String
    * @param oldEmail - String
    * @param newPhone - String
    * @param newMail - String
    */
    @AuraEnabled
    public static void updateContactForScartoDocumentale(Id accountId, String oldPhone, String oldEmail, String newPhone, String newMail){
        System.debug('updateContactForScartoDocumentale start accountId: ' + accountId);
        System.debug('updateContactForScartoDocumentale start oldPhone: ' + oldPhone );
        System.debug('updateContactForScartoDocumentale start oldEmail: ' + oldEmail);
        System.debug('updateContactForScartoDocumentale start newPhone: ' + newPhone);
        System.debug('updateContactForScartoDocumentale start newMail: ' + newMail);
        try{
        List<Contact> relatedContacts = [SELECT Id, IndividualId
                                         FROM Contact 
                                         WHERE AccountId = :accountId
                                         WITH SECURITY_ENFORCED];
        if(!relatedContacts.isEmpty()){
            Set<Id> individualIds = new Set<Id>();
            for(Contact curContact : relatedContacts){
                individualIds.add(curContact.IndividualId);
            } 
            List<sObject> recordsForDML = new List<SObject>();
            if(String.isNotBlank(oldPhone)){
                List<ContactPointPhone> cpp = [SELECT Id, TelephoneNumber, Status__c, ParentId 
                                                FROM ContactPointPhone 
                                                WHERE ParentId IN :individualIds
                                                AND TelephoneNumber = :oldPhone
                                                WITH SECURITY_ENFORCED];
                if(!cpp.isEmpty()){
                    if('Verificato'.equalsIgnoreCase(cpp.get(0).Status__c)){
                        ContactPointPhone newCPP = new ContactPointPhone();
                        newCPP.TelephoneNumber = newPhone;
                        newCPP.Status__c = 'Non verificato';
                        newCPP.ParentId = cpp.get(0).ParentId;
                        recordsForDML.add(newCPP);
                    }
                    else if('Non Verificato'.equalsIgnoreCase(cpp.get(0).Status__c)){
                        ContactPointPhone toUpdateCPP = new ContactPointPhone(Id = cpp.get(0).Id);
                        toUpdateCPP.TelephoneNumber = newPhone;
                        recordsForDML.add(toUpdateCPP);
                    }
                }
            }
            if(String.isNotBlank(oldEmail)){
                List<ContactPointEmail> cpe = [SELECT Id, EmailAddress, Status__c, ParentId 
                                                FROM ContactPointEmail 
                                                WHERE ParentId IN :individualIds
                                                AND EmailAddress = :oldEmail
                                                WITH SECURITY_ENFORCED];
                if(!cpe.isEmpty()){
                    if('Verificato'.equalsIgnoreCase(cpe.get(0).Status__c)){
                        ContactPointEmail newCPE = new ContactPointEmail();
                        newCPE.EmailAddress = newMail;
                        newCPE.Status__c = 'Non verificato';
                        newCPE.ParentId = cpe.get(0).ParentId;
                        recordsForDML.add(newCPE);
                    }
                    else if('Non Verificato'.equalsIgnoreCase(cpe.get(0).Status__c)){
                        ContactPointEmail toUpdateCPE = new ContactPointEmail(Id = cpe.get(0).Id);
                        toUpdateCPE.EmailAddress = newMail;
                        recordsForDML.add(toUpdateCPE);
                    }
                }
            }
            System.debug('updateContactForScartoDocumentale end recordsForDML: ' + JSON.serializePretty(recordsForDML));
            if(!recordsForDML.isEmpty()){
                HDT_UTL_DatabaseService.upsertSObject(recordsForDML);
            }
        }
        }
        catch(Exception e){
            System.debug('updateContactForScartoDocumentale errorMessage: ' + e.getMessage());
            System.debug('updateContactForScartoDocumentale errorStackTraceString: ' + e.getStackTraceString());
        }
    }

    /**
    * @author Marco Arci (marco.arci@webresults.it)
    * @date 22/07/2021
    * @description HDT_UTL_Scarti.setLookupFields - populating lookup fields
    * @param inputData - list<wrts_prcgvr__Activity__c>
    * @return List<wrts_prcgvr__Activity__c> 
    */
    public static List<wrts_prcgvr__Activity__c> setLookupFields(List<wrts_prcgvr__Activity__c> inputData){
        System.debug('setLookupFields start' + inputData);
        list<string> codiciClienti= new list<String>();
        set<string> activityTypes= new set<string>();

        RecordType rtScarto = new HDT_QR_RecordType().getRecordType('HDT_RT_Scarto', 'wrts_prcgvr__Activity__c');

        for(wrts_prcgvr__Activity__c activity: inputData){
            if(activity.Account__c == null && !String.isBlank(activity.BPCode__c)){
                codiciClienti.add(activity.BPCode__c);
            }
            if(activity.wrts_prcgvr__ActivityTemplate__c == null && !String.isBlank(activity.Type__c)){
                activityTypes.add(activity.Type__c);
            }
        }
        System.debug('setLookupFields codiciClienti' + codiciClienti);
        System.debug('setLookupFields activityTypes' + activityTypes);

        map<string,Id> mapActivityTemplates= new map<string,Id>();
        list<wrts_prcgvr__ActivityTemplate__c> activityTemplates=[SELECT Id, Name 
                                                                  FROM wrts_prcgvr__ActivityTemplate__c
                                                                  WHERE Name =: CANONERAITEMPLATENAME
                                                                  OR Name=: BONUSSOCIALETEMPLATENAME 
                                                                  WITH SECURITY_ENFORCED];
        for(wrts_prcgvr__ActivityTemplate__c singleTemplate: activityTemplates){
            mapActivityTemplates.put(singleTemplate.Name,singleTemplate.Id);
        }


        List<Account> listAccounts=[SELECT Id, CustomerCode__c 
                                    FROM Account 
                                    WHERE CustomerCode__c IN: codiciClienti 
                                    WITH SECURITY_ENFORCED];
        Map<String, Id> accIdsPerBPcode = new Map<String, Id>();
        for(Account singleAccount: listAccounts){
            accIdsPerBPcode.put(singleAccount.CustomerCode__c, singleAccount.Id);
        }
        for(wrts_prcgvr__Activity__c activity2: inputData){
            if(activity2.Account__c == null && !String.isBlank(activity2.BPCode__c)){
                activity2.Account__c = accIdsPerBPcode.get(activity2.BPCode__c);
            }
            if(activity2.wrts_prcgvr__ActivityTemplate__c == null){
                if('CanoneRAI'.equalsIgnoreCase(activity2.Type__c)){
                    if(activity2.RecordTypeId != rtScarto.Id){
                        activity2.RecordTypeId = rtScarto.Id;
                    }
                    activity2.wrts_prcgvr__ActivityTemplate__c=mapActivityTemplates.get(CANONERAITEMPLATENAME); 
                }else if('Bonussociale'.equalsIgnoreCase(activity2.Type__c)){
                    if(activity2.RecordTypeId != rtScarto.Id){
                        activity2.RecordTypeId = rtScarto.Id;
                    }
                    activity2.wrts_prcgvr__ActivityTemplate__c=mapActivityTemplates.get(BONUSSOCIALETEMPLATENAME); 
                }
            }
            if(activity2.RecordTypeDevName__c == 'HDT_RT_Scarto' && activity2.RecordTypeId != rtScarto.Id){
                activity2.RecordTypeId = rtScarto.Id;
            }
        }
        System.debug('setLookupFields end' + inputData);
        return inputData;
    }

    /**
    * @author Marco Arci (marco.arci@webresults.it)
    * @date 23/07/2021
    * @description HDT_UTL_Scarti.createScartoForMarketingCloud - Creazione attività PClick
    * @param inputData - List<SObject> of et4ae5__IndividualEmailResult__c
    * @param oldData - Map<Id,SObject>
    */
    public static void createScartoForMarketingCloud(List<SObject> inputData, Map<Id,SObject> oldData){
        list<SObject> toHandle= new list<SObject>();
        for(SObject singleData: inputData){
            if(singleData.getSObjectType()==schema.et4ae5__IndividualEmailResult__c.getSObjectType()){
                if(String.isNotBlank((string)singleData.get('BounceSubCategory__c')) && 
                    oldData.get((Id)singleData.get('Id')).get('BounceSubCategory__c')!=((string)singleData.get('BounceSubCategory__c'))){
                    toHandle.add(singleData);
                }
            }else if(singleData.getSObjectType()==schema.SMSTracking__c.getSObjectType()){
                if(singleData.get('Undelivered__c')==true
                   && oldData.get((Id)singleData.get('Id')).get('Undelivered__c')!=singleData.get('Undelivered__c')){
                    toHandle.add(singleData);
                }
            }
        }
        

        if(toHandle.size()!=0){
            list<wrts_prcgvr__Activity__c> insertedActivities= new list<wrts_prcgvr__Activity__c>();
            wrts_prcgvr.Interfaces_1_1.IActivityIntegration activityIntegration =(wrts_prcgvr.Interfaces_1_1.IActivityIntegration)wrts_prcgvr.VersionManager.newClassInstance('activityIntegration');
            list<wrts_prcgvr__ActivityTemplate__c> templates=[SELECT id, name, wrts_prcgvr__Code__c 
                                                                FROM wrts_prcgvr__ActivityTemplate__c 
                                                                WHERE name=: SCARTODOCUMENTALEPOSTSALESTEMPLATENAME 
                                                                OR name=: SCARTODOCUMENTALESALESTEMPLATENAME
                                                                WITH SECURITY_ENFORCED];
            map<string,string> templateCodes= new Map<String,string>();                                             
            for(wrts_prcgvr__ActivityTemplate__c template: templates){
                if(SCARTODOCUMENTALEPOSTSALESTEMPLATENAME.equalsIgnoreCase(template.name)){
                    templateCodes.put('postSalesTemplate',template.wrts_prcgvr__Code__c);    
                }else if(SCARTODOCUMENTALESALESTEMPLATENAME.equalsIgnoreCase(template.name)){
                    templateCodes.put('salesTemplate',template.wrts_prcgvr__Code__c);    
                }
            }

            List<wrts_prcgvr__Activity__c> currActivities;
            Id parentObjId;
            for(SObject handlesItem: toHandle){
                if(String.isNotBlank((string)handlesItem.get('OrderID__c'))){
                    parentObjId = (String)handlesItem.get('OrderID__c');
                }else if(String.isNotBlank((string)handlesItem.get('CaseID__c'))){ 
                    parentObjId = (String)handlesItem.get('CaseID__c');
                }
                currActivities = (wrts_prcgvr__Activity__c[]) activityIntegration.createFromTemplate(templateCodes.get('postSalesTemplate'), new Map<String,Object>{'objectId' => parentObjId});
                currActivities[0].wrts_prcgvr__Description__c = handlesItem.getSObjectType() == schema.et4ae5__IndividualEmailResult__c.getSObjectType() ? 'Scarto EMAIL Marketing Cloud' : (handlesItem.getSObjectType()==schema.SMSTracking__c.getSObjectType() ? 'Scarto SMS Marketing Cloud' : '');
                insertedActivities.addAll(currActivities);
            }
            HDT_UTL_DatabaseService.insertSObject(insertedActivities);
        }
    }

    /**
    * @author Marco Arci (marco.arci@webresults.it)
    * @date 12/08/2021
    * @description HDT_UTL_Scarti.checkForEsitiIntermedi - annullamneto scarti dopo ricezione scarto Heroku
    * @param inputData - list<wrts_prcgvr__Activity__c>  of Herokus's scarti (activity(custom) 
    */
    public static void checkForEsitiIntermedi(List<wrts_prcgvr__Activity__c> inputData){
        system.debug('checkForEsitiIntermedi start' + JSON.serializePretty(inputData));
        Set<String> categories = new Set<String>();
        Schema.DescribeFieldResult fieldResult = wrts_prcgvr__Activity__c.DiscardCategory__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
            if(!'Manuale'.equalsIgnoreCase(pickListVal.getValue()) && pickListVal.isActive()){
                categories.add(pickListVal.getValue());
            }
		}     

        List<wrts_prcgvr__Activity__c> toUpdate = new List<wrts_prcgvr__Activity__c>();

        set<id> parentObjectCase = new set<id>();
        set<id> parentObjectOrder = new set<id>();
        set<id> inputDataIds = new set<id>();
        for(wrts_prcgvr__Activity__c currAct : inputData){
            if(categories.contains(currAct.DiscardCategory__c)){
                inputDataIds.add(currAct.Id);
                if(String.isNotBlank(currAct.wrts_prcgvr__ObjectId__c)){
                    if(Schema.Case.SObjectType == Id.valueOf(currAct.wrts_prcgvr__ObjectId__c).getSobjectType()){
                        parentObjectCase.add(currAct.wrts_prcgvr__ObjectId__c);
                    }else if(Schema.Order.SObjectType == Id.valueOf(currAct.wrts_prcgvr__ObjectId__c).getSobjectType()){
                        parentObjectOrder.add(currAct.wrts_prcgvr__ObjectId__c);
                    }
                }
            }
        }
        
        system.debug('checkForEsitiIntermedi parentObjectCase' + JSON.serializePretty(parentObjectCase));
        system.debug('checkForEsitiIntermedi parentObjectOrder' + JSON.serializePretty(parentObjectOrder));
        system.debug('checkForEsitiIntermedi categories' + JSON.serializePretty(categories));
        system.debug('checkForEsitiIntermedi inputDataIds' + JSON.serializePretty(inputDataIds));

        list<wrts_prcgvr__Activity__c> relatedActs = [SELECT id, wrts_prcgvr__Status__c 
                                                      FROM wrts_prcgvr__Activity__c 
                                                      WHERE (Case__c IN :parentObjectCase OR Order__c IN :parentObjectOrder) 
                                                      AND DiscardCategory__c IN :categories 
                                                      AND Id NOT IN :inputDataIds
                                                      AND wrts_prcgvr__Status__c NOT IN ('Chiusa','Sospesa')
                                                      WITH SECURITY_ENFORCED];

        system.debug('checkForEsitiIntermedi relatedActs' + JSON.serializePretty(relatedActs));

        for(wrts_prcgvr__Activity__c relatedAct: relatedActs){
            system.debug(relatedAct);
            relatedAct.wrts_prcgvr__Status__c='Chiusa';
            toUpdate.add(relatedAct);
        }

        
        if(!toUpdate.IsEmpty()){
            system.debug('checkForEsitiIntermedi toUpdate' + JSON.serializePretty(inputData));
            HDT_UTL_DatabaseService.updateSObject(toUpdate);
        }
    }
    
    /**
    * @author Costanzo Pio Lo Mele (costanzo.lomele@webresults.it)
    * @date 14/10/2021
    * @description HDT_UTL_Scarti.handleEditButtonPress - annullamento pratica
    * @param newActs
    * @param oldActsMap
    */
    public static void handleEditButtonPress(List<wrts_prcgvr__Activity__c> newActs, Map<Id, wrts_prcgvr__Activity__c> oldActsMap){
        System.debug('handleEditButtonPress start');
        RecordType rtScarto = new HDT_QR_RecordType().getRecordType('HDT_RT_Scarto', 'wrts_prcgvr__Activity__c');
        for(wrts_prcgvr__Activity__c curAct : newActs){
            if('Completed'.equalsIgnoreCase(curAct.wrts_prcgvr__Status__c)
               && curAct.wrts_prcgvr__Status__c != oldActsMap.get(curAct.Id).wrts_prcgvr__Status__c
               && rtScarto.Id == curAct.RecordTypeId){
        		System.debug('handleEditButtonPress found ' + curAct.Id);
                if('Scarto Complesso'.equalsIgnoreCase(curAct.DiscardCategory__c)
                   || 'Contattare il cliente'.equalsIgnoreCase(curAct.Type__c)){
                	curAct.wrts_prcgvr__Status__c = 'Aperta';
                }
                else curAct.wrts_prcgvr__Status__c = 'Chiusa';
            	curAct.DiscardWorked__c = true;
        	}
        }
    }
 
    /**
    * @author Marco Arci (marco.arci@webresults.it)
    * @date 27/08/2021
    * @description HDT_UTL_Scarti.annullaPratica - annullamento pratica
    * @param objectId - Id
    */
    public static void annullaPratica(Id objectId){
        if(Schema.Case.SObjectType == objectId.getSobjectType()){
            Case caseRecord= new Case(Id=objectId, Phase__c='Annullato', Status='Closed', CancellationReason__c='Gestione Scarto');
            /*eventuali modifiche*/
            HDT_UTL_DatabaseService.updateSObject(caseRecord);
        }else if(Schema.Order.SObjectType == objectId.getSobjectType()){
            Order orderRecord = new Order(Id=objectId, Phase__c='Annullato', Status='Activated', CancellationReason__c='Gestione Scarto');
            /*eventuali modifiche*/
            HDT_UTL_DatabaseService.updateSObject(orderRecord);
        }
    }

    /**
    * @author Marco Arci (marco.arci@webresults.it)
    * @date 27/08/2021
    * @description HDT_UTL_Scarti.chiudiAttvita - chiusura attività figlie
    * @param objectId - objectId
    */
    public static void chiudiAttivita(Id objectId){
        List<wrts_prcgvr__Activity__c> toUpdateActivities = new list<wrts_prcgvr__Activity__c>();
        if(Schema.Case.SObjectType == objectId.getSobjectType()){
            toUpdateActivities = [SELECT id, wrts_prcgvr__Status__c
                                  FROM wrts_prcgvr__Activity__c
                                  WHERE Case__c= :objectId 
                                  AND wrts_prcgvr__Status__c != 'Chiusa'
                                  WITH SECURITY_ENFORCED]; 
            for(wrts_prcgvr__Activity__c singleActivity : toUpdateActivities){
                singleActivity.wrts_prcgvr__Status__c='Chiusa';
            }
            HDT_UTL_DatabaseService.updateSObject(toUpdateActivities);
        }else if(Schema.Order.SObjectType == objectId.getSobjectType()){
            toUpdateActivities = [SELECT id, wrts_prcgvr__Status__c
                        FROM wrts_prcgvr__Activity__c
                        WHERE Order__c= :objectId 
                        AND wrts_prcgvr__Status__c != 'Chiusa'
                        WITH SECURITY_ENFORCED];
            for(wrts_prcgvr__Activity__c singleActivity : toUpdateActivities){
                singleActivity.wrts_prcgvr__Status__c='Chiusa';
            }
            HDT_UTL_DatabaseService.updateSObject(toUpdateActivities);
        }    
    }

}