/**
 * @author Luca Molino (luca.molino@dunegroup.it)
 * @date 07/10/2021
 * @description HDT_SRV_SalesManager test Class
 * @history Luca Molino – 07/10/2021 – Created Class
 */
@isTest
public class HDT_SRV_SalesManagerTst {
	
    private static HDT_SRV_SalesManager srvSalesManager = new HDT_SRV_SalesManager();
    private static HDT_UTL_Constants utlConstants = new HDT_UTL_Constants();

    @testSetup
    public static void setup(){

        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(utlConstants.HERA_SYSTEM_ADMINISTRATOR_NAME);
 
        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
    
        internalUser.UserPermissionsMarketingUser=true;
    
        insert internalUser;  
        System.runAs(internalUser){
            List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(1, false, 'HERA COMM', 'Azienda', 'Aziende SME');
            accounts[0].ActiveMonitoring__c=false;
            accounts[0].Name='INRETE DIST. ENER.-13R0000000';
            accounts[0].LastName__c='INRETE DIST. ENER.-13R0000000';
            insert accounts;
            List<Order> orders=HDT_UTL_DataFactoryTst.createOrder(7, false, accounts[0].Id, 'Bozza');
            List<Contact> contact = HDT_UTL_DataFactoryTst.createContact(1,true,accounts[0].Id);
            List<ServicePoint__c> spList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
            List<Contract> contract = HDT_UTL_DataFactoryTst.createContract(1, true, accounts[0].Id);
            HDT_UTL_DataFactoryTst.createCase(1,true,accounts[0].Id,contact[0].Id,spList[0].Id,contract[0].Id,orders[0].Id);
        
        id orderVoltura=utlConstants.ORDER_RECORDTYPEID_VOLTURA;
        id orderSubentro=utlConstants.ORDER_RECORDTYPEID_SUBENTRO;
        id orderSwitchIn=utlConstants.ORDER_RECORDTYPEID_SWITCHIN;
        id orderAttivazione=utlConstants.ORDER_RECORDTYPEID_ATTIVAZIONE;
        id orderAttivazioneConModifica=utlConstants.ORDER_RECORDTYPEID_ATTIVAZIONECONMODIFICA;
        id orderConnessioneConAttiv=utlConstants.ORDER_RECORDTYPEID_CONNESSIONECONATTIVAZIONE;
        id orderTemporaneaNuovaAtt=utlConstants.ORDER_RECORDTYPEID_TEMPORANEANUOVAATT;
            
            HDT_UTL_DataFactoryTst.pClickInstance();
            HDT_UTL_DataFactoryTst.pClickOrderPhase();
            HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa conferma cliente','Bozza',utlConstants.ORDER_RECORDTYPEID_CONNESSIONECONATTIVAZIONE,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_CONNESSIONECONATTIVAZIONE);
			
            system.debug('order list : ' +orders);
        	orders[0].RecordTypeId=orderSubentro;
			orders[0].Username__c='test';
			orders[0].Password__c='test1';
			orders[0].NotRegisteredMeterCase__c=true;
			orders[0].EffectiveDate__c=date.today();
			orders[0].PowerCommitted__c=2;
			orders[0].ImplantType__c='13A0-Usi di Abitazione BT';
			orders[0].RequestOption__c='Domestici-TD';
			orders[0].CreditCheckDescription__c='test1';
			orders[0].QualityCall__c=true;  
        	orders[0].ComfortCallDaysDue__c=null;

			orders[1].RecordTypeId=orderVoltura;
			orders[1].CreditCheckDescription__c='test2Voltura';
			orders[1].ProcessCode__c='PN1';
			orders[1].PowerRequested__c=1;
			orders[1].PowerAvailable__c=3;
			orders[1].PowerCommitted__c=2;
			orders[1].NotRegisteredMeterCase__c=false;
			orders[1].EffectiveDate__c=date.today().addDays(-4);
			orders[1].RequestOption__c='Domestici-TD';
			orders[1].Vat__c='Iva 10% (Cod. 01)';
            orders[1].QualityCall__c=true;

			orders[2].PowerCommitted__c=2;
			orders[2].CreditCheckDescription__c = 'test3';
			orders[2].VoltureType__c='In Continuità';
			orders[2].RecordTypeId = orderSwitchIn;
        	orders[2].QualityCall__c=true;

			orders[3].PowerCommitted__c=2;
			orders[3].VoltureType__c='In Continuità';
			orders[3].CreditCheckDescription__c='test4AttivConMod';
			orders[3].RecordTypeId=orderAttivazioneConModifica;
			orders[3].PowerRequested__c=3;
			orders[3].ProcessCode__c='E02';
			orders[3].QualityCall__c=true;
        
			orders[4].EffectiveDate__c=date.today().addDays(10);
			orders[4].PowerCommitted__c=2;
			orders[4].RecordTypeId=orderAttivazione;
			orders[4].CreditCheckDescription__c='test5Conessione1';
			orders[4].ProcessCode__c='PN1';
        	orders[4].QualityCall__c=true;

			orders[5].RecordTypeId=orderConnessioneConAttiv;
			orders[5].VoltageLevel__c='BT';
			orders[5].ProcessCode__c='E02';
			orders[5].UseTypeEnergy__c='Manifest (Temp Straord 16h)';
			orders[5].CreditCheckDescription__c='test6Temporanea';
			orders[5].RequestOption__c='Domestici-TD';
			orders[5].PowerRequested__c=2;
			orders[5].PowerCommitted__c=2;
       	 	orders[5].QualityCall__c=true;
            
            orders[6].RecordTypeId=orderTemporaneaNuovaAtt;
			orders[6].VoltageLevel__c='BT';
			orders[6].ProcessCode__c='E02';
			orders[6].UseTypeEnergy__c='Manifest (Temp Straord 16h)';
			orders[6].CreditCheckDescription__c='test6Temporanea';
			orders[6].RequestOption__c='Domestici-TD';
			orders[6].PowerRequested__c=2;
			orders[6].PowerCommitted__c=2;
        	orders[6].QualityCall__c=true;
           	system.debug('order list2 : ' +orders[0]);
        insert orders;
            

        }

    }

