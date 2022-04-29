/**
 * @author Fabio Palladino, fabio.palladino@nttdata.com
 * @version 1.0
 * @description: classe di test per il servizio inbound HDT_WS_InboundSIE34
 * copertura anche del wrapper HDT_WRP_SIE108OrderEnrichment
 * @history
 * @Created 28/04/2022
 * Modified By:
 **/
@isTest
public with sharing class HDT_WS_InboundSIE34Tst {
    @TestSetup static void makedata(){
        
        HDT_UTL_DataFactoryTst.pClickInstance();
		HDT_UTL_DataFactoryTst.pClickOrderPhase();
        
        List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'HERA COMM','Azienda','Aziende SME');
        
        Id pricebookId = Test.getStandardPricebookId();
        
        List<Sale__c> sales = HDT_UTL_DataFactoryTst.createSale(1, true, accs[0].id, 'Bozza');
        
        List<ServicePoint__c> points = HDT_UTL_DataFactoryTst.createServicePoint(1, false);
        points[0].CommoditySector__c = 'Gas';
        insert points;
        
        List<Order> orders = HDT_UTL_DataFactoryTst.createOrderWithPricebook(1, false, accs[0].id, sales, pricebookId);
        orders[0].ServicePointCode__c = 'servicepointcode';
        orders[0].HerokuPracticeCode__c = 'herokucode';
        orders[0].SupplyType__c = 'Domestico';
        orders[0].ServicePoint__c = points[0].id;
        insert orders;
        
        List<Product2> prods = HDT_UTL_DataFactoryTst.createProduct2(1, false);
        prods[0].Family = 'Bonus Percentuale';
        prods[0].Name = 'Bonus Percentuale GAS Pippo';
        prods[0].Version__c = 'V1';
        insert prods;
        
        List<PricebookEntry> entries = HDT_UTL_DataFactoryTst.createPricebookEntry(prods, true, pricebookId);
        
        HDT_UTL_DataFactoryTst.createOrderItem(1, true, orders[0].id, points[0].id, prods[0].id, entries[0].id);
        
        List<Service26Config__c> configs = HDT_UTL_DataFactoryTst.createService26Config(2, false);
        configs[0].Type__c = 'Posizione';
        configs[0].ProductFamily__c = 'Bonus Percentuale';
        configs[0].SapCode__c = 'ZDV_GF_BON_P1';
        configs[0].Servizio__c = 'Gas';
        configs[0].Occurrence__c = 1;
        configs[0].Field__c = 'VersionDescr__c';
        configs[1].Field__c = 'Percentage__c';
        configs[1].SapCode__c = 'GF_BON_P1';
        configs[1].Type__c = 'Operando';
        configs[1].ProductFamily__c = 'Bonus Percentuale';
        configs[1].Servizio__c = 'Gas';
        configs[1].Occurrence__c = 1;
        insert configs;
        
        configs[0].Operando__c = configs[1].id;
        update configs;
    }
    
    @isTest static void getSIE34SingleOrderTst() {
        Id orderId = [Select id FROM Order][0].id;
        RestRequest req = new RestRequest();
        req.requestURI = 'services/apexrest/SIE34InboundServices/'+orderId;
		req.httpMethod = 'GET';
        RestContext.request = req;
        
        Test.startTest();
        List<HDT_WRP_SIE108OrderEnrichment> result = HDT_WS_InboundSIE34.getSIE34SingleOrder();
        Test.stopTest();

        System.assert(result.size() == 1 , 'result.size()!= 1');
    }
    
    @isTest static void doPostSIE34ListOrderTst() {
        Id orderId = [Select id FROM Order][0].id;
        List<String> orderList = new List<String>{orderId,'idfake'};

        Test.startTest();
        List<HDT_WRP_SIE108OrderEnrichment> result = HDT_WS_InboundSIE34.doPostSIE34ListOrder(orderList);
        Test.stopTest();

        System.assert(result.size() == 2 , 'result.size()!= 2');
    }
}