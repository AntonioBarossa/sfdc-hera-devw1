/*
 * @author Laureta Demishaj (laureta.demishaj@dunegroup.it)
 * @date 21/09/2021
 * @description HDT_LC_AccountVasOrdersView for Test Classes
 * @history Laureta Demishaj – 06/10/2021 – Modified assertion messages
*/
@isTest
public with sharing class HDT_LC_AccountVasOrdersViewTst {
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
  
    @isTest
    public static void getOrdersTst() {
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        Order ord = new Order();
        ord.AccountId = accList[0].Id;
        ord.RecordTypeId ='0121X000002NNTaQAO';
        ord.Status = 'In Lavorazione';
        ord.EffectiveDate = Date.today();
        insert ord;
        Test.startTest();
       List<Order> response = HDT_LC_AccountVasOrdersView.getOrders(accList[0].Id);
        Test.stopTest();
        List<order> expectedResponse = [SELECT Id FROM Order];
        System.debug(expectedResponse[0].Id);
        System.debug(response[0].Id);
        System.assertEquals(expectedResponse[0].Id, response[0].Id, 'This method workes when the given account Id has orders');
        System.assertNotEquals(null, response, 'This method workes when the given Account Id has orders, the result is null');
    }
    @isTest
    public static void runNegativeTestCases(){
        Id minimumAccessProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.MINIMUM_ACCESS_SALESFORCE);
        User minimumAccessUser=HDT_UTL_DataFactoryTst.createInternalUser(minimumAccessProfileId, false);
        minimumAccessUser.Email = 'sales@force.com';
        insert minimumAccessUser;
        System.runAs(minimumAccessUser) {
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        Test.startTest();
        try {
            List<Order> response = new List<Order>();
            response = HDT_LC_AccountVasOrdersView.getOrders(accList[0].Id);
        } catch (Exception e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'If the logged user has minimum access the method cant run');
            System.assertNotEquals('', e.getMessage(), 'The exception throws an error message');
        }
        Test.stopTest();
        }
}
}