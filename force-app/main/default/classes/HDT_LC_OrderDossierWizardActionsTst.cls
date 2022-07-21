/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 22/07/2021
 * @description Test Class for HDT_LC_OrderDossierWizardActions.cls
 * @history Fabricio Petkevicius Nunes ? 22/07/2021 ? Created class
 */
@isTest
public class HDT_LC_OrderDossierWizardActionsTst{
	@TestSetup
	static void setup(){

		HDT_UTL_Constants constRecordType=new HDT_UTL_Constants();

		Id rt=constRecordType.ORDER_RECORDTYPEID_ORDERDOSSIER;

		HDT_UTL_DataFactoryTst.pClickOrderPhase();        
		HDT_UTL_DataFactoryTst.newPhaseTransition('Documentazione Gestita','Documentazione da validare',rt,'HDT_RT_OrderDossier');
        HDT_UTL_DataFactoryTst.newPhaseTransition('Documentazione da validare','Bozza',rt,'HDT_RT_OrderDossier');
		HDT_UTL_DataFactoryTst.newPhaseTransition('Documentazione da validare','In Lavorazione',rt,'HDT_RT_OrderDossier');
        HDT_UTL_DataFactoryTst.newPhaseTransition('Bozza','Documentazione da validare',rt,'HDT_RT_OrderDossier');
        HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa validazione','Bozza',rt,'HDT_RT_OrderDossier');
        HDT_UTL_DataFactoryTst.newPhaseTransition('Documentazione da inviare','Bozza',rt,'HDT_RT_OrderDossier');
		HDT_UTL_DataFactoryTst.newPhaseTransition('In Lavorazione','Bozza',rt,'HDT_RT_OrderDossier');
        HDT_UTL_DataFactoryTst.newPhaseTransition('Documentazione da validare','Documentazione da inviare',rt,'HDT_RT_OrderDossier');
        HDT_UTL_DataFactoryTst.newPhaseTransition('Documentazione da inviare','Documentazione da validare',rt,'HDT_RT_OrderDossier');
        HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa validazione','Bozza',Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_VolturaConSwitch').getRecordTypeId(),'HDT_RT_VolturaConSwitch');
		HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa conferma cliente','Bozza',Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_VolturaConSwitch').getRecordTypeId(),'HDT_RT_VolturaConSwitch');
		List<Account> accList=HDT_UTL_DataFactoryTst.createAccountResidenziale(1, true, 'HERA COMM', 'D1 - Persona fisica', 'Famiglie');
        
		List<Sale__c> saleList=HDT_UTL_DataFactoryTst.createSale(1, true, accList[0].Id, 'Attiva');

        List<Product2> products = HDT_UTL_DataFactoryTst.createProduct2(1, true);
        
		List<Contact> contactList=HDT_UTL_DataFactoryTst.createContact(1, false, accList[0].Id);
		contactList[0].CompanyOwner__c='HERA COMM';
		contactList[0].Company__c='HC';
		insert contactList;
        
		List<Order> orderList=HDT_UTL_DataFactoryTst.createOrder(1, false, accList[0].Id, 'Bozza');
		orderList[0].RecordTypeId=rt;
		orderList[0].Contact__c=contactList[0].Id;
		orderList[0].ProcessType__c='To define';
        orderList[0].CommercialProductLink__c = products[0].id;
		insert orderList;

		List<Order> childOrderList=HDT_UTL_DataFactoryTst.createChildOrder(2, false, accList[0].Id, saleList, orderList[0].Id, contactList[0].Id);
        childOrderList[0].RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_VolturaConSwitch').getRecordTypeId();
        childOrderList[0].ComfortCallDaysDue__c = null;
		childOrderList[0].Contact__c=contactList[0].Id;
        insert childOrderList;

		AmministrazioneFrodi__c amList = new AmministrazioneFrodi__c();
		amList.Processo__c = 'Voltura';
		amList.CanaleVendita__c = 'Agenzie';
		amList.CategoriaCliente__c = 'Famiglie';
		amList.BpNumber__c = 1;
		insert amList;
		//'sales@force.com'
		//982591380
		List<Individual> indList = HDT_UTL_DataFactoryTst.createIndividual(1,true);
		HDT_UTL_DataFactoryTst.createContactPointPhone(1, true, indList[0].Id);
		HDT_UTL_DataFactoryTst.createContactPointEmail(1, true, indList[0].Id);


	}

	@isTest static void testSave1(){

		Order ord = [SELECT Id, Phase__c, ContractSigned__c, SignatureMethod__c FROM Order LIMIT 1];
        Id ordId = ord.id;
        
		HDT_LC_OrderDossierWizardActions.save(ord);
        
        ord = [SELECT Id, Phase__c, ContractSigned__c, SignatureMethod__c FROM Order WHERE Id =: ordId];
        
        System.assertEquals('Documentazione da validare', ord.Phase__c, 'save did not work correctly');
		System.assertNotEquals('Bozza', ord.Phase__c, 'save did not work correctly');
	}
    
    @isTest static void testSave1False(){

		Order ord = [SELECT Id, Phase__c, ContractSigned__c, SignatureMethod__c FROM Order LIMIT 1];
        Id ordId = ord.id;
        
        ord.ContractSigned__c = false;
        
		HDT_LC_OrderDossierWizardActions.save(ord);
        
        ord = [SELECT Id, Phase__c, ContractSigned__c, SignatureMethod__c FROM Order WHERE Id =: ordId];
        
        System.assertEquals('Documentazione da inviare', ord.Phase__c, 'save did not work correctly');
		System.assertNotEquals('Bozza', ord.Phase__c, 'save did not work correctly');
	}
    
    @isTest static void testSave2(){

		Order ord = [SELECT Id, SignMode__c, SignatureMethod__c,Phase__c, ContractSigned__c FROM Order LIMIT 1];
        Id ordId = ord.id;
        
        ord.Phase__c = 'In Lavorazione';
		update ord;
        
		HDT_LC_OrderDossierWizardActions.save2(ord, null);
        
        ord = [SELECT Id, Phase__c, ContractSigned__c FROM Order WHERE Id =: ordId];
        
		System.assertNotEquals('Bozza', ord.Phase__c, 'save did not work correctly');
	}
    
    @isTest static void testCreateActivityVocalOrder(){
        
        Order ord = [SELECT Id, Phase__c, ContractSigned__c FROM Order LIMIT 1];
        
        ord.SignatureMethod__c ='Vocal Order';
        ord.Phase__c = 'In Lavorazione';
        ord.ContractSigned__c = false;
		String phaseContent = '';
        
        String phase = HDT_LC_OrderDossierWizardActions.createActivityVocalOrder(ord);
        if(phase.contains('Documentazione da inviare')){
			phaseContent = 'Documentazione da inviare';
		}
		else {
			phaseContent = '';
		}

        System.assertEquals('Documentazione da inviare', phaseContent, 'save did not work correctly');
		System.assertNotEquals('Bozza', phase, 'save did not work correctly');
        
        ord.ContractSigned__c = true;
        phase = HDT_LC_OrderDossierWizardActions.createActivityVocalOrder(ord);
        
		if(phase.contains('Documentazione da validare')){
			phaseContent = 'Documentazione da validare';
		}
		else {
			phaseContent = '';
		}

        System.assertEquals('Documentazione da validare', phaseContent, 'save did not work correctly');
		System.assertNotEquals('Bozza', phase, 'save did not work correctly');
        
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

		List<Order> torderList=[SELECT Id, Phase__c, ContractSigned__c, AutorizationVolturaThirdTrader__c, CILegalRepresentative__c, CIAccoutn__c, QuickQuote__c, ChamberCommerceRegistration__c, Instance326__c, DocumentLow80__c, DocumentPackage__c
		                        FROM Order
		                        WHERE Phase__c='Bozza'
		                        LIMIT 1];
		

		torderList[0].CILegalRepresentative__c = 'Non Validato';
        torderList[0].DocumentPackage__c = 'Non Validato';

		Boolean check=HDT_LC_OrderDossierWizardActions.checkRequiredDocs(torderList[0]);

		System.debug('check = '+check);

		System.assertEquals(false, check, 'Return is Wrong');

		System.assertNotEquals(true, check, 'checkRequiredDocs did not work correctly');

		Test.stopTest();
	}
    
	@isTest static void testcheckRequiredDocsTrue(){

		Test.startTest();

		List<Order> torderList=[SELECT Id, Phase__c, ContractSigned__c, AutorizationVolturaThirdTrader__c, CILegalRepresentative__c, CIAccoutn__c, QuickQuote__c, ChamberCommerceRegistration__c, Instance326__c, DocumentLow80__c, DocumentPackage__c
		                        FROM Order
		                        WHERE Phase__c='Bozza'
		                        LIMIT 1];
		

		torderList[0].CILegalRepresentative__c = null;
        torderList[0].DocumentPackage__c = null;
        torderList[0].AutorizationVolturaThirdTrader__c = null;
        torderList[0].CIAccoutn__c = null;
        torderList[0].QuickQuote__c = null;
        torderList[0].ChamberCommerceRegistration__c = null;
        torderList[0].Instance326__c = null;
        torderList[0].DocumentLow80__c = null;

		Boolean check=HDT_LC_OrderDossierWizardActions.checkRequiredDocs(torderList[0]);
        
		System.assertEquals(true, check, 'Return is Wrong');

		System.assertNotEquals(null, check, 'checkRequiredDocs did not work correctly');

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

	@isTest static void testGetActivePicklistValue(){

		List<String> activeValue = HDT_LC_OrderDossierWizardActions.getActivePicklistValue('Order', 'SignMode__c');
        
        System.assert(activeValue != null, 'Non sono stati trovati i valori nella picklist');
	}	
	
	@isTest static void testGetActivePicklistValueError(){

		List<String> activeValue = HDT_LC_OrderDossierWizardActions.getActivePicklistValue('Orderr', 'SignMode__c');
        
        System.assert(activeValue.isEmpty(), 'Gestione dell\'errore non funzionante.');
	}

	@IsTest
	static void seekFraudTestOne()
	{
		//'sales@force.com'
		//982591380
		List<Order> orderList = [SELECT Id, Contact__c, ParentOrder__c FROM Order WHERE ParentOrder__c != null AND Contact__c != NULL];
		orderList[0].PhoneNumber__c = '982591380';
		orderList[0].ShippingMail__c = 'sales@force.com';
		orderList[0].ProcessType__c = 'Voltura';
		List<Contact> contactList = [Select Id FROM Contact WHERE Id = :orderList[0].Contact__c];
		contactList[0].HomePhone = '982591380';
		contactList[0].Phone = '982591380';
		contactList[0].Email = 'sales@force.com';
		List<Order> parentOrder = [Select Id FROM Order WHERE Id = :orderList[0].ParentOrder__c];
		parentOrder[0].Channel__c = 'Agenzie';
		List<SObject> sobj = new List<SObject>();
		sobj.add(contactList[0]);
		sobj.add(orderList[0]);
		sobj.add(parentOrder[0]);
		update sobj;
		Test.startTest();
			String result = HDT_LC_OrderDossierWizardActions.seekFraud(parentOrder[0].Id, parentOrder[0]); 
		Test.stopTest();
		System.assertEquals(true, String.isNotBlank(result), 'Controllo Frode Fallito');
	}
	@IsTest
	static void seekFraudTestTwo()
	{
		//'sales@force.com'
		//982591380
		List<Order> orderList = [SELECT Id, Contact__c, ParentOrder__c FROM Order WHERE ParentOrder__c != null AND Contact__c != NULL];
		orderList[0].PhoneNumber__c = '982591380';
		orderList[0].ShippingMail__c = 'sales@force.com';
		orderList[0].ProcessType__c = 'Voltura';
		List<Contact> contactList = [Select Id FROM Contact WHERE Id = :orderList[0].Contact__c];
		contactList[0].HomePhone = '982591380';
		contactList[0].Phone = '982591380';
		contactList[0].Email = 'sales@force.com';
		List<Order> parentOrder = [Select Id FROM Order WHERE Id = :orderList[0].ParentOrder__c];
		parentOrder[0].Channel__c = 'Agenzie';
		parentOrder[0].PhoneNumber__c = '982591380';
		parentOrder[0].ShippingMail__c = 'sales@force.com';
		List<SObject> sobj = new List<SObject>();
		sobj.add(contactList[0]);
		sobj.add(orderList[0]);
		sobj.add(parentOrder[0]);
		update sobj;
		Test.startTest();
			String result = HDT_LC_OrderDossierWizardActions.seekFraud(parentOrder[0].Id, null); 
		Test.stopTest();
		System.assertEquals(true, String.isNotBlank(result), 'Controllo Frode Fallito');
	}
	@isTest
	static void getPicklistValueTst()
	{
		Test.startTest();
			List<String> result = HDT_LC_OrderDossierWizardActions.getActivePicklistValue('Case', 'Type');
		Test.stopTest();
		System.assertEquals(true, !result.isEmpty(), 'Valori non trovati');
	}
	@isTest
	static void isCancelDisabledTst()
	{
		List<Order> parentOrder = [Select Id FROM Order WHERE ParentOrder__c = NULL];
		Test.startTest();
			Boolean result = HDT_LC_OrderDossierWizardActions.isCancelDisabled(parentOrder[0]);
		Test.stopTest();
		System.assertEquals(false, result, 'Annullamento disabilitato');
	}
	@isTest
	static void isOnlyAmendTst()
	{
		List<Order> parentOrder = [Select Id FROM Order WHERE ParentOrder__c = NULL];
		List<Order> childOrders = [SELECT Id FROM Order WHERE ParentOrder__c != NULL];
		for(Order o : childOrders)
		{
			o.Type = 'New';
		}
		update childOrders;
		Test.startTest();
			Boolean result = HDT_LC_OrderDossierWizardActions.isOnlyAmend(parentOrder[0]);
		Test.stopTest();
		System.assertEquals(false, result, 'Annullamento disabilitato');
	}

}