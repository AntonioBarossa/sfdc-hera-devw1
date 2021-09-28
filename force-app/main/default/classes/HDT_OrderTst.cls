@isTest
public with sharing class HDT_OrderTst {

    @isTest
    public static void HDT_OrderTst() {

        List<Account> testAcc = HDT_UTL_DataFactoryTst.createAccountPartner(1,false, 'Pooyan');
        testAcc[0].CompanyOwner__c = 'HERA COMM';

        insert testAcc;

        Account acct = [SELECT id,Name FROM Account WHERE id =: testAcc[0].id ];

       //List<Account> testAcc = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Persona fisica','Famiglie');
       //Account acct = [SELECT id,Name FROM Account WHERE Name =: 'testact'];

        List<Order> orderTest = HDT_UTL_DataFactoryTst.createOrder(1, false, acct.Id , 'Bozza');
        

        

        insert orderTest;


        Order O = [SELECT id,Phase__c FROM Order WHERE id =: orderTest[0].id LIMIT 1];
        
        system.assertEquals('Bozza', orderTest[0].Phase__c , 'Order is inserted correctly');
        system.assertNotEquals('',  orderTest[0].Phase__c , 'is not Empty');

    }
}
