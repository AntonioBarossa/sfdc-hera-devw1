/**
 * Header of the class "HDT_WS_InvioNumerazioniTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_WS_InvioNumerazioni"
 * @history
 * @Created 27/09/2021
 * Modified By:
 **/

@isTest
public class HDT_WS_InvioNumerazioniTst {
    
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
    
    @TestSetup
    static void makedata(){
                
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
		internalUser.UserPermissionsMarketingUser=true;

        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountDistributore(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(2, true, accList[0].Id);
        List<Lead> leadList = HDT_UTL_DataFactoryTst.createLead(1, true);
        List<Campaign> campaignList = HDT_UTL_DataFactoryTst.createCampaign(1, true);
        List<CampaignMember> campaignMemberList = HDT_UTL_DataFactoryTst.createCampaignMember(true, campaignList[0].Id, leadList, contactList);

        insert internalUser;

        System.runAs(internalUser){
            
            HDT_UTL_DataFactoryTst.createWebServiceConfiguration('InvioNumerazioni','https://integration-ts.gruppohera.it/dev/salesforce-api-exp/api/data-management/files','POST','MulesoftSalesforceUser');
                        
        }
    }

    @IsTest
    static void test1(){

        String macroactivity = 'macro';
        String phonenumber = 'phone';
        String cmId = [Select id from CampaignMember LIMIT 1].Id;
        
        test.startTest();
        
        HDT_WS_Response res = HDT_WS_InvioNumerazioni.callService(macroactivity,phonenumber, cmId);
        
        test.stopTest();
        
        System.assertNotEquals(null, res, 'A response was not created');        
        System.assertEquals(null, res.body, 'The respose fields should be set to null since the mock is not instantiated');        
    }
    
}