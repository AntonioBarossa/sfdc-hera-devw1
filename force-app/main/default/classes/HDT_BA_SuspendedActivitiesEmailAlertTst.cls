
@isTest
public with sharing class HDT_BA_SuspendedActivitiesEmailAlertTst {

    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();

    @testSetup
    static void setup(){

        HDT_UTL_DataFactoryTst.pClickInstanceActivityIntegration();

        Id adminUserProfileId = HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);

        User internalUser = HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);

        internalUser.UserPermissionsMarketingUser=true;

        insert internalUser;

        System.runAs(internalUser) {

        List<Account> testAcc =  HDT_UTL_DataFactoryTst.createAccountPartner(1, false , 'testact');
        testAcc[0].CompanyOwner__c  = 'HERA COMM';
        insert testAcc;

        id acctId = [SELECT id FROM Account WHERE id =: testAcc[0].id ].Id;
        
        List<wrts_prcgvr__Activity__c> testActivity = HDT_UTL_DataFactoryTst.createActivityCustom(1,true,acctId);
        testActivity[0].SuspensionDueDate__c = system.now().addMinutes(30);
        testActivity[0].Status__c = 'Sospesa'; 
        testActivity[0].RecordTypeDevName__c  = 'HDT_RT_Scarto';
        update testActivity;         
         
        }
    }

    @isTest
    public static void testSuspendedActivityEmailAlert() {

        test.startTest();
        HDT_BA_SuspendedActivitiesEmailAlert sae = new HDT_BA_SuspendedActivitiesEmailAlert();
        Database.executeBatch(sae);
        test.stopTest();

        wrts_prcgvr__Activity__c q = [SELECT id, Name, ownerid  FROM  wrts_prcgvr__Activity__c WHERE Status__c = 'Sospesa' LIMIT 1];
        id userName = q.ownerid;
        List<User> users = [SELECT id,Name,Email FROM User WHERE id =: userName ];

        system.assertEquals(false, users.isEmpty(), 'List of  users with ownerId of wrts_prcgvr__Activity__c is Empty ');
        system.assertNotEquals('', users[0].id , 'List of  users with ownerId of wrts_prcgvr__Activity__c is Empty' );

    }
    
}
