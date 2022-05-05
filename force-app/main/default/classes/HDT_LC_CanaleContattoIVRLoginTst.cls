@isTest
public with sharing class HDT_LC_CanaleContattoIVRLoginTst {
    
    @TestSetup
    static void setup(){
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> orderList = HDT_UTL_DataFactoryTst.createOrder(1, false, accList[0].Id, 'Bozza');
        orderList[0].Username__c = 'Username';
        orderList[0].Password__c = 'Password';
        insert orderList;
        
    }

    @isTest
    public static void testcheckLogin(){
        
        Test.startTest();
        Order orderRetrieved = HDT_LC_CanaleContattoIVRLogin.checkLogin('Username', 'Password');
        Test.stopTest();
        System.assertNotEquals(null, orderRetrieved, 'Nessun Order recuperato.');
    }
}
