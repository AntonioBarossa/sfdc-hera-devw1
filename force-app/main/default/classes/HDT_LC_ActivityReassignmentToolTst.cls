/**
 * @author Lorenzo Rollo (lorenzo.rollo@everis.com)
 * @date 07/09/2021
 * @description HDT_LC_ActivityReassignmentTool test class
 * @history Name – Date – Description
 */

@isTest
public with sharing class HDT_LC_ActivityReassignmentToolTst {

    private static HDT_UTL_Constants constantsUtl = new HDT_UTL_Constants();

    @TestSetup
    private static void makeData() {
        User currentUser = [SELECT UserCompany__c FROM User WHERE Id =: UserInfo.getUserId()];

        System.runAs(currentUser) {

            HDT_UTL_DataFactoryTst.pClickInstance();
            List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');

            List<Order> order = HDT_UTL_DataFactoryTst.createOrder(1, false, accList[0].Id, 'Bozza');
            order[0].Agency__c = 'MATCH SRL';
            insert order;

            List<wrts_prcgvr__Activity__c> activity = HDT_UTL_DataFactoryTst.createActivityCustom(2, false, accList[0].Id);
            activity[0].wrts_prcgvr__Status__c = 'Aperta';
            activity[0].Type__c = 'Sportello';
            activity[0].Order__c = order[0].Id;
            insert activity[0];
            activity[1].wrts_prcgvr__Status__c = 'Aperta';
            activity[1].Type__c = 'Gestione Agenzia';
            activity[1].ParentActivity__c = activity[0].Id;
            insert activity[1];

            Queue__c queue = new Queue__c(
                Name = 'coda1',
                WorkGroup__c = Schema.getGlobalDescribe().get('Queue__c').getDescribe().fields.getMap().get('WorkGroup__c').getDescribe().getPicklistValues()[0].getValue(),
                Agency2__c = Schema.getGlobalDescribe().get('Queue__c').getDescribe().fields.getMap().get('Agency2__c').getDescribe().getPicklistValues()[0].getValue()
            );

            insert queue;

            Queue__c queueSecond = new Queue__c(
                Name = 'FirstName 1',
                Group__c = 'gruppo1',
                Agency__c = 'agenzia1',
                WorkGroup__c = 'HC_CDO_OM',
                Agency2__c = 'Hera Comm'
            );
            insert queueSecond;

        }

        String omniPermission = 'HDT_OmniSupervisor';
        String omniPermissionId = HDT_UTL_DataFactoryTst.getPermissionSetId(omniPermission);
        List<PermissionSetAssignment> psAssigment = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSetId = :omniPermissionId AND AssigneeId = :currentUser.Id];

        if(psAssigment.isEmpty())
        {
            HDT_UTL_DataFactoryTst.assignPermissionSet(currentUser, 'HDT_OmniSupervisor', true);
        }

        Id profileId = HDT_UTL_DataFactoryTst.getProfileId(constantsUtl.HERA_STANDARD_USER_NAME);
        User user = HDT_UTL_DataFactoryTst.createInternalUser(profileId, false);
        user.LastName = '1';
        user.UserCompany__c = currentUser.UserCompany__c;
        insert user;
    }

    @isTest
    private static void getAssignees() {
        Test.startTest();

        PermissionSet permissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'HDT_OmniSupervisor'];
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
        returnedValue = HDT_LC_ActivityReassignmentTool.getAssignees('FirstName 1');
        System.assertEquals('FirstName 1', returnedValue[0].get('name'), 'USER NON TROVATO');

        Test.stopTest();
    }

    @isTest
    private static void getWorkGroups() {
        Test.startTest();

        Queue__c queue = [SELECT Id, Agency2__c, WorkGroup__c FROM Queue__c LIMIT 1];
        List<Map<String,String>> returnedValue = HDT_LC_ActivityReassignmentTool.getWorkGroups(queue.WorkGroup__c);
        System.assertEquals(queue.WorkGroup__c, returnedValue[0].get('name'), 'NOME GRUPPO DI LAVORO ERRATO');
        System.assertEquals(queue.Agency2__c, returnedValue[0].get('agency'), 'AGENZIA GRUPPO DI LAVORO ERRATA');

        Test.stopTest();
    }

    @isTest
    private static void assignToMe() {
        Test.startTest();

        wrts_prcgvr__Activity__c activity = [SELECT Id FROM wrts_prcgvr__Activity__c LIMIT 1];
        String returnedValue = HDT_LC_ActivityReassignmentTool.assignToMe(new List<String>{activity.Id});
        System.assertEquals(null, returnedValue, 'ERRORE: ' + returnedValue);

        Test.stopTest();
    }

    @isTest
    private static void isDynamicWorkGroup() {
        Test.startTest();

        Boolean returnedValue = HDT_LC_ActivityReassignmentTool.isDynamicWorkGroup('Protocollo');

        System.assertEquals(true, returnedValue, 'Workgroup is Dynamic');

        Test.stopTest();
    }

    @isTest
    private static void reassignActivity() {
        Test.startTest();

        Queue__c queue = [SELECT Id FROM Queue__c LIMIT 1];
        User user = [SELECT Id FROM User WHERE Name = 'FirstName 1'];
        wrts_prcgvr__Activity__c activity = [SELECT Id FROM wrts_prcgvr__Activity__c WHERE ParentActivity__c != null LIMIT 1];
        
        String result1 = HDT_LC_ActivityReassignmentTool.reassignActivity(new List<String>{activity.Id}, user.Id, queue.Id, 'workGroup', 'agency');

        System.assertEquals(true, String.isNotBlank(result1), 'String was not supposed to be empty');
        
        String result2 = HDT_LC_ActivityReassignmentTool.reassignActivity(new List<String>{activity.Id}, user.Id, queue.Id, 'workGroup', 'MATCH SRL');

        System.assertEquals(true, String.isBlank(result2), 'String was supposed to be empty');

        Test.stopTest();
    }

    @isTest
    private static void refreshPage() {
        Test.startTest();

        wrts_prcgvr__Activity__c activity = [SELECT Id FROM wrts_prcgvr__Activity__c LIMIT 1];
        Boolean returnedValue = HDT_LC_ActivityReassignmentTool.refreshPage(activity.Id);
        System.assertEquals(false, returnedValue, 'ERRORE: ' + returnedValue);

        Test.stopTest();
    }
}