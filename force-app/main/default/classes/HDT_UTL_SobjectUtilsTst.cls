/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 16/08/2021
 * @description HDT_UTL_SobjectUtilsTst Test Class
 * @history Fabricio Petkevicius Nunes – 16/08/2021 – Created class
 */
@isTest
public with sharing class HDT_UTL_SobjectUtilsTst{
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
	@testSetup
	static void setup(){

		HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
	}

	@isTest
	public static void testgetSobjectTypeName(){

		Test.startTest();

		List<SObject> tObjList=[SELECT Id, VATNumber__c
		                        FROM Account
		                        WHERE VATNumber__c='12345678100'];

		String tObjectType=HDT_UTL_SobjectUtils.getSobjectTypeName(tObjList);

		Test.stopTest();

		System.assertEquals('Account', tObjectType, 'SObject type Name is wrong');
		System.assertNotEquals('', tObjectType, 'SObject type Name is wrong');
	}

	@isTest
	public static void testgetSobjectTypeNamebyId(){

		Test.startTest();

		List<Account> tAccount=[SELECT Id, VATNumber__c
		                        FROM Account
		                        WHERE VATNumber__c='12345678100'];

		List<Id> idList=new List<Id>();
		idList.add(tAccount[0].Id);

		String tObjectType=HDT_UTL_SobjectUtils.getSobjectTypeName(idList);

		Test.stopTest();

		System.assertEquals('Account', tObjectType, 'SObject type Name is wrong');
		System.assertNotEquals('', tObjectType, 'SObject type Name is wrong');
	}

	@isTest
	public static void testlistNotNullByField(){

		Test.startTest();

		List<SObject> tObjList=[SELECT Id, VATNumber__c
		                        FROM Account
		                        WHERE VATNumber__c='12345678100'];

		Schema.DescribeFieldResult describe=Account.VATNumber__c.getDescribe();
		Schema.sObjectField fieldDesc=describe.getSObjectField();

		List<String> listNotNull=HDT_UTL_SobjectUtils.listNotNullByField(tObjList, fieldDesc);

		Test.stopTest();

		System.assertEquals('12345678100', listNotNull[0], 'return is wrong');
		System.assertNotEquals('', listNotNull[0], 'return is wrong');
	}

	@isTest
	public static void testsetNotNullByField(){

		Test.startTest();

		List<SObject> tObjList=[SELECT Id, VATNumber__c
		                        FROM Account
		                        WHERE VATNumber__c='12345678100'];

		Schema.DescribeFieldResult describe=Account.VATNumber__c.getDescribe();
		Schema.sObjectField fieldDesc=describe.getSObjectField();

		Set<String> setNotNullByField=HDT_UTL_SobjectUtils.setNotNullByField(tObjList, fieldDesc);

		Test.stopTest();

		System.assertEquals(false, setNotNullByField.isEmpty(), 'return is wrong');
		System.assertNotEquals(true, setNotNullByField.isEmpty(), 'return is wrong');
	}

	@isTest
	public static void testsetIdByField(){

		Test.startTest();

		List<SObject> tObjList=[SELECT Id, VATNumber__c
		                        FROM Account
		                        WHERE VATNumber__c='12345678100'];

		Schema.DescribeFieldResult describe=Account.Id.getDescribe();
		Schema.sObjectField fieldDesc=describe.getSObjectField();

		Set<Id> setIdByField=HDT_UTL_SobjectUtils.setIdByField(tObjList, fieldDesc);

		Test.stopTest();

		System.assertEquals(false, setIdByField.isEmpty(), 'return is wrong');
		System.assertNotEquals(true, setIdByField.isEmpty(), 'return is wrong');
	}

	@isTest
	public static void testmapTwoFields(){

		Test.startTest();

		List<SObject> tObjList=[SELECT Id, VATNumber__c
		                        FROM Account
		                        WHERE VATNumber__c='12345678100'];

		Schema.DescribeFieldResult describe=Account.Id.getDescribe();
		Schema.sObjectField fieldDesc=describe.getSObjectField();

		Map<String, String> mapTwoFields=HDT_UTL_SobjectUtils.mapTwoFields(tObjList, fieldDesc, fieldDesc);

		Test.stopTest();

		System.assertEquals(false, mapTwoFields.isEmpty(), 'return is wrong');
		System.assertNotEquals(true, mapTwoFields.isEmpty(), 'return is wrong');
	}

	@isTest
	public static void testmapByFieldAndSobject(){

		Test.startTest();

		List<SObject> tObjList=[SELECT Id, VATNumber__c
		                        FROM Account
		                        WHERE VATNumber__c='12345678100'];

		Schema.DescribeFieldResult describe=Account.Id.getDescribe();
		Schema.sObjectField fieldDesc=describe.getSObjectField();

		Map<String, SObject> mapByFieldAndSobject=HDT_UTL_SobjectUtils.mapByFieldAndSobject(tObjList, fieldDesc);

		Test.stopTest();

		System.assertEquals(false, mapByFieldAndSobject.isEmpty(), 'return is wrong');
		System.assertNotEquals(true, mapByFieldAndSobject.isEmpty(), 'return is wrong');
	}

	@isTest
	public static void testmapByFieldAndList(){

		Test.startTest();

		List<SObject> tObjList=[SELECT Id, VATNumber__c
		                        FROM Account
		                        WHERE VATNumber__c='12345678100'];

		Schema.DescribeFieldResult describe=Account.Id.getDescribe();
		Schema.sObjectField fieldDesc=describe.getSObjectField();

		Map<String, SObject[]> mapByFieldAndList=HDT_UTL_SobjectUtils.mapByFieldAndList(tObjList, fieldDesc);

		Test.stopTest();

		System.assertEquals(false, mapByFieldAndList.isEmpty(), 'return is wrong');
		System.assertNotEquals(true, mapByFieldAndList.isEmpty(), 'return is wrong');
	}

	@isTest
	public static void testmapFieldAndSet(){

		Test.startTest();

		List<SObject> tObjList=[SELECT Id, VATNumber__c
		                        FROM Account
		                        WHERE VATNumber__c='12345678100'];

		Schema.DescribeFieldResult describe=Account.Id.getDescribe();
		Schema.sObjectField fieldDesc=describe.getSObjectField();

		Schema.SObjectType.Account.fields.getMap();

		Map<String, Set<String>> mapFieldAndSet=HDT_UTL_SobjectUtils.mapFieldAndSet(tObjList, fieldDesc, fieldDesc);

		Test.stopTest();

		System.assertEquals(false, mapFieldAndSet.isEmpty(), 'return is wrong');
		System.assertNotEquals(true, mapFieldAndSet.isEmpty(), 'return is wrong');
	}
}