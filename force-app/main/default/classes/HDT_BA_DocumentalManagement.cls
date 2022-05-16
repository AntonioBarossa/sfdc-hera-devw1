public with sharing class HDT_BA_DocumentalManagement implements Database.Batchable<sObject>, Database.Stateful {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Phase__c,SignatureMethod__c,DocSendingMethod__c FROM Order Where Phase__c = \'In Lavorazione\' AND isMassive__c = true';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Order> scope){
        Order singleOrder = (Order) scope[0];
        Map<String,String> params = new Map<String,String>();
        String modInvio = singleOrder.DocSendingMethod__c == 'Stampa Cartacea'? 'Sportello':singleOrder.DocSendingMethod__c;
        params.put('signMode', singleOrder.SignatureMethod__c);
        params.put('sendMode', modInvio);
        params.put('Contesto', 'Order');
        params.put('mode', 'Print');
        params.put('Archiviato', 'Y');
        //singleOrder.Phase__c = 'Documentazione da inviare';
        //HDT_UTL_DatabaseService.updateSObject(singleOrder);
        HDT_SRV_DocumentalManagementFacade.sendDocumentAsync(singleOrder.Id, 'Order',JSON.serialize(params));
    }
    public void finish(Database.BatchableContext bc){
        //no code needed
    }
}
