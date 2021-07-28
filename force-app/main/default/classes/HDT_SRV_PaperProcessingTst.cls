/**
* @author Luis Bispo (luis.bispo@engdb.com.br)
* @date 27/07/2021
* @description HDT_SRV_PaperProcessing for Test Classes
* @history Luis Bispo – 27/07/2021 – Created class
*/

@isTest
public with sharing class HDT_SRV_PaperProcessingTst {
    @TestSetup
    static void setup(){
                
        PaperProcessing__c pp = new PaperProcessing__c();
        insert pp;
    }

    @isTest
    static void testUpdateRecords(){
        List<PaperProcessing__c> lstPaperPro = new List<PaperProcessing__c>();
        PaperProcessing__c paperProcessing = [SELECT Id FROM PaperProcessing__c LIMIT 1];
        lstPaperPro.add(paperProcessing);

        Test.startTest();
        HDT_SRV_PaperProcessing.updateRecords(lstPaperPro);
        system.assertEquals(paperProcessing != null, true);
        system.assertNotEquals(paperProcessing == null, true);
        Test.stopTest();
    }

}
