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

        List<Order> orderTest = HDT_UTL_DataFactoryTst.createOrder(1, true, acct.Id , 'Bozza');
        
        system.assertEquals(true, orderTest[0].Id != null , 'Order was not inserted correctly');
        system.assertNotEquals(true,  orderTest[0].Id == null , 'The Id of the inserted Order is null');

    }
}
