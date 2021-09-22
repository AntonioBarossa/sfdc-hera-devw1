/**
 * @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
 * @date 22/09/2021
 * @description HDT_BA_RecurringCampaingCreation Test Class
 * @history Lucas da Silva Fernandes – 22/09/2021 – Created Class
 */
@isTest
public with sharing class HDT_BA_RecurringCampaingCreationTst {
    
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
	
	@TestSetup
    static void setup(){
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
 
        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
 
        internalUser.UserPermissionsMarketingUser=true;
 
        insert internalUser;
 
        System.runAs(internalUser) {
 
            List<Campaign> cmpList = HDT_UTL_DataFactoryTst.createCampaign(2, true);
            cmpList[0].Status = 'Pianificata';
            cmpList[0].RecurringCampaign__c = true;
            cmpList[0].DateNextGeneration__c = Date.today();
            cmpList[0].EndDate = Date.today().addDays(10);
            cmpList[0].StartDate = Date.today();
            cmpList[1].Status = 'Bozza';
            cmpList[1].EndDate = Date.today();
            cmpList[1].DateNextGeneration__c = Date.today();
            cmpList[1].StartDate = Date.today();
            cmpList[1].ParentId = cmpList[0].Id;
            update cmpList;
        }
    }
	
	@isTest
    public static void testBatch() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            HDT_BA_RecurringCampaingCreation rcc = new HDT_BA_RecurringCampaingCreation();

            Database.executeBatch(rcc);
 
            Test.stopTest();

            List<Campaign> cmpList = [SELECT Id FROM Campaign WHERE DateNextGeneration__c = null];

            System.assertEquals(false, cmpList.isEmpty(), 'Campaign updated.');
            System.assertNotEquals(true, cmpList.isEmpty(), 'Campaign update failed');
        }
    }
}
