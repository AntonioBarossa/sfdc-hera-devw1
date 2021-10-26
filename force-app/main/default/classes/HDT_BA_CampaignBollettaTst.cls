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
                
                
            List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'MMS','MMS Azienda','Aziende SME');
            Id accId = accs[0].id;
            
            List<Contact> contacts = HDT_UTL_DataFactoryTst.createContact(50,false,accId);
            i=0;
            for(Contact c : contacts){
                c.Email='email@'+i+'.it';
                c.Company__c='MMS';
                i++;
            }
            insert contacts;
            
            
            List<CampaignMember> campMembers = HDT_UTL_DataFactoryTst.createCampaignMember(false,camps[0].id,leads,contacts);
            for(CampaignMember c : campMembers){
                c.ContractReference__c = 'testContractReference';
                c.isWsBollettaInvoked__c = false;
            }
            insert campMembers;

            HDT_UTL_DataFactoryTst.createWebServiceConfiguration('campaignBolletta','https://integration-ts.gruppohera.it/dev/salesforce-api-exp/api/data-management/files','POST','MulesoftSalesforceUser');

        }
    }
    
    @isTest
    static void test1(){
             
        String campaignId = [SELECT id from Campaign where Name='Test Campaign' limit 1].id;     
        List<CampaignMember> listaCMpreBatch = [SELECT id,isWsBollettaInvoked__c from CampaignMember where ContractReference__c = 'testContractReference'];
        for(CampaignMember c : listaCMpreBatch)
            c.isWsBollettaInvoked__c=false;
        update listaCMpreBatch;
        
        Test.startTest();
        HDT_BA_CampaignBolletta cb = new HDT_BA_CampaignBolletta(new List<String>{campaignId}); //Updated method signature
        Id batchId = Database.executeBatch(cb,200);
        Test.stopTest();
        
        List<CampaignMember> listaCM = [SELECT id,isWsBollettaInvoked__c from CampaignMember where ContractReference__c = 'testContractReference' and isWsBollettaInvoked__c = true];              
        
        System.assertEquals(50, listaCM.size(), 'CampaignMembers field isWsBollettaInvoked__c were not set to true by the batch');
        System.assertNotEquals(listaCMpreBatch[0].isWsBollettaInvoked__c, listaCM[0].isWsBollettaInvoked__c ,'CampaignMember field isWsBollettaInvoked__c was not updated by the batch');
    }
}