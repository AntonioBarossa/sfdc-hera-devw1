@isTest
public with sharing class HDT_BA_CustomerLifeCycleTst {
    @TestSetup
    static void makeData(){
        List<Account> accounts = HDT_UTL_DataFactoryTst.createAccountResidenziale(2, false, 'HERA COMM', 'D1 - Persona fisica', 'Famiglie');
        accounts[1].CustomerLifeCycleWaste__c = 'ONBOARDING';
        insert accounts;

        List<ServicePoint__c> points = HDT_UTL_DataFactoryTst.createServicePoint(5, false);
        points[0].CommoditySector__c = 'Gas';
        points[1].CommoditySector__c = 'Ambiente';
        points[2].CommoditySector__c = 'Acqua';
        points[3].CommoditySector__c = 'Teleriscaldamento';
        points[4].CommoditySector__c = 'Energia Elettrica';
        insert points;

        List<Contract> contracts = HDT_UTL_DataFactoryTst.createContract(6, false, accounts[0].Id);
        contracts[0].ServicePoint__c = points[0].Id;
        contracts[0].CustomerSignedDate = Date.today().addDays(-1);
        contracts[0].StartDate = Date.today().addDays(-1);
        contracts[0].EndDate = Date.today().addDays(1);
        contracts[1].ServicePoint__c = points[1].Id;
        contracts[1].CustomerSignedDate = Date.today().addDays(-2);
        contracts[1].StartDate = Date.today().addDays(2);
        contracts[1].EndDate = Date.today().addDays(4);
        contracts[1].AccountId = accounts[1].Id;
        contracts[2].ServicePoint__c = points[2].Id;
        contracts[2].CustomerSignedDate = Date.today().addDays(-2);
        contracts[2].StartDate = Date.today().addDays(2);
        contracts[2].EndDate = Date.today().addDays(4);

        contracts[3].ServicePoint__c = points[3].Id;
        contracts[3].CustomerSignedDate = Date.today();
        contracts[3].StartDate = Date.today();
        contracts[3].EndDate = Date.today().addDays(-1);
        contracts[4].ServicePoint__c = points[3].Id;
        contracts[4].CustomerSignedDate = Date.today().addDays(-61);
        contracts[4].StartDate = Date.today().addDays(-61);
        contracts[4].EndDate = Date.today().addDays(4);
        contracts[5].ServicePoint__c = points[4].Id;
        contracts[5].CustomerSignedDate = Date.today().addDays(-400);
        contracts[5].StartDate = Date.today().addDays(-400);
        contracts[5].EndDate = Date.today().addDays(4);
        insert contracts;

        Case caso = HDT_UTL_DataFactoryTst.createCase(1, false, accounts[0].Id, null, null, contracts[0].Id, null)[0];
        insert caso;
    }

    @isTest
    private static void executeBatch() {
        Test.startTest();
        Database.executeBatch(new HDT_BA_CustomerLifeCycle());
        Test.stopTest();
        List<Account> accounts = [SELECT Id, CustomerLifeCycleGas__c, CustomerLifeCycleWaste__c, CustomerLifeCycleWater__c, CustomerLifeCycleEnergy__c, CustomerLifeCycleNonEnergy__c FROM Account ORDER BY Name ASC];
        System.assertEquals('WELCOME', accounts[0].CustomerLifeCycleGas__c,'This is the value provided on the field');
        System.assertEquals('ONBOARDING', accounts[1].CustomerLifeCycleWaste__c,'This is the value provided on the field');
        System.assertEquals('ONBOARDING', accounts[0].CustomerLifeCycleWater__c,'This is the value provided on the field');
        System.assertEquals('ENGAGEMENT', accounts[0].CustomerLifeCycleEnergy__c,'This is the value provided on the field');
        // System.assertEquals('LOST', accounts[0].CustomerLifeCycleNonEnergy__c);
        System.assertEquals(null, accounts[1].CustomerLifeCycleEnergy__c,'This field is not provided');
        System.assertEquals(null, accounts[1].CustomerLifeCycleNonEnergy__c,'This field is not provided');  // FIELD NOT POPULATED IN MAKE DATA - SHOULD NOT BE UPDATED BY BATCH
    }
}