/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 28/07/2021
 * @description Test Class for HDT_SRV_Note.cls
 * @history Fabricio Petkevicius Nunes – 28/07/2021 – Created class
 */
@isTest
public class HDT_SRV_NoteTst{
	@TestSetup
	static void setup(){

		HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
		HDT_UTL_DataFactoryTst.createContentVers(1, true);
	}

	@isTest
	static void testcreateRecordNote(){

		Test.startTest();

		ContentNote contentNoteTst=new ContentNote();
		contentNoteTst.Title='test';

		HDT_SRV_Note.createRecordNote(contentNoteTst);

		ContentNote tContentNote=[SELECT Id, Title
		                          FROM ContentNote
		                          WHERE Title='test'
		                          LIMIT 1];

		System.debug('tContentNote = '+tContentNote);


		System.assertEquals('test', tContentNote.title, 'Content Note not inserted');

		System.assertNotEquals(null, tContentNote.Id, 'Content Note not inserted');

		Test.stopTest();
	}

	@isTest
	static void testcreateRecordAssign(){

		Test.startTest();

		Account accTst=[SELECT Id, Name
		                FROM Account 
		                WHERE CompanyOwner__c='HERA COMM'
		                LIMIT 1];

		ContentDocument contDocTst=[SELECT Id
		                            FROM ContentDocument
		                            LIMIT 1];

		ContentDocumentLink contentDocLinkTst=new ContentDocumentLink();
		contentDocLinkTst.LinkedEntityId=accTst.Id;
		contentDocLinkTst.ContentDocumentId=contDocTst.Id;

		HDT_SRV_Note.createRecordAssign(contentDocLinkTst);

		ContentDocumentLink tContentDocLink=[SELECT Id, IsDeleted
		                                     FROM ContentDocumentLink
		                                     WHERE LinkedEntityId=:accTst.Id
		                                     LIMIT 1];

		System.debug('tContentDocLink = '+tContentDocLink);


		System.assertEquals(false, tContentDocLink.IsDeleted, 'Content Document Link not inserted');

		System.assertNotEquals(null, tContentDocLink.Id, 'Content Document Link not inserted');

		Test.stopTest();
	}
}