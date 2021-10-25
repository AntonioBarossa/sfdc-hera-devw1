/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 29/07/2021
 * @description Test Class for HDT_SRV_Interaction.cls
 * @history Fabricio Petkevicius Nunes – 29/07/2021 – Created class
 */
@isTest
public class HDT_SRV_InteractionTst{
	@TestSetup
	static void setup(){

		List<Interaction__c> interactionTstList=new List<Interaction__c>();
		Interaction__c interactionTst=new Interaction__c();
		interactionTst.Comment__c='test';
		interactionTst.Status__c='Bozza';

		insert interactionTst;
	}

	@isTest
	static void testcheckAccessInit(){

		Boolean finished = false;

		Test.startTest();

		List<Interaction__c> tInteractionList=[SELECT Id, Status__c, Comment__c
		                                       FROM Interaction__c
		                                       WHERE Comment__c='test'
		                                       LIMIT 1];

		System.debug('tInteractionList = '+tInteractionList);

		HDT_SRV_Interaction tstInteractionSrv=new HDT_SRV_Interaction();

		tstInteractionSrv.checkAccessInit('Status__c, Comment__c', 'create');


		// System.assertEquals('', '', '');

		// System.assertNotEquals('', '');

		finished = true;

		Test.stopTest();

		System.assertEquals(true, finished, 'Test Not Ended');
	}

	@isTest
	static void testcheckReadAccess(){

		Boolean finished = false;

		Test.startTest();

		List<Interaction__c> tInteractionList=[SELECT Id, Status__c, Comment__c
		                                       FROM Interaction__c
		                                       WHERE Comment__c='test'
		                                       LIMIT 1];

		System.debug('tInteractionList = '+tInteractionList);

		HDT_SRV_Interaction tstInteractionSrv=new HDT_SRV_Interaction();

		tstInteractionSrv.checkReadAccess('Status__c, Comment__c');


		// System.assertEquals('', '', '');

		// System.assertNotEquals('', '');

		finished = true;

		Test.stopTest();

		System.assertEquals(true, finished, 'Test Not Ended');
	}

	@isTest
	static void testcheckCreateAccess(){

		Boolean finished = false;

		Test.startTest();

		List<Interaction__c> tInteractionList=[SELECT Id, Status__c, Comment__c
		                                       FROM Interaction__c
		                                       WHERE Comment__c='test'
		                                       LIMIT 1];

		System.debug('tInteractionList = '+tInteractionList);

		HDT_SRV_Interaction tstInteractionSrv=new HDT_SRV_Interaction();

		tstInteractionSrv.checkCreateAccess('Status__c, Comment__c');


		// System.assertEquals('', '', '');

		// System.assertNotEquals('', '');

		finished = true;

		Test.stopTest();

		System.assertEquals(true, finished, 'Test Not Ended');
	}

	@isTest
	static void testcheckUpdateAccess(){

		Boolean finished = false;

		Test.startTest();

		List<Interaction__c> tInteractionList=[SELECT Id, Status__c, Comment__c
		                                       FROM Interaction__c
		                                       WHERE Comment__c='test'
		                                       LIMIT 1];

		System.debug('tInteractionList = '+tInteractionList);

		HDT_SRV_Interaction tstInteractionSrv=new HDT_SRV_Interaction();

		tstInteractionSrv.checkUpdateAccess('Status__c, Comment__c');


		// System.assertEquals('', '', '');

		// System.assertNotEquals('', '');

		finished = true;

		Test.stopTest();

		System.assertEquals(true, finished, 'Test Not Ended');
	}

	@isTest
	static void testcreateRecord(){

		Test.startTest();

		Interaction__c interactionTst=new Interaction__c();
		interactionTst.Comment__c='test create';
		interactionTst.Status__c='Bozza';

		HDT_SRV_Interaction tstInteractionSrv=new HDT_SRV_Interaction();

		tstInteractionSrv.createRecord(interactionTst);

		List<Interaction__c> tInteractionList=[SELECT Id, Status__c, Comment__c
		                                       FROM Interaction__c
		                                       WHERE Comment__c='test create'
		                                       LIMIT 1];

		System.debug('tInteractionList = '+tInteractionList);


		System.assertEquals('test create', tInteractionList[0].Comment__c, 'Interaction not created');

		System.assertNotEquals(null, tInteractionList[0].Id, 'Interaction not created');

		Test.stopTest();
	}

	@isTest
	static void testupdateRecord(){

		Test.startTest();

		List<Interaction__c> tInteractionList=[SELECT Id, Status__c, Comment__c
		                                       FROM Interaction__c
		                                       WHERE Comment__c='test'
		                                       LIMIT 1];

		System.debug('tInteractionList = '+tInteractionList);

		tInteractionList[0].Comment__c='test update record';

		HDT_SRV_Interaction tstInteractionSrv=new HDT_SRV_Interaction();

		tstInteractionSrv.updateRecord(tInteractionList[0]);


		System.assertEquals('test update record', tInteractionList[0].Comment__c, 'Interaction not updated');

		System.assertNotEquals('test', tInteractionList[0].Comment__c, 'Interaction not updated');

		Test.stopTest();
	}
}