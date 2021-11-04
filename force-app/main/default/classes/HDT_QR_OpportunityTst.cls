/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 03/08/2021
 * @description Test Class for HDT_QR_Opportunity.cls
 * @history Fabricio Petkevicius Nunes – 03/08/2021 – Created class
 */
@isTest
public class HDT_QR_OpportunityTst{
	@TestSetup
	static void setup(){

		HDT_UTL_DataFactoryTst.pClickInstance();
		HDT_UTL_DataFactoryTst.pClickOrderPhase();

		List<Account> tAccount=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
		List<Sale__c> tSale=HDT_UTL_DataFactoryTst.createSale(1, true, tAccount[0].Id, 'Attiva');
		List<Opportunity> tOpp=HDT_UTL_DataFactoryTst.createOpportunity(1, false);
		tOpp[0].Sale__c=tsale[0].Id;

		insert tOpp;


		List<Contract> tContract=HDT_UTL_DataFactoryTst.createContract(1, true, tAccount[0].Id);

		List<Order> tOrder=HDT_UTL_DataFactoryTst.createOrder(1, false, tAccount[0].Id, tSale[0].Id);
		tOrder[0].Phase__c='Bozza';

		insert tOrder;

		List<SBQQ__Quote__c> tQuote=HDT_UTL_DataFactoryTst.createQuote(1, false, tOrder[0].Id, topp[0].Id, tSale[0].Id, 'Amendment');

		tQuote[0].IsVAS__c=true;
		tquote[0].OrderReference__c=tOrder[0].Id;
		tquote[0].ContractReference__c=tContract[0].Id;
		tQuote[0].SupplyCity__c='Roma';

		insert tQuote;

		// List<SBQQ__Quote__c> quoteLst = [SELECT IsVas__c, SupplyCity__c FROM SBQQ__Quote__c WHERE Id=:tquote[0].Id];
		// System.debug('quoteLst = '+quoteLst);

		topp[0].SBQQ__PrimaryQuote__c=tQuote[0].Id;

		update tOpp;
		//    List<Opportunity> oppLst = [SELECT StageName, SBQQ__PrimaryQuote__r.IsVAS__c FROM Opportunity WHERE Sale__c =: tSale[0].Id];
		//     System.debug('oppLst = '+oppLst);
	}

	@isTest
	static void testcountRecordsBySale(){

		Test.startTest();

		Sale__c saleTst=[SELECT Id, Status__c
		                 FROM Sale__c
		                 WHERE Status__c='Attiva'
		                 LIMIT 1];

		HDT_QR_Opportunity oppQr=new HDT_QR_Opportunity();


		integer methodRet=oppQr.countRecordsBySale(saleTst.Id);

		System.debug('methodRet = '+methodRet);


		System.assertEquals(1, methodRet, 'Return is wrong');

		System.assertNotEquals(0, methodRet, 'Value of parameter is not matching');

		Test.stopTest();
	}

	@isTest
	static void testgetRecordsBySaleFilterStageName(){

		Test.startTest();

		Sale__c saleTst=[SELECT Id, Status__c
		                 FROM Sale__c
		                 WHERE Status__c='Attiva'
		                 LIMIT 1];

		HDT_QR_Opportunity oppQr=new HDT_QR_Opportunity();

		string stageName='Negotiation';
		string fields='StageName';


		List<Opportunity> methodRet=oppQr.getRecordsBySaleFilterStageName(saleTst.Id, fields, stageName);

		System.debug('methodRet = '+methodRet);


		System.assertEquals('Negotiation', methodRet[0].StageName, 'Return is wrong');

		System.assertNotEquals('', methodRet[0].StageName, 'Value of parameter is not matching');

		Test.stopTest();
	}

