/**
 * @description       : 
 * @author            : Giacinto Florio
 * @group             : 
 * @last modified on  : 24-08-2022
 * @last modified by  : Giacinto Florio
**/
@isTest
public with sharing class HDT_UTL_SegnalazioniCriteriaTst {
      
    @TestSetup
    static void setup(){

        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
 
    }

    @isTest
    public static void evaluateTest() {
        Order order = [SELECT Id, PhaseStory__c FROM Order LIMIT 1];
        order.PhaseStory__c = '';
        update order;
        HDT_UTL_SegnalazioniCriteria segnalazioniCriteria = new HDT_UTL_SegnalazioniCriteria();
        Map<String, Object> args = new Map<String, Object>();
        args.put('method','not');
        args.put('record',order);

        Test.startTest();
        Boolean result = segnalazioniCriteria.evaluate(args);
        System.assert(result, true);
        Test.stopTest();
    }
}
