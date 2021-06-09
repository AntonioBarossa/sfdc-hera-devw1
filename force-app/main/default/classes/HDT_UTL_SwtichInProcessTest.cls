@isTest
public class HDT_UTL_SwtichInProcessTest {
    
        @testSetup
        static void setup() {

            Id rtId = [SELECT Id FROM recordType WHERE developerName = 'HDT_RT_Business' and sObjectType = 'Account'].Id;

            Account acc = new Account();

                acc.FirstName__c = 'Mickey';
                acc.LastName__c = 'Mouse';
                acc.Name = 'Mickey Mouse';
                acc.FiscalCode__c = 'PCCLSN78C24B354F';
                acc.RecordTypeId = rtId;            
                acc.VatNumber__c = '99999999999';
                acc.CustomerMarking__c = 'ACEL-Persona fisica';
                acc.Category__c = 'Aziende';
                acc.CompanyOwner__c = 'HERA COMM';
                // acc.BillingCity = currentCase.BillingCity__c;
                // acc.BillingCityCode__c = currentCase.BillingCityCode__c;
                // acc.BillingCountry = currentCase.BillingCountry__c;
                // acc.BillingIsAddressVerified__c = currentCase.BillingIsAddressVerified__c;
                // acc.BillingPlace__c = currentCase.BillingPlace__c;
                // acc.BillingPostalCode = currentCase.BillingPostalCode__c;
                // acc.BillingState = currentCase.BillingProvince__c;
                // acc.BillingStreetCode__c = currentCase.BillingStreetCode__c;
                // acc.BillingStreetName__c = currentCase.BillingStreetName__c;
                // acc.BillingStreetNumber__c = currentCase.BillingStreetNumber__c;
                // acc.BillingStreetNumberExtension__c = currentCase.BillingStreetNumberExtension__c;
                // acc.BillingStreetToponym__c = currentCase.BillingStreetToponym__c;
                // objToUpdate = acc;
            

            //Account accTest = new Account(FirstName__c='Test001',LastName__c='AccountTest',FiscalCode__c='00100010',Category__c='Famiglie', CustomerMarking__c='ACEL-Persona fisica',VATNumber__c='', VATGroup__c='');
            insert acc;

            Date Ed = Date.today();

            Order ordTest = new Order(Status='Draft', EffectiveDate=Ed,SignedDate__c=Ed);
            ordTest.AccountId = acc.Id;
            insert ordTest;

        }   

        @isTest static void getMaxAfterthoughtDateTest() {

            Test.startTest();   
                Order testOrder = [select id, SignedDate__c from Order];

                HDT_UTL_SwtichInProcess.getMaxAfterthoughtDate(testOrder);

                Test.stopTest();

        }

}