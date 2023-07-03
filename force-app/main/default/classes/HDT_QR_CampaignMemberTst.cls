/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 23/08/2021
 * @description Test Class for HDT_QR_Campaign.cls
 * @history Fabricio Petkevicius Nunes – 23/08/2021 – Created class
 */
@isTest
public class HDT_QR_CampaignMemberTst{
	private static HDT_QR_CampaignMember campMembQr=new HDT_QR_CampaignMember();
	@TestSetup
	static void setup(){
		List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
		for (Account temp : accounts) {
			temp.VATNumber__c='12345678901';
		}
		update accounts;
		List<Lead> leads=HDT_UTL_DataFactoryTst.createLead(1, false);
		leads[0].Latitude=-34.397;
		leads[0].Longitude=150.644;
		leads[0].Country='Australia';
		insert leads;

		List<Contact> contacts=HDT_UTL_DataFactoryTst.createContact(1, false, accounts[0].Id);
		contacts[0].MailingLatitude=-34.397;
		contacts[0].MailingLongitude=150.644;
		contacts[0].MailingCountry='Australia';
		insert contacts;

		List<Campaign> campaigns=HDT_UTL_DataFactoryTst.createCampaign(2, false);
		campaigns[1].ParentId=campaigns[0].Id;
		campaigns[0].IsActive=true;
		campaigns[0].StartDate=Date.today().addDays(-1);
		campaigns[0].EndDate=Date.today().addDays(15);
		campaigns[0].Category__c='Campagna CRM';
		campaigns[0].Channel__c='Telefonico Inbound';
		campaigns[0].Required__c=true;
		insert campaigns;

		List<CampaignMember> campMembs=HDT_UTL_DataFactoryTst.createCampaignMember(false, campaigns[0].Id, leads, contacts);
		campMembs[0].Ecid__c='test';
		campMembs[0].isToSendStatusReitek__c=true;
		insert campMembs;

		HDT_UTL_DataFactoryTst.createPaperProcessing(1, true, 'test', campaigns[0].id);

		HDT_UTL_DataFactoryTst.createAccountPartner(1, true, 'testPartnerAccount');

	}

	@isTest
	static void testgetActiveCampaignsByContact(){

		Test.startTest();

		List<Contact> tContact=[SELECT Id, FirstName
		                        FROM Contact
		                        WHERE FirstName='test'
		                        LIMIT 1];


		List<CampaignMember> getCampByContact=campMembQr.getActiveCampaignsByContact(tContact[0].Id);

		Test.stopTest();

		//System.assertEquals(false, getCampByContact.isEmpty(), 'Campaign Member not found');
		System.assertEquals( true,!getCampByContact.isEmpty(),true);
	}

	@isTest
	static void testgetActiveCampaignsByLead(){

		Test.startTest();

		List<Lead> tLead=[SELECT Id, FirstName
		                  FROM Lead
		                  WHERE FirstName='FirstNameTest0'
		                  LIMIT 1];


		List<CampaignMember> getCampByLead=campMembQr.getActiveCampaignsByLead(tLead[0].Id);

		Test.stopTest();

		System.assertEquals(false, getCampByLead.isEmpty(), 'Campaign Member not found');
		System.assertNotEquals(true, getCampByLead.isEmpty(), 'Campaign Member not found');
	}

	@isTest
	static void testgetActiveCampaignsByContacts(){

		Test.startTest();

		List<Contact> tContact=[SELECT Id, FirstName
		                        FROM Contact
		                        WHERE FirstName='test'
		                        LIMIT 1];


		List<CampaignMember> getCampByContacts=campMembQr.getActiveCampaignsByContacts(tContact);

		Test.stopTest();

		System.assertEquals(false, getCampByContacts.isEmpty(), 'Campaign Member not found');
		System.assertNotEquals(true, getCampByContacts.isEmpty(), 'Campaign Member not found');
	}

