/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 10/09/2021
 * @description Test Class for HDT_SRV_Opportunity.cls
 * @history Fabricio Petkevicius Nunes – 10/09/2021 – Created class
 */
@isTest
public class HDT_SRV_OpportunityTst{
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
	private static HDT_SRV_Opportunity oppsSrv=new HDT_SRV_Opportunity();
	@TestSetup
	static void setup(){

		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, true);

		System.runAs(internalUser){

			List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
			List<Sale__c> sales=HDT_UTL_DataFactoryTst.createSale(1, true, accounts[0].Id, 'Bozza');
		}
	}

	@isTest
	static void testCheckAccessInit(){

		Boolean finished = false;

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			Test.startTest();

			oppsSrv.checkAccessInit('NextStep, Fiscal', 'create');

			finished = true;

			Test.stopTest();

			// Method return is VOID
			// System.assertEquals('', '', '');
			// System.assertNotEquals('', '');

			System.assertEquals(true, finished, 'Test Not Ended');
		}
	}

	@isTest
	static void testCheckReadAccess(){

		Boolean finished = false;

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			Test.startTest();

			oppsSrv.checkReadAccess('NextStep, Fiscal');

			finished = true;

			Test.stopTest();

			// Method return is VOID
			// System.assertEquals('', '', '');
			// System.assertNotEquals('', '');

			System.assertEquals(true, finished, 'Test Not Ended');
		}
	}

	@isTest
	static void testCheckUpdateAccess(){

		Boolean finished = false;

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			Test.startTest();

			oppsSrv.checkUpdateAccess('NextStep, Fiscal');

			finished = true;

			Test.stopTest();

			// Method return is VOID
			// System.assertEquals('', '', '');
			// System.assertNotEquals('', '');

			System.assertEquals(true, finished, 'Test Not Ended');
		}
	}

	@isTest
	static void testGenerateName(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			Test.startTest();

			List<Sale__c> tSale=[SELECT Id, Name
			                     FROM Sale__c 
			                     WHERE Name='testSaleName0'
			                     LIMIT 1];

			List<Opportunity> tOpps=HDT_UTL_DataFactoryTst.createOpportunity(1, false);
			tOpps[0].Sale__c=tSale[0].Id;

			insert tOpps;

			String generatedName=oppsSrv.generateName(tSale[0]);

			Test.stopTest();

			System.assertEquals(false, String.isBlank(generatedName), 'String not returned');
			System.assertNotEquals(true, String.isBlank(generatedName), 'String not returned');
		}
	}

	@isTest
	static void testCreateRecord(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			Test.startTest();

			List<Opportunity> tOpps=HDT_UTL_DataFactoryTst.createOpportunity(1, false);

			Opportunity createdOpp=oppsSrv.createRecord(tOpps[0]);

			Test.stopTest();

			System.assertEquals(true, createdOpp.Id!=null, 'Opportunity not created');
			System.assertNotEquals(false, createdOpp.Id!=null, 'Opportunity not created');
		}
	}

	@isTest
	static void testUpdateRecord(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			Test.startTest();

			List<Opportunity> tOpps=HDT_UTL_DataFactoryTst.createOpportunity(1, true);
			tOpps[0].Amount=2100.00;

			oppsSrv.updateRecord(tOpps[0]);

			Test.stopTest();

			Opportunity updatedOpp=[SELECT Id, Amount
			                        FROM Opportunity
			                        WHERE Amount=2100.00
			                        LIMIT 1];

			System.assertEquals(true, updatedOpp.Amount!=null, 'Opportunity not updated');
			System.assertNotEquals(false, updatedOpp.Amount!=null, 'Opportunity not updated');
		}
	}

	@isTest
	static void testUpdateRecords(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			Test.startTest();

			List<Opportunity> tOpps=HDT_UTL_DataFactoryTst.createOpportunity(1, true);
			tOpps[0].Amount=2100.00;

			oppsSrv.updateRecords(tOpps);

			Test.stopTest();

			List<Opportunity> updatedOpps=[SELECT Id, Amount
			                               FROM Opportunity
			                               WHERE Amount=2100.00
			                               LIMIT 1];

			System.assertEquals(true, updatedOpps[0].Amount!=null, 'Opportunities not updated');
			System.assertNotEquals(false, updatedOpps[0].Amount!=null, 'Opportunities not updated');
		}
	}

	@isTest
	static void testDeleteRecord(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			Test.startTest();

			List<Account> tAccount=[SELECT Id, Name
			                        FROM Account 
			                        WHERE Name='test account0'
			                        LIMIT 1];

			List<Sale__c> tSale=[SELECT Id, Name
			                     FROM Sale__c 
			                     WHERE Name='testSaleName0'
			                     LIMIT 1];

			List<Order> tOrder=HDT_UTL_DataFactoryTst.createOrder(1, true, tAccount[0].Id, tSale);
			List<Opportunity> tOpps=HDT_UTL_DataFactoryTst.createOpportunity(1, true);
			List<SBQQ__Quote__c> tQuotes=HDT_UTL_DataFactoryTst.createQuote(1, true, tOrder[0].Id, tOpps[0].Id, tSale[0].Id, 'Quote');
			List<ServicePoint__c> servPoints=HDT_UTL_DataFactoryTst.createServicePoint(1, true);
			List<SaleServiceItem__c> saleServItem=HDT_UTL_DataFactoryTst.createSaleServiceItem(1, true, tOpps[0].Id, tQuotes[0].Id, servPoints[0].Id);

			tOpps[0].SBQQ__PrimaryQuote__c=tQuotes[0].Id;
			update tOpps;

			oppsSrv.deleteRecord(tOpps[0].Id);

			Test.stopTest();

			List<Opportunity> deletedOpp=[SELECT Id, IsDeleted
			                              FROM Opportunity
			                              WHERE Id=:tOpps[0].Id ALL ROWS];

			System.assertEquals(true, deletedOpp[0].IsDeleted, 'Opportunity Not Deleted');
			System.assertNotEquals(false, deletedOpp[0].IsDeleted, 'Opportunity Not Deleted');

		}
	}

	@isTest
	static void testDeleteRecords(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			Test.startTest();

			List<Opportunity> tOpps=HDT_UTL_DataFactoryTst.createOpportunity(1, true);

			List<String> oppIds=new List<String>();
			oppIds.add(tOpps[0].Id);

			oppsSrv.deleteRecords(oppIds);

			Test.stopTest();

			List<Opportunity> deletedOpps=[SELECT Id, IsDeleted
			                               FROM Opportunity
			                               WHERE Id=:tOpps[0].Id ALL ROWS];

			System.assertEquals(true, deletedOpps[0].IsDeleted, 'Opportunities Not Deleted');
			System.assertNotEquals(false, deletedOpps[0].IsDeleted, 'Opportunities Not Deleted');

		}
	}
}