/**
* @author Luis Bispo (luis.bispo@engdb.com.br)
* @date 29/07/2021
* @description HDT_UTL_CampaignMember for Test Classes
* @history Luis Bispo – 29/07/2021 – Created class
*/

@isTest
public with sharing class HDT_UTL_CampaignMemberTst {
    
    @TestSetup
    static void setup(){
        List<Campaign> cp = HDT_UTL_DataFactoryTst.createCampaign(2, true);
    }
    
    @isTest
    public static void testCreateCampaignMemberStatus(){

        List<Campaign> lstCampaign = [SELECT Id, Status From Campaign LIMIT 2];
        lstCampaign[0].Status = 'Bozza';
        lstCampaign[1].Status = 'Pianificata';
        update lstCampaign;

        Test.startTest();
        HDT_UTL_CampaignMember.createCampaignMemberStatus(lstCampaign, lstCampaign);

        System.assert(lstCampaign != null);
        System.assertNotEquals(null, lstCampaign);
        Test.stopTest();
    }
}
