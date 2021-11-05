/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 20/09/2021
 * @description HDT_LC_GestionePrivacyField Test Classes
 * @history Fabricio Petkevicius Nunes – 20/09/2021 – Created class
 */
@isTest
public with sharing class HDT_LC_GestionePrivacyFieldTst{
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
	@TestSetup
	static void makeData(){

		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, true);

		System.runAs(internalUser){

			List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
			List<Individual> individuals=HDT_UTL_DataFactoryTst.createIndividual(1, true);
			List<Contact> contacts=HDT_UTL_DataFactoryTst.createContact(1, false, accounts[0].Id);
			contacts[0].IndividualId=individuals[0].Id;
			insert contacts;
			List<Lead> leads=HDT_UTL_DataFactoryTst.createLead(1, false);
			leads[0].IndividualId=individuals[0].Id;
			insert leads;
		}
	}

	@isTest
	public static void testUpdateIndividual(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();

			List<Contact> tContact=[SELECT Id, FirstName
			                        FROM Contact
			                        WHERE FirstName='test'
			                        LIMIT 1];

			List<Lead> tLead=[SELECT Id, FirstName
			                  FROM Lead
			                  WHERE FirstName='FirstNameTest0'];


			Map<String, String> indvData=new Map<String, String>();
			indvData.put('ProfilingPrivacy', 'SI');

			HDT_LC_GestionePrivacyField.updateIndividual(tContact[0].Id, 'Contact', indvData);
			HDT_LC_GestionePrivacyField.updateIndividual(tLead[0].Id, 'Lead', indvData);

			test.stopTest();

			Individual tIndividual=[SELECT Id, ProfilingPrivacy__c
			                        FROM Individual
			                        WHERE ProfilingPrivacy__c='SI'
			                        LIMIT 1];

			System.assertEquals(true, tIndividual.Id!=null, 'Individual not updated');
			System.assertNotEquals(false, tIndividual.Id!=null, 'Individual not updated');
		}
	}
}