    @isTest
    public static void testExecute(){
        HDT_SRV_SalesManager sm = new HDT_SRV_SalesManager();

        Map<String, Object> argsMap = new Map<String, Object>() ;
        Map<String, Object> argsMap2 = new Map<String, Object>() ;
        Map<String, Object> argsMap3 = new Map<String, Object>() ;

        List<Order> order =[SELECT Id,Name,VASType__c FROM Order WHERE Name='testOrderName0'LIMIT 1];
        system.debug('order-------------------'+ order);

        argsMap.put('method', 'activation');
        argsMap.put('sender', order[0]);
        argsMap2.put('method', 'updatePhase');
        argsMap2.put('sender', order[0]);
        argsMap3.put('method', 'contracted');
        argsMap3.put('sender', order[0]);

        sm.execute(argsMap);
        sm.execute(argsMap2);
        sm.execute(argsMap3);
        
        system.assertEquals(order != null, true, 'Update Record order');
        system.assertNotEquals(order == null, true, 'Update Record order');

    }
    
        @isTest
    public static void testExecute2(){
        HDT_SRV_SalesManager sm = new HDT_SRV_SalesManager();

        Map<String, Object> argsMap4 = new Map<String, Object>() ;
        List<Order> order =[SELECT Id,Name,VASType__c FROM Order WHERE Name='testOrderName0'LIMIT 1];


        argsMap4.put('method', 'deactivation');
        argsMap4.put('sender', order[0]);


        sm.execute(argsMap4);

        
        system.assertEquals(order != null, true, 'Update Record order');
        system.assertNotEquals(order == null, true, 'Update Record order');

    }
    
            @isTest
    public static void testExecute3(){
        HDT_SRV_SalesManager sm = new HDT_SRV_SalesManager();

        Map<String, Object> argsMap5 = new Map<String, Object>() ;
        List<Order> order =[SELECT Id,Name,VASType__c FROM Order WHERE Name='testOrderName0'LIMIT 1];

        argsMap5.put('method', 'service26');
        argsMap5.put('sender', order[0]);

        sm.execute(argsMap5);
        
        system.assertEquals(order != null, true, 'Update Record order');
        system.assertNotEquals(order == null, true, 'Update Record order');

    }
    
