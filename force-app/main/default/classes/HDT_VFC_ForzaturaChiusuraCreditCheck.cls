/**
 * @author alessandro.picchiri@eng.it
 * @date 24/05/2021 
*/
public inherited sharing class HDT_VFC_ForzaturaChiusuraCreditCheck implements Database.Batchable<sObject>{
    
    public final String QUERY;
    public HDT_VFC_ForzaturaChiusuraCreditCheck(String q){
        QUERY=q;
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(QUERY);
    }

    // @Picchiri Credit Check ko definitivo activity dopo x giorni
    // x giorni presi da custome setting
    public void execute(Database.BatchableContext bc,List<wrts_prcgvr__Activity__c> scope){
        
        List<Id> idOrder = new List<Id>();
        for(wrts_prcgvr__Activity__c act : scope){
            act.Status__c = 'KO Definitivo';
            idOrder.add(act.Order__c);
        }
        update scope;
        // Viene scattenato il trigger delle Activity Custom
    }

    public void finish(Database.BatchableContext bc){
        return;
    }
}