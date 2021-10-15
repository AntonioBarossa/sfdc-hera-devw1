/**
 * Header of the class "HDT_BA_CommercialCodeTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_BA_CommercialCode"
 * @history
 * @Created 20/09/2021
 * Modified By:
 **/
@isTest
public class HDT_BA_CommercialCodeTst {
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
    
    @TestSetup
    static void makedata(){
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
		internalUser.UserPermissionsMarketingUser=true;

		insert internalUser;

        System.runAs(internalUser){
        	
            
            List<Campaign> camps = HDT_UTL_DataFactoryTst.createCampaign(1, false);
            for(Campaign c : camps){
                c.CodeManagementModel__c ='Porta un amico';
                c.Channel__c = 'Bolletta';
                c.Category__c= 'Campagna Outbound';
                c.CodeGenerationRule__c = 'PrefissoProgressivo';
                c.PrefixCode__c = 'TST';
            }
            insert camps;
            
            
            List<Lead> leads = HDT_UTL_DataFactoryTst.createLead(1,true); 
            
            
            List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'MMS','MMS Azienda','Aziende SME');
            Id accId = accs[0].id;
            
            
            List<Contact> contacts = HDT_UTL_DataFactoryTst.createContact(50,false,accId);
            integer i=0;
            for(Contact c : contacts){
                c.Email='email@'+i+'.it';
                c.Company__c='MMS';
                i++;
            }
            insert contacts;
            
            
            List<CampaignMember> campMembers = HDT_UTL_DataFactoryTst.createCampaignMember(50,false,camps[0].id,leads[0].id,contacts[0].id);
            i=0;
            for(CampaignMember c : campMembers){
                c.contactId = contacts[i].id;
                i++;
            }
            insert campMembers;
        }
    }
    
    @isTest
    static void test1(){
        
        String campaignId = [SELECT id from Campaign].id;
        
        List<String> campaignMembers = new List<String>();
        List <CampaignMember> cm = [SELECT id from CampaignMember];
        for(CampaignMember m : cm)
        	campaignMembers.add(m.id);
                
        CampaignMember  cm1 = [SELECT id,PromoCommercialCode__c from CampaignMember limit 1];
        Map<String,List<String>> allMembers = new Map<String,List<String>>();
        allMembers.put(campaignId, campaignMembers);            
        
        Test.startTest();
		HDT_BA_CommercialCode cc = new HDT_BA_CommercialCode(allMembers);     
        Id batchId = Database.executeBatch(cc,200);
        Test.stopTest();
        
        CampaignMember  cm2 = [SELECT id,PromoCommercialCode__c from CampaignMember limit 1];
        System.assertNotEquals(cm1.PromoCommercialCode__c,cm2.PromoCommercialCode__c,'CampaignMember field PromoCommercialCode__c not updated by the batch'); 
        
        List<CommercialCode__c> commercialCodes = [select id from CommercialCode__c];
    	System.assertEquals(100, commercialCodes.size(), 'The number of CommercialCodes in the system does not double the number of CampaignMembers');
    }
}