/**
 * @author Valere (valere@noeli-it.net)
 * @date 23/09/2021
 * @description HDT_UTL_HelperMethods Test Class
 * @history valere - 23/09/2021– Created Class
 */
@isTest
private class HDT_UTL_HelperMethodsTst {
    private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
    @testSetup 
    static void setup() {
        User admin = HDT_UTL_DataFactoryTst.createInternalUser( HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME), false);
        admin.UserRoleId = HDT_UTL_DataFactoryTst.getUserRoleId(constants.USERROLE_DEVELOPERNAME_BACKOFFICE);
        insert admin;
        List<PermissionSetAssignment> permissionSetAssignments=new List<PermissionSetAssignment>{HDT_UTL_DataFactoryTst.assignPermissionSet(admin, constants.PERMISSIONSET_HDT_SUPER_USER_CPQ, false)};
		insert permissionSetAssignments;

        System.runAs(admin) {
            List<Account> accountList= HDT_UTL_DataFactoryTst.createAccountResidenziale(1,true,'HERA COMM','Persona fisica','Famiglie');
            List<Contact> contacts = HDT_UTL_DataFactoryTst.createContact(1, true, accountList[0].Id);
            HDT_UTL_DataFactoryTst.createCommunityUser(contacts[0], HDT_UTL_DataFactoryTst.getProfileId(constants.HERA_DOOR2DOOR_PARTNER_NAME), true);
        }

    }
    
    @isTest
     static void testGetObjAttrList() {

        List<Account> accountList=[SELECT id,CompanyOwner__c,CustomerMarking__c,Category__C
                                   FROM Account];
        HDT_UTL_HelperMethods help= new HDT_UTL_HelperMethods();
        List<String> fields = help.getObjAttrList(accountList[0]);

        System.assertEquals(3, fields.size(),'returns 3 because the account only has 3 fields different from id and attributes');

        System.assertNotEquals(1, fields.size(),' because the account has more than one field different from id and attributes');

    }

    @isTest
    static void testCheckCommunityLogin() {

     User user=[SELECT id FROM User Limit 1];

     system.runAs(user){
        HDT_UTL_HelperMethods help= new HDT_UTL_HelperMethods();
        Boolean check = help.checkCommunityLogin();

        System.assertEquals(true, check,'returns true because the current user is community');

        System.assertNotEquals(false, check,' because the current user is not crm');
     }     
   }


   @isTest
    static void testIsSuperUser() {

        List<User> userTest = [SELECT Id, Email, IsActive FROM User WHERE email = 'commuser@test.com'];

        System.runAs(userTest[0]) {
            HDT_UTL_HelperMethods help= new HDT_UTL_HelperMethods();
            Boolean check = help.isSuperUser();
            System.assertEquals(false, check,'because there is no PermissionSetAssignment that has this user id and HDT_SuperUserCPQ permissions');
            System.assertNotEquals(true, check,'because the returned PermissionSetAssignment list is empty ');
        }
   }



}