/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 23/08/2021
 * @description Test Class for HDT_QR_AtecoMatrix.cls
 * @history Fabricio Petkevicius Nunes – 23/08/2021 – Created class
 */
@isTest
public class HDT_QR_AtecoMatrixTst{
	@TestSetup
	static void setup(){

		List<AtecoMatrix__c> atecoMats=HDT_UTL_DataFactoryTst.createAtecoMatrix(1, false, 'testAtecoM');
		atecoMats[0].AtecoCode__c='test0';
		atecoMats[0].City__c='RO';
		atecoMats[0].IstatCode__c='test1';
		atecoMats[0].Category__c='test3';
		atecoMats[0].RonchiCode__c='test4';
		atecoMats[0].AtecoCode__c='test5';

		insert atecoMats;
	}

	@isTest
	static void testgetAtecoMatrixByComune(){

		Test.startTest();

		List<AtecoMatrix__c> testGetByComune=HDT_QR_AtecoMatrix.getAtecoMatrixByComune('RO');

		System.assertEquals('RO', testGetByComune[0].City__c, 'Ateco Matrix returned is wrong');
		System.assertNotEquals('', testGetByComune[0].City__c, 'getAtecoMatrixByComune did not work correctly');

		Test.stopTest();
	}

	@isTest
	static void testgetAtecoMatrixByCodiceIstat(){

		Test.startTest();

		List<AtecoMatrix__c> testGetByIstatCode=HDT_QR_AtecoMatrix.getAtecoMatrixByCodiceIstat('test1');

		System.assertEquals('test1', testGetByIstatCode[0].IstatCode__c, 'Ateco Matrix returned is wrong');
		System.assertNotEquals('', testGetByIstatCode[0].IstatCode__c, 'getAtecoMatrixByCodiceIstat did not work correctly');

		Test.stopTest();
	}

	@IsTest
	static void testGetAtecoMatrixByCodiceIstatWhich(){
		
		Test.startTest();

		List<AtecoMatrix__c> testGetByIstatCode = HDT_QR_AtecoMatrix.getAtecoMatrixByCodiceIstat('test1', 'Istat');
		HDT_QR_AtecoMatrix.getAtecoMatrixByCodiceIstat('test1', 'Ronchi');
		
		System.assertEquals('test1', testGetByIstatCode[0].IstatCode__c, 'Ateco Matrix returned is wrong');
		System.assertNotEquals('', testGetByIstatCode[0].IstatCode__c, 'getAtecoMatrixByCodiceIstat did not work correctly');
		
		Test.stopTest();
		
	}

	@IsTest
	static void testGetAtecoMatrixByComuneWhich(){
		
		Test.startTest();

		List<AtecoMatrix__c> testGetByComune=HDT_QR_AtecoMatrix.getAtecoMatrixByComune('RO', 'Istat');
		HDT_QR_AtecoMatrix.getAtecoMatrixByComune('RO', 'Ronchi');

		System.assertEquals('RO', testGetByComune[0].City__c, 'Ateco Matrix returned is wrong');
		System.assertNotEquals('', testGetByComune[0].City__c, 'getAtecoMatrixByComune did not work correctly');

		Test.stopTest();
		
	}
}