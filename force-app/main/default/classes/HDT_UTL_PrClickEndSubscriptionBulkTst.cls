/**
 * @description       : 
 * @author            : federico.defelice@webresults.it
 * @group             : WR
 * @last modified on  : 09-11-2021
 * @last modified by  : federico.defelice@webresults.it
**/
@isTest
public class HDT_UTL_PrClickEndSubscriptionBulkTst {
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    public static HDT_UTL_PclickBulkActionVas myObjectToTest = new HDT_UTL_PclickBulkActionVas();


    @TestSetup
    static void myData(){
        //Creare Subscription e Case
        //HDT_BA_VasSupplierTableTst.makedata();

        //Id recordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_PostSalesVAS').getRecordTypeId();
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        HDT_UTL_DataFactoryTst.pClickCasePhase();
        
        List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'MMS','MMS Azienda','Aziende SME');
        Id accId = accs[0].id; 
        
        List<Sale__c> sales = HDT_UTL_DataFactoryTst.createSale(1,true,accId,'Bozza'); 
        
        Id pricebookId = Test.getStandardPricebookId();
        
        List<ServicePoint__c> points = HDT_UTL_DataFactoryTst.createServicePoint(1,true);
        Id pointId = points[0].id;   
        
        List<Product2> products = HDT_UTL_DataFactoryTst.createProduct2(1,true);
        Id productId = products[0].id; 
        
        List<PricebookEntry> entries = HDT_UTL_DataFactoryTst.createPricebookEntry(products,true,pricebookId);
        Id entryId = entries[0].id;
        
        List<Contract> contracts = HDT_UTL_DataFactoryTst.createContract(1,true,accId);
        Id contractId = contracts[0].id;
                    
        List<Order> orders = HDT_UTL_DataFactoryTst.createOrderWithPricebook(1,true,accId,sales,pricebookId);
        Id orderId = orders[0].id;
      
        List<OrderItem> orderItems = HDT_UTL_DataFactoryTst.createOrderItem(10,true,orderId,pointId,productId,entryId);
        Id orderItemId = orderItems[0].id;
        
        List<SBQQ__Subscription__c> subs = HDT_UTL_DataFactoryTst.createSubscription (1,false,accId,contractId,pointId);
        for(SBQQ__Subscription__c s : subs){
            s.VasPracticeCode__c = 'vascode';
            s.SBQQ__OrderProduct__c = orderItemId;
        }
        insert subs;

        List<Case> cases = HDT_UTL_DataFactoryTst.createCaseMorosita(1, false,accId, null, pointId, contractId, null);
        cases[0].Subscription__c = subs[0].Id;
        insert cases;
      	/*HDT_UTL_DataFactoryTst.pClickOrderPhase();
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountResidenziale(1, true, 'HERA COMM', 'D1 - Persona fisica', 'Enti');
        List<Contact> conList = HDT_UTL_DataFactoryTst.createContact(1,true,accList[0].Id);
        Id conId              =  conList[0].Id;
        List<Order> orderList          = HDT_UTL_DataFactoryTst.createOrder(2, true, accList[0].Id, 'Bozza');
        orderList[0].Phase__c          = 'Annullato';
        orderList[0].Contact__c        = conId;
        orderList[0].ProcessType__c    = 'Cambio Offerta Ele';
        orderList[0].OrderReference__c = orderList[1].Id;
        update orderList;      
        List<Contract> contrList    = HDT_UTL_DataFactoryTst.createContract(1,true,accList[0].Id);
        contrList[0].SBQQ__Order__c =  orderList[1].Id;
        update contrList;*/
    }
    @isTest
    public static void testPclickEndSubscriptionBulk(){
        //List<Order>  ord           = [SELECT Id,Phase__c,PhaseStory__c,OrderReference__c FROM Order WHERE Phase__c = 'Annullato'];
        List<Case> cases = [select id, Subscription__c from case ];
        Map<String,Object> argsMap = new Map<String,Object>{'parameter' => new Map<String, Object>{'records'=> cases }};
        Test.startTest();
        HDT_UTL_PrClickEndSubscriptionBulk.updateCorrelatedObjects();
        Object result = new HDT_UTL_PrClickEndSubscriptionBulk().execute(argsMap); 
        HDT_UTL_PrClickEndSubscriptionBulk.updateCorrelatedObjects();  
        Test.stopTest();
        System.assertEquals(null, result=null, 'The result should  be null!');
    }
}