	@isTest
	static void testgetCampaignsFilteredByContacts(){

		Test.startTest();

		List<Contact> tContact=[SELECT Id, FirstName
		                        FROM Contact
		                        WHERE FirstName='test'
		                        LIMIT 1];

		List<String> contactIds=new List<String>();
		contactIds.add(tContact[0].id);

		List<CampaignMember> getCampFilteredByContacts=campMembQr.getCampaignsFilteredByContacts(contactIds);
		campMembQr.getCampaignsFilteredByContactsWithStatus(contactIds);

		Test.stopTest();

		System.assertEquals(false, getCampFilteredByContacts.isEmpty(), 'Campaign Member not found');
		System.assertNotEquals(true, getCampFilteredByContacts.isEmpty(), 'Campaign Member not found');
	}

	@isTest
	static void testfilterCampaignsByCategory(){

		Test.startTest();

		List<Contact> tContact=[SELECT Id, FirstName
		                        FROM Contact
		                        WHERE FirstName='test'
		                        LIMIT 1];

		List<String> contactIds=new List<String>();
		contactIds.add(tContact[0].id);

		List<CampaignMember> getCampByCategory=campMembQr.filterCampaignsByCategory(contactIds, 'Campagna CRM');

		Test.stopTest();

		System.assertEquals(false, getCampByCategory.isEmpty(), 'Campaign Member not found');
		System.assertNotEquals(true, getCampByCategory.isEmpty(), 'Campaign Member not found');
	}

	@isTest
	static void testfilterCampaignsByCategoryAndChannel(){

		Test.startTest();

		List<Contact> tContact=[SELECT Id, FirstName
		                        FROM Contact
		                        WHERE FirstName='test'
		                        LIMIT 1];

		List<String> contactIds=new List<String>();
		contactIds.add(tContact[0].id);

		List<CampaignMember> getCampByCategAndChannel=campMembQr.filterCampaignsByCategoryAndChannel(contactIds, 'Campagna CRM', 'Telefonico Inbound');

		Test.stopTest();

		System.assertEquals(false, getCampByCategAndChannel.isEmpty(), 'Campaign Member not found');
		System.assertNotEquals(true, getCampByCategAndChannel.isEmpty(), 'Campaign Member not found');
	}

	@isTest
	static void testgetUnassignedCampaignMembers(){

		Test.startTest();

		List<Campaign> tCampaign=[SELECT Id, Category__c
		                          FROM Campaign
		                          WHERE Category__c='Campagna CRM'
		                          LIMIT 1];


		List<CampaignMember> getUnassCampMember=campMembQr.getUnassignedCampaignMembers(tCampaign[0].Id);

		Test.stopTest();

		System.assertEquals(false, getUnassCampMember.isEmpty(), 'Campaign Member not found');
		System.assertNotEquals(true, getUnassCampMember.isEmpty(), 'Campaign Member not found');
	}

	@isTest
	static void testgetUnassignedCampaignMembersSlice(){

		Test.startTest();

		List<Campaign> tCampaign=[SELECT Id, Category__c
		                          FROM Campaign
		                          WHERE Category__c='Campagna CRM'
		                          LIMIT 1];


		List<CampaignMember> getUnassCampMemberSlice=campMembQr.getUnassignedCampaignMembersSlice(tCampaign[0].Id, 1);

		Test.stopTest();

		System.assertEquals(false, getUnassCampMemberSlice.isEmpty(), 'Campaign Member not found');
		System.assertNotEquals(true, getUnassCampMemberSlice.isEmpty(), 'Campaign Member not found');
	}

	@isTest
	static void testgetAccountsforCampaignMembers(){

		Test.startTest();

		List<Account> getAccsforCampMembs=campMembQr.getAccountsforCampaignMembers();

		Test.stopTest();

		System.assertNotEquals(false, getAccsforCampMembs.isEmpty(), 'Campaign Member not found');
		System.assertEquals(true, getAccsforCampMembs.isEmpty(), 'Campaign Member not found');
	}

	@isTest
	static void testgetAccountAndCampaign(){

		Test.startTest();

		List<CampaignMember> tCampMember=[SELECT Id
		                                  FROM CampaignMember
		                                  LIMIT 1];


		CampaignMember getAccAndCamp=campMembQr.getAccountAndCampaign(tCampMember[0].Id);

		Test.stopTest();

		System.assertEquals(true, getAccAndCamp!=null, 'Campaign Member not found');
		System.assertNotEquals(false, getAccAndCamp!=null, 'Campaign Member not found');
	}

