/**
 * Header of the class "HDT_UTL_ServiceTwentySixTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_UTL_ServiceTwentySix"
 * @history
 * @Created 02/11/2021
 * Modified By:
 **/
@isTest
public class HDT_UTL_ServiceTwentySixTst {
    
    private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
    
    @TestSetup static void makedata(){
        
        HDT_UTL_DataFactoryTst.pClickInstance();
		HDT_UTL_DataFactoryTst.pClickOrderPhase();
        
        List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'HERA COMM','Azienda','Aziende SME');
        
        Id pricebookId = Test.getStandardPricebookId();
        
        List<Sale__c> sales = HDT_UTL_DataFactoryTst.createSale(1, true, accs[0].id, 'Bozza');
        
        List<ServicePoint__c> points = HDT_UTL_DataFactoryTst.createServicePoint(1, false);
        points[0].CommoditySector__c = 'GAS';
        insert points;
        
        List<Order> orders = HDT_UTL_DataFactoryTst.createOrderWithPricebook(1, false, accs[0].id, sales, pricebookId);
        orders[0].ServicePointCode__c = 'servicepointcode';
        orders[0].HerokuPracticeCode__c = 'herokucode';
        orders[0].SupplyType__c = 'Domestico';
        orders[0].ServicePoint__c = points[0].id;
        insert orders;
        
        List<Product2> prods = HDT_UTL_DataFactoryTst.createProduct2(1, false);
        prods[0].Family = 'VAS Fatturabili';
        prods[0].Old__c  = 'N';
        insert prods;
        
        List<PricebookEntry> entries = HDT_UTL_DataFactoryTst.createPricebookEntry(prods, true, pricebookId);
        
        HDT_UTL_DataFactoryTst.createOrderItem(1, true, orders[0].id, points[0].id, prods[0].id, entries[0].id);
        
        List<Service26Config__c> configs = HDT_UTL_DataFactoryTst.createService26Config(2, false);
        configs[0].Type__c = 'Posizione';
        configs[0].ProductFamily__c = 'VAS Fatturabili';
        configs[0].Servizio__c = 'GAS';
        configs[0].Occurrence__c = 1;
        configs[0].Field__c = 'billable__c';
        configs[1].Field__c = 'billable__c';
        configs[1].SapCode__c = 'sapcode1';
        configs[1].Type__c = 'Operando';
        configs[1].ProductFamily__c = 'VAS Fatturabili';
        configs[1].Servizio__c = 'GAS';
        configs[1].Occurrence__c = 1;
        insert configs;
        
