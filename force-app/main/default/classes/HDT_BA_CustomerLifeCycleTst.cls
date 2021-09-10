@isTest
public with sharing class HDT_BA_CustomerLifeCycleTst {
    @TestSetup
    static void makeData(){
        List<Account> accounts = HDT_UTL_DataFactoryTst.createAccountResidenziale(2, true, 'HERA COMM', 'Persona Fisica', 'Famiglie');

        List<ServicePoint__c> points = HDT_UTL_DataFactoryTst.createServicePoint(1, false);
        point[0].CommoditySector__c = 'Gas';
        point[1].CommoditySector__c = 'Acqua';
        insert points;

        List<Contract> contracts = HDT_UTL_DataFactoryTst.createContract(1, false, account.Id);
        contract[0].ServicePoint__c = points[0].Id;
        contract[0].CustomerSignedDate = Date.today().addDays(-1);
        contract[0].EndDate = Date.today().addDays(1);
        contract[1].ServicePoint__c = points[1].Id;
        contract[1].CustomerSignedDate = Date.today().addDays(-2);
        contract[1].EndDate = Date.today().addDays(2);
        insert contracts;

        Case caso = HDT_UTL_DataFactoryTst.createCase(1, false, account.Id, null, null, contract.Id, null)[0];
        insert caso;
    }

    @isTest
    private static void executeBatch() {
        Test.startTest();
        Database.executeBatch(new HDT_BA_CustomerLifeCycle());
        Test.stopTest();
    }
}