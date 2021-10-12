/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 22/07/2021
 * @description Test Class for HDT_LC_ProcessesContainer.cls
 * @history Fabricio Petkevicius Nunes – 22/07/2021 – Created class
 */
@isTest
public class HDT_LC_ProcessesContainerTst{
	@TestSetup
	static void setup(){

		HDT_UTL_DataFactoryTst.pClickOrderPhase();
		List<Account> accList=HDT_UTL_DataFactoryTst.createAccountResidenziale(1, true, 'HERA COMM', 'D1 - Persona fisica', 'Enti');
		List<Sale__c> saleList=HDT_UTL_DataFactoryTst.createSale(1, true, accList[0].Id, 'Attiva');
		List<Order> orderList=HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].Id, saleList);
	}

	@isTest
	static void testcontrollerInit(){

		Test.startTest();

		List<Sale__c> tsaleList=[SELECT Id, Status__c
		                         FROM Sale__c
		                         WHERE Status__c='Attiva'
		                         LIMIT 1];


		Map<string, object> testcontrollerInit=HDT_LC_ProcessesContainer.controllerInit(tsaleList[0].Id);

		System.debug('testcontrollerInit = '+testcontrollerInit);


		System.assertEquals(4, testcontrollerInit.values().size(), 'Result Map is Wrong');

		System.assertNotEquals(1, testcontrollerInit.values().size(), 'controllerInit did not work correctly');

		Test.stopTest();
	}

	@isTest
	static void testcontrollerInitRedirect(){

		Test.startTest();

		List<Order> torderList=[SELECT Id, Status
		                        FROM Order
		                        WHERE Status='Draft'
		                        LIMIT 1];

		Map<string, object> testcontrollerInitRedirect=HDT_LC_ProcessesContainer.controllerInitRedirect(torderList[0].Id);


		System.debug('testcontrollerInitRedirect = '+testcontrollerInitRedirect);


		System.assertEquals(4, testcontrollerInitRedirect.values().size(), 'Result Map is Wrong');

		System.assertNotEquals(1, testcontrollerInitRedirect.values().size(), 'controllerInitRedirect did not work correctly');

		Test.stopTest();
	}
}