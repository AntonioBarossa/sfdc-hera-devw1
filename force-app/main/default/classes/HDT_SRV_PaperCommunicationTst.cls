/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 29/07/2021
 * @description Test Class for HDT_SRV_PaperCommunication.cls
 * @history Fabricio Petkevicius Nunes – 29/07/2021 – Created class
 */
@isTest
public class HDT_SRV_PaperCommunicationTst{
	@isTest
	static void testinsertRecords(){

		Test.startTest();
		List<PaperCommunication__c> tPaperCommList=new List<PaperCommunication__c>();
		PaperCommunication__c tPaperComm=new PaperCommunication__c();
		tPaperComm.Name='test';

		tPaperCommList.add(tPaperComm);

		HDT_SRV_PaperCommunication.insertRecords(tPaperCommList);


		PaperCommunication__c paperCommInsert=[SELECT Id, Name
		                                       FROM PaperCommunication__c 
		                                       WHERE Name='test'
		                                       LIMIT 1];

		System.debug('paperCommInsert = '+paperCommInsert);


		System.assertEquals('test', paperCommInsert.Name, 'Paper Communication not inserted');

		System.assertNotEquals(null, paperCommInsert.Id, 'Paper Communication not inserted');

		Test.stopTest();
	}

	@isTest
	static void testupdateRecords(){

		Test.startTest();

		List<PaperCommunication__c> tPaperCommList=new List<PaperCommunication__c>();
		PaperCommunication__c tPaperComm=new PaperCommunication__c();
		tPaperComm.Name='test';

		tPaperCommList.add(tPaperComm);

		insert tPaperCommList;

		tPaperCommList[0].Name='UpdateTest';

		HDT_SRV_PaperCommunication.updateRecords(tPaperCommList);


		PaperCommunication__c paperCommInsert=[SELECT Id, Name
		                                       FROM PaperCommunication__c 
		                                       WHERE Name='UpdateTest'
		                                       LIMIT 1];

		System.debug('paperCommInsert = '+paperCommInsert);


		System.assertEquals('UpdateTest', paperCommInsert.Name, 'Paper Communication not updated');

		System.assertNotEquals(null, paperCommInsert.Id, 'Paper Communication not updated');

		Test.stopTest();
	}
}