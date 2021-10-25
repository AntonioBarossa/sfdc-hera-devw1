/**
 * @author Valere (valere@noeli-it.net)
 * @date 6/10/2021
 * @description HDT_UTL_VasManagementTst Test Class
 * @history valere - 6/10/2021– Created Class
 */
@isTest
public class HDT_UTL_VasManagementTst {

    
	
    @TestSetup
    static void makeData(){
        //String VAS_STANDALONE_PRICEBOOK = 'VAS STANDALONE';
        List<Account> accountList= HDT_UTL_DataFactoryTst.createAccountResidenziale(1,true,'HERA COMM','Persona fisica','Famiglie');
        List<Sale__c> saleslist= HDT_UTL_DataFactoryTst.createSale( 1, true, accountList[0].id, 'Bozza');
        //Instantiate the Pricebook2 record with StandardPricebookId
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        Update standardPricebook;
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact (1,true,accountList[0].id);
        List<ServicePoint__c> servicepointList = HDT_UTL_DataFactoryTst.createServicePoint (1,true);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContractNw (1,true,new Map<String,Object>{
            'ServicePoint'=>servicepointList[0].id,
            'accountId'=>accountList[0].id
        }); 
        List<Order> orderListSale= HDT_UTL_DataFactoryTst.createOrder(1, true, accountList[0].id, saleslist);
        List<Order> orderListWithPricebook= HDT_UTL_DataFactoryTst.createOrderWithPricebookNw(1, true, saleslist, new Map<String,Object>{
            'SalesCompany__c'=>'Hera Comm Marche',
            'CustomerCode__c'=>'TestCustomerCode',
            'accountId'=>accountList[0].id,
            'Pricebook2Id'=>standardPricebook.id,
            'CustomerFiscalCode__c'=>'TestFiscalCode',
            'CustomerVATNumber__c'=>'TestVATNumber',
            'ServicePointCode__c'=>'TestPointCode',
            'OrderReference__c'=>orderListSale[0].id,
            'ContractReference__c'=>contractList[0].id,
            'CustomerName__c'=>'TestCustomer',
            'CommercialProduct__c'=>'TestProduct',
            'CommercialProductVersion__c'=>'TestVersion',
            'ContractAccountCode__c'=>'TestAccCod',
            'VasServiceActivationDate__c'=>date.today(),
            'ShippingStreetToponym__c'=>'TestSST',
            'ShippingStreetName__c'=>'TestSSNA',
            'ShippingStreetNumber__c'=>'TestSSnU',
            'ShippingCity__c'=>'SA',
            'ShippingPostalCode__c'=>'SPC',
            'ShippingPlace__c'=>'SPC',
            'ShippingProvince__c'=>'SP',
            'PhoneNumber__c'=>'3934927025',
            'ShippingMail__c'=>'Test@SM.com',
            'SignedDate__c'=>date.today()
        } );     
        SBQQ__Subscription__c mySubscription = HDT_UTL_DataFactoryTst.createSubscriptionNw(contractList[0].id);

        List<Case> caseList = HDT_UTL_DataFactoryTst.createCaseNw(1, true, new Map<String,Object>{
            'accountId'=>accountList[0].id,
            'ContractReference'=>contractList[0].id,
            'contactID'=>contactList[0].id,
            'servicepointID'=>servicepointList[0].id,
            'orderID'=>orderListWithPricebook[0].id,
            'VasStatus'=>'ANNUL PER CESSAZIONE'
            
        } );

        List<string> strValuesList = new List<string>();
        strValuesList.add('teststrValues');
        List<Product2> product2List = HDT_UTL_DataFactoryTst.createProduct2Nw(3, true, new Map<String,Object>{
            'NumberRateMonthly'=>10           
        } );
        // Product2List[0].NumberRateMonthly__c=10;
        // insert Product2List;
        SBQQ__Quote__c quote = HDT_UTL_DataFactoryTst.createEmptyQuoteNw();
        List<SBQQ__QuoteLine__c> quoteLineList= HDT_UTL_DataFactoryTst.createQuoteLines(product2List[0].id, quote.id, 1, true);
        List<PricebookEntry> pricebookentryList= HDT_UTL_DataFactoryTst.createPricebookEntry(product2List, true, standardPricebook.Id);
    }


