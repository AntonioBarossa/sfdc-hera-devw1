/**
 * @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
 * @date 22/09/2021
 * @description HDT_BA_PraxidiaFront Test Class
 * @history Lucas da Silva Fernandes – 22/09/2021 – Created Class
 */
@isTest
public with sharing class HDT_BA_PraxidiaFrontTst {
    
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

            HDT_UTL_DataFactoryTst.createWebServiceConfiguration('PraxidiaIntegration', 'end', 'method', 'testUser');
            HDT_UTL_DataFactoryTst.createWebServiceCredential('FirstName LastName', '12345', 'usernameTest');
        }
    }
	
	@isTest
    public static void testBatch() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){

            HDT_WS_HTTPServiceCallMock mock = new HDT_WS_HTTPServiceCallMock();
            Test.setMock(HttpCalloutMock.class, mock);

            List<Order> orders = [SELECT Id, CreatedDate FROM Order WHERE Phase__c = 'Bozza'];
            List<Case> cases = [SELECT Id, CreatedDate FROM Case WHERE Phase__c = 'Bozza'];

            Test.setCreatedDate(orders[0].Id, Datetime.now().addDays(-1));
            Test.setCreatedDate(cases[0].Id, Datetime.now().addDays(-1));
 
            Test.startTest();

            orders = [SELECT Id, CreatedDate FROM Order WHERE Phase__c = 'Bozza'];
            cases = [SELECT Id, CreatedDate FROM Case WHERE Phase__c = 'Bozza'];

            List<HDT_WRP_CampaignPraxidia.wrapToIterate> cpList = new List<HDT_WRP_CampaignPraxidia.wrapToIterate>();
            HDT_WRP_CampaignPraxidia.wrapToIterate cp = new HDT_WRP_CampaignPraxidia.wrapToIterate(orders[0], cases[0]);
            cpList.add(cp);

            HDT_BA_PraxidiaFront pf = new HDT_BA_PraxidiaFront('00','24');

            Database.executeBatch(pf);

            Test.stopTest();

            List<ContentVersion> cv = [SELECT Id FROM ContentVersion];

            System.assertEquals(false, cv.isEmpty(), 'Content Version created');
            System.assertNotEquals(true, cv.isEmpty(), 'Content Version not created');
        }
    }	
}
