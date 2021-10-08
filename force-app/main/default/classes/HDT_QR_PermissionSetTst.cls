/**
* @author Luis Bispo (luis.bispo@engdb.com.br)
* @date 26/07/2021
* @description HDT_QR_PermissionSet for Test Classes
* @history Luis Bispo – 26/07/2021 – Created class
*/
@isTest
public with sharing class HDT_QR_PermissionSetTst {

    private static HDT_UTL_Constants constantsUtl = new HDT_UTL_Constants();
    private static HDT_QR_PermissionSet permissionSetQr = new HDT_QR_PermissionSet();

    @TestSetup
    static void setup(){
        
        User internal = HDT_UTL_DataFactoryTst.createInternalUser(HDT_UTL_DataFactoryTst.getProfileId(constantsUtl.SYSTEM_ADMINISTRATOR_NAME), true);
        
        List<PermissionSetAssignment> permissionAssignments = new List<PermissionSetAssignment>(); 
        permissionAssignments.add(HDT_UTL_DataFactoryTst.assignPermissionSet(internal, constantsUtl.PERMISSIONSET_HDT_SALESFORCE_CPQ_ADMIN_NAME, false));
        permissionAssignments.add(HDT_UTL_DataFactoryTst.assignPermissionSet(internal, constantsUtl.PERMISSIONSET_HDT_SALESFORCE_CPQ_LICENSE_NAME, false));

        insert permissionAssignments;

    }

    @isTest
    public static void testGetPermissionSetAssignment(){
        
        User u = [SELECT Id FROM User WHERE Alias = 'crmuser' LIMIT 1];


        Test.startTest();
            List<PermissionSetAssignment> lstPermSet = permissionSetQr.getPermissionSetAssignment(HDT_UTL_DataFactoryTst.getPermissionSetId(constantsUtl.PERMISSIONSET_HDT_SALESFORCE_CPQ_ADMIN_NAME), u.Id);
        Test.stopTest();
        System.assertEquals(!lstPermSet.isEmpty(), true, 'Permission set assignment not retrieved');
    }

    @isTest
    public static void testGetSetupEntityAccessSucess(){
        Test.startTest();
        SetupEntityAccess setupAccess = permissionSetQr.getSetupEntityAccess('HDT_CP_SuperUserCPQ');
        System.assertEquals(setupAccess != null, true, 'SetupEntityAccess was not extracted');
        System.assertNotEquals(setupAccess == null, true, 'Value of parameter is not matching');
        Test.stopTest();
    }

    @isTest
    public static void testGetSetupEntityAccessFail(){
        Test.startTest();
        SetupEntityAccess setupAccess = permissionSetQr.getSetupEntityAccess('');
        System.assertEquals(setupAccess == null, true, 'SetupEntityAccess should be null');
        System.assertNotEquals(setupAccess != null, true, 'Value of parameter is not matching');
        Test.stopTest();
    }

    @IsTest
    static void testGetPermissionSetAssignmentByName(){
        
        User u = [SELECT Id FROM User WHERE Alias = 'crmuser' LIMIT 1];


        Test.startTest();
            List<PermissionSetAssignment> lstPermSet = permissionSetQr.getPermissionSetAssignmentByName(constantsUtl.PERMISSIONSET_HDT_SALESFORCE_CPQ_ADMIN_NAME, u.Id);
        Test.stopTest();
        System.assertEquals(!lstPermSet.isEmpty(), true, 'Permission set assignment not retrieved (by name)');
        System.assertNotEquals(!lstPermSet.isEmpty(), false, 'Value of parameter is not matching');
        
    }

    @IsTest
    public static void testGetCustomPermissionsByUserId(){

        User u = [SELECT Id FROM User WHERE Alias = 'crmuser' LIMIT 1];
        
        Test.startTest();

        System.runAs(u){

            List<CustomPermission> customPermissions = permissionSetQr.getCustomPermissionsByUserId(u.Id);
            
            System.assertEquals(customPermissions.get(0).DeveloperName, constantsUtl.CUSTOMPERMISSION_NAME_SALESFORCECPQADMIN, 'Wrong Custom Permission assignment');
            System.assertNotEquals(null, constantsUtl.CUSTOMPERMISSION_NAME_SALESFORCECPQADMIN, 'Value of parameter is not matching');
        }

        Test.stopTest();
        
    }

}
