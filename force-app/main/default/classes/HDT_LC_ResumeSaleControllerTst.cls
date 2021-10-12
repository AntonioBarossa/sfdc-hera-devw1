/**
 * @author Fabricio Nunes (fabricio.nunes@engdb.com.br)
 * @date 19/07/2021
 * @description HDT_LC_ResumeSaleController Test Class
 * @history Fabricio Nunes – 19/07/2021 – Created class
 */
@isTest
public with sharing class HDT_LC_ResumeSaleControllerTst{
	@testSetup
	static void setup(){

		List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
		List<Sale__c> saleList = HDT_UTL_DataFactoryTst.createSale(1, true, accList[0].id, 'Attiva');
	}

	@isTest
	public static void testloadVendite(){
		Test.startTest();

		Sale__c tSale = [SELECT Id, Status__c
		                 FROM Sale__c
		                 WHERE Status__c = 'Attiva'
		                 LIMIT 1];

		Map<String, Object> tSaleMap = HDT_LC_ResumeSaleController.loadVendite(tSale.Id);

		System.debug('tSaleMap = ' + tSaleMap);

		HDT_QR_Sale saleQr = new HDT_QR_Sale();
		Sale__c sale = saleQr.getRecordById(tSale.Id, 'Account__c,Status__c');

		System.assertEquals(sale, tSaleMap.get('sale'), 'Method return is not correct!');

		System.assertNotEquals(null, tSaleMap.get('sale'), 'loadVendite did not work correctly');

		Test.stopTest();
	}
}