/**
 * @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
 * @date 13/09/2021
 * @description HDT_SRV_Quote Test Classes
 * @history Lucas da Silva Fernandes – 13/09/2021 – Created Class
 */
@isTest
public with sharing class HDT_SRV_QuoteTst {
    
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    private static HDT_SRV_Quote srvQuote = new HDT_SRV_Quote();
	
	@TestSetup
    static void setup(){
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
 
        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
 
        internalUser.UserPermissionsMarketingUser=true;
 
        insert internalUser;
 
        System.runAs(internalUser) {

            HDT_UTL_DataFactoryTst.pClickInstance();
            HDT_UTL_DataFactoryTst.pClickOrderPhase();
 
            List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
            List<Sale__c> saleList = HDT_UTL_DataFactoryTst.createSale(1, true, accList[0].Id, 'Bozza');
            List<Order> orderList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].Id, 'Bozza');
            List<Opportunity> oppList = HDT_UTL_DataFactoryTst.createOpportunity(1, true);
            HDT_UTL_DataFactoryTst.createQuote(1, true, orderList[0].Id, oppList[0].Id, saleList[0].Id, 'Amendment');
        }
    }
	
	@isTest
    public static void testCheckReadAccess() {

        Boolean finished = false;
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            srvQuote.checkReadAccess('Agency__c');

            finished = true;
 
            Test.stopTest();

            System.assertEquals(true, finished, 'Test Not Ended');
        }
    }

    @isTest
    public static void testCheckCreateAccess() {

        Boolean finished = false;
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            srvQuote.checkCreateAccess('Agency__c');

            finished = true;
 
            Test.stopTest();

            System.assertEquals(true, finished, 'Test Not Ended');
        }
    }

    @isTest
    public static void testCheckUpdateAccess() {

        Boolean finished = false;
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            srvQuote.checkUpdateAccess('Agency__c');

            finished = true;
 
            Test.stopTest();

            System.assertEquals(true, finished, 'Test Not Ended');
        }
    }

    @isTest
    public static void testCreateRecord() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest(); 

            Order order = [SELECT Id FROM Order WHERE Phase__c = 'Bozza'];
            Opportunity opp = [SELECT Id FROM Opportunity WHERE StageName = 'Negotiation'];
            Sale__c sale = [SELECT Id FROM Sale__c WHERE Status__c = 'Bozza'];

            SBQQ__Quote__c quote = new SBQQ__Quote__c (
                SBQQ__Type__c = 'In Review',
                OrderReference__c = order.Id,
                SBQQ__Opportunity2__c = opp.Id,
                Sale__c = sale.Id
            );

            srvQuote.createRecord(quote);

            List<SBQQ__Quote__c> quoteList = [SELECT Id FROM SBQQ__Quote__c WHERE SBQQ__Type__c = 'In Review'];
 
            Test.stopTest();

            System.assertEquals(false, quoteList.isEmpty(), 'Quote created');
            System.assertNotEquals(true, quoteList.isEmpty(), 'Quote creation failed');
        }
    }

    @isTest
    public static void testDeleteRecord() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            List<SBQQ__Quote__c> quotes = [SELECT Id FROM SBQQ__Quote__c WHERE SBQQ__Type__c = 'Amendment'];

            srvQuote.deleteRecord(quotes[0].Id);

            List<SBQQ__Quote__c> quoteList = [SELECT Id FROM SBQQ__Quote__c WHERE SBQQ__Type__c = 'Amendment'];
 
            Test.stopTest();

            System.assertEquals(true, quoteList.isEmpty(), 'Quote deleted');
            System.assertNotEquals(false, quoteList.isEmpty(), 'Quote deletion failed');
        }
    }

    @isTest
    public static void testDeleteRecords() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            List<SBQQ__Quote__c> quotes = [SELECT Id FROM SBQQ__Quote__c WHERE SBQQ__Type__c = 'Amendment'];

            List<String> ids = new List<String>();

            for (Integer i = 0; i<quotes.size(); i++) {
                String id = quotes[i].Id;
                ids.add(id);
            }

            srvQuote.deleteRecords(ids);

            List<SBQQ__Quote__c> quoteList = [SELECT Id FROM SBQQ__Quote__c WHERE SBQQ__Type__c = 'Amendment'];
 
            Test.stopTest();

            System.assertEquals(true, quoteList.isEmpty(), 'Quote deleted');
            System.assertNotEquals(false, quoteList.isEmpty(), 'Quote deletion failed');
        }
    }

    @isTest
    public static void testUpdateRecord() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            List<SBQQ__Quote__c> quotes = [SELECT Id, SBQQ__Type__c FROM SBQQ__Quote__c WHERE SBQQ__Type__c = 'Amendment'];

            quotes[0].SBQQ__Type__c = 'Quote';

            srvQuote.updateRecord(quotes[0]);

            List<SBQQ__Quote__c> quoteList = [SELECT Id FROM SBQQ__Quote__c WHERE SBQQ__Type__c = 'Quote'];
 
            Test.stopTest();

            System.assertEquals(false, quoteList.isEmpty(), 'Quote updated');
            System.assertNotEquals(true, quoteList.isEmpty(), 'Quote update failed');
        }
    }

    @isTest
    public static void testUpdateRecords() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            List<SBQQ__Quote__c> quotes = [SELECT Id, SBQQ__Type__c FROM SBQQ__Quote__c WHERE SBQQ__Type__c = 'Amendment'];

            quotes[0].SBQQ__Type__c = 'Quote';

            srvQuote.updateRecords(quotes);

            List<SBQQ__Quote__c> quoteList = [SELECT Id FROM SBQQ__Quote__c WHERE SBQQ__Type__c = 'Quote'];
 
            Test.stopTest();

            System.assertEquals(false, quoteList.isEmpty(), 'Quote updated');
            System.assertNotEquals(true, quoteList.isEmpty(), 'Quote update failed');
        }
    }
}
