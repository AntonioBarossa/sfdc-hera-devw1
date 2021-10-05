/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 09/08/2021
 * @description HDT_TRH_DocumentalActivity Test Classes
 * @history Fabricio Petkevicius Nunes – 9/08/2021 – Created class
 */
@isTest
public with sharing class HDT_TRH_DocumentalActivityTst{
	@isTest
	public static void testTriggerDocActivityBeforeInsert(){

		Test.startTest();

		List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
		List<Contact> contacts=HDT_UTL_DataFactoryTst.createContact(1, true, accounts[0].Id);
		List<ServicePoint__c> servPoints=HDT_UTL_DataFactoryTst.createServicePoint(1, true);
		List<Contract> contracts=HDT_UTL_DataFactoryTst.createContract(1, true, accounts[0].Id);
		List<Order> orders=HDT_UTL_DataFactoryTst.createOrder(1, true, accounts[0].Id, 'Bozza');
		List<Case> cases=HDT_UTL_DataFactoryTst.createCase(1, true, accounts[0].Id, contacts[0].Id, servPoints[0].Id, contracts[0].Id, orders[0].Id);
		List<DocumentalActivity__c> docActivities=new List<DocumentalActivity__c>();
		DocumentalActivity__c docActivity=new DocumentalActivity__c();
		docActivity.OrderId__c=orders[0].id;
		docActivity.CaseId__c=cases[0].Id;
		docActivity.ParentProcessId__c=cases[0].Id;
		docActivity.ProcessId__c=orders[0].Id;

		docActivities.add(docActivity);

		insert docActivities;

		System.debug('docActivities = '+docActivities);

		DocumentalActivity__c testDocActivity=[SELECT Id, CaseId__c
		                                       FROM DocumentalActivity__c
		                                       WHERE CaseId__c=:cases[0].Id
		                                       LIMIT 1];

		System.assertEquals(cases[0].Id, testDocActivity.CaseId__c, 'Document Activity not Inserted');
		System.assertNotEquals('', testDocActivity.CaseId__c, 'Attenzione!');
		Test.stopTest();
	}
}