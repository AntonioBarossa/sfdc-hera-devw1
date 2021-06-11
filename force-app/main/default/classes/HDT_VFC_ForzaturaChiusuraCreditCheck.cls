/**
 * @author alessandro.picchiri@eng.it
 * @date 24/05/2021 
*/
global class HDT_VFC_ForzaturaChiusuraCreditCheck implements Database.Batchable<sObject>{
    
    global final String QUERY;
    global HDT_VFC_ForzaturaChiusuraCreditCheck(String q){
        System.debug('HDT_VFC_ForzaturaChiusuraCreditCheck START');
        QUERY=q;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(QUERY);
    }

    // @Picchiri Credit Check ko definitivo activity dopo x giorni
    // x giorni presi da custome setting
    global void execute(Database.BatchableContext BC,List<wrts_prcgvr__Activity__c> scope){
        System.debug('HDT_VFC_ForzaturaChiusuraCreditCheck START EXECUTE');
        
        List<Id> idOrder = new List<Id>();
        for(wrts_prcgvr__Activity__c act : scope){
            act.Status__c = 'KO Definitivo';
            idOrder.add(act.Order__c);
        }
        update scope;
        // Viene scattenato il trigger delle Activity Custom
    }

    global void finish(Database.BatchableContext BC){}
}