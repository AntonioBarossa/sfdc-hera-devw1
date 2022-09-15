/**
 * @description       : 
 * @author            : Giacinto Florio
 * @group             : 
 * @last modified on  : 14-09-2022
 * @last modified by  : Giacinto Florio
**/
@isTest
public with sharing class HDT_UTL_ActivityCloseActionsTst {
    
    private static HDT_UTL_Constants constants=new HDT_UTL_Constants();

    @TestSetup
    static void makedata(){

        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
        insert internalUser;
        System.runAs(internalUser){
            HDT_UTL_DataFactoryTst.pClickInstance();
        }
    }
    
    @isTest 
    static void riduzioneSuperficieTest(){

        Case caso = new Case();
        caso.Type = 'Riduzione Superficie rifiuti spec promiscui';
        caso.Phase__c = '';
        insert caso;
        wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c();
        activity.Approved__c = 'si';
        insert activity;
        String activityType = 'Gestione Manuale SAP';

        Test.startTest();
        HDT_UTL_ActivityCloseActions.HDT_WRP_Actions action = HDT_UTL_ActivityCloseActions.getOnCloseActions(caso,activity, activityType);
        System.assertEquals(action.phase, 'Completata', 'OK');
        activityType = '';
        HDT_UTL_ActivityCloseActions.getOnCloseActions(caso,activity, activityType);
        activity.Approved__c = 'no';
        update activity;
        HDT_UTL_ActivityCloseActions.getOnCloseActions(caso,activity, activityType);
        Test.stopTest();

    }

    @isTest 
    static void gestioneRifiutiTest(){

        Case caso = new Case();
        caso.Type = 'Gestione Rifiuti';
        caso.PhaseStory__c='';
        insert caso;
        wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c();
        activity.Approved__c = 'si';
        insert activity;
        String activityType = 'Risposta Ricevuta';

        Test.startTest();
        HDT_UTL_ActivityCloseActions.HDT_WRP_Actions action = HDT_UTL_ActivityCloseActions.getOnCloseActions(caso,activity, activityType);
        System.assertEquals(action.phase, 'Annullato', 'OK');
        HDT_UTL_ActivityCloseActions.getOnCloseActions(caso,activity, activityType);
        activity.Approved__c = 'no';
        update activity;
        HDT_UTL_ActivityCloseActions.getOnCloseActions(caso,activity, activityType);
        Test.stopTest();

    }

    @isTest 
    static void annulloRichiestaTest(){

        Case caso = new Case();
        caso.Type = 'Ambiente annullo richiesta senza appuntamento';
        insert caso;
        wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c();
        activity.Approved__c = 'si';
        insert activity;
        String activityType = 'Risposta Ricevuta';

        Test.startTest();
        HDT_UTL_ActivityCloseActions.HDT_WRP_Actions action = HDT_UTL_ActivityCloseActions.getOnCloseActions(caso,activity, activityType);
        System.assertEquals(action.phase, 'Completata', 'OK');
        activity.Approved__c = 'no';
        update activity;
        HDT_UTL_ActivityCloseActions.getOnCloseActions(caso,activity, activityType);
        Test.stopTest();

    }
    
    
    @isTest 
    static void approvazioneAgevolazioneTst(){

        Order ord = new Order(ProcessType__c='Modifica Tariffa', Phase__c='In attesa Approvazione');
        wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c();
        activity.Approved__c = 'no';
        String activityType = 'Approvazione Agevolazione';

        Test.startTest();
        HDT_UTL_ActivityCloseActions.HDT_WRP_Actions action = HDT_UTL_ActivityCloseActions.getOnCloseActions(ord, activity, activityType);
        system.assertEquals(action.activityType, 'Contattare Cliente', 'Unexpected Logic');
		activity.Approved__c = 'si';
        action= HDT_UTL_ActivityCloseActions.getOnCloseActions(ord, activity, activityType);
        system.assertEquals(action.phase, 'Documentazione Validata', 'Unexpected Logic');
        Test.stopTest();

    }

    @isTest 
    static void queueFakeTest(){

        Map<Id, HDT_UTL_ActivityCloseActions.HDT_WRP_Actions> actionsCase = new Map<Id, HDT_UTL_ActivityCloseActions.HDT_WRP_Actions>();
        Map<Id, HDT_UTL_ActivityCloseActions.HDT_WRP_Actions> actionsOrder = new Map<Id, HDT_UTL_ActivityCloseActions.HDT_WRP_Actions>();

        HDT_UTL_ActivityCloseActions.HDT_WRP_Queue queue = new HDT_UTL_ActivityCloseActions.HDT_WRP_Queue(actionsCase,actionsOrder);
        System.assertEquals(actionsCase.isEmpty(), true, 'Fake Test');
        Test.startTest();
        queue.execute(null);
        Test.stopTest();
    }

}