
@isTest
public with sharing class HDT_BA_QueueAssignmentTst {
    
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();

    @testSetup
    static void setup(){

        String userRoleIdAdmin = HDT_UTL_DataFactoryTst.getUserRoleId(Constants.USERROLE_DEVELOPERNAME_BACKOFFICE);

        String userProfileId = HDT_UTL_DataFactoryTst.getProfileId(Constants.HERA_DOOR2DOOR_PARTNER_NAME);


        Id adminUserProfileId = HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);

        User internalUser = HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
        internalUser.UserRoleId = userRoleIdAdmin;

        internalUser.UserPermissionsMarketingUser=true;

        insert internalUser;

        System.runAs(internalUser) {


        List<Account> listAcct = HDT_UTL_DataFactoryTst.createAccountBusiness(1, false, 'HERA COMM', 'Azienda', 'Aziende SME');
        insert listAcct;

        List<Contact> con = HDT_UTL_DataFactoryTst.createContact(1, true, listAcct[0].id );
        
  
        HDT_UTL_DataFactoryTst.createCommunityUser(con[0], userProfileId , true);
        

        }

    }

    @isTest
    public static void testQueueAssignment() {
        
        List<Account> acct = [SELECT id,Name FROM Account  ];

        test.startTest();
        HDT_BA_QueueAssignment hbq = new HDT_BA_QueueAssignment(acct);
        Database.executeBatch(hbq);
        test.stopTest();

        List<Group> q = [SELECT id,Name FROM Group WHERE Name = 'HDT_QUE_TestAccount0'];

        System.assertEquals(false, q.isEmpty() , 'Group quesry is null' );
        System.assertNotEquals('', q[0].Name , 'Group query Name is Empty');
    }
}
