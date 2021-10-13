/**
* @author Luis Bispo (luis.bispo@engdb.com.br)
* @date 27/07/2021
* @description HDT_QR_LoginGroupItem for Test Classes
* @history Luis Bispo – 27/07/2021 – Created class
*/

@isTest
public with sharing class HDT_QR_LoginGroupItemTst {

    @isTest
    public static void testGetRecordByLogin(){
        Test.startTest();
        List<LoginGroupItem__c> testLoginGpItem = HDT_QR_LoginGroupItem.getRecordByLogin('Teste');
        System.assertEquals(testLoginGpItem.size() != null, true, 'value of parameter is matching');
        System.assertNotEquals(testLoginGpItem.size() == null, true, 'value of parameter is not matching');
        Test.stopTest();
    }
}
