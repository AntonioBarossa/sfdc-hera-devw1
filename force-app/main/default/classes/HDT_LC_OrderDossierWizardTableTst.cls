/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 23/07/2021
 * @description Test Class for HDT_LC_OrderDossierWizardTable.cls
 * @history Fabricio Petkevicius Nunes – 23/07/2021 – Created class
 */
@isTest
public class HDT_LC_OrderDossierWizardTableTst{
	@TestSetup
	static void setup(){

		HDT_UTL_Constants constRecordType=new HDT_UTL_Constants();

		Id rt=constRecordType.ORDER_RECORDTYPEID_ORDERDOSSIER;
		Id rtVoltura=constRecordType.ORDER_RECORDTYPEID_VOLTURA;

		HDT_UTL_DataFactoryTst.pClickOrderPhase();

		insert new Wrts_prcgvr__PhaseTransition__c(Wrts_prcgvr__Code__c=Math.random()+'', Wrts_prcgvr__DestinationPhase__c='Documentazione da validare', Wrts_prcgvr__OriginPhase__c='Bozza', Wrts_prcgvr__RecordTypeId__c=rt, Wrts_prcgvr__RecordTypeName__c='HDT_RT_OrderDossier', Wrts_prcgvr__Type__c='A');


		insert new Wrts_prcgvr__PhaseTransition__c(Wrts_prcgvr__Code__c=Math.random()+'', Wrts_prcgvr__DestinationPhase__c='In attesa validazione', Wrts_prcgvr__OriginPhase__c='Bozza', Wrts_prcgvr__RecordTypeId__c=rt, Wrts_prcgvr__RecordTypeName__c='HDT_RT_OrderDossier', Wrts_prcgvr__Type__c='A');


		insert new Wrts_prcgvr__PhaseTransition__c(Wrts_prcgvr__Code__c=Math.random()+'', Wrts_prcgvr__DestinationPhase__c='In attesa validazione', Wrts_prcgvr__OriginPhase__c='Bozza', Wrts_prcgvr__RecordTypeId__c=rtVoltura, Wrts_prcgvr__RecordTypeName__c='HDT_RT_Voltura', Wrts_prcgvr__Type__c='A');


		insert new Wrts_prcgvr__PhaseTransition__c(Wrts_prcgvr__Code__c=Math.random()+'', Wrts_prcgvr__DestinationPhase__c='Bozza', Wrts_prcgvr__OriginPhase__c='Documentazione da validare', Wrts_prcgvr__RecordTypeId__c=rt, Wrts_prcgvr__RecordTypeName__c='HDT_RT_OrderDossier', Wrts_prcgvr__Type__c='A');


		insert new Wrts_prcgvr__PhaseTransition__c(Wrts_prcgvr__Code__c=Math.random()+'', Wrts_prcgvr__DestinationPhase__c='Documentazione da inviare', Wrts_prcgvr__OriginPhase__c='Bozza', Wrts_prcgvr__RecordTypeId__c=rt, Wrts_prcgvr__RecordTypeName__c='HDT_RT_OrderDossier', Wrts_prcgvr__Type__c='A');


		List<Account> accList=HDT_UTL_DataFactoryTst.createAccountResidenziale(1, true, 'HERA COMM', 'D1 - Persona fisica', 'Enti');
		List<Sale__c> saleList=HDT_UTL_DataFactoryTst.createSale(1, true, accList[0].Id, 'Attiva');
		List<Order> orderList=HDT_UTL_DataFactoryTst.createOrder(1, false, accList[0].Id, 'Bozza');
		List<Contact> contactList=HDT_UTL_DataFactoryTst.createContact(1, false, accList[0].Id);

		contactList[0].CompanyOwner__c='HERA COMM';
		contactList[0].Company__c='HC';

		insert contactList;

		orderList[0].RecordTypeId=rt;
		orderList[0].ContractSigned__c=true;
		orderList[0].Contact__c=contactList[0].Id;
		orderList[0].ProcessType__c='To define';

		insert orderList;

		List<Order> childOrderList=HDT_UTL_DataFactoryTst.createChildOrder(1, true, accList[0].Id, saleList, orderList[0].Id, contactList[0].Id);

		System.debug('orderList = '+orderList);
		System.debug('childOrderList = '+childOrderList);
	}

	@isTest
	static void testTableData(){

		Test.startTest();

		List<Order> torderList=[SELECT Id, Phase__c, ContractSigned__c
		                        FROM Order
		                        WHERE ParentOrder__c = null
		                        LIMIT 1];

		Map<String, Object> testgetTableData=HDT_LC_OrderDossierWizardTable.getTableData(torderList[0].Id);

		System.assertEquals(true, testgetTableData.get('childOrdersList') != null, 'Result Map is Wrong');

		System.assertNotEquals(0, testgetTableData.values().size(), 'getTableData did not work correctly');

		Test.stopTest();
	}

	@isTest
	static void testnext(){

		Test.startTest();

		List<Order> torderList=[SELECT Id, Phase__c
		                        FROM Order
		                        WHERE Phase__c='Bozza'
		                        LIMIT 1];


		HDT_LC_OrderDossierWizardTable.next(torderList[0]);

		List<Order> torderList2=[SELECT Id, Step__c
		                         FROM Order
		                         WHERE Step__c=3
		                         LIMIT 1];

		System.assertEquals(3, torderList2[0].Step__c, 'Order was not updated');

		System.assertNotEquals(0, torderList2[0].Step__c, 'next did not work correctly');

		Test.stopTest();
	}

	@isTest
	static void testedit(){

		Test.startTest();

		List<Order> torderList=[SELECT Id, Phase__c
		                        FROM Order
		                        WHERE Phase__c='Bozza'
		                        LIMIT 1];


		HDT_LC_OrderDossierWizardTable.edit(torderList[0].Id);

		List<Order> torderList2=[SELECT Id, Step__c
		                         FROM Order
		                         WHERE Step__c=2
		                         LIMIT 1];

		System.assertEquals(2, torderList2[0].Step__c, 'Order was not updated');

		System.assertNotEquals(0, torderList2[0].Step__c, 'edit did not work correctly');

		Test.stopTest();
	}
}