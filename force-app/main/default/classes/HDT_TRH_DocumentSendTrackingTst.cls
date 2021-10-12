/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 09/08/2021
 * @description HDT_TRH_DocumentSendTracking Test Classes
 * @history Fabricio Petkevicius Nunes – 9/08/2021 – Created class
 */
@isTest
public with sharing class HDT_TRH_DocumentSendTrackingTst{
	@isTest
	public static void testTriggerDocSendTrackBeforeInsert(){

		Test.startTest();

		List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
		List<DocumentSendTracking__c> docSendTracks=new List<DocumentSendTracking__c>();
		DocumentSendTracking__c docSendTrack=new DocumentSendTracking__c();
		docSendTrack.Account__c=accounts[0].Id;

		docSendTracks.add(docSendTrack);

		insert docSendTracks;


		System.debug('docSendTracks = '+docSendTracks);

		DocumentSendTracking__c testDocSendTrack=[SELECT Id, Account__c
		                                          FROM DocumentSendTracking__c
		                                          WHERE Account__c=:accounts[0].Id
		                                          LIMIT 1];

		System.assertEquals(accounts[0].Id, testDocSendTrack.Account__c, 'Document Send Tracking not Inserted');
		System.assertNotEquals('', testDocSendTrack.Account__c, 'Document Send Tracking not Inserted');
		Test.stopTest();
	}
}