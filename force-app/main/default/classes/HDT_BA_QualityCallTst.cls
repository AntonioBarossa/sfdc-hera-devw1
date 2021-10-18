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

        id orderDossier=utlConstants.ORDER_RECORDTYPEID_ORDERDOSSIER;
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
			List<AgentMatrix__c> agentMatrix = HDT_UTL_DataFactoryTst.createAgentMatrix(1,true,'Sportello') ; 
        	agentMatrix[0].IsMonitoring__c=true;
        	agentMatrix[0].AgencyCode__c='001';
            List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'MMS','MMS Azienda','Aziende SME');
            Id accId = accs[0].id;
            
            List<Contact> contacts = HDT_UTL_DataFactoryTst.createContact(2,false,accId);
            for(Contact c : contacts)
                c.Company__c='MMS';
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
            insert orderss;
            orderss[0].recordTypeId = utlConstants.ORDER_RECORDTYPEID_CONNESSIONECONATTIVAZIONE;
            orderss[0].Phase__c = 'Bozza';
            update orderss;
            
            Group g = new Group(Name = 'test', DeveloperName = 'HDT_QUE_ComfortQuality');
            
            List<Campaign> campaigns = HDT_UTL_DataFactoryTst.createCampaign(1,false);
            campaigns[0].Name = 'Comfort Campaign';
            insert campaigns;
            Id campaignId = campaigns[0].id;
            
            List<Order> orders2 = HDT_UTL_DataFactoryTst.createOrder(1,false,accId,'Bozza');
            orders2[0].qualityCall__c = true;
            orders2[0].DateComfortCall__c = System.today() - 3;
            orders2[0].ComfortCallDaysDue__c = 6.2;
            orders2[0].ParentOrder__c = parentOrderId;
            orders2[0].Contact__c = anotherContactId;
            insert orders2;
            orders2[0].recordTypeId = utlConstants.ORDER_RECORDTYPEID_CONNESSIONECONATTIVAZIONE;
            orders2[0].Phase__c = 'In attesa conferma cliente';
            update orders2;
        
            List<Order> orders3 = HDT_UTL_DataFactoryTst.createOrder(1,false,accId,'Bozza');
			orders3[0].Username__c='test';
			orders3[0].Password__c='test1';
			orders3[0].NotRegisteredMeterCase__c=true;
			orders3[0].EffectiveDate__c=date.today();
			orders3[0].PowerCommitted__c=2;
			orders3[0].ImplantType__c='13A0-Usi di Abitazione BT';
			orders3[0].RequestOption__c='Domestici-TD';
			orders3[0].CreditCheckDescription__c='test1';
			orders3[0].QualityCall__c=true;  
        	orders3[0].ComfortCallDaysDue__c=null;
			orders3[0].WizardCompletedDate__c=date.today();
        	orders3[0].QualityCallUnique__c=false;
            orders3[0].ParentOrder__c = parentOrderId;
            orders3[0].Contact__c = contactId;
            insert orders3;
            orders3[0].recordTypeId = utlConstants.ORDER_RECORDTYPEID_CONNESSIONECONATTIVAZIONE;
            orders3[0].Phase__c = 'Bozza';
            update orders3;
        List<Contract> con = HDT_UTL_DataFactoryTst.createContract(1,true,accId);
        List<ServicePoint__c> sp = HDT_UTL_DataFactoryTst.createServicePoint(1,true);
        List<Case> case1 = HDT_UTL_DataFactoryTst.createCaseDocumentale(1,true,accId,contactId,sp[0].Id,con[0].Id,orderss[0].Id);
       	List<wrts_prcgvr__Activity__c> activity = HDT_UTL_DataFactoryTst.createActivityCustom(1,true,accId);
        List<Campaign> campaign = HDT_UTL_DataFactoryTst.createCampaign(1,true);
        campaign[0].Name='Quality Campaign';
        update campaign;
        activity[0].order__c=orderss[0].Id;
        activity[0].RecordTypeId = utlConstants.ACTIVITYCUSTOM_RECORDTYPEID_COMFORTQUALITYCALL ;
        update activity;
       
    } 
}

@isTest
public static void testQualityCallExecute(){
    test.startTest();

	
    HDT_BA_QualityCall batch = new HDT_BA_QualityCall();
    Id batchId = Database.executeBatch(batch,200);

    test.stopTest();
    
    System.assertEquals(1, [Select id From wrts_prcgvr__Activity__c LIMIT 1].size(), 'HDT_BA_QualityCall did not work correctly: wrong amount of custom activities');
        
    System.assertNotEquals(1, [Select id From wrts_prcgvr__Activity__c LIMIT 1].size() ,'HDT_BA_QualityCall did not work correctly: wrong amount of CampaignMember');
}
}