/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 21/07/2021
 * @description Test Class for HDT_LC_ManageBillingProfile.cls
 * @history Fabricio Petkevicius Nunes – 21/07/2021 – Created class
 */
@isTest
public class HDT_LC_ManageBillingProfileTst{
	@TestSetup
	static void setup(){

		List<Account> accList=HDT_UTL_DataFactoryTst.createAccountResidenziale(1, false, 'HERA COMM', 'D1 - Persona fisica', 'Enti');
		accList[0].FirstName__c='test';
		accList[0].BillingCityCode__c='RO';
		insert accList;


		HDT_UTL_DataFactoryTst.createBillingProfile(1, true, accList[0].Id);
	}

	@isTest
	static void testgetBillingProfileList(){

		Test.startTest();

		List<Account> taccList=[SELECT Id, FirstName__c
		                        FROM Account
		                        WHERE FirstName__c='test'
		                        LIMIT 1];


		List<BillingProfile__c> tBilProf=[SELECT Id, Name
		                                  FROM BillingProfile__c
		                                  WHERE Account__c=:taccList[0].Id
		                                  LIMIT 1];


		List<BillingProfile__c> testBilProf=HDT_LC_ManageBillingProfile.getBillingProfileList(taccList[0].Id);

		System.debug('testBilProf = '+testBilProf);


		System.assertEquals(testBilProf[0].Name, tBilProf[0].Name, 'Billing Profile Name is wrong');

		System.assertNotEquals(null, tBilProf[0].Name, 'getBillingProfileList did not work correctly');

		Test.stopTest();
	}
}