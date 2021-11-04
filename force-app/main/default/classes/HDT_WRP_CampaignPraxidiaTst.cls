/**
 * @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
 * @date 22/09/2021
 * @description HDT_WRP_CampaignPraxidia Test Class
 * @history Lucas da Silva Fernandes – 22/09/2021 – Created Class
 */
@isTest
public with sharing class HDT_WRP_CampaignPraxidiaTst {
    
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
	
	@TestSetup
    static void setup(){
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
 
        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
 
        internalUser.UserPermissionsMarketingUser=true;
 
        insert internalUser;

        System.runAs(internalUser) {
 
            List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
            List<Order> orderList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].Id, 'Bozza');
            List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
            List<ServicePoint__c> spList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
            List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].Id);
            HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].Id, contactList[0].Id, spList[0].Id, contractList[0].Id, orderList[0].Id);
        }
    }

    @isTest
    public static void testCreateCampaignPraxidia() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();
            List<Order> orders = [SELECT Id FROM Order WHERE Phase__c = 'Bozza'];
            List<Case> cases = [SELECT Id FROM Case WHERE Phase__c = 'Bozza'];
            
            HDT_WRP_CampaignPraxidia cp = new HDT_WRP_CampaignPraxidia();
            HDT_WRP_CampaignPraxidia.front cpFront = new HDT_WRP_CampaignPraxidia.front();
            HDT_WRP_CampaignPraxidia.reclami cpReclami = new HDT_WRP_CampaignPraxidia.reclami();
            HDT_WRP_CampaignPraxidia.wrapToIterate cpWrapPopulated = new HDT_WRP_CampaignPraxidia.wrapToIterate(orders[0], cases[0]);

            System.assertEquals(orders[0], cpWrapPopulated.o, 'HDT_WRP_CampaignPraxidia did not work correctly');
            System.assertNotEquals(null, cp, 'HDT_WRP_CampaignPraxidia did not work correctly');
            System.assertNotEquals(null, cpFront, 'HDT_WRP_CampaignPraxidia did not work correctly');
            System.assertNotEquals(null, cpReclami, 'HDT_WRP_CampaignPraxidia did not work correctly');

            Test.stopTest();
        }
    }
}
