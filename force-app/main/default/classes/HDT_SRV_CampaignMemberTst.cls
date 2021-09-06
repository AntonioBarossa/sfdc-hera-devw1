/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 06/09/2021
 * @description Test Class for HDT_SRV_CampaignMember.cls
 * @history Fabricio Petkevicius Nunes – 06/00/2021 – Created class
 */
@isTest
public class HDT_SRV_CampaignMemberTst{
	private static HDT_SRV_CampaignMember CampMembSrv=new HDT_SRV_CampaignMember();
	private static HDT_WS_HTTPServiceCallMock mock=new HDT_WS_HTTPServiceCallMock();
	@TestSetup
	static void makeData(){
		HDT_UTL_DataFactoryTst.createWebServiceConfiguration('campaignBolletta', 'end', 'method', 'testUser');
		HDT_UTL_DataFactoryTst.createWebServiceCredential('testUser', '12345', 'usernameTest');

		List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
		List<Lead> leads=HDT_UTL_DataFactoryTst.createLead(1, true);
        List<Contact> contacts=HDT_UTL_DataFactoryTst.createContact(1, true, accounts[0].Id);
		List<Campaign> campaigns=HDT_UTL_DataFactoryTst.createCampaign(1, false);
		campaigns[0].Category__c='Campagna Outbound';
		campaigns[0].Description='testDesc';
		campaigns[0].StaticTextMessageBill__c='tstStaticTextMsgBill';
		campaigns[0].Channel__c='Bolletta';

		insert campaigns;


	}

	@isTest
	static void testCheckAccessInit(){

		Test.startTest();

		CampMembSrv.checkAccessInit('GenericField1__c, Name', 'create');

		Test.stopTest();

		// Method Return is VOID
		// System.assertEquals('', '', '');
		// System.assertNotEquals('', '');
	}

	@isTest
	static void testCheckReadAccess(){

		Test.startTest();

		CampMembSrv.checkReadAccess('GenericField1__c, Name');

		Test.stopTest();

		// Method Return is VOID
		// System.assertEquals('', '', '');
		// System.assertNotEquals('', '');
	}

	@isTest
	static void testCheckCreateAccess(){

		Test.startTest();

		CampMembSrv.checkCreateAccess('GenericField1__c, Name');

		Test.stopTest();

		// Method Return is VOID
		// System.assertEquals('', '', '');
		// System.assertNotEquals('', '');
	}

	@isTest
	static void testCheckUpdateAccess(){

		Test.startTest();

		CampMembSrv.checkUpdateAccess('GenericField1__c, Name');

		Test.stopTest();

		// Method Return is VOID
		// System.assertEquals('', '', '');
		// System.assertNotEquals('', '');
	}

	@isTest
	static void testUpdateRecord(){

		Test.setMock(HttpCalloutMock.class, mock);

		Test.startTest();

		List<Campaign> tCampaigns=[SELECT Id, Name, Category__c, Description, StaticTextMessageBill__c, Channel__c
		                           FROM Campaign
		                           WHERE Category__c='Campagna Outbound'
		                           LIMIT 1];

		List<Lead> tLeads=[SELECT Id, FirstName
		                   FROM Lead
		                   WHERE FirstName='FirstNameTest0'
		                   LIMIT 1];

		List<Contact> tContacts=[SELECT Id, FirstName
		                         FROM Contact
		                         WHERE FirstName='test'
		                         LIMIT 1];


		List<Campaignmember> campMembers=HDT_UTL_DataFactoryTst.createCampaignMember(1, false, tCampaigns[0].Id, tLeads[0].Id, tContacts[0].Id);
		campMembers[0].GenericField1__c='testGenField';
		campMembers[0].ContractReference__c='testConRef';

		List<CommercialCode__c> commCodes=HDT_UTL_DataFactoryTst.createCommCode(1, false);
		commCodes[0].FullCode__c='testCode';
		commCodes[0].Campaign__c=tCampaigns[0].Id;
		insert commCodes;

		campMembers[0].PromoCommercialCode__c=commCodes[0].Id;
		insert campMembers;

		campMembers[0].GenericField1__c='tstUpdatedFenField';

		CampMembSrv.updateRecord(campMembers[0]);

		CampaignMember updtCampMember=[SELECT Id, GenericField1__c
		                               FROM CampaignMember
		                               WHERE GenericField1__c='tstUpdatedFenField'
		                               LIMIT 1];

		Test.stopTest();

		System.assertEquals('tstUpdatedFenField', updtCampMember.GenericField1__c, 'Campaign Member not Updated');
		System.assertNotEquals('testGenField', updtCampMember.GenericField1__c);
	}

