/**
 * @author Valere (valere@noeli-it.net)
 * @date 6/10/2021
 * @description HDT_UTL_VasManagementTst Test Class
 * @history valere - 6/10/2021– Created Class
 */
@isTest
public class HDT_UTL_VasManagementTst {

    private static HDT_UTL_Constants utlConstants = new HDT_UTL_Constants();    
    private static HDT_UTL_Constants constants=new HDT_UTL_Constants(); 
	
    @TestSetup
    static void makeData(){

        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
        internalUser.UserPermissionsMarketingUser=true;

        insert internalUser;

        System.runAs(internalUser){

            HDT_UTL_DataFactoryTst.pClickInstance();
            HDT_UTL_DataFactoryTst.pClickOrderPhase();

            //String VAS_STANDALONE_PRICEBOOK = 'VAS STANDALONE';
            List<Account> accountList= HDT_UTL_DataFactoryTst.createAccountResidenziale(1,true,'HERA COMM','Persona fisica','Famiglie');
            List<Sale__c> saleslist= HDT_UTL_DataFactoryTst.createSale(5, true, accountList[0].id, 'Bozza');
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

            List<Product2> product2List = HDT_UTL_DataFactoryTst.createProduct2(3, false);
            for (Product2 prod : product2List) {
                prod.NumberRateMonthly__c = 10;
            }
            product2List[0].DescriptionSAP__c = 'HERA CALDAIA SICURA FAMIGLIEV3';
            insert product2List;

            List<Order> orderListSale= HDT_UTL_DataFactoryTst.createOrder(5, false, accountList[0].id, saleslist);
            orderListSale[0].Pricebook2Id = standardPricebook.id;
            orderListSale[0].ServicePoint__c = servicepointList[0].id;
            orderListSale[0].SalesCompany__c = 'Hera Comm Marche';
            orderListSale[0].CustomerCode__c='TestCustomerCode';
            orderListSale[0].AccountId=accountList[0].id;
            orderListSale[0].Pricebook2Id=standardPricebook.id;
            orderListSale[0].CustomerFiscalCode__c='TestFiscalCode';
            orderListSale[0].CustomerVATNumber__c='TestVATNumber';
            orderListSale[0].ServicePointCode__c='TestPointCode';
            orderListSale[0].OrderReference__c=orderListSale[0].id;
            orderListSale[0].ContractReference__c=contractList[0].id;
            orderListSale[0].CustomerName__c='TestCustomer';
            orderListSale[0].CommercialProduct__c='TestProduct';
            orderListSale[0].CommercialProductVersion__c='TestVersion';
            orderListSale[0].ContractAccountCode__c='TestAccCod';
            orderListSale[0].VasServiceActivationDate__c=date.today();
            orderListSale[0].ShippingStreetToponym__c='TestSST';
            orderListSale[0].ShippingStreetName__c='TestSSNA';
            orderListSale[0].ShippingStreetNumber__c='TestSSnU';
            orderListSale[0].ShippingCity__c='SA';
            orderListSale[0].ShippingPostalCode__c='SPC';
            orderListSale[0].ShippingPlace__c='SPC';
            orderListSale[0].ShippingProvince__c='SP';
            orderListSale[0].PhoneNumber__c='3934927025';
            orderListSale[0].ShippingMail__c = 'Test@SM.com';
            orderListSale[0].SignedDate__c=date.today();
            orderListSale[0].Name='testOrder1';
            orderListSale[0].VASType__c='VAS Servizio';
            orderListSale[0].ComfortCallDaysDue__c=2;
            orderListSale[0].IsEarlyActivation__c=true;

            orderListSale[2].VASType__c='VAS Servizio';
            orderListSale[2].ComfortCallDaysDue__c=null;
            orderListSale[2].IsEarlyActivation__c=false;
            orderListSale[2].Name='testOrder2';

            orderListSale[3].VASType__c='VAS Fatturabili';
            orderListSale[3].Name='testOrder4';

            orderListSale[4].VASType__c='VAS Prodotto';
            orderListSale[4].Name='testOrder5';
            insert orderListSale;

            List<Order> orderListWithPricebook= HDT_UTL_DataFactoryTst.createOrderWithParams(1, false, saleslist, utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_DEFAULT, new Map<String,Object>{
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
            orderListWithPricebook[0].Name = 'testOrder3';
            insert orderListWithPricebook;

            List<SBQQ__Subscription__c> subList = HDT_UTL_DataFactoryTst.createSubscription(1,false,accountList[0].id,contractList[0].id,servicepointList[0].id);
            subList[0].SBQQ__Product__c = product2List[0].id;
            insert subList;

            List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(2, false,accountList[0].id,contactList[0].id,servicepointList[0].id,contractList[0].id,orderListSale[0].id);     
            caseList[0].Subscription__c = subList[0].id;
            caseList[0].VasStatus__c = 'ANNUL PER CESSAZIONE';
            caseList[0].Order__c = orderListSale[0].id;

            caseList[1].VasStatus__c = null;
            caseList[1].Subscription__c = subList[0].id;
            insert caseList;

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
            
            SBQQ__Quote__c quote = HDT_UTL_DataFactoryTst.createEmptyQuote(1, true).get(0);
            HDT_UTL_DataFactoryTst.createQuoteLines(product2List[0].id, quote.id, 1, true);
            List<PricebookEntry> priceBookEntryList =  HDT_UTL_DataFactoryTst.createPricebookEntry(product2List, true, standardPricebook.Id);      

            List<OrderItem> orderItemList = HDT_UTL_DataFactoryTst.createOrderItem(1,false,orderListSale[0].id,servicepointList[0].id,product2List[0].id,priceBookEntryList[0].id);
            orderItemList[0].SBQQ__RequiredBy__c = null;
            insert orderItemList;
        }
    }


    @isTest 
    static void methodTst() {
        List<Order> orderList =[SELECT id,SalesCompany__c,CustomerCode__c,CustomerFiscalCode__c,CustomerVATNumber__c,ServicePointCode__c,OrderReference__c,ContractReference__c,CustomerName__c,
        CommercialProduct__c,CommercialProductVersion__c,OrderNumber,ContractReference__r.SAPContractCode__c,ContractAccountCode__c,VasServiceActivationDate__c,
        SBQQ__Quote__r.SBQQ__ListAmount__c,SBQQ__Quote__r.ListAmountVAT__c,SBQQ__Quote__r.TotalDiscountAmountVAT__c,ShippingStreetToponym__c, Account.Id, Account.CustomerCode__c,
        ShippingStreetName__c,ShippingStreetNumber__c,ShippingCity__c,ShippingPlace__c,ShippingPostalCode__c,ShippingProvince__c,PhoneNumber__c,
        ShippingMail__c,SignedDate__c, VasPracticeCode__c , TotalAmount, CommercialProductLink__r.DurationDay__c, CommercialProductLink__r.DurationDayGas__c, Pricebook2Id 
        FROM Order WHERE Name= 'testOrder1'];

        List<Order> orderList1 =[SELECT id,SalesCompany__c,CustomerCode__c,CustomerFiscalCode__c,CustomerVATNumber__c,ServicePointCode__c,OrderReference__c,ContractReference__c,CustomerName__c,
        CommercialProduct__c,CommercialProductVersion__c,OrderNumber,ContractReference__r.SAPContractCode__c,ContractAccountCode__c,VasServiceActivationDate__c,
        SBQQ__Quote__r.SBQQ__ListAmount__c,SBQQ__Quote__r.ListAmountVAT__c,SBQQ__Quote__r.TotalDiscountAmountVAT__c,ShippingStreetToponym__c, Account.Id, Account.CustomerCode__c,
        ShippingStreetName__c,ShippingStreetNumber__c,ShippingCity__c,ShippingPlace__c,ShippingPostalCode__c,ShippingProvince__c,PhoneNumber__c,
        ShippingMail__c,SignedDate__c, VasPracticeCode__c , TotalAmount, CommercialProductLink__r.DurationDay__c, CommercialProductLink__r.DurationDayGas__c, Pricebook2Id 
        FROM Order WHERE Name= 'testOrder3'];

        List<Case> caseList =[SELECT id, Order__c,CaseNumber,VasStatus__c,Asset.SBQQ__OrderProduct__r.OrderId,Subscription__r.SBQQ__Contract__r.SBQQ__Order__c,  Subscription__r.VasPracticeCode__c 
        FROM case];  

        Test.startTest();
        HDT_UTL_VasManagement.HDT_WRP_VASActivationReq actReq = HDT_UTL_VasManagement.getActivationRequest(orderList[0].id);
        String actReqString = JSON.serialize(actReq);
        System.assertEquals(true,actReqString.contains(orderList1[0].ShippingMail__c),'The object has the good value of the field');
        System.assertNotEquals(false,actReqString.contains(JSON.serialize(orderList1[0].SignedDate__c)),'The object has the good value of the field');

        HDT_UTL_VasManagement.HDT_WRP_VASDisactivationReq disactReq = HDT_UTL_VasManagement.getDeactivationRequest(caseList[0].id);
        String disactReqString = JSON.serialize(disactReq);
		System.assertEquals(true,disactReqString.contains(orderList1[0].ContractReference__r?.SAPContractCode__c),'The object has the good value of the field');
        System.assertNotEquals(false,disactReqString.contains(caseList[0].VasStatus__c),'The object has the good value of the field');

        Test.stopTest();

        /*
        *Modified by Edoardo Zanatta
        *date 11/05/2022
        */
    }

    /*
     * Created by Edoardo Zanatta
     * @date 12/05/2022
     * @description test method for updateVasPhase method
     */
    @isTest
    static void testUpdateVasPhase(){

        List<Order> orderList = [SELECT id, Phase__c, VASType__c, ComfortCallDaysDue__c, IsEarlyActivation__c FROM Order WHERE Name= 'testOrder1'];
        List<Order> orderListTwo = [SELECT id, Phase__c, VASType__c, IsEarlyActivation__c, ComfortCallDaysDue__c FROM Order WHERE Name = 'testOrder2' AND ComfortCallDaysDue__c = null];
        List<Order> orderListTree = [SELECT id, VASType__c, Phase__c, IsEarlyActivation__c, ComfortCallDaysDue__c FROM Order WHERE Name = 'testOrder4'];
        List<Order> orderListFour = [SELECT id, VASType__c, Phase__c, IsEarlyActivation__c, ComfortCallDaysDue__c FROM Order WHERE Name = 'testOrder5'];

        Test.startTest();
        //Test for the case vasPhase == 'Esportazione VS Siebel'
        String strinResult = HDT_UTL_VasManagement.updateVasPhase('Esportazione VS Siebel', orderList[0]);
        System.assertEquals('Esportazione VS Siebel', strinResult, 'testUpdateVasPhase did not work correctly');
        //Test for the case ord.ComfortCallDaysDue__c != null
        String strinResultTwo = HDT_UTL_VasManagement.updateVasPhase('Esito OK da SII', orderList[0]);
        System.assertEquals('In attesa conferma cliente', strinResultTwo, 'testUpdateVasPhase did not work correctly');
        //Test for the case ord.VASType__c == 'VAS Servizio' && !ord.IsEarlyActivation__c 
        String strinResultTree = HDT_UTL_VasManagement.updateVasPhase('Esito OK da SII', orderListTwo[0]);
        System.assertEquals('In attesa tempi di ripensamento', strinResultTree, 'testUpdateVasPhase did not work correctly');
        //Test for the case ord.VASType__c == 'VAS Fatturabili'
        String strinResultFour = HDT_UTL_VasManagement.updateVasPhase('Esito OK da SII', orderListTree[0]);
        System.assertEquals('Comunicazione verso Heroku', strinResultFour, 'testUpdateVasPhase did not work correctly');
        //Test for the case else
        String strinResultFive = HDT_UTL_VasManagement.updateVasPhase('Esito OK da SII', orderListFour[0]);
        System.assertEquals('Comunicazione Motore VAS', strinResultFive, 'testUpdateVasPhase did not work correctly');

        Test.stopTest();

    }

    /*
     * Created by Edoardo Zanatta
     * @date 12/05/2022
     * @description test method for getDeactivationRequest Exception e
     */
    @isTest 
    static void getMapTest() {
        List<Case> caseList =[SELECT id, Order__c,CaseNumber,VasStatus__c,Asset.SBQQ__OrderProduct__r.OrderId,Subscription__r.SBQQ__Contract__r.SBQQ__Order__c,  Subscription__r.VasPracticeCode__c 
        FROM case WHERE VasStatus__c=null ]; 

        Test.startTest();

        HDT_UTL_VasManagement.HDT_WRP_VASDisactivationReq disactReq = HDT_UTL_VasManagement.getDeactivationRequest(caseList[0].id);
        String disactReqString = JSON.serialize(disactReq);
		System.assertEquals(true,disactReqString.length() > 1,'The object has the good value of the field');

        Test.stopTest();

    }

}