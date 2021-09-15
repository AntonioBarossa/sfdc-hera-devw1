/**
 * @author Valere (valere@noeli-it.net)
 * @date 13/09/2021
 * @description HDT_UTL_Sales Test Class
 * @history valere - 13/09/2021– Created Class
 */
@IsTest
public class HDT_UTL_SalesTst {
    @TestSetup
    static void makeData(){
        City__c city=HDT_UTL_DataFactoryTst.createCity(1, true,true,'svd0')[0];

        Account acc0=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true,new Map<String,String>{
            'companyOwner'=>'AAA-EBT',
            'customerMarking'=>'AAS Azienda',
            'customerCode'=>'0000000',
            'numCustomerCode'=>'400065',
            'vatNumber'=>'123400',
            'nameStart'=>'acc',
            'code'=>'00',
            'category'=>'Enti'
        })[0];
        
        
        Account acc1=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true,new Map<String,String>{
            'companyOwner'=>'AAA-EBT',
            'customerMarking'=>'AAS Azienda',
            'customerCode'=>'00000001',
            'numCustomerCode'=>'4565465',
            'vatNumber'=>'123456',
            'nameStart'=>'acc0',
            'category'=>'Aziende Soho'
        })[0];
        HDT_UTL_DataFactoryTst.createSale(1,true,acc0.Id,'Attiva');
        HDT_UTL_DataFactoryTst.createSale(1,true,acc1.Id,'Attiva');
        HDT_UTL_DataFactoryTst.createServicePoint(1, true,city.Name,acc0.Id);
    }
    
    @IsTest
    static void isTransitionNoUpTest(){
        Sale__c sale0=[SELECT Account__r.CompanyOwner__c,Account__r.Category__c FROM Sale__c WHERE  Account__r.code__c!=null LIMIT 1];
        Sale__c sale1=[SELECT Account__r.CompanyOwner__c,Account__r.Category__c FROM Sale__c WHERE  Account__r.code__c=null LIMIT 1];
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
        System.assert(HDT_UTL_Sales.getAgentNameAndCode(sp,'').get('nomeAgente')=='');//because there are no custom metadatas
        System.assert(HDT_UTL_Sales.getAgentNameAndCode(sp,'').get('codiceAgente')=='');//because there are no custom metadatas
        Test.stopTest();
    }
}