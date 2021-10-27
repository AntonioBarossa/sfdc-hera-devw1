@SuppressWarnings('PMD.AvoidDebugStatements')
public with sharing class HDT_BA_ExpiredCases implements Database.Batchable<sObject> {
    
    
    //BATCH START
    
    //TODO: SOSTITUIRE SEND DATE CON DocusignExpirationDate__c
    public Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT Id, Status__c, DocusignExpirationDate__c, Phase__c, CancellationReason__c '
                    + 'FROM Case '
                    + 'WHERE SendDate__c < ' + Date.today()
                    + ' WITH SECURITY_ENFORCED';

        return Database.getQueryLocator(query);
    }
    
    //BATCH EXECUTE
    public void execute(Database.BatchableContext bc, List<Case> casesToNullify){
        
        for(Case myCase : casesToNullify){
            myCase.Phase__c = 'Annullato';
            myCase.CancellationReason__c = 'Annullato per no conferma cliente';
        }
        System.debug(LoggingLevel.DEBUG, 'HDT_BA_ExpiredCases - Aggiorno Case Record: ' + casesToNullify.size());
        
        update casesToNullify;
    }
    
    //BATCH FINISH
    public void finish(Database.BatchableContext bc) {
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :bc.getJobId()];
        System.debug(LoggingLevel.DEBUG, 'HDT_BA_ActivityDispatcher - finished job: ' + a);
    }
    
}
