/**
* Header of the class "HDT_LC_ChildOrderProcessPrecheckTst"
* @author: Luca Belometti 
* @version 1.0
* @description: ApexTest Class of the relative Class "HDT_LC_ChildOrderProcessPrecheck"
* @history
* Created: 2021-08-18
* Modified By:
**/

@IsTest
public with sharing class HDT_LC_ChildOrderProcessPrecheckTst {
    @TestSetup
    static void makeData(){
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<BillingProfile__c> bpList = HDT_UTL_DataFactoryTst.createBillingProfile(1, true, accList[0].Id);

        List<ServicePoint__c> spList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Sale__c> saleList = HDT_UTL_DataFactoryTst.createSale(1, true, accList[0].Id, 'Bozza');
        List<Opportunity> oppList = HDT_UTL_DataFactoryTst.createOpportunity(1, true);
        
        List<Product2> productList = HDT_UTL_DataFactoryTst.createProduct2(1, false);
        productList[0].Name = 'POD';
        productList[0].Family = 'VAS Fatturabili';
        insert productList;

        List<Order> orderList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].Id, 'Bozza');
        
        List<SBQQ__Quote__c> quoteList = HDT_UTL_DataFactoryTst.createQuote(1, false, orderList[0].Id, oppList[0].Id, saleList[0].Id, 'Quote');
        quoteList[0].OrderReference__c = null;
        insert quoteList;
        
        List<SBQQ__QuoteLine__c> qlList = HDT_UTL_DataFactoryTst.createQuoteLines(productList[0].Id, quoteList[0].Id, 2, true);
        qlList[0].PaymentMode__c = 'RID';
        qlList[0].SendingBillMode__c = 'Bolletta per e-mail';
        qlList[0].BillingProfile__c = bpList[0].Id;
        qlList[1].PaymentMode__c = 'Bollettino postale';
        qlList[1].SendingBillMode__c = 'Cartaceo';
        qlList[1].BillingProfile__c = bpList[0].Id;
        qlList[0].SBQQ__RequiredBy__c = qlList[1].Id;
        update qlList;

    }

    
	@isTest
	static void testInit(){
        List<Order> listaOrder = [SELECT Id,ServicePoint__c FROM Order LIMIT 1];
        HDT_LC_ChildOrderProcessPrecheck.init(listaOrder[0]);
	}

     
	@isTest
	static void testNext(){
        List<Order> listaOrder = [SELECT Id,ServicePoint__c FROM Order LIMIT 1];
        List<ServicePoint__c> listaServicePoint = [SELECT Id FROM ServicePoint__c LIMIT 1];

        ServiceRequest__c srvReq = new ServiceRequest__c();
        srvReq.ServicePointCode__c = 'Test1234';
        srvReq.Status__c = 'Bozza';
        srvReq.Order__c = listaOrder[0].Id;
        srvReq.CommoditySector__c = 'Energia Elettrica';
        srvReq.Type__c = 'Order';
        srvReq.ServicePoint__c = listaServicePoint[0].Id;
        srvReq.ProcessType__c = 'Alert';

        Map<String,String> mappaStringa = new Map<String,String>();
        mappaStringa.put('recordType', '123456');

        HDT_LC_ChildOrderProcessPrecheck.next(listaOrder[0], listaOrder[0].Id, mappaStringa, 'In Delibera', mappaStringa, srvReq);
        
	}

    
}