	@isTest
	static void testCreateRecord(){

		Test.setMock(HttpCalloutMock.class, mock);

		Test.startTest();

		List<Campaign> tCampaigns=[SELECT Id, Name, Category__c, Description, StaticTextMessageBill__c, Channel__c
		                           FROM Campaign
		                           WHERE Category__c='Campagna Outbound'
		                           LIMIT 1];

		List<Lead> tLeads=[SELECT Id, FirstName
		                   FROM Lead
		                   WHERE FirstName='FirstNameTest0'
		                   LIMIT 1];

		List<Contact> tContacts=[SELECT Id, FirstName
		                         FROM Contact
		                         WHERE FirstName='test'
		                         LIMIT 1];


		List<Campaignmember> campMembers=HDT_UTL_DataFactoryTst.createCampaignMember(1, false, tCampaigns[0].Id, tLeads[0].Id, tContacts[0].Id);
		campMembers[0].GenericField1__c='testGenField';
		campMembers[0].ContractReference__c='testConRef';

		List<CommercialCode__c> commCodes=HDT_UTL_DataFactoryTst.createCommCode(1, false);
		commCodes[0].FullCode__c='testCode';
		commCodes[0].Campaign__c=tCampaigns[0].Id;
		insert commCodes;

		campMembers[0].PromoCommercialCode__c=commCodes[0].Id;

		CampMembSrv.createRecord(campMembers[0]);

		CampaignMember newCampMember=[SELECT Id, GenericField1__c
		                              FROM CampaignMember
		                              WHERE GenericField1__c='testGenField'
		                              LIMIT 1];

		Test.stopTest();

		System.assertEquals(true, newCampMember.Id!=null, 'Campaign Member not Created');
		System.assertNotEquals(false, newCampMember.Id!=null);
	}

	@isTest
	static void testUpdateRecords(){

		Test.setMock(HttpCalloutMock.class, mock);

		Test.startTest();

		List<Campaign> tCampaigns=[SELECT Id, Name, Category__c, Description, StaticTextMessageBill__c, Channel__c
		                           FROM Campaign
		                           WHERE Category__c='Campagna Outbound'
		                           LIMIT 1];

		List<Lead> tLeads=[SELECT Id, FirstName
		                   FROM Lead
		                   WHERE FirstName='FirstNameTest0'
		                   LIMIT 1];

		List<Contact> tContacts=[SELECT Id, FirstName
		                         FROM Contact
		                         WHERE FirstName='test'
		                         LIMIT 1];


		List<Campaignmember> campMembers=HDT_UTL_DataFactoryTst.createCampaignMember(1, false, tCampaigns[0].Id, tLeads[0].Id, tContacts[0].Id);
		campMembers[0].GenericField1__c='testGenField';
		campMembers[0].ContractReference__c='testConRef';

		List<CommercialCode__c> commCodes=HDT_UTL_DataFactoryTst.createCommCode(1, false);
		commCodes[0].FullCode__c='testCode';
		commCodes[0].Campaign__c=tCampaigns[0].Id;
		insert commCodes;

		campMembers[0].PromoCommercialCode__c=commCodes[0].Id;
		insert campMembers;

		campMembers[0].GenericField1__c='tstUpdatedFenField';

		CampMembSrv.updateRecords(campMembers);

		CampaignMember updtCampMember=[SELECT Id, GenericField1__c
		                               FROM CampaignMember
		                               WHERE GenericField1__c='tstUpdatedFenField'
		                               LIMIT 1];

		Test.stopTest();

		System.assertEquals('tstUpdatedFenField', updtCampMember.GenericField1__c, 'Campaign Members not Updated');
		System.assertNotEquals('testGenField', updtCampMember.GenericField1__c);
	}
}