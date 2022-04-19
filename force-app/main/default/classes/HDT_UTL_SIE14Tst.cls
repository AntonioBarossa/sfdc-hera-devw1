
@isTest
public with sharing class HDT_UTL_SIE14Tst {
    
    @TestSetup
    static void makeData(){
        List<Account> accounts= HDT_UTL_DataFactoryTst.createAccountResidenziale(3, true, 'HERA COMM', 'D1 - Persona fisica', 'Enti');
        Account acc1 = accounts.get(0);
        Contract testContract1=new Contract(AccountId=acc1.Id, ContractSalesCompany__c='Hera Comm Marche');
        insert testContract1;
        Contract testContract2=new Contract(AccountId=acc1.Id, ContractSalesCompany__c='Hera Comm Marche');
        insert testContract2;
        Contract testContract3=new Contract(AccountId=acc1.Id, ContractSalesCompany__c='Hera Comm S.p.A.');
        insert testContract3; 

        Account acc2 = accounts.get(1);
        Contract testContract4=new Contract(AccountId=acc2.Id, ContractSalesCompany__c='Hera Comm S.p.A.');
        insert testContract4;
        Contract testContract5=new Contract(AccountId=acc2.Id, ContractSalesCompany__c='Hera Comm S.p.A.');
        insert testContract5;
        Contract testContract6=new Contract(AccountId=acc2.Id, ContractSalesCompany__c='Hera Comm Marche');
        insert testContract6;

        Account acc3 = accounts.get(2);
        Contract testContract7=new Contract(AccountId=acc3.Id, ContractSalesCompany__c='Acegas Aps Service');
        insert testContract7;
        Contract testContract8=new Contract(AccountId=acc3.Id, ContractSalesCompany__c='Acegas Aps Service');
        insert testContract8;
        Contract testContract9=new Contract(AccountId=acc3.Id, ContractSalesCompany__c='Hera Comm Marche');
        insert testContract9;
    }

    @isTest
    static void testSie14() {
        
        List<Contract> contracts =  [SELECT Id, AccountId FROM Contract];
        system.debug('allContracts -> ' + contracts);

        Test.startTest();
        HDT_UTL_SIE14 testSie14 = new HDT_UTL_SIE14();
        testSie14.initSIE(new Set<Contract>(contracts));
         
        Test.stopTest();
    }
    
}