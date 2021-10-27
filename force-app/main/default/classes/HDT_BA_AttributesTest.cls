@isTest
public with sharing class HDT_BA_AttributesTest {
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
            tempLead.Rating='Hot';
            listLead.add(tempLead);
        }
        for (Integer i = 0; i < 20; i++) {
            Lead tempLead=new Lead();
            tempLead.LastName='testLastName2'+String.valueOf(i);
            tempLead.FirstName='FirstNameName'+String.valueOf(i);
            tempLead.Email=tempLead.LastName+'@test.it';
            tempLead.CompanyOwner__c='AAA-EBT';
            tempLead.Company='test';
            tempLead.ContactReason__c='Altro';
            
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
        
     /*  Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HDT_RT_Residenziale').getRecordTypeId();
        
        Account acc = new Account();
        acc.RecordTypeId=accRecordTypeId;
        acc.CompanyOwner__c='HERA COMM';
        acc.CustomerCode__c='12345';
        acc.CustomerMarking__c='Persona fisica';
        acc.FirstName__c='Mario';
        acc.LastName__c='Rossi';
        Date myDate = Date.newInstance(1980, 1, 1);
        acc.IsWrongFiscalData__c=false;
        acc.BirthDate__c=myDate;
        acc.FiscalCode__c='RSSMRA80A01F839W';
        acc.RowIdSiebel__c='1000';
        acc.Segment__c='FAMIGLIE';
        acc.Name='Rossi';
        acc.BillingStreetName__c='Via Roma';
        acc.BillingCityCode__c='80100';
        acc.BillingStreetNumber__c='1';
        acc.Category__c='Famiglie';
        insert acc;
        */

        List<Account> acc=HDT_UTL_DataFactoryTst.createAccountResidenziale(1, true, 'HERA COMM', 'D1 - Persona fisica', 'Enti');


        List<Contact> listContact = new List<Contact>();
        for (Integer i = 0; i < 10; i++) {
            Contact tempContact=new Contact();
            tempContact.LastName='testLastName'+String.valueOf(i);
            tempContact.FirstName='FirstNameName'+String.valueOf(i);
            tempContact.Email=tempContact.LastName+'@test.it';
            tempContact.AccountId=acc[0].id;
            tempContact.CompanyOwner__c='HERA COMM';
            listContact.add(tempContact);
        }
        
        for (Integer i = 0; i < 30; i++) {
            Contact tempContact=new Contact();
            tempContact.LastName='testLastNameCon'+String.valueOf(i);
            tempContact.FirstName='FirstNameNameCon'+String.valueOf(i);
            tempContact.Email=tempContact.LastName+'@test.it';
            tempContact.CompanyOwner__c='HERA COMM';
            listContact.add(tempContact);
        }
        for (Integer i = 0; i < 20; i++) {
            Contact tempContact=new Contact();
            tempContact.LastName='testLastNameCon2'+String.valueOf(i);
            tempContact.FirstName='FirstNameNameCon'+String.valueOf(i);
            tempContact.Email=tempContact.LastName+'@test2.it';
            tempContact.CompanyOwner__c='HERA COMM';
            tempContact.AccountId=acc[0].id;

            listContact.add(tempContact);
            
        }
        insert listContact;
        Id ordRecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_Subentro').getRecordTypeId();
        
        Date myDate2 = Date.newInstance(2022, 1, 1);
        Order ord=new Order();
        ord.recordTypeId=ordRecordTypeId;
        ord.AccountId=acc[0].id;
        ord.Contact__c=listContact.get(0).id;       
        ord.status='Draft';
        ord.EffectiveDate=myDate2;
        
        // insert ord;
       
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_Subentro_EE').getRecordTypeId();
        
        List<Case> listCase = new List<Case>();
        List<Contract> listContract = new List<Contract>();
        List<BillingProfile__c> listbill = new List<BillingProfile__c>();
        for (Integer i = 0; i < 30; i++) {
            Contract ctr = new contract();
            Case mCase=new Case();
            mcase.Origin='Email';
            mCase.ContactId=listContact.get(i).id;
            mcase.recordTypeId=caseRecordTypeId;
            mCase.Outcome__c='OK';
            mCase.Reason='New problem';
            mcase.EarlyRecess__c=false;
            mcase.EnergyService__c='Si';
            mcase.Market__c='Libero';
            mcase.Status='New'; 
            mCase.SalesCompany__c='test';
            listCase.add(mcase);
            ctr.AccountId=acc[0].id;
            ctr.Contact__c=listContact.get(i).id;
            ctr.ContractTerm=12;
            ctr.Status='Draft';
            ctr.StartDate=myDate2;
            listContract.add(ctr);
            BillingProfile__c bill=new BillingProfile__c();
            bill.Account__c=acc[0].Id;
            bill.Contact__c=listContact.get(i).id;
            bill.BillSendingMethod__c='Fatturazione PA';
            bill.PaymentMethod__c='Bollettino postale';
            bill.Status__c='New';
            listbill.add(bill);
        }
        insert listCase;
        insert listContract;
        insert listbill;
        
        
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
        HDT_BA_AttributesLead shn = new HDT_BA_AttributesLead('123458'); 
        Id batchprocessid = Database.executeBatch(shn);
        Test.StopTest();
        
        List<ContentVersion> listContentVersion = [SELECT id FROM ContentVersion];
        System.assertEquals(2, listContentVersion.size(), 'Value of parameter is matching');
        System.assertNotEquals(1, listContentVersion.size(), 'Value of parameter is not matching');
        
        
    }
    
}
