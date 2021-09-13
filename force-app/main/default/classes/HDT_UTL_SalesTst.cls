/**
 * @author Valere (valere@noeli-it.net)
 * @date 10/09/2021
 * @description HDT_QR_RateCategory Test Classes
 * @history valere - 10/09/2021– Created Class
 */
@IsTest
public class HDT_UTL_SalesTst {
    @TestSetup
    static void makeData(){

        
        insert new City__c(Name='city0',SDV__c='svd0',ServiceEle__c=true);

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
		acc0.code__c = '00';
        
        Account acc1=new Account();
		acc1.Name='test account1';
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
        insert acc0;
        insert acc1;
        insert new Sale__c(Name='sale0',Account__c=acc0.Id);
        insert new Sale__c(Name='sale1',Account__c=acc1.Id);

        insert new ServicePoint__c(SupplyProvince__c='AQ',GlobalMigrationKey__c='1123255',SupplyCity__c='city0',CommoditySector__c='Energia Elettrica',Distributor__c=acc0.Id);
    }

    @IsTest
    static void isTransitionNoUpTest(){
        Sale__c sale0=[SELECT Account__r.CompanyOwner__c,Account__r.Category__c FROM Sale__c WHERE Name='sale0' LIMIT 1];
        Sale__c sale1=[SELECT Account__r.CompanyOwner__c,Account__r.Category__c FROM Sale__c WHERE Name='sale1' LIMIT 1];
        Test.startTest();
        System.assert(HDT_UTL_Sales.isTransitionNoUp(new ServicePoint__c(SupplyProvince__c='PEP'),sale0));
        System.assert(!HDT_UTL_Sales.isTransitionNoUp(new ServicePoint__c(SupplyProvince__c='AQ'),sale1));
        System.assert(HDT_UTL_Sales.isTransitionNoUp(sale0));
        System.assert(!HDT_UTL_Sales.isTransitionNoUp(sale1));
        System.assert(HDT_UTL_Sales.isTransition(new ServicePoint__c(SupplyProvince__c='PEP'),sale0));
        System.assert(!HDT_UTL_Sales.isTransition(new ServicePoint__c(SupplyProvince__c='AQ'),sale1));
        
        Test.stopTest();
    }

    @IsTest
    static void isWinbackTest(){
        ServicePoint__c sp=[SELECT Id FROM ServicePoint__c WHERE GlobalMigrationKey__c='1123255' LIMIT 1];
        Test.startTest();
        System.assert(!HDT_UTL_Sales.isWinback(sp.Id));
        Test.stopTest();
    }

    @IsTest
    static void getAgentNameAndCodeListTest(){
        List<ServicePoint__c> serviceList=[SELECT Id,SupplyCity__c,CommoditySector__c,Distributor__r.code__c FROM ServicePoint__c WHERE GlobalMigrationKey__c='1123255'];
        Test.startTest();
        System.assert(HDT_UTL_Sales.getAgentNameAndCodeList(serviceList,'').get(serviceList[0].Id)=='');//because there are no custom metadatas
        Test.stopTest();
    }

    @IsTest
    static void getAgentNameAndCodeTest(){
        ServicePoint__c sp=[SELECT Id,SupplyCity__c,CommoditySector__c,Distributor__r.code__c FROM ServicePoint__c WHERE GlobalMigrationKey__c='1123255' LIMIT 1];
        Test.startTest();
        System.assert(HDT_UTL_Sales.getAgentNameAndCode(sp,'').size()==0);//because there are no custom metadatas
        Test.stopTest();
    }
}