/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 16/09/2021
 * @description HDT_SRV_ContentDocumentLink Test Classes
 * @history Fabricio Petkevicius Nunes – 16/09/2021 – Created class
 */
@isTest
public with sharing class HDT_SRV_ContentDocumentLinkTst{
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
	private static HDT_SRV_ContentDocumentLink contDocLinkSrv=new HDT_SRV_ContentDocumentLink();
	@TestSetup
	static void makeData(){
		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, true);

		System.runAs(internalUser){

			HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
			List<Campaign> campaignList=HDT_UTL_DataFactoryTst.createCampaign(1, true);
			HDT_UTL_DataFactoryTst.createContentVersion(1, true, 'test', 'TestContentData', 'Test.jpg');
			List<PaperProcessing__c> paperProcessingList=HDT_UTL_DataFactoryTst.createPaperProcessing(1, false, 'TestPaperProc', campaignList[0].Id);
			paperProcessingList[0].Status__c='Bozza';
			insert paperProcessingList;
		}
	}

	@isTest
	public static void testCreateRecord(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();

			List<ContentDocument> contentDocs=[SELECT Id, Title, LatestPublishedVersionId
			                                   FROM ContentDocument];

			List<PaperProcessing__c> tPaperProcs=[SELECT Id, Status__c
			                                      FROM PaperProcessing__c
			                                      WHERE Status__c='Bozza'];

			ContentDocumentLink tCreatedRecord=contDocLinkSrv.createRecord(tPaperProcs[0].Id, contentDocs[0].Id, 'V');

			test.stopTest();

			System.assertEquals(true, tCreatedRecord.Id!=null, 'ContentDocumentLink not created');
			System.assertNotEquals(false, tCreatedRecord.Id!=null, 'ContentDocumentLink not created');
		}
	}
}