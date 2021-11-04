/**
* @author Luis Bispo (luis.bispo@engdb.com.br)
* @date 27/07/2021
* @description HDT_QR_PaperProcessing for Test Classes
* @history Luis Bispo – 27/07/2021 – Created class
*/
@isTest
public with sharing class HDT_QR_PaperProcessingTst {


    @TestSetup
    static void setup(){
        List<Campaign> campTestList = HDT_UTL_DataFactoryTst.createCampaign(1, true);
        HDT_UTL_DataFactoryTst.createPaperProcessing(1, true, 'testPaperProcessing', campTestList[0].Id);
    }
    

    @isTest
    public static void testGetParameterForName(){
        List<String> lstString = new List<String>();
        PaperProcessing__c paperProcessing = [SELECT Id FROM PaperProcessing__c LIMIT 1];
        lstString.add(paperProcessing.Id);
        Test.startTest();

        PaperProcessing__c testPaper = HDT_QR_PaperProcessing.getParameterForName(lstString);
        system.assertEquals(testPaper != null, true, 'Value of parameter is matching');
        system.assertNotEquals(testPaper == null, true, 'Value of parameter is not matching');
        Test.stopTest();
    }


}
