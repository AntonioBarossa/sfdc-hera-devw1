/**
 * @author Marco Arci (marco.arci@webresults.it)
 * @date 22/07/2021
 * @description HDT_UTL_Scarti - Utility scarti
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */
global with sharing class HDT_UTL_Scarti implements wrts_prcgvr.Interfaces_1_0.IApexAction{
    static final string CANONERAITEMPLATENAME='CBS_CAR002__CANONE_RAI';
    static final string BONUSSOCIALETEMPLATENAME='CBS_FAT011__BONUS_SOCIALE';
    static final string SCARTODOCUMENTALEPOSTSALESTEMPLATENAME='CBS_CRP004__SCARTI_DOCUMENTALI_POST_SALES';
    static final string SCARTODOCUMENTALESALESTEMPLATENAME='CBS_CRP003__SCARTI_DOCUMENTALI_SALES';

    static final set<string> ESITIINTERMEDIHEROKU = new set<string>{'Ammissibilità KO','Esito Ko da Sap','Esito KO da DL',
                                                                    'Richiesta non identificata/anonima',
                                                                    'Esito non elaborato da DL/SII','Esito ricevuto su richiesta chiusa',
                                                                    'Eliminato esito in scarto','Errore invio a SAP','Errore determinazione variante SAP'};

    static final Map<String, String> TRACCIAMENTOHEROKUSALES = new Map<String, String>{ 'Esito ricevuto su richiesta chiusa' => 'CBS_HER007__ESITO_RICEVUTO_SU_RICHIESTA_CHIUSA_SALES',
                                                                                        'Esito non elaborato' => 'CBS_HER006__ESITO_NON_ELABORATO_DA_DLSII_SALES',
                                                                                        'Eliminato esito in scarto' => 'CBS_HER008__ELIMINATO_ESITO_IN_SCARTO_SALES',
                                                                                        'Errore invio a SAP' => 'CBS_HER009__ERRORE_INVIO_A_SAP_SALES',
                                                                                        'Errore determinazione variante SAP' => 'CBS_HER010__ERRORE_DETERMINAZIONE_VARIANTE_SAP_SALES'};

    static final Map<String, String> TRACCIAMENTOHEROKUPOSTSALES = new Map<String, String>{'Esito ricevuto su richiesta chiusa' => 'CBS_HER002__ESITO_RICEVUTO_SU_RICHIESTA_CHIUSA_POSTSALES',
                                                                                           'Esito non elaborato' => 'CBS_HER001__ESITO_NON_ELABORATO_DA_DLSII_POSTSALES',
                                                                                           'Eliminato esito in scarto' => 'CBS_HER003__ELIMINATO_ESITO_IN_SCARTO_POSTSALES',
                                                                                           'Errore invio a SAP' => 'CBS_HER004__ERRORE_INVIO_A_SAP_POSTSALES',
                                                                                           'Errore determinazione variante SAP' => 'CBS_HER005__ERRORE_DETERMINAZIONE_VARIANTE_SAP_POSTSALES'};

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
                                                                                   'DiscardDescription__c' => 'ERROR_MESSAGE'};
    global Object execute(Object args){
        Map<String, Object> argsMap = (Map<String, Object>) args;
        SObject transition = (SObject) argsMap.get('transition');
        SObject action = (SObject) argsMap.get('action');
        String method = (String) argsMap.get('method');
        SObject sender = (SObject) argsMap.get('sender');

        //c'è annullamento automatico a partire dal singolo scarto, per singolo processo, per singolo cluster
        //non si riescono a passare tutte queste info tramite method, servirebbero una marea di method
        //non sembra esserci un modo per passare i dati tramite "parametri" alla action
        //l'unica via, per ora, sembra quella di mettere il nome del template nel method. ES: 'checkActivityCreation(CBS_ATT006__AMMISSIBILITA_KO)'
        //di conseguenza lo switch è poco funzionale, perchè bisognerebbe scrivere n righe per quanti template vengono rigchiesti... è anche poco manutenibile
        //dinamicamente, con substring, si vede il prefisso (checkActivityCreation) e poi si estrae il nome del template dalle parentesi tonde
        
        if(method.startsWith('checkActivityCreation')){
            checkActivityCreation((Id)sender.get('Id'), method.substringAfter('___'));
        }

        return null;
    }

    /**
    * @author Costanzo Lo Mele (costanzo.lomele@webresults.it)
    * @date 22/07/2021
    * @description HDT_UTL_Scarti.getTemplatesMapByName - returns a map <templateName, templateObj>
    * @param1 recordId - Id of a record
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
                                                              WHERE Name IN :names];

        for(wrts_prcgvr__ActivityTemplate__c curTemplate : queryResult) returnMap.put(curTemplate.Name, curTemplate);
        return returnMap;
    }

    /**
    * @author Costanzo Lo Mele (costanzo.lomele@webresults.it)
    * @date 22/07/2021
    * @description HDT_UTL_Scarti.createAttivitaTracciaturaHeroku - Creates attività di tracciamento Heroku
    * @param1 recordId - Id of a record
    * @return void
    */
    public static void createAttivitaTracciaturaHeroku(List<Map<String,String>> sourceData){
        System.debug('createAttivitaTracciaturaHeroku start' + sourceData);
        List<wrts_prcgvr__Activity__c> toInsert = new List<wrts_prcgvr__Activity__c>();
        
        Set<String> tracciamentoTemplateNames = new Set<String>(TRACCIAMENTOHEROKUSALES.values());
        tracciamentoTemplateNames.addAll(TRACCIAMENTOHEROKUPOSTSALES.values());
        Map<String, wrts_prcgvr__ActivityTemplate__c> templatesMap = getTemplatesMapByName(tracciamentoTemplateNames);
        
        Map<String, List<Map<String,String>>> dataPerTemplateCode = new Map<String, List<Map<String,String>>>(); 

        Map<String, Map<String,String>> dataForSalesHandlingByTemplateCode = new Map<String, Map<String,String>>();

        wrts_prcgvr.Interfaces_1_1.IActivityIntegration activityIntegration = (wrts_prcgvr.Interfaces_1_1.IActivityIntegration) wrts_prcgvr.VersionManager.newClassInstance('ActivityIntegration');
        
        for(Map<String,String> curData : sourceData){
            if('Richiesta non identificata'.equalsIgnoreCase(curData.get('ATTIVITA'))){
                wrts_prcgvr__Activity__c newAct = new wrts_prcgvr__Activity__c();
                for(String curActField : ANONIMAMAPPING.keySet()){
                    if('StartDate__c'.equalsIgnoreCase(curActField)) newAct.put(curActField, Date.valueOf(curData.get(ANONIMAMAPPING.get(curActField))));
                    else newAct.put(curActField, curData.get(ANONIMAMAPPING.get(curActField)));
                }
                toInsert.add(newAct);
            }          
            else if(TRACCIAMENTOHEROKUSALES.keySet().contains(curData.get('ATTIVITA')) && !String.isBlank(curData.get('RECORD_ID'))){//va bene controllare solo su una mappa, tanto i keyset sono uguali
                if('sales'.equalsIgnoreCase(curData.get('PROCESS_CATEGORY'))) dataForSalesHandlingByTemplateCode.put(curData.get('RECORD_ID'), curData);
                else if('postsales'.equalsIgnoreCase(curData.get('PROCESS_CATEGORY'))){
                    String templateCode = templatesMap.get(TRACCIAMENTOHEROKUPOSTSALES.get(curData.get('ATTIVITA'))).wrts_prcgvr__Code__c;
                    List<wrts_prcgvr__Activity__c> activities = (List<wrts_prcgvr__Activity__c>) activityIntegration.createFromTemplate(templateCode, new Map<String,Object>{'objectId'=>curData.get('RECORD_ID')});
                    for(String curActField : ANONIMAMAPPING.keySet()){
                        if('StartDate__c'.equalsIgnoreCase(curActField)) activities[0].put(curActField, Date.valueOf(curData.get(ANONIMAMAPPING.get(curActField))));
                        else activities[0].put(curActField, curData.get(ANONIMAMAPPING.get(curActField)));
                    }
                    toInsert.addAll(activities);
                }
            }
        }
        
        System.debug('createAttivitaTracciaturaHeroku dataForSalesHandlingByTemplateCode' + dataForSalesHandlingByTemplateCode);
        if(!dataForSalesHandlingByTemplateCode.keySet().isEmpty()){
            Map<Id, Order> orders = new Map<Id, Order>([SELECT Id, OrderNumber FROM Order WHERE OrderNumber IN :dataForSalesHandlingByTemplateCode.keySet()]);
            for(Order curOrder : orders.values()){
                Map<String,String> curData = dataForSalesHandlingByTemplateCode.get(curOrder.OrderNumber);
                String templateCode = templatesMap.get(TRACCIAMENTOHEROKUSALES.get(curData.get('ATTIVITA'))).wrts_prcgvr__Code__c;
                List<wrts_prcgvr__Activity__c> activities = (List<wrts_prcgvr__Activity__c>) activityIntegration.createFromTemplate(templateCode, new Map<String,Object>{'objectId'=>curOrder.Id});
                for(String curActField : ANONIMAMAPPING.keySet()){
                    if('StartDate__c'.equalsIgnoreCase(curActField)) activities[0].put(curActField, Date.valueOf(curData.get(ANONIMAMAPPING.get(curActField))));
                    else activities[0].put(curActField, curData.get(ANONIMAMAPPING.get(curActField)));
                }
                toInsert.addAll(activities);
            }
        }
        
        System.debug('createAttivitaTracciaturaHeroku end' + toInsert);
        HDT_UTL_DatabaseService.insertSObject(toInsert);
    }

    public class HDT_UTL_FlowInputs{

        @InvocableVariable
        public String objectId;
        @InvocableVariable
        public String templateName;


    }
    
    public class HDT_UTL_FlowOutputs{

        @InvocableVariable
        public String esito;
        @InvocableVariable
        public String dettaglioEsito;

    }

    /**
    * @author Marco Arci (marco.arci@webresults.it)
    * @date 19/08/2021
    * @description HDT_UTL_Scarti.createActivityByObjectIdAndTemplateNameFlow
    * @param1 inputData - list<HDT_UTL_FlowInputs>
    * @return string 
    */
    @InvocableMethod(label='prova')
    public static list<HDT_UTL_FlowOutputs> createActivityByObjectIdAndTemplateNameFlow(list<HDT_UTL_FlowInputs> inputParam){
        list<HDT_UTL_FlowOutputs> listOutputs= new list<HDT_UTL_FlowOutputs>();
        HDT_UTL_FlowOutputs output= new HDT_UTL_FlowOutputs();
        try{
            wrts_prcgvr__Activity__c act= createActivityByObjectIdAndTemplateName(inputParam[0].objectId, inputParam[0].templateName);
            insert act;
            output.esito='OK';
            output.dettaglioEsito=act.Id;
        }catch(Exception e){
            output.esito='KO';
            output.dettaglioEsito= e.getMessage();
        }
        listOutputs.add(output);
        return listOutputs;
    }


    /**
    * @author Costanzo Lo Mele (costanzo.lomele@webresults.it)
    * @date 06/08/2021
    * @description HDT_UTL_Scarti.createActivityByObjectIdAndTemplateName 
    * @param1 objectId - Id of the parent record of the activity
    * @param1 templateName - name of an activityTemplate
    * @return void
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
    * @param1 list of objectId - list of Ids of the parent records of the activity
    * @param2 templateName - name of an activityTemplate
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
    * @param1 recordId - Id of a record
    * @return void
    */
    public static void checkActivityCreation(Id recordId, String templateName){        
        //TODO: check campi del case/order per vedere se va annullata la pratica o creata l'attività
        if(Schema.Case.SObjectType == recordId.getSobjectType()
            || Schema.Order.SObjectType == recordId.getSobjectType()){
            wrts_prcgvr__Activity__c newAct = createActivityByObjectIdAndTemplateName(recordId, templateName);
            if(newAct != null) HDT_UTL_DatabaseService.insertSObject(newAct);
        }
    }

    /**
    * @author Marco Arci (marco.arci@webresults.it)
    * @date 22/07/2021
    * @description HDT_UTL_Scarti.setLookupFields - populating lookup fields
    * @param1 inputData - list of wrts_prcgvr__Activity__c
    * @return List<wrts_prcgvr__Activity__c> 
    */
    public static List<wrts_prcgvr__Activity__c> setLookupFields(List<wrts_prcgvr__Activity__c> inputData){
        System.debug('setLookupFields start' + inputData);
        list<string> codiciClienti= new list<String>();
        set<string> activityTypes= new set<string>();

        RecordType rtScarto = new HDT_QR_RecordType().getRecordType('HDT_RT_Scarto', 'wrts_prcgvr__Activity__c');

        for(wrts_prcgvr__Activity__c activity: inputData){
            if(activity.Account__c == null && !String.isBlank(activity.BPCode__c)) codiciClienti.add(activity.BPCode__c);
            if(activity.wrts_prcgvr__ActivityTemplate__c == null && !String.isBlank(activity.Type__c)) activityTypes.add(activity.Type__c);
        }
        System.debug('setLookupFields codiciClienti' + codiciClienti);
        System.debug('setLookupFields activityTypes' + activityTypes);

        map<string,Id> mapActivityTemplates= new map<string,Id>();
        list<wrts_prcgvr__ActivityTemplate__c> activityTemplates=[SELECT Id, Name FROM wrts_prcgvr__ActivityTemplate__c WHERE Name =: CANONERAITEMPLATENAME OR Name=: BONUSSOCIALETEMPLATENAME];
        for(wrts_prcgvr__ActivityTemplate__c singleTemplate: activityTemplates){
            mapActivityTemplates.put(singleTemplate.Name,singleTemplate.Id);
        }


        List<Account> listAccounts=[SELECT Id, CustomerCode__c FROM Account WHERE CustomerCode__c IN: codiciClienti];
        Map<String, Id> accIdsPerBPcode = new Map<String, Id>();
        for(Account singleAccount: listAccounts) accIdsPerBPcode.put(singleAccount.CustomerCode__c, singleAccount.Id);
        for(wrts_prcgvr__Activity__c activity2: inputData){
            if(activity2.Account__c == null && !String.isBlank(activity2.BPCode__c)) activity2.Account__c = accIdsPerBPcode.get(activity2.BPCode__c);
            if(activity2.wrts_prcgvr__ActivityTemplate__c == null){
                if('CanoneRAI'.equalsIgnoreCase(activity2.Type__c)){
                    if(activity2.RecordTypeId != rtScarto.Id) activity2.RecordTypeId = rtScarto.Id;
                    activity2.wrts_prcgvr__ActivityTemplate__c=mapActivityTemplates.get(CANONERAITEMPLATENAME); 
                }else if('Bonussociale'.equalsIgnoreCase(activity2.Type__c)){
                    if(activity2.RecordTypeId != rtScarto.Id) activity2.RecordTypeId = rtScarto.Id;
                    activity2.wrts_prcgvr__ActivityTemplate__c=mapActivityTemplates.get(BONUSSOCIALETEMPLATENAME); 
                }
            }
            if(activity2.RecordTypeDevName__c == 'HDT_RT_Scarto' && activity2.RecordTypeId != rtScarto.Id) activity2.RecordTypeId = rtScarto.Id;
        }
        System.debug('setLookupFields end' + inputData);
        return inputData;
    }

    /**
    * @author Marco Arci (marco.arci@webresults.it)
    * @date 23/07/2021
    * @description HDT_UTL_Scarti.createScartoForMarketingCloudEMAIL - Creazione attività PClick
    * @param1 inputData - list of et4ae5__IndividualEmailResult__c
    * @return List<object> 
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
                if(singleData.get('Undelivered__c')==true &&
                oldData.get((Id)singleData.get('Id')).get('Undelivered__c')!=((string)singleData.get('Undelivered__c'))){
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
                                                                OR name=: SCARTODOCUMENTALESALESTEMPLATENAME];
            map<string,string> templateCodes= new Map<String,string>();                                             
            for(wrts_prcgvr__ActivityTemplate__c template: templates){
                if(SCARTODOCUMENTALEPOSTSALESTEMPLATENAME.equalsIgnoreCase(template.name)){
                    templateCodes.put('postSalesTemplate',template.wrts_prcgvr__Code__c);    
                }else if(SCARTODOCUMENTALESALESTEMPLATENAME.equalsIgnoreCase(template.name)){
                    templateCodes.put('salesTemplate',template.wrts_prcgvr__Code__c);    
                }
            }

            for(SObject handlesItem: toHandle){
                if(String.isBlank((string)handlesItem.get('OrderID__c'))){ 
                    insertedActivities.addAll((wrts_prcgvr__Activity__c[]) activityIntegration.createFromTemplate(templateCodes.get('postSalesTemplate'), new Map<String,Object>{'objectId' => handlesItem.get('CaseID__c')}));
                }else if(String.isBlank((string)handlesItem.get('CaseID__c'))){ 
                    insertedActivities.addAll((wrts_prcgvr__Activity__c[]) activityIntegration.createFromTemplate(templateCodes.get('salesTemplate'), new Map<String,Object>{'objectId' => handlesItem.get('OrderID__c')}));
                }
            }
            HDT_UTL_DatabaseService.insertSObject(insertedActivities);
        }
    }

    /**
    * @author Marco Arci (marco.arci@webresults.it)
    * @date 12/08/2021
    * @description HDT_UTL_Scarti.checkForEsitiIntermedi - annullamneto scarti dopo ricezione scarto Heroku
    * @param1 inputData - list of Herokus's scarti (activity(custom) wrts_prcgvr__Activity__c)
    * @return void
    */
    public static void checkForEsitiIntermedi(List<wrts_prcgvr__Activity__c> inputData){
        List<wrts_prcgvr__Activity__c> toUpdate = new List<wrts_prcgvr__Activity__c>();

        set<id> parentObjectCase = new set<id>();
        set<id> parentObjectOrder = new set<id>();
        set<id> inputDataId = new set<id>();
        for(wrts_prcgvr__Activity__c currAct : inputData){
            if(ESITIINTERMEDIHEROKU.contains(currAct.Type__c)){
                inputDataId.add(currAct.Id);
                if(string.isNotBlank(currAct.Case__c)){
                    parentObjectCase.add(currAct.Case__c);
                }else if(string.isNotBlank(currAct.Order__c)){
                    parentObjectOrder.add(currAct.Order__c);
                }
            }
        }
        list<wrts_prcgvr__Activity__c> relatedActCase = [select id, Status__c from wrts_prcgvr__Activity__c where Case__c in :parentObjectCase and Type__c in :ESITIINTERMEDIHEROKU and Id not in :inputDataId];
        list<wrts_prcgvr__Activity__c> relatedActOrder = [select id, Status__c from wrts_prcgvr__Activity__c where Order__c in :parentObjectOrder and Type__c in :ESITIINTERMEDIHEROKU and Id not in :inputDataId];

        for(wrts_prcgvr__Activity__c relatedAct: relatedActCase){
            system.debug(relatedAct);
            relatedAct.Status__c='Chiusa';
            toUpdate.add(relatedAct);
        }
        for(wrts_prcgvr__Activity__c relatedAct: relatedActOrder){
            system.debug(relatedAct);
            relatedAct.Status__c='Chiusa';
            toUpdate.add(relatedAct);
        }
        
        if(!toUpdate.IsEmpty()){
            system.debug('lista NON vuota -> Aggiorno'+toUpdate);
            update toUpdate;
        }
    }
}