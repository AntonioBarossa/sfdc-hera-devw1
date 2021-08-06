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

		Id standardUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.HERA_STANDARD_USER_NAME);
		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);

		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);

		internalUser.UserPermissionsMarketingUser=true;
        internalUser.Title = 'srTest';

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
			SBQQ__QuoteLine__c quoteLine=new SBQQ__QuoteLine__c();
			quoteline.SBQQ__Quote__c=quotes[0].Id;
			quoteLine.SBQQ__Product__c=products[0].Id;
			quoteLine.ServicePoint__c=servpoints[0].Id;
			quoteLine.SupplyCity__c='test city';
			quoteLine.BillingProfile__c=billProfs[0].Id;
			quoteLine.Agency__c=accounts[0].Id;
			quoteLine.OwnerAC__c='Si';
			insert quoteLine;

			wrts_prcgvr__Activity__c actCustom=new wrts_prcgvr__Activity__c();
			actCustom.Account__c=accounts[0].Id;
			actCustom.ServicePoint__c=servpoints[0].Id;
			actCustom.Status__c='Creata';
			actCustom.Type__c='Approvazione Quote';
			actCustom.ServicePointCode__c='test';
			actCustom.Order__c=orders[0].Id;
			actCustom.Approved__c='Si';
			actCustom.Case__c=cases[0].Id;
			actCustom.QuoteLine__c=quoteLine.Id;
			actCustom.OwnerId=internalUser.Id;

			System.debug('actCustom.OwnerId = '+actCustom.OwnerId);

			insert actCustom;

			wrts_prcgvr__Activity__c actCustom2=new wrts_prcgvr__Activity__c();
			actCustom2.Account__c=accounts[0].Id;
			actCustom2.ServicePoint__c=servpoints[0].Id;
			actCustom2.Status__c='Creata';
			actCustom2.Type__c='Approvazione Quote';
			actCustom2.ServicePointCode__c='test 2';
			actCustom2.Order__c=orders[0].Id;
			actCustom2.Approved__c='Si';
			actCustom2.Case__c=cases[0].Id;
			actCustom2.QuoteLine__c=quoteLine.Id;
			actCustom2.OwnerId=internalUser.Id;
			actCustom2.ParentActivity__c=actCustom.Id;

			System.debug('actCustom2.ParentActivity__c = '+actCustom2.ParentActivity__c);

			insert actCustom2;
		}
	}

	@isTest
	public static void testgetRecordByTypeAndStatusAndAccountAndServicePoint(){
		Test.startTest();

		Account tAcc=[SELECT Id, CompanyOwner__c
		              FROM Account
		              WHERE CompanyOwner__c='HERA COMM'
		              LIMIT 1];

		ServicePoint__c tServPoint=[SELECT Id, ServicePointCode__c
		                            FROM ServicePoint__c
		                            WHERE ServicePointCode__c='testServicePointCode'];

		List<wrts_prcgvr__Activity__c> tActivity=HDT_QR_ActivityCustom.getRecordByTypeAndStatusAndAccountAndServicePoint('Approvazione Quote', 'Creata', tAcc.Id, 'test');
		System.debug('tActivity = '+tActivity);

		System.assertEquals('Creata', tActivity[0].Status__c, 'query return is wrong');
		System.assertNotEquals('', tActivity[0].Status__c);

		Test.stopTest();
	}

	@isTest
	public static void testgetRecordById(){
		Test.startTest();

		wrts_prcgvr__Activity__c tActivityCust=[SELECT Id, Status__c
		                                        FROM wrts_prcgvr__Activity__c
		                                        WHERE Status__c='Creata'
		                                        LIMIT 1];

		List<wrts_prcgvr__Activity__c> tActivity=HDT_QR_ActivityCustom.getRecordById(tActivityCust.Id);
		System.debug('tActivity = '+tActivity);

		System.assertEquals('Creata', tActivity[0].Status__c, 'query return is wrong');
		System.assertNotEquals('', tActivity[0].Status__c);

		Test.stopTest();
	}

	@isTest
	public static void testgetRecordByIdS(){
		Test.startTest();

		List<wrts_prcgvr__Activity__c> tActivityCust=[SELECT Id, Status__c
		                                              FROM wrts_prcgvr__Activity__c
		                                              WHERE Status__c='Creata'
		                                              LIMIT 1];

		wrts_prcgvr__Activity__c tActivity=HDT_QR_ActivityCustom.getRecordByIds(tActivityCust[0].Id);
		System.debug('tActivity = '+tActivity);

		System.assertEquals('Creata', tActivity.Status__c, 'query return is wrong');
		System.assertNotEquals('', tActivity.Status__c);

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
		System.assertNotEquals('', tActivity[0].Approved__c);

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
		System.assertNotEquals('', tActivity[0].Approved__c);

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
		System.assertNotEquals('', tActivity[0].Approved__c);

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

		System.debug('tUser = '+tUser);
		System.debug('userIds = '+userIds);

		List<wrts_prcgvr__Activity__c> tActivity=HDT_QR_ActivityCustom.getRecordByOwnerId(userIds);
		System.debug('tActivity = '+tActivity);

		System.assertEquals('Si', tActivity[0].Approved__c, 'query return is wrong');
		System.assertNotEquals('', tActivity[0].Approved__c);

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

			List<Order> tOrder=[SELECT Id, Phase__c
			                    FROM Order
			                    WHERE Phase__c='Bozza'
			                    LIMIT 1];

			Set<Id> orderIds=new Set<Id>();
			orderIds.add(tOrder[0].Id);

			HDT_UTL_Constants constRecordType=new HDT_UTL_Constants();

			Id rt=constRecordType.ACTIVITYCUSTOM_RECORDTYPEID_KOPRECEDETECLIENTE;

			List<wrts_prcgvr__Activity__c> tActCust=[SELECT Id, Type__c
			                                         FROM wrts_prcgvr__Activity__c
			                                         WHERE Type__c='Approvazione Quote'
			                                         LIMIT 1];
			tActCust[0].RecordTypeId=rt;

			update tActCust;

			System.debug('tOrder = '+tOrder);
			System.debug('orderIds = '+orderIds);
			System.debug('tActCust = '+tActCust);

			List<wrts_prcgvr__Activity__c> tActivity=HDT_QR_ActivityCustom.getActivityListCrediCheck(orderIds);
			System.debug('tActivity = '+tActivity);

			System.assertEquals('Creata', tActivity[0].Status__c, 'query return is wrong');
			System.assertNotEquals(null, tActivity[0].Status__c);

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

			List<wrts_prcgvr__Activity__c> tActivityCust=[SELECT Id, Status__c, Type__c
			                                              FROM wrts_prcgvr__Activity__c
			                                              WHERE Status__c='Creata'
			                                              LIMIT 1];

			Set<Id> actCustIds=new Set<Id>();
			actCustIds.add(tActivityCust[0].Id);

			HDT_UTL_Constants constRecordType=new HDT_UTL_Constants();

			Id rt=constRecordType.ACTIVITYCUSTOM_RECORDTYPEID_KOPRECEDETECLIENTE;

			List<wrts_prcgvr__Activity__c> tActCust=[SELECT Id, ServicePointCode__c
			                                         FROM wrts_prcgvr__Activity__c
			                                         WHERE ServicePointCode__c='test 2'
			                                         LIMIT 1];
			tActCust[0].RecordTypeId=rt;
			tActCust[0].Type__c='Scarto Comunicazione';

			update tActCust;

			System.debug('tActivityCust = '+tActivityCust);
			System.debug('actCustIds = '+actCustIds);
			System.debug('tActCust = '+tActCust);

			List<wrts_prcgvr__Activity__c> tActivity=HDT_QR_ActivityCustom.getRejectedActivities(actCustIds, rt);
			System.debug('tActivity = '+tActivity);

			System.assertEquals('Scarto Comunicazione', tActivity[0].Type__c, 'query return is wrong');
			System.assertNotEquals(null, tActivity[0].Type__c);

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

			List<wrts_prcgvr__Activity__c> tActivityCust=[SELECT Id, Status__c
			                                              FROM wrts_prcgvr__Activity__c
			                                              WHERE Status__c='Creata'
			                                              LIMIT 1];

			List<wrts_prcgvr__Activity__c> tActivity=HDT_QR_ActivityCustom.getActivityByRecordId(tActivityCust[0].Id);
			System.debug('tActivity = '+tActivity);

			System.assertEquals('Approvazione Quote', tActivity[0].Type__c, 'query return is wrong');
			System.assertNotEquals('', tActivity[0].Type__c);

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

			// List<wrts_prcgvr__Activity__c> tActivityCust=[SELECT Id, Status__c, Type__c
			//                                               FROM wrts_prcgvr__Activity__c
			//                                               WHERE Status__c='Creata'
			//                                               LIMIT 1];

			// Set<String> actCustIds=new Set<String>();
			// actCustIds.add(tActivityCust[0].Id);

			HDT_UTL_Constants constRecordType=new HDT_UTL_Constants();

			Id rt=constRecordType.ACTIVITYCUSTOM_RECORDTYPEID_KOPRECEDETECLIENTE;

			List<wrts_prcgvr__Activity__c> tActCust=[SELECT Id, ServicePointCode__c
			                                         FROM wrts_prcgvr__Activity__c
			                                         WHERE ServicePointCode__c='test 2'
			                                         LIMIT 1];
			tActCust[0].RecordTypeId=rt;
			tActCust[0].Type__c='Scarto Comunicazione';

			update tActCust;

            Set<String> actCustIds=new Set<String>();
			actCustIds.add(tActCust[0].Id);

			//System.debug('tActivityCust = '+tActivityCust);
			System.debug('actCustIds = '+actCustIds);
			System.debug('tActCust = '+tActCust);

			List<wrts_prcgvr__Activity__c> tActivity=HDT_QR_ActivityCustom.getRecordByParentIds(actCustIds, rt);
			System.debug('tActivity = '+tActivity);

			System.assertEquals(rt, tActivity[0].RecordTypeId, 'query return is wrong');
			System.assertNotEquals(null, tActivity[0].RecordTypeId);

		}
		Test.stopTest();
	}
}