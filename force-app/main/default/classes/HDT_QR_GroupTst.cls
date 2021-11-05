/**
* @author Luis Bispo (luis.bispo@engdb.com.br)
* @date 26/07/2021
* @description HDT_QR_Group for Test Classes
* @history Luis Bispo – 26/07/2021 – Created class
*/

@isTest
public with sharing class HDT_QR_GroupTst {

    @isTest
    public static void testGetQueueByDevelopername(){

        Test.startTest();
            Group gp = new HDT_QR_Group().getQueueByDevelopername('HDT_QUE_ActivityProtocollo');
            System.assertEquals(gp != null, true, 'value of parameter is matching');
            System.assertNotEquals(gp == null, true, 'value of parameter is not matching');
        Test.stopTest();
    }

    @isTest
    public static void testToGetQueueByDevelopername(){
        List<Group> lstGroup = new List<Group>();
        List<String> lstString = new List<String>();
        Test.startTest();
        lstGroup = new HDT_QR_Group().getQueueByDevelopername(lstString);
        System.assertEquals(lstGroup.size() != null, true, 'value of parameter is matching');
        System.assertNotEquals(lstGroup.size() == null, true, 'value of parameter is not matching');
        Test.stopTest();
    }
}
