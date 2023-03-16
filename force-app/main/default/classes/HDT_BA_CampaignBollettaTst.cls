/**
 * Header of the class "HDT_BA_CampaignBollettaTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_BA_CampaignBolletta"
 * @history
 * @Created 20/09/2021
 * Modified By:
 **/
@isTest
public class HDT_BA_CampaignBollettaTst {
    private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
	@TestSetup
    static void makedata(){
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
		internalUser.UserPermissionsMarketingUser=true;

		insert internalUser;

        System.runAs(internalUser){
        
            integer i;
            List<Campaign> camps = HDT_UTL_DataFactoryTst.createCampaign(50, false);
            for(Campaign c : camps){
                c.Category__c= 'Campagna Outbound';
                c.Channel__c = 'Bolletta';
            }
            insert camps;
            
            
            List<Lead> leads = HDT_UTL_DataFactoryTst.createLead(50,true); 
                
                
            List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'MMS','G3 - MMS Azienda','Aziende SME');
            Id accId = accs[0].id;
            
            List<Contact> contacts = HDT_UTL_DataFactoryTst.createContact(50,false,accId);
            i=0;
            for(Contact c : contacts){
                c.Email='email@'+i+'.it';
                c.Company__c='MMS';
                i++;
            }
            insert contacts;

            List<CommercialCode__c> CommCodes = HDT_UTL_DataFactoryTst.createCommCode(50, true);
            
            
            List<CampaignMember> campMembers = HDT_UTL_DataFactoryTst.createCampaignMember(false,camps[0].id,leads,contacts);
            i = 0;
            for(CampaignMember c : campMembers){
                c.ContractReference__c = 'testContractReference';
                c.isWsBollettaInvoked__c = false;
                c.PromoCommercialCode__c = CommCodes[i].Id;
                i++;
            }
            insert campMembers;

            HDT_UTL_DataFactoryTst.createWebServiceConfiguration('campaignBolletta','https://integration-ts.gruppohera.it/dev/salesforce-api-exp/api/data-management/files','POST','MulesoftSalesforceUser');

        }
    }
    
    @isTest
    static void test(){
        CampaignMember cmBefore = [SELECT id,isWsBollettaInvoked__c from CampaignMember WHERE isWsBollettaInvoked__c = FALSE LIMIT 1];
        
        Test.startTest();
        HDT_BA_CampaignBolletta cb = new HDT_BA_CampaignBolletta(); //Updated method signature
        Database.executeBatch(cb);
        Test.stopTest();
        
        CampaignMember cmAfter = [SELECT id,isWsBollettaInvoked__c from CampaignMember where id = :cmBefore.Id];
        System.assertNotEquals(cmBefore.isWsBollettaInvoked__c,cmAfter.isWsBollettaInvoked__c,'CampaignMember field isWsBollettaInvoked__c not updated by the batch'); 
    }
}