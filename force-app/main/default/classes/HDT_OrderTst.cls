@isTest
public with sharing class HDT_OrderTst {

    @isTest
    public static void orderTest() {

        List<Account> testAcc = HDT_UTL_DataFactoryTst.createAccountPartner(1,false, 'Pooyan');
        testAcc[0].CompanyOwner__c = 'HERA COMM';
        insert testAcc;

        id acctId = testAcc[0].id;

        List<Order> orderTest = HDT_UTL_DataFactoryTst.createOrder(1, true, acctId , 'Bozza');
        
        system.assertEquals(true, orderTest[0].Id != null , 'Order was not inserted correctly');
        system.assertNotEquals(true,  orderTest[0].Id == null , 'The Id of the inserted Order is null');

    }
}
