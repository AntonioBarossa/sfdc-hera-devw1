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
			atecMat.RonchiCode__c='test2';
			atecMat.AtecoCode__c='test3';

			atecoMatrix.add(atecMat);

			insert atecoMatrix;

			List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'MMS','G6 - MMS Associazione','Aziende SME');
			
			List<Case> cases = HDT_UTL_DataFactoryTst.createCase(1, true, accs.get(0).Id, null, null, null, null);
			List<Order> orders=HDT_UTL_DataFactoryTst.createOrder(1, true, accs.get(0).Id, 'Bozza');

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
		
		Test.startTest();

		Order orders = [SELECT Id FROM Order LIMIT 1];
        
        Map<String,String> params =  new Map<String,String>();
        params.put('atecoCode','atecoCode');
        params.put('istatCode','istatCode');

		HDT_LC_CodiceAteco.saveAtecoCode(orders, params);

		Order tOrder=[SELECT Id, AtecoCode__c
		              FROM Order
		              LIMIT 1];

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

		List<Order> currOrder = [SELECT Id,AtecoCode__c,HerAteco__c,RonchiCode__c,RonchiSubcat__c,RonchiDescription__c
							FROM Order LIMIT 1];

		Test.startTest();

		HDT_LC_CodiceAteco.saveAtecoRonchiCode(currOrder[0], tempMap);

		// HDT_LC_CodiceAteco.saveAtecoRonchiCode(currOrder[0], tempMap);
		
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

		List<Case> currCase = [SELECT Id,AtecoCode__c,SupplyCityCode__c,RonchiCode__c,RonchiSubcategory__c,RonchiCodeDescription__c
							FROM Case LIMIT 1];

		Test.startTest();
		
		HDT_LC_CodiceAteco.saveAtecoRonchiCodeCase(currCase[0], tempMap);

		// HDT_LC_CodiceAteco.saveAtecoRonchiCodeCase(currCase[0], tempMap);

		Test.stopTest();

		currCase = [SELECT Id,AtecoCode__c,SupplyCityCode__c,RonchiCode__c,RonchiSubcategory__c,RonchiCodeDescription__c
		 					FROM Case LIMIT 1];

		system.assertEquals('1', currCase[0].AtecoCode__c);
		system.assertEquals('2', currCase[0].SupplyCityCode__c);
		system.assertEquals('3', currCase[0].RonchiCode__c);
		system.assertEquals('4', currCase[0].RonchiSubcategory__c);
		system.assertEquals('5', currCase[0].RonchiCodeDescription__c);

	}

	@IsTest
	static void testGetAtecoMatrixListIstatRonchi(){
		
		Test.startTest();

		List<AtecoMatrix__c> atecoMatrixList = HDT_LC_CodiceAteco.getAtecoMatrixListIstatRonchi('City__c', 'Roma', 'Istat');
		HDT_LC_CodiceAteco.getAtecoMatrixListIstatRonchi('IstatCode__c', 'test', 'Ronchi');
		
		System.assertEquals('Roma', atecoMatrixList[0].City__c, 'Ateco Matrix returned is wrong');
		System.assertNotEquals('', atecoMatrixList[0].City__c, 'getAtecoMatrixByComune did not work correctly');
		
		Test.stopTest();
		
	}

	@IsTest
	static void testSaveIstatRonchiCase(){
		
		Test.startTest();

		Map<String,String> tempMap = new Map<String,String>{
			'atecoCode'=>'1',
			'istatCode'=>'2',
			'ronchiCode'=>'3',
			'ronchiSubcategory'=>'4',
			'ronchiDescription'=>'5'
		};

		List<Case> currCase = [SELECT Id,AtecoCode__c,SupplyCityCode__c,RonchiCode__c,RonchiSubcategory__c,RonchiCodeDescription__c
							FROM Case LIMIT 1];

		HDT_LC_CodiceAteco.saveIstatRonchiCase(currCase[0], 'Istat', tempMap);
		HDT_LC_CodiceAteco.saveIstatRonchiCase(currCase[0], 'Ronchi', tempMap);

		currCase = [SELECT Id,AtecoCode__c,SupplyCityCode__c,RonchiCode__c,RonchiSubcategory__c,RonchiCodeDescription__c
		 					FROM Case LIMIT 1];

		system.assertEquals('1', currCase[0].AtecoCode__c);
		system.assertEquals('2', currCase[0].SupplyCityCode__c);
		system.assertEquals('3', currCase[0].RonchiCode__c);
		system.assertEquals('4', currCase[0].RonchiSubcategory__c);
		system.assertEquals('5', currCase[0].RonchiCodeDescription__c);
		
		Test.stopTest();
		
	}
}