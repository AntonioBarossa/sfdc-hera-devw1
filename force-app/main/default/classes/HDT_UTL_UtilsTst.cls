/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 05/08/2021
 * @description Test Class for HDT_UTL_Utils.cls
 * @history Fabricio Petkevicius Nunes – 05/08/2021 – Created class
 */
@isTest
public class HDT_UTL_UtilsTst{
	@TestSetup
	static void setup(){

		List<Account> accList=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
    }

	@isTest
	static void testcreateMapFromSobjectList(){

		Test.startTest();

		List<SObject> accTst=[SELECT Id, CompanyOwner__c, Category__c, Name, Description
		                      FROM Account
		                      WHERE CompanyOwner__c='HERA COMM'
		                      LIMIT 1];


		HDT_UTL_Utils utilsTest=new HDT_UTL_Utils();

		Schema.SObjectField fieldToken=Account.Name;

		Map<String, sObject> testReturn=utilsTest.createMapFromSobjectList(accTst, fieldToken);


		System.debug('accTst = '+accTst);
		System.debug('testReturn = '+testReturn);


		System.assertEquals(false, testReturn.isEmpty(), 'Return is wrong');

		System.assertNotEquals(true, testReturn.isEmpty());

		Test.stopTest();
	}

	@isTest
	static void testcodingSha256(){

		Test.startTest();

		String stringTst='testString';

		string testReturn=HDT_UTL_Utils.codingSha256(stringTst);


		System.debug('testReturn = '+testReturn);


		System.assertEquals(true, testReturn.isAlphanumeric(), 'Return is wrong');

		System.assertNotEquals(false, testReturn.isAlphanumeric());

		Test.stopTest();
	}
}