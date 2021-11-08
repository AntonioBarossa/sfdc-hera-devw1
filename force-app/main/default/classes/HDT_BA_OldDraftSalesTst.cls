/**
 * @author Sabina Levonja (sabina.levonja@dunegroup.it)
 * @date 28/09/2021
 * @description HDT_BA_OldDraftSales Test Class
 * @history Sabina Levonja – 28/09/2021 – Created Class
 */
@isTest
public with sharing class HDT_BA_OldDraftSalesTst {
    @TestSetup
    static void setup(){
        
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        List<Account> accList=HDT_UTL_DataFactoryTst.createAccountResidenziale(1, true, 'HERA COMM', 'D1 - Persona fisica', 'Enti');
       	List<BillingProfile__c> bpList = HDT_UTL_DataFactoryTst.createBillingProfile(1, true, accList[0].Id);
       	List<Sale__c> saleList = HDT_UTL_DataFactoryTst.createSale(1, true, accList[0].Id, 'Bozza');
        Test.setCreatedDate(saleList[0].Id,System.now().addDays(-30));
        List<Opportunity> oppList = HDT_UTL_DataFactoryTst.createOpportunity(1, false);
		oppList[0].Sale__c= saleList[0].Id;
        insert oppList;
        List<Order> orderList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].Id, saleList);

        List<ServicePoint__c> spList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<SBQQ__Quote__c> quoteList = HDT_UTL_DataFactoryTst.createQuote(1, true, orderList[0].Id, oppList[0].Id, saleList[0].Id, 'Quote');
        Order ord= orderList[0];
        ord.Sale__c= saleList[0].Id;
        ord.SBQQ__Quote__c= quoteList[0].Id;
        ord.BillingProfile__c= bpList[0].Id;
        ord.ServicePoint__c= spList[0].Id;
        update ord;
        HDT_UTL_DataFactoryTst.createDaysToExpiration(1, true,'20','Vendita');
    }
    
    @isTest
    public static void testBatch() {
        Test.startTest();
        Sale__c sale = [SELECT Id, Status__c,CancellationReason__c from Sale__c limit 1];

        HDT_BA_OldDraftSales oldSales = new HDT_BA_OldDraftSales();
        Database.executeBatch(oldSales);
                
        Test.stopTest();
        
        Sale__c updatedSale = [SELECT Id, Status__c,CancellationReason__c from Sale__c limit 1];

        System.assertEquals(true, updatedSale.Status__c!=sale.Status__c,'This field has been updated');
        System.assertNotEquals(true, updatedSale.CancellationReason__c == sale.CancellationReason__c,'This is not true because the field has been updated');

    }
}