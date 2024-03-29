@isTest
public with sharing class HDT_BA_ActivityDispatcherTst {
    @TestSetup
    private static void makeData() {
        HDT_UTL_DataFactoryTst.pClickInstance();
        insert new Group(Name = 'testnamegroup2');

        Group gr = [SELECT Id FROM Group LIMIT 1];
        Queue__c queue = new Queue__c(
            Name = 'coda1',
            WorkGroup__c = Schema.getGlobalDescribe().get('Queue__c').getDescribe().fields.getMap().get('WorkGroup__c').getDescribe().getPicklistValues()[0].getValue(),
            Agency2__c = Schema.getGlobalDescribe().get('Queue__c').getDescribe().fields.getMap().get('Agency2__c').getDescribe().getPicklistValues()[0].getValue(),
            QueueId__c = gr.Id,
            Priority__c = '1 - Alta',
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
    }

    @isTest
    private static void executeBatch() {

        //TESTING
        Test.startTest();
        System.schedule('testjob', '0 0 1 ? * *', new HDT_SCH_ActivityDispatcherScheduler());
        Test.stopTest();
        
        //RETRIEVING DATA
        List<AsyncApexJob> a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob];
        
        //ASSERTS
        System.assertEquals(0, a[0].NumberOfErrors, 'Schedulable fallito.');
        System.assertEquals(0, a[1].NumberOfErrors, 'Batch fallito.');
        
    }
}
