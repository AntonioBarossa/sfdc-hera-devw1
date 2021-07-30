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

    static final Map<String, String> TRACCIAMENTOHEROKUSALES = new Map<String, String>{ 'Esito ricevuto su richiesta chiusa' => 'CBS_HER006__ESITO_NON_ELABORATO_DA_DLSII_SALES',
                                                                                                     'Esito non elaborato' => 'CBS_HER007__ESITO_RICEVUTO_SU_RICHIESTA_CHIUSA_SALES',
                                                                                                     'Eliminato esito in scarto' => 'CBS_HER008__ELIMINATO_ESITO_IN_SCARTO_SALES',
                                                                                                     'Errore invio a SAP' => 'CBS_HER009__ERRORE_INVIO_A_SAP_SALES',
                                                                                                     'Errore determinazione variante SAP' => 'CBS_HER010__ERRORE_DETERMINAZIONE_VARIANTE_SAP_SALES'};


    static final Map<String, String> TRACCIAMENTOHEROKUPOSTSALES = new Map<String, String>{ 'Esito ricevuto su richiesta chiusa' => 'CBS_HER001__ESITO_NON_ELABORATO_DA_DLSII_POSTSALES',

																						                 'Esito non elaborato' => 'CBS_HER002__ESITO_RICEVUTO_SU_RICHIESTA_CHIUSA_POSTSALES',
																						                 'Eliminato esito in scarto' => 'CBS_HER003__ELIMINATO_ESITO_IN_SCARTO_POSTSALES',
																						                 'Errore invio a SAP' => 'CBS_HER004__ERRORE_INVIO_A_SAP_POSTSALES',
																						                 'Errore determinazione variante SAP' => 'CBS_HER005__ERRORE_DETERMINAZIONE_VARIANTE_SAP_POSTSALES'};

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
        
        if(method.startsWith('checkActivityCreation(')){
            checkActivityCreation((Id)sender.get('Id'), method.substringAfter('(').substringBefore(')'));
        }

        return null;
    }

    public class HDT_WRP_AttivitaTracciaturaData{
        public String errorMessage {get; set;}
        public String utenza {get; set;}
        public String dataEvento {get; set;}
        public String codPraticaUtente {get; set;}
        public String recordId {get; set;}
        public String tipoAttivita {get; set;}
        public String method {get; set;}
        public String processCategory {get; set;}
        public HDT_WRP_AttivitaTracciaturaData(){}
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
    public static void createAttivitaTracciaturaHeroku(List<HDT_WRP_AttivitaTracciaturaData> sourceData){
        List<wrts_prcgvr__Activity__c> toInsert = new List<wrts_prcgvr__Activity__c>();
        
        Set<String> tracciamentoTemplateNames = new Set<String>(TRACCIAMENTOHEROKUSALES.values());
        tracciamentoTemplateNames.addAll(TRACCIAMENTOHEROKUPOSTSALES.values());
        Map<String, wrts_prcgvr__ActivityTemplate__c> templatesMap = getTemplatesMapByName(tracciamentoTemplateNames);
        
        Map<String, List<HDT_WRP_AttivitaTracciaturaData>> dataPerTemplateCode = new Map<String, List<HDT_WRP_AttivitaTracciaturaData>>(); 

        Map<String, HDT_WRP_AttivitaTracciaturaData> dataForSalesHandlingByTemplateCode = new Map<String, HDT_WRP_AttivitaTracciaturaData>();

        wrts_prcgvr.Interfaces_1_1.IActivityIntegration activityIntegration = (wrts_prcgvr.Interfaces_1_1.IActivityIntegration) wrts_prcgvr.VersionManager.newClassInstance('ActivityIntegration');
        
        for(HDT_WRP_AttivitaTracciaturaData curData : sourceData){
            if('Richiesta non identificata'.equalsIgnoreCase(curData.tipoAttivita)){
                wrts_prcgvr__Activity__c newAct = new wrts_prcgvr__Activity__c();
                newAct.Type__c = curData.tipoAttivita;
                newAct.CreatedByUsername__c = curData.utenza;
                //newAct.StartDate__c = curData.dataEvento;
                //newAct.DiscardDescription__c = curData.errorMessage;
                toInsert.add(newAct);
            }
          
            else if(TRACCIAMENTOHEROKUSALES.keySet().contains(curData.tipoAttivita)){//va bene controllare solo su una mappa, tanto i keyset sono uguali
                if('sales'.equalsIgnoreCase(curData.processCategory)) dataForSalesHandlingByTemplateCode.put(curData.recordId, curData);
                else if('postsales'.equalsIgnoreCase(curData.processCategory)){
                    String templateCode = templatesMap.get(TRACCIAMENTOHEROKUPOSTSALES.get(curData.tipoAttivita)).wrts_prcgvr__Code__c;
                    List<wrts_prcgvr__Activity__c> activities = (List<wrts_prcgvr__Activity__c>) activityIntegration.createFromTemplate(templateCode, new Map<String,Object>{'objectId'=>curData.recordId});
                    //qui si possono integrare eventuali campi aggiuntivi sull'activity
                    toInsert.addAll(activities);
                }
            }
        }

        if(!dataForSalesHandlingByTemplateCode.keySet().isEmpty()){
            Map<Id, Order> orders = new Map<Id, Order>([SELECT Id FROM Order WHERE OrderNumber IN :dataForSalesHandlingByTemplateCode.keySet()]);
            for(Order curOrder : orders.values()){
                HDT_WRP_AttivitaTracciaturaData curData = dataForSalesHandlingByTemplateCode.get(curOrder.OrderNumber);
                String templateCode = templatesMap.get(TRACCIAMENTOHEROKUSALES.get(curData.tipoAttivita)).wrts_prcgvr__Code__c;
                List<wrts_prcgvr__Activity__c> activities = (List<wrts_prcgvr__Activity__c>) activityIntegration.createFromTemplate(templateCode, new Map<String,Object>{'objectId'=>curOrder.Id});
                //qui si possono integrare eventuali campi aggiuntivi sull'activity
                toInsert.addAll(activities);
            }
        }

        HDT_UTL_DatabaseService.insertSObject(toInsert);
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
            wrts_prcgvr__ActivityTemplate__c template = [SELECT Id, wrts_prcgvr__Code__c 
                                                        FROM wrts_prcgvr__ActivityTemplate__c
                                                        WHERE Name = :templateName
                                                        LIMIT 1];
            if(template != null){
                wrts_prcgvr.Interfaces_1_1.IActivityIntegration activityIntegration = (wrts_prcgvr.Interfaces_1_1.IActivityIntegration) wrts_prcgvr.VersionManager.newClassInstance('ActivityIntegration');
                List<wrts_prcgvr__Activity__c> activities = (List<wrts_prcgvr__Activity__c>) activityIntegration.createFromTemplate(template.wrts_prcgvr__Code__c, new Map<String,Object>{'objectId'=>recordId});
                HDT_UTL_DatabaseService.insertSObject(activities);
            }
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
        list<string> codiciClienti= new list<String>();        
        set<string> activityTypes= new set<string>();

        for(wrts_prcgvr__Activity__c activity: inputData){
            codiciClienti.add(activity.BPCode__c);
            activityTypes.add(activity.Type__c);
        }

        map<string,Id> mapActivityTemplates= new map<string,Id>();
        list<wrts_prcgvr__ActivityTemplate__c> activityTemplates=[SELECT Id, Name FROM wrts_prcgvr__ActivityTemplate__c WHERE Name =: CANONERAITEMPLATENAME OR Name=: BONUSSOCIALETEMPLATENAME];
        for(wrts_prcgvr__ActivityTemplate__c singleTemplate: activityTemplates){
            mapActivityTemplates.put(singleTemplate.Name,singleTemplate.Id);
        }

        List<Account> listAccounts=[SELECT Id, CustomerCode__c FROM Account WHERE CustomerCode__c IN: codiciClienti];
        for(wrts_prcgvr__Activity__c activity: inputData){
            for(Account singleAccount: listAccounts){
                if(activity.BPCode__c==singleAccount.CustomerCode__c){
                    activity.Account__c=singleAccount.Id;
                    if('Canone RAI'.equalsIgnoreCase(activity.Type__c)){
                        activity.wrts_prcgvr__ActivityTemplate__c=mapActivityTemplates.get(CANONERAITEMPLATENAME); 
                    }else if('Bonus sociale'.equalsIgnoreCase(activity.Type__c)){
                        activity.wrts_prcgvr__ActivityTemplate__c=mapActivityTemplates.get(BONUSSOCIALETEMPLATENAME); 
                    }
                }
            }
        }
        return inputData;
    }

    /**
    * @author Marco Arci (marco.arci@webresults.it)
    * @date 23/07/2021
    * @description HDT_UTL_Scarti.createScartoForDocusign - populating lookup fields
    * @param1 inputData - list of ?DocumentSendTracking__c?                             //DA CONFERMARE!
    * @return List<object> 
    */
    public static List<Object> createScartoForDocusign(List<Object> inputData){
        return inputdata;
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

            for(SObject scarto: toHandle){
                if(String.isBlank((string)scarto.get('OrderID__c'))){ 
                    insertedActivities.addAll((wrts_prcgvr__Activity__c[]) activityIntegration.createFromTemplate(templateCodes.get('postSalesTemplate'), new Map<String,Object>{'objectId' => scarto.get('CaseID__c')}));
                }else if(String.isBlank((string)scarto.get('CaseID__c'))){ 
                    insertedActivities.addAll((wrts_prcgvr__Activity__c[]) activityIntegration.createFromTemplate(templateCodes.get('salesTemplate'), new Map<String,Object>{'objectId' => scarto.get('OrderID__c')}));
                }
            }
            HDT_UTL_DatabaseService.insertSObject(insertedActivities);
        }
    }
}