/**
 * Header of the class "HDT_BA_ArchivedRecordsDelete"
 * @author Andrei Necsulescu, andrei.necsulescu@webresults.it
 * @version 1.0
 * @description: Deletes archived records and parents of this objects
 * @history
 * @Created 19/10/2022
 * Modified By:
 **/

public with sharing class HDT_BA_ArchivedRecordsDelete implements Database.Batchable<Sobject> {

    // List of objects to delete
    private final List<String> OBJECTS_TO_PROCESS = new List<String>{'ContentDocument', 'wrts_prcgvr__Activity__c', 'PushTracking__c', 'SMSTracking__c', 'SolTracking__c', 
    'et4ae5__IndividualEmailResult__c', 'Reading__c', 'DocumentSelected__c', 'DocumentalActivity__c', 'DocumentSendTracking__c', 'CommunicationLog__c', 'Asset', 'Case', 'Contract', 
    'OrderItem', 'Order', 'Opportunity', 'BillingProfile__c', 'ServicePoint__c', 'SiebelCommTracking__c', 'SurveyResponse__c', 'ContactPointPhone', 'ContactPointEmail', 'Contact', 'Individual', 
    'Account', 'Interaction__c'};

    private final Set<String> OBJECTS_THAT_ARE_NOT_ARCHIVED = new Set<String>{'CommunicationLog__c', 'BillingProfile__c', 'ServicePoint__c', 'Individual', 'Interaction__c'};

    @TestVisible 
    private String currentObject = '';
    private Integer currentObjectIndex = 0;
    private Integer queryLimit = 0;

    // Batch size to use in the finish for the batch to relaunch iself
    private Integer batchScope = 200;

    // Determines if the batch should proceed with the next Object in the list or stop right away
    @TestVisible
    private Boolean relaunchBatch = true;

    // private List<Sobject> recordsDeleted = new List<Sobject>();
    // private String queryUsed;
    // private String exceptionErr = '';
    // private Datetime executionTimeStamp;
    // private Integer numberOfDeletedRecords = 0;
    
    public HDT_BA_ArchivedRecordsDelete (Integer batchSize) {

        this.batchScope = batchSize;
        this.currentObjectIndex = 0;
        this.currentObject = OBJECTS_TO_PROCESS.get(this.currentObjectIndex);

    }

    public HDT_BA_ArchivedRecordsDelete (Integer batchSize, Integer index) {

        this.batchScope = batchSize;
        this.currentObjectIndex = index;
        this.currentObject = OBJECTS_TO_PROCESS.get(this.currentObjectIndex);
        
    }

    public HDT_BA_ArchivedRecordsDelete (Integer batchSize, Integer index, Integer queryLimit) {

        this.batchScope = batchSize;
        this.currentObjectIndex = index;
        this.queryLimit = queryLimit;
        this.currentObject = OBJECTS_TO_PROCESS.get(this.currentObjectIndex);
        
    }

    public HDT_BA_ArchivedRecordsDelete (Integer batchSize, Integer index, Boolean relaunchBatch) {

        this.relaunchBatch = relaunchBatch;
        this.batchScope = batchSize;
        this.currentObjectIndex = index;
        this.currentObject = OBJECTS_TO_PROCESS.get(this.currentObjectIndex);
        
    }

    public HDT_BA_ArchivedRecordsDelete (Integer batchSize, Integer index, Integer queryLimit, Boolean relaunchBatch) {

        this.relaunchBatch = relaunchBatch;
        this.batchScope = batchSize;
        this.currentObjectIndex = index;
        this.queryLimit = queryLimit;
        this.currentObject = OBJECTS_TO_PROCESS.get(this.currentObjectIndex);
        
    }

    public Database.QueryLocator start (Database.BatchableContext bc) {

        String queryString = 'SELECT Id ';

        // Add fields to query for objects that may need an update before being deleted
        switch on this.currentObject {
            when 'Order' {
                queryString += ', SBQQ__Contracted__c, Status ';
            }
            when 'OrderItem' {
                queryString += ', SBQQ__Activated__c, SBQQ__Contracted__c ';
            }
            // when 'BillingProfile__c' {
            //     queryString += ', (SELECT Id FROM Cases__r LIMIT 1), (SELECT Id FROM Casi__r LIMIT 1), (SELECT Id FROM Orders__r LIMIT 1), (SELECT Id FROM Order_Products__r LIMIT 1), (SELECT Id FROM Contracts__r LIMIT 1) ';
            // }
            // when 'CommunicationLog__c' {
            //     queryString += ', (SELECT Id FROM IndividualEmailResults__r LIMIT 1), (SELECT Id FROM PushTracking__r LIMIT 1), (SELECT Id FROM SMSTracking__r LIMIT 1) ';
            // }
            // when 'Individual' {
            //     queryString += ', (SELECT Id FROM Contacts LIMIT 1), (SELECT Id FROM Leads LIMIT 1) ';
            // }
            // when 'Interaction__c' {
            //     queryString += ', (SELECT Id FROM Cases__r LIMIT 1), (SELECT Id FROM Orders__r LIMIT 1), (SELECT Id FROM Vendite__r LIMIT 1), (SELECT Id FROM Activities_Custom__r LIMIT 1) ';
            // }
            // when 'ServicePoint__c' {
            //     queryString += ', (SELECT Id FROM Cases__r LIMIT 1), (SELECT Id FROM Activities_Custom__r LIMIT 1) ';
            // }
        }

        queryString += ' FROM ' + this.currentObject;

        if (this.currentObject == 'ContentDocument') {
            queryString += ' WHERE LatestPublishedVersion.IsArchived__c = true';
        } else if(this.currentObject == 'Opportunity') {
            queryString += ' WHERE Account.IsArchived__c = true AND StageName = \'Closed Won\'';
        } else if(!this.OBJECTS_THAT_ARE_NOT_ARCHIVED.contains(this.currentObject)) {
            queryString += ' WHERE IsArchived__c = true';
        }

        if (this.queryLimit > 0) {
            queryString += ' LIMIT ' + this.queryLimit;
        }

        // this.queryUsed = queryString;

        System.debug('This is the generated query string' + queryString);

        CS_ArchivedRecordsDeleteBatch__c executionTracking = [SELECT CurrentBatchId__c, RelaunchBatch__c, ExecutionTimestamp__c, ErrorMessage__c, 
                                                              QueryUsed__c, NumberOfRecordsDeleted__c, NumberOfDeleteErrors__c 
                                                              FROM CS_ArchivedRecordsDeleteBatch__c LIMIT 1];
        executionTracking.CurrentBatchId__c = bc.getJobId();
        executionTracking.RelaunchBatch__c = this.relaunchBatch;
        executionTracking.ExecutionTimestamp__c = System.now();
        executionTracking.QueryUsed__c = queryString.abbreviate(255);
        executionTracking.NumberOfRecordsDeleted__c = 0;
        executionTracking.NumberOfDeleteErrors__c = 0;
        executionTracking.ErrorMessage__c = '';

        Database.update(executionTracking);

        return Database.getQueryLocator(queryString);

    }


    public void execute (Database.BatchableContext bc, List<SObject> scope) {

        CS_ArchivedRecordsDeleteBatch__c executionTracking = [SELECT CurrentBatchId__c, RelaunchBatch__c, ExecutionTimestamp__c, ErrorMessage__c, 
                                                              QueryUsed__c, NumberOfRecordsDeleted__c, NumberOfDeleteErrors__c 
                                                              FROM CS_ArchivedRecordsDeleteBatch__c LIMIT 1];

        try {

            String exceptionErr = executionTracking.ErrorMessage__c;

            List<Id> filteredRecordsToDelete = new List<Id>();
            Boolean needsDeletionWithSet = false;

            List<Database.DeleteResult> deleteResults;

            switch on this.currentObject {
                // Custom logic for records that need to be updated before being deleted
                when 'Order' {
                    deactivateRecords(scope);
                }
                when 'OrderItem' {
                    deactivateRecords(scope);
                }
                // Custom logic for records that are not archived but need to be deleted
                when 'BillingProfile__c' {
                    
                    filteredRecordsToDelete.addAll(filterScopeForDeletedChildren(scope, new List<String> {'Case|BillingProfile__c', 'Case|TargetBillingProfile__c', 'Order|BillingProfile__c', 'OrderItem|BillingProfile__c', 'Contract|BillingProfile__c'}));
                    needsDeletionWithSet = true;

                }
                when 'CommunicationLog__c' {
                    
                    filteredRecordsToDelete.addAll(filterScopeForDeletedChildren(scope, new List<String> {'et4ae5__IndividualEmailResult__c|IdLog__c', 'PushTracking__c|IdLog__c', 'SMSTracking__c|IdLog__c'}));
                    needsDeletionWithSet = true;

                }
                when 'Individual' {
                    
                    filteredRecordsToDelete.addAll(filterScopeForDeletedChildren(scope, new List<String> {'Contact|IndividualId', 'Lead|IndividualId'}));
                    needsDeletionWithSet = true;

                }
                when 'Interaction__c' {
                    
                    filteredRecordsToDelete.addAll(filterScopeForDeletedChildren(scope, new List<String> {'Case|Interaction__c', 'Order|Interaction__c', 'Sale__c|Interaction__c', 'wrts_prcgvr__Activity__c|Interaction__c'}));
                    needsDeletionWithSet = true;

                }
                when 'ServicePoint__c' {
                    
                    filteredRecordsToDelete.addAll(filterScopeForDeletedChildren(scope, new List<String> {'Case|ServicePoint__c', 'Order|ServicePoint__c', 'wrts_prcgvr__Activity__c|ServicePoint__c'}));
                    needsDeletionWithSet = true;

                }
            }

            // this.recordsDeleted.addAll(scope);

            if (this.currentObject != 'OrderItem') { // Order Products can't be deleted directly, they will be deleted when the associated Order is Deleted

                // Delete records in scope and return error if there are problems           
                if (needsDeletionWithSet) {
                    deleteResults = Database.delete(filteredRecordsToDelete, false);
                } else {
                    deleteResults = Database.delete(scope, false);
                }

                for (Database.DeleteResult dr : deleteResults) {

                    if (!dr.isSuccess()) {                        
                        executionTracking.NumberOfDeleteErrors__c++;
                        
                        // Stop launch of next batch if there are errors in the delete
                        // executionTracking.RelaunchBatch__c = false;

                        exceptionErr += JSON.serialize(dr.getErrors());

                        // this.exceptionErr += JSON.serializePretty(dr.getErrors());                        
                    } else {
                        executionTracking.NumberOfRecordsDeleted__c++;
                    }

                }

            }

            executionTracking.ErrorMessage__c = exceptionErr?.abbreviate(255);

            System.debug('executionTracking.NumberOfRecordsDeleted__c before execute update: ' + executionTracking.NumberOfRecordsDeleted__c);
            System.debug('executionTracking.NumberOfDeleteErrors__c before execute update: ' + executionTracking.NumberOfDeleteErrors__c);
            System.debug('executionTracking.ErrorMessage__c before execute update: ' + executionTracking.ErrorMessage__c);

            Database.update(executionTracking);

        } catch (Exception e) {

            // Stop launch of next batch if there are errors in execute
            // executionTracking.RelaunchBatch__c = false;
            executionTracking.ErrorMessage__c = (e.getMessage() + '\n' + e.getStackTraceString()).abbreviate(255);

            Database.update(executionTracking);

            // this.exceptionErr += e.getMessage() + '\n\n' + e.getStackTraceString();

        }        
        
    }

    public void finish (Database.BatchableContext bc) {

        CS_ArchivedRecordsDeleteBatch__c executionTracking = [SELECT CurrentBatchId__c, RelaunchBatch__c, ExecutionTimestamp__c, ErrorMessage__c, 
                                                              QueryUsed__c, NumberOfRecordsDeleted__c, NumberOfDeleteErrors__c 
                                                              FROM CS_ArchivedRecordsDeleteBatch__c LIMIT 1];

        String nextObject = '';

        this.currentObjectIndex ++;
        System.debug('Index is at ' + this.currentObjectIndex);
        
        if (executionTracking.RelaunchBatch__c && this.currentObjectIndex < this.OBJECTS_TO_PROCESS.size()) {
            nextObject = this.OBJECTS_TO_PROCESS.get(this.currentObjectIndex);
            System.debug('Next object is ' + nextObject);
            Database.executeBatch(new HDT_BA_ArchivedRecordsDelete(this.batchScope, this.currentObjectIndex, this.queryLimit), this.batchScope);
        }

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        mail.setSubject('Deleted ' + this.currentObject);
        mail.setToAddresses(new List<String>{UserInfo.getUserEmail()});
        mail.setOrgWideEmailAddressId([SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'HERA Org Wide Address'].Id);

        if (String.isNotBlank(executionTracking.ErrorMessage__c)) {
            mail.setPlainTextBody('Execution Timestamp: ' + executionTracking.ExecutionTimestamp__c + 
                                  ', Records Deleted: ' + executionTracking.NumberOfRecordsDeleted__c + 
                                  ', Records With Deleted Errors: ' + executionTracking.NumberOfDeleteErrors__c + 
                                  ', Next Object To Process: ' + nextObject + 
                                  '\n\nQuery used: ' + executionTracking.QueryUsed__c + '\n\nthe execution resulted in the following errors: ' + executionTracking.ErrorMessage__c);
        } else {
            // mail.setPlainTextBody('Execution Timestamp: ' + this.executionTimeStamp + '\n\nQuery used: ' + this.queryUsed + '\n\nThe following records of type ' + this.currentObject + ' have been deleted:\n' + JSON.serializePretty(this.recordsDeleted));
            mail.setPlainTextBody('Execution Timestamp: ' + executionTracking.ExecutionTimestamp__c + 
                                  ', Records Deleted: ' + executionTracking.NumberOfRecordsDeleted__c + 
                                  ', Next Object To Process: ' + nextObject + 
                                  '\n\nQuery used: ' + executionTracking.QueryUsed__c + '\n\nThe records of type ' + this.currentObject + ' have been deleted.');
        }

        Messaging.sendEmail(new Messaging.Email[] { mail });

    }

    // These records need to be deactivated before being deleted
    private void deactivateRecords(List<SObject> scope) {

        switch on this.currentObject {
            when 'Order' {

                for (SObject ord : scope) {

                    ord.put('SBQQ__Contracted__c', false);
                    ord.put('Status', 'Draft');
        
                }

            }
            when 'OrderItem' {

                for (SObject ord : scope) {

                    ord.put('SBQQ__Activated__c', false);
                    ord.put('SBQQ__Contracted__c', false);

                }

            }
        }

        Database.update(scope);

    }

    // Check that all children were deleted
    public Set<Id> filterScopeForDeletedChildren(List<SObject> scope, List<String> parentRelationships) {

        Set<Id> result = new Set<Id>();

        for (SObject so : scope) {
            result.add((Id) so.get('Id'));
        }

        for (String parent : parentRelationships) {

            String targetObject = parent.split('\\|').get(0);
            String targetField = parent.split('\\|').get(1);

            String queryString = 'SELECT ' + targetField + 
                                 ' FROM ' + targetObject + 
                                 ' WHERE ' + targetField + 
                                 ' IN :result ' + 
                                 ' GROUP BY ' + targetField + 
                                 ' LIMIT ' + this.batchScope;

            System.debug('Parents query used ' + queryString);

            for (AggregateResult so : Database.query(queryString)) {

                result.remove((Id) so.get(targetField));

            }

        }

        return result;

    }
}