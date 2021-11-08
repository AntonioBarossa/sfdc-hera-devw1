@isTest
public with sharing class HDT_CampaignTst {

    @isTest
    public static void campaignTest() {


        List<Campaign> campTest =   HDT_UTL_DataFactoryTst.createCampaign(1, true);

        
        id campId = campTest[0].id;


       
        system.assertNotEquals('',  campId , 'Campaign is not Empty(Campaign trigger)');
        system.assertEquals(true, campId != null,'Campaign is not Empty(Campaign trigger)' );
  
    }
}