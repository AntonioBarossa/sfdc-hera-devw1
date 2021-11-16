/**
 * @author Luca Molino (luca.molino@dunegroup.it)
 * @date 06/09/2021
 * @description HDT_BA_QualityCall test Class
 * @history Luca Molino – 06/10/2021 – Created Class
 */
@isTest
public with sharing class HDT_BA_QualityCallTst {

    private static HDT_UTL_Constants utlConstants = new HDT_UTL_Constants();

    @testSetup
    public static void setup(){

        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(utlConstants.HERA_SYSTEM_ADMINISTRATOR_NAME);
    
        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);

        internalUser.UserPermissionsMarketingUser=true;

        insert internalUser;  
        System.runAs(internalUser){
            
            HDT_UTL_DataFactoryTst.pClickInstance();
            HDT_UTL_DataFactoryTst.pClickOrderPhase();
            HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa conferma cliente','Bozza',utlConstants.ORDER_RECORDTYPEID_CONNESSIONECONATTIVAZIONE,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_CONNESSIONECONATTIVAZIONE);
            List<AgentMatrix__c> agentMatrix = HDT_UTL_DataFactoryTst.createAgentMatrix(1,true,'Sportello') ; 
            agentMatrix[0].IsMonitoring__c=true;
            agentMatrix[0].AgencyCode__c='001';
            List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'MMS','MMS Azienda','Aziende SME');
            Id accId = accs[0].id;
            
            List<Contact> contacts = HDT_UTL_DataFactoryTst.createContact(2,false,accId);
            for(Contact c : contacts) {
                c.Company__c='MMS';
            }
            insert contacts;
            Id contactId = contacts[0].id;
            Id anotherContactId = contacts[1].id;
            
            List<Order> parentOrders = HDT_UTL_DataFactoryTst.createOrder(1,true,accId,'Bozza');
            Id parentOrderId = parentOrders[0].id;
            parentOrders[0].Contact__c = contactId;
            parentOrders[0].phase__c = 'In attesa conferma cliente';
            parentOrders[0].recordTypeId = utlConstants.ORDER_RECORDTYPEID_CONNESSIONECONATTIVAZIONE;
            update parentOrders;
            
            List<Order> orderss = HDT_UTL_DataFactoryTst.createOrder(1,false,accId,'Bozza');
            orderss[0].Username__c='test';
            orderss[0].Password__c='test1';
            orderss[0].NotRegisteredMeterCase__c=true;
            orderss[0].EffectiveDate__c=date.today();
            orderss[0].PowerCommitted__c=2;
            orderss[0].ImplantType__c='13A0-Usi di Abitazione BT';
            orderss[0].RequestOption__c='Domestici-TD';
            orderss[0].CreditCheckDescription__c='test1';
            orderss[0].QualityCall__c=true;  
            orderss[0].ComfortCallDaysDue__c=null;
            orderss[0].WizardCompletedDate__c=date.today()-60;
            orderss[0].ParentOrder__c = parentOrderId;
            orderss[0].Contact__c = contactId;
            orderss[0].QualityCallUnique__c=false;
            orderss[0].AgencyCode__c='001';
            orderss[0].recordTypeId = utlConstants.ORDER_RECORDTYPEID_CONNESSIONECONATTIVAZIONE;
            orderss[0].Phase__c = 'Bozza';
            insert orderss;
            
            List<Campaign> campaigns = HDT_UTL_DataFactoryTst.createCampaign(1,false);
            campaigns[0].Name = 'Comfort Campaign';
            insert campaigns;
            
            List<Order> moreOrders = HDT_UTL_DataFactoryTst.createOrder(1,false,accId,'Bozza');
            moreOrders[0].qualityCall__c = true;
            moreOrders[0].DateComfortCall__c = System.today() - 3;
            moreOrders[0].ComfortCallDaysDue__c = 6.2;
            moreOrders[0].ParentOrder__c = parentOrderId;
            moreOrders[0].Contact__c = anotherContactId;
            moreOrders[0].recordTypeId = utlConstants.ORDER_RECORDTYPEID_CONNESSIONECONATTIVAZIONE;
            moreOrders[0].Phase__c = 'In attesa conferma cliente';
            insert moreOrders;
        
            List<Order> ordersToday = HDT_UTL_DataFactoryTst.createOrder(1,false,accId,'Bozza');
            ordersToday[0].Username__c='test';
            ordersToday[0].Password__c='test1';
            ordersToday[0].NotRegisteredMeterCase__c=true;
            ordersToday[0].EffectiveDate__c=date.today();
            ordersToday[0].PowerCommitted__c=2;
            ordersToday[0].ImplantType__c='13A0-Usi di Abitazione BT';
            ordersToday[0].RequestOption__c='Domestici-TD';
            ordersToday[0].CreditCheckDescription__c='test1';
            ordersToday[0].QualityCall__c=true;  
            ordersToday[0].ComfortCallDaysDue__c=null;
            ordersToday[0].WizardCompletedDate__c=date.today();
            ordersToday[0].QualityCallUnique__c=false;
            ordersToday[0].ParentOrder__c = parentOrderId;
            ordersToday[0].Contact__c = contactId;
            ordersToday[0].recordTypeId = utlConstants.ORDER_RECORDTYPEID_CONNESSIONECONATTIVAZIONE;
            ordersToday[0].Phase__c = 'Bozza';
            insert ordersToday;

            List<Contract> con = HDT_UTL_DataFactoryTst.createContract(1,true,accId);
            List<ServicePoint__c> sp = HDT_UTL_DataFactoryTst.createServicePoint(1,true);
            HDT_UTL_DataFactoryTst.createCaseDocumentale(1,true,accId,contactId,sp[0].Id,con[0].Id,orderss[0].Id);

            List<Campaign> campaign = HDT_UTL_DataFactoryTst.createCampaign(1,false);
            campaign[0].Name='Quality Campaign';
            insert campaign;

            List<wrts_prcgvr__Activity__c> activity = HDT_UTL_DataFactoryTst.createActivityCustom(1,false,accId);
            activity[0].order__c=orderss[0].Id;
            activity[0].RecordTypeId = utlConstants.ACTIVITYCUSTOM_RECORDTYPEID_COMFORTQUALITYCALL ;
            insert activity;

            List<ComfortQualityCall__c> cqcRecords = HDT_UTL_DataFactoryTst.createComfortQualityCall(1, false);
            cqcRecords[0].DocumentValidation__c = true;
            cqcRecords[0].QualityEnabled__c = true;
            insert cqcRecords;
        } 
    }

    @isTest
    public static void testQualityCallExecute(){
        Test.startTest();
        
        HDT_BA_QualityCall batch = new HDT_BA_QualityCall();
        Database.executeBatch(batch,200);

        Test.stopTest();
        
        System.assertEquals(1, [Select id From wrts_prcgvr__Activity__c LIMIT 1].size(), 'HDT_BA_QualityCall did not work correctly: wrong amount of custom activities');
        System.assertNotEquals(0, [Select id From wrts_prcgvr__Activity__c LIMIT 1].size() ,'HDT_BA_QualityCall did not work correctly: wrong amount of CampaignMember');
    }
}