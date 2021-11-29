@isTest
public with sharing class HDT_BA_ActivityDispatcherTst {
    @TestSetup
    private static void makeData() {
        HDT_UTL_DataFactoryTst.pClickInstance();
        insert new Group(Name = 'testnamegroup1');
    }

    @isTest
    private static void executeBatch() {
        Group gr = [SELECT Id FROM Group LIMIT 1];
        Queue__c queue = new Queue__c(
            Agency__c = 'ag1',
            Name = 'coda1',
            Group__c = 'gr1',
            QueueId__c = gr.Id,
            Priority__c = '1',
            Type__c = 'PUSH'
        );
        insert queue;
        wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c(
            wrts_prcgvr__Status__c = 'Aperta',
            Type__c = 'Sportello',
            wrts_prcgvr__Priority__c = '1'
        );
        insert activity;
        AssignmentRule__c rule = new AssignmentRule__c(
            Name = 'rule1',
            Type__c = 'Sportello',
            RulePriority__c = 40,
            HighPriorityQueue__c = queue.Id,
            LowPriorityQueue__c = queue.Id,
            MediumPriorityQueue__c = queue.Id
        );
        insert rule;
        
        //TESTING
        Test.startTest();
        Database.executeBatch(new HDT_BA_ActivityDispatcher());
        Test.stopTest();
        
        //RETRIEVING DATA
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob];
        
        //ASSERTS
        System.assertEquals(0, a.NumberOfErrors, 'Batch fallito.');
        
    }
}
