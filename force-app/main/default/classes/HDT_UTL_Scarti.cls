/**
 * @author Marco Arci (marco.arci@webresults.it)
 * @date 22/07/2021
 * @description HDT_UTL_Scarti - Utility scarti
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */

global with sharing class HDT_UTL_Scarti implements wrts_prcgvr.Interfaces_1_0.IApexAction{
    
    global Object execute(Object args){

        Map<String, Object> argsMap = (Map<String, Object>) args;

        SObject transition = (SObject) argsMap.get('transition');
        SObject action = (SObject) argsMap.get('action');
        String method = (String) argsMap.get('method');
        SObject sender = (SObject) argsMap.get('sender');

        switch on method{
            when 'checkActivityCreation'{
                checkActivityCreation((Id)sender.get('Id'));
            }
            when else{

            }
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
    Public static void checkActivityCreation(id recordId){
        //controllo il case per capire il tipo di processo e il tipo di scarto
        //query su template con le informazioni precedenti(tipo di processo e tipo di scarto)
        //chiamo il metodo di process click per creare l'attività
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
        list<wrts_prcgvr__ActivityTemplate__c> activityTemplates=[SELECT Id, Name FROM wrts_prcgvr__ActivityTemplate__c WHERE Name IN: activityTypes]; //to do matchare nome template
        for(wrts_prcgvr__ActivityTemplate__c singleTemplate: activityTemplates){
            mapActivityTemplates.put(singleTemplate.Name,singleTemplate.Id);
        }

        List<Account> listAccounts=[SELECT Id, CustomerCode__c FROM Account WHERE CustomerCode__c IN: codiciClienti];
        for(wrts_prcgvr__Activity__c activity: inputData){
            for(Account singleAccount: listAccounts){
                if(activity.BPCode__c==singleAccount.CustomerCode__c){
                    activity.Account__c=singleAccount.Id;
                    activity.wrts_prcgvr__ActivityTemplate__c=mapActivityTemplates.get(activity.Type__c); //to do matchare nome template
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
    public static List<Object> createScartoForMarketingCloudEMAIL(List<Object> inputData){
        
        return inputdata;
    }

    /**
    * @author Marco Arci (marco.arci@webresults.it)
    * @date 23/07/2021
    * @description HDT_UTL_Scarti.createScartoForMarketingCloudSMS - Creazione attività PClick
    * @param1 inputData - list of SMSTracking__c
    * @return List<object> 
    */
    public static List<Object> createScartoForMarketingCloudSMS(List<Object> inputData){
        
        return inputdata;
    }
}
