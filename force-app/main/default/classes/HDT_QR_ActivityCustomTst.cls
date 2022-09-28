/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 05/08/2021
 * @description HDT_QR_ActivityCustom for Test Classes
 * @history Luis Bispo – 05/08/2021 – Created class
 */
@isTest
public with sharing class HDT_QR_ActivityCustomTst{
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
	@TestSetup
	static void setup(){

		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);

		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);

		internalUser.UserPermissionsMarketingUser=true;
		internalUser.Title='srTest';

		insert internalUser;

		List<PermissionSetAssignment> permissionSetAssignments=new List<PermissionSetAssignment>{HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, constants.PERMISSIONSET_HDT_SALESFORCE_CPQ_ADMIN_NAME, false), HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, constants.PERMISSIONSET_HDT_SALESFORCE_CPQ_LICENSE_NAME, false)};

		insert permissionSetAssignments;

		System.runAs(internalUser){

			HDT_UTL_DataFactoryTst.pClickInstance();
			HDT_UTL_DataFactoryTst.pClickOrderPhase();

			List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
			List<ServicePoint__c> servpoints=HDT_UTL_DataFactoryTst.createServicePoint(1, true);
			List<Contact> contacts=HDT_UTL_DataFactoryTst.createContact(1, true, accounts[0].Id);
			List<Contract> contracts=HDT_UTL_DataFactoryTst.createContract(1, true, accounts[0].Id);
			List<Order> orders=HDT_UTL_DataFactoryTst.createOrder(1, true, accounts[0].Id, 'Bozza');
			List<Case> cases=HDT_UTL_DataFactoryTst.createCase(1, true, accounts[0].Id, contacts[0].Id, servpoints[0].Id, contracts[0].Id, orders[0].Id);
			List<Opportunity> opps=HDT_UTL_DataFactoryTst.createOpportunity(1, true);
			List<Sale__c> sales=HDT_UTL_DataFactoryTst.createSale(1, true, accounts[0].Id, 'Attiva');
			List<BillingProfile__c> billProfs=HDT_UTL_DataFactoryTst.createBillingProfile(1, true, accounts[0].Id);
			List<Product2> products=HDT_UTL_DataFactoryTst.createProduct2(1, true);
			List<SBQQ__Quote__c> quotes=HDT_UTL_DataFactoryTst.createQuote(1, true, orders[0].Id, opps[0].Id, sales[0].Id, 'Amendment');
			List<SBQQ__QuoteLine__c> quoteLines=HDT_UTL_DataFactoryTst.createQuoteLines(products[0].Id, quotes[0].Id, 1, false);
			quoteLines[0].ServicePoint__c=servpoints[0].Id;
			quoteLines[0].SupplyCity__c='test city';
			quoteLines[0].BillingProfile__c=billProfs[0].Id;
			quoteLines[0].Agency__c=accounts[0].Id;
			quoteLines[0].OwnerAC__c='Si';
			insert quoteLines;

			List<wrts_prcgvr__Activity__c> actCustoms=HDT_UTL_DataFactoryTst.createActivityCustom(2, false, accounts[0].Id);
			actCustoms[0].ServicePoint__c=servpoints[0].Id;
			actCustoms[0].wrts_prcgvr__Status__c='Creata';
			actCustoms[0].Type__c='Approvazione Quote';
			actCustoms[0].ServicePointCode__c='test';
			actCustoms[0].Order__c=orders[0].Id;
			actCustoms[0].Approved__c='Si';
			actCustoms[0].Case__c=cases[0].Id;
			actCustoms[0].QuoteLine__c=quoteLines[0].Id;
			actCustoms[0].OwnerId=internalUser.Id;
			actCustoms[0].wrts_prcgvr__IsClosed__c = true;

			actCustoms[1].Account__c=accounts[0].Id;
			actCustoms[1].ServicePoint__c=servpoints[0].Id;
			actCustoms[1].wrts_prcgvr__Status__c='Aperta';
			actCustoms[1].Type__c='Approvazione Quote';
			actCustoms[1].ServicePointCode__c='test 2';
			actCustoms[1].Order__c=orders[0].Id;
			actCustoms[1].Approved__c='Si';
			actCustoms[1].Case__c=cases[0].Id;
			actCustoms[1].QuoteLine__c=quoteLines[0].Id;
			actCustoms[1].OwnerId=internalUser.Id;
			actCustoms[1].ParentActivity__c=actCustoms[0].Id;
			actCustoms[1].wrts_prcgvr__IsClosed__c = true;

			insert actCustoms;
		}
	}

	@isTest
	public static void testgetRecordByTypeAndStatusAndAccountAndServicePoint(){
		Test.startTest();

		Account tAcc=[SELECT Id, CompanyOwner__c
		              FROM Account
		              WHERE CompanyOwner__c='HERA COMM'
		              LIMIT 1];


		List<wrts_prcgvr__Activity__c> tActivity=HDT_QR_ActivityCustom.getRecordByTypeAndStatusAndAccountAndServicePoint('Approvazione Quote', 'Creata', tAcc.Id, 'test');
		System.debug('tActivity = '+tActivity);

		System.assertEquals('Creata', tActivity[0].wrts_prcgvr__Status__c, 'query return is wrong');
		System.assertNotEquals('', tActivity[0].wrts_prcgvr__Status__c, 'getRecordByTypeAndStatusAndAccountAndServicePoint did not work correctly');

		Test.stopTest();
	}

	@isTest
	public static void testgetRecordById(){
		Test.startTest();

		wrts_prcgvr__Activity__c tActivityCust=[SELECT Id, wrts_prcgvr__Status__c
		                                        FROM wrts_prcgvr__Activity__c
		                                        WHERE wrts_prcgvr__Status__c='Creata'
		                                        LIMIT 1];

		List<wrts_prcgvr__Activity__c> tActivity=HDT_QR_ActivityCustom.getRecordById(tActivityCust.Id);
		System.debug('tActivity = '+tActivity);

		System.assertEquals('Creata', tActivity[0].wrts_prcgvr__Status__c, 'query return is wrong');
		System.assertNotEquals('', tActivity[0].wrts_prcgvr__Status__c, 'getRecordById did not work correctly');

		Test.stopTest();
	}

	@isTest
	public static void testgetRecordByIds(){
		Test.startTest();

		List<wrts_prcgvr__Activity__c> tActivityCust=[SELECT Id, wrts_prcgvr__Status__c
		                                              FROM wrts_prcgvr__Activity__c
		                                              WHERE wrts_prcgvr__Status__c='Creata'
		                                              LIMIT 1];

		wrts_prcgvr__Activity__c tActivity=HDT_QR_ActivityCustom.getRecordByIds(tActivityCust[0].Id);
		System.debug('tActivity = '+tActivity);

		System.assertEquals('Creata', tActivity.wrts_prcgvr__Status__c, 'query return is wrong');
		System.assertNotEquals('', tActivity.wrts_prcgvr__Status__c, 'getRecordByIds- did not work correctly');

		Test.stopTest();
	}

	@isTest
	public static void testgetRecordByCaseId(){
		Test.startTest();

		List<Case> tCase=[SELECT Id, Subject
		                  FROM Case
		                  WHERE Subject='test'
		                  LIMIT 1];

		List<wrts_prcgvr__Activity__c> tActivity=HDT_QR_ActivityCustom.getRecordByCaseId(tCase[0].Id);
		System.debug('tActivity = '+tActivity);

		System.assertEquals('Si', tActivity[0].Approved__c, 'query return is wrong');
		System.assertNotEquals('', tActivity[0].Approved__c, 'getRecordByCaseId did not work correctly');

		Test.stopTest();
	}

	@isTest
	public static void testgetRecordByCaseIdList(){
		Test.startTest();

		List<Case> tCase=[SELECT Id, Subject
		                  FROM Case
		                  WHERE Subject='test'
		                  LIMIT 1];

		List<String> caseIds=new List<String>();
		caseIds.add(tCase[0].Id);

		List<wrts_prcgvr__Activity__c> tActivity=HDT_QR_ActivityCustom.getRecordByCaseIdList(caseIds);
		System.debug('tActivity = '+tActivity);

		System.assertEquals('Si', tActivity[0].Approved__c, 'query return is wrong');
		System.assertNotEquals('', tActivity[0].Approved__c, 'getRecordByCaseIdList did not work correctly');

		Test.stopTest();
	}

	@isTest
	public static void testgetRecordByOrderLine(){
		Test.startTest();

		List<SBQQ__QuoteLine__c> tQuoteLine=[SELECT Id, SupplyCity__c
		                                     FROM SBQQ__QuoteLine__c
		                                     WHERE SupplyCity__c='test city'
		                                     LIMIT 1];

		List<String> quoteLineIds=new List<String>();
		quoteLineIds.add(tQuoteLine[0].Id);

		List<wrts_prcgvr__Activity__c> tActivity=HDT_QR_ActivityCustom.getRecordByOrderLine(quoteLineIds);
		System.debug('tActivity = '+tActivity);

		System.assertEquals('Si', tActivity[0].Approved__c, 'query return is wrong');
		System.assertNotEquals('', tActivity[0].Approved__c, 'getRecordByOrderLine did not work correctly');

		Test.stopTest();
	}

	@isTest
	public static void testgetRecordByOwnerId(){
		Test.startTest();

		List<User> tUser=[SELECT Id, FirstName
		                  FROM User
		                  WHERE FirstName='FirstName' AND Email='crmuser@test.com'
		                  LIMIT 1];

		List<String> userIds=new List<String>();
		userIds.add(tUser[0].Id);

		List<wrts_prcgvr__Activity__c> tActivity=HDT_QR_ActivityCustom.getRecordByOwnerId(userIds);
		System.debug('tActivity = '+tActivity);

		System.assertEquals('Si', tActivity[0].Approved__c, 'query return is wrong');
		System.assertNotEquals('', tActivity[0].Approved__c, 'getRecordByOwnerId did not work correctly');

		Test.stopTest();
	}

	@isTest
	public static void testgetActivityListCrediCheck(){
		Test.startTest();

		User tUser=[SELECT Id, FirstName
		            FROM User
		            WHERE FirstName='FirstName' AND Email='crmuser@test.com'
		            LIMIT 1];

		System.runAs(tUser){

			List<Order> tOrder=[SELECT Id, Phase__c FROM Order WHERE Phase__c='Bozza' LIMIT 1];

			Set<Id> orderIds=new Set<Id>();
			orderIds.add(tOrder[0].Id);

			Id rt=constants.ACTIVITYCUSTOM_RECORDTYPEID_KOPRECEDETECLIENTE;

			List<wrts_prcgvr__Activity__c> tActCust=[SELECT Id, Type__c,wrts_prcgvr__IsClosed__c 
			                                         FROM wrts_prcgvr__Activity__c
			                                         WHERE Type__c='Approvazione Quote' AND wrts_prcgvr__Status__c='Aperta'
			                                         LIMIT 1];
			
			tActCust[0].RecordTypeId=rt;
			tActCust[0].wrts_prcgvr__IsClosed__c=false;
			update tActCust;

			List<wrts_prcgvr__Activity__c> tActivity=HDT_QR_ActivityCustom.getActivityListCrediCheck(orderIds);
			System.debug('tActivity = '+tActivity);

			System.assertEquals('Aperta', tActivity[0].wrts_prcgvr__Status__c, 'query return is wrong');
			System.assertNotEquals(null, tActivity[0].wrts_prcgvr__Status__c, 'getActivityListCreditCheck did not work correctly');

		}
		Test.stopTest();
	}

	@isTest
	public static void testgetRejectedActivities(){
		Test.startTest();

		User tUser=[SELECT Id, FirstName
		            FROM User
		            WHERE FirstName='FirstName' AND Email='crmuser@test.com'
		            LIMIT 1];

		System.runAs(tUser){

			List<wrts_prcgvr__Activity__c> tActivityCust=[SELECT Id, wrts_prcgvr__Status__c, Type__c, ServicePointCode__c, ParentActivity__c
			                                              FROM wrts_prcgvr__Activity__c
			                                              WHERE ServicePointCode__c='test'
			                                              LIMIT 1];

			Set<Id> actCustIds=new Set<Id>();
			actCustIds.add(tActivityCust[0].Id);

			Id rt=constants.ACTIVITYCUSTOM_RECORDTYPEID_KOPRECEDETECLIENTE;

			List<wrts_prcgvr__Activity__c> tActCust=[SELECT Id, ServicePointCode__c, Type__c, ParentActivity__c
			                                         FROM wrts_prcgvr__Activity__c
			                                         WHERE ServicePointCode__c='test 2'
			                                         LIMIT 1];
			tActCust[0].RecordTypeId=rt;
			tActCust[0].Type__c='Scarto Comunicazione';
			tactcust[0].ParentActivity__c=tActivityCust[0].Id;

			update tActCust[0];

			List<wrts_prcgvr__Activity__c> tActivity=HDT_QR_ActivityCustom.getRejectedActivities(actCustIds, rt);
			System.debug('***!!tActivity = '+tActivity);

			System.assertEquals('Scarto Comunicazione', tActivity[0].Type__c, 'query return is wrong');
			System.assertNotEquals(null, tActivity[0].Type__c, 'getRejectedActivities did not work correctly');

		}
		Test.stopTest();
	}

	@isTest
	public static void testgetActivityByRecordId(){

		Test.startTest();
		User tUser=[SELECT Id, FirstName, Title
		            FROM User
		            WHERE Title='srTest' AND Email='crmuser@test.com'
		            LIMIT 1];


		System.runAs(tUser){

			List<wrts_prcgvr__Activity__c> tActivityCust=[SELECT Id, wrts_prcgvr__Status__c
			                                              FROM wrts_prcgvr__Activity__c
			                                              WHERE wrts_prcgvr__Status__c='Creata'
			                                              LIMIT 1];

			List<wrts_prcgvr__Activity__c> tActivity=HDT_QR_ActivityCustom.getActivityByRecordId(tActivityCust[0].Id);
			System.debug('tActivity = '+tActivity);

			System.assertEquals('Approvazione Quote', tActivity[0].Type__c, 'query return is wrong');
			System.assertNotEquals('', tActivity[0].Type__c, 'getActivityByRecordId did not work correctly');

			Test.stopTest();
		}
	}

	@isTest
	public static void testgetRecordByParentIds(){
		Test.startTest();

		User tUser=[SELECT Id, FirstName
		            FROM User
		            WHERE FirstName='FirstName' AND Email='crmuser@test.com'
		            LIMIT 1];

		System.runAs(tUser){

			Id rt=constants.ACTIVITYCUSTOM_RECORDTYPEID_KOPRECEDETECLIENTE;

			List<wrts_prcgvr__Activity__c> tActCust=[SELECT Id, ServicePointCode__c
			                                         FROM wrts_prcgvr__Activity__c
			                                         WHERE ServicePointCode__c='test 2'
			                                         LIMIT 1];
			tActCust[0].RecordTypeId=rt;
			tActCust[0].Type__c='Scarto Comunicazione';

			update tActCust;

			Set<String> actCustIds=new Set<String>();
			actCustIds.add(tActCust[0].Id);

			List<wrts_prcgvr__Activity__c> tActivity=HDT_QR_ActivityCustom.getRecordByParentIds(actCustIds, rt);
			System.debug('tActivity = '+tActivity);

			System.assertEquals(rt, tActivity[0].RecordTypeId, 'query return is wrong');
			System.assertNotEquals(null, tActivity[0].RecordTypeId, 'getRecordByParentIds did not work correctly');

		}
		Test.stopTest();
	}

	
	@isTest
	static void testisActivityNotClosedCase(){
		Test.startTest();

		List<wrts_prcgvr__Activity__c> activities = [ SELECT Case__r.Id 
														FROM wrts_prcgvr__Activity__c 
														WHERE Case__r.Id != null 
														LIMIT 1 ];
		Boolean isClose = HDT_QR_ActivityCustom.isActivityNotClosed( activities[0].Case__r.id );

		System.assertEquals( isClose, true, 'isActivityNotClosed work correctly' );

		Test.stopTest();
	}

	@isTest
	static void testisActivityNotClosedOrder(){
		Test.startTest();

		List<wrts_prcgvr__Activity__c> activities = [ SELECT Order__r.Id 
														FROM wrts_prcgvr__Activity__c 
														WHERE Order__r.Id != null 
														LIMIT 1 ];
		Boolean isClose = HDT_QR_ActivityCustom.isActivityNotClosed( activities[0].Order__r.id );

		System.assertEquals( isClose, true, 'isActivityNotClosed work correctly' );

		Test.stopTest();
	}

	@isTest
	static void getActivityCreatedByQualityBatchTest(){
		Test.startTest();


		List<Id> orderId = new List<Id>();
		for (wrts_prcgvr__Activity__c act:[ SELECT Order__c FROM wrts_prcgvr__Activity__c WHERE Order__r.Id != null]){
			orderId.add(act.Order__c);
		}

		System.assertEquals(0, HDT_QR_ActivityCustom.getActivityCreatedByQualityBatch(orderId).size(), 'getActivityCreatedByQualityBatch doesn\'t work correctly' );

		Test.stopTest();
	}

	@isTest
	static void getRecordByMethodTest(){
		Test.startTest();


		List<wrts_prcgvr__Activity__c> activities = [ SELECT Id, Order__c,Order__r.ServicePoint__c, Account__c
														FROM wrts_prcgvr__Activity__c 
														WHERE Order__r.Id != null 
														LIMIT 1 ];

		System.assertEquals(0, HDT_QR_ActivityCustom.getRecordByTypeAndStatusAndAccountAndServicePointNotStatus('TEST', 'Chiusa', activities[0].Account__c, activities[0].Order__r.ServicePoint__c).size(), 'getRecordByTypeAndStatusAndAccountAndServicePointNotStatus doesn\'t work correctly' );
		System.assertEquals(activities[0].Id, HDT_QR_ActivityCustom.getRecordByIdAccise(activities[0].Id).Id, 'getRecordByIdAccise doesn\'t work correctly' );
		System.assertEquals(activities[0].Id, HDT_QR_ActivityCustom.getRecordByIdValidation(activities[0].Id).Id, 'getRecordByIdValidation doesn\'t work correctly' );
		System.assertEquals(0, HDT_QR_ActivityCustom.getRecordByOrderIdAndType(activities[0].Order__c,'TEST').size(), 'getRecordByOrderIdAndType doesn\'t work correctly' );
		System.assertEquals(0, HDT_QR_ActivityCustom.getRecordByOrderAndQuality(activities[0].Order__c).size(), 'getRecordByOrderAndQuality doesn\'t work correctly' );
		System.assertEquals(0, HDT_QR_ActivityCustom.getRecordByOrderListAndQuality(new List<Id>{activities[0].Order__c}).size(), 'getRecordByOrderListAndQuality doesn\'t work correctly' );
		System.assertEquals(0, HDT_QR_ActivityCustom.getRecordByOrderListAndQuality(new Set<String>{activities[0].Order__c}).size(), 'getRecordByOrderListAndQuality doesn\'t work correctly' );
		System.assertEquals(0, HDT_QR_ActivityCustom.getRecordByEcid('TEST').size(), 'getRecordByEcid doesn\'t work correctly' );

		Test.stopTest();
	}

	@isTest
	static void datiDiscordantiMethodTest(){
		Test.startTest();


		List<wrts_prcgvr__Activity__c> activities = [ SELECT Id, Order__c,Order__r.ServicePoint__c, Account__c
														FROM wrts_prcgvr__Activity__c 
														WHERE Order__r.Id != null 
														LIMIT 1 ];

		System.assertEquals(0, HDT_QR_ActivityCustom.getRecordScartoDiscordante(activities[0].Order__r.ServicePoint__c,activities[0].Account__c).size(), 'getRecordScartoDiscordante doesn\'t work correctly' );
		System.assertEquals(0, HDT_QR_ActivityCustom.getRecordScartoDiscordante(activities[0].Order__c).size(), 'getRecordScartoDiscordante doesn\'t work correctly' );
		System.assertEquals(0, new HDT_QR_ActivityCustom().getEsitoActivityDiscordante(activities[0].Order__c).size(), 'getEsitoActivityDiscordante doesn\'t work correctly' );
		
		Test.stopTest();
	}

	@isTest
	static void telesellingMethodTest(){
		Test.startTest();


		
		System.assertEquals(0, HDT_QR_ActivityCustom.getActivityTelesellingOutbound('TEST').size(), 'getActivityTelesellingOutbound doesn\'t work correctly' );
		System.assertEquals(0, HDT_QR_ActivityCustom.getActivityTelesellingOutboundByUser().size(), 'getActivityTelesellingOutboundByUser doesn\'t work correctly' );
		
		Test.stopTest();
	}

	@isTest
	static void creditCheckMethodTest(){
		Test.startTest();


		List<wrts_prcgvr__Activity__c> activities = [ SELECT Id, Order__c,Order__r.ServicePoint__c, Account__c
														FROM wrts_prcgvr__Activity__c 
														WHERE Order__r.Id != null 
														LIMIT 1 ];

		System.assertEquals(1, HDT_QR_ActivityCustom.getActivityKoPrecedenteClienteByIds(new List<Id>{activities[0].Id}).size(), 'getActivityKoPrecedenteClienteByIds doesn\'t work correctly' );
		
		Test.stopTest();
	}

	@isTest
	static void qualityCallMethodTest(){
		Test.startTest();


		List<wrts_prcgvr__Activity__c> activities = [ SELECT Order__c
														FROM wrts_prcgvr__Activity__c 
														WHERE Order__r.Id != null 
														LIMIT 1 ];

		System.assertEquals(true, HDT_QR_ActivityCustom.getQualCallByParentOrder(new Set<String>{activities[0].Order__c}).isEmpty(), 'getQualCallByParentOrder doesn\'t work correctly' );
		
		Test.stopTest();
	}
}