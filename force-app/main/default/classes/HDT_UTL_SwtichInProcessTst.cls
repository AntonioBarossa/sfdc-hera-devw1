/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 24/09/2021
 * @description HDT_UTL_SwtichInProcess Test Classes
 * @history Fabricio Petkevicius Nunes – 24/09/2021 – Created class
 */
@isTest
public with sharing class HDT_UTL_SwtichInProcessTst{
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();

	@TestSetup
	static void makeData(){

		HDT_UTL_DataFactoryTst.pClickInstance();
		HDT_UTL_DataFactoryTst.pClickOrderPhase();

		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.HERA_SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, true);

		System.runAs(internalUser){

			List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
			List<Account> accountRes=HDT_UTL_DataFactoryTst.createAccountResidenziale(1, false, 'HERA COMM', 'D1 - Persona fisica', 'Enti');
			accountRes[0].Name='test accountRes';
			accountRes[0].VATNumber__c='12345438';
			accountRes[0].FiscalCode__c='SXSRFF45H38H1';
			accountRes[0].FirstName__c='test22Res';
			accountRes[0].LastName__c='account22Res';
			accountRes[0].CustomerCode__c='4325432432';
			insert accountRes;

			List<ServicePoint__c> servPoints=HDT_UTL_DataFactoryTst.createServicePoint(1, false);
			servPoints[0].CommoditySector__c='Energia Elettrica';
			insert servPoints;

			List<Order> orders=HDT_UTL_DataFactoryTst.createOrder(2, false, accounts[0].Id, 'Bozza');
			Id orderRtSwitchin=constants.ORDER_RECORDTYPEID_SWITCHIN;
			orders[0].RecordTypeId=orderRtSwitchin;
			orders[0].ServicePoint__c=servPoints[0].Id;

			orders[1].AccountId=accountRes[0].Id;
			orders[1].RecordTypeId=orderRtSwitchin;
			orders[1].ServicePoint__c=servPoints[0].Id;
			insert orders;

			List<HDT_FulfillmentDateMatrix__c> fullfillDateMtx=HDT_UTL_DataFactoryTst.createFullfillmentDateMatrix(1, false);
			fullfillDateMtx[0].OriginMarket__c='Libero';
			fullfillDateMtx[0].ProcessType__c='Switch In';
			fullfillDateMtx[0].Commodity__c='Energia Elettrica';
			fullfillDateMtx[0].VoltageLevel__c='BT';
			fullfillDateMtx[0].SupplyType__c='Non Domestico';
			fullfillDateMtx[0].FulfillmentDateFrom__c=Date.today();
			fullfillDateMtx[0].FulfillmentDateTo__c=Date.today();
			fullfillDateMtx[0].ActivationDate__c=Date.newInstance(2021, 11, 01);
			insert fullfillDateMtx;
		}
	}

	@isTest
	public static void testCheckAccountOrderIsResidential(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();

			List<Order> tOrder=[SELECT Id, Name, AccountId
			                    FROM Order
			                    WHERE Name='testOrderName0'];

			Map<String, Boolean> checkAccOrderisRes=HDT_UTL_SwtichInProcess.checkAccountOrderIsResidential(tOrder);

			test.stopTest();

			System.assertEquals(false, checkAccOrderisRes.isEmpty(), 'Return is wrong');
			System.assertNotEquals(true, checkAccOrderisRes.isEmpty(), 'Return is wrong');
		}
	}

	@isTest
	public static void testGetMaxAfterthoughtDate(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();

			List<Order> tOrder=[SELECT Id, Name, AccountId, Channel__c, Market__c, CustomerCategory__c, SignatureMethod__c, DocSendingMethod__c
			                    FROM Order
			                    WHERE Name='testOrderName0'];

			tOrder[0].SignedDate__c=Date.today();
			tOrder[0].SignatureMethod__c='Cartacea';
			tOrder[0].DocSendingMethod__c='Cartacea';

			Date getMaxAfterthoughtDate=HDT_UTL_SwtichInProcess.getMaxAfterthoughtDate(tOrder[0]);

			test.stopTest();

			System.assertEquals(tOrder[0].SignedDate__c, getMaxAfterthoughtDate, 'Date is wrong');
			System.assertNotEquals(false, getMaxAfterthoughtDate==tOrder[0].SignedDate__c, 'Date is wrong');
		}
	}

	@isTest
	public static void testGetDateSentToSii(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();

			List<Order> tOrder=[SELECT Id, Name, AccountId, Channel__c, Market__c, CustomerCategory__c, SignatureMethod__c, DocSendingMethod__c, EffectiveDate__c, WizardCompletedDate__c, ProcessType__c
			                    FROM Order
			                    WHERE Name='testOrderName0'];

			List<Order> tOrderRes=[SELECT Id, Name, AccountId, Channel__c, Market__c, CustomerCategory__c, SignatureMethod__c, DocSendingMethod__c, EffectiveDate__c, WizardCompletedDate__c, ProcessType__c, IsActivationDeferred__c, IsSequanzialized__c, RecessNotice__c, VoltageLevel__c, SupplyType__c, MarketOrigin__c, ServicePoint__r.CommoditySector__c, RecordType.DeveloperName
			                       FROM Order
			                       WHERE Name='testOrderName1'];

			tOrder[0].SignedDate__c=Date.today();
			tOrder[0].SignatureMethod__c='Cartacea';
			tOrder[0].DocSendingMethod__c='Cartacea';

			tOrderRes[0].SignedDate__c=Date.today();
			tOrderRes[0].SignatureMethod__c='Cartacea';
			tOrderRes[0].DocSendingMethod__c='Cartacea';

			Date getDateSentToSii=HDT_UTL_SwtichInProcess.getDateSentToSii(tOrder[0]);
			Date getDateSentToSiiRes=HDT_UTL_SwtichInProcess.getDateSentToSii(tOrderRes[0]);

			test.stopTest();

			List<Order> updatedOrder=[SELECT Id, SignedDate__c
			                          FROM Order
			                          LIMIT 1];

			System.assertEquals(updatedOrder[0].SignedDate__c, getDateSentToSii, 'Date is wrong');
			System.assertNotEquals(false, getDateSentToSii==updatedOrder[0].SignedDate__c, 'Date is wrong');
		}
	}

	@isTest
	public static void testGetEffectiveDate(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();

			List<Order> tOrder=[SELECT Id, Name, AccountId, Channel__c, Market__c, CustomerCategory__c, SignatureMethod__c, DocSendingMethod__c, EffectiveDate__c, WizardCompletedDate__c, ProcessType__c, IsActivationDeferred__c, IsSequanzialized__c, RecessNotice__c, VoltageLevel__c, SupplyType__c, MarketOrigin__c, ServicePoint__r.CommoditySector__c, RecordType.DeveloperName
			                    FROM Order
			                    WHERE Name='testOrderName0'];

			List<Order> tOrderRes=[SELECT Id, Name, AccountId, Channel__c, Market__c, CustomerCategory__c, SignatureMethod__c, DocSendingMethod__c, EffectiveDate__c, WizardCompletedDate__c, ProcessType__c, IsActivationDeferred__c, IsSequanzialized__c, RecessNotice__c, VoltageLevel__c, SupplyType__c, MarketOrigin__c, ServicePoint__r.CommoditySector__c, RecordType.DeveloperName
			                       FROM Order
			                       WHERE Name='testOrderName1'];

			List<HDT_FulfillmentDateMatrix__c> tFulDatMat=[SELECT Id, Name, OriginMarket__c, Commodity__c, VoltageLevel__c, SupplyType__c, FulfillmentDateFrom__c, FulfillmentDateTo__c, ActivationDate__c, ProcessType__c
			                                               FROM HDT_FulfillmentDateMatrix__c
			                                               WHERE Name='testFulDatMx0'
			                                               LIMIT 1];

			tOrder[0].SignedDate__c=Date.today();
			tOrder[0].SignatureMethod__c='Cartacea';
			tOrder[0].DocSendingMethod__c='E-Mail';
			tOrder[0].MarketOrigin__c='Libero';
			tOrder[0].SupplyType__c='Non Domestico';
			tOrder[0].VoltageLevel__c='BT';

			update tOrder;

			tOrderRes[0].SignedDate__c=Date.today();
			tOrderRes[0].SignatureMethod__c='Cartacea';
			tOrderRes[0].DocSendingMethod__c='E-Mail';
			tOrderRes[0].MarketOrigin__c='Libero';
			tOrderRes[0].SupplyType__c='Non Domestico';
			tOrderRes[0].VoltageLevel__c='BT';

			update tOrderRes;

			Date getEffectiveDate=HDT_UTL_SwtichInProcess.getEffectiveDate(tOrder[0]);
			Date getEffectiveDateRes=HDT_UTL_SwtichInProcess.getEffectiveDate(tOrderRes[0]);

			test.stopTest();

			System.assertEquals(tFulDatMat[0].ActivationDate__c, getEffectiveDate, 'Date is wrong');
			System.assertNotEquals(false, getEffectiveDate==tFulDatMat[0].ActivationDate__c, 'Date is wrong');
		}
	}
}