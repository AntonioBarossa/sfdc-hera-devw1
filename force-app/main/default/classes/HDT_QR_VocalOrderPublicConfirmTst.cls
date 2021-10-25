/**
* @author Andrea Arosio (andrea.arosio@webresults.it)
* @date 12/10/2021
* @description Test Class for HDT_QR_VocalOrderPublicConfirm
*/
@isTest
public with sharing class HDT_QR_VocalOrderPublicConfirmTst {
    @testSetup
    static void setup() {
        final String PHASE_INC = 'Bozza';
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, PHASE_INC);
        HDT_UTL_DataFactoryTst.createVocalOrderPublicConfirm(1, true, '', ordList[0].Id);
    }

    @isTest
    public static void testGetVocalPublicConfirm() {

        Test.startTest();

        Order order = [SELECT Id, Name FROM Order WHERE Name = 'testOrderName0' LIMIT 1];
        List<VocalOrderPublicConfirm__c> vopc = HDT_QR_VocalOrderPublicConfirm.getVocalPublicConfirm(order.ID);
        System.assertNotEquals(null, vopc[0].ID, 'There should be at least one VocalOrderPublicConfirm associated to Order:'+Order.ID);

        Test.stopTest();
    }
}