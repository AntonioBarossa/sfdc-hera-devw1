@IsTest
public class HDT_UTL_SalesTst {
    @TestSetup
    static void makeData(){

        Account acc0=new Account();
			acc0.Name='test account0';
			acc0.CompanyOwner__c='AAA-EBT';
			acc0.CustomerMarking__c='AAS Azienda';
			acc0.Category__C='Enti';
			acc0.VATNumber__c='123';
			acc0.BillingCityCode__c='Roma';
			acc0.BillingStreetName__c='via roma';
			acc0.BillingStreetNumber__c='55';
			acc0.LastName__c='test account0';
			acc0.FiscalCode__c='SXSRLA45H28H501K';
			acc0.BillingIsAddressVerified__c=true;
        	acc0.IsWrongFiscalData__c = false;
        	acc0.BillingIsAddressVerified__c = true;
			acc0.CustomerCode__c = '0000000';
        
        Account acc1=new Account();
			acc1.Name='test account0';
			acc1.CompanyOwner__c='AAA-EBT';
			acc1.CustomerMarking__c='AAS Associazione';
			acc1.Category__C='Aziende Soho';
			acc1.VATNumber__c='12344';
			acc1.BillingCityCode__c='Roma';
			acc1.BillingStreetName__c='via roma';
			acc1.BillingStreetNumber__c='55';
			acc1.LastName__c='test account1';
			acc1.FiscalCode__c='SXSRLA45H2';
			acc1.BillingIsAddressVerified__c=true;
        	acc1.IsWrongFiscalData__c = false;
        	acc1.BillingIsAddressVerified__c = true;
			acc1.CustomerCode__c = '00000001';

        HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'Reseller', 'AAS Azienda', 'Famiglie');
        
        Account acc=new Account(
            Name='acc0',CompanyOwner__c='Reseller',
            Category__c = 'Famiglie',CustomerMarking__c='AAS Azienda',
            ShippingStreetName__c='test',BillingStreetName__c='test'
        );//,Category__c='Accedi'
        insert acc;
        insert new Sale__c(Name='sales0',Account__c=acc.Id);
    }

    @IsTest
    static void isTransitionNoUpTest(){
        Sale__c sale=[SELECT Account__r.CompanyOwner__c,Account__r.Category__c FROM Sale__c WHERE Name='sale0' LIMIT 1];
        Test.startTest();
        HDT_UTL_Sales.isTransitionNoUp(new ServicePoint__c(SupplyProvince__c='PE'),sale);
        Test.stopTest();
    }
}
