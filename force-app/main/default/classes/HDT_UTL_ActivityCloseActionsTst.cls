/**
 * @description       : 
 * @author            : Giacinto Florio
 * @group             : 
 * @last modified on  : 24-11-2022
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
        caso.Type = 'Riduz. superficie rifiuti spec promiscui';
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
    static void executeOnCloseActionsCaseTest(){

        Case caso = new Case();
        caso.Type = 'Riduz. superficie rifiuti spec promiscui';
        caso.Phase__c = '';
        insert caso;
        wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c();
        activity.Approved__c = 'si';
        insert activity;

        Test.startTest();
        activity.wrts_prcgvr__Status__c = 'Chiusa';
        activity.Case__c = caso.Id;
        update activity;
        System.assertEquals(activity.wrts_prcgvr__Status__c, 'Chiusa', 'OK');
        Test.stopTest();
    }

    @isTest 
    static void executeOnCloseActionsOrderTest(){

        Account account = HDT_UTL_DataFactoryTst.createAccountResidenziale(1, true, 'HERA COMM', 'D1 - Persona fisica', 'Enti')[0];
        Order ordine = HDT_UTL_DataFactoryTst.createOrder(1, false, account.id, 'Bozza')[0];
        insert ordine;
        wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c();
        activity.Approved__c = 'si';
        insert activity;

        Test.startTest();
        activity.wrts_prcgvr__Status__c = 'Chiusa';
        activity.Order__c = ordine.Id;
        update activity;
        System.assertEquals(activity.wrts_prcgvr__Status__c, 'Chiusa', 'OK');
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
        system.assertEquals(action.activityType, 'Contattare Cliente', 'OK');
		activity.Approved__c = 'si';
        action= HDT_UTL_ActivityCloseActions.getOnCloseActions(ord, activity, activityType);
        system.assertEquals(action.phase, 'Documentazione Validata', 'OK');
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

    @isTest
    static void tariLogicVarDisTst(){
        Id rtId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_VariazioniTari').getRecordTypeId();
        Case c = new Case();
        c.Phase__c = 'Comunicazione verso Heroku KO';
        c.Type = 'Modifica dati contrattuali';
        c.Subprocess__c = 'DOM_Componenti non residenti';
        c.RecordTypeId = rtId;
        Case csap = new Case();
        csap.Phase__c = 'Esito KO da SAP';
        csap.Type = 'Modifica dati contrattuali';
        csap.Subprocess__c = 'DOM_Componenti non residenti';
        csap.RecordTypeId = rtId;
        Case cni = new Case();
        cni.Phase__c = 'Comunicazione verso Heroku KO';
        cni.Type = 'Modifica dati contrattuali';
        cni.Subprocess__c = 'DOM_Componenti residenti';
        cni.RecordTypeId = rtId;
        Case cs = new Case();
        cs.Phase__c = 'Comunicazione verso Heroku KO';
        cs.Type = 'Modifica dati contrattuali';
        cs.Subprocess__c = 'Superficie';
        cs.ModuleFromContributor__c = true;
        cs.RequestSource__c = 'Da Contribuente';
        cs.RecordTypeId = rtId;
		Case csf = new Case();
        csf.Phase__c = 'Comunicazione verso Heroku KO';
        csf.Type = 'Modifica dati contrattuali';
        csf.Subprocess__c = 'Superficie';
        csf.ModuleFromContributor__c = false;
        csf.RequestSource__c = 'Da Contribuente';
        csf.RecordTypeId = rtId;
        wrts_prcgvr__Activity__c abo = new wrts_prcgvr__Activity__c();
        abo.Type__c = 'Istruttoria Back Office';
        abo.ActivityOutcome__c = 'Positivo';
        wrts_prcgvr__Activity__c abon = new wrts_prcgvr__Activity__c();
        abon.Type__c = 'Istruttoria Back Office';
        abon.ActivityOutcome__c = 'Negativo';
        wrts_prcgvr__Activity__c ap = new wrts_prcgvr__Activity__c();
        ap.ActivityOutcome__c = 'Positivo';
        wrts_prcgvr__Activity__c an = new wrts_prcgvr__Activity__c();
        an.ActivityOutcome__c = 'Negativo';
        HDT_UTL_ActivityCloseActions.HDT_WRP_Actions action;
        Test.startTest();
            action = HDT_UTL_ActivityCloseActions.tariLogicVarDis(c, ap);
       		system.assertEquals(action.phase, 'Da Inviare', 'OK');
            action = HDT_UTL_ActivityCloseActions.tariLogicVarDis(c, an);
        	system.assertEquals(action.phase, 'Annullato', 'OK');
            action = HDT_UTL_ActivityCloseActions.tariLogicVarDis(cni, ap);
        	system.assertEquals(action.phase, 'Completata', 'OK');
            action = HDT_UTL_ActivityCloseActions.tariLogicVarDis(cni, an);
        	system.assertEquals(action.phase, 'Annullato', 'OK');
        	action = HDT_UTL_ActivityCloseActions.tariLogicVarDis(cs, abo);
        	system.assertEquals(action.phase, 'Da Inviare', 'OK');
        	action = HDT_UTL_ActivityCloseActions.tariLogicVarDis(csf, abo);
        	system.assertEquals(action.phase, 'Gestione Documentale', 'OK');
        	action = HDT_UTL_ActivityCloseActions.tariLogicVarDis(csf, abon);
        	system.assertEquals(action.phase, 'Annullato', 'OK');
        	action = HDT_UTL_ActivityCloseActions.tariLogicVarDis(csap, ap);
        	system.assertEquals(action.phase, 'Completata', 'OK');
        	action = HDT_UTL_ActivityCloseActions.tariLogicVarDis(csap, an);
        	system.assertEquals(action.phase, 'Annullato', 'OK');
        Test.stopTest();
    }

}