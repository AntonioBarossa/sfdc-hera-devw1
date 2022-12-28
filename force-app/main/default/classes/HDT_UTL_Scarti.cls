/**
 * @author Marco Arci (marco.arci@webresults.it)
 * @date 22/07/2021
 * @description HDT_UTL_Scarti - Utility scarti
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */
@SuppressWarnings('PMD.EmptyStatementBlock , PMD.AvoidGlobalModifier , PMD.AvoidDebugStatements, PMD.LocalVariableNamingConventions, PMD.MethodNamingConventions, PMD.CyclomaticComplexity, PMD.AvoidDeeplyNestedIfStmts, PMD.ExcessivePublicCount, PMD.ExcessiveParameterList, PMD.ExcessiveClassLength')
global with sharing class HDT_UTL_Scarti implements wrts_prcgvr.Interfaces_1_2.IApexCriteria, Queueable{
    private List<wrts_prcgvr__Activity__c> newActivities;
    private List<wrts_prcgvr__Activity__c> oldActivities;

    static final string CANONERAITEMPLATENAME='CBS_CAR002__CANONE_RAI';
    static final string BONUSSOCIALETEMPLATENAME='CBS_FAT011__BONUS_SOCIALE';
    static final string SCARTODOCUMENTALEPOSTSALESTEMPLATENAME='CBS_CRP004__SCARTI_DOCUMENTALI_POST_SALES';
    static final string SCARTODOCUMENTALESALESTEMPLATENAME='CBS_CRP003__SCARTI_DOCUMENTALI_SALES';
    

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
    
    global HDT_UTL_Scarti(){}//need empty constructor for Dynamically creating instance of this class

    public HDT_UTL_Scarti(List<wrts_prcgvr__Activity__c> newActs, List<wrts_prcgvr__Activity__c> oldActs) {
        this.newActivities = newActs;
        this.oldActivities = oldActs;
    }

    public void execute(QueueableContext context) {
        system.debug(LoggingLevel.DEBUG, 'HDT_UTL_Scarti execute start QueueableContext: ' + context);
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
            system.debug(LoggingLevel.DEBUG, e.getMessage());
            system.debug(LoggingLevel.DEBUG, e.getStackTraceString());
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
                when 'selfReading','discardSelfReading'{
                    Map <String, Object> mapParam=new Map<String,object>();
                    case c=new case(Id=inputParam[0].objectId);
                    if ('discardSelfReading'.equalsIgnoreCase(inputParam[0].methodName)){
                        System.enqueueJob(new HDT_QBL_SelfReadingsCallouts(c,'InvioLettureForzato',true));
                    }
                    Map <String,String> reqType=new Map <String, String>();
                    reqType.put('requestType', 'InvioLettureForzato');
                    mapParam.put('sender', c);
                    mapParam.put('parameters', reqType);
                    HDT_SRV_SelfReadingsFacade selfReadingsFacade=new HDT_SRV_SelfReadingsFacade();
                    selfReadingsFacade.execute((Object)mapParam);
                }
            }
            output.recordId=outputRecordId;
            output.esito='OK';
            output.dettaglioEsito='OK';
        }catch(Exception e){
            system.debug(LoggingLevel.DEBUG, 'ERROR: ' + e.getMessage() + ' @@ ' + e.getStackTraceString());
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
        Map<String, String> activitiesValues = new Map<String,String>();
        for (HDT_WRP_MrrRequest.HDT_WRP_Request request : inboundRequests) {
            HDT_WRP_MrrResponse.HDT_WRP_Response parsedResponseItem = (HDT_WRP_MrrResponse.HDT_WRP_Response) JSON.deserialize(JSON.serialize(request), HDT_WRP_MrrResponse.HDT_WRP_Response.class);
            for(HDT_WRP_MrrResponse.HDT_WRP_Object curObj : parsedResponseItem.objects){
                for(HDT_WRP_MrrResponse.HDT_WRP_Field curField : curObj.fields){
                    activitiesValues.put(curField.name,curField.value);
                    system.debug(LoggingLevel.DEBUG, 'handleMRRInboundRequest curField: ' + curField.name + ' ' + curField.value);
                    /* 
                    //Gestione scarti SAP commentata per nuova gestione tramite custom metadata type 
                    if('ATTIVITA'.equalsIgnoreCase(curField.name) && TRACCIATURATYPES.contains(curField.value)){ */
                    if('ATTIVITA'.equalsIgnoreCase(curField.name) && 'Richiesta non identificata'.equalsIgnoreCase(curField.value)){
                        Map<String,String> newData = new Map<String,String>();
                        for(HDT_WRP_MrrResponse.HDT_WRP_Field curField2 : curObj.fields){ newData.put(curField2.name, curField2.value); }
                        /* 
                        Commentato perché nella Richiesta non identificata, il curObj.fields è vuoto ed in ogni caso non serve.
                        for(HDT_WRP_MrrRequest.HDT_WRP_Field curField3 : request.header.fields){ newData.put(curField3.name, curField3.value); }
                         */
                        dataForAttivitaTracciaturaCreation.add(newData);
                    }
                    if(('FASE'.equalsIgnoreCase(curField.name) && String.isNotBlank(curField.value)) 
                        || ('ATTIVITA'.equalsIgnoreCase(curField.name) && 'Eliminato esito in scarto'.equalsIgnoreCase(curField.value))){
                    	system.debug(LoggingLevel.DEBUG, 'handleMRRInboundRequest curField: ' + curField.name + ' ' + curField.value);
                        for(HDT_WRP_MrrResponse.HDT_WRP_Field curField2 : curObj.fields){
                            if('RECORD_ID'.equalsIgnoreCase(curField2.name)){
                                if(curField2.value.length() == 18 ){
                                    wrts_prcgvr__Activity__c tempAct = new wrts_prcgvr__Activity__c(DiscardCategory__c = 'Tracciatura');
                                    tempAct.wrts_prcgvr__ObjectId__c = curField2.value;   
                                    if(Schema.Case.SObjectType == Id.valueOf(curField2.value).getSobjectType()){
                                        tempAct.Case__c = curField2.value;
                                        dataForCheckEsitiIntermedi.add(tempAct);
                                    }else if(Schema.Order.SObjectType == Id.valueOf(curField2.value).getSobjectType()){
                                        tempAct.Order__c = curField2.value;
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
        system.debug(LoggingLevel.DEBUG, 'MRREQUEST orderNameSet' + JSON.serializePretty(orderNameSet));
        if(!orderNameSet.isEmpty()){
            for(Order curOrder : [SELECT Id FROM Order WHERE OrderNumber IN :orderNameSet]){
                wrts_prcgvr__Activity__c tempAct = new wrts_prcgvr__Activity__c(DiscardCategory__c = 'Tracciatura');
                tempAct.Order__c = curOrder.Id;
                tempAct.wrts_prcgvr__ObjectId__c = curOrder.Id;
                dataForCheckEsitiIntermedi.add(tempAct);
            }
        }
        system.debug(LoggingLevel.DEBUG, 'MRREQUEST dataForAttivitaTracciaturaCreation' + JSON.serializePretty(dataForAttivitaTracciaturaCreation));
        system.debug(LoggingLevel.DEBUG, 'MRREQUEST dataForCheckEsitiIntermedi' + JSON.serializePretty(dataForCheckEsitiIntermedi));
        if(!dataForAttivitaTracciaturaCreation.isEmpty()){ createAttivitaTracciaturaHeroku(dataForAttivitaTracciaturaCreation); }
        if(!dataForCheckEsitiIntermedi.isEmpty()){ checkForEsitiIntermedi(dataForCheckEsitiIntermedi,activitiesValues); }
    }


    /**
    * @author Costanzo Lo Mele (costanzo.lomele@webresults.it)
    * @date 22/07/2021
    * @description HDT_UTL_Scarti.getTemplatesMapByName - returns a map <templateName, templateObj>
    * @param names - Set<String>
    * @return Map<String, wrts_prcgvr__ActivityTemplate__c> name per template
    */
    public static Map<String, wrts_prcgvr__ActivityTemplate__c> getTemplatesMapByName(Set<String> names){
        return getTemplatesMapByName(names,null);
    }

    public static Map<String, wrts_prcgvr__ActivityTemplate__c> getTemplatesMapByName(Set<String> names, String objectType){
        Map<String, wrts_prcgvr__ActivityTemplate__c> returnMap = new Map<String, wrts_prcgvr__ActivityTemplate__c>();
        List<wrts_prcgvr__ActivityTemplate__c> queryResult;
        if (String.isEmpty(objectType)){
            queryResult = [SELECT Name,
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
        }else{
            queryResult = [SELECT Name,
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
                            WHERE Name IN :names AND wrts_prcgvr__ObjectType__c =:objectType
                            WITH SECURITY_ENFORCED];
        }
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
        system.debug(LoggingLevel.DEBUG, 'createAttivitaTracciaturaHeroku start' + sourceData);
        List<wrts_prcgvr__Activity__c> toInsert = new List<wrts_prcgvr__Activity__c>();
        for(Map<String,String> curData : sourceData){
            if('Richiesta non identificata'.equalsIgnoreCase(curData.get('ATTIVITA'))){
                system.debug(LoggingLevel.DEBUG, 'anonima' + JSON.serializePretty(curData));
                wrts_prcgvr__Activity__c newAct = new wrts_prcgvr__Activity__c();
                for(String curActField : ANONIMAMAPPING.keySet()){
                    if('StartDate__c'.equalsIgnoreCase(curActField)){
                        newAct.put(curActField, Date.valueOf(curData.get(ANONIMAMAPPING.get(curActField))));
                    }else{
                        newAct.put(curActField, curData.get(ANONIMAMAPPING.get(curActField)));
                    }
                }
                newAct.wrts_prcgvr__Status__c = 'Chiusa';
                toInsert.add(newAct);
            }
        }
        system.debug(LoggingLevel.DEBUG, 'createAttivitaTracciaturaHeroku end' + toInsert);
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
        return createActivityByObjectIdAndTemplateName(objectId,templateName,getObjectName(objectId));
    }
    public static wrts_prcgvr__Activity__c createActivityByObjectIdAndTemplateName(String objectId, String templateName, String objectType){
        system.debug(LoggingLevel.DEBUG, 'HDT_UTL_Scarti objectId ' + objectId);
        system.debug(LoggingLevel.DEBUG, 'HDT_UTL_Scarti templateName ' + templateName);
        try{
            Map<String, wrts_prcgvr__ActivityTemplate__c> template;
            if (String.isEmpty(objectType)){ 
                template = getTemplatesMapByName(new Set<String>{templateName});
            }else{
                template = getTemplatesMapByName(new Set<String>{templateName},objectType);
            }
            system.debug(LoggingLevel.DEBUG, 'HDT_UTL_Scarti template ' + template);
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
                system.debug(LoggingLevel.DEBUG, 'HDT_UTL_Scarti end ' + activities.get(0));
                return activities.get(0);
            }
            system.debug(LoggingLevel.DEBUG, 'HDT_UTL_Scarti end');
            return null;
        }
        catch(Exception e){
            system.debug(LoggingLevel.DEBUG, 'HDT_UTL_Scarti catch ' + e);
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
        system.debug(LoggingLevel.DEBUG, 'HDT_UTL_Scarti objectIds ' + objectIds);
        system.debug(LoggingLevel.DEBUG, 'HDT_UTL_Scarti templateName ' + templateName);
        try{
            Map<String, wrts_prcgvr__ActivityTemplate__c> template = getTemplatesMapByName(new Set<String>{templateName});
            system.debug(LoggingLevel.DEBUG, 'HDT_UTL_Scarti template ' + template);
            if(template.values().size() > 0){
                wrts_prcgvr.Interfaces_1_1.IActivityIntegration activityIntegration = (wrts_prcgvr.Interfaces_1_1.IActivityIntegration) wrts_prcgvr.VersionManager.newClassInstance('ActivityIntegration');
                List<wrts_prcgvr__Activity__c> resultActivities = new List<wrts_prcgvr__Activity__c>();
                for(String singleObjectId: objectIds){
                    List<wrts_prcgvr__Activity__c> activities = (List<wrts_prcgvr__Activity__c>) activityIntegration.createFromTemplate(template.values().get(0).wrts_prcgvr__Code__c, new Map<String,Object>{'objectId'=>singleObjectId});
                    system.debug(LoggingLevel.DEBUG, 'HDT_UTL_Scarti single activity ' + activities.get(0));
                    resultActivities.add(activities.get(0));
                }
                system.debug(LoggingLevel.DEBUG, 'HDT_UTL_Scarti end ' + resultActivities);
                return resultActivities;
            }
            system.debug(LoggingLevel.DEBUG, 'HDT_UTL_Scarti end');
            return null;
        }
        catch(Exception e){
            system.debug(LoggingLevel.DEBUG, 'HDT_UTL_Scarti catch ' + e);
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
        system.debug(LoggingLevel.DEBUG, 'checkActivityCreation start recordId: ' + recordId + '; templateName: ' + templateName);
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
        return checkDiscardAnnullmentRule(recordId, activityType,'');
    }

    public static boolean checkDiscardAnnullmentRule(Id recordId, String activityType,String discardMessage){
        system.debug(LoggingLevel.DEBUG, 'checkDiscardAnnullmentRule start recordId: ' + recordId + '; activityType: ' + activityType);
        Boolean outcome = false;
        

        //Gestione Scarti SAP tolti i campi parent Object process field e controlling field
        List<DiscardAnnullmentRule__c> rules = [SELECT ControllingValue__c, ProcessValue__c, DiscardNoteReliability__c, ControllingCommodity__c
                                                FROM DiscardAnnullmentRule__c
                                                WHERE ActivityType__c = :activityType
                                                AND IsActive__c = true
                                                WITH SECURITY_ENFORCED];
		
        system.debug(LoggingLevel.DEBUG, 'checkDiscardAnnullmentRule rules: ' + JSON.serializePretty(rules));
        if(!rules.isEmpty()){
            String processField = '';
            String ctrField = '';
            String commodity = '';
            if(Schema.Case.SObjectType == recordId.getSobjectType()){
                //Gestione Scarti SAP il processField per il case è sempre il type ed il controlField è sempre il DiscardDescription
                List<Case> parentCase = [SELECT Id,Type,DiscardDescription__c, ServicePoint__r.CommoditySector__c FROM Case WHERE Id =:recordId WITH SECURITY_ENFORCED];
                if(!parentCase.isEmpty()){
                    processField = parentCase.get(0).Type;
                    ctrField = String.isNotBlank(discardMessage) ? discardMessage : parentCase.get(0).DiscardDescription__c;
                    commodity = (parentCase.get(0).ServicePoint__r == null) ? '' : parentCase.get(0).ServicePoint__r.CommoditySector__c;
                }
            }
            if(Schema.Order.SObjectType == recordId.getSobjectType()){
                //Gestione Scarti SAP il processField per l'order è sempre il type ed il controlField è sempre il DiscardReason
                List<Order> parentOrder = [SELECT Id,ProcessType__c,DiscardReason__c,Subprocess__c, ServicePoint__r.CommoditySector__c FROM Order WHERE Id =:recordId WITH SECURITY_ENFORCED];
                if(!parentOrder.isEmpty()){
                    Order ord = parentOrder.get(0);
                    processField = ('Voltura'.equalsIgnoreCase(ord.ProcessType__c) && 'Con Autolettura'.equalsIgnoreCase(ord.Subprocess__c)) ? 'Voltura con Autolettura' : ord.ProcessType__c;
                    ctrField = String.isNotBlank(discardMessage) ? discardMessage : ord.DiscardReason__c;
                    commodity = (ord.ServicePoint__r == null) ? '' : ord.ServicePoint__r.CommoditySector__c;
                }
            }
            if (String.isNotEmpty(processField) && String.isNotEmpty(ctrField)){
                for(DiscardAnnullmentRule__c curRule : rules){
                    if(curRule.ProcessValue__c.equalsIgnoreCase(processField) && (String.isBlank(curRule.ControllingCommodity__c) || curRule.ControllingCommodity__c.equalsIgnoreCase(commodity))){
                        switch on curRule.DiscardNoteReliability__c {
                            when 'Alta'{
                                if (ctrField.equalsIgnoreCase(curRule.ControllingValue__c)){
                                    outcome = true;
                                    break;
                                }
                            }
                            when 'Bassa' {
                                if (ctrField.containsIgnoreCase(curRule.ControllingValue__c)){
                                    outcome = true;
                                    break;
                                }
                            }
                        }
                    }
                }
            }
        }
        system.debug(LoggingLevel.DEBUG, 'checkDiscardAnnullmentRule outcome: ' + outcome);
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
        system.debug(LoggingLevel.DEBUG, 'updatePraticaForScartoDocumentale start newActivities: ' + JSON.serializePretty(newActivities));
        system.debug(LoggingLevel.DEBUG, 'updatePraticaForScartoDocumentale start oldActivities: ' + JSON.serializePretty(oldActivities));
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

        system.debug(LoggingLevel.DEBUG, 'updatePraticaForScartoDocumentale relatedCases: ' + JSON.serializePretty(relatedCases));
        system.debug(LoggingLevel.DEBUG, 'updatePraticaForScartoDocumentale relatedOrders: ' + JSON.serializePretty(relatedOrders));
        
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
        system.debug(LoggingLevel.DEBUG, 'updatePraticaForScartoDocumentale end relatedObjectsToUpdate: ' + JSON.serializePretty(relatedObjectsToUpdate));
        if(!relatedObjectsToUpdate.isEmpty()){
            HDT_UTL_DatabaseService.updateSObject(relatedObjectsToUpdate);
        }
        }
        catch(Exception e){
            system.debug(LoggingLevel.DEBUG, 'updatePraticaForScartoDocumentale errorMessage: ' + e.getMessage());
            system.debug(LoggingLevel.DEBUG, 'updatePraticaForScartoDocumentale errorStackTraceString: ' + e.getStackTraceString());
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
        system.debug(LoggingLevel.DEBUG, 'updateContactForScartoDocumentale start accountId: ' + accountId);
        system.debug(LoggingLevel.DEBUG, 'updateContactForScartoDocumentale start oldPhone: ' + oldPhone );
        system.debug(LoggingLevel.DEBUG, 'updateContactForScartoDocumentale start oldEmail: ' + oldEmail);
        system.debug(LoggingLevel.DEBUG, 'updateContactForScartoDocumentale start newPhone: ' + newPhone);
        system.debug(LoggingLevel.DEBUG, 'updateContactForScartoDocumentale start newMail: ' + newMail);
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
            system.debug(LoggingLevel.DEBUG, 'updateContactForScartoDocumentale end recordsForDML: ' + JSON.serializePretty(recordsForDML));
            if(!recordsForDML.isEmpty()){
                HDT_UTL_DatabaseService.upsertSObject(recordsForDML);
            }
        }
        }
        catch(Exception e){
            system.debug(LoggingLevel.DEBUG, 'updateContactForScartoDocumentale errorMessage: ' + e.getMessage());
            system.debug(LoggingLevel.DEBUG, 'updateContactForScartoDocumentale errorStackTraceString: ' + e.getStackTraceString());
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
        system.debug(LoggingLevel.DEBUG, 'setLookupFields start' + inputData);
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
        system.debug(LoggingLevel.DEBUG, 'setLookupFields codiciClienti' + codiciClienti);
        system.debug(LoggingLevel.DEBUG, 'setLookupFields activityTypes' + activityTypes);

        map<string,Id> mapActivityTemplates= new map<string,Id>();
        list<wrts_prcgvr__ActivityTemplate__c> activityTemplates=[SELECT Id, Name 
                                                                  FROM wrts_prcgvr__ActivityTemplate__c
                                                                  WHERE Name =: CANONERAITEMPLATENAME
                                                                  OR Name=: BONUSSOCIALETEMPLATENAME 
                                                                  WITH SECURITY_ENFORCED];
        for(wrts_prcgvr__ActivityTemplate__c singleTemplate: activityTemplates){
            mapActivityTemplates.put(singleTemplate.Name,singleTemplate.Id);
        }

        Map<String, Account> accIdsPerBPcode = new Map<String, Account>();
        if(!codiciClienti.isEmpty()){
            List<Account> listAccounts=[SELECT Id, CustomerCode__c, CompanyOwner__c
                                        FROM Account 
                                        WHERE CustomerCode__c IN: codiciClienti 
                                        WITH SECURITY_ENFORCED];
            for(Account singleAccount: listAccounts){
                accIdsPerBPcode.put(singleAccount.CustomerCode__c, singleAccount);
            }
        }
        for(wrts_prcgvr__Activity__c activity2: inputData){
            if(activity2.Account__c == null && !String.isBlank(activity2.BPCode__c) && accIdsPerBPcode.containsKey(activity2.BPCode__c)){
                activity2.Account__c = accIdsPerBPcode.get(activity2.BPCode__c).Id;
                activity2.CompanyOwner__c = accIdsPerBPcode.get(activity2.BPCode__c).CompanyOwner__c;
            }
            if(activity2.wrts_prcgvr__ActivityTemplate__c == null){
                if('CanoneRAI'.equalsIgnoreCase(activity2.Type__c)){
                    if(activity2.RecordTypeId != rtScarto.Id){
                        activity2.RecordTypeId = rtScarto.Id;
                    }
                    activity2.DiscardCategory__c = 'Gestionale';
                    if (String.isBlank(activity2.DiscardDescription__c)){
                        activity2.DiscardDescription__c = 'Canone RAI';
                    }
                    activity2.wrts_prcgvr__Status__c = 'Aperta';
                    activity2.wrts_prcgvr__ActivityTemplate__c=mapActivityTemplates.get(CANONERAITEMPLATENAME); 
                }else if('Bonussociale'.equalsIgnoreCase(activity2.Type__c)){
                    if(activity2.RecordTypeId != rtScarto.Id){
                        activity2.RecordTypeId = rtScarto.Id;
                    }
                    activity2.DiscardCategory__c = 'Gestionale';
                    if (String.isBlank(activity2.DiscardDescription__c)){
                        activity2.DiscardDescription__c = 'Bonus Sociale';
                    }
                    activity2.wrts_prcgvr__Status__c = 'Aperta';
                    activity2.wrts_prcgvr__ActivityTemplate__c=mapActivityTemplates.get(BONUSSOCIALETEMPLATENAME); 
                }
            }
            if(activity2.RecordTypeDevName__c == 'HDT_RT_Scarto' && activity2.RecordTypeId != rtScarto.Id){
                activity2.RecordTypeId = rtScarto.Id;
            }
        }
        system.debug(LoggingLevel.DEBUG, 'setLookupFields end' + inputData);
    
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
                if(handlesItem.getSObjectType() == schema.et4ae5__IndividualEmailResult__c.getSObjectType()){
                    currActivities[0].Individual_Email_Result__c = (Id)handlesItem.get('Id');
                    if(handlesItem.get('et4ae5__Contact__c') != null && String.isNotBlank((string)handlesItem.get('et4ae5__Contact__c')))
                        currActivities[0].Contact__c = (Id)handlesItem.get('et4ae5__Contact__c');
                    if(handlesItem.get('Account__c') != null && String.isNotBlank((string)handlesItem.get('Account__c')))
                        currActivities[0].Account__c = (Id)handlesItem.get('Account__c');
                }
                else if(handlesItem.getSObjectType() == schema.SMSTracking__c.getSObjectType()){
                    currActivities[0].SMS_Tracking__c = (Id)handlesItem.get('Id');
                    if(handlesItem.get('ContactID__c') != null && String.isNotBlank((string)handlesItem.get('ContactID__c')))
                        currActivities[0].Contact__c = (Id)handlesItem.get('ContactID__c');
                    if(handlesItem.get('Account__c') != null && String.isNotBlank((string)handlesItem.get('Account__c')))
                        currActivities[0].Account__c = (Id)handlesItem.get('Account__c');
                }

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
        checkForEsitiIntermedi(inputData, new Map<String, String>());
    }

    public static void checkForEsitiIntermedi(List<wrts_prcgvr__Activity__c> inputData,Map<String,String> activityValues){
        system.debug(LoggingLevel.DEBUG, 'checkForEsitiIntermedi start' + JSON.serializePretty(inputData));
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
        Set<String> activityTypeToCheck = new Set<String>{'ammissibilità ko','esito ko da dl','esito ko da sii'};
        Map<Id,Set<String>> activityToCheckMap = new Map<Id,Set<String>>();
        for(wrts_prcgvr__Activity__c currAct : inputData){
            if (currAct.Id != null && String.isNotBlank(currAct.Type__c) && activityTypeToCheck.contains(currAct.Type__c.toLowerCase()) && currAct.wrts_prcgvr__ObjectId__c != null){
                if (!activityToCheckMap.containsKey(currAct.wrts_prcgvr__ObjectId__c)){
                    activityToCheckMap.put(currAct.wrts_prcgvr__ObjectId__c, new Set<String>());
                }
                activityToCheckMap.get(currAct.wrts_prcgvr__ObjectId__c).add(currAct.Type__c.toLowerCase());
            }
            if(categories.contains(currAct.DiscardCategory__c) && !'Quality Scaduta'.equalsIgnoreCase(currAct.Type__c) && !HDT_UTL_ActivityCustom.ANNULLAMENTO_SIEBEL.equalsIgnoreCase(currAct.Type__c) && !HDT_UTL_ActivityCustom.CONTRATTO_NON_RICHIESTO.equalsIgnoreCase(currAct.Type__c)){
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

        if (parentObjectCase.isEmpty() && parentObjectOrder.isEmpty()){
            return;
        }
        
        system.debug(LoggingLevel.DEBUG, 'checkForEsitiIntermedi parentObjectCase' + JSON.serializePretty(parentObjectCase));
        system.debug(LoggingLevel.DEBUG, 'checkForEsitiIntermedi parentObjectOrder' + JSON.serializePretty(parentObjectOrder));
        system.debug(LoggingLevel.DEBUG, 'checkForEsitiIntermedi categories' + JSON.serializePretty(categories));
        system.debug(LoggingLevel.DEBUG, 'checkForEsitiIntermedi inputDataIds' + JSON.serializePretty(inputDataIds));

        //Le activity Ammissibilità KO, Esito KO da DL, Esito KO da SII devono essere chiuse se arriva un altra dello stesso tipo.
        list<wrts_prcgvr__Activity__c> relatedActs = [SELECT id, wrts_prcgvr__Status__c,Type__c ,Order__c, Case__c
                                                      FROM wrts_prcgvr__Activity__c 
                                                      WHERE (Case__c IN :parentObjectCase OR Order__c IN :parentObjectOrder) 
                                                      AND DiscardCategory__c IN :categories 
                                                      AND Id NOT IN :inputDataIds
                                                      AND wrts_prcgvr__IsClosed__c = false
                                                      AND (wrts_prcgvr__Status__c NOT IN ('Chiusa','Sospesa')
                                                      OR Type__c IN ('Ammissibilità KO','Esito KO da DL','Esito KO da SII'))
                                                      WITH SECURITY_ENFORCED];

        system.debug(LoggingLevel.DEBUG, 'checkForEsitiIntermedi relatedActs' + JSON.serializePretty(relatedActs));

        String endDate = activityValues.containsKey('DATA_ELABORAZIONE')? activityValues.get('DATA_ELABORAZIONE') :
                        activityValues.containsKey('DATA_EVENTO')? activityValues.get('DATA_EVENTO') : '';
        String cmp = activityValues.get('CMP');
        String utenza = activityValues.get('UTENZA');
        Date endDateVal = null;
        if(String.isNotBlank(endDate)){
            endDateVal = date.valueOf(endDate);
        }
        Datetime endDatetimeVal = null;
        if(String.isNotBlank(endDate)){
            endDatetimeVal = Datetime.valueOf(endDate);
        }
        for(wrts_prcgvr__Activity__c relatedAct: relatedActs){
            if (String.isNotBlank(relatedAct.Type__c) && activityTypeToCheck.contains(relatedAct.Type__c.toLowerCase()) 
            &&((relatedAct.Case__c != null && (!activityToCheckMap.containsKey(relatedAct.Case__c) || (activityToCheckMap.get(relatedAct.Case__c) != null && !activityToCheckMap.get(relatedAct.Case__c).contains(relatedAct.Type__c.toLowerCase()))))
            || (relatedAct.Order__c != null && (!activityToCheckMap.containsKey(relatedAct.Order__c) || (activityToCheckMap.get(relatedAct.Order__c) != null && !activityToCheckMap.get(relatedAct.Order__c).contains(relatedAct.Type__c.toLowerCase())))))){
                    continue;
            }
            system.debug(LoggingLevel.DEBUG, relatedAct);
            relatedAct.wrts_prcgvr__Status__c='Chiusa';
            relatedAct.EndDate__c = endDateVal;
            relatedAct.ActivityEndTime__c = endDatetimeVal;
            relatedAct.UserCompany__c = String.isNotBlank(cmp) ? cmp : null;
            relatedAct.ClosedByUsername__c = String.isNotBlank(utenza) ? utenza : null;
            toUpdate.add(relatedAct);
        }

        
        if(!toUpdate.IsEmpty()){
            system.debug(LoggingLevel.DEBUG, 'checkForEsitiIntermedi toUpdate' + JSON.serializePretty(inputData));
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
        system.debug(LoggingLevel.DEBUG, 'handleEditButtonPress start');
        RecordType rtScarto = new HDT_QR_RecordType().getRecordType('HDT_RT_Scarto', 'wrts_prcgvr__Activity__c');
        for(wrts_prcgvr__Activity__c curAct : newActs){
            if('Chiusa'.equalsIgnoreCase(curAct.wrts_prcgvr__Status__c)
               && curAct.wrts_prcgvr__Status__c != oldActsMap.get(curAct.Id).wrts_prcgvr__Status__c
               && rtScarto.Id == curAct.RecordTypeId){
        		system.debug(LoggingLevel.DEBUG, 'handleEditButtonPress found ' + curAct.Id);
                if('Scarto Complesso'.equalsIgnoreCase(curAct.DiscardCategory__c)
                   || 'Contattare il cliente'.equalsIgnoreCase(curAct.Type__c)){
                	curAct.wrts_prcgvr__Status__c = 'Aperta';
                }
                else {curAct.wrts_prcgvr__Status__c = 'Chiusa';
            	curAct.DiscardWorked__c = true;
                }
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
        String objectName = '';
        if(Schema.Case.SObjectType == objectId.getSobjectType()){
            objectName = 'Case';
        }else if(Schema.Order.SObjectType == objectId.getSobjectType()){
            objectName = 'Order';
        }
        annulmentProcess(objectId, objectName);
    }

    /**
    * @author Marco Arci (marco.arci@webresults.it)
    * @date 27/08/2021
    * @description HDT_UTL_Scarti.chiudiAttvita - chiusura attività figlie
    * @param objectId - objectId
    */
    public static void chiudiAttivita(Id objectId){
        List<wrts_prcgvr__Activity__c> toUpdateActivities = new list<wrts_prcgvr__Activity__c>();
        toUpdateActivities = [SELECT id, wrts_prcgvr__Status__c
                                FROM wrts_prcgvr__Activity__c
                                WHERE (Case__c= :objectId OR Order__c= :objectId)  
                                AND (wrts_prcgvr__Status__c != 'Chiusa' AND wrts_prcgvr__Status__c != 'Completed' 
                                    AND wrts_prcgvr__Status__c != 'Annullata' AND wrts_prcgvr__Status__c != 'Comunicazione inviata')
                                WITH SECURITY_ENFORCED]; 
        List<User> u = [SELECT ID, UserCompany__c, Username FROM User WHERE ID =: Userinfo.getUserId()];
        for(wrts_prcgvr__Activity__c singleActivity : toUpdateActivities){
            singleActivity.wrts_prcgvr__Status__c='Chiusa';
            singleActivity.EndDate__c = Date.today();
            singleActivity.UserCompany__c = u[0].UserCompany__c;
            singleActivity.ClosedByUsername__c=u[0].Username;
        }
        if(!toUpdateActivities.isEmpty()){
            HDT_UTL_DatabaseService.updateSObject(toUpdateActivities); 
        }   
        
    }

    //EVERIS: Gestione Scarti SAP
    public static Boolean updateCloseDiscardActivity(Id activityId){
        wrts_prcgvr__Activity__c activityToUpdate = closeDiscardActivity(activityId);
        return HDT_UTL_DatabaseService.updateSObject(activityToUpdate);
    }

    public static wrts_prcgvr__Activity__c closeDiscardActivity(Id activityId){
        List<User> u = [SELECT ID, UserCompany__c, Username, CreatorGroup__c,LoginChannel__c, Station__c FROM User WHERE ID =: Userinfo.getUserId()];
        return new wrts_prcgvr__Activity__c(Id =  activityId, 
                                            wrts_prcgvr__Status__c ='Chiusa', 
                                            EndDate__c = Date.today(), 
                                            UserCompany__c = u[0].UserCompany__c, 
                                            ClosedByUsername__c=u[0].Username,
                                            ClosingCreatorGroup__c = u[0].CreatorGroup__c,
                                            ClosingUserChannel__c = u[0].LoginChannel__c,
                                            //@ealpi valorizzato in apertura activity --> Place__c = u[0].Station__c,
                                            ActivityEndTime__c = DateTime.now());
    }

    public static Boolean manageSapDiscard(List<SObject> newObjectList, Map<Id,SObject> oldObjectMap){
        SObject newObject = newObjectList[0];
        SObject oldObject = oldObjectMap.get((Id)newObject.get('Id'));
        String newPhase = newObject.get('Phase__c') != null ? (String)newObject.get('Phase__c') : '';
        String oldPhase = oldObject.get('Phase__c') != null ?  (String)oldObject.get('Phase__c') : '';
        String previousPhase = newObject.get('PreviousPhase__c') != null ? (String)newObject.get('PreviousPhase__c') : '';
        Boolean response = false;
        if (String.isNotBlank(newPhase) && String.isNotBlank(oldPhase) && !newPhase.equalsIgnoreCase(oldPhase)){
            DateTime nowDateTime = DateTime.now();
            String phaseStoryOld = oldObject.get('PhaseStory__c') != null ? (String)oldObject.get('PhaseStory__c') : '';
            String phaseStrory = oldPhase+'@@'+newPhase+'@@'+nowDateTime.getTime()+'@@A||'+phaseStoryOld;
            newObject.put('PhaseStory__c',phaseStrory);
            response = HDT_UTL_GestioneScartiSap.skipPhaseManager(newPhase);
        }
        if (response && String.isNotBlank(oldPhase) && String.isBlank(previousPhase) && oldPhase.indexOf('KO') > -1){
            newObject.put('PreviousPhase__c',oldPhase);
        } else if ('Completata'.equalsIgnoreCase(newPhase) && String.isNotBlank(previousPhase) && previousPhase.indexOf('KO') > -1 && HDT_UTL_GestioneScartiSap.skipPhaseManager(oldPhase)){
            newObject.put('PreviousPhase__c', '');
            newObject.put('Phase__c', previousPhase);
            response = true;
        }
        return response;
    }

    public static void handleHerokuResponse(Id objectId, String activityName, String fase, Map<String,String> mapActivityField){
        if ((String.isNotBlank(fase) || String.isNotBlank(activityName)) && objectId != null){
            Map<String,String> mapFieldValue = new Map<String,String>();
            if (String.isNotBlank(activityName)){
                mapFieldValue.put('Activity__c',activityName); 
            }
            if (String.isNotBlank(fase)){
                mapFieldValue.put('Phase__c',fase);
            }
            List<HDT_GestioneScartiSap__mdt> rules = HDT_UTL_GestioneScartiSap.getRuleFromActivity(mapFieldValue);
            
            if (!rules.isEmpty()){
                System.enqueueJob(new HDT_QBL_GestioneScartiSap(objectId,rules,mapActivityField));
            }
        }
    }

    public static String getObjectName(String objectId){
        String objectName;
        if(Schema.Case.SObjectType == ((Id)objectId).getSobjectType()){ 
            objectName = 'Case';
        }else if(Schema.Order.SObjectType == ((Id)objectId).getSobjectType()){
            objectName = 'Order';
        }else if(Schema.Account.SObjectType == ((Id)objectId).getSobjectType()){
            objectName = 'Account';
        }
        return objectName;
    }

    public static void discardManagement(Map<String,String> requestDiscardManagemnt){
        if (String.isNotBlank(requestDiscardManagemnt.get('FASE')) && String.isNotBlank(requestDiscardManagemnt.get('RECORD_ID')) && String.isNotBlank(requestDiscardManagemnt.get('OBJECT_TYPE'))){
            Id recordId = (Id)requestDiscardManagemnt.get('RECORD_ID');
            String fase = requestDiscardManagemnt.get('FASE');
            String objectType = requestDiscardManagemnt.get('OBJECT_TYPE');
            String templateName = '';
            for (HDT_GestioneScarti__mdt conf : [SELECT OrderTemplate__c, CaseTemplate__c FROM HDT_GestioneScarti__mdt WHERE IsActive__c = true AND Phase__c =:fase WITH SECURITY_ENFORCED]){
                templateName = 'Case'.equalsIgnoreCase(requestDiscardManagemnt.get('OBJECT_TYPE')) ? conf.CaseTemplate__c : conf.OrderTemplate__c;
                break; //Se per sbaglio vengono configurate più configurazioni prende la prima che trova
            }
            System.debug(LoggingLevel.DEBUG, 'HDT_UTL_Scarti -> Discard Message: ' +  requestDiscardManagemnt.get('DISCARD_MESSAGE'));
            System.debug(LoggingLevel.DEBUG, 'HDT_UTL_Scarti -> templateName: ' +  templateName);
            Boolean discardActivity = checkDiscardAnnullmentRule(recordId, fase,requestDiscardManagemnt.get('DISCARD_MESSAGE'));
            System.debug(LoggingLevel.DEBUG, 'HDT_UTL_Scarti -> checkDiscardAnnullmentRule: ' + discardActivity); 
            if (String.isNotEmpty(templateName) && !discardActivity){
                wrts_prcgvr__Activity__c act = createActivityByObjectIdAndTemplateName(recordId, templateName,objectType);
                String errore = String.isNotBlank(requestDiscardManagemnt.get('DISCARD_MESSAGE')) && requestDiscardManagemnt.get('DISCARD_MESSAGE').length()>255 ? requestDiscardManagemnt.get('DISCARD_MESSAGE').substring(0,255) : requestDiscardManagemnt.get('DISCARD_MESSAGE');
                act.DiscardDescription__c = errore;
                act.wrts_prcgvr__Description__c  = errore;
                System.debug(LoggingLevel.DEBUG, 'HDT_UTL_Scarti -> act: ' +  act);
                HDT_UTL_DatabaseService.insertSObject(act);
            }else if (String.isNotEmpty(templateName)){
                annulmentProcess(recordId, objectType);
            }
        }
    }

    public static void discardManagement(List<HDT_WRP_MrrRequest.HDT_WRP_Request> inboundRequests){
        Map<String,String> requestDiscardManagemnt = createRequestMap(inboundRequests);
        discardManagement(requestDiscardManagemnt);
    }

    private static Map<String,String> createRequestMap(List<HDT_WRP_MrrRequest.HDT_WRP_Request> inboundRequests){
        Map<String,String> requestMap = new Map<String,String>();
        String discardError = '';
        for (HDT_WRP_MrrRequest.HDT_WRP_Request request : inboundRequests) {
            HDT_WRP_MrrResponse.HDT_WRP_Response parsedResponseItem = (HDT_WRP_MrrResponse.HDT_WRP_Response) JSON.deserialize(JSON.serialize(request), HDT_WRP_MrrResponse.HDT_WRP_Response.class);
            for(HDT_WRP_MrrResponse.HDT_WRP_Object curObj : parsedResponseItem.objects){
                for(HDT_WRP_MrrResponse.HDT_WRP_Field curField : curObj.fields){
                    if (String.isBlank(curField.value)){
                        continue;
                    }
                    if ('FASE'.equalsIgnoreCase(curField.name)){
                        requestMap.put('FASE',curField.value);
                    }else if('RECORD_ID'.equalsIgnoreCase(curField.name)){
                        requestMap.putAll(getRecordId(curField.value));
                    }
                    //
                    if(('NOTE_ERR'.equalsIgnoreCase(curField.name) 
                    || 'DES_ERR_AEEG'.equalsIgnoreCase(curField.name)
                    || 'TESTO_ERRR'.equalsIgnoreCase(curField.name)
                    || 'ANNOTAZIONI'.equalsIgnoreCase(curField.name)
                    || 'NOTE_ANN'.equalsIgnoreCase(curField.name)
                    || 'ANNOTAZIONI_ANN'.equalsIgnoreCase(curField.name))
                    && String.isNotBlank(curField.value)){
                        discardError += HDT_UTL_Accents.removeDiacritics(curField.value) + '\n';
                    }
                }
            }
        }
        requestMap.put('DISCARD_MESSAGE',discardError);
        return requestMap;
    }

    private static Map<String,String> getRecordId(String recordIdToWork){
        Map<String,String> requestMap = new Map<String,String>();
        String objectType = '';
        if(recordIdToWork instanceOf Id){
            if(Schema.Case.SObjectType == Id.valueOf(recordIdToWork).getSobjectType()){
                objectType = 'Case';
            }else if(Schema.Order.SObjectType == Id.valueOf(recordIdToWork).getSobjectType()){
                objectType = 'Order';
            }
        }
        else if(recordIdToWork.startsWith('O-') ){
            List<Order> orderList = HDT_QR_GenericQuery.getGenericRecords('Id', 'Order', 'OrderNumber = \''+String.escapeSingleQuotes(recordIdToWork)+'\'');
            if(!orderList.isEmpty()){
                objectType = 'Order';
                recordIdToWork = orderList[0].Id;
            }
        }
        if (String.isNotEmpty(objectType)){
            requestMap.put('RECORD_ID', recordIdToWork);
            requestMap.put('OBJECT_TYPE',objectType);
        }
        return requestMap;
    }

    private static void annulmentProcess(Id recordId,String objectType){
        if (String.isNotEmpty(objectType)){
            SObject objectToUpdate = Schema.getGlobalDescribe().get(objectType).newSObject();
            String status = 'Case'.equalsIgnoreCase(objectType)? 'Closed' : 'Annullato';
            objectToUpdate.put('Id',recordId);
            objectToUpdate.put('CancellationReason__c','Gestione scarto');
            objectToUpdate.put('Phase__c','Annullato');
            objectToUpdate.put('Status',status);
            HDT_UTL_DatabaseService.updateSObject(objectToUpdate);
        }
    }
    //EVERIS: END Gestione Scarti SAP


    //EVERIS Gestione Scarto Transitorio
    public static void createActivityForKoSiebel(Map<Id,String> objectRelated){
        List<wrts_prcgvr__ActivityTemplate__c> template = HDT_QR_GenericQuery.getGenericRecords('Id, Name', 'wrts_prcgvr__ActivityTemplate__c', 'Name = \'ORDER_CARICAMENTO_SIEBEL_KO\' AND wrts_prcgvr__ObjectType__c =\'Order\'');
        Id recorcTypeId = new HDT_QR_RecordType().getRecordTypeIdByName('HDT_RT_Scarto', 'wrts_prcgvr__Activity__c');
        Id templateId;
        if (!template.isEmpty()){
            templateId = template[0].Id;
        }
        List<wrts_prcgvr__Activity__c> activitiesToCreate = new List<wrts_prcgvr__Activity__c>();
        for (Id orderId : objectRelated.keySet()){
            wrts_prcgvr__Activity__c newAct = new wrts_prcgvr__Activity__c();
            newAct.Type__c = 'Scarto Transitorio';
            newAct.RecordTypeId = recorcTypeId;
            newAct.DiscardCategory__c = 'Scarto complesso';
            newAct.DiscardDescription__c = 'Scarto Transitorio';
            newAct.wrts_prcgvr__Status__c = 'Aperta';
            newAct.wrts_prcgvr__ActivityTemplate__c = templateId;
            newAct.wrts_prcgvr__ObjectId__c = orderId;
            newAct.Order__c = orderId;
            newAct.wrts_prcgvr__Description__c = objectRelated.get(orderId);
            activitiesToCreate.add(newAct);
        }
        HDT_UTL_DatabaseService.insertSObject(activitiesToCreate);
    }
    //EVERIS fine Gestione Scarto Transitorio

    public static void closeDocumentalManagementActivity(String formParams){
        Map<String,Object> formParamsMap = formParams != null? (Map<String,Object>) JSON.deserializeUntyped(formParams) : new Map<String,Object>();
        if (formParamsMap.containsKey('discardRework') && (Boolean)formParamsMap.get('discardRework')){
            List<wrts_prcgvr__Activity__c> actsToClose = HDT_QR_GenericQuery.getGenericRecords('Id','wrts_prcgvr__Activity__c','wrts_prcgvr__IsClosed__c = false AND Type__c = \'Busta Docusign non consegnata\' AND Id =\''+(String)formParamsMap.get('discardActivityId')+'\'');
            List<wrts_prcgvr__Activity__c> actsToUpdate = new List<wrts_prcgvr__Activity__c>();
            for (wrts_prcgvr__Activity__c act : actsToClose){
                actsToUpdate.add(closeDiscardActivity(act.Id));
            }
            if (!actsToUpdate.isEmpty()){
                HDT_UTL_DatabaseService.updateSObject(actsToUpdate);
            }
        }
    }

    public static void closeActivityOnCompleted(List<SObject> newObjectList, Map<Id,SObject> oldObjectMap){
        Set<Id> objectIdSet = new Set<Id>();
        for (SObject newObj : newObjectList){
            Id recordId = (Id)newObj.get('Id');
            String newPhase = (String) newObj.get('Phase__c');
            String oldPhase = (String) oldObjectMap.get(recordId).get('Phase__c');
            if ('Completata'.equalsIgnoreCase(newPhase) && !newPhase.equalsIgnoreCase(oldPhase)){
                objectIdSet.add(recordId);
            }
        }
        closeActivityOnCompletedFromNotify(objectIdSet);
    }

    public static void closeActivityOnCompletedFromNotify(Set<Id> objectIdSet){
        if (!objectIdSet.isEmpty()){
            List<wrts_prcgvr__Activity__c> activitiesToUpdate = new List<wrts_prcgvr__Activity__c>();
            String listId = '(\''+String.join((Iterable<String>) objectIdSet, '\',\'') +'\')';
            List<wrts_prcgvr__Activity__c> activities = HDT_QR_GenericQuery.getGenericRecords('Id','wrts_prcgvr__Activity__c', '(Order__c IN ' + listId + ' OR Case__c IN' + listId + ') AND wrts_prcgvr__IsClosed__c = false AND DiscardCategory__c = \'Tracciatura\'');
            for (wrts_prcgvr__Activity__c act : activities){
                activitiesToUpdate.add(closeDiscardActivity(act.Id));
            }
            if (!activitiesToUpdate.isEmpty()){
                HDT_UTL_DatabaseService.updateSObject(activitiesToUpdate);
            }
        }
    }

    public static void createActivity(Id caseId, String activityType, String errorMessage) {
        if ('Esito KO da SAP'.equalsIgnoreCase(activityType) || 'Esito KO pre-MDM'.equalsIgnoreCase(activityType)){
            String objectName = 'wrts_prcgvr__ActivityTemplate__c';
            String templateName = activityType.equalsIgnoreCase('Esito KO pre-MDM') ? 'CBS_AUT004__ESITO_KO_PRE-MDM' : 'CBS_AUT002__ESITO_KO_DA_SAP';
            String queryStringTemplate = 'Select Id from wrts_prcgvr__ActivityTemplate__c  where Name = \''+templateName+'\'';
            Id actRecordTypeId = Schema.SObjectType.wrts_prcgvr__Activity__c.getRecordTypeInfosByDeveloperName().get('HDT_RT_Scarto').getRecordTypeId();
            wrts_prcgvr__ActivityTemplate__c templateActivity = (wrts_prcgvr__ActivityTemplate__c)(HDT_QR_GenericQuery.getGenericRecords(queryStringTemplate, objectName).get(0));
            wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c();
            activity.wrts_prcgvr__ActivityTemplate__c = templateActivity.Id;
            activity.Case__c = caseId;
            activity.Type__c = activityType;
            activity.DiscardCategory__c = 'Scarto complesso';
            activity.RecordTypeId=actRecordTypeId;
            activity.wrts_prcgvr__Description__c = errorMessage;
            HDT_UTL_DatabaseService.insertSObject(activity);
        }
        
    }

    public static void changeSapPhaseHandler(Map<Id,SObject> newRecsMap, Map<Id,SObject> oldRecsMap){
        Set<Id> secondCheck = new Set<Id>();
        for (Sobject obj : newRecsMap.values()){
            SObject oldObj = oldRecsMap.get((Id)obj.get('Id'));
            String newPhase = obj.get('Phase__c') == null ? '' : (String)obj.get('Phase__c');
            String oldPhase = oldObj.get('Phase__c') == null ? '' : (String)oldObj.get('Phase__c');
            if(!newPhase.equalsIgnoreCase(oldPhase) && HDT_UTL_GestioneScartiSap.skipPhaseManager(oldPhase) && !HDT_UTL_GestioneScartiSap.skipPhaseManager(newPhase)){
                if ('Completata'.equalsIgnoreCase(newPhase)){
                    String phase = HDT_UTL_Utils.beforeSapPhase(oldPhase,oldObj.get('PhaseStory__c') == null ? '' : (String)oldObj.get('PhaseStory__c'));
                    if (String.isBlank(phase)){
                        secondCheck.add((Id)obj.get('Id'));
                        continue;
                    }
                    if (phase.containsIgnoreCase('KO')){
                        obj.put('Phase__c',phase);
                        continue;
                    }
                }
                //In attesa della risposta di s.b. su mail "Richiesta riscontro Autoletture e Scarti SAP"
                if (newPhase.indexOf('Annullamento') > -1 || newPhase.indexOf('Ripensamento') > -1 || 'Annullato'.equalsIgnoreCase(newPhase)){
                    obj.addError('Per procedere con l\'annullamento, è necessario gestire lo scarto SAP');
                }
            }
        }
        if (secondCheck.isEmpty()){
            return;
        }
        String stringIds = '(\''+String.join(secondCheck, '\',\'')+'\')'; 
        for (wrts_prcgvr__Activity__c act : HDT_QR_GenericQuery.getGenericRecords('Id, Type__c, Order__c, Case__c', 'wrts_prcgvr__Activity__c', 'Case__c IN '+stringIds+' OR Order__c IN '+stringIds)){ // inserire la query invece di acts
            Sobject obj = newRecsMap.get(act.Order__c != null ? act.Order__c : act.Case__c);
            String pStory = obj.get('PhaseStory__c') == null ? '' : (String)obj.get('PhaseStory__c');
            String prefix = pStory.startsWithIgnoreCase('Annullamento -') ? 'Annullamento - ' :
            pStory.startsWith('Ripensamento -') ? 'Ripensamento - ' : ''; 
            obj.put('Phase__c',prefix + act.Type__c);
        }
    }
}