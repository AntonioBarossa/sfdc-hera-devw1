@isTest
public with sharing class HDT_LC_ActivityReassignmentToolTst {
    @TestSetup
    private static void makeData() {
        wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c(
            wrts_prcgvr__Status__c = 'Not Started',
            Type__c = 'Sportello'
        );
        insert activity;

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
        PermissionSetAssignment permissionSetAssignment = new PermissionSetAssignment(
            AssigneeId = UserInfo.getUserId(),
            PermissionSetId = permissionSet.Id
        );
        insert permissionSetAssignment;
        HDT_LC_ActivityReassignmentTool.getAssignees('1');
        Test.stopTest();
    }
    
    @isTest
    private static void getWorkGroups() {
        Test.startTest();
        HDT_LC_ActivityReassignmentTool.getWorkGroups('gruppo');
        Test.stopTest();
    }
    @isTest
    private static void assignToMe() {
        Test.startTest();
        wrts_prcgvr__Activity__c activity = [SELECT Id FROM wrts_prcgvr__Activity__c];
        HDT_LC_ActivityReassignmentTool.assignToMe(activity.Id);
        Test.stopTest();
    }
    @isTest
    private static void isDynamicWorkGroup() {
        Test.startTest();
        HDT_LC_ActivityReassignmentTool.isDynamicWorkGroup('loginChannel');
        Test.stopTest();
    }
    // @isTest
    // private static void reassignActivity() {
    //     HDT_LC_ActivityReassignmentTool.reassignActivity(recordId, assigneeId, wrapperId, workGroup, agency);
    // }
}
