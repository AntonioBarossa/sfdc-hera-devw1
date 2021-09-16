@isTest
public with sharing class HDT_BA_CustomerLifeCycleTst {
    @TestSetup
    static void makeData(){
        List<Account> accounts = HDT_UTL_DataFactoryTst.createAccountResidenziale(2, false, 'HERA COMM', 'Persona Fisica', 'Famiglie');
        accounts[1].CustomerLifeCycleWaste__c = 'ONBOARDING';
        insert accounts;

        List<ServicePoint__c> points = HDT_UTL_DataFactoryTst.createServicePoint(3, false);
        points[0].CommoditySector__c = 'Gas';
        points[1].CommoditySector__c = 'Ambiente';
        points[2].CommoditySector__c = 'Acqua';
        insert points;

        List<Contract> contracts = HDT_UTL_DataFactoryTst.createContract(3, false, accounts[0].Id);
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
        insert contracts;

        Case caso = HDT_UTL_DataFactoryTst.createCase(1, false, accounts[0].Id, null, null, contracts[0].Id, null)[0];
        insert caso;
    }

    @isTest
    private static void executeBatch() {
        Test.startTest();
        Database.executeBatch(new HDT_BA_CustomerLifeCycle());
        Test.stopTest();
    }
}