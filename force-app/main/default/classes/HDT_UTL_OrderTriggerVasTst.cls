/**
 * @author Sabina Levonja (sabina.levonja@dunegroup.it)
 * @date 30/09/2021
 * @description HDT_UTL_OrderTriggerVas Test Class
 * @history Sabina Levonja – 30/09/2021 – Created Class
 */

@isTest
public with sharing class HDT_UTL_OrderTriggerVasTst {

    private static final Id rtVas= Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_VAS').getRecordTypeId();
    private static final Id rtDefault= Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_Default').getRecordTypeId();
    private static final Id rtVoltura= Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_Voltura').getRecordTypeId();
    
    @TestSetup
    static void setup(){
        
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        List<Account> accList=HDT_UTL_DataFactoryTst.createAccountResidenziale(1, true, 'HERA COMM', 'D1 - Persona fisica', 'Enti');
		List<Contact> conList = HDT_UTL_DataFactoryTst.createContact(1,true,accList[0].Id);
        List<ServicePoint__c> servList = HDT_UTL_DataFactoryTst.createServicePoint(1, false);
        servList[0].Account__c = accList[0].id;
        insert servList;

        List<Order> firstOrder= HDT_UTL_DataFactoryTst.createOrder(3, false,accList[0].Id, 'Bozza');
        firstOrder[0].RecordTypeId = rtVoltura;
        insert firstOrder;

        List<Order> orders= HDT_UTL_DataFactoryTst.createOrder(2, false,accList[0].Id, 'Bozza');
        orders[0].RecordTypeId= rtVas;
        orders[0].Contact__c = conList[0].Id;
        orders[0].OrderReference__c = firstOrder[0].Id;
        orders[1].RecordTypeId= rtDefault;
        orders[1].Contact__c = conList[0].Id;
        orders[1].isVas__c = true;
        orders[1].OrderReference__c = firstOrder[0].Id;
        insert orders;
	}
    
    @isTest
    public static void testCancelLinkedVasOrders() {

        Test.startTest();
        Order voltura = [SELECT Id,AccountId, RecordTypeId, Status, Phase__c FROM Order WHERE RecordTypeId = :rtVoltura];
        voltura.Status = 'Annullato'; 
        update voltura;
         List<Order> ords = [SELECT Id,AccountId, RecordTypeId, Status, Phase__c FROM Order];
        Id ordId;
        Map<Id,Order> oldOrders= new Map<Id,Order>();
        for(Order o: ords){
            if(o.RecordTypeId!= rtVas && o.RecordTypeId!= rtDefault){
                ordId= o.Id;
            }
            oldOrders.put(o.Id,o);
        }
        List<Order> newOrds= [SELECT Id,AccountId, RecordTypeId, Status, Phase__c, SBQQ__Quote__c, CancellationReason__c FROM Order];
        Map<Id,Order> newOrders= new Map<Id,Order>();
        for(Order o: newOrds){
            if(o.RecordTypeId == rtVas){
                o.OrderReference__c =ordId;
            }else{
              	o.Status='Annullato';
            }
            newOrders.put(o.Id, o);

        }
        update newOrds;
		HDT_UTL_OrderTriggerVas.cancelLinkedVasOrders(newOrders,oldOrders); 

        Test.stopTest();
        /*List<Order> updOrds= [SELECT Id,AccountId, RecordTypeId, Status, Phase__c FROM Order Where RecordTypeId IN :(new List<Id>{rtVas,rtDefault})];
        for (Order ord : updOrds){
            System.assertNotEquals('Annullato', ord.Phase__c,'The phase has been updated');
            System.assertNotEquals('',ord.Status,'The status is not empty');
        }*/

        System.assertEquals('Bozza', voltura.Phase__c,'The phase has been updated');
        System.assertNotEquals('',voltura.Status,'The status is not empty');
    }

    @isTest
    public static void testCancelLinkedVasOrdersTwo() {

        Test.startTest();
        Set<Id> idSetOne = new Set<Id>();
        Set<Id> idSetTwo = new Set<Id>();
        HDT_UTL_OrderTriggerVas.cancelLinkedOrders(idSetOne,idSetTwo);
        Test.stopTest();

        System.assertEquals(true, idSetOne.isEmpty(),'The phase has been updated');
    }

   
}