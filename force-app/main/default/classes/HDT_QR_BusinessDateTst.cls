/**
* @author Luis Bispo (luis.bispo@engdb.com.br)
* @date 22/07/2021
* @description HDT_QR_BusinessDate for Test Classes
* @history Luis Bispo – 22/07/2021 – Created class
*/

@isTest
public with sharing class HDT_QR_BusinessDateTst {


    @isTest
    public static void testGetWorkingBusinessDateConfSuccess(){
        Test.startTest();
        String testBd = HDT_QR_BusinessDate.getWorkingBusinessDateConf();
        System.assert(testBd == null);
		System.assertNotEquals('BusinessHours', testBd,'value of parameter is not matching');
        Test.stopTest();    
    }

}
