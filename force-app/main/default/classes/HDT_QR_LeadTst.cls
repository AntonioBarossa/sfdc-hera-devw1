/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 16/07/2021
 * @description Test Class for HDT_QR_LeadTst.cls
 * @history Fabricio Petkevicius Nunes – 16/07/2021 – Created class
 */
@isTest
public class HDT_QR_LeadTst{
	@TestSetup
	static void setup(){

		List<Lead> leadList = HDT_UTL_DataFactoryTst.createLead(1, false);

		Individual indTest = new Individual();

		indTest.LastName = 'Test';

		insert indTest;

		leadList[0].IndividualId = indTest.Id;
		leadList[0].Country = 'Italy';
		leadList[0].State = '';
		leadList[0].City = '';
		leadList[0].PostalCode = '';
		leadList[0].Street = 'test st';


		insert leadList;
	}

	@isTest
	static void getRecordByIndividual(){

		Test.startTest();

		Lead tLead = [SELECT Id, Firstname, IndividualId FROM Lead WHERE Status = 'New' LIMIT 1];

		HDT_QR_Lead qrLead = new HDT_QR_Lead();
		List<Lead> testLead = qrLead.getRecordByIndividual(tLead.IndividualId, 'id, country');

		System.assertNotEquals('', testLead[0].country, 'value of parameter is not matching');
		System.assertEquals('Italy', testLead[0].Country, 'Lead Country is wrong');

		Test.stopTest();
	}

	@isTest
	static void testgetRecordById(){

		Test.startTest();

		Lead tLead = [SELECT Id, Status, Firstname, LastName, IndividualId, birthdate__c, gender__c, birthcity__c, country, state, city, PostalCode, street, streetName__c, StreetNumber__c, CityCode__c, StreetNumberExtension__c, StreetCode__c
		              FROM Lead
		              WHERE Status = 'New'
		              LIMIT 1];

		HDT_QR_Lead qrLead = new HDT_QR_Lead();

		Lead testLead = qrLead.getRecordById(tLead.Id);

		System.assertEquals('Italy', testLead.Country, 'Lead Country is wrong');
		System.assertNotEquals('', testLead.Country, 'value of parameter is not matching');

		Test.stopTest();
	}
}