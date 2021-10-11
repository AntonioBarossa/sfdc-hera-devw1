/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 09/08/2021
 * @description HDT_TRH_Sale for Test Classes
 * @history Fabricio Petkevicius Nunes – 9/08/2021 – Created class
 */
@isTest
public with sharing class HDT_TRH_SaleTst{
	@isTest
	public static void testTriggerSaleBeforeInsert(){

		Test.startTest();

		List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
		List<Sale__c> sales=HDT_UTL_DataFactoryTst.createSale(1, true, accounts[0].Id, 'Attiva');

		System.debug('sales = '+sales);

		Sale__c testSale=[SELECT Id, Name, Status__c
		                  FROM Sale__c
		                  WHERE Status__c='Attiva' AND Name='testSaleName0'
		                  LIMIT 1];

		System.assertEquals('testSaleName0', testSale.Name, 'Sale not Inserted');
		System.assertNotEquals('', testSale.Name, 'Sale not Inserted');
		Test.stopTest();
        
	}
}