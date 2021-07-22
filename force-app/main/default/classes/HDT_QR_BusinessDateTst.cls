
@isTest
public with sharing class HDT_QR_BusinessDateTst {


    @isTest
    public static void testGetWorkingBusinessDateConfSuccess(){
        Test.startTest();
        String testBd = HDT_QR_BusinessDate.getWorkingBusinessDateConf();
        System.assert(testBd == null);
		System.assertNotEquals('BusinessHours', testBd);
        Test.stopTest();    
    }

}
