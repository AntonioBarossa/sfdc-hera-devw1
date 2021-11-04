@isTest
public with sharing class HDT_BA_ConsentContactTest {
   @TestSetup
   static void makeData(){
	   List<Lead> listLead = new List<Lead>();
	   for (Integer i = 0; i < 30; i++) {
		   Lead tempLead=new Lead();
		   tempLead.LastName='testLastName'+String.valueOf(i);
		   tempLead.FirstName='FirstNameName'+String.valueOf(i);
		   tempLead.Email=tempLead.LastName+'@test.it';
		   tempLead.CompanyOwner__c='AAA-EBT';
		   tempLead.Company='test';
		   listLead.add(tempLead);
	   }
	   for (Integer i = 0; i < 20; i++) {
		Lead tempLead=new Lead();
		tempLead.LastName='testLastName2'+String.valueOf(i);
		tempLead.FirstName='FirstNameName'+String.valueOf(i);
		tempLead.Email=tempLead.LastName+'@test.it';
		tempLead.CompanyOwner__c='AAA-EBT';
		tempLead.Company='test';
		listLead.add(tempLead);
	}
	   insert listLead;
	   List<Individual> listInd = new List<Individual>();
	   integer j=0;
	   for (Lead tempLead : listLead) {
			Individual individual =new Individual(
			LastName = tempLead.LastName,
			FirstName = tempLead.firstName,
			ProfilingPrivacy__c='SI',
			PrivacyProfilingChoiceDate__c=Date.today().addDays(-j)    
			);

			listInd.add(individual);
			j++;
		}

		List<Contact> listContact = new List<Contact>();
		for (Integer i = 0; i < 10; i++) {
			Contact tempContact=new Contact();
			tempContact.LastName='testLastName'+String.valueOf(i);
			tempContact.FirstName='FirstNameName'+String.valueOf(i);
			tempContact.Email=tempContact.LastName+'@test.it';
			listContact.add(tempContact);
		}
	  
		for (Integer i = 0; i < 30; i++) {
			Contact tempContact=new Contact();
			tempContact.LastName='testLastNameCon'+String.valueOf(i);
			tempContact.FirstName='FirstNameNameCon'+String.valueOf(i);
			tempContact.Email=tempContact.LastName+'@test.it';
			listContact.add(tempContact);
		}
		for (Integer i = 0; i < 20; i++) {
			Contact tempContact=new Contact();
			tempContact.LastName='testLastNameCon2'+String.valueOf(i);
			tempContact.FirstName='FirstNameNameCon'+String.valueOf(i);
			tempContact.Email=tempContact.LastName+'@test.it';
			listContact.add(tempContact);
		}
		insert listContact;

		integer p=0;
		for (Contact tempContact : listContact) {
			 Individual individual =new Individual(
			 LastName = tempContact.LastName,
			 FirstName = tempContact.firstName,
			 ProfilingPrivacy__c='SI',
			 PrivacyProfilingChoiceDate__c=Date.today().addDays(-p)    
			 );
 
			 listInd.add(individual);
			 p++;
		 }
		 insert listInd;
		 HDT_WebServiceConfiguration__c wsConf=new HDT_WebServiceConfiguration__c();
		 wsConf.name='CampagenDmDmpData';
		 wsConf.Endpoint__c='https://integration-ts.gruppohera.it/dev/salesforce-api-exp/api/data-management/files';
		 wsConf.Method__c='POST';
		 wsConf.User__c='MulesoftSalesforceUser';
		 insert wsConf;

   }


   @isTest
   public static void testConsentLead(){
	   Test.StartTest();
		 	HDT_BA_ConsentLead shn = new HDT_BA_ConsentLead('123458'); 
			Database.executeBatch(shn);
		Test.StopTest();
		
		List<ContentVersion> listContentVersion = [SELECT id FROM ContentVersion];
		System.assertEquals(2, listContentVersion.size(),'value of parameter is matching');


   }
   @isTest
   public static void testConsentNoContact(){
	   List<Contact> listContact = [SELECT Id FROM Contact];
	   delete listContact;
		Test.StartTest();
			HDT_BA_ConsentLead shn = new HDT_BA_ConsentLead('123458'); 
			Database.executeBatch(shn);
	 	Test.StopTest();
		List<ContentVersion> listContentVersion = [SELECT id FROM ContentVersion];
		System.assertEquals(1, listContentVersion.size(),'value of parameter is matching');
	}
}