    @istest 
    static void methodTst() {
        Order[] orderList =[select id,SalesCompany__c,CustomerCode__c,CustomerFiscalCode__c,CustomerVATNumber__c,ServicePointCode__c,OrderReference__c,ContractReference__c,CustomerName__c,
        CommercialProduct__c,CommercialProductVersion__c,OrderNumber,ContractReference__r.SAPContractCode__c,ContractAccountCode__c,VasServiceActivationDate__c,
        SBQQ__Quote__r.SBQQ__ListAmount__c,SBQQ__Quote__r.ListAmountVAT__c,SBQQ__Quote__r.TotalDiscountAmountVAT__c,ShippingStreetToponym__c,
        ShippingStreetName__c,ShippingStreetNumber__c,ShippingCity__c,ShippingPlace__c,ShippingPostalCode__c,ShippingProvince__c,PhoneNumber__c,
        ShippingMail__c,SignedDate__c from order];
        Case[] caseList =[select id, Order__c,CaseNumber,VasStatus__c,Asset.SBQQ__OrderProduct__r.OrderId,Subscription__r.SBQQ__Contract__r.SBQQ__Order__c from case ];
        OrderItem[] orderItemList = [select id,Product2Id,VASBillingMode__c,VasActivationDate__c,DurationDay__c,PaymentMode__c,Quantity,
        PriceNet__c,PriceNetDiscounted__c,Percentage__c from orderItem ];
        SBQQ__Quote__c[] quoteList = [select id,SBQQ__ListAmount__c,ListAmountVAT__c,TotalDiscountAmountVAT__c from SBQQ__Quote__c ];
        System.debug('caseList[0]:'+ caseList[0]);

        Test.startTest();
        HDT_UTL_VasManagement.HDT_WRP_VASActivationReq actReq = HDT_UTL_VasManagement.getActivationRequest(orderList[1].id);
        String actReqString = JSON.serialize(actReq);
        System.assertEquals(true,actReqString.contains(orderList[1].ShippingMail__c),'The object has the good value of the field');
        System.assertNotEquals(false,actReqString.contains(JSON.serialize(orderList[1].SignedDate__c)),'The object has the good value of the field');

        HDT_UTL_VasManagement.HDT_WRP_VASDisactivationReq disactReq = HDT_UTL_VasManagement.getDeactivationRequest(caseList[0].id);
        String disactReqString = JSON.serialize(disactReq);
		System.assertEquals(true,disactReqString.contains(orderList[1].ContractReference__r?.SAPContractCode__c),'The object has the good value of the field');
        System.assertNotEquals(false,disactReqString.contains(caseList[0].VasStatus__c),'The object has the good value of the field');

        HDT_UTL_VasManagement.HDT_WRP_VASReq vasReq = new HDT_UTL_VasManagement.HDT_WRP_VASReq(orderList[1]);
        String vasReqString = JSON.serialize(vasReq);
		System.assertEquals(true,vasReqString.contains(orderList[1].CommercialProductVersion__c),'The object has the good value of the field');
        System.assertNotEquals(false,vasReqString.contains(orderList[1].OrderNumber),'The object has the good value of the field');

        HDT_UTL_VasManagement.HDT_WRP_VASReq vasReq2 = new HDT_UTL_VasManagement.HDT_WRP_VASReq(orderList[1],caseList[0]);
        String vasReq2String = JSON.serialize(vasReq2);
        System.debug('vasReq2String:'+vasReq2String);
        System.assertEquals(true,vasReq2String.contains(orderList[1].OrderNumber),'The value of the field keyServizio');
        System.assertNotEquals(false,vasReq2String.contains('Version'),'The value of versione field is TestVersion');
                       

        HDT_UTL_VasManagement.HDT_WRP_VASDisactivationReq vasDisactivationReq = new HDT_UTL_VasManagement.HDT_WRP_VASDisactivationReq(orderList[1],caseList[0]);
        String vasDisactivationReqString = JSON.serialize(vasDisactivationReq);
     	System.assertEquals(true,vasDisactivationReqString.contains(JSON.serialize(orderList[0].ContractReference__r?.SAPContractCode__c)),'The object has the good value of the field');
        System.assertNotEquals(false,vasDisactivationReqString.contains(caseList[0].VasStatus__c),'The object has the good value of the field');


        HDT_UTL_VasManagement.HDT_WRP_VASActivationReq vasDisactivationReq2 = new HDT_UTL_VasManagement.HDT_WRP_VASActivationReq(orderList[1]);
        String vasDisactivationReq2String = JSON.serialize(vasDisactivationReq2);
  		System.assertEquals(true,vasDisactivationReq2String.contains(JSON.serialize(orderList[1].SignedDate__c)),'The object has the good value of the field');
        System.assertNotEquals(false,vasDisactivationReq2String.contains(JSON.serialize(orderList[1].SignedDate__c)),'The object has the good value of the field');

        
        OrderItem orderItem = new OrderItem();
        orderItem.Percentage__c=0;
        orderItem.Quantity=1;
        HDT_UTL_VasManagement.HDT_WRP_VASActivationReqItem vasActivationReqItem = new HDT_UTL_VasManagement.HDT_WRP_VASActivationReqItem(orderItem);
        String vasActivationReqItemString = JSON.serialize(vasActivationReqItem);
    	System.assertEquals(true,vasActivationReqItemString.contains(JSON.serialize(orderItem.PriceNetDiscounted__c)),'The object has the good value of the field');
        System.assertNotEquals(false,vasActivationReqItemString.contains(JSON.serialize(orderItem.Percentage__c)),'The object has the good value of the field');


        Test.stopTest();
    }
}