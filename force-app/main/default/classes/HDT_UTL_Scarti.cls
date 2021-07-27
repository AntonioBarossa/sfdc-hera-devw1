/**
 * @author Marco Arci (marco.arci@webresults.it)
 * @date 22/07/2021
 * @description HDT_UTL_Scarti - Utility scarti
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */

global with sharing class HDT_UTL_Scarti implements wrts_prcgvr.Interfaces_1_0.IApexAction{
    static final string CANONERAI_TEMPLATENAME='CBS_CAR002__CANONE_RAI';
    static final string BONUSSOCIALE_TEMPLATENAME='CBS_FAT011__BONUS_SOCIALE';

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

    /**
    * @author Marco Arci (marco.arci@webresults.it)
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
        list<wrts_prcgvr__ActivityTemplate__c> activityTemplates=[SELECT Id, Name FROM wrts_prcgvr__ActivityTemplate__c WHERE Name =: CANONERAI_TEMPLATENAME OR Name=: BONUSSOCIALE_TEMPLATENAME];
        for(wrts_prcgvr__ActivityTemplate__c singleTemplate: activityTemplates){
            mapActivityTemplates.put(singleTemplate.Name,singleTemplate.Id);
        }

        List<Account> listAccounts=[SELECT Id, CustomerCode__c FROM Account WHERE CustomerCode__c IN: codiciClienti];
        for(wrts_prcgvr__Activity__c activity: inputData){
            for(Account singleAccount: listAccounts){
                if(activity.BPCode__c==singleAccount.CustomerCode__c){
                    activity.Account__c=singleAccount.Id;
                    if(activity.Type__c.equalsIgnoreCase('Canone RAI')){
                        activity.wrts_prcgvr__ActivityTemplate__c=mapActivityTemplates.get(CANONERAI_TEMPLATENAME); 
                    }else if(activity.Type__c.equalsIgnoreCase('Bonus sociale')){
                        activity.wrts_prcgvr__ActivityTemplate__c=mapActivityTemplates.get(BONUSSOCIALE_TEMPLATENAME); 
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
    public static List<wrts_prcgvr__Activity__c> createScartoForMarketingCloud(List<object> inputData){
        list<wrts_prcgvr__Activity__c> insertedActivities= new list<wrts_prcgvr__Activity__c>();

        wrts_prcgvr.Interfaces_1_1.IActivityIntegration ActivityIntegration =(wrts_prcgvr.Interfaces_1_1.IActivityIntegration)wrts_prcgvr.VersionManager.newClassInstance('ActivityIntegration');

        wrts_prcgvr__ActivityTemplate__c templatePostSales=[SELECT id, name, wrts_prcgvr__Code__c FROM wrts_prcgvr__ActivityTemplate__c WHERE name='CBS_CRP004__SCARTI_DOCUMENTALI_POST_SALES'];
        wrts_prcgvr__ActivityTemplate__c templateSales=[SELECT id, name, wrts_prcgvr__Code__c FROM wrts_prcgvr__ActivityTemplate__c WHERE name='CBS_CRP003__SCARTI_DOCUMENTALI_SALES'];

        for(et4ae5__IndividualEmailResult__c scarto: inputData){
            if(Template.OrderID__c.isBlank()){
                insertedActivities.addAll((wrts_prcgvrActivity_c[]) ActivityIntegration.createFromTemplate(templatePostSales.wrts_prcgvr__Code__c, new Map<String,Object>{'objectId' => CaseID__c}));
            }else if(Template.CaseID__c.isBlank()){ 
                insertedActivities.addAll((wrts_prcgvrActivity_c[]) ActivityIntegration.createFromTemplate(templateSales.wrts_prcgvr__Code__c, new Map<String,Object>{'objectId' => OrderID__c}));
            }
        }
        return insertedActivities;
    }

}
