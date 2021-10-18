@isTest
public with sharing class HDT_LC_ActivityReassignmentToolTst {
    @TestSetup
    private static void makeData() {
        HDT_UTL_DataFactoryTst.pClickInstance();
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');

        List<Order> order = HDT_UTL_DataFactoryTst.createOrder(1, false, accList[0].Id, 'Bozza');
        order[0].Agency__c = 'MATCH SRL';
        insert order;

        List<wrts_prcgvr__Activity__c> activity = HDT_UTL_DataFactoryTst.createActivityCustom(2, false, accList[0].Id);
        activity[0].wrts_prcgvr__Status__c = 'Not Started';
        activity[0].Type__c = 'Sportello';
        activity[0].Order__c = order[0].Id;
        insert activity[0];
        activity[1].wrts_prcgvr__Status__c = 'Not Started';
        activity[1].Type__c = 'Gestione Agenzia';
        activity[1].ParentActivity__c = activity[0].Id;
        insert activity[1];

        Queue__c queue = new Queue__c(
            Name = 'coda1',
            Group__c = 'gruppo1',
            Agency__c = 'agenzia1'
        );
        insert queue;

        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Hera Standard User'];
        User user = HDT_UTL_DataFactoryTst.createInternalUser(profile.Id, false);
        user.LastName = '1';
        insert user;
    }

    @isTest
    private static void getAssignees() {
        Test.startTest();

        PermissionSet permissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'HDT_OmniSupervisorPermissionSet'];
        AggregateResult count = [SELECT COUNT(Id) FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSetId = :permissionSet.Id];
        if(count.get('expr0') == '0') {
            PermissionSetAssignment permissionSetAssignment = new PermissionSetAssignment(
                AssigneeId = UserInfo.getUserId(),
                PermissionSetId = permissionSet.Id
            );
            insert permissionSetAssignment;
        }
        List<Map<String,String>> returnedValue = HDT_LC_ActivityReassignmentTool.getAssignees('coda1');
        System.assertEquals('coda1', returnedValue[0].get('name'), 'CODA NON TROVATA');
        returnedValue = HDT_LC_ActivityReassignmentTool.getAssignees('FirstName');
        System.assertEquals('FirstName 1', returnedValue[0].get('name'), 'USER NON TROVATO');

        Test.stopTest();
    }

    @isTest
    private static void getWorkGroups() {
        Test.startTest();

        List<Map<String,String>> returnedValue = HDT_LC_ActivityReassignmentTool.getWorkGroups('gruppo');
        System.assertEquals('gruppo1', returnedValue[0].get('name'), 'NOME GRUPPO DI LAVORO ERRATO');
        System.assertEquals('agenzia1', returnedValue[0].get('agency'), 'AGENZIA GRUPPO DI LAVORO ERRATA');

        Test.stopTest();
    }

    @isTest
    private static void assignToMe() {
        Test.startTest();

        wrts_prcgvr__Activity__c activity = [SELECT Id FROM wrts_prcgvr__Activity__c LIMIT 1];
        String returnedValue = HDT_LC_ActivityReassignmentTool.assignToMe(activity.Id);
        System.assertEquals(null, returnedValue, 'ERRORE: ' + returnedValue);

        Test.stopTest();
    }

    @isTest
    private static void isDynamicWorkGroup() {
        Test.startTest();

        Boolean returnedValue = HDT_LC_ActivityReassignmentTool.isDynamicWorkGroup('loginChannel');

        Test.stopTest();
    }

    @isTest
    private static void reassignActivity() {
        Test.startTest();

        Queue__c queue = [SELECT Id FROM Queue__c];
        User user = [SELECT Id FROM User WHERE Name = 'FirstName 1'];
        wrts_prcgvr__Activity__c activity = [SELECT Id FROM wrts_prcgvr__Activity__c WHERE ParentActivity__c != null LIMIT 1];
        HDT_LC_ActivityReassignmentTool.reassignActivity(activity.Id, user.Id, queue.Id, 'workGroup', 'agency');
        
        HDT_LC_ActivityReassignmentTool.reassignActivity(activity.Id, user.Id, queue.Id, 'workGroup', 'MATCH SRL');

        Test.stopTest();
    }
}