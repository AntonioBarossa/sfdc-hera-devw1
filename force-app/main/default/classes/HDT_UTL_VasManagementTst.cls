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
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContractNW (1,true,new Map<String,Object>{
            'ServicePoint'=>servicepointList[0].id,
            'accountId'=>accountList[0].id
        }); 
        List<Order> orderListSale= HDT_UTL_DataFactoryTst.createOrder(1, true, accountList[0].id, saleslist);
        List<Order> orderListWithPricebook= HDT_UTL_DataFactoryTst.createOrderWithPricebookNW(1, true, saleslist, new Map<String,Object>{
            'SalesCompany'=>'Hera Comm Marche',
            'CustomerCode'=>'TestCustomerCode',
            'accountId'=>accountList[0].id,
            'standardPricebookId'=>standardPricebook.id,
            'CustomerFiscalCode'=>'TestFiscalCode',
            'CustomerVATNumber'=>'TestVATNumber',
            'ServicePointCode'=>'TestPointCode',
            'OrderReference'=>orderListSale[0].id,
            'ContractReference'=>contractList[0].id,
            'CustomerName'=>'TestCustomer',
            'CommercialProduct'=>'TestProduct',
            'CommercialProductVersion'=>'TestVersion',
            'ContractAccountCode'=>'TestAccCod',
            'VasServiceActivationDate'=>date.today(),
            'ShippingStreetToponym'=>'TestSST',
            'ShippingStreetName'=>'TestSSNA',
            'ShippingStreetNumber'=>'TestSSnU',
            'ShippingCity'=>'SA',
            'ShippingPostalCode'=>'SPC',
            'ShippingProvince'=>'SP',
            'PhoneNumber'=>'3934927025',
            'ShippingMail'=>'Test@SM.com',
            'SignedDate'=>date.today()
        } );     
        SBQQ__Subscription__c mySubscription = HDT_UTL_DataFactoryTst.createSubscriptionNW(contractList[0].id);

        List<Case> caseList = HDT_UTL_DataFactoryTst.createCaseNW(1, true, new Map<String,Object>{
            'accountId'=>accountList[0].id,
            'ContractReference'=>contractList[0].id,
            'contactID'=>contactList[0].id,
            'servicepointID'=>servicepointList[0].id,
            'orderID'=>orderListWithPricebook[0].id,
            'VasStatus'=>'ANNUL PER CESSAZIONE'
            
        } );

        List<string> strValuesList = new List<string>();
        strValuesList.add('teststrValues');
        List<Product2> Product2List = HDT_UTL_DataFactoryTst.createProduct2NW(3, true, new Map<String,Object>{
            'NumberRateMonthly'=>10           
        } );
        // Product2List[0].NumberRateMonthly__c=10;
        // insert Product2List;
        SBQQ__Quote__c quote = HDT_UTL_DataFactoryTst.createEmptyQuoteNW();
        List<SBQQ__QuoteLine__c> QuoteLineList= HDT_UTL_DataFactoryTst.createQuoteLines(Product2List[0].id, quote.id, 1, true);
        List<PricebookEntry> pricebookentryList= HDT_UTL_DataFactoryTst.createPricebookEntry(Product2List, true, standardPricebook.Id);
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
        SBQQ__Quote__c[] QuoteList = [select id,SBQQ__ListAmount__c,ListAmountVAT__c,TotalDiscountAmountVAT__c from SBQQ__Quote__c ];
        System.debug('caseList[0]:'+ caseList[0]);

        Test.startTest();
        HDT_UTL_VasManagement.HDT_WRP_VASActivationReq actReq = HDT_UTL_VasManagement.getActivationRequest(orderList[1].id);
        String actReqString = JSON.serialize(actReq);
        System.debug('actReqString:'+actReqString);
        System.assert(actReqString.contains(orderList[1].ContractAccountCode__c),'value of parameter is matching');
        System.assert(actReqString.contains(JSON.serialize(orderList[1].VasServiceActivationDate__c)),'value of parameter is matching');
        System.assert(actReqString.contains(JSON.serialize(orderList[1].SBQQ__Quote__r.SBQQ__ListAmount__c)),'value of parameter is matching');
        System.assert(actReqString.contains(JSON.serialize(orderList[1].SBQQ__Quote__r?.ListAmountVAT__c)),'value of parameter is matching');
        System.assert(actReqString.contains(JSON.serialize(orderList[1].SBQQ__Quote__r?.TotalDiscountAmountVAT__c)),'value of parameter is matching');
        System.assert(actReqString.contains(orderList[1].ShippingStreetToponym__c),'value of parameter is matching');
        System.assert(actReqString.contains(orderList[1].ShippingStreetName__c),'value of parameter is matching');
        System.assert(actReqString.contains(orderList[1].ShippingStreetNumber__c),'value of parameter is matching');
        System.assert(actReqString.contains(orderList[1].ShippingCity__c),'value of parameter is matching');
        System.assert(actReqString.contains(orderList[1].ShippingPlace__c),'value of parameter is matching');
        System.assert(actReqString.contains(orderList[1].ShippingProvince__c),'value of parameter is matching');
        System.assert(actReqString.contains(orderList[1].PhoneNumber__c),'value of parameter is matching');
        System.assert(actReqString.contains(orderList[1].ShippingMail__c),'value of parameter is matching');
        System.assert(actReqString.contains(JSON.serialize(orderList[1].SignedDate__c)),'value of parameter is matching');

        HDT_UTL_VasManagement.HDT_WRP_VASDisactivationReq disactReq = HDT_UTL_VasManagement.getDeactivationRequest(caseList[0].id);
        String disactReqString = JSON.serialize(disactReq);
        System.debug('disactReqString:'+disactReqString);
        System.assert(disactReqString.contains(orderList[1].ContractReference__r?.SAPContractCode__c),'value of parameter is matching');
        System.assert(disactReqString.contains(caseList[0].VasStatus__c),'value of parameter is matching');

        HDT_UTL_VasManagement.HDT_WRP_VASReq VASReq = new HDT_UTL_VasManagement.HDT_WRP_VASReq(orderList[1]);
        String VASReqString = JSON.serialize(VASReq);
        System.debug('VASReqString:'+VASReqString);
        System.assert(VASReqString.contains('2060'),'value of parameter is matching');
        System.assert(VASReqString.contains(orderList[1].CustomerCode__c),'value of parameter is matching');
        System.assert(VASReqString.contains(orderList[1].CustomerFiscalCode__c),'value of parameter is matching');
        System.assert(VASReqString.contains(orderList[1].CustomerVATNumber__c),'value of parameter is matching');
        System.assert(VASReqString.contains(orderList[1].ServicePointCode__c),'value of parameter is matching');
        System.assert(VASReqString.contains(orderList[1].CustomerName__c),'value of parameter is matching');
        System.assert(VASReqString.contains(orderList[1].CommercialProduct__c),'value of parameter is matching');
        System.assert(VASReqString.contains(orderList[1].CommercialProductVersion__c),'value of parameter is matching');
        System.assert(VASReqString.contains(orderList[1].OrderNumber),'value of parameter is matching');

        HDT_UTL_VasManagement.HDT_WRP_VASReq VASReq2 = new HDT_UTL_VasManagement.HDT_WRP_VASReq(orderList[1],caseList[0]);
        String VASReq2String = JSON.serialize(VASReq2);
        System.debug('VASReq2String:'+VASReq2String);
        System.assert(VASReq2String.contains('O-00100300'),'value of parameter is matching');

        HDT_UTL_VasManagement.HDT_WRP_VASDisactivationReq VASDisactivationReq = new HDT_UTL_VasManagement.HDT_WRP_VASDisactivationReq(orderList[1],caseList[0]);
        String VASDisactivationReqString = JSON.serialize(VASDisactivationReq);
        System.debug('VASDisactivationReqString:'+VASDisactivationReqString);
        System.assert(VASDisactivationReqString.contains(JSON.serialize(orderList[0].ContractReference__r?.SAPContractCode__c)),'value of parameter is matching');
        System.assert(VASDisactivationReqString.contains(caseList[0].VasStatus__c),'value of parameter is matching');


        HDT_UTL_VasManagement.HDT_WRP_VASActivationReq VASDisactivationReq2 = new HDT_UTL_VasManagement.HDT_WRP_VASActivationReq(orderList[1]);
        String VASDisactivationReq2String = JSON.serialize(VASDisactivationReq2);
        System.debug('VASDisactivationReq2String:'+VASDisactivationReq2String);
        System.assert(VASDisactivationReq2String.contains(orderList[1].ContractAccountCode__c),'value of parameter is matching');
        System.assert(VASDisactivationReq2String.contains(JSON.serialize(orderList[1].VasServiceActivationDate__c)),'value of parameter is matching');
        System.assert(VASDisactivationReq2String.contains(JSON.serialize(orderList[1].SBQQ__Quote__r.SBQQ__ListAmount__c)),'value of parameter is matching');
        System.assert(VASDisactivationReq2String.contains(JSON.serialize(orderList[1].SBQQ__Quote__r?.ListAmountVAT__c)),'value of parameter is matching');
        System.assert(VASDisactivationReq2String.contains(JSON.serialize(orderList[1].SBQQ__Quote__r?.TotalDiscountAmountVAT__c)),'value of parameter is matching');
        System.assert(VASDisactivationReq2String.contains(orderList[1].ShippingStreetToponym__c),'value of parameter is matching');
        System.assert(VASDisactivationReq2String.contains(orderList[1].ShippingStreetName__c),'value of parameter is matching');
        System.assert(VASDisactivationReq2String.contains(orderList[1].ShippingStreetNumber__c),'value of parameter is matching');
        System.assert(VASDisactivationReq2String.contains(orderList[1].ShippingCity__c),'value of parameter is matching');
        System.assert(VASDisactivationReq2String.contains(orderList[1].ShippingPlace__c),'value of parameter is matching');
        System.assert(VASDisactivationReq2String.contains(orderList[1].ShippingPostalCode__c),'value of parameter is matching');
        System.assert(VASDisactivationReq2String.contains(orderList[1].ShippingProvince__c),'value of parameter is matching');
        System.assert(VASDisactivationReq2String.contains(orderList[1].PhoneNumber__c),'value of parameter is matching');
        System.assert(VASDisactivationReq2String.contains(orderList[1].ShippingMail__c),'value of parameter is matching');
        System.assert(VASDisactivationReq2String.contains(JSON.serialize(orderList[1].SignedDate__c)),'value of parameter is matching');

        
        OrderItem orderItem = new OrderItem();
        orderItem.Percentage__c=0;
        orderItem.Quantity=1;
        HDT_UTL_VasManagement.HDT_WRP_VASActivationReqItem VASActivationReqItem = new HDT_UTL_VasManagement.HDT_WRP_VASActivationReqItem(orderItem);
        String VASActivationReqItemString = JSON.serialize(VASActivationReqItem);
        System.debug('VASActivationReqItemString:'+VASActivationReqItemString);
        System.assert(VASActivationReqItemString.contains(JSON.serialize(orderItem.Quantity)),'value of parameter is matching');
        System.assert(VASActivationReqItemString.contains(JSON.serialize(orderItem.PriceNet__c)),'value of parameter is matching');
        System.assert(VASActivationReqItemString.contains(JSON.serialize(orderItem.PriceNetDiscounted__c)),'value of parameter is matching');
        System.assert(VASActivationReqItemString.contains(JSON.serialize(orderItem.Percentage__c)),'value of parameter is matching');


        Test.stopTest();
    }
}