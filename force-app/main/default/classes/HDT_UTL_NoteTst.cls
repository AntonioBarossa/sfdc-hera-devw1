/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 28/07/2021
 * @description Test Class for HDT_UTL_Note.cls
 * @history Fabricio Petkevicius Nunes – 28/07/2021 – Created class
 */
@isTest
public class HDT_UTL_NoteTst{
	@TestSetup
	static void setup(){

		List<Account> accList=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
	}

	@isTest
	static void testcreateNoteAndAssign(){
		Test.startTest();
		String title='test';
		string content='';

		Account tAccount=[SELECT Id
		                  FROM Account
		                  LIMIT 1];

		HDT_UTL_Note.createNoteAndAssign(tAccount.Id, title, content);

		ContentNote tContentNote=[SELECT Id, Title
		                          FROM ContentNote
		                          WHERE Title='test'
		                          LIMIT 1];

		System.debug('tContentNote = '+tContentNote);

		System.assertEquals(true, String.isNotEmpty(tContentNote.Id), 'Content Note not inserted');
		System.assertNotEquals(false, String.isNotEmpty(tContentNote.Id), 'Content Note not inserted');
		Test.stopTest();
	}

	@isTest
	static void testcreateNoteAndAssignWithContent(){
		Test.startTest();
		String title='test';
		string content='testContent';

		Account tAccount=[SELECT Id
		                  FROM Account
		                  LIMIT 1];

		HDT_UTL_Note.createNoteAndAssign(tAccount.Id, title, content);

		ContentNote tContentNote=[SELECT Id, Title
		                          FROM ContentNote
		                          WHERE Title='test'
		                          LIMIT 1];

		System.debug('tContentNote = '+tContentNote);

		System.assertEquals(true, String.isNotEmpty(tContentNote.Id), 'Content Note not inserted');
		System.assertNotEquals(false, String.isNotEmpty(tContentNote.Id), 'Content Note not inserted');
		Test.stopTest();
	}
}