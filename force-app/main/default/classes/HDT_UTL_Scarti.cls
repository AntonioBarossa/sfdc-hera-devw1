/**
 * @author Marco Arci (marco.arci@webresults.it)
 * @date 22/07/2021
 * @description HDT_UTL_Scarti - Utility scarti
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */

public with sharing class HDT_UTL_Scarti {
    
    /**
    * @author Marco Arci (marco.arci@webresults.it)
    * @date 22/07/2021
    * @description HDT_UTL_Scarti.checkActivityCreation - Check on activity creation
    * @param1 recordId - Id of a record
    * @return void
    */
    Public static void checkActivityCreation(id recordId){

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
        list<wrts_prcgvr__ActivityTemplate__c> activityTemplates=[SELECT Id, Name FROM wrts_prcgvr__ActivityTemplate__c WHERE Name IN: activityTypes];
        for(wrts_prcgvr__ActivityTemplate__c singleTemplate: activityTemplates){
            mapActivityTemplates.put(singleTemplate.Name,singleTemplate.Id);
        }

        List<Account> listAccounts=[SELECT Id, CustomerCode__c FROM Account WHERE CustomerCode__c IN: codiciClienti];
        for(wrts_prcgvr__Activity__c activity: inputData){
            for(Account singleAccount: listAccounts){
                if(activity.BPCode__c==singleAccount.CustomerCode__c){
                    activity.Account__c=singleAccount.Id;
                    activity.wrts_prcgvr__ActivityTemplate__c=mapActivityTemplates.get(activity.Type__c);
                }
            }
        }
        return inputData;
    }

}
