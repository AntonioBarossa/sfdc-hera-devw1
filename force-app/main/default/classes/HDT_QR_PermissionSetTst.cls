/**
* @author Luis Bispo (luis.bispo@engdb.com.br)
* @date 26/07/2021
* @description HDT_QR_PermissionSet for Test Classes
* @history Luis Bispo – 26/07/2021 – Created class
*/
@isTest
public with sharing class HDT_QR_PermissionSetTst {

    @isTest
    public static void testGetPermissionSetAssignment(){
        Test.startTest();
            List<PermissionSetAssignment> lstPermSet = new HDT_QR_PermissionSet().getPermissionSetAssignment('Test','Test');
        Test.stopTest();
        System.assertEquals(lstPermSet.size() != null, true, 'The List is null!');
        System.assertNotEquals(lstPermSet.size() == null, true);
    }

    @isTest
    public static void testGetSetupEntityAccessSucess(){
        Test.startTest();
        SetupEntityAccess setupAccess = new HDT_QR_PermissionSet().getSetupEntityAccess('HDT_CP_SuperUserCPQ');
        System.assertEquals(setupAccess != null, true, 'The List is null!');
        System.assertNotEquals(setupAccess == null, true);
        Test.stopTest();
    }

    @isTest
    public static void testGetSetupEntityAccessFail(){
        Test.startTest();
        SetupEntityAccess setupAccess = new HDT_QR_PermissionSet().getSetupEntityAccess('');
        System.assertEquals(setupAccess == null, true, 'The List is not null!');
        System.assertNotEquals(setupAccess != null, true);
        Test.stopTest();
    }
}
