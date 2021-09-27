/**
 * @author Sabina Levonja (sabina.levonja@dunegroup.it)
 * @date 23/09/2021
 * @description HDT_SRV_SalesCriteriaManager Test Class
 * @history Sabina Levonja – 23/09/2021 – Created Class
 */
@isTest
public with sharing class HDT_SRV_SalesCriteriaManagerTst {
    @TestSetup
    static void setup(){
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        List<Account> accList=HDT_UTL_DataFactoryTst.createAccountResidenziale(1, true, 'HERA COMM', 'D1 - Persona fisica', 'Enti');
        List<Contact> conList = HDT_UTL_DataFactoryTst.createContact(1,true,accList[0].Id);
        Id conId =  conList[0].Id;
        List<Order> orderList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].Id, 'Bozza');
        orderList[0].Phase__c = 'Annullato';
        orderList[0].Contact__c = conId;
        orderList[0].ProcessType__c = 'Cambio Offerta Ele';
        update orderList;
    }
    
    @isTest
    public static void testEvaluate() {
        
        Test.startTest();
        Order ord= [SELECT Id,Phase__c,PhaseStory__c
                     FROM Order LIMIT 1];
        Map<String,Object> argsMap = new Map<String,Object>{'method' =>'notExecWorks',
            												'record' => ord};
		HDT_SRV_SalesCriteriaManager sCriteria= new HDT_SRV_SalesCriteriaManager();
		boolean res= sCriteria.evaluate(argsMap);
        Test.stopTest();

        System.assertEquals(true, res, 'The Phase of the order has never been Dati Tecnici Ricevuti');

    }
}