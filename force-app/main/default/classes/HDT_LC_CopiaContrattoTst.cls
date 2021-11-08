/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 21/09/2021
 * @description HDT_LC_CopiaContratto Test Classes
 * @history Fabricio Petkevicius Nunes – 21/09/2021 – Created class
 */
@isTest
public with sharing class HDT_LC_CopiaContrattoTst{
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
	@TestSetup
	static void makeData(){

		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, true);

		System.runAs(internalUser){

			HDT_UTL_DataFactoryTst.pClickInstance();
			HDT_UTL_DataFactoryTst.pClickCasePhase();
			HDT_UTL_DataFactoryTst.pClickOrderPhase();
			String caseId=constants.CASE_RECORDTYPEID_MOROSITA;
			String orderId = constants.ORDER_RECORDTYPEID_DEFAULT;
			HDT_UTL_DataFactoryTst.newPhaseTransition('In Lavorazione', 'Bozza', caseId, 'HDT_RT_Morosita');
			HDT_UTL_DataFactoryTst.newPhaseTransition('Completata', 'In Lavorazione', caseId, 'HDT_RT_Morosita');
			HDT_UTL_DataFactoryTst.newPhaseTransition('n Lavorazione', 'Bozza', orderId, 'HDT_RT_Default');

			List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
			List<Individual> individuals=HDT_UTL_DataFactoryTst.createIndividual(1, true);
			List<Contact> contacts=HDT_UTL_DataFactoryTst.createContact(1, false, accounts[0].Id);
			contacts[0].IndividualId=individuals[0].Id;
			insert contacts;
			List<Lead> leads=HDT_UTL_DataFactoryTst.createLead(1, false);
			leads[0].IndividualId=individuals[0].Id;
			insert leads;
			List<ServicePoint__c> servPoints=HDT_UTL_DataFactoryTst.createServicePoint(1, true);
			List<Sale__c> sales=HDT_UTL_DataFactoryTst.createSale(1, true, accounts[0].Id, 'Attiva');
			List<Contract> contracts=HDT_UTL_DataFactoryTst.createContract(1, true, accounts[0].Id);
			List<Order> orders=HDT_UTL_DataFactoryTst.createOrder(1, true, accounts[0].Id, 'Bozza');
			HDT_UTL_DataFactoryTst.createChildOrder(1, true, accounts[0].Id, sales, orders[0].Id, contacts[0].Id);
			List<Case> cases=HDT_UTL_DataFactoryTst.createCase(1, false, accounts[0].Id, contacts[0].Id, servPoints[0].Id, contracts[0].Id, orders[0].Id);
			cases[0].Channel__c='testChannel';
			insert cases;
			List<Opportunity> opps=HDT_UTL_DataFactoryTst.createOpportunity(1, true);
			List<ContentVersion> contentVersion=HDT_UTL_DataFactoryTst.createContentVers(1, true);
			Id contentDocumentId=[SELECT ContentDocumentId
			                      FROM ContentVersion
			                      WHERE Id=:contentVersion[0].Id].ContentDocumentId;
			List<ContentDocumentLink> contDocLinks=HDT_UTL_DataFactoryTst.createContentDocumentLink(1, false, opps[0].Id, contentDocumentId);
			contDocLinks[0].LinkedEntityId=cases[0].Id;
			insert contDocLinks;
			List<wrts_prcgvr__Activity__c> activityCustom=HDT_UTL_DataFactoryTst.createActivityCustom(1, false, accounts[0].Id);
			activityCustom[0].Case__c=cases[0].Id;
			activityCustom[0].Documentation__c='testDoc';
			insert activityCustom;
		}
	}

	@isTest
	public static void testGetAccountOrder(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();

			List<Account> tAccount=[SELECT Id, Name
			                        FROM Account
			                        WHERE Name='test account0'
			                        LIMIT 1];

			List<Order> tOrder=[SELECT Id, Name
			                        FROM Order
			                        WHERE Name='testOrderName0'
			                        LIMIT 1];

			tOrder[0].Status = 'In Lavorazione';
			update tOrder;
			List<Order> getAccOrder=HDT_LC_CopiaContratto.getAccountOrder(tAccount[0].Id, 'Copia contratto firmato');
			HDT_LC_CopiaContratto.getAccountOrder(tAccount[0].Id, 'Copia contratto non firmato');
			HDT_LC_CopiaContratto.getAccountOrder(tAccount[0].Id, 'Copia della registrazione');

			test.stopTest();

			System.assertEquals(false, getAccOrder.isEmpty(), 'Order returned');
			System.assertNotEquals(true, getAccOrder.isEmpty(), 'getAccountOrder did not work correctly');
		}
	}

	@isTest
	public static void testGetOrderChild(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();

			List<Order> tOrder=[SELECT Id, Name
			                    FROM Order
			                    WHERE Name='testOrderName0'
			                    LIMIT 1];

			List<Order> getOrderChild=HDT_LC_CopiaContratto.getOrderChild(tOrder[0].Id);

			test.stopTest();

			System.assertEquals(false, getOrderChild.isEmpty(), 'Order not returned');
			System.assertNotEquals(true, getOrderChild.isEmpty(), 'getOrderChild did not work correctly');
		}
	}

	@isTest
	public static void testConfirmAction(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();

			List<Account> tAccount=[SELECT Id, Name
			                        FROM Account
			                        WHERE Name='test account0'
			                        LIMIT 1];

			List<Case> tCase=[SELECT Id, HerokuPracticeCode__c
			                  FROM Case
			                  WHERE HerokuPracticeCode__c='21313232132132'
			                  LIMIT 1];

			List<Order> tOrder=[SELECT Id, Name
			                    FROM Order
			                    WHERE Name='testOrderName0'
			                    LIMIT 1];

			string confirmAction=HDT_LC_CopiaContratto.confirmAction(tCase[0], tAccount[0].Id, tOrder[0].Id, 'testChannel', 'Copia della registrazione', 'E-Mail');
			HDT_LC_CopiaContratto.confirmAction(tCase[0], tAccount[0].Id, tOrder[0].Id, 'testChannel', 'Copia contratto non firmato', 'E-Mail');

			HDT_UTL_DataFactoryTst.createDocumentSendTracking(1, tOrder[0].Id, tCase[0].Id);
			HDT_LC_CopiaContratto.confirmAction(tCase[0], tAccount[0].Id, tOrder[0].Id, 'Inbound', 'Copia contratto non firmato', 'Posta Cartacea');

			test.stopTest();

			System.assertEquals('Invio registrazione', confirmAction, 'return is wrong');
			System.assertNotEquals('', confirmAction, 'confirmAction did not work correctly');
		}
	}

	@isTest
	public static void testConfirmActionDraft(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();

			List<Account> tAccount=[SELECT Id, Name
			                        FROM Account
			                        WHERE Name='test account0'
			                        LIMIT 1];

			List<Case> tCase=[SELECT Id, HerokuPracticeCode__c
			                  FROM Case
			                  WHERE HerokuPracticeCode__c='21313232132132'
			                  LIMIT 1];

			List<Order> tOrder=[SELECT Id, Name
			                    FROM Order
			                    WHERE Name='testOrderName0'
			                    LIMIT 1];

			HDT_LC_CopiaContratto.confirmActionDraft(tCase[0], tAccount[0].Id, tOrder[0].Id, 'testChannel', 'Copia della registrazione', 'E-Mail');

			test.stopTest();

			Case updatedCase=[SELECT Id, Channel__c
			                  FROM Case
			                  WHERE Channel__c='testChannel'
			                  LIMIT 1];

			System.assertEquals(true, updatedCase!=null, 'Case not updated');
			System.assertNotEquals(false, updatedCase!=null, 'confirmActionDraft did not work correctly');
		}
	}

	@isTest
	public static void testChiudiAttivit(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();

			List<wrts_prcgvr__Activity__c> tActCust=[SELECT Id, Documentation__c
			                                         FROM wrts_prcgvr__Activity__c
			                                         WHERE Documentation__c='testDoc'
			                                         LIMIT 1];

			Boolean chiudiAttivit=HDT_LC_CopiaContratto.chiudiAttivit(tActCust[0].Id);

			test.stopTest();

			System.assertEquals(true, chiudiAttivit, 'Case or ActivityCustom not updated');
			System.assertNotEquals(false, chiudiAttivit, 'chiudiAttivit did not work correctly');
		}
	}

    @isTest
	public static void testChiudiAttivitNoCase(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();

			List<wrts_prcgvr__Activity__c> tActCust=[SELECT Id, Documentation__c
			                                         FROM wrts_prcgvr__Activity__c
			                                         WHERE Documentation__c='testDoc'
			                                         LIMIT 1];

			Boolean chiudiAttivitNoCase=HDT_LC_CopiaContratto.chiudiAttivitNoCase(tActCust[0].Id);

			test.stopTest();

			System.assertEquals(true, chiudiAttivitNoCase, 'ActivityCustom not updated');
			System.assertNotEquals(false, chiudiAttivitNoCase, 'chiudiAttivitNoCase did not work correctly');
		}
	}
}