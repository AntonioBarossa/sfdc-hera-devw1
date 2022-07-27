/**
 * Header of the class "HDT_BA_InvioNumerazioniTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_BA_InvioNumerazioni"
 **/
@isTest
public class HDT_BA_InvioNumerazioniTst {
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
                c.ReitekIntegrationTechnology__c = 'Web Service';
            }
            insert camps;
            
            
            List<Lead> leads = HDT_UTL_DataFactoryTst.createLead(50,true);
            leads[0].ContactDate__c = Datetime.now();
            update leads[0];
                
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
            
            
            List<CampaignMember> campMembers = HDT_UTL_DataFactoryTst.createCampaignMember(true,camps[0].id,leads,contacts);

            HDT_UTL_DataFactoryTst.createWebServiceConfiguration('InvioNumerazioni','https://integration-ts.gruppohera.it/dev/salesforce-api-exp/api/data-management/files','POST','MulesoftSalesforceUser');

        }
    }
    
    @isTest
    static void test(){
        CampaignMember cmBefore = [SELECT id,ReitekSendDate__c from CampaignMember limit 1];
        
        Test.startTest();
        HDT_BA_InvioNumerazioni cb = new HDT_BA_InvioNumerazioni(); //Updated method signature
        Database.executeBatch(cb);
        Test.stopTest();
        
        CampaignMember cmAfter = [SELECT id,ReitekSendDate__c from CampaignMember limit 1];
        System.assertNotEquals(cmBefore.ReitekSendDate__c,cmAfter.ReitekSendDate__c,'CampaignMember field ReitekSendDate__c not updated by the batch'); 
    }
}