/*
 * @author Laureta Demishaj (laureta.demishaj@dunegroup.it)
 * @date 21/09/2021
 * @description HDT_LC_AccountVasOrdersView for Test Classes
 * @history Laureta Demishaj – 21/09/2021 – Created class
*/
@isTest
public with sharing class HDT_LC_AccountVasOrdersViewTst {
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
  
    @isTest
    public static void getOrdersTst() {
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        Id accountId          = accList[0].Id;
        List<Order> orderList = HDT_UTL_DataFactoryTst.createOrder(1, true, accountId, 'Bozza' );
        
        Test.startTest();
            List<Order> response = HDT_LC_AccountVasOrdersView.getOrders(accountId);
            List<order> expectedResponse = [SELECT Id FROM Order];
            System.assertEquals(expectedResponse, response, 'This method worked when given an Id that has orders');
            System.assertEquals(null, response, 'This method worked when given an Account Id that has orders, the result is not null');
        Test.stopTest();
    }

    @isTest
    public static void runNegativeTestCases(){
        Id minimumAccessProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.MINIMUM_ACCESS_SALESFORCE);
        User minimumAccessUser=HDT_UTL_DataFactoryTst.createInternalUser(minimumAccessProfileId, false);
        minimumAccessUser.Email = 'sales@force.com';
        insert minimumAccessUser;
        System.runAs(minimumAccessUser) {
            List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        Id accountId = accList[0].Id;
        List<Order> orderList = HDT_UTL_DataFactoryTst.createOrder(1, true, accountId, 'Bozza' );
        
        Test.startTest();
        try {
            List<Order> response = new List<Order>();
            response = HDT_LC_AccountVasOrdersView.getOrders(accountId);
            
        } catch (Exception e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'As expected, if the logged user has minimum access the method cant run');
            System.assertNotEquals('', e.getMessage(), 'The exception throws an error message');
        }
            
         
        Test.stopTest();
        
        }

}
}