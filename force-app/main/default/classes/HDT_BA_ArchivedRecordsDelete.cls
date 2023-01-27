/**
 * Header of the class "HDT_BA_ArchivedRecordsDelete"
 * @author Andrei Necsulescu, andrei.necsulescu@webresults.it
 * @version 1.0
 * @description: Deletes archived records and parents of this objects
 * @history
 * @Created 19/10/2022
 * Modified By:
 **/

public with sharing class HDT_BA_ArchivedRecordsDelete implements Database.Batchable<Sobject>, Database.Stateful {

    // List of objects to delete
    private List<String> objectsToProcess = new List<String>{'ContentDocument', 'wrts_prcgvr__Activity__c', 'PushTracking__c', 'SMSTracking__c', 'SolTracking__c', 
    'et4ae5__IndividualEmailResult__c', 'Reading__c', 'DocumentSelected__c', 'DocumentalActivity__c', 'DocumentSendTracking__c', 'CommunicationLog__c', 'Asset', 'Case', 'Contract', 
    'OrderItem', 'Order', 'Opportunity', 'BillingProfile__c', 'ServicePoint__c', 'SiebelCommTracking__c', 'SurveyResponse__c', 'ContactPointPhone', 'ContactPointEmail', 'Contact', 'Individual', 
    'Account', 'Interaction__c'};

    private Set<String> objectsThatAreNotArchived = new Set<String>{'CommunicationLog__c', 'BillingProfile__c', 'ServicePoint__c', 'Individual', 'Interaction__c'};

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
    private String queryUsed;
    private String exceptionErr = '';
    private Datetime executionTimeStamp;
    
    public HDT_BA_ArchivedRecordsDelete (Integer batchSize) {

        this.batchScope = batchSize;
        this.currentObjectIndex = 0;
        this.currentObject = objectsToProcess.get(this.currentObjectIndex);

    }

    public HDT_BA_ArchivedRecordsDelete (Integer batchSize, Integer index) {

        this.batchScope = batchSize;
        this.currentObjectIndex = index;
        this.currentObject = objectsToProcess.get(this.currentObjectIndex);
        
    }

    public HDT_BA_ArchivedRecordsDelete (Integer batchSize, Integer index, Integer queryLimit) {

        this.batchScope = batchSize;
        this.currentObjectIndex = index;
        this.queryLimit = queryLimit;
        this.currentObject = objectsToProcess.get(this.currentObjectIndex);
        
    }

    public HDT_BA_ArchivedRecordsDelete (Integer batchSize, Integer index, Boolean relaunchBatch) {

        this.relaunchBatch = relaunchBatch;
        this.batchScope = batchSize;
        this.currentObjectIndex = index;
        this.currentObject = objectsToProcess.get(this.currentObjectIndex);
        
    }

    public HDT_BA_ArchivedRecordsDelete (Integer batchSize, Integer index, Integer queryLimit, Boolean relaunchBatch) {

        this.relaunchBatch = relaunchBatch;
        this.batchScope = batchSize;
        this.currentObjectIndex = index;
        this.queryLimit = queryLimit;
        this.currentObject = objectsToProcess.get(this.currentObjectIndex);
        
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
            when 'BillingProfile__c' {
                queryString += ', (SELECT Id FROM Cases__r), (SELECT Id FROM Casi__r), (SELECT Id FROM Orders__r), (SELECT Id FROM Order_Products__r), (SELECT Id FROM Contracts__r) ';
            }
            when 'CommunicationLog__c' {
                queryString += ', (SELECT Id FROM IndividualEmailResults__r), (SELECT Id FROM PushTracking__r), (SELECT Id FROM SMSTracking__r) ';
            }
            when 'Individual' {
                queryString += ', (SELECT Id FROM Contacts), (SELECT Id FROM Leads) ';
            }
            when 'Interaction__c' {
                queryString += ', (SELECT Id FROM Cases__r), (SELECT Id FROM Orders__r), (SELECT Id FROM Vendite__r), (SELECT Id FROM Activities_Custom__r) ';
            }
            when 'ServicePoint__c' {
                queryString += ', (SELECT Id FROM Cases__r), (SELECT Id FROM Activities_Custom__r) ';
            }
        }

        queryString += ' FROM ' + this.currentObject;

        if (this.currentObject == 'ContentDocument') {
            queryString += ' WHERE LatestPublishedVersion.IsArchived__c = true';
        } else if(this.currentObject == 'Opportunity') {
            queryString += ' WHERE Account.IsArchived__c = true AND StageName = \'Closed Won\'';
        } else if(!this.objectsThatAreNotArchived.contains(this.currentObject)) {
            queryString += ' WHERE IsArchived__c = true';
        }

        if (this.queryLimit > 0) {
            queryString += ' LIMIT ' + this.queryLimit;
        }

        this.queryUsed = queryString;

        System.debug('This is the generated query string' + queryString);

        return Database.getQueryLocator(queryString);

    }


    public void execute (Database.BatchableContext bc, List<SObject> scope) {

        try {

            List<Id> filteredRecordsToDelete = new List<Id>();
            Boolean needsDeletionWithSet = false;

            if (this.executionTimeStamp == null) {
                this.executionTimeStamp = System.now();
            }

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
                    
                    filteredRecordsToDelete.addAll(filterScopeForDeletedChildren(scope, new List<String> {'Cases__r', 'Casi__r', 'Orders__r', 'Order_Products__r', 'Contracts__r'}));
                    needsDeletionWithSet = true;

                }
                when 'CommunicationLog__c' {
                    
                    filteredRecordsToDelete.addAll(filterScopeForDeletedChildren(scope, new List<String> {'IndividualEmailResults__r', 'PushTracking__r', 'SMSTracking__r'}));
                    needsDeletionWithSet = true;

                }
                when 'Individual' {
                    
                    filteredRecordsToDelete.addAll(filterScopeForDeletedChildren(scope, new List<String> {'Contacts', 'Leads'}));
                    needsDeletionWithSet = true;

                }
                when 'Interaction__c' {
                    
                    filteredRecordsToDelete.addAll(filterScopeForDeletedChildren(scope, new List<String> {'Cases__r', 'Orders__r', 'Vendite__r', 'Activities_Custom__r'}));
                    needsDeletionWithSet = true;

                }
                when 'ServicePoint__c' {
                    
                    filteredRecordsToDelete.addAll(filterScopeForDeletedChildren(scope, new List<String> {'Cases__r', 'Activities_Custom__r'}));
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
                        this.exceptionErr += JSON.serializePretty(dr.getErrors());

                        // Stop launch of next batch if there are errors in the delete
                        this.relaunchBatch = false;
                    }

                }

            }

        } catch (Exception e) {

            // Stop launch of next batch if there are errors in execute
            this.relaunchBatch = false;

            this.exceptionErr += e.getMessage() + '\n\n' + e.getStackTraceString();

        }        
        
    }

    public void finish (Database.BatchableContext bc) {

        this.currentObjectIndex ++;
        System.debug('Index is at ' + this.currentObjectIndex);
        
        if (this.relaunchBatch && this.currentObjectIndex < this.objectsToProcess.size()) {
            System.debug('Next object is ' + this.objectsToProcess.get(this.currentObjectIndex));
            Database.executeBatch(new HDT_BA_ArchivedRecordsDelete(this.batchScope, this.currentObjectIndex, this.queryLimit), this.batchScope);
        }

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        mail.setSubject('Deleted ' + this.currentObject);
        mail.setToAddresses(new List<String>{UserInfo.getUserEmail()});
        mail.setOrgWideEmailAddressId([SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'HERA Org Wide Address'].Id);
    
        if (String.isNotBlank(this.exceptionErr)) {
            mail.setPlainTextBody('Execution Timestamp: ' + this.executionTimeStamp + '\n\nQuery used: ' + this.queryUsed + '\n\nthe execution resulted in the following errors: ' + this.exceptionErr);
        } else {
            // mail.setPlainTextBody('Execution Timestamp: ' + this.executionTimeStamp + '\n\nQuery used: ' + this.queryUsed + '\n\nThe following records of type ' + this.currentObject + ' have been deleted:\n' + JSON.serializePretty(this.recordsDeleted));
            mail.setPlainTextBody('Execution Timestamp: ' + this.executionTimeStamp + '\n\nQuery used: ' + this.queryUsed + '\n\nThe records of type ' + this.currentObject + ' have been deleted.');
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
    public List<Id> filterScopeForDeletedChildren(List<SObject> scope, List<String> childrenRelationships) {

        List<Id> result = new List<Id>();

        for (SObject so : scope) {

            Boolean canBeDeleted = true;
            
            for (String rel : childrenRelationships) {

                if (so.getSObjects(rel) != null && !so.getSObjects(rel).isEmpty()) {
                    canBeDeleted = false;
                    break;
                }

            }

            if (canBeDeleted) {
                result.add(so.Id);
            }

        }

        return result;

    }
}