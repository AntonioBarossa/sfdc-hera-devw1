/**
 * @author Valere (valere@noeli-it.net)
 * @date 19/10/2021
 * @description HDT_BA_DeactivateCampaign Test Classes
 * @history valere - 19/10/2021– Created Class
 */
@istest
public class HDT_BA_DeactivateCampaignTst {
    @TestSetup
    static void makeData(){
        HDT_UTL_DataFactoryTst.createWebServiceConfiguration ('arrestocampaign', 'https://integration-ts.gruppohera.it/dev/salesforce-api-exp/api/data-enrichment/entities', 'POST', 'HerokuUser');
        HDT_UTL_DataFactoryTst.createWebServiceCredential ('arrestocampaign' , 'heroku-hera-dev-2021!', 'dev-heroku');
    }
    @IsTest
    static void testexecute(){
        List<Campaign> campaignList= HDT_UTL_DataFactoryTst.createCampaign(3, true);
        List<Id> listIdCampaign = new List<Id>();
        listIdCampaign.add(campaignList[0].id);
        listIdCampaign.add(campaignList[1].id);
        listIdCampaign.add(campaignList[2].id);
        
        Test.setMock(HttpCalloutMock.class, new HDT_BA_DeactivateCampaignMck());
        Test.startTest();
        HDT_BA_DeactivateCampaign thisCampaign = new HDT_BA_DeactivateCampaign(listIdCampaign);
        DataBase.executeBatch(thisCampaign); 
        Test.stopTest();
        System.debug('JSON.serialize(thisCampaign) '+JSON.serialize(thisCampaign));
        System.assertEquals(true,JSON.serialize(thisCampaign).contains(campaignList[0].id),'HDT_BA_DeactivateCampaign has been well instantiated will the value passed');
    }
}