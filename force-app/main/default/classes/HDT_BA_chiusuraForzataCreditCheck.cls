/**
 * @author alessandro.picchiri@eng.it
 * @date 24/05/2021 
*/
global class HDT_BA_chiusuraForzataCreditCheck implements Database.Batchable<sObject>{
    global final String Query;
    global HDT_BA_chiusuraForzataCreditCheck(String q){
        Query=q;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC,List<wrts_prcgvr__Activity__c> scope){
        //delete scope;
        // chiusura activity e cambio phase
    }

    global void finish(Database.BatchableContext BC){}
}