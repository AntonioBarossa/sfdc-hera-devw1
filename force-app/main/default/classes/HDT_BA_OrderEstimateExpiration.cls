public class HDT_BA_OrderEstimateExpiration implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts, Schedulable {
    
    HDT_SRV_Order orderSrv = new HDT_SRV_Order();


    public Database.QueryLocator start(Database.BatchableContext bc) {

        Set<String> rtNameSet = new Set<String>{'HDT_RT_ConnessioneConAttivazione', 'HDT_RT_AttivazioneConModifica', 'HDT_RT_TemporaneaNuovaAtt'};
        return Database.getQueryLocator([SELECT Id, Phase__c FROM Order WHERE Phase__c ='Attesa conferma preventivo cliente' AND RecordType.DeveloperName IN :rtNameSet AND ValidityDateEstimate__c < TODAY]);
    }


    public void execute(Database.BatchableContext bc, List<Order> scope) {
        for(Order o : scope){
            o.Phase__c='Preventivo scaduto';
        }
        orderSrv.updateRecords(scope);
    }

    public void finish(Database.BatchableContext bc){
		return;
	}

    public void execute(SchedulableContext ctx){
        HDT_BA_OrderEstimateExpiration batch = new HDT_BA_OrderEstimateExpiration();
        Database.executebatch(batch, 200);
    }
}
