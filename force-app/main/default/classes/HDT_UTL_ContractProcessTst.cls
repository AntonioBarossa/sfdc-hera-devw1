/**
* @author 'Keltin Mesonjesi' (keltin.mesonjesi@protonmail.ch);
* @date 19/04/2020
* @description Class HDT_UTL_ContractProcess.cls
* @history Lucas da Silva Fernandes – 19/04/2020 – Updated Header
*/

@isTest
public with sharing class HDT_UTL_ContractProcessTst {

    @TestSetup
    static void setup(){

        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<BillingProfile__c> bpList = HDT_UTL_DataFactoryTst.createBillingProfile(1, true, accList[0].Id);
        List<ServicePoint__c> spList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);

        List<Order> orderList = HDT_UTL_DataFactoryTst.createOrder(1, false, accList[0].Id, 'Bozza');
        orderList[0].BillingProfile__c = bpList[0].Id;
        orderList[0].ServicePoint__c = spList[0].Id;
        insert orderList;

        List<Contract> cttList = HDT_UTL_DataFactoryTst.createContract(1, false, accList[0].Id);
        cttList[0].SBQQ__Order__c = orderList[0].Id;
        insert cttList;
    }

    @isTest
    public static void testOrderCompletataPhaseManagement() {

        Test.startTest();

        List<Contract> cttList = [SELECT Id, SBQQ__Order__c, BillingProfile__c FROM Contract WHERE SAPContractCode__c='3011913470' LIMIT 1];
        System.debug('cttList: '+cttList);
        List<Order> orderList = [SELECT Id, BillingProfile__c FROM Order WHERE Name = 'testOrderName0' LIMIT 1];
        System.debug('orderList: '+orderList);
        HDT_UTL_ContractProcess.orderCompletataPhaseManagement(cttList);

        System.assertEquals(orderList[0].Id, cttList[0].SBQQ__Order__c, 'Order Id Match');
        System.assertNotEquals(null, cttList[0].SBQQ__Order__c, 'Order Id mismatch');

        Test.stopTest();
    }

    @isTest
    public static void testmoveOut() {

        Test.startTest();

        List<Contract> cttList = [SELECT Id,Status,EndDate FROM Contract LIMIT 1];
        List<Order> orderList = [SELECT Id FROM Order LIMIT 1];
        
        orderList[0].ContractReference__c = cttList[0].Id;

        update orderList;

        HDT_UTL_ContractProcess.moveOut( orderList[0].Id, 'ContractReference__c' );

        cttList = [SELECT Id,Status,EndDate FROM Contract LIMIT 1];

        System.assertEquals(cttList[0].Status, 'Cessato','Status non in Cessato');
        System.assertEquals(cttList[0].EndDate, date.Today(), 'Data non aggiornata ad Oggi correttamente');

        Test.stopTest();
    }

}
