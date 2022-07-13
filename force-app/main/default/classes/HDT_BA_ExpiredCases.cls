@SuppressWarnings('PMD.AvoidDebugStatements')
public with sharing class HDT_BA_ExpiredCases implements Database.Batchable<sObject>, Schedulable {

    public void execute(SchedulableContext ctx){
        Database.executebatch(this,100);
    }

    //BATCH START
    public Database.QueryLocator start(Database.BatchableContext bc){
        Date todayDate = Date.today();
        List<String> listPhase = new List<String>{'Attesa Modulo Firmato'};
        String query = 'SELECT Id, Status, DocusignExpirationDate__c, Phase__c, CancellationReason__c FROM Case WHERE Phase__c IN:listPhase AND DocusignExpirationDate__c <: todayDate AND DocusignExpirationDate__c != null WITH SECURITY_ENFORCED';

        return Database.getQueryLocator(query);
    }
    
    //BATCH EXECUTE
    public void execute(Database.BatchableContext bc, List<Case> casesToNullify){
        
        for(Case myCase : casesToNullify){
            myCase.Phase__c = 'Annullato';
            myCase.CancellationReason__c = 'Annullato per no conferma cliente';
        }
        System.debug(LoggingLevel.DEBUG, 'HDT_BA_ExpiredCases - Aggiorno Case Record: ' + casesToNullify.size());
        
        HDT_UTL_DatabaseService.updateSObject(casesToNullify);
    }
    
    //BATCH FINISH
    public void finish(Database.BatchableContext bc) {
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :bc.getJobId()];
        System.debug(LoggingLevel.DEBUG, 'HDT_BA_ExpiredCases - finished job: ' + a);
    }
    
}