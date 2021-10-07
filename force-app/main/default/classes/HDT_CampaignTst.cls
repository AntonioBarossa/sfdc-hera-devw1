@isTest
public with sharing class HDT_CampaignTst {

    @isTest
    public static void HDT_CampaignTst() {


        List<Campaign> campTest =   HDT_UTL_DataFactoryTst.createCampaign(1, true);

        
        Campaign camp = [SELECT id FROM Campaign WHERE id =: campTest[0].id ];


       
        system.assertNotEquals('',  camp.id , 'Campaign is not Empty(Campaign trigger)');
        system.assertEquals(true, camp.id != null,'Campaign is not Empty(Campaign trigger)' );
  
    }
}