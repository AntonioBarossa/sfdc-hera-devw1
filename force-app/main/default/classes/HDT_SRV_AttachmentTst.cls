/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 27/07/2021
 * @description Test Class for HDT_SRV_Attachment.cls
 * @history Fabricio Petkevicius Nunes – 27/07/2021 – Created class
 */
@isTest
public class HDT_SRV_AttachmentTst{
	@TestSetup
	static void setup(){

		List<Account> accList=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
	}

	@isTest
	static void testinsertAttach(){

		Test.startTest();

		Account accTst=[SELECT Id, Name
		                From Account 
		                WHERE CompanyOwner__c='HERA COMM'
		                LIMIT 1];


		List<Attachment> attachList=HDT_UTL_DataFactoryTst.createAttachment(1, false, accTst.id);


		HDT_SRV_Attachment.insertAttach(attachList);


		Attachment tAttach=[SELECT Id, Name, ParentId
		                    FROM Attachment
		                    WHERE Name='test' AND ParentId=:accTst.id
		                    LIMIT 1];

		System.debug('tAttach = '+tAttach);


		System.assertEquals('test', tAttach.Name, 'Attachment not inserted');

		System.assertNotEquals(null, tAttach.ParentId, 'Value of parameter is not matching');

		Test.stopTest();
	}

	@isTest
	static void testinsertContentVersion(){

		Test.startTest();

		List<ContentVersion> contVerTstList=HDT_UTL_DataFactoryTst.createContentVers(1, false);

		HDT_SRV_Attachment.insertContentVersion(contVerTstList[0]);


		ContentVersion tContVers=[SELECT Id, PathOnClient, Title
		                          FROM ContentVersion
		                          WHERE Title='test'
		                          LIMIT 1];

		System.debug('tContVers = '+tContVers);


		System.assertEquals('test', tContVers.Title, 'Content version not inserted');

		System.assertNotEquals(null, tContVers.Title, 'Value of parameter is not matching');

		Test.stopTest();
	}
}