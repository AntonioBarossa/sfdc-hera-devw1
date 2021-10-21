/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 23/09/2021
 * @description HDT_BA_ConsentContact Test Class
 * @history Fabricio Petkevicius Nunes – 23/09/2021 – Created Class
 */
@isTest
public with sharing class HDT_BA_ConsentContactTst{
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
	private static HDT_WS_HTTPServiceCallMock mock=new HDT_WS_HTTPServiceCallMock();

	@TestSetup
	static void setup(){

		HDT_UTL_DataFactoryTst.pClickInstance();
		HDT_UTL_DataFactoryTst.pClickCasePhase();

		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, true);

		System.runAs(internalUser){

			List<Account> accList=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
			List<Individual> indList=HDT_UTL_DataFactoryTst.createIndividual(2, true);
			List<Contact> contactList=HDT_UTL_DataFactoryTst.createContact(2, false, accList[0].Id);
			contactList[0].Email='contactOne@conOne.com';
			contactList[0].IndividualId=indList[0].Id;
			contactList[1].Email='contactOne@conOne.com';
			contactList[1].IndividualId=indList[1].Id;
			insert contactList;

			HDT_UTL_DataFactoryTst.createWebServiceConfiguration('CampagenDmDmpData', 'end', 'method', 'testUser');
			HDT_UTL_DataFactoryTst.createWebServiceCredential('testUser', '12345', 'usernameTest');
		}
	}

	@isTest
	public static void testBatch(){

		User u=[SELECT Id
		        FROM User
		        WHERE Alias='crmuser'
		        LIMIT 1];

		System.runAs(u){

			Test.setMock(HttpCalloutMock.class, mock);

			Test.startTest();

			List<Individual> inds=[SELECT Id, FirstName
			                       FROM Individual
			                       WHERE FirstName='Mama'];

			List<Contact> contacts=[SELECT Id, FirstName, IndividualId, Email
			                        FROM Contact
			                        WHERE FirstName='test'];

			List<id> paramListIdContentVersion=new List<Id>();
			Set<String> paramSetEmailProcessed=new Set<String>();
			paramSetEmailProcessed.add('conTre@conTre.com');

			HDT_BA_ConsentContact cc=new HDT_BA_ConsentContact(1, '', '', '', paramListIdContentVersion, paramSetEmailProcessed);

			Database.executeBatch(cc);

			Test.stopTest();

			List<ContentVersion> cv=[SELECT Id
			                         FROM ContentVersion];

			System.assertEquals(false, cv.isEmpty(), 'Content Version created');
			System.assertNotEquals(true, cv.isEmpty(), 'Content Version not created');
		}
	}
}