	@isTest
	static void testgetCampaignMembersByContacts(){

		Test.startTest();

		List<Contact> tContact=[SELECT Id, FirstName
		                        FROM Contact
		                        WHERE FirstName='test'
		                        LIMIT 1];


		List<CampaignMember> getCampMembByContacts=HDT_QR_CampaignMember.getCampaignMembersByContacts(tContact);

		Test.stopTest();

		System.assertEquals(false, getCampMembByContacts.isEmpty(), 'Campaign Member not found');
		System.assertNotEquals(true, getCampMembByContacts.isEmpty(), 'Campaign Member not found');
	}

	@isTest
	static void testgetByEcid(){

		Test.startTest();

		CampaignMember getByEcid=campMembQr.getByEcid('test');

		Test.stopTest();

		System.assertEquals(true, getByEcid!=null, 'Campaign Member not found');
		System.assertNotEquals(false, getByEcid!=null, 'Campaign Member not found');
	}

	@isTest
	static void testgetEcidById(){

		Test.startTest();

		List<CampaignMember> tCampMember=[SELECT Id
		                                  FROM CampaignMember
		                                  LIMIT 1];


		CampaignMember getEcidById=campMembQr.getEcidById(tCampMember[0].Id);

		Test.stopTest();

		System.assertEquals(true, getEcidById!=null, 'Campaign Member not found');
		System.assertNotEquals(false, getEcidById!=null, 'Campaign Member not found');
	}

	@isTest
	static void testgetContactsWithinDistance(){
		Test.startTest();
		List<Campaign> tCamp=[SELECT Id, Channel__c
		                      FROM Campaign
		                      WHERE Channel__c='Telefonico Inbound'
		                      LIMIT 1];

		tCamp[0].Category__c='Campagna Outbound';
		tCamp[0].Channel__c='Door to Door';
		update tCamp;

		List<CampaignMember> getContactsWithinDist=campMembQr.getContactsWithinDistance(-34.387, 150.646, 1500);

		Test.stopTest();

		System.assertEquals(false, getContactsWithinDist.isEmpty(), 'Campaign Member not found');
		System.assertNotEquals(true, getContactsWithinDist.isEmpty(), 'Campaign Member not found');
	}

	@isTest
	static void testgetLeadsWithinDistance(){

		Test.startTest();

		List<Campaign> tCamp=[SELECT Id, Channel__c
		                      FROM Campaign
		                      WHERE Channel__c='Telefonico Inbound'
		                      LIMIT 1];

		tCamp[0].Category__c='Campagna Outbound';
		tCamp[0].Channel__c='Door to Door';
		update tCamp;

		List<CampaignMember> getLeadsWithinDist=campMembQr.getLeadsWithinDistance(-34.387, 150.646, 1500);

		Test.stopTest();

		System.assertEquals(false, getLeadsWithinDist.isEmpty(), 'Campaign Member not found');
		System.assertNotEquals(true, getLeadsWithinDist.isEmpty(), 'Campaign Member not found');
	}

	@isTest
	static void testgetMembersByAccountAndCampaign(){

		Test.startTest();

		List<CampaignMember> tCampMember=[SELECT Id
		                                  FROM CampaignMember
		                                  LIMIT 1];

		List<Account> tAccs=[SELECT Id, VATNumber__c
		                     FROM Account limit 1];

/*
		String acc=tAccs[0].id;
		String campMem=tCampMember[0].Id;
		List<String> campMembIds=new List<String>();
		campMembIds.add(campMem);

		List<String> accId=new List<String>();
		accId.add(acc);
*/
		List<CampaignMember> getMembByAccAndCamp=campMembQr.getMembersByAccountAndCampaign(new list<String>{tAccs.get(0).id},new list<String>{tCampMember.get(0).Id});

		Test.stopTest();

		System.assertEquals(true, getMembByAccAndCamp!=null, 'Campaign Member not found');
		System.assertNotEquals(false, getMembByAccAndCamp!=null,'value of parameter is not matching');

	}

