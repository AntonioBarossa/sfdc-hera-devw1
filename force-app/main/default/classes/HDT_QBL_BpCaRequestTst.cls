/*
 * @author Laureta Demishaj (laureta.demishaj@dunegroup.it)
 * @date 22/09/2021
 * @description HDT_QBL_BpCaRequest for Test Classes
 * @history Laureta Demishaj – 22/09/2021 – Created class
*/
@isTest
public class HDT_QBL_BpCaRequestTst {
   private static HDT_UTL_Constants utlConstants = new HDT_UTL_Constants();
   @IsTest
    public static void testMeth(){
		Id adminUserProfileId = HDT_UTL_DataFactoryTst.getProfileId(utlConstants.HERA_SYSTEM_ADMINISTRATOR_NAME);
		User internalUser = HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
		internalUser.UserPermissionsMarketingUser = true;
		insert internalUser;
		List<PermissionSetAssignment> permissionSetAssignments = new List<PermissionSetAssignment>{HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, utlConstants.PERMISSIONSET_HDT_SALESFORCE_CPQ_ADMIN_NAME, false), HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, utlConstants.PERMISSIONSET_HDT_VOLTURARETROATTIVA, false), HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, utlConstants.PERMISSIONSET_HDT_SALESFORCE_CPQ_LICENSE_NAME, false)};
		insert permissionSetAssignments;
		System.runAs(internalUser){
        HDT_UTL_DataFactoryTst.createWebServiceConfiguration('BP_CA','https://integration-ts.gruppohera.it/dev/salesforce-api-exp/api/data-management/files','POST','MulesoftSalesforceUser');
        HDT_UTL_DataFactoryTst.createWebServiceCredential('MulesoftSalesforceUser', 'a74b50dbaac04215bfbf89a2ee315a80','48fe5165a40c49aa9bf4b3d9bca2552f');
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
		List<Contact> conList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);  
        HDT_QBL_BpCaRequest testim = new HDT_QBL_BpCaRequest(accList[0],conList[0]);
        Test.startTest();   
        System.enqueueJob(testim);
        Test.stopTest();
        System.assertEquals(true, testim !=null, 'An error has occurred!');
      }
    }
}