/**
 * @author Valere (valere@noeli-it.net)
 * @date 6/10/2021
 * @description HDT_UTL_VasManagementTst Test Class
 * @history valere - 6/10/2021– Created Class
 */
@isTest
public class HDT_UTL_VasManagementTst {

    private static HDT_UTL_Constants utlConstants = new HDT_UTL_Constants();    
	
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
        
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract (1, false , accountList[0].id);
        contractList[0].ServicePoint__c = servicepointList[0].id;
        insert contractList;

        List<Order> orderListSale= HDT_UTL_DataFactoryTst.createOrder(1, true, accountList[0].id, saleslist);

        List<Order> orderListWithPricebook= HDT_UTL_DataFactoryTst.createOrderWithParams(1, true, saleslist, utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_DEFAULT, new Map<String,Object>{
            'SalesCompany__c'=>'Hera Comm Marche',
            'CustomerCode__c'=>'TestCustomerCode',
            'AccountId'=>accountList[0].id,
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

        HDT_UTL_DataFactoryTst.createSubscription(1, true, null, contractList[0].id, null).get(0);

        HDT_UTL_DataFactoryTst.createCaseWithParams(1, true, new Map<String,Object>{
            'AccountId'=>accountList[0].id,
            'Contract__c'=>contractList[0].id,
            'ContactId'=>contactList[0].id,
            'ServicePoint__c'=>servicepointList[0].id,
            'Order__c'=>orderListWithPricebook[0].id,
            'VasStatus__c'=>'ANNUL PER CESSAZIONE'
            
        } );

        List<string> strValuesList = new List<string>();
        strValuesList.add('teststrValues');
        
        List<Product2> product2List = HDT_UTL_DataFactoryTst.createProduct2(3, false);
        for (Product2 prod : product2List) {
            prod.NumberRateMonthly__c = 10;
        }
        insert product2List;
        
        SBQQ__Quote__c quote = HDT_UTL_DataFactoryTst.createEmptyQuote(1, true).get(0);
        HDT_UTL_DataFactoryTst.createQuoteLines(product2List[0].id, quote.id, 1, true);
        HDT_UTL_DataFactoryTst.createPricebookEntry(product2List, true, standardPricebook.Id);
    }


    @istest 
    static void methodTst() {
        List<Order> orderList =[select id,SalesCompany__c,CustomerCode__c,CustomerFiscalCode__c,CustomerVATNumber__c,ServicePointCode__c,OrderReference__c,ContractReference__c,CustomerName__c,
        CommercialProduct__c,CommercialProductVersion__c,OrderNumber,ContractReference__r.SAPContractCode__c,ContractAccountCode__c,VasServiceActivationDate__c,
        SBQQ__Quote__r.SBQQ__ListAmount__c,SBQQ__Quote__r.ListAmountVAT__c,SBQQ__Quote__r.TotalDiscountAmountVAT__c,ShippingStreetToponym__c,
        ShippingStreetName__c,ShippingStreetNumber__c,ShippingCity__c,ShippingPlace__c,ShippingPostalCode__c,ShippingProvince__c,PhoneNumber__c,
        ShippingMail__c,SignedDate__c from order];
        List<Case> caseList =[select id, Order__c,CaseNumber,VasStatus__c,Asset.SBQQ__OrderProduct__r.OrderId,Subscription__r.SBQQ__Contract__r.SBQQ__Order__c from case ];        

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