	@isTest
	static void testgetCampaignMembersForPaperProcessing(){

		Test.startTest();

		List<PaperProcessing__c> tPaperProc=[SELECT Id
		                                     FROM PaperProcessing__c
		                                     LIMIT 1];

		List<CampaignMember> camList = [SELECT id,PaperProcess__c FROM CampaignMember];
		System.debug('camList++++++++++++++ '+ camList); 

		camList[0].PaperProcess__c = null;
		update camList;

		List<CampaignMember> getCampMemForPaperProc=campMembQr.getCampaignMembersForPaperProcessing(tPaperProc[0].Id );

		Test.stopTest();

		System.assertEquals(false, getCampMemForPaperProc.isEmpty(), 'Campaign Member not found');
		System.assertNotEquals(true, getCampMemForPaperProc.isEmpty(),'value of parameter is not matching');

	}

	@isTest
	static void testgetMembersByCampaign(){

		Test.startTest();

		List<Campaign> tCampaign=[SELECT Id, Category__c
		                          FROM Campaign
		                          WHERE Category__c='Campagna CRM'
		                          LIMIT 1];


		List<CampaignMember> getCampMemByCamp=campMembQr.getMembersByCampaign(tCampaign[0].Id);

		Test.stopTest();

		System.assertEquals(false, getCampMemByCamp.isEmpty(), 'Campaign Member not found');
		System.assertNotEquals(true, getCampMemByCamp.isEmpty(), 'Campaign Member not found');
	}

	@isTest
	static void testgetCampaignMemberByCampaingAndContact(){

		Test.startTest();

		List<Campaign> tCampaign=[SELECT Id, Category__c
		                          FROM Campaign
		                          WHERE Category__c='Campagna CRM'
		                          LIMIT 1];

		List<Contact> tContact=[SELECT Id, FirstName
		                        FROM Contact
		                        WHERE FirstName='test'
		                        LIMIT 1];

		List<CampaignMember> getCampMemByCampAndContact=campMembQr.getCampaignMemberByCampaingAndContact(tCampaign[0].Id, tContact[0].Id);

		Test.stopTest();

		System.assertEquals(false, getCampMemByCampAndContact.isEmpty(), 'Campaign Member not found');
		System.assertNotEquals(true, getCampMemByCampAndContact.isEmpty(), 'Campaign Member not found');
	}

	@isTest
	static void testgetCampaignMemberByCampaingAndContactInBulk(){

		Test.startTest();

		List<Campaign> tCampaign=[SELECT Id, Category__c
		                          FROM Campaign
		                          WHERE Category__c='Campagna CRM'
		                          LIMIT 1];

		List<Contact> tContact=[SELECT Id, FirstName
		                        FROM Contact
		                        WHERE FirstName='test'
		                        LIMIT 1];


		String con=tContact[0].id;
		String camp=tCampaign[0].Id;
		List<String> campaignIds=new List<String>();
		campaignIds.add(camp);

		List<String> conIds=new List<String>();
		conIds.add(con);

		List<CampaignMember> getCampMemByCampAndContactBulk=campMembQr.getCampaignMemberByCampaingAndContactInBulk(campaignIds, conIds);

		Test.stopTest();

		System.assertEquals(false, getCampMemByCampAndContactBulk.isEmpty(), 'Campaign Member not found');
		System.assertNotEquals(true, getCampMemByCampAndContactBulk.isEmpty(), 'Campaign Member not found');
	}

	@isTest
	static void testgetSiblingMembersByAccountId(){

		Test.startTest();

		List<Account> tAccs=[SELECT Id, VATNumber__c
		                     FROM Account
		                     WHERE VATNumber__c='12345678901'];

		String acc=tAccs[0].id;
		List<String> accIds=new List<String>();
		accIds.add(acc);

		List<CampaignMember> getSibMembByAccId=HDT_QR_CampaignMember.getSiblingMembersByAccountId(accIds, 'Telefonico Inbound');

		Test.stopTest();

		System.assertEquals(false, getSibMembByAccId.isEmpty(), 'Campaign Member not found');
		System.assertNotEquals(true, getSibMembByAccId.isEmpty(), 'Campaign Member not found');
	}
}