	@isTest
	static void testgetRecordsBySaleFilterStageNameNotVas(){

		Test.startTest();

		Sale__c saleTst=[SELECT Id, Status__c
		                 FROM Sale__c
		                 WHERE Status__c='Attiva'
		                 LIMIT 1];
		
		Order ordTst=[SELECT Id
		FROM Order
		LIMIT 1];

		Opportunity oppTst=[SELECT Id, SBQQ__PrimaryQuote__c
		FROM Opportunity
		LIMIT 1];
		
		List<SBQQ__Quote__c> tQuote= HDT_UTL_DataFactoryTst.createQuote(1, true, ordTst.Id, oppTst.Id, saleTst.Id, 'Quote');
		oppTst.SBQQ__PrimaryQuote__c = tQuote[0].Id;
		update oppTst;


		HDT_QR_Opportunity oppQr=new HDT_QR_Opportunity();

		string stageName='NotNegotiation';
		string fields='StageName';

		List<Opportunity> methodRet=oppQr.getRecordsBySaleFilterStageNameNotVas(saleTst.Id, fields, stageName);

		// Cannot insert IsVas= null, return is always empty

		System.assertEquals(1, methodRet.size(), 'Return is wrong');

		System.assertNotEquals(0, methodRet.size(), 'Value of parameter is not matching');

		Test.stopTest();
	}

	@isTest
	static void testgetRecordById(){

		Test.startTest();

		Opportunity oppTst=[SELECT Id, StageName, SBQQ__PrimaryQuote__c
		                    FROM Opportunity
		                    WHERE StageName='Negotiation'
		                    LIMIT 1];


		HDT_QR_Opportunity oppQr=new HDT_QR_Opportunity();

		Opportunity methodRet=oppQr.getRecordById(oppTst.Id);

		System.debug('methodRet = '+methodRet);


		System.assertEquals('Negotiation', methodRet.StageName, 'Return is wrong');

		System.assertNotEquals('', methodRet.StageName, 'Value of parameter is not matching');

		Test.stopTest();
	}

	@isTest
	static void testgetRecordByIdFilterStatus(){

		Test.startTest();

		Opportunity oppTst=[SELECT Id, StageName, SBQQ__PrimaryQuote__c
		                    FROM Opportunity
		                    WHERE StageName='Negotiation'
		                    LIMIT 1];


		HDT_QR_Opportunity oppQr=new HDT_QR_Opportunity();

		Opportunity methodRet=oppQr.getRecordByIdFilterStatus(oppTst.Id, 'Proposal');

		System.debug('methodRet = '+methodRet);


		System.assertEquals('Negotiation', methodRet.StageName, 'Return is wrong');

		System.assertNotEquals('', methodRet.StageName, 'Value of parameter is not matching');

		Test.stopTest();
	}

	@isTest
	static void testgetRecordsBySaleFilteredVas(){

		Test.startTest();

		Sale__c saleTst=[SELECT Id, Status__c
		                 FROM Sale__c
		                 WHERE Status__c='Attiva'
		                 LIMIT 1];

		HDT_QR_Opportunity oppQr=new HDT_QR_Opportunity();


		List<Opportunity> methodRet=oppQr.getRecordsBySaleFilteredVas(saleTst.Id);

		System.debug('methodRet = '+methodRet);


		System.assertEquals('Roma', methodRet[0].SBQQ__PrimaryQuote__r.SupplyCity__c, 'Return is wrong');

		System.assertNotEquals('0', methodRet[0].SBQQ__PrimaryQuote__r.SupplyCity__c, 'Value of parameter is not matching');

		Test.stopTest();
	}

	@isTest
	static void testgetRecordByQuote(){

		Test.startTest();

		SBQQ__Quote__c quoteTst=[SELECT Id, SBQQ__Type__c
		                         FROM SBQQ__Quote__c
		                         WHERE SBQQ__Type__c='Amendment'
		                         LIMIT 1];

		HDT_QR_Opportunity oppQr=new HDT_QR_Opportunity();


		List<Opportunity> methodRet=oppQr.getRecordByQuote(quoteTst.Id);

		System.debug('methodRet = '+methodRet);


		System.assertEquals(1, methodRet.size(), 'Return is wrong');

		System.assertNotEquals(0, methodRet.size(), 'Value of parameter is not matching');

		Test.stopTest();
	}
}