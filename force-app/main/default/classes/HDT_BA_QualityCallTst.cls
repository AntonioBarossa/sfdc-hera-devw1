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
            HDT_UTL_DataFactoryTst.newPhaseTransition('Ammissibilità OK','Bozza',utlConstants.ORDER_RECORDTYPEID_SWITCHIN,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_SWITCHIN);
            HDT_UTL_DataFactoryTst.newPhaseTransition('Comunicazione verso Heroku','Bozza',utlConstants.ORDER_RECORDTYPEID_SWITCHIN,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_SWITCHIN);  
            HDT_UTL_DataFactoryTst.newPhaseTransition('Comunicazione verso Motore VAS','Bozza',utlConstants.ORDER_RECORDTYPEID_SWITCHIN,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_SWITCHIN);  
             
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
            
            List<Order> parentOrders = HDT_UTL_DataFactoryTst.createOrder(2,true,accId,'Bozza');
            Id parentOrderId = parentOrders[0].id;
            parentOrders[0].Contact__c = contactId;
            parentOrders[0].VASType__c = 'VAS Fatturabili';
            parentOrders[0].phase__c = 'Comunicazione verso Heroku';
            parentOrders[0].Status = 'Completed';
            parentOrders[0].recordTypeId = utlConstants.ORDER_RECORDTYPEID_SWITCHIN;
            parentOrders[1].Contact__c = contactId;
            parentOrders[1].VASType__c = 'VAS Fatturabili';
            parentOrders[1].phase__c = 'Comunicazione verso Heroku';
            parentOrders[1].Status = 'Completed';
            parentOrders[1].recordTypeId = utlConstants.ORDER_RECORDTYPEID_SWITCHIN;
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
            orderss[0].WizardCompletedDate__c=date.today().addDays(-60);
            orderss[0].ParentOrder__c = parentOrders[1].Id;
            orderss[0].Channel__c = 'Agenzia';
            orderss[0].Contact__c = contactId;
            orderss[0].QualityCallUnique__c=true;
            orderss[0].AgencyCode__c='001';
            orderss[0].recordTypeId = utlConstants.ORDER_RECORDTYPEID_SWITCHIN;
            orderss[0].Phase__c = 'Ammissibilità OK';
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
            moreOrders[0].Channel__c = 'Agenzia';
            moreOrders[0].recordTypeId = utlConstants.ORDER_RECORDTYPEID_SWITCHIN;
            moreOrders[0].Phase__c = 'Bozza';
            insert moreOrders;
        
            List<Order> ordersToday = HDT_UTL_DataFactoryTst.createOrder(2,false,accId,'Bozza');
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
            ordersToday[0].QualityCallUnique__c=true;
            ordersToday[0].ParentOrder__c = parentOrderId;
            ordersToday[0].Contact__c = contactId;
            ordersToday[0].recordTypeId = utlConstants.ORDER_RECORDTYPEID_SWITCHIN;
            ordersToday[0].VASType__c = 'VAS Fatturabili';
            ordersToday[0].Phase__c = 'Comunicazione verso Heroku';
            ordersToday[0].Channel__c = 'Agenzia';
            
            ordersToday[1].Username__c='test2';
            ordersToday[1].Password__c='test21';
            ordersToday[1].NotRegisteredMeterCase__c=true;
            ordersToday[1].EffectiveDate__c=date.today();
            ordersToday[1].PowerCommitted__c=2;
            ordersToday[1].ImplantType__c='13A0-Usi di Abitazione BT';
            ordersToday[1].RequestOption__c='Domestici-TD';
            ordersToday[1].CreditCheckDescription__c='test2';
            ordersToday[1].QualityCall__c=true;  
            ordersToday[1].ComfortCallDaysDue__c=null;
            ordersToday[1].WizardCompletedDate__c=date.today().addDays(-100);
            ordersToday[1].QualityCallUnique__c=true;
            ordersToday[1].ParentOrder__c = parentOrderId;
            ordersToday[1].Contact__c = contactId;
            ordersToday[1].recordTypeId = utlConstants.ORDER_RECORDTYPEID_SWITCHIN;
            ordersToday[1].VASType__c = 'VAS Fatturabili';
            ordersToday[1].Phase__c = 'Comunicazione verso Heroku';
            ordersToday[1].Channel__c = 'Agenzia';
            insert ordersToday;

            wrts_prcgvr__Activity__c activityVas=new wrts_prcgvr__Activity__c(
                        RecordTypeId = (new  HDT_QR_RecordType()).getRecordType('HDT_RT_AttivitaGestionali', 'wrts_prcgvr__Activity__c').Id,
                        Account__c = ordersToday[0].AccountId,
                        Order__c = ordersToday[0].Id,
                        wrts_prcgvr__Description__c = 'TEST',
                        wrts_prcgvr__Status__c = 'Aperta',
                        Type__c = HDT_UTL_ActivityCustom.ANNULLAMENTO_SIEBEL
                    );
            List<Contract> con = HDT_UTL_DataFactoryTst.createContract(1,true,accId);
            List<ServicePoint__c> sp = HDT_UTL_DataFactoryTst.createServicePoint(1,true);
            HDT_UTL_DataFactoryTst.createCaseDocumentale(1,true,accId,contactId,sp[0].Id,con[0].Id,orderss[0].Id);

            List<Campaign> campaign = HDT_UTL_DataFactoryTst.createCampaign(1,false);
            campaign[0].Name='Quality Campaign';
            campaign[0].CompanyOwner__c ='MMS';
            campaign[0].Tipology__c = 'Quality Call';
            campaign[0].Status = 'In Corso';
            insert campaign;
            
            List<Lead> leads = HDT_UTL_DataFactoryTst.createLead(1, false);
            List<Individual> inds = HDT_UTL_DataFactoryTst.createIndividual(1, false);
            insert inds;
            leads[0].IndividualId=inds[0].id;
            insert leads;

            List<CampaignMember> campaignMember = HDT_UTL_DataFactoryTst.createCampaignMember( false, campaign[0].Id, leads, contacts);
            insert campaignMember;

            List<wrts_prcgvr__Activity__c> activity = HDT_UTL_DataFactoryTst.createActivityCustom(2,false,accId);
            activity[0].order__c=orderss[0].Id;
            activity[0].Type__c='Quality Call';
            activity[0].RecordTypeId = utlConstants.ACTIVITYCUSTOM_RECORDTYPEID_COMFORTQUALITYCALL ;
            activity[0].wrts_prcgvr__Status__c = 'Aperta';
            activity[0].order__c=parentOrders[1].Id;
            activity[0].Type__c='Quality Call';
            activity[0].RecordTypeId = utlConstants.ACTIVITYCUSTOM_RECORDTYPEID_COMFORTQUALITYCALL ;
            activity[0].wrts_prcgvr__Status__c = 'Aperta';
            activity.add(activityVas);
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

    @isTest
    public static void testQualityCallClosed(){
        
        Order ord = [SELECT id FROM Order WHERE WizardCompletedDate__c = TODAY LIMIT 1];
        ord.QualityCallStatus__c='Attività gestita';
        update ord;
        wrts_prcgvr__Activity__c act = [Select id From wrts_prcgvr__Activity__c LIMIT 1];
        act.wrts_prcgvr__Status__c = 'Chiusa';
        act.wrts_prcgvr__IsClosed__c = true;
        act.Order__c = ord.Id;
        update act;
        Test.startTest();
        HDT_BA_QualityCall batch = new HDT_BA_QualityCall();
        Database.executeBatch(batch,200);

        Test.stopTest();
        
        System.assertEquals(1, [Select id From wrts_prcgvr__Activity__c LIMIT 1].size(), 'HDT_BA_QualityCall did not work correctly: wrong amount of custom activities');
        System.assertNotEquals(0, [Select id From wrts_prcgvr__Activity__c LIMIT 1].size() ,'HDT_BA_QualityCall did not work correctly: wrong amount of CampaignMember');
    }

    @isTest
    public static void testOrderToCancel(){
        Order ord = [SELECT id,RecordTypeId, RecordType.DeveloperName FROM Order WHERE Phase__c NOT IN ('In attesa validazione', 'Accettazione Voltura', 'Da Inviare', 'Bozza',  'In attesa conferma cliente', 'Completata','Annullato','Credit Check KO') AND QualityCall__c = true AND ComfortCallDaysDue__c = null AND VasSubtype__c != 'Analisi Consumi' AND QualityCallStatus__c != 'Scadenza Gestita' LIMIT 1];
        HDT_UTL_DataFactoryTst.newPhaseTransition('Esito KO da DL','Ammissibilità OK',ord.RecordTypeId,ord.RecordType.DeveloperName);
            
        ord.QualityCallStatus__c='Attività gestita';
        ord.WizardCompletedDate__c = Date.today().addDays(-100);
        ord.IsVas__c = true;
        ord.Phase__c = 'Esito KO da DL';
        ord.AgencyCode__c = 'TEST';
        update ord;

        insert new AgentMatrix__c(IsMonitoring__c = true,AgencyName__c = 'Name', AgentCode__c = 'TEST',AgencyCode__c = 'TEST');
        
        List<wrts_prcgvr__Activity__c> activities = new List<wrts_prcgvr__Activity__c>();
        wrts_prcgvr__Activity__c act = [SELECT Order__r.Id,Order__r.Phase__c,RecordType.DeveloperName FROM wrts_prcgvr__Activity__c WHERE Type__c = 'Quality Call' AND wrts_prcgvr__Status__c= 'Aperta' LIMIT 1];
        activities.add(new wrts_prcgvr__Activity__c(Id = act.Id, Order__c = ord.Id));
        act = [SELECT id FROM wrts_prcgvr__Activity__c WHERE Order__c = null LIMIT 1]; 
        act.Order__c = ord.Id;
        act.Type__c = 'Ammissibilità KO';
        act.wrts_prcgvr__Status__c= 'Aperta';
        activities.add(act);
        update activities;
        Test.startTest();
        HDT_BA_QualityCall batch = new HDT_BA_QualityCall();
        Database.executeBatch(batch,200);

        Test.stopTest();
        
        System.assertEquals(1, [Select id From wrts_prcgvr__Activity__c WHERE Order__c =:ord.Id AND wrts_prcgvr__Status__c = 'Annullata' AND Type__c = 'Ammissibilità KO'].size(), 'HDT_BA_QualityCall did not work correctly: wrong amount of custom activities');
    }
}