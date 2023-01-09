/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 21/09/2021
 * @description HDT_TRH_Lead Test Classes
 * @history Fabricio Petkevicius Nunes – 21/09/2021 – Created class
 * @history Sabina Levonja – 07/10/2021
 */
@isTest
public with sharing class HDT_TRH_LeadTst{
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
	@TestSetup
	static void makeData(){
		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, true);

		HDT_UTL_DataFactoryTst.createIndividual(1, true);
			List<Lead> leads=HDT_UTL_DataFactoryTst.createLead(1, false);
         	leads[0].VATNumber__c = '07988320011';
			leads[0].FiscalCode__c = '07988320011';
            leads[0].CustomerMarking__c= 'Azienda';
            leads[0].CompanyOwner__c ='HERA COMM';
            leads[0].Category__c ='Aziende SME';
            leads[0].CityCode__c='Roma';
            leads[0].StreetName__c='via roma';
            leads[0].StreetNumber__c='55';
            leads[0].IsAddressVerified__c = true;

			insert leads;
			List<City__c> cities = HDT_UTL_DataFactoryTst.createCity();
        	cities[0].BelfioreCode__c='Bt00';
        	update cities;

			List<User> ownerUser = new List<User>();
			ownerUser.add(internalUser);

			List<Lead> myLeadList = [Select id from Lead WHERE FirstName='FirstNameTest0' LIMIT 1];

			Database.LeadConvert convLead=new Database.LeadConvert();
			convLead.setLeadId(myLeadList[0].Id);

			leadStatus convertStatus=[SELECT Id, MasterLabel
			                          FROM LeadStatus
			                          WHERE IsConverted=true
			                          LIMIT 1];
			convLead.setConvertedStatus(convertStatus.MasterLabel);

			Database.convertLead(convLead);
            HDT_UTL_DataFactoryTst.createWebServiceConfiguration('BP_CA', 'test.com', 'post', 'testUser');
            HDT_UTL_DataFactoryTst.createWebServiceCredential('testUser', '12345', 'usernameTest');

	}

	@isTest
	public static void testTriggerLeadBeforeAfterInsert(){

		List<User> tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser[0]){

			test.startTest();

			Lead lead = [SELECT Id, FirstName,LastName,MobilePhone,Company, CompanyOwner__c,MobilePhonePrefix__c/*,ConvertedContactId*/,Phone,Email,IndividualId, PhonePrefix__c FROM Lead WHERE FirstName='FirstNameTest0' AND IsConverted = true LIMIT 1];
			Lead newLead= lead.clone();
			newLead.Country = 'Italy';
            newLead.CompanyOwner__c= 'MMS';
            newLead.Company='Default';
            newLead.CityCode__c='Verona';
			insert newLead;
            
			Lead l= lead.clone();
            l.Email='';
            l.Phone='0033344456';
            l.Company='Default';

            insert l;
			test.stopTest();
			
            List<Lead> leads = [SELECT Id, FirstName,CityCode__c FROM Lead Where CityCode__c='Verona'];

			System.assertEquals(1, leads.size(), 'Lead not created');
			System.assertNotEquals(true, leads.isEmpty(),'The lead has not been inserted');
		}
	}
    @isTest
	public static void testTriggerLeadBeforeAfterUpdate(){

		List<User> tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser[0]){

			test.startTest();

			Lead lead = [SELECT Id, FirstName,LastName,MobilePhone,Company, CompanyOwner__c,MobilePhonePrefix__c/*,ConvertedContactId*/,Phone,Email,IndividualId, PhonePrefix__c FROM Lead WHERE FirstName='FirstNameTest0' AND IsConverted = true LIMIT 1];
			
            lead.LastName='Smith';
            lead.FirstName='George';
            lead.FiscalCode__c='13288870150';
            lead.Birthdate__c= Date.parse('2/10/1990') ;
            lead.Birthcity__c='Roma';
            lead.Gender__c='Maschio';
            update lead;

			HDT_LC_LeadCalculateFiscalCode.calculateLeadFiscalCode(lead.Id);
			
			test.stopTest();

			List<Lead> leads = [SELECT Id,FiscalCode__c,Birthcity__c, FirstName,LastName FROM Lead Where LastName='Smith'];

			System.assertEquals(true, leads[0].FiscalCode__c!=null, 'Lead has not been updated');
			System.assertNotEquals('', leads[0].Birthcity__c,'The Birthcity__c has not been updated');		
		}
	}
}