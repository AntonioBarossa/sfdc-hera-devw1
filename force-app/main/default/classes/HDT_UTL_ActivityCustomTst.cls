/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 17/09/2021
 * @description HDT_UTL_ActivityCustom Test Classes
 * @history Fabricio Petkevicius Nunes – 17/09/2021 – Created class
 */
@isTest
public with sharing class HDT_UTL_ActivityCustomTst{
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();

	@TestSetup
	static void makeData(){

		HDT_UTL_DataFactoryTst.pClickInstance();
		HDT_UTL_DataFactoryTst.pClickCasePhase();
		HDT_UTL_DataFactoryTst.pClickOrderPhase();

		String rtId=constants.CASE_RECORDTYPEID_DOCUMENTALECOPIACONTRATTO;
		String ordRtId=constants.ORDER_RECORDTYPEID_DEFAULT;
		String ordRtDoss=constants.ORDER_RECORDTYPEID_ORDERDOSSIER;
		String actCustDist=constants.ACTIVITYCUSTOM_RECORDTYPEID_DISTRIBUTORAPPOINTMENT;

		HDT_UTL_DataFactoryTst.newPhaseTransition('In Attesa Approvazione', 'Bozza', rtId, 'HDT_RT_DocCopiaContratto');
		HDT_UTL_DataFactoryTst.newPhaseTransition('In Lavorazione', 'Bozza', rtId, 'HDT_RT_DocCopiaContratto');
		HDT_UTL_DataFactoryTst.newPhaseTransition('Registrazione validata  Firmato/Inviato', 'Bozza', ordRtId, 'HDT_RT_Default');
		HDT_UTL_DataFactoryTst.newPhaseTransition('Registrazione validata', 'Bozza', ordRtId, 'HDT_RT_Default');
		HDT_UTL_DataFactoryTst.newPhaseTransition('Documentazione Gestita', 'Bozza', ordRtDoss, 'HDT_RT_OrderDossier');

		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, true);

		System.runAs(internalUser){

			List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(2, false, 'HERA COMM', 'Azienda', 'Aziende SME');
			accounts[1].VATNumber__c='12345678';
			accounts[1].FiscalCode__c='SXSRLA45H28H5';
			insert accounts;

			List<Contact> contacts=HDT_UTL_DataFactoryTst.createContact(1, true, accounts[0].Id);
			List<ServicePoint__c> servPoints=HDT_UTL_DataFactoryTst.createServicePoint(1, true);
			List<Contract> contracts=HDT_UTL_DataFactoryTst.createContract(1, true, accounts[0].Id);
			List<Product2> prods=HDT_UTL_DataFactoryTst.createProduct2(1, true);
			List<Sale__c> sales=HDT_UTL_DataFactoryTst.createSale(2, true, accounts[0].Id, 'Attiva');
			Id pricebookId=Test.getStandardPricebookId();
			List<Order> orderWithPricebook=HDT_UTL_DataFactoryTst.createOrderWithPricebook(2, false, accounts[0].Id, sales, pricebookId);
			orderWithPricebook[1].RecordTypeId=ordRtDoss;
			orderWithPricebook[1].CommercialProduct__c=prods[0].Id;
			orderWithPricebook[0].Contact__c = contacts[0].Id;
			insert orderWithPricebook;
			orderWithPricebook[1].ParentOrder__c = orderWithPricebook[0].Id;
			update orderWithPricebook;
			List<Order> orders=HDT_UTL_DataFactoryTst.createOrder(1, true, accounts[0].Id, 'Bozza');
			List<PricebookEntry> pricebokEntry=HDT_UTL_DataFactoryTst.createPricebookEntry(prods, true, pricebookId);
			List<OrderItem> orderItem=HDT_UTL_DataFactoryTst.createOrderItem(2, false, orderWithPricebook[0].Id, servPoints[0].Id, prods[0].Id, pricebokEntry[0].Id);
			orderItem[1].OrderId=orderWithPricebook[1].Id;
			insert orderItem;

			List<Case> cases=HDT_UTL_DataFactoryTst.createCase(1, false, accounts[0].Id, contacts[0].Id, servPoints[0].Id, contracts[0].Id, orders[0].Id);
			cases[0].RecordTypeId=rtId;
			insert cases;

			List<wrts_prcgvr__Activity__c> activityCustom=HDT_UTL_DataFactoryTst.createActivityCustom(2, false, accounts[0].Id);
			//activityCustom[0].Place__c='testPlace';
			activityCustom[0].Case__c=cases[0].Id;
			activityCustom[0].Order__c=orderWithPricebook[0].Id;
			activityCustom[0].RecordTypeId=actCustDist;

			//activityCustom[1].Place__c='testPlace1';
			activityCustom[1].Case__c=cases[0].Id;
			activityCustom[1].Order__c=orderWithPricebook[1].Id;
			activityCustom[1].RecordTypeId=actCustDist;

			insert activityCustom;
		}
	}

	@isTest
	public static void testRiassegnaComCod(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();

			List<wrts_prcgvr__Activity__c> tActivCust=[SELECT Id, Place__c
			                                           FROM wrts_prcgvr__Activity__c
			                                           WHERE Order__r.RecordType.DeveloperName = 'HDT_RT_Default'];

			Boolean riassegnaComCod=HDT_UTL_ActivityCustom.riassegnaComCod(tActivCust[0].Id, 'Standby per attesa cessazione contratto');

			test.stopTest();

			System.assertEquals(true, riassegnaComCod, 'Return is wrong');
			System.assertNotEquals(false, riassegnaComCod, 'Return is wrong');
		}
	}

	@isTest
	public static void testCambiaphaseComm(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();

			List<wrts_prcgvr__Activity__c> tActivCust=[SELECT Id, Place__c, Case__c, recordtypeid, Account__c
			                                           FROM wrts_prcgvr__Activity__c
			                                           WHERE Order__r.RecordType.DeveloperName = 'HDT_RT_Default'];

			Boolean cambiaPhaseComm=HDT_UTL_ActivityCustom.cambiaphaseComm(tActivCust[0].Id, 'Si');

			test.stopTest();

			System.assertEquals(true, cambiaPhaseComm, 'Return is wrong');
			System.assertNotEquals(false, cambiaPhaseComm, 'Return is wrong');
		}
	}

	@isTest
	public static void testCreateActivityWithParams(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();

			Map<String, String> params=new Map<String, String>();

			params.put('RecordTypeDeveloperName', 'HDT_RT_Default');
			params.put('Type__c', 'Chiamata inbound');
			params.put('ServicePointCode__c', 'testServicePointCode');

			HDT_UTL_ActivityCustom.createActivityWithParams(params);

			params.put('FiscalCode__c', 'SXSRLA45H28H5');
			HDT_UTL_ActivityCustom.createActivityWithParams(params);

			params.put('VATNumber__c', '12345678');
			HDT_UTL_ActivityCustom.createActivityWithParams(params);

			test.stopTest();

			List<wrts_prcgvr__Activity__c> tActivityCustom=[SELECT Id, Type__c
			                                                FROM wrts_prcgvr__Activity__c
			                                                WHERE Type__c='Chiamata inbound'];

			System.assertEquals(true, tActivityCustom[2].Id!=null, 'ActivityCustom not created');
			System.assertNotEquals(false, tActivityCustom[2].Id!=null, 'ActivityCustom not created');
		}
	}

	@isTest
	public static void testValidaActivityVocal(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();

			List<wrts_prcgvr__Activity__c> tActivCust=[SELECT Id, Place__c
			                                           FROM wrts_prcgvr__Activity__c
			                                           WHERE Order__r.RecordType.DeveloperName = 'HDT_RT_Default'];

			Boolean validaActivityVocal=HDT_UTL_ActivityCustom.validaActivityVocal(tActivCust[0].Id, 'Si');

			test.stopTest();

			System.assertEquals(true, validaActivityVocal, 'Return is wrong');
			System.assertNotEquals(false, validaActivityVocal, 'Return is wrong');
		}
	}

	@isTest
	public static void testValidaActivityDocument(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];
		List<wrts_prcgvr__Activity__c> tActivCust=[SELECT Id, Place__c
					FROM wrts_prcgvr__Activity__c
					WHERE Order__r.RecordType.DeveloperName = 'HDT_RT_OrderDossier'];
		String validaActivityDocument=HDT_UTL_ActivityCustom.validaActivityDocument(tActivCust[0].Id, 'Si');
		tActivCust[0].OwnerId = tUser.Id;
		tActivCust[0].ManuallyReassigned__c = true;
		update tActivCust;
		System.runAs(tUser){

			test.startTest();

			

			validaActivityDocument=HDT_UTL_ActivityCustom.validaActivityDocument(tActivCust[0].Id, 'Si');
			HDT_UTL_ActivityCustom.validaActivityDocument(tActivCust[0].Id, 'No');

			test.stopTest();

			System.assertEquals(true, validaActivityDocument!=null, 'Return is wrong');
			System.assertNotEquals(false, validaActivityDocument!=null, 'Return is wrong');
		}
	}

	@isTest
	public static void testisMandatoryComplete(){

		test.startTest();

		List<wrts_prcgvr__Activity__c> activities = [ SELECT Case__r.Id 
														FROM wrts_prcgvr__Activity__c 
														WHERE Case__r.Id != null 
														LIMIT 1 
		];

		Boolean isClose = HDT_UTL_ActivityCustom.isMandatoryComplete( activities[0].Case__r.id );

		System.assertEquals( isClose, false, 'isActivityNotClosed work correctly' );

		test.stopTest();
	
	}
    @isTest
    public static void testRejectActivityDocument(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];
		List<wrts_prcgvr__Activity__c> tActivCust=[SELECT Id, Place__c
					FROM wrts_prcgvr__Activity__c
					WHERE Order__r.RecordType.DeveloperName = 'HDT_RT_OrderDossier'];
		String rejectActivityDocument=HDT_UTL_ActivityCustom.rejectActivityDocument(tActivCust[0].Id, 'Si');
		tActivCust[0].OwnerId = tUser.Id;
		tActivCust[0].ManuallyReassigned__c = true;
		update tActivCust;
		System.runAs(tUser){

			test.startTest();

			rejectActivityDocument=HDT_UTL_ActivityCustom.rejectActivityDocument(tActivCust[0].Id, 'Si');
			HDT_UTL_ActivityCustom.rejectActivityDocument(tActivCust[0].Id, 'No');

			test.stopTest();

			System.assertEquals(true, rejectActivityDocument!=null, 'Return is wrong');
			System.assertNotEquals(false, rejectActivityDocument!=null, 'Return is wrong');
		}
	}

	@isTest
    public static void testPostSurvayWorkActivity(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];
		List<wrts_prcgvr__Activity__c> tActivCust=[SELECT Id, Case__c, Name
					FROM wrts_prcgvr__Activity__c
					WHERE Case__r.Id != null];
		tActivCust[0].Type__c = 'Lavorazione Reclamo Post Survey';
		update tActivCust;
		String message = 'Annullata per apertura attività più recente: ' + tActivCust[0].Name;
		System.runAs(tUser){

			test.startTest();
				insert new wrts_prcgvr__Activity__c(Type__c = 'Lavorazione Reclamo Post Survey', Case__c = tActivCust[0].Case__c,wrts_prcgvr__Status__c = 'Aperta');
			test.stopTest();
			tActivCust = [SELECT id,ClosingNote__c FROM wrts_prcgvr__Activity__c WHERE wrts_prcgvr__Status__c != 'Annullata' AND Type__c = 'Lavorazione Reclamo Post Survey'];
			System.assertEquals(1, tActivCust.size(), 'Return is wrong');
			tActivCust = [SELECT id,ClosingNote__c FROM wrts_prcgvr__Activity__c WHERE wrts_prcgvr__Status__c = 'Annullata' AND Type__c = 'Lavorazione Reclamo Post Survey'];
			System.assertEquals(message, tActivCust[0].ClosingNote__c, 'Return is wrong');
		}
	}

    
    
    
    
}