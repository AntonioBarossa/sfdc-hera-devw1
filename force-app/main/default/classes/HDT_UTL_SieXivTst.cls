@isTest
public with sharing class HDT_UTL_SieXivTst {
    
    static void createOrder(Contract c){
        Order o = HDT_UTL_DataFactoryTst.createOrder(1, false, c.AccountId, 'Bozza')[0];
        o.SalesCompany__c=c.contractSalesCompany__c;
        insert o;
        c.SBQQ__Order__c=o.Id;
        insert c;
    }
    static void createOrderAndSale(Contract c){
            Order o = HDT_UTL_DataFactoryTst.createOrder(1, false, c.AccountId, 'Bozza')[0];
            o.SalesCompany__c=c.contractSalesCompany__c;
            Sale__c s =HDT_UTL_DataFactoryTst.createSale(1, false, c.AccountId, 'Bozza')[0];
            s.CommercialId__c='AGSMECON1234';
            insert s;
            o.Sale__c=s.Id;
            insert o;
            c.SBQQ__Order__c=o.Id;
            insert c;
    }

    @TestSetup
    static void makeData(){
        List<Account> accounts= HDT_UTL_DataFactoryTst.createAccountResidenziale(4, true, 'HERA COMM', 'D1 - Persona fisica', 'Enti');
        List<Order> orderToInsert = new List<Order>();
        Account accountOne = accounts.get(0);
        createOrder(new Contract(AccountId=accountOne.Id, ContractSalesCompany__c='Hera Comm Marche'));
        createOrder(new Contract(AccountId=accountOne.Id, ContractSalesCompany__c='Hera Comm Marche'));
        createOrder(new Contract(AccountId=accountOne.Id, ContractSalesCompany__c='Hera Comm S.p.A.'));

        Account accountTwo = accounts.get(1);
        accountTwo.CategoryCode__c = 'Z006';
        update accountTwo;

        createOrderAndSale(new Contract(AccountId=accountTwo.Id, ContractSalesCompany__c='Hera Comm S.p.A.'));
        createOrderAndSale(new Contract(AccountId=accountTwo.Id, ContractSalesCompany__c='Hera Comm S.p.A.'));
        createOrderAndSale(new Contract(AccountId=accountTwo.Id, ContractSalesCompany__c='EstEnergy S.p.A.'));
        
        Account accountThree = accounts.get(2);
        createOrder(new Contract(AccountId=accountThree.Id, ContractSalesCompany__c='Acegas Aps Service'));
        createOrder(new Contract(AccountId=accountThree.Id, ContractSalesCompany__c='Acegas Aps Service'));
        createOrder(new Contract(AccountId=accountThree.Id, ContractSalesCompany__c='Hera Comm Marche'));


    }

    @isTest
    static void testSieXivWithSale() {
        
        List<Contract> contracts =  [SELECT Id, AccountId, SBQQ__Order__c, SBQQ__Order__r.CommercialId__c FROM Contract where ContractSalesCompany__c='EstEnergy S.p.A.'];
        update new Account(Id=contracts[0].AccountId, CategoryCode__c='');
        Test.startTest();
        HDT_SRV_SieXiv testSieXiv = new HDT_SRV_SieXiv();
        testSieXiv.initSIE(new Map<Id,Contract>(contracts).keySet());
        Test.stopTest();
        String result = [Select Segment__c from account where id=:contracts[0].AccountId].Segment__c;
        system.assertEquals('Corporate_GDA', result, 'Unexpected Behaviour');
    }


    @isTest
    static void testSieXiv() {
        
        List<Contract> contracts =  [SELECT Id, AccountId FROM Contract]; 
        //system.debug('allContracts -> ' + contracts);
        Test.startTest();
        HDT_SRV_SieXiv testSieXiv = new HDT_SRV_SieXiv();
        testSieXiv.initSIE(new Map<Id,Contract>(contracts).keySet());
        Test.stopTest();
        Integer accountsToCode = [Select Count() from Account Where Segment__c='ZCOD-DA CODIFICARE'];
        system.assertEquals(2, accountsToCode, 'Unexpected Behaviour');
    }

    @isTest
    static void testSieXivcheckBpcaChanges() {
        Test.startTest();
        wrts_prcgvr.InstallIntegration.install();
        HDT_UTL_DataFactoryTst.installPhaseManagerSObjectSetting('Case');
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
        update new Account(id=AccountId, CategoryCode__c='Z006');

        Contract c = new Contract(AccountId=accountId, ContractSalesCompany__c='Hera Comm Marche');
        insert c;
        ServicePoint__c servicePoints = HDT_UTL_DataFactoryTst.createServicePoint(1,true)[0];
        Contact testContact = HDT_UTL_DataFactoryTst.createContact(1, true, accountId)[0];
        
        Case testCase = HDT_UTL_DataFactoryTst.createCase(1, false, accountId, testContact.Id, servicePoints.Id, c.Id, c.Id)[0];
        testCase.Type='BP/CA - errata categoria';
        testCase.Phase__c='Completata';
        insert testCase;

        Map<Id, Sobject> newMap = new Map<Id, Sobject>{testCase.Id => testCase};
        Map<Id, Sobject> oldMap = new Map<Id, Sobject>{testCase.Id => new Case(Id=testCase.Id, Phase__c='Test')};

        
        HDT_UTL_CaseProcess.caseBpcaSieManagement(newMap, oldMap);
        Test.stopTest();
        String result = [Select Segment__c from account where id=:accountId].Segment__c;
        system.assertEquals('CORPORATE_IC', result.toUpperCase(), 'Unexpected Behaviour');
    }
    
}