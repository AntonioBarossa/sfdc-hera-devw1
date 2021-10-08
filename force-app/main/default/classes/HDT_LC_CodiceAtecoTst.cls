/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 16/08/2021
 * @description HDT_LC_CodiceAteco  Test Class
 * @history Fabricio Petkevicius Nunes – 16/08/2021 – Created class
 */
@isTest
public with sharing class HDT_LC_CodiceAtecoTst{
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
	@testSetup
	static void setup(){

		HDT_UTL_DataFactoryTst.pClickInstance();
		HDT_UTL_DataFactoryTst.pClickOrderPhase();

		List<AtecoMatrix__c> atecoMatrix=new List<AtecoMatrix__c>();
		AtecoMatrix__c atecMat=new AtecoMatrix__c();
		atecMat.City__c='Roma';
		atecMat.IstatCode__c='test';

		atecoMatrix.add(atecMat);

		insert atecoMatrix;
	}

	@isTest
	public static void getAtecoMatrixList(){

		Test.startTest();

		String filterType='City__c';
		string filterValue='Roma';

		List<AtecoMatrix__c> tAtecoMatrix=HDT_LC_CodiceAteco.getAtecoMatrixList(filterType, filterValue);

		System.debug('tAtecoMatrix = '+tAtecoMatrix);

		filterType='IstatCode__c';
		filterValue='test';

		List<AtecoMatrix__c> tAtecoMatrix2=HDT_LC_CodiceAteco.getAtecoMatrixList(filterType, filterValue);

		System.debug('tAtecoMatrix2 = '+tAtecoMatrix2);

		System.assertEquals('Roma', tAtecoMatrix2[0].City__c, 'Ateco Matrix return is wrong');
		System.assertNotEquals('', tAtecoMatrix2[0].City__c, 'value of parameter is not matching');
		Test.stopTest();
	}

	@isTest
	public static void saveAtecoCode(){

		Test.startTest();

		List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
		List<Order> orders=HDT_UTL_DataFactoryTst.createOrder(1, true, accounts[0].id, 'Bozza');
        
        Map<String,String> params =  new Map<String,String>();
        params.put('atecoCode','atecoCode');
        params.put('istatCode','istatCode');

		HDT_LC_CodiceAteco.saveAtecoCode(orders[0], params);

		Order tOrder=[SELECT Id, AtecoCode__c
		              FROM Order
		              WHERE ID=:orders[0].Id];

		System.debug('tOrder = '+tOrder);

		System.assertEquals('atecoCode', tOrder.AtecoCode__c, 'Order not updated');
		System.assertNotEquals('', tOrder.AtecoCode__c, 'value of parameter is not matching');
		Test.stopTest();
	}
}