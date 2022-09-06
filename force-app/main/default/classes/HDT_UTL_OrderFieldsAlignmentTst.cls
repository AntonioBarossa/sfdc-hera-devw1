/**
 * @author Sabina Levonja (sabina.levonja@dunegroup.it)
 * @date 16/09/2021
 * @description HDT_UTL_OrderFieldsAlignmentTst Test Class
 * @history Sabina Levonja – 16/09/2021 – Created Class
 */

@isTest
public with sharing class HDT_UTL_OrderFieldsAlignmentTst {
    
    @TestSetup
    static void setup(){
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
		List<Account> accList=HDT_UTL_DataFactoryTst.createAccountResidenziale(1, true, 'HERA COMM', 'D1 - Persona fisica', 'Enti');
       	List<BillingProfile__c> bpList = HDT_UTL_DataFactoryTst.createBillingProfile(1, true, accList[0].Id);
       	List<Opportunity> oppList = HDT_UTL_DataFactoryTst.createOpportunity(1, true);
       	List<Sale__c> saleList = HDT_UTL_DataFactoryTst.createSale(1, true, accList[0].Id, 'Bozza');
       	List<ServicePoint__c> spList = HDT_UTL_DataFactoryTst.createServicePoint(1, false);
       	ServicePoint__c spoint= spList[0];
       	spoint.CommoditySector__c = 'Gas';
        spoint.ExciseGas__c='';
        spoint.MeterStatus__c= 'Attivo';
        spoint.ServicePointCode__c='testServicePoint';
        insert spoint;
       
        
        List<Product2> productList = HDT_UTL_DataFactoryTst.createProduct2(1, false);
        productList[0].Name = 'POD';
        productList[0].Family = 'VAS Fatturabili';
        insert productList;
        
		Id pricebookId=Test.getStandardPricebookId();
		List<PricebookEntry> pricebookEntry=HDT_UTL_DataFactoryTst.createPricebookEntry(productList, true, pricebookId);
        List<Order> orderList = HDT_UTL_DataFactoryTst.createOrderWithPricebook(1, true, accList[0].Id, saleList, pricebookId);
       
        List<SBQQ__Quote__c> quoteList = HDT_UTL_DataFactoryTst.createQuote(1, false, orderList[0].Id, oppList[0].Id, saleList[0].Id, 'Quote');
       	quoteList[0].OrderReference__c = null;
       	quoteList[0].AmendmentAllowed__c = true;
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
        Order ord= orderList[0];
        ord.Sale__c= saleList[0].Id;
        ord.SBQQ__Quote__c= quoteList[0].Id;
        ord.BillingProfile__c= bpList[0].Id;
        ord.ServicePoint__c= spList[0].Id;
        ord.ImplantType__c= '13EM-Non domestici MT';
        ord.PowerCommitted__c= 50.2;
        update ord;
        
        List<OrderItem> orderItems=HDT_UTL_DataFactoryTst.createOrderItem(1, false, orderList[0].Id, spList[0].Id, productList[0].Id, pricebookEntry[0].Id);
		orderItems[0].BillingProfile__c=bpList[0].Id;

		insert orderItems;
    }
    
    @isTest
    public static void testAlignFields() {

        Test.startTest();

        Order ord = [SELECT Id,AccountId,Sale__c,ServicePoint__c, ServicePointCode__c,OrderReference__c,isTransition__c, SBQQ__Quote__c,SalesCompanyCode__c,SalesCompany__c,BillingProfile__c,ServicePoint__r.Vat__c
                     FROM Order LIMIT 1];
        ServicePoint__c srPoint= [SELECT Id, ServicePointCode__c
                     FROM ServicePoint__c Where Id= :ord.ServicePoint__c LIMIT 1];
        
        HDT_UTL_Constants constants=new HDT_UTL_Constants();

        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, true);

        System.runAs(internalUser){
            HDT_UTL_OrderFieldsAlignment.alignFields(ord);
        }
        
        Order ordUpdated = [SELECT Id,ServicePoint__c, ServicePointCode__c
                     FROM Order LIMIT 1];
        System.assertEquals(ordUpdated.ServicePointCode__c, srPoint.ServicePointCode__c, 'The order ServicePointCode__c field has been updated');

        Test.stopTest();
    }

    @isTest
    public static void testCalculateRequestedOption() {

        Test.startTest();
        
		Order ord = [SELECT Id,ImplantType__c,PowerCommitted__c
                     FROM Order LIMIT 1];
        String result = HDT_UTL_OrderFieldsAlignment.calculateRequestedOption(ord.ImplantType__c,ord.PowerCommitted__c);
        System.assertNotEquals('', result, 'The String is not empty');
        
        Test.stopTest();
    }
}