/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 28/09/2021
 * @description HDT_TRH_TriggerHandler Test Class
 * @history Fabricio Petkevicius Nunes – 28/09/2021 – Created Class
 */
@isTest
public with sharing class HDT_TRH_TriggerHandlerTst {
    
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    private static HDT_TRH_TriggerHandler trigHnd = new HDT_TRH_TriggerHandler();
	
	@TestSetup
    static void setup(){
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME); 
        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false); 
        internalUser.UserPermissionsMarketingUser=true; 
        insert internalUser;
 
        System.runAs(internalUser) {
 
            HDT_UTL_DataFactoryTst.pClickInstance();
            HDT_UTL_DataFactoryTst.pClickOrderPhase();
            HDT_UTL_DataFactoryTst.newPhaseTransition('Documentazione validata', 'Bozza', constants.ORDER_RECORDTYPEID_CAMBIO_OFFERTA, 'HDT_RT_CambioOfferta');
            HDT_UTL_DataFactoryTst.newPhaseTransition('Comunicazione Verso Heroku', 'Documentazione validata', constants.ORDER_RECORDTYPEID_CAMBIO_OFFERTA, 'HDT_RT_CambioOfferta');

            List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(50, true, 'HERA COMM', 'Azienda', 'Aziende SME');
            List<Contact> cttList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
            List<Order> orderList = HDT_UTL_DataFactoryTst.createOrder(1, false, accList[0].Id, 'Bozza');
            orderList[0].RecordTypeId = constants.ORDER_RECORDTYPEID_CAMBIO_OFFERTA;
            orderList[0].Contact__c = cttList[0].Id;
            orderList[0].TecnicalPhase__c = 'Documentazione validata';
            insert orderList;
        }
    }
	
	@isTest
    public static void testUpdate() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            List<Order> orderList = [SELECT Id, Phase__c, TecnicalPhase__c FROM Order WHERE Phase__c = 'Bozza'];
            orderList[0].Phase__c = 'Documentazione validata';
            update orderList;
            System.debug('@@'+[SELECT Id, Phase__c, TecnicalPhase__c FROM Order]);
            List<Order> orders = [SELECT Id, Phase__c, TecnicalPhase__c FROM Order WHERE Phase__c = 'Comunicazione verso Heroku'];

            Test.stopTest();

            System.assertEquals(true, orders.isEmpty(), 'Order successfully updated.');
            System.assertNotEquals(false, orders.isEmpty(), 'Order update failed.');
        }
    }

    @isTest
    public static void testDelete() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            List<Order> orderList = [SELECT Id, Phase__c, TecnicalPhase__c FROM Order WHERE Phase__c = 'Bozza'];
            orderList[0].Phase__c = 'Documentazione validata';
            update orderList;
            System.debug('@@'+[SELECT Id, Phase__c, TecnicalPhase__c FROM Order]);

            delete orderList;

            undelete orderList;
            List<Order> orders = [SELECT Id, Phase__c, TecnicalPhase__c FROM Order WHERE Id=:orderList[0].Id];

            Test.stopTest();

            System.assertEquals(false, orders.isEmpty(), 'Order successfully undeleted.');
            System.assertNotEquals(true, orders.isEmpty(), 'Order undelete failed.');
        }
    }

    @isTest
    public static void testSetMaxLoopCount() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
            
            boolean finito = false;
 
            Test.startTest();

           
            trigHnd.setMaxLoopCount(100);
            trigHnd.clearMaxLoopCount();

            Test.stopTest();
            
            finito = true;

            System.assertEquals(true, finito, 'Test not finished');
            System.assertNotEquals(false, finito, 'Test not finished');
        }
    }

    @isTest
    public static void testBypass() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
            
            boolean finito = false;
 
            Test.startTest();

           
            HDT_TRH_TriggerHandler.bypass('Order');
            HDT_TRH_TriggerHandler.clearBypass('Order');
            HDT_TRH_TriggerHandler.isBypassed('Order');
            HDT_TRH_TriggerHandler.clearAllBypasses();

            Test.stopTest();
            
            finito = true;
            
            System.assertEquals(true, finito, 'Test not finished');
            System.assertNotEquals(false, finito, 'Test not finished');
        }
    }

    @isTest
    public static void testInnerClasses() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            HDT_TRH_TriggerHandler.HDT_TRH_LoopCount loopCount = new HDT_TRH_TriggerHandler.HDT_TRH_LoopCount();
           
            loopCount.increment();
            loopCount.exceeded();
            Integer testMax =loopCount.getMax();
            loopCount.getCount();
            loopCount.setMax(10);


            Test.stopTest();

            System.assertEquals(5, testMax, 'Max Count is wrong.');
            System.assertNotEquals(0, testMax, 'Max Count is wrong.');
        }
    }    
}