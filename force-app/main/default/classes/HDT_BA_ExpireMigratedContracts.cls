public without sharing class HDT_BA_ExpireMigratedContracts implements Database.Batchable<Sobject>, Schedulable, Database.Stateful {
    @TestVisible
    private List<String> errors;

    public void execute(SchedulableContext ctx){
        Database.executebatch(this, 200);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        this.errors=new List<String>();
        return Database.getQueryLocator([select id, IsMigrated__c, SBQQ__ExpirationDate__c, EndDate  from Contract where IsMigrated__c = true and EndDate < :Date.today() AND Status != 'Cessato']);
    }

    public void execute(Database.BatchableContext bc, List<Contract> contractsChunk) {
        for(Contract c : contractsChunk){
            c.Status='Cessato';
        }
        List<Database.SaveResult> results = Database.update(contractsChunk, false);
        for(Database.SaveResult result : results) {
            if(!result.isSuccess()) {
                this.errors.add((result.getId() + ' | ' + result.getErrors()).abbreviate(155));
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
        List<String> errorsToJoin = new list<String>();
        List<wrts_prcgvr__Log__c> logsToInsert = new List<wrts_prcgvr__Log__c>();

        Integer counter =0;
        while(!this.errors.isEmpty()){
            counter++;
            errorsToJoin.add(this.errors.remove(0));
            if(counter>=200){
                logsToInsert.add(createCalloutLog('HDT_BA_ExpireMigratedContracts - '+bc?.getJobId(), STRING.join(errorsToJoin, '$$\n')));
                errorsToJoin.clear();
                counter=0;
            }
        }
        if(!errorsToJoin.isEmpty()){
            logsToInsert.add(createCalloutLog('HDT_BA_ExpireMigratedContracts - '+bc?.getJobId(), STRING.join(errorsToJoin, '$$\n')));
        }

        if(!logsToInsert.isEmpty()){
            Database.insert(logsToInsert);//those debug logs must violate crud permission, those are registered for admins only
        }
    }

    private wrts_prcgvr__Log__c createCalloutLog(String message, String errors){
        wrts_prcgvr__Log__c calloutLog = new wrts_prcgvr__Log__c();
        calloutLog.wrts_prcgvr__Code__c = String.valueof(system.now().format('yyyyMMddHHmmssSSS'));
        calloutLog.wrts_prcgvr__Message__c = message;
        calloutLog.wrts_prcgvr__Description__c = 'Errors: \n'+errors;
        return calloutLog;
    }

}