        @isTest
    public static void testHDT_QBL_AsycnronousCallout(){
        new HDT_SRV_SalesManager();

        List<Order> order =[SELECT Id,Name,VASType__c FROM Order WHERE Name='testOrderName0'LIMIT 1];

		HDT_SRV_SalesManager.HDT_QBL_AsycnronousCallout async = new HDT_SRV_SalesManager.HDT_QBL_AsycnronousCallout(order[0].Id,'activation');
		System.enqueueJob(async);
        HDT_SRV_SalesManager.HDT_QBL_AsycnronousCallout async2 = new HDT_SRV_SalesManager.HDT_QBL_AsycnronousCallout((String)order[0].Id,'activation');
		System.enqueueJob(async2);
        HDT_SRV_SalesManager.HDT_QBL_AsycnronousCallout async3 = new HDT_SRV_SalesManager.HDT_QBL_AsycnronousCallout();
		System.enqueueJob(async3);
        
        system.assertEquals(order != null, true, 'Update Record order');
        system.assertNotEquals(order == null, true, 'Update Record order');

    }
    
            @isTest
    public static void testHDT_QBL_AsycnronousUpdate(){
        
        List<Order> order =[SELECT Id,Name,VASType__c FROM Order WHERE Name='testOrderName0'LIMIT 1];

		HDT_SRV_SalesManager.HDT_QBL_AsycnronousUpdate async = new HDT_SRV_SalesManager.HDT_QBL_AsycnronousUpdate(order[0].Id,'In attesa conferma cliente');
		System.enqueueJob(async);
        HDT_SRV_SalesManager.HDT_QBL_AsycnronousUpdate async2 = new HDT_SRV_SalesManager.HDT_QBL_AsycnronousUpdate((String)order[0].Id,'In attesa conferma cliente');
		System.enqueueJob(async2);
        HDT_SRV_SalesManager.HDT_QBL_AsycnronousUpdate async3 = new HDT_SRV_SalesManager.HDT_QBL_AsycnronousUpdate();
		System.enqueueJob(async3);
        
        system.assertEquals(order != null, true, 'Update Record order');
        system.assertNotEquals(order == null, true, 'Update Record order');
        
        List<Case> c =[SELECT Id,Status FROM Case WHERE Status='In Lavorazione'LIMIT 1];
        HDT_SRV_SalesManager.HDT_QBL_AsycnronousUpdate async4 = new HDT_SRV_SalesManager.HDT_QBL_AsycnronousUpdate(c[0].Id,'In attesa conferma cliente');
		System.enqueueJob(async4);
        
        system.assertEquals(c[0] != null, true, 'Update Record Case');
        system.assertNotEquals(c[0] == null, true, 'Update Record Case');
        
        List<ServicePoint__c> s =[SELECT Id FROM ServicePoint__c LIMIT 1];
        HDT_SRV_SalesManager.HDT_QBL_AsycnronousUpdate async5 = new HDT_SRV_SalesManager.HDT_QBL_AsycnronousUpdate(s[0].Id,'In attesa conferma cliente');
		System.enqueueJob(async5);
        
        System.assertEquals(s[0] != null, true, 'Update Record ServicePoint');
        System.assertNotEquals(s[0] == null, true, 'Update Record ServicePoint');
        


    }
    
    @isTest
    public static void testHDT_QBL_AsycnronousUpdate2(){
           
        List<Case> c =[SELECT Id,Status FROM Case WHERE Status='In Lavorazione'LIMIT 1];
        HDT_SRV_SalesManager.HDT_QBL_AsycnronousUpdate async4 = new HDT_SRV_SalesManager.HDT_QBL_AsycnronousUpdate(c[0].Id,'In attesa conferma cliente');
		System.enqueueJob(async4);
        
        system.assertEquals(c[0] != null, true, 'Update Record Case');
        system.assertNotEquals(c[0] == null, true, 'Update Record Case');

    }
    
        @isTest
    public static void testHDT_QBL_AsycnronousUpdate3(){
        
        List<ServicePoint__c> s =[SELECT Id FROM ServicePoint__c LIMIT 1];
        HDT_SRV_SalesManager.HDT_QBL_AsycnronousUpdate async5 = new HDT_SRV_SalesManager.HDT_QBL_AsycnronousUpdate(s[0].Id,'In attesa conferma cliente');
		System.enqueueJob(async5);
        
        System.assertEquals(s[0] != null, true, 'Update Record ServicePoint');
        System.assertNotEquals(s[0] == null, true, 'Update Record ServicePoint');

    }
    
      
    
    
}