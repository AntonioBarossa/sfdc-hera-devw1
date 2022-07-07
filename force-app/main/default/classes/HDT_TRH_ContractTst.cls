/**
* Header of the class "HDT_TRH_ContractTst"
* @author Cesare Bagnolini, cesare.bagnolini@webresults.it
* @version 1.0
* @description: Apex Test Class of the relative Apex Class "HDT_TRH_Contract"
* @history
* @Created 12/10/2021
* Modified By:
**/
@isTest
public with sharing class HDT_TRH_ContractTst{
    
        private static HDT_UTL_Constants utlConstants = new HDT_UTL_Constants();
    
    @isTest
    public static void testUpdate(){
        
        Test.startTest();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        
        
        List<BillingProfile__c> bpList = HDT_UTL_DataFactoryTst.createBillingProfile(1, true, accs[0].Id);
        List<ServicePoint__c> spList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Opportunity> opps=HDT_UTL_DataFactoryTst.createOpportunity(1, true);
        List<Sale__c> sales=HDT_UTL_DataFactoryTst.createSale(1, true, accs[0].Id, 'Attiva');
        Id pricebookId=Test.getStandardPricebookId();
        List<Contract> contract =  HDT_UTL_DataFactoryTst.createContract(1, true, accs[0].Id);
        List<Order> orders=HDT_UTL_DataFactoryTst.createOrder(1, false, accs[0].id, 'Bozza');            
        
        
        
        orders[0].BillingProfile__c = bpList[0].Id;
        orders[0].ServicePoint__c = spList[0].Id;
        orders[0].Market__c ='Libero'; 
        orders[0].VAT__c = 'Iva 22% (Cod. 02)';
        orders[0].EffectiveDate__c = Date.today()-5;
        orders[0].SapContractCode__c = '3001002003';
        orders[0].CommercialProduct__c = 'test';
        orders[0].recordTypeId = utlConstants.ORDER_RECORDTYPEID_VOLTURA;
        orders[0].ProcessType__c = 'Voltura';
        
        
        
        insert orders;
        
        List<SBQQ__Quote__c> quotes = HDT_UTL_DataFactoryTst.createQuote(1, false, orders[0].id, null, null, 'Quote');
        quotes[0].AllowChangeUse__c = false;
        quotes[0].AmendmentAllowed__c = false;
        quotes[0].SBQQ__PriceBook__c = pricebookId;
        insert quotes;
        
        orders[0].SBQQ__Quote__c = quotes[0].Id;
        update orders;
        
        System.debug('££££'+ orders[0].Id + '  ££££' + orders[0].SBQQ__Quote__c);
        
        
        Contract contr = [Select Id from contract limit 1];
        
        contr.SBQQ__Order__c = orders[0].id;
        
        update contr;
        
        
        
        Test.stopTest();
        
        List<Contract> query = [Select id,SBQQ__Order__c from contract];
        
        System.assertEquals(1, query.size(), 'Contract not inserted correctly');
        System.assertNotEquals(null, query[0].SBQQ__Order__c, 'Contract not updated correctly');
        
    }
    
    @isTest
    public static void beforeAfterInsertTestEnergiaElettrica(){
        
        List<Account> accounts = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        ServicePoint__c servPoint = HDT_UTL_DataFactoryTst.createServicePoint(1, false)[0];
        servPoint.CommoditySector__c = 'Energia Elettrica';
        insert servPoint;
        
        Test.startTest();
        Contract con = HDT_UTL_DataFactoryTst.createContract(1, false, accounts[0].Id)[0];
        con.ServicePoint__c = servPoint.Id;
        insert con;
        
        Test.stopTest();
        
        Contract testContract = [SELECT Id, SAPContractCode__c FROM Contract WHERE SAPContractCode__c = '3011913470' LIMIT 1];
        Account testAccount = [SELECT Id, ActiveServicesEle__c FROM Account];
        
        System.assertEquals('3011913470', testContract.SAPContractCode__c, 'Contract not Inserted');
        System.assertNotEquals('', testContract.SAPContractCode__c, 'Contract not Inserted');
        System.assertEquals(1, testAccount.ActiveServicesEle__c, 'Active Services Ele errato.');
    }
    
    
    @isTest
    public static void beforeAfterInsertTestGas(){
        
        List<Account> accounts = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        ServicePoint__c servPoint = HDT_UTL_DataFactoryTst.createServicePoint(1, false)[0];
        servPoint.CommoditySector__c = 'Gas';
        insert servPoint;
        
        Test.startTest();
        Contract con = HDT_UTL_DataFactoryTst.createContract(1, false, accounts[0].Id)[0];
        con.ServicePoint__c = servPoint.Id;
        insert con;
        
        Test.stopTest();
        
        Contract testContract = [SELECT Id, SAPContractCode__c FROM Contract WHERE SAPContractCode__c = '3011913470' LIMIT 1];
        Account testAccount = [SELECT Id, ActiveServicesGas__c FROM Account];
        
        System.assertEquals('3011913470', testContract.SAPContractCode__c, 'Contract not Inserted');
        System.assertNotEquals('', testContract.SAPContractCode__c, 'Contract not Inserted');
        System.assertEquals(1, testAccount.ActiveServicesGas__c, 'Active Services Gas errato.');
    }
    
    
    
    @isTest
    public static void beforeAfterInsertTestTlr(){
        
        List<Account> accounts = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        ServicePoint__c servPoint = HDT_UTL_DataFactoryTst.createServicePoint(1, false)[0];
        servPoint.CommoditySector__c = 'Teleriscaldamento';
        insert servPoint;
        
        Test.startTest();
        Contract con = HDT_UTL_DataFactoryTst.createContract(1, false, accounts[0].Id)[0];
        con.ServicePoint__c = servPoint.Id;
        insert con;
        
        Test.stopTest();
        
        Contract testContract = [SELECT Id, SAPContractCode__c FROM Contract WHERE SAPContractCode__c = '3011913470' LIMIT 1];
        Account testAccount = [SELECT Id, ActiveServicesTLR__c FROM Account];
        
        System.assertEquals('3011913470', testContract.SAPContractCode__c, 'Contract not Inserted');
        System.assertNotEquals('', testContract.SAPContractCode__c, 'Contract not Inserted');
        System.assertEquals(1, testAccount.ActiveServicesTLR__c, 'Active Services TLR errato.');
    }
    
    
    @isTest
    public static void beforeAfterInsertTestWater(){
        
        List<Account> accounts = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        ServicePoint__c servPoint = HDT_UTL_DataFactoryTst.createServicePoint(1, false)[0];
        servPoint.CommoditySector__c = 'Acqua';
        insert servPoint;
        
        Test.startTest();
        Contract con = HDT_UTL_DataFactoryTst.createContract(1, false, accounts[0].Id)[0];
        con.ServicePoint__c = servPoint.Id;
        insert con;
        
        Test.stopTest();
        
        Contract testContract = [SELECT Id, SAPContractCode__c FROM Contract WHERE SAPContractCode__c = '3011913470' LIMIT 1];
        Account testAccount = [SELECT Id, ActiveServicesWater__c FROM Account];
        
        System.assertEquals('3011913470', testContract.SAPContractCode__c, 'Contract not Inserted');
        System.assertNotEquals('', testContract.SAPContractCode__c, 'Contract not Inserted');
        System.assertEquals(1, testAccount.ActiveServicesWater__c, 'Active Services Water errato.');
    }
    
    
    @isTest
    public static void beforeAfterInsertTestWaste(){
        
        List<Account> accounts = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        ServicePoint__c servPoint = HDT_UTL_DataFactoryTst.createServicePoint(1, false)[0];
        servPoint.CommoditySector__c = 'Ambiente';
        insert servPoint;
        
        Test.startTest();
        Contract con = HDT_UTL_DataFactoryTst.createContract(1, false, accounts[0].Id)[0];
        con.ServicePoint__c = servPoint.Id;
        insert con;
        
        Test.stopTest();
        
        Contract testContract = [SELECT Id, SAPContractCode__c FROM Contract WHERE SAPContractCode__c = '3011913470' LIMIT 1];
        Account testAccount = [SELECT Id, ActiveServicesWaste__c FROM Account];
        
        System.assertEquals('3011913470', testContract.SAPContractCode__c, 'Contract not Inserted');
        System.assertNotEquals('', testContract.SAPContractCode__c, 'Contract not Inserted');
        System.assertEquals(1, testAccount.ActiveServicesWaste__c, 'Active Services Waste errato.');
    }
    
    
    
    @isTest
    public static void testTriggerContractBeforeAfterUpdate(){
        
        Test.startTest();
        
        List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Contract> contracts=HDT_UTL_DataFactoryTst.createContract(1, true, accounts[0].Id);
        
        contracts[0].BillingCountry='IT';
        
        update contracts;
        
        
        Contract testContract=[SELECT Id, SAPContractCode__c, BillingCountry
                               FROM Contract
                               WHERE SAPContractCode__c='3011913470' and BillingCountry='IT'
                               LIMIT 1];
        
        System.assertEquals('IT', testContract.BillingCountry, 'Contract not Updated');
        System.assertNotEquals('', testContract.BillingCountry, 'Contract not Updated');
        Test.stopTest();    
    }
}