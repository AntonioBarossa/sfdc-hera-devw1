public inherited sharing class HDT_BA_BlacklistOneshot implements Database.Batchable<SObject> {

    public Database.QueryLocator start(Database.BatchableContext context) {
        String query = 'SELECT Id FROM Individual WHERE OneshotBlacklistRemovalReason__c = \'Rimozione temporanea dalla blacklist\' AND OneshotBlacklist__c = True';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<sObject> recordList){

        for(sObject sobj : recordList){
            switch on sobj{
                when Individual individual {
                    individual.OneshotBlacklist__c = False;
                    individual.OneshotBlacklistRemovalReason__c = '';
                }
            }
        }

        HDT_UTL_DatabaseService.updateSObject(recordList);
    }

    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext context) {}
}