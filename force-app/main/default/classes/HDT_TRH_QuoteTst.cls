/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 09/09/2021
 * @description HDT_TRH_Quote Test Classes
 * @history Fabricio Petkevicius Nunes – 09/09/2021 – Created class
 */
@isTest
public with sharing class HDT_TRH_QuoteTst{
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
	@TestSetup
	static void makeData(){
		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, true);

		System.runAs(internalUser){
			List<Account> accs=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
			HDT_UTL_DataFactoryTst.createOrder(1, true, accs[0].Id, 'Bozza');
			HDT_UTL_DataFactoryTst.createOpportunity(1, true);
			HDT_UTL_DataFactoryTst.createSale(1, true, accs[0].Id, 'Bozza');
		}
	}

	@isTest
	public static void testQuoteBeforeAfterInsert(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			Test.startTest();

			List<Order> tOrder=[SELECT Id, Phase__c
			                    FROM Order
			                    WHERE Phase__c='Bozza'];

			List<Opportunity> tOpp=[SELECT Id, Name
			                        FROM Opportunity 
			                        WHERE Name='testOpportunity0'];

			List<Sale__c> tSale=[SELECT Id, Status__c
			                     FROM Sale__c
			                     WHERE Status__c='Bozza'];

			List<SBQQ__Quote__c> quotes=HDT_UTL_DataFactoryTst.createQuote(1, false, tOrder[0].Id, tOpp[0].Id, tSale[0].Id, 'Amendment');
			quotes[0].UseCategory__c='test';
			insert quotes;

			Test.stopTest();

			List<SBQQ__Quote__c> createdQuote=[SELECT Id, Name
			                                   FROM SBQQ__Quote__c 
			                                   WHERE UseCategory__c='test'
			                                   LIMIT 1];

			System.assertEquals(true, createdQuote[0].Id!=null, 'Quote Not Created');
			System.assertNotEquals(false, createdQuote[0].Id!=null, 'Quote Not Created');
		}
	}

	@isTest
	public static void testQuoteBeforeAfterUpdate(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			Test.startTest();

			List<Order> tOrder=[SELECT Id, Phase__c
			                    FROM Order
			                    WHERE Phase__c='Bozza'];

			List<Opportunity> tOpp=[SELECT Id, Name
			                        FROM Opportunity 
			                        WHERE Name='testOpportunity0'];

			List<Sale__c> tSale=[SELECT Id, Status__c
			                     FROM Sale__c
			                     WHERE Status__c='Bozza'];

			List<SBQQ__Quote__c> quotes=HDT_UTL_DataFactoryTst.createQuote(1, true, tOrder[0].Id, tOpp[0].Id, tSale[0].Id, 'Amendment');
			quotes[0].UseCategory__c='test';
			update quotes;

			Test.stopTest();

			List<SBQQ__Quote__c> updatedQuote=[SELECT Id, Name, UseCategory__c
			                                   FROM SBQQ__Quote__c
			                                   WHERE UseCategory__c='test'
			                                   LIMIT 1];

			System.assertEquals('test', updatedQuote[0].UseCategory__c, 'Quote Not Updated');
			System.assertNotEquals('', updatedQuote[0].UseCategory__c, 'Quote Not Updated');
		}
	}

	@isTest
	public static void testQuoteBeforeAfterDelete(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			Test.startTest();

			List<Order> tOrder=[SELECT Id, Phase__c
			                    FROM Order
			                    WHERE Phase__c='Bozza'];

			List<Opportunity> tOpp=[SELECT Id, Name
			                        FROM Opportunity 
			                        WHERE Name='testOpportunity0'];

			List<Sale__c> tSale=[SELECT Id, Status__c
			                     FROM Sale__c
			                     WHERE Status__c='Bozza'];

			List<SBQQ__Quote__c> quotes=HDT_UTL_DataFactoryTst.createQuote(1, false, tOrder[0].Id, tOpp[0].Id, tSale[0].Id, 'Amendment');
			quotes[0].UseCategory__c='test';
			insert quotes;

			List<SBQQ__Quote__c> createdQuote=[SELECT Id, Name, IsDeleted
			                                   FROM SBQQ__Quote__c
			                                   WHERE UseCategory__c='test'
			                                   LIMIT 1];

			delete createdQuote;

			Test.stopTest();

			List<SBQQ__Quote__c> deletedQuote=[SELECT Id, IsDeleted
			                                   FROM SBQQ__Quote__c
			                                   WHERE Id=:createdQuote[0].Id ALL ROWS];

			System.assertEquals(true, deletedQuote[0].IsDeleted, 'Quote Not Deleted');
			System.assertNotEquals(false, deletedQuote[0].IsDeleted, 'Quote Not Deleted');
		}
	}
}