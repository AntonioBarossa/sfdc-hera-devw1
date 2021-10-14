/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 02/08/2021
 * @description Test Class for HDT_QR_ContentVersion.cls
 * @history Fabricio Petkevicius Nunes – 02/08/2021 – Created class
 */
@isTest
public class HDT_QR_ContentVersionTst{
	@isTest
	static void tesgetRecordById(){

		Test.startTest();

		List<ContentVersion> contVerTstList=HDT_UTL_DataFactoryTst.createContentVers(1, true);

		HDT_QR_ContentVersion conTVersQr = new HDT_QR_ContentVersion();

		ContentVersion tContVers = conTVersQr.getRecordById(contVerTstList[0].Id);

		System.assertEquals('test', tContVers.Title, 'Content version not returned');

		System.assertNotEquals(null, tContVers.Title, ' The Content Version was not retrieved properly');

		Test.stopTest();
	}

	@isTest
	static void tesrecordByDocumentIdQueryString(){

		Test.startTest();

		List<ContentVersion> contVerTstList=HDT_UTL_DataFactoryTst.createContentVers(1, false);

		ContentDocument contentDoc=new ContentDocument();

		contVerTstList[0].ContentDocumentId=contentDoc.Id;

		insert contVerTstList;


		HDT_QR_ContentVersion conTVersQr=new HDT_QR_ContentVersion();

		String tContVers=conTVersQr.recordByDocumentIdQueryString(contentDoc.Id);

		System.assertEquals(true, String.IsNotBlank(tContVers), 'Content version query not right');

		System.assertNotEquals('test', tContVers, 'The query string was not generated properly');

		Test.stopTest();
	}
}