/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 22/07/2021
 * @description Test Class for HDT_LC_OrderDossierWizardActions.cls
 * @history Fabricio Petkevicius Nunes – 22/07/2021 – Created class
 */
@isTest
public class HDT_LC_OrderDossierWizardActionsTst{
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
	static void testSave(){

		Test.startTest();

		List<Order> torderList=[SELECT Id, Phase__c, ContractSigned__c
		                        FROM Order
		                        WHERE Phase__c='Bozza'
		                        LIMIT 1];

		HDT_LC_OrderDossierWizardActions.save(torderList[0]);

		torderList[0].ContractSigned__c=false;

		update torderList;

		HDT_LC_OrderDossierWizardActions.save(torderList[0]);


		List<Order> torderList2=[SELECT Id, Phase__c, ContractSigned__c
		                         FROM Order
		                         WHERE Phase__c='In attesa validazione'
		                         LIMIT 1];

		System.assertEquals('In attesa validazione', torderList2[0].Phase__c, 'Order was not updated');

		System.assertNotEquals('', torderList2[0].Phase__c, 'save did not work correctly');

		Test.stopTest();
	}

	@isTest
	static void testcancel(){

		Test.startTest();

		List<Order> torderList=[SELECT Id, Phase__c, ContractSigned__c
		                        FROM Order
		                        WHERE Phase__c='Bozza'
		                        LIMIT 1];


		torderList[0].CancellationReason__c='Pratica errata';

		update torderList;

		HDT_LC_OrderDossierWizardActions.cancel(torderList[0], torderList[0].CancellationReason__c);

		List<Order> torderList2=[SELECT Id, Phase__c, ContractSigned__c
		                         FROM Order
		                         WHERE Phase__c='Annullato'
		                         LIMIT 1];


		System.assertEquals('Annullato', torderList2[0].Phase__c, 'Order was not updated');

		System.assertNotEquals('', torderList2[0].Phase__c, 'cancel did not work correctly');

		Test.stopTest();
	}

	@isTest
	static void testcheckRequiredDocs(){

		Test.startTest();

		List<Order> torderList=[SELECT Id, Phase__c, ContractSigned__c, AutorizationVolturaThirdTrader__c, CILegalRepresentative__c, CIAccoutn__c, QuickQuote__c, ChamberCommerceRegistration__c, Instance326__c, DocumentLow80__c
		                        FROM Order
		                        WHERE Phase__c='Bozza'
		                        LIMIT 1];


		update torderList;

		Boolean check=HDT_LC_OrderDossierWizardActions.checkRequiredDocs(torderList[0]);

		System.debug('check = '+check);

		System.assertEquals(false, check, 'Return is Wrong');

		System.assertNotEquals(true, check, 'checkRequiredDocs did not work correctly');

		Test.stopTest();
	}

	@isTest
	static void testisSaveDisabled(){

		Test.startTest();

		List<Order> torderList=[SELECT Id, Phase__c, ContractSigned__c, AutorizationVolturaThirdTrader__c, CILegalRepresentative__c, CIAccoutn__c, QuickQuote__c, ChamberCommerceRegistration__c, Instance326__c, DocumentLow80__c
		                        FROM Order
		                        WHERE Phase__c='Bozza'
		                        LIMIT 1];


		Boolean result=HDT_LC_OrderDossierWizardActions.isSaveDisabled(torderList[0]);

		System.debug('result = '+result);

		System.assertEquals(true, result, 'Return is Wrong');

		System.assertNotEquals(false, result, 'isSaveDisabled did not work correctly');

		Test.stopTest();
	}
}