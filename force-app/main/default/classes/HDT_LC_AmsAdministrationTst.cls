@isTest
public with sharing class HDT_LC_AmsAdministrationTst {

    @TestSetup
    static void setup(){

        HDT_UTL_Constants constants = new HDT_UTL_Constants();
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();


        List<Account> accList=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'D1 - Persona fisica', 'Enti');
        List<Order> orderList=HDT_UTL_DataFactoryTst.createOrder(4, false, accList[0].Id, 'Bozza');
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

        /* Activity Creation */
        List<wrts_prcgvr__Activity__c> actToCreate = HDT_UTL_DataFactoryTst.createActivityWithParams(1, true, accList[0].Id, new Map<String, Object>{
            'Type__c' => 'Scarto Transitorio',
            'wrts_prcgvr__Status__c' => 'Aperta',
            'Order__c' => orderToSequenzialize[1].Id
        });
        
        /* User Creation */
        Profile p = [SELECT Id FROM Profile WHERE Name= 'System Administrator'];
        User u = new user(alias = 'test123', email='test@test.com',
            emailencodingkey='UTF-8', firstName='AMS', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p.Id, country='Italy',
            timezonesidkey='Europe/Berlin', username='testAmsAdministrationHera2@ams.com');
        insert u;
    }

    @isTest
    static void fetchConfigurationsTst(){
        User u = [SELECT Id FROM User WHERE Username = 'testAmsAdministrationHera2@ams.com'];
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'HDT_AmsAdministration'];
        PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id);
        insert psa; 
        System.runAs(u){
            AmsAdministration__c amsAdm = new AmsAdministration__c();
            amsAdm.Process__c = 'SEQUENZIALIZZAZIONE_ORDERS';
            amsAdm.Status__c = 'PENDING';
            insert amsAdm;

            Test.startTest();
                String result = HDT_LC_AmsAdministration.fetchConfigurations();
            Test.stopTest();

            Assert.areEqual(true, String.isNotBlank(result), 'Configurazioni non generate correttamente');
        }
    }
    @isTest
    static void initializeOperation(){
        User u = [SELECT Id FROM User WHERE Username = 'testAmsAdministrationHera2@ams.com'];
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'HDT_AmsAdministration'];
        PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id);
        insert psa; 
        System.runAs(u){

            Test.startTest();
                String result = HDT_LC_AmsAdministration.initializeOperation('SEQUENZIALIZZAZIONE_ORDERS','HDT_UTL_AmsOrderDependencies');
            Test.stopTest();

            Assert.areEqual(true, String.isNotBlank(result), 'Configurazioni non generate correttamente');
        }
    }
    @isTest
    static void isOperationPending(){
        User u = [SELECT Id FROM User WHERE Username = 'testAmsAdministrationHera2@ams.com'];
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'HDT_AmsAdministration'];
        PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id);
        insert psa; 
        System.runAs(u){
            AmsAdministration__c amsAdm = new AmsAdministration__c();
            amsAdm.Process__c = 'SEQUENZIALIZZAZIONE_ORDERS';
            amsAdm.Status__c = 'PENDING';
            insert amsAdm;

            Test.startTest();
                Boolean result = HDT_LC_AmsAdministration.isOperationPending();
            Test.stopTest();

            Assert.areEqual(true, result, 'Record AmsAmd non creato correttamente');
        }
    }

}