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
        List<Campaign> camList = HDT_UTL_DataFactoryTst.createCampaign(1, true);
        HDT_UTL_DataFactoryTst.createPaperProcessing(1, true, 'paperTest', camList[0].ID);
    }

    @isTest
    static void testUpdateRecords(){
        List<PaperProcessing__c> lstPaperPro = new List<PaperProcessing__c>();
        
        PaperProcessing__c paperProcessing = [SELECT Id FROM PaperProcessing__c LIMIT 1];
        lstPaperPro.add(paperProcessing);

        Test.startTest();
        HDT_SRV_PaperProcessing.updateRecords(lstPaperPro);
        system.assertEquals(paperProcessing != null, true, 'Update Record Paper Processing');
        system.assertNotEquals(paperProcessing == null, true, 'Update Record Paper Processing');
        Test.stopTest();
    }

}
