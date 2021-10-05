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
        List<Account> accountList= HDT_UTL_DataFactoryTst.createAccountResidenziale(1,true,'HERA COMM','Persona fisica','Famiglie');
        Profile p = [SELECT Id FROM Profile WHERE Name LIKE '%Community%' LIMIT 1];
		User tUser=HDT_UTL_DataFactoryTst.createCommunityUser(new Contact(), p.Id, true);

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

     User user=[SELECT  id FROM User WHERE Email = 'commuser@test.com'];

     system.runAs(user){
        HDT_UTL_HelperMethods help= new HDT_UTL_HelperMethods();
        Boolean check = help.checkCommunityLogin();

        System.assertEquals(true, check,'returns true because the current user is community');

        System.assertNotEquals(false, check,' because the current user is not crm');
     }     
   }


   @isTest
    static void testIsSuperUser() {

        HDT_UTL_HelperMethods help= new HDT_UTL_HelperMethods();
        Boolean check = help.isSuperUser();

        System.assertEquals(false, check,'because there is no PermissionSetAssignment that has this user id and HDT_SuperUserCPQ permissions');
        System.assertNotEquals(true, check,'because the returned PermissionSetAssignment list is empty ');
    
   }



}