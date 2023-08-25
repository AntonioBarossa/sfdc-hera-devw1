@isTest
public with sharing class HDT_UTL_AmsOrderDependenciesTst {

    @TestSetup
    static void setup(){

        HDT_UTL_Constants constants = new HDT_UTL_Constants();
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();


        List<Account> accList=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'D1 - Persona fisica', 'Enti');
        List<Order> orderList=HDT_UTL_DataFactoryTst.createOrder(6, false, accList[0].Id, 'Bozza');
        /* Phase Transitions */
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Sequenzializzato', 'Esportazione VS Siebel', constants.ORDER_RECORDTYPEID_VAS, constants.ORDER_RECORDTYPE_DEVELOPERNAME_VAS,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Sequenzializzato', 'Caricamento Siebel KO', constants.ORDER_RECORDTYPEID_VAS, constants.ORDER_RECORDTYPE_DEVELOPERNAME_VAS,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Esportazione VS Siebel', 'Sequenzializzato', constants.ORDER_RECORDTYPEID_VAS, constants.ORDER_RECORDTYPE_DEVELOPERNAME_VAS,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Completata', 'Bozza', constants.ORDER_RECORDTYPEID_SWITCHIN, constants.ORDER_RECORDTYPE_DEVELOPERNAME_SWITCHIN,'A','','','');
        /* Related Order */
        List<Order> relatedOrder = new List<Order>();
        orderList[0].ProcessType__c = 'Switch in Ele';
        orderList[0].RecordTypeId = constants.ORDER_RECORDTYPEID_SWITCHIN;
        orderList[1].ProcessType__c = 'Switch in Ele';
        orderList[1].RecordTypeId = constants.ORDER_RECORDTYPEID_SWITCHIN;
        relatedOrder.add(orderList[0]);
        relatedOrder.add(orderList[1]);
        insert relatedOrder;

        /* Test Sequenzializzazione */
        List<Order> orderToSequenzialize = new List<Order>();
        orderList[2].ProcessType__c = 'VAS';
        orderList[2].Phase__c = 'Esportazione VS Siebel';
        orderList[2].isTransition__c = true;
        orderList[2].OrderReference__c = relatedOrder[0].Id;
        orderList[2].RecordTypeId = constants.ORDER_RECORDTYPEID_VAS;
        orderList[3].ProcessType__c = 'VAS';
        orderList[3].Phase__c = 'Caricamento Siebel KO';
        orderList[3].isTransition__c = true;
        orderList[3].OrderReference__c = relatedOrder[1].Id;
        orderList[3].RecordTypeId = constants.ORDER_RECORDTYPEID_VAS;
        orderToSequenzialize.add(orderList[2]);
        orderToSequenzialize.add(orderList[3]);
        insert orderToSequenzialize;

        /* Test Desequenzializzazione */
        List<Order> orderToDesequenzialize = new List<Order>();
        orderList[4].ProcessType__c = 'VAS';
        orderList[4].Phase__c = 'Sequenzializzato';
        orderList[4].isTransition__c = true;
        orderList[4].OrderReference__c = relatedOrder[0].Id;
        orderList[4].RecordTypeId = constants.ORDER_RECORDTYPEID_VAS;
        orderList[4].CommercialProduct__c = 'HERA LAMPADINA';
        orderList[4].VasSubtype__c = 'VAS Prodotto';
        orderList[5].ProcessType__c = 'VAS';
        orderList[5].Phase__c = 'Sequenzializzato';
        orderList[5].isTransition__c = true;
        orderList[5].OrderReference__c = relatedOrder[1].Id;
        orderList[5].RecordTypeId = constants.ORDER_RECORDTYPEID_VAS;
        orderList[5].CommercialProduct__c = 'HERA LAMPADINA';
        orderList[5].VasSubtype__c = 'VAS Prodotto';
        orderToDesequenzialize.add(orderList[4]);
        orderToDesequenzialize.add(orderList[5]);
        insert orderToDesequenzialize;

        /* Activity Creation */
        List<wrts_prcgvr__Activity__c> actToCreate = HDT_UTL_DataFactoryTst.createActivityWithParams(1, true, accList[0].Id, new Map<String, Object>{
            'Type__c' => 'Scarto Transitorio',
            'wrts_prcgvr__Status__c' => 'Aperta',
            'Order__c' => orderToSequenzialize[1].Id
        });

        /* Service Request Creation */
        List<ServiceRequest__c> srToCreate = HDT_UTL_DataFactoryTst.createServiceRequest(2, false);
        srToCreate[0].Order__c = orderToDesequenzialize[0].Id;
        srToCreate[1].Order__c = orderToDesequenzialize[1].Id;
        insert srToCreate;
        
        /* User Creation */
        Profile p = [SELECT Id FROM Profile WHERE Name= 'System Administrator'];
        User u = new user(alias = 'test123', email='test@test.com',
            emailencodingkey='UTF-8', firstName='AMS', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p.Id, country='Italy',
            timezonesidkey='Europe/Berlin', username='testAmsAdministrationHera@ams.com');
        insert u;



    }

    @isTest
    static void sequenzializationTst(){
        User u = [SELECT Id FROM User WHERE Username = 'test@ams.com'];
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'HDT_AmsAdministration'];
        PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id);
        insert psa; 
        //HDT_UTL_AmsOrderDependencies testClass = new HDT_UTL_AmsOrderDependencies();
        System.runAs(u){
            Test.startTest();
                Database.executeBatch(new HDT_BA_AmsAdministration('SEQUENZIALIZZAZIONE_ORDERS','HDT_UTL_AmsOrderDependencies'));
            Test.stopTest();

            List<wrts_prcgvr__Activity__c> actToTest = [SELECT Id FROM wrts_prcgvr__Activity__c WHERE wrts_prcgvr__Status__c = 'Chiusa'];
            List<Order> orderToTest = [SELECT Id FROM Order WHERE Phase__c = 'Sequenzializzato' AND VasSubtype__c = NULL];
            
            Assert.areEqual(true, !actToTest.isEmpty(), 'Attivita non chiuse correttamente');
            Assert.areEqual(true, orderToTest.size() == 2, 'Ordini non aggiornati correttamente');
        }
    }

    @isTest
    static void desequenzializationTst(){
        User u = [SELECT Id FROM User WHERE Username = 'test@ams.com'];
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'HDT_AmsAdministration'];
        PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id);
        insert psa; 
        //HDT_UTL_AmsOrderDependencies testClass = new HDT_UTL_AmsOrderDependencies();
        System.runAs(u){
        //HDT_UTL_AmsOrderDependencies testClass = new HDT_UTL_AmsOrderDependencies();
        /* Update Related Order */
            List<Order> orderToUpdate = [SELECT Id, Phase__c FROM Order WHERE ProcessType__c = 'Switch in Ele'];
            for(Order o : orderToUpdate)
            {
                o.Phase__c = 'Completata';
            }
            update orderToUpdate;

            Test.startTest();
                Database.executeBatch(new HDT_BA_AmsAdministration('DESEQUENZIALIZZAZIONE_ORDERS','HDT_UTL_AmsOrderDependencies'));
            Test.stopTest();

            List<ServiceRequest__c> srToTest = [SELECT Id FROM ServiceRequest__c ];
            List<Order> orderToTest = [SELECT Id FROM Order WHERE Phase__c = 'Esportazione VS Siebel' AND VasSubtype__c = 'VAS Prodotto'];

            Assert.areEqual(true, srToTest.isEmpty(), 'ServiceRequest non eliminate correttamente');
            Assert.areEqual(true, orderToTest.size() == 2, 'Ordini non aggiornati correttamente');
        }
    }

}