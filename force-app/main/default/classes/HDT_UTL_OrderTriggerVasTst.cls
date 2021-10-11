/**
 * @author Sabina Levonja (sabina.levonja@dunegroup.it)
 * @date 30/09/2021
 * @description HDT_UTL_OrderTriggerVas Test Class
 * @history Sabina Levonja – 30/09/2021 – Created Class
 */

@isTest
public with sharing class HDT_UTL_OrderTriggerVasTst {

    private static final Id rt= Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_VAS').getRecordTypeId();
    
    @TestSetup
    static void setup(){
        
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        List<Account> accList=HDT_UTL_DataFactoryTst.createAccountResidenziale(1, true, 'HERA COMM', 'D1 - Persona fisica', 'Enti');
		List<Contact> conList = HDT_UTL_DataFactoryTst.createContact(1,true,accList[0].Id);
        List<Order> orders= HDT_UTL_DataFactoryTst.createOrder(2, false,accList[0].Id, 'Bozza');
        orders[0].RecordTypeId= rt;
        orders[0].Contact__c = conList[0].Id;
        insert orders;
	}
    
    @isTest
    public static void testCancelLinkedVasOrders() {

        Test.startTest();

        List<Order> ords = [SELECT Id,AccountId, RecordTypeId, Status, Phase__c FROM Order];
        Id ordId;
        Map<Id,Order> oldOrders= new Map<Id,Order>();
        for(Order o: ords){
            if(o.RecordTypeId!= rt){
                ordId= o.Id;
            }
            oldOrders.put(o.Id,o);
        }
        List<Order> newOrds= [SELECT Id,AccountId, RecordTypeId, Status, Phase__c FROM Order];
        Map<Id,Order> newOrders= new Map<Id,Order>();
        for(Order o: newOrds){
            if(o.RecordTypeId == rt){
                o.OrderReference__c =ordId;
            }else{
              	o.Status='Annullato';
            }
            newOrders.put(o.Id, o);

        }
        update newOrds;
		HDT_UTL_OrderTriggerVas.cancelLinkedVasOrders(newOrders,oldOrders);

        Test.stopTest();

        List<Order> updOrds= [SELECT Id,AccountId, RecordTypeId, Status, Phase__c FROM Order Where RecordTypeId=:rt];
        System.assertEquals('Annullato', updOrds[0].Phase__c,'The phase has been updated');
        System.assertNotEquals('', updOrds[0].Status,'The status is not empty');

    }
}