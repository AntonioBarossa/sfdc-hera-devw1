public with sharing class HDT_BA_DeltaSelfReadingManagement implements Database.Batchable<SObject>, Database.AllowsCallouts, Schedulable{
    private HDT_SRV_LogService logs;
    public HDT_BA_DeltaSelfReadingManagement(){
        this.logs = new HDT_SRV_LogService(String.valueOf(this).substring(0,String.valueOf(this).indexOf(':')));
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT id, Phase__c, Origin,Note__c FROM Case WHERE Type = \'Autolettura da cliente\' AND Cluster__c = \'Autolettura\' AND (Phase__c = \'Esito OK da SAP\' OR (Phase__c = \'Check preliminari OK\' AND Origin IN (\'IVR\',\'SMS\'))) AND CommodityFormula__c IN (\'Gas\',\'Energia Elettrica\')');
    }

    public void execute(Database.BatchableContext context, List<SObject> scope){
        Id recordId = null;
        try{
            List<String> cIds = new List<String>();
            for (SObject obj : scope){
                Case  c = (Case)(obj);
                cIds.add('\''+c.Id+'\'');
            }
            Map<Id,String> callForCases = this.getAllCall(cIds); 
            List<Case> caseToUp = new List<Case>();
            for (SObject obj : scope){
                Case  c = (Case)(obj);
                recordId = c.Id;
                if (callForCases.containsKey(c.Id)){
                    this.logs.addLog('HDT_BA_DeltaSelfReadingManagement', 'execute', JSON.serialize(c), null, 'Trovata callout in Queued --> ' + callForCases.containsKey(c.Id) , c != null ? c.Id : null, null, null);
                    continue;
                }
                if ('Esito OK da SAP'.equalsIgnoreCase(c.Phase__c)){
                    c.Note__c =  String.isBlank(c.Note__c) ? '.' : c.Note__c.endsWithIgnoreCase('.') ? c.Note__c.substring(0,c.Note__c.length()-1) : c.Note__c +'.';
                    caseToUp.add(c);
                }
                if ('Check preliminari OK'.equalsIgnoreCase(c.Phase__c) && ('IVR'.equalsIgnoreCase(c.Origin) || 'SMS'.equalsIgnoreCase(c.Origin))){
                    this.send(c);
                }
            }
            if (!caseToUp.isEmpty()){
                HDT_UTL_DatabaseService.updateSObject(caseToUp);
            }
        }catch (Exception e){
            this.logs.addLog('HDT_BA_DeltaSelfReadingManagement', 'execute', JSON.serialize(scope), null, e.getStackTraceString()+ ' Error Message: ' + e.getMessage(), recordId, null, null);
        }
        logs.saveMassiveRecords();
    }

    private Map<Id,String> getAllCall(List<String> cIds){
        Map<Id,String> allCalls = new Map<Id,String>();
        List<SObject> calls = HDT_QR_GenericQuery.getGenericRecords('Id,wrts_prcgvr__JobItem__c', 'wrts_prcgvr__AsyncJob__c', 'wrts_prcgvr__JobItem__c IN ('+String.join(cIds, ',')+')  AND wrts_prcgvr__Status__c = \'Queued\' AND wrts_prcgvr__JobType__c = \'Callout\'');
        if (calls != null) {
            for (wrts_prcgvr__AsyncJob__c call : (List<wrts_prcgvr__AsyncJob__c>)calls){
                allCalls.put(call.wrts_prcgvr__JobItem__c,call.Id);
            }
        }
        return allCalls;
    }

    private void send(Case c){
        Map<String, Object> args = new Map<String, Object>{
            'sender' => c,
            'method' => 'handleInvioLettureForzato'
        };
        HDT_SRV_PostSalesManager postSales = new HDT_SRV_PostSalesManager();
        postSales.execute(args);
    }

    @SuppressWarnings('PMD.AvoidDebugStatements')
    public void finish(Database.BatchableContext context) {
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :context.getJobId()];
        System.debug(LoggingLevel.DEBUG, 'HDT_BA_DiscardDocusignEnvelope - finished job: ' + a);
    }

    public void execute(SchedulableContext ctx){
        // lasciare la chiamata ad uno
        Database.executebatch(this,1);
    }
}
