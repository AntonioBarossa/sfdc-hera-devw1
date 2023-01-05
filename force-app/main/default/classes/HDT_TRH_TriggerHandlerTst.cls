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
            orderList[0].IsArchived__c = true;
            update orderList;
            List<Order> orders = [SELECT Id, Phase__c, TecnicalPhase__c FROM Order WHERE IsArchived__c = true];

            Test.stopTest();

            System.assertEquals(false, orders.isEmpty(), 'Order successfully updated.');
            System.assertNotEquals(true, orders.isEmpty(), 'Order update failed.');
        }
    }

    @isTest
    public static void testDelete() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            List<Order> orderList = [SELECT Id, Phase__c, TecnicalPhase__c FROM Order WHERE Phase__c = 'Bozza'];
            orderList[0].IsArchived__c = true;
            update orderList;

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
            
            Test.startTest();
           
            trigHnd.setMaxLoopCount(100);
            trigHnd.clearMaxLoopCount();

            Test.stopTest();

            System.assertEquals(-1, HDT_TRH_TriggerHandler.loopCountMap.get('HDT_TRH_TriggerHandler').getMax(), 'Max has not been cleared');
            System.assertNotEquals(100, HDT_TRH_TriggerHandler.loopCountMap.get('HDT_TRH_TriggerHandler').getMax(), 'Max has not been cleared');
        }
    }

    @isTest
    public static void testBypass() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
            
            Test.startTest();
           
            HDT_TRH_TriggerHandler.bypass('HDT_TRH_Order');
            Boolean bypassed = HDT_TRH_TriggerHandler.isBypassed('HDT_TRH_Order');
            HDT_TRH_TriggerHandler.clearBypass('HDT_TRH_Order');
            Boolean notBypassed = HDT_TRH_TriggerHandler.isBypassed('HDT_TRH_Order');

            HDT_TRH_TriggerHandler.bypass('HDT_TRH_Account');
            HDT_TRH_TriggerHandler.clearAllBypasses();
            Boolean notBypassed2 = HDT_TRH_TriggerHandler.isBypassed('HDT_TRH_Account');

            Test.stopTest();
            
            System.assertEquals(true, bypassed, 'Bypass is not working properly');
            System.assertNotEquals(true, notBypassed, 'Bypass is not working properly');
            System.assertNotEquals(true, notBypassed2, 'Bypass is not working properly');
        }
    }

    @isTest
    public static void testInnerClasses() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            HDT_TRH_TriggerHandler.HDT_TRH_LoopCount loopCount = new HDT_TRH_TriggerHandler.HDT_TRH_LoopCount();
           
            loopCount.setMax(10);
            Integer testMax = loopCount.getMax();
            Boolean exceeded = loopCount.increment();
            Integer testCount = loopCount.getCount();

            loopCount.increment();
            loopCount.setMax(1);
            Boolean testExc = loopCount.exceeded();

            Test.stopTest();

            System.assertEquals(10, testMax, 'Max Count is wrong.');
            System.assertNotEquals(true, exceeded, 'Count is exceeded');
            System.assertEquals(1, testCount, 'Count is wrong');
            System.assertEquals(true, testExc, 'Not Exceeded');
        }
    }    

    /**
    * @description Testing disabilitation with all events disabled
    * @author gabriele.rota@webresults.it | 2021-10-28 
    **/
    @isTest
    public static void testTriggerDisabilitationDisabled() {
        
        HDT_TRH_TriggerHandler triggerInstance = new HDT_TRH_TriggerHandler();

        HDT_AutomationToggle__mdt triggerDis = addTriggerDisabilitation(HDT_TRH_TriggerHandler.JOLLY_CHAR, UserInfo.getUserName(), null);

        triggerInstance.context = HDT_TRH_TriggerHandler.TriggerContext.BEFORE_DELETE;
        Boolean isAutDisabled1 = triggerInstance.isAutomationDisabled(triggerDis.DeveloperName);

        triggerInstance.context = HDT_TRH_TriggerHandler.TriggerContext.AFTER_DELETE;
        Boolean isAutDisabled2 = triggerInstance.isAutomationDisabled(triggerDis.DeveloperName);

        System.assertEquals(true, isAutDisabled1, 'Trigger is not disabled');
        System.assertEquals(true, isAutDisabled2, 'Trigger is not disabled');
    }

    /**
    * @description Testing disabilitation with specific events
    * @author gabriele.rota@webresults.it | 2021-10-28 
    **/
    @isTest
    public static void testTriggerDisabilitationOnlyAfter() {
        
        HDT_TRH_TriggerHandler triggerInstance = new HDT_TRH_TriggerHandler();
        
        HDT_AutomationToggle__mdt triggerDis = addTriggerDisabilitation('after insert; before delete', HDT_TRH_TriggerHandler.JOLLY_CHAR, null);
        
        triggerInstance.context = HDT_TRH_TriggerHandler.TriggerContext.BEFORE_INSERT;
        Boolean isAutDisabled1 = triggerInstance.isAutomationDisabled(triggerDis.DeveloperName);

        triggerInstance.context = HDT_TRH_TriggerHandler.TriggerContext.AFTER_INSERT;
        Boolean isAutDisabled2 = triggerInstance.isAutomationDisabled(triggerDis.DeveloperName);

        System.assertEquals(false, isAutDisabled1, 'Trigger is disabled');
        System.assertEquals(true, isAutDisabled2, 'Trigger is not disabled');
    }

    /**
    * @description Testing disabilitation with expired due date
    * @author gabriele.rota@webresults.it | 2021-10-28 
    **/
    @isTest
    public static void testTriggerDisabilitationExpired() {
        
        HDT_TRH_TriggerHandler triggerInstance = new HDT_TRH_TriggerHandler();
        
        Datetime tenHoursAgo = Datetime.now().addHours(-10);
        HDT_AutomationToggle__mdt triggerDis = addTriggerDisabilitation(HDT_TRH_TriggerHandler.JOLLY_CHAR, HDT_TRH_TriggerHandler.JOLLY_CHAR, tenHoursAgo);
        
        triggerInstance.context = HDT_TRH_TriggerHandler.TriggerContext.BEFORE_UPDATE;
        Boolean isAutDisabled1 = triggerInstance.isAutomationDisabled(triggerDis.DeveloperName);

        triggerInstance.context = HDT_TRH_TriggerHandler.TriggerContext.AFTER_UPDATE;
        Boolean isAutDisabled2 = triggerInstance.isAutomationDisabled(triggerDis.DeveloperName);

        System.assertEquals(false, isAutDisabled1, 'Trigger is disabled');
        System.assertEquals(false, isAutDisabled2, 'Trigger is disabled');
    }

    /**
    * @description Adding trigger disabilitation on Custom Metadata Type (only one per transaction)
    * @author gabriele.rota@webresults.it | 2021-10-28 
    * @param events  
    * @param usernames  
    * @param dueDate  
    * @return HDT_AutomationToggle__mdt 
    **/
    private static HDT_AutomationToggle__mdt addTriggerDisabilitation(String events, String usernames, Datetime dueDate) {
        HDT_AutomationToggle__mdt triggerDis = new HDT_AutomationToggle__mdt();
        triggerDis.DeveloperName = 'HDT_TRH_FakeClassName';
        triggerDis.SkipEvents__c = events;
        triggerDis.SkipUsernames__c = usernames;
        triggerDis.SkipDueDateTime__c = dueDate;

        HDT_TRH_TriggerHandler.disabilitationMap.put(triggerDis.DeveloperName, triggerDis);
        return triggerDis;
    }
}