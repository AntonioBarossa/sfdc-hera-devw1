public class HDT_BA_OrderEstimateExpiration implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts, Schedulable {
    
    HDT_SRV_Order orderSrv = new HDT_SRV_Order();
    Date today = System.today();


    public Database.QueryLocator start(Database.BatchableContext bc) {

        Set<String> rtNameSet = new Set<String>{'HDT_RT_ConnessioneConAttivazione', 'HDT_RT_AttivazioneConModifica', 'HDT_RT_TemporaneaNuovaAtt'};
        return Database.getQueryLocator([SELECT Id, Phase__c,PhaseStory__c FROM Order WHERE (Phase__c = 'Attesa conferma preventivo cliente' OR (Phase__c = 'Ammissibilità OK' AND QuotationType__c = 'Predeterminabile')) 
        AND RecordType.DeveloperName IN :rtNameSet AND ValidityDateEstimate__c < :today]);
    }


    public void execute(Database.BatchableContext bc, List<Order> scope) {
 
        HDT_UTL_PostSalesCriteriaManager psCrit = new HDT_UTL_PostSalesCriteriaManager();
        List<Order> orderToUpdate = new List<Order>();

        for(Order ord : scope){
            if(ord.Phase__c.equalsIgnoreCase('Attesa conferma preventivo cliente') 
                || (ord.Phase__c.equalsIgnoreCase('Ammissibilità OK') && psCrit.secondAdmissibility(ord.PhaseStory__c)))
            {
                ord.Phase__c = 'Preventivo scaduto';
                ord.Status = 'Annullato';
                orderToUpdate.add(ord);
            }
        }
        if(!orderToUpdate.isEmpty())
        {
            HDT_UTL_DatabaseService.updateSObject(scope);
        }
    }

    public void finish(Database.BatchableContext bc){
        //Schedulable instance = (Schedulable) wrts_prcgvr.VersionManager.newClassInstance('AsyncJobBatchSchedule');
        //instance.execute(null);
	}

    public void execute(SchedulableContext ctx){
        HDT_BA_OrderEstimateExpiration batch = new HDT_BA_OrderEstimateExpiration();
        Database.executebatch(batch, 200);
    }
}
