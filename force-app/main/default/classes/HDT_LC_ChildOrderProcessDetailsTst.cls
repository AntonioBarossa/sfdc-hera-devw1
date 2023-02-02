/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 27/08/2021
 * @description Test Class for HDT_LC_ChildOrderProcessDetails.cls
 * @history Fabricio Petkevicius Nunes – 27/08/2021 – Created class
 */
@isTest
public class HDT_LC_ChildOrderProcessDetailsTst{
	private static HDT_UTL_Constants utlConstants=new HDT_UTL_Constants();
	static HDT_LC_ChildOrderProcessDetails.HDT_WRP_QuoteType quoteTypeWrp=new HDT_LC_ChildOrderProcessDetails.HDT_WRP_QuoteType();
	@TestSetup
	static void setup(){

		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(utlConstants.SYSTEM_ADMINISTRATOR_NAME);

		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);

		internalUser.UserPermissionsMarketingUser=true;

		insert internalUser;

		List<PermissionSetAssignment> permissionSetAssignments=new List<PermissionSetAssignment>{HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, utlConstants.PERMISSIONSET_HDT_SALESFORCE_CPQ_ADMIN_NAME, false), HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, utlConstants.PERMISSIONSET_HDT_VOLTURARETROATTIVA, false), HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, utlConstants.PERMISSIONSET_HDT_SALESFORCE_CPQ_LICENSE_NAME, false)};

		insert permissionSetAssignments;

		System.runAs(internalUser){

			HDT_UTL_DataFactoryTst.pClickInstance();
			HDT_UTL_DataFactoryTst.pClickOrderPhase();
			HDT_UTL_DataFactoryTst.pClickCasePhase();

			List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(1, false, 'HERA COMM', 'Azienda', 'Aziende SME');
			accounts[0].ActiveMonitoring__c=false;
			accounts[0].Name='INRETE DIST. ENER.-13R0000000';
			accounts[0].LastName__c='INRETE DIST. ENER.-13R0000000';
			accounts[0].FiscalCode__c='SXSRLA45H28H6';
			accounts[0].VATNumber__c='12345689';
			accounts[0].CustomerCode__c='1003616211';
            


			List<Account> accDist = HDT_UTL_DataFactoryTst.createAccountDistributore(1, true, 'HERA COMM', 'Azienda', 'Aziende SME'); 

			System.debug('*** '+accounts);
			insert accounts;

			List<Opportunity> opps=HDT_UTL_DataFactoryTst.createOpportunity(1, true);
			List<Contact> contacts=HDT_UTL_DataFactoryTst.createContact(1, true, accounts[0].Id);
			List<Sale__c> sales=HDT_UTL_DataFactoryTst.createSale(6, true, accounts[0].Id, 'Attiva');
            Id pricebookIdSTD = Test.getStandardPricebookId();
			List<Pricebook2> pricebook=HDT_UTL_DataFactoryTst.createPricebook(1, true);
            List<ServicePoint__c> sP =HDT_UTL_DataFactoryTst.createServicePoint(1, true);
			List<Order> orders=HDT_UTL_DataFactoryTst.createOrderWithPricebook(6, false, accounts[0].Id, sales, pricebookIdSTD);
            List<Product2> products=HDT_UTL_DataFactoryTst.createProduct2(1, true);
            List<PricebookEntry> entries = HDT_UTL_DataFactoryTst.createPricebookEntry(products, true, pricebookIdSTD);
            
            
            
			id orderConnessioneConAttiv=utlConstants.ORDER_RECORDTYPEID_CONNESSIONECONATTIVAZIONE;
			id orderTemporaneaNuovaAtt=utlConstants.ORDER_RECORDTYPEID_TEMPORANEANUOVAATT;
			id orderVoltura=utlConstants.ORDER_RECORDTYPEID_VOLTURA;
			id orderAttivazioneConModifica=utlConstants.ORDER_RECORDTYPEID_ATTIVAZIONECONMODIFICA;
			orders[0].Username__c='test';
			orders[0].Password__c='test1';
			orders[0].NotRegisteredMeterCase__c=true;
			orders[0].EffectiveDate__c=date.today();
			orders[0].PowerCommitted__c=2;
			orders[0].ImplantType__c='13A0-Usi di Abitazione BT';
			orders[0].RequestOption__c='Domestici-TD';
			orders[0].CreditCheckDescription__c='test1';
			orders[0].ProcessCode__c='PN1';
			orders[0].QuotationType__c = 'Rapido';
            
            
			orders[1].RecordTypeId=orderVoltura;
			orders[1].CreditCheckDescription__c='test2Voltura';
			orders[1].ProcessCode__c='PN1';
			orders[1].PowerRequested__c=1;
			orders[1].PowerAvailable__c=3;
			orders[1].PowerCommitted__c=2;
			orders[1].NotRegisteredMeterCase__c=false;
			orders[1].EffectiveDate__c=date.today().addDays(-4);
			orders[1].RequestOption__c='Domestici-TD';
			orders[1].VoltureType__c='Ordinaria';
			orders[1].Subprocess__c='Standard';

			orders[2].PowerCommitted__c=2;
			orders[2].CreditCheckDescription__c = 'test3';
			orders[2].VoltureType__c='In Continuità';
			orders[2].RecordTypeId = orderVoltura;

			orders[3].PowerCommitted__c=2;
			orders[3].VoltureType__c='In Continuità';
			orders[3].CreditCheckDescription__c='test4AttivConMod';
			orders[3].RecordTypeId=orderAttivazioneConModifica;
			orders[3].PowerRequested__c=3;
			orders[3].ProcessCode__c='E02';

			orders[4].EffectiveDate__c=date.today().addDays(10);
			orders[4].PowerCommitted__c=2;
			orders[4].RecordTypeId=orderConnessioneConAttiv;
			orders[4].CreditCheckDescription__c='test5Conessione1';
			orders[4].ProcessCode__c='PN1';

			orders[5].RecordTypeId=orderTemporaneaNuovaAtt;
			orders[5].VoltageLevel__c='BT';
			orders[5].ProcessCode__c='E02';
			orders[5].UseTypeEnergy__c='Manifest (Temp Straord 16h)';
			orders[5].CreditCheckDescription__c='test6Temporanea';
			orders[5].RequestOption__c='Domestici-TD';
			orders[5].PowerRequested__c=2;
			orders[5].PowerCommitted__c=2;

			insert orders;
			
            
            
			List<Order> childOrders=HDT_UTL_DataFactoryTst.createChildOrder(1, false, accounts[0].Id, sales, orders[0].Id, contacts[0].Id);
			childOrders[0].QualityCall__c=true;
			insert childOrders;

			List<ServicePoint__c> servPoints=HDT_UTL_DataFactoryTst.createServicePoint(2, false);
			servPoints[0].Distributor__c=accDist[0].Id;
			servPoints[0].CommoditySector__c='Energia Elettrica';
			servPoints[1].CommoditySector__c='Gas';

			insert servPoints;

			List<SBQQ__Quote__c> quotes=HDT_UTL_DataFactoryTst.createQuote(1, false, orders[0].Id, opps[0].Id, sales[0].Id, 'Amendment');
			quotes[0].IsVAS__c=false;
			quotes[0].AmendmentAllowed__c=false;
			insert quotes;
            
            List<SBQQ__QuoteLine__c> qL = HDT_UTL_DataFactoryTst.createQuoteLines(products[0].Id, quotes[0].Id, 1, true);
            
            
            List<OrderItem> orderItems=HDT_UTL_DataFactoryTst.createOrderItem(1, false, orders[0].Id, sP[0].Id, products[0].Id, entries[0].Id);
            orderItems[0].Description = '1';
            orderItems[0].OwnerAC__c = 'Si';
            orderItems[0].DwellingType__c = 'Appartamento';
            orderItems[0].OccupantsNumber__c = 2;
            orderItems[0].Surface__c = 50;
            orderItems[0].SBQQ__QuoteLine__c = qL[0].Id;
            
            insert orderItems;

			orders[1].ServicePoint__c=servPoints[1].Id;
			orders[0].ServicePoint__c=servPoints[0].Id;
			orders[0].SBQQ__Quote__c=quotes[0].id;
			orders[3].ServicePoint__c=servPoints[0].Id;
			orders[3].SBQQ__Quote__c=quotes[0].id;
			orders[0].ProcessType__c = 'Voltura';
			orders[0].NotRegisteredMeterCase__c = true;
			HDT_UTL_Constants utlConstants = new HDT_UTL_Constants();
			Id rt=utlConstants.ORDER_RECORDTYPEID_VOLTURA;
			orders[0].RecordTypeId = rt;

			update orders;

			List<Contract> contracts=HDT_UTL_DataFactoryTst.createContract(1, true, accounts[0].Id);
			List<Case> cases=HDT_UTL_DataFactoryTst.createCase(1, false, accounts[0].Id, contacts[0].Id, servPoints[0].Id, contracts[0].Id, orders[0].Id);
			cases[0].Type='Cambio Contatore Non Registrato';
			cases[0].Phase__c='Completata';
			cases[0].VulturePracticeReference__c=orders[0].Id;
			cases[0].ServicePoint__c = servPoints[0].Id;
	

			insert cases;

			List<QuoteManagement__c> menageQuoteList=HDT_UTL_DataFactoryTst.createQuoteManagement(2, false, 'Gas');
			menageQuoteList[0].Operation_type__c = 'HDT_RT_ConnessioneConAttivazione';
			menageQuoteList[0].CausalCode__c = orders[0].ProcessCode__c;
            menageQuoteList[0].QuoteType__c = 'Analitico';
            menageQuoteList[0].OperationCode__c = '02';

			insert menageQuoteList;
 
		}
	}
    
    @isTest static void testInit(){
        
        Map<String,Object> mapp = HDT_LC_ChildOrderProcessDetails.init('id');
        System.assertEquals(1, mapp.size(), 'Init did not work correctly');
        System.assertNotEquals(null, mapp, 'Init did not work correctly');
    }

	@isTest
	static void testcreateActivityAccise(){

		Test.startTest();

		List<Order> tOrder=[SELECT Id, Name, AccountId
		                    FROM Order
		                    WHERE Name='testOrderName0'
		                    LIMIT 1];

		HDT_LC_ChildOrderProcessDetails.createActivityAccise(true, true, tOrder[0].Id, tOrder[0].AccountId);

		List<wrts_prcgvr__Activity__c> tActivityCustom=[SELECT Id, Account__c
		                                                FROM wrts_prcgvr__Activity__c
		                                                WHERE Account__c=:tOrder[0].AccountId
		                                                LIMIT 1];

		Test.stopTest();

		System.assertEquals(false, tActivityCustom.isEmpty(), 'Order not found');
		System.assertNotEquals(true, tActivityCustom.isEmpty(), 'createActivityAccise did not work correctly');
	}

	@isTest
	static void testupdateProcessStep(){

		User tUser=[SELECT Id, Alias
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			Test.startTest();

			List<Order> tOrder1=[SELECT Id, Name, AccountId, NotRegisteredMeterCase__c, EffectiveDate__c, VoltureType__c, ImplantType__c, RequestOption__c, PowerCommitted__c, TemporaryConnectionStartDate__c, RecordType.DeveloperName, VATfacilitationFlag__c, FacilitationExcise__c
			                    FROM Order
			                    WHERE CreditCheckDescription__c='test1'];

			List<Order> tOrder2=[SELECT Id, Name, AccountId, NotRegisteredMeterCase__c, EffectiveDate__c, VoltureType__c, ImplantType__c, RequestOption__c, PowerCommitted__c, TemporaryConnectionStartDate__c, RecordType.DeveloperName, VATfacilitationFlag__c, FacilitationExcise__c, RetroactiveDate__c, Subprocess__c
			                    FROM Order
			                    WHERE CreditCheckDescription__c='test2Voltura'];

			List<Order> tOrder3=[SELECT Id, Name, AccountId, NotRegisteredMeterCase__c, EffectiveDate__c, VoltureType__c, ImplantType__c, RequestOption__c, PowerCommitted__c, TemporaryConnectionStartDate__c, RecordType.DeveloperName, VATfacilitationFlag__c, FacilitationExcise__c
			                    FROM Order
			                    WHERE CreditCheckDescription__c='test3'];

			List<Order> tOrder4=[SELECT Id, Name, AccountId, NotRegisteredMeterCase__c, EffectiveDate__c, VoltureType__c, ImplantType__c, RequestOption__c, PowerCommitted__c, TemporaryConnectionStartDate__c, RecordType.DeveloperName, VATfacilitationFlag__c, FacilitationExcise__c
			                    FROM Order
			                    WHERE CreditCheckDescription__c='test5Conessione1'];

			try{

				HDT_LC_ChildOrderProcessDetails.updateProcessStep(tOrder1[0], true, true, true, false, date.today());

				HDT_LC_ChildOrderProcessDetails.updateProcessStep(tOrder2[0], true, true, true, false, date.today());

			//	HDT_LC_ChildOrderProcessDetails.updateProcessStep(tOrder2[0], true, false, true, date.today());

				HDT_LC_ChildOrderProcessDetails.updateProcessStep(tOrder3[0], true, true, true, false, date.today());						

			//	HDT_LC_ChildOrderProcessDetails.updateProcessStep(tOrder5[0], false, true, true, date.today());

			} catch (Exception e){

				System.debug('tOrder 3 updateProcessStep Exception : '+e.getMessage());
				System.debug('tOrder 3 updateProcessStep lineNumber : '+e.getLineNumber());

			}

			tOrder2[0].EffectiveDate__c = Date.today().addDays(20);
			update tOrder4;

		    HDT_LC_ChildOrderProcessDetails.updateProcessStep(tOrder2[0], true, true, true, false, date.today());


			Test.stopTest();

			List<Order> tOrderupdated=[SELECT Id, Name, AccountId, NotRegisteredMeterCase__c, EffectiveDate__c, VoltureType__c, ImplantType__c, RequestOption__c, ReadingCustomerDate__c, Subprocess__c
			                           FROM Order
			                           WHERE Name='testOrderName1'
			                           LIMIT 1];

			System.Debug('tOrderupdated[0] = '+tOrderupdated[0]);

			System.assertEquals('Standard', tOrderupdated[0].Subprocess__c, 'Order not found');
			System.assertNotEquals(null, tOrderupdated[0], 'Order not found');
		}
	}

	@isTest
	static void testgetQuoteTypeMtd(){

		User tUser=[SELECT Id, Alias
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			Test.startTest();

			List<Order> tOrderConnessione=[SELECT Id, Name, AccountId, CreditCheckDescription__c, recordType.DeveloperName, PowerRequested__c, PowerCommitted__c, PowerAvailable__c, ServicePoint__r.Distributor__r.Name, RequestPhase__c, ProcessCode__c, ConnectionType__c, VoltageLevel__c, UseTypeEnergy__c, DistributorFormula__c
			                               FROM Order
			                               WHERE CreditCheckDescription__c='test5Conessione1'
			                               LIMIT 1];

			List<Order> tOrderAttivConMod=[SELECT Id, Name, AccountId, CreditCheckDescription__c, recordType.DeveloperName, PowerRequested__c, PowerCommitted__c, PowerAvailable__c, ServicePoint__r.Distributor__r.Name, RequestPhase__c, ProcessCode__c, ConnectionType__c, VoltageLevel__c, UseTypeEnergy__c, DistributorFormula__c
			                               FROM Order
			                               WHERE CreditCheckDescription__c='test4AttivConMod'
			                               LIMIT 1];

			List<Order> tOrderTemporanea=[SELECT Id, Name, AccountId, CreditCheckDescription__c, recordType.DeveloperName, PowerRequested__c, PowerCommitted__c, PowerAvailable__c, ServicePoint__r.Distributor__r.Name, RequestPhase__c, ProcessCode__c, ConnectionType__c, VoltageLevel__c, UseTypeEnergy__c, DistributorFormula__c
			                              FROM Order
			                              WHERE CreditCheckDescription__c='test6Temporanea'
			                              LIMIT 1];


			quoteTypeWrp=HDT_LC_ChildOrderProcessDetails.getQuoteTypeMtd(tOrderAttivConMod[0]);

			quoteTypeWrp=HDT_LC_ChildOrderProcessDetails.getQuoteTypeMtd(tOrderTemporanea[0]);

			tOrderTemporanea[0].PowerRequested__c=1;

			update tOrderTemporanea;

			quoteTypeWrp=HDT_LC_ChildOrderProcessDetails.getQuoteTypeMtd(tOrderTemporanea[0]);

			quoteTypeWrp=HDT_LC_ChildOrderProcessDetails.getQuoteTypeMtd(tOrderConnessione[0]);

			Test.stopTest();

			System.assertEquals(false, quoteTypeWrp.quoteCode==null, 'quoteTypeWrp return is Wrong');
			System.assertNotEquals(true, quoteTypeWrp.quoteCode==null, 'getQuoteTypeMtd did not work correctly');
		}
	}

	@isTest
	static void testretrieveOrderCreditCheck(){

		User tUser=[SELECT Id, Alias
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			Test.startTest();

			List<Order> tOrder=[SELECT Id, Name, AccountId, IncomingCreditCheckResult__c, OutgoingCreditCheckResult__c, CreditCheckDescription__c
			                    FROM Order
			                    WHERE Name='testOrderName0'
			                    LIMIT 1];

			Order retrievedOrderCreditCheck=HDT_LC_ChildOrderProcessDetails.retrieveOrderCreditCheck(tOrder[0].Id);

			Test.stopTest();

			System.assertEquals('test1', retrievedOrderCreditCheck.CreditCheckDescription__c, 'Wrong Order returned');
			System.assertNotEquals('', retrievedOrderCreditCheck.CreditCheckDescription__c, 'retrieveOrderCreditCheck did not work correctly');
		}
	}
    

	@isTest
	static void testvoltureEffectiveDateCheck(){

		User tUser=[SELECT Id, Alias
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			Test.startTest();

			List<Order> tOrder=[SELECT Id, Name, AccountId, EffectiveDate__c
			                    FROM Order
			                    WHERE Name='testOrderName0'
			                    LIMIT 1];

			HDT_LC_ChildOrderProcessDetails.voltureEffectiveDateCheck(tOrder[0].EffectiveDate__c);

			tOrder[0].EffectiveDate__c=Date.today().addDays(10);

			update tOrder;

			Integer voltureEffectiveDataCheckKo=HDT_LC_ChildOrderProcessDetails.voltureEffectiveDateCheck(tOrder[0].EffectiveDate__c);

			
            
			Test.stopTest();

			System.assertEquals(0, voltureEffectiveDataCheckKo, 'Effective Date Check is wrong');
			System.assertNotEquals(1, voltureEffectiveDataCheckKo, 'voltureEffectiveDateCheck did not work correctly');
		}
	}

	@isTest
	static void testgetDates(){

		User tUser=[SELECT Id, Alias
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			Test.startTest();

			List<Order> tOrder=[SELECT Id, Name
			                    FROM Order 
			                    WHERE Name='testOrderName0'
			                    LIMIT 1];

			Order orderGetDates=HDT_LC_ChildOrderProcessDetails.getDates(tOrder[0].Id);

			Test.stopTest();

			System.assertEquals(false, orderGetDates.Id==null, 'Order returned is Wrong');
			System.assertNotEquals(true, orderGetDates.Id==null, 'getDates did not work correctly');
		}
	}

	@isTest
	static void testupdateProcessStep2(){

		User tUser=[SELECT Id, Alias
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			Test.startTest();

			List<Order> tOrder1=[SELECT Id, Name, EffectiveDate__c, VoltureType__c, ImplantType__c, RequestOption__c, PowerCommitted__c, TemporaryConnectionStartDate__c, TemporaryConnectionEndDate__c, RecordType.DeveloperName, VATfacilitationFlag__c, FacilitationExcise__c
			                    FROM Order
								WHERE RecordType.DeveloperName != 'HDT_RT_TemporaneaNuovaAtt'
								AND ImplantType__c != null
								AND PowerCommitted__c != null
			                    LIMIT 1];

			try{

				HDT_LC_ChildOrderProcessDetails.updateProcessStep(tOrder1[0], true, true, true, date.today());

			} catch (Exception e){

				System.debug('tOrder updateProcessStep Exception : '+e.getMessage());

			}
            
			Test.stopTest();


			System.assert(tOrder1 != null, 'The Order is null');
		}
	}

	@isTest
	static void isPreventivoTest(){

		Test.startTest();

			List<Order> tOrder=[SELECT Id, Name
			                    FROM Order 
			                    WHERE Name='testOrderName0'
								AND QuotationType__c = 'Rapido'
			                    LIMIT 1];

			Boolean tipoPreventivo = HDT_LC_ChildOrderProcessDetails.isPreventivo(tOrder[0]);

			Test.stopTest();
			System.assertEquals(true, tipoPreventivo, 'Order non preventivo');
	}
    
    @isTest
	static void testretrieveOrderCreditCheckTwo(){

		User tUser=[SELECT Id, Alias
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			Test.startTest();

			List<OrderItem> tOrderItem=[SELECT id, ServicePoint__c, OrderId, Product2Id, PricebookEntryId, UnitPrice, Quantity, Description, OwnerAC__c, DwellingType__c, Surface__c, OccupantsNumber__c, SBQQ__QuoteLine__c
			                    FROM OrderItem
			                    LIMIT 1];

			HDT_LC_ChildOrderProcessDetails.updateProcessStep(tOrderItem[0], false, false, false, false, date.today());

			List<Order> orders = [SELECT Id, Step__c FROM Order WHERE Id=:tOrderItem[0].OrderId LIMIT 1];

			Test.stopTest();
            
            

			System.assertEquals(1, orders[0].Step__c, 'Wrong Step');
			//System.assertNotEquals('', retrievedOrderCreditCheck.CreditCheckDescription__c, 'retrieveOrderCreditCheck did not work correctly');
		}
	}

	@isTest
	static void checkTechnicalTransferTst()
	{
		HDT_WRP_VoltureChangeManager.HDT_WRP_TransferCheck testWrp = new HDT_WRP_VoltureChangeManager.HDT_WRP_TransferCheck();
		HDT_WRP_VoltureChangeManager.HDT_WRP_TransferCheck testWrpErr = new HDT_WRP_VoltureChangeManager.HDT_WRP_TransferCheck();

		testWrp.firstName = 'Nome';
		testWrp.lastName = 'Cognome';
		testWrp.fiscalCode = '';
		testWrp.vatNumber = 'TestVat';
		testWrp.ragSoc ='OK';

		testWrpErr.firstName = 'Nome';
		testWrpErr.lastName = 'Cognome';
		testWrpErr.fiscalCode = '';
		testWrpErr.vatNumber = 'TestVat';
		testWrpErr.ragSoc ='';

		Test.startTest();
			HDT_WRP_VoltureChangeManager.HDT_WRP_ProcessCheck resultWrp = HDT_LC_ChildOrderProcessDetails.checkTechnicalTransfer(testWrp);
			HDT_WRP_VoltureChangeManager.HDT_WRP_ProcessCheck resultWrpErr = HDT_LC_ChildOrderProcessDetails.checkTechnicalTransfer(testWrpErr);
		Test.stopTest();

		System.assertEquals('', resultWrp.result, 'Check incorretto');
		System.assertEquals(true, String.isNotBlank(resultWrpErr.result), 'Errore incorretto');

	}
}