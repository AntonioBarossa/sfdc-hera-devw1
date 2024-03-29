/**
 * @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
 * @date 29/06/2021
 * @description HDT_LC_ApplyBillingProfileModal Test Classes
 * @history Lucas da Silva Fernandes – 29/06/2021 – Created Class
 */

@isTest
public with sharing class HDT_LC_ApplyBillingProfileModalTst {
    
    @TestSetup
    static void setup(){

        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();

        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<BillingProfile__c> bpList = HDT_UTL_DataFactoryTst.createBillingProfile(1, true, accList[0].Id);

        List<ServicePoint__c> spList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Sale__c> saleList = HDT_UTL_DataFactoryTst.createSale(1, true, accList[0].Id, 'Bozza');
        List<Opportunity> oppList = HDT_UTL_DataFactoryTst.createOpportunity(1, true);
        
        List<Product2> productList = HDT_UTL_DataFactoryTst.createProduct2(1, false);
        productList[0].Name = 'Punto Fornitura Acqua';
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
        qlList[0].SBQQ__RequiredBy__c = qlList[1].Id;

        qlList[1].PaymentMode__c = 'Bollettino postale';
        qlList[1].SendingBillMode__c = 'Cartaceo';
        qlList[1].ServicePoint__c = spList[0].Id;
        qlList[1].BillingProfile__c = bpList[0].Id;
        update qlList;
    }

    @isTest
    public static void testGetBonusPerOffer() {

        Test.startTest();

        List<SBQQ__QuoteLine__c> ql = [SELECT Id, SBQQ__RequiredBy__c FROM SBQQ__QuoteLine__c];

        List<SBQQ__QuoteLine__c> result = HDT_LC_ApplyBillingProfileModal.getBonusPerOffer(ql);

        System.assertEquals(false, result.isEmpty(), 'result is not empty nor null');
        System.assertNotEquals(true, result.isEmpty(), 'result is empty or null');

        Test.stopTest();
    }

    @isTest
    public static void testGetEligibleQuoteLinesToApply() {

        Test.startTest();

        Sale__c sale = [SELECT Id FROM Sale__c WHERE Name = 'testSaleName0' LIMIT 1];
        BillingProfile__c bp = [SELECT Id, PaymentMethod__c, PaymentConditions__c, BillSendingMethod__c, InvoicingCity__c FROM BillingProfile__c LIMIT 1];
        bp.PaymentMethod__c = 'Bollettino postale';
        bp.BillSendingMethod__c = 'Cartaceo';

        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('saleId', sale.Id);
        inputs.put('selectedBillingProfile', JSON.Serialize(bp));

        String result = HDT_LC_ApplyBillingProfileModal.getEligibleQuoteLinesToApply(inputs);

        System.assertEquals(false, String.isBlank(result), 'result is not empty nor null');
        System.assertNotEquals(true, String.isBlank(result), 'result is empty or null');

        Test.stopTest();
    }

    @isTest
    public static void testGetQuoteLineBundle() {

        Test.startTest();

        Sale__c sale = [SELECT Id FROM Sale__c WHERE Name = 'testSaleName0' LIMIT 1];
        SBQQ__QuoteLine__c ql = [SELECT Id, PaymentMode__c, SendingBillMode__c FROM SBQQ__QuoteLine__c WHERE PaymentMode__c = 'Bollettino postale' LIMIT 1];
        
        Map<String,List<SBQQ__QuoteLine__c>> mapQuoteLine = HDT_LC_ApplyBillingProfileModal.getQuoteLineBundle(sale.Id, ql.PaymentMode__c, ql.SendingBillMode__c);

        System.assertEquals(false, mapQuoteLine.isEmpty(), 'Map is not empty nor null');

        System.assertNotEquals(true, mapQuoteLine.isEmpty(), 'Map is empty or null');

        Test.stopTest();
    }

    @isTest
    public static void testUpdateQuoteLinesBillingProfile() {

        Test.startTest();

        Account acc = [SELECT Id FROM Account WHERE Category__c = 'Aziende SME' LIMIT 1];

        BillingProfile__c bp = new BillingProfile__c(
            Account__c = acc.Id,
            ContractAccountCode__c = '200001008453'
        );
        insert bp;

        List<SBQQ__QuoteLine__c> qline = [SELECT Id,
                                                SBQQ__ProductFamily__c,
                                                BillingProfile__c,
                                                SBQQ__RequiredBy__c,
                                                Name,
                                                SBQQ__RequiredBy__r.BillingProfile__c,
                                                SBQQ__RequiredBy__r.BillingProfile__r.Name,
                                                ServicePoint__r.ServicePointCode__c,
                                                SBQQ__RequiredBy__r.SBQQ__Product__c,
                                                SBQQ__RequiredBy__r.SBQQ__Product__r.Name,
                                                SBQQ__Quote__r.ContractReference__c,
                                                SBQQ__Quote__r.AllowChangeUse__c,
                                                SBQQ__Quote__r.AmendmentAllowed__c,
                                                SBQQ__Quote__r.ContractReference__r.BillingProfile__c,
                                                SBQQ__Quote__r.ContractReference__r.BillingProfile__r.Name,
                                                SBQQ__Product__r.Name 
                                            FROM SBQQ__QuoteLine__c 
                                            WHERE PaymentMode__c = 'RID'];
        List<HDT_LC_ApplyBillingProfileModal.HDT_WRP_QuoteLineWrp> wrpList = new List<HDT_LC_ApplyBillingProfileModal.HDT_WRP_QuoteLineWrp>();
        for(SBQQ__QuoteLine__c ql : qline){
            HDT_LC_ApplyBillingProfileModal.HDT_WRP_QuoteLineWrp wrp = new HDT_LC_ApplyBillingProfileModal.HDT_WRP_QuoteLineWrp(ql);
            wrp.isDueThirtyDays='Si';
            wrpList.add(wrp);
        }

        HDT_LC_ApplyBillingProfileModal.updateQuoteLinesBillingProfile(JSON.serialize(wrpList), bp.Id);

        qline = [SELECT Id, BillingProfile__c FROM SBQQ__QuoteLine__c WHERE PaymentMode__c = 'RID'];

        System.assertEquals(bp.Id, qLine[0].BillingProfile__c, 'Quote Line updated.');

        System.assertNotEquals(null, qLine[0].BillingProfile__c, 'Quote Line not updated');

        Test.stopTest();
    }
}
