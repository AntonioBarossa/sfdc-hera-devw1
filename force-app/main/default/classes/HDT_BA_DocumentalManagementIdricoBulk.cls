/**
 * Created by Cristiano Salvati on 05/12/2022.
 */

public with sharing class HDT_BA_DocumentalManagementIdricoBulk implements Database.Batchable<sObject>, Database.Stateful{
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Phase__c,SendMode__c,SignMode__c FROM Case Where Phase__c =\''+Label.consumoAnomaloIdricoDefaultPhase+'\'';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Case> scope){
        Case singleCase = (Case) scope[0];
        Map<String,String> params = new Map<String,String>();
        params.put('signMode', singleCase.SignMode__c);
        params.put('sendMode', singleCase.SendMode__c);
        params.put('Contesto', 'Case');
        params.put('mode', 'Print');
        params.put('Archiviato', 'Y');
        HDT_SRV_DocumentalManagementFacade.sendDocumentAsync(singleCase.Id, 'Case',JSON.serialize(params));
        singleCase.Phase__c=Label.consumoAnomaloIdricoE1WaitPhase;
        HDT_UTL_DatabaseService.updateSObject(singleCase);
    }
    public void finish(Database.BatchableContext bc){
        //no code needed
    }

}