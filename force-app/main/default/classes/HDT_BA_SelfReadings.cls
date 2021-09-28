// BATCH DEPRECATO - DA NON SCHEDULARE
public inherited sharing class HDT_BA_SelfReadings implements Database.Batchable<SObject> {

    public Database.QueryLocator start(Database.BatchableContext context) {
        String query = 'SELECT Id FROM Case WHERE Type = \'Autolettura da cliente\' AND Phase__c = \'Inviata a SAP\' AND LastModifiedDate <= LAST_N_DAYS:2';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<sObject> recordList){

        for(sObject sobj : recordList){
            switch on sobj{
                when Case selfReadingCase {
                    selfReadingCase.Phase__c = 'Esito KO da SAP simulato';
                }
                when else {}
            }
        }

        HDT_UTL_DatabaseService.updateSObject(recordList);
    }

    public void finish(Database.BatchableContext context) {}
}