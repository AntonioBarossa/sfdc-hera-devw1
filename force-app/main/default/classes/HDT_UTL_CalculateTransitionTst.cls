@IsTest
public with sharing class HDT_UTL_CalculateTransitionTst {

    @TestSetup
    static void setup()
    {
        List<Account> accList=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'D1 - Persona fisica', 'Enti');
		List<Sale__c> saleList=HDT_UTL_DataFactoryTst.createSale(1, true, accList[0].Id, 'Attiva');
        List<ServicePoint__c> spList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        spList[0].SupplyCity__c = 'Pesaro';
        spList[0].CommoditySector__c = 'Gas';
        spList[0].IsReseller__c = true;
        update spList;
        List<City__c> cities = new List<City__c>();
        City__c c = new City__c(SDV__C = 'HCM', Province__c = 'PU', Name = spList[0].SupplyCity__c, IsNotTransition__c = true);
        City__c city = new City__c(SDV__C = 'HCM', Province__c = 'RM', Name = 'Acerra', IsNotTransition__c = false);
        cities.add(c);
        cities.add(city);
        insert cities;
    }

    @istest
    static void calculateTransitionTest1(){

        String city = 'Pesaro';
        String commodity = 'Gas';
        Boolean result = false;
        HDT_UTL_CalculateTransition calculateTransition = new HDT_UTL_CalculateTransition(city, commodity); 
        result = calculateTransition.calculateTransition();
        
        System.assertEquals(true, result,'Transizione non calcolata');
    }

    @istest
    static void calculateTransitionTest2(){

        List<ServicePoint__c> servicePoints = [SELECT Id, SupplyCity__c, CommoditySector__c, IsReseller__c 
                                               FROM ServicePoint__c 
                                               WHERE SupplyCity__c = 'Pesaro'
                                               AND CommoditySector__c = 'Gas'
                                               AND IsReseller__c = true WITH SECURITY_ENFORCED];
        
        List<Sale__c> sales = [SELECT Id FROM Sale__c];
        Boolean result = false;
        if(!servicePoints.isEmpty() && !sales.isEmpty()){
            HDT_UTL_CalculateTransition calculateTransition = new HDT_UTL_CalculateTransition(servicePoints[0], sales[0]); 
            result = calculateTransition.calculateTransition();
            
            System.assertEquals(true, result,'Transizione non calcolata');
        }

    }

    @istest
    static void calculateTransitionTest3(){

        String city = 'Pesaro';
        List<Sale__c> sales = [SELECT Id FROM Sale__c];
        Boolean result = false;
        HDT_UTL_CalculateTransition calculateTransition = new HDT_UTL_CalculateTransition(city, sales[0]); 
        result = calculateTransition.calculateTransition();
        
        System.assertEquals(true, result,'Transizione non calcolata');

    }

    @istest
    static void calculateTransitionTest4(){

        String city = 'Acerra';
        String commodity = 'Gas';
        String distributorCode = 'ALTRO';
        Boolean result = false;
        HDT_UTL_CalculateTransition calculateTransition = new HDT_UTL_CalculateTransition(city, commodity, distributorCode); 
        result = calculateTransition.calculateTransition();
        
        System.assertEquals(true, result,'Transizione non calcolata');
    }
    @IsTest
    static void calculateCompanyInfosTst()
    {
        String city = 'Pesaro';
        String commodity = 'Gas';
        String distributorCode = 'ALTRO';
        HDT_UTL_CalculateTransition calculateTransition = new HDT_UTL_CalculateTransition(city, commodity, distributorCode);
        Test.startTest();
            Map<String,Object> result = calculateTransition.calculateCompanyInfos();
        Test.stopTest();
        System.assertEquals(true, !result.isEmpty(), 'Compnay Info Calcolati');
    }
}
