/**
* @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
* @date 12/08/2021
* @description Test Class for HDT_LC_QuoteAmentContract Test Class
* @history Lucas da Silva Fernandes – 12/08/2021 – Created class
*/

@isTest
public with sharing class HDT_LC_QuoteAmendContractTst {
    
    @TestSetup
    static void setup(){

        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');

        List<BillingProfile__c> billProfList = HDT_UTL_DataFactoryTst.createBillingProfile(1, true, accList[0].Id);

        List<ServicePoint__c> spList = HDT_UTL_DataFactoryTst.createServicePoint(1, false);
        spList[0].Name = 'servicePoint test';
        insert spList;

        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, false, accList[0].Id);
        contractList[0].Name = 'test Contract';
        contractList[0].Status = 'Attivo';
        insert contractList;

        List<Sale__c> saleList = HDT_UTL_DataFactoryTst.createSale(1, true, accList[0].Id, 'Bozza');

        List<Order> orderList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].Id, 'Bozza');

        List<Opportunity> oppList = HDT_UTL_DataFactoryTst.createOpportunity(1, true);
        
        List<SBQQ__Quote__c> quoteList = HDT_UTL_DataFactoryTst.createQuote(1, false, orderList[0].Id, oppList[0].Id, saleList[0].Id, 'Quote');
        quoteList[0].SBQQ__Status__c = 'Accepted';
        quoteList[0].ContractReference__c = contractList[0].Id;
        quoteList[0].SBQQ__Opportunity2__c = oppList[0].Id;
        insert quoteList;

        List<Product2> prodList = HDT_UTL_DataFactoryTst.createProduct2(1, false);
        prodList[0].Name = 'POD';
        insert prodList;

        HDT_UTL_DataFactoryTst.createSaleServiceItem(1, true, oppList[0].Id, quoteList[0].Id, spList[0].Id);

        List<SBQQ__QuoteLine__c> quoteLineList = HDT_UTL_DataFactoryTst.createQuoteLines(prodList[0].Id, quoteList[0].Id, 1, false);
        quoteLineList[0].BillingProfile__c = billProfList[0].Id;
        quoteLineList[0].PaymentMode__c = 'RID';
        quoteLineList[0].ServicePoint__c = spList[0].Id;
        insert quoteLineList;

    }

    @isTest
    public static void tesExecModalExitActions() {

        Test.startTest();

        Contract ct = [SELECT Id FROM Contract WHERE Name = 'test Contract' LIMIT 1];

        Sale__c sale = [SELECT Id FROM Sale__c WHERE Name = 'testSaleName0' LIMIT 1];

        ServicePoint__c sp = [SELECT Id FROM ServicePoint__c WHERE Name = 'servicePoint test'];

        SBQQ__QuoteLine__c sbqqQuote = [SELECT Id, ServicePoint__c FROM SBQQ__QuoteLine__c WHERE PaymentMode__c = 'RID' LIMIT 1];

        HDT_LC_QuoteAmendContract.execModalExitActions(ct.Id, sale.Id, sbqqQuote.Id);

        sbqqQuote = [SELECT Id, ServicePoint__c FROM SBQQ__QuoteLine__c WHERE PaymentMode__c = 'RID' LIMIT 1];
        sbqqQuote.ServicePoint__c = null;
        update sbqqQuote;

        HDT_LC_QuoteAmendContract.execModalExitActions(ct.Id, sale.Id, sbqqQuote.Id);

        System.assertEquals(null, sbqqQuote.ServicePoint__c, 'QuoteLine successfully updated');
        System.assertNotEquals(sp.Id, sbqqQuote.ServicePoint__c, 'QuoteLine update failed');

        Test.stopTest();
    }
}
