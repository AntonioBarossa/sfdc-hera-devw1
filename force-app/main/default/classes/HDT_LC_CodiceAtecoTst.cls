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
		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
		internalUser.UserPermissionsMarketingUser=true;
		insert internalUser;

        System.runAs(internalUser){
			HDT_UTL_DataFactoryTst.pClickInstance();
			HDT_UTL_DataFactoryTst.pClickOrderPhase();
			HDT_UTL_DataFactoryTst.pClickCasePhase();

			List<AtecoMatrix__c> atecoMatrix=new List<AtecoMatrix__c>();
			AtecoMatrix__c atecMat=new AtecoMatrix__c();
			atecMat.City__c='Roma';
			atecMat.IstatCode__c='test';

			atecoMatrix.add(atecMat);

			insert atecoMatrix;

			List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'MMS','MMS Azienda','Aziende SME');

		}
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
		Id accId = [SELECT Id FROM Account LIMIT 1].Id;
		Test.startTest();

		List<Order> orders=HDT_UTL_DataFactoryTst.createOrder(1, true, accId, 'Bozza');
        
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

	@isTest
	public static void saveAtecoRonchiCode(){
		Map<String,String> tempMap = new Map<String,String>{
			'atecoCode'=>'1',
			'istatCode'=>'2',
			'ronchiCode'=>'3',
			'ronchiSubcategory'=>'4',
			'ronchiDescription'=>'5'
		};

		Id accId = [SELECT Id FROM Account LIMIT 1].Id;

		List<Order> orders = HDT_UTL_DataFactoryTst.createOrder(1, true, accId, 'Bozza');

		List<Order> currOrder = [SELECT Id,AtecoCode__c,HerAteco__c,RonchiCode__c,RonchiSubcat__c,RonchiDescription__c
							FROM Order LIMIT 1];

		Test.startTest();
			HDT_LC_CodiceAteco.saveAtecoRonchiCode(currOrder[0], tempMap);
		Test.stopTest();

		currOrder = [SELECT Id,AtecoCode__c,HerAteco__c,RonchiCode__c,RonchiSubcat__c,RonchiDescription__c
							FROM Order LIMIT 1];
							  
		system.assertEquals('1', currOrder[0].AtecoCode__c);
		system.assertEquals('2', currOrder[0].HerAteco__c);
		system.assertEquals('3', currOrder[0].RonchiCode__c);
		system.assertEquals('4', currOrder[0].RonchiSubcat__c);
		system.assertEquals('5', currOrder[0].RonchiDescription__c);

	}

	@isTest
	public static void saveAtecoRonchiCodeCase(){
		Map<String,String> tempMap = new Map<String,String>{
			'atecoCode'=>'1',
			'istatCode'=>'2',
			'ronchiCode'=>'3',
			'ronchiSubcategory'=>'4',
			'ronchiDescription'=>'5'
		};

		Id accId = [SELECT Id FROM Account LIMIT 1].Id;

		List<Case> cases = HDT_UTL_DataFactoryTst.createCase(1, true, accId, null, null, null, null);

		List<Case> currCase = [SELECT Id,AtecoCode__c,SupplyCityCode__c,RonchiCode__c,RonchiSubcategory__c,RonchiCodeDescription__c
							FROM Case LIMIT 1];

		Test.startTest();
			HDT_LC_CodiceAteco.saveAtecoRonchiCodeCase(currCase[0], tempMap);
		Test.stopTest();

		currCase = [SELECT Id,AtecoCode__c,SupplyCityCode__c,RonchiCode__c,RonchiSubcategory__c,RonchiCodeDescription__c
							FROM Case LIMIT 1];

		system.assertEquals('1', currCase[0].AtecoCode__c);
		system.assertEquals('2', currCase[0].SupplyCityCode__c);
		system.assertEquals('3', currCase[0].RonchiCode__c);
		system.assertEquals('4', currCase[0].RonchiSubcategory__c);
		system.assertEquals('5', currCase[0].RonchiCodeDescription__c);

	}
}