        configs[0].Operando__c = configs[1].id;
        update configs;
    }
    
    @isTest static void testStartProcess(){
        
        HDT_UTL_ServiceTwentySix.HDT_WRP_DtoServiceTwentySix res = new HDT_UTL_ServiceTwentySix.HDT_WRP_DtoServiceTwentySix();
        
        Id orderId = [Select id FROM Order][0].id;
        
        HDT_UTL_ServiceTwentySix service = new HDT_UTL_ServiceTwentySix();
        
        res = service.startProcess(orderId);
        
        System.assertEquals('herokucode', res.documentKey, 'HDT_UTL_ServiceTwentySix did not work correctly');
        System.assertNotEquals(null, res, 'HDT_UTL_ServiceTwentySix did not work correctly');
        
    }
    
    @isTest static void testGetFieldValueBlank(){
        
        HDT_UTL_ServiceTwentySix service = new HDT_UTL_ServiceTwentySix();
        
        String res = service.getFieldValue('', null, null);
        
        System.assertEquals('', res, 'getFieldValue did not work correctly');
        System.assertNotEquals(null, res, 'getFieldValue did not work correctly');                
    }
    
    @isTest static void testGetFieldValue(){
        
        HDT_UTL_ServiceTwentySix service = new HDT_UTL_ServiceTwentySix();
        
        String res = service.getFieldValue('CustomCheck.test', null, null);
        
        System.assertEquals('', res, 'getFieldValue did not work correctly');
        System.assertNotEquals(null, res, 'getFieldValue did not work correctly');
    }

    @isTest static void testAmendmentManaged(){
        Order o = [SELECT id,AccountId FROM Order];
        Sale__c sale  = HDT_UTL_DataFactoryTst.createSale(1, true, o.AccountId,'Attiva')[0];
        Contract contr = HDT_UTL_DataFactoryTst.createContract(1, true, o.AccountId)[0];
        Opportunity opp = HDT_UTL_DataFactoryTst.createOpportunity(1, true)[0];
        List<SBQQ__Quote__c> qList = HDT_UTL_DataFactoryTst.createQuote(2, false, o.Id, opp.Id, sale.Id, 'Amendment');
        qList[0].ContractReference__c = contr.Id;
        qList[1].ContractReference__c = contr.Id;
        qList[1].SBQQ__Type__c = 'Quote';
        insert qList;
        SBQQ__Quote__c q = qList[0];
        o.SBQQ__Quote__c = q.Id;
        update o;
        List<Service26Config__c> configs = HDT_UTL_DataFactoryTst.createService26Config(6, false);
        configs[0].Type__c = 'Posizione';
        configs[0].ProductFamily__c = 'VAS Fatturabili';
        configs[0].Servizio__c = 'GAS';
        configs[0].Occurrence__c = 2;
        configs[0].Field__c = 'billable__c';
        configs[1].Field__c = 'billable__c';
        configs[1].SapCode__c = 'sapcode2';
        configs[1].Type__c = 'Operando';
        configs[1].ProductFamily__c = 'VAS Fatturabili';
        configs[1].Servizio__c = 'GAS';
        configs[1].Occurrence__c = 2;
        configs[2].Type__c = 'Posizione';
        configs[2].ProductFamily__c = 'VAS Fatturabili';
        configs[2].Servizio__c = 'GAS';
        configs[2].Occurrence__c = 3;
        configs[2].Field__c = 'billable__c';
        configs[3].Field__c = 'billable__c';
        configs[3].SapCode__c = 'sapcode3';
        configs[3].Type__c = 'Operando';
        configs[3].ProductFamily__c = 'VAS Fatturabili';
        configs[3].Servizio__c = 'GAS';
        configs[3].Occurrence__c = 3;
        configs[4].Type__c = 'Posizione';
        configs[4].ProductFamily__c = 'VAS Fatturabili';
        configs[4].Servizio__c = 'GAS';
        configs[4].Occurrence__c = 4;
        configs[4].Field__c = 'billable__c';
        configs[5].Field__c = 'billable__c';
        configs[5].SapCode__c = 'sapcode4';
        configs[5].Type__c = 'Operando';
        configs[5].ProductFamily__c = 'VAS Fatturabili';
        configs[5].Servizio__c = 'GAS';
        configs[5].Occurrence__c = 4;
        insert configs;

        configs[2].Operando__c = configs[3].id;
        configs[4].Operando__c = configs[5].id;
        update configs;

        List<Product2> prods = HDT_UTL_DataFactoryTst.createProduct2(2, false);
        prods[0].Family = 'VAS Fatturabili';
        prods[0].Name  = 'VAS Fatturabili 2';
        prods[0].Old__c  = 'Y';
        prods[1].Family = 'VAS Fatturabili';
        prods[1].Name  = 'VAS Fatturabili 4';
        prods[1].Old__c  = 'Y';
        insert prods;
        prods = [SELECT Id FROM Product2];
        List<SBQQ__QuoteLine__c> qliList = new List<SBQQ__QuoteLine__c>();
        Integer i = 0;
        for(SBQQ__QuoteLine__c ql : HDT_UTL_DataFactoryTst.createQuoteLines(prods[0].Id, q.Id, 3, false)){
            qL.SBQQ__Existing__c = true;
            qL.SBQQ__Product__c = prods[i].Id;
            i++;
            qliList.add(qL);           
        }
        insert qliList;
        Test.startTest();
            HDT_UTL_ServiceTwentySix service = new HDT_UTL_ServiceTwentySix();
            HDT_UTL_ServiceTwentySix.HDT_WRP_DtoServiceTwentySix res = service.startProcess(o.Id); 
            System.assertEquals('sapcode3', res.elements[0].field, 'testAmendmentManaged : doesn\'t work');
        Test.stopTest();
    }
}