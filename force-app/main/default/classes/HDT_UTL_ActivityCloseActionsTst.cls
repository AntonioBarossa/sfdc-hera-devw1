/**
 * @description       : 
 * @author            : Giacinto Florio
 * @group             : 
 * @last modified on  : 22-03-2023
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
    
    static Case createCase(String recordType, String caseType){
        Id rtId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(recordType).getRecordTypeId();
        Case testCase = new Case();
        testCase.Type = caseType;
        testCase.RecordType = [SELECT Id, DeveloperName FROM RecordType WHERE Id=:rtId];
        insert testCase;
        return testCase;
    }

    @isTest 
    static void getOnCloseActionsTest(){

        Case caso = new Case();
        caso.Type = 'Riduz. superficie rifiuti spec promiscui';
        caso.Phase__c = '';
        insert caso;

        wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c();
        activity.ActivityOutcome__c = 'Positivo';
        insert activity;
        String activityType             = 'Gestione Manuale SAP';
        String activityTypeAcqua        = 'Inviare Resoconto Verifica'; 
        String activityTypeAnnullamento = 'CBS_ANN006__ELABORAZIONE_MANUALE'; 
        String activityTypeErroreFatturazione = 'CBS_FAT004__ELABORAZIONE_MANUALE'; 
        String activityTypeRimborsoPagamento = 'CBS_PAG003__ELABORAZIONE_MANUALE'; 

        Test.startTest();
        HDT_UTL_ActivityCloseActions.getOnCloseActions(HDT_UTL_ActivityCloseActionsTst.createCase('HDT_RT_VariazioniTari',''),activity, activityType);
        HDT_UTL_ActivityCloseActions.getOnCloseActions(HDT_UTL_ActivityCloseActionsTst.createCase('HDT_RT_VerificheAcqua',''),activity, activityTypeAcqua);
        HDT_UTL_ActivityCloseActions.getOnCloseActions(HDT_UTL_ActivityCloseActionsTst.createCase('HDT_RT_Annullamento','Annullamento Contratti'),activity, activityTypeAnnullamento);
        HDT_UTL_ActivityCloseActions.getOnCloseActions(HDT_UTL_ActivityCloseActionsTst.createCase('HDT_RT_ErroreFatturazione_TARI','Errore di Fatturazione'),activity, activityTypeErroreFatturazione);
        HDT_UTL_ActivityCloseActions.getOnCloseActions(HDT_UTL_ActivityCloseActionsTst.createCase('HDT_RT_Rimborso','Rimborso'),activity, activityTypeRimborsoPagamento);
        HDT_UTL_ActivityCloseActions.getOnCloseActions(HDT_UTL_ActivityCloseActionsTst.createCase('HDT_RT_ComunicazionePagamento','Comunicazione Pagamento'),activity, activityTypeRimborsoPagamento);
        HDT_UTL_ActivityCloseActions.getOnCloseActions(HDT_UTL_ActivityCloseActionsTst.createCase('HDT_RT_ComunicazionePagamento','Doppi Pagamenti/Incassi'),activity, activityTypeRimborsoPagamento);
        HDT_UTL_ActivityCloseActions.HDT_WRP_Actions action = HDT_UTL_ActivityCloseActions.getOnCloseActions(caso,activity, activityType);
        System.assertEquals(action.phase, 'Completata', 'OK');
        activityType = '';
        HDT_UTL_ActivityCloseActions.getOnCloseActions(caso,activity, activityType);
        activity.ActivityOutcome__c = 'Negativo';
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
        activity.ActivityOutcome__c = 'Positivo';
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
        activity.ActivityOutcome__c = 'Positivo';
        insert activity;

        Test.startTest();
        activity.wrts_prcgvr__Status__c = 'Chiusa';
        activity.Order__c = ordine.Id;
        update activity;
        System.assertEquals(activity.wrts_prcgvr__Status__c, 'Chiusa', 'OK');
        Test.stopTest();
    }

    
    @isTest 
    static void approvazioneAgevolazioneTst(){

        Order ord = new Order(ProcessType__c='Modifica Tariffa', Phase__c='In attesa Approvazione');
        wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c();
        activity.ActivityOutcome__c = 'Negativo';
        String activityType = 'Approvazione Agevolazione';

        Order ordElaborazioneManuale = new Order(ProcessType__c='Modifica Tariffa - Rimozione Agevolazione', Phase__c='In attesa Approvazione');
        wrts_prcgvr__Activity__c activityElaborazioneManuale = new wrts_prcgvr__Activity__c();
        activityElaborazioneManuale.ActivityOutcome__c = 'Positivo';
        String activityTypeElaborazioneManuale = 'Elaborazione Manuale';

        Test.startTest();
        HDT_UTL_ActivityCloseActions.HDT_WRP_Actions action = HDT_UTL_ActivityCloseActions.getOnCloseActions(ord, activity, activityType);
        system.assertEquals(action.activityType, 'CBS_CRP001__CONTATTARE_IL_CLIENTE_SALES', 'OK');
		activity.ActivityOutcome__c = 'Positivo';
        action= HDT_UTL_ActivityCloseActions.getOnCloseActions(ord, activity, activityType);
        system.assertEquals(action.phase, 'Documentazione Validata', 'OK');
        action = HDT_UTL_ActivityCloseActions.getOnCloseActions(ordElaborazioneManuale, activityElaborazioneManuale, activityTypeElaborazioneManuale);
        system.assertEquals(action.phase, 'Completata', 'OK');
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
        Case c = new Case();    //case variazioni - integrato - ko heroku
        c.Phase__c = 'Comunicazione verso Heroku KO';
        c.Type = 'Modifica dati contrattuali';
        c.Subprocess__c = 'DOM_Componenti non residenti';
        c.RecordTypeId = rtId;
        Case csap = new Case(); //case variazioni - integrato - ko sap
        csap.Phase__c = 'Esito KO da SAP';
        csap.Type = 'Modifica dati contrattuali';
        csap.Subprocess__c = 'DOM_Componenti non residenti';
        csap.RecordTypeId = rtId;
        Case cni = new Case(); //case variazioni - non integrato - ko heroku
        cni.Phase__c = 'Comunicazione verso Heroku KO';
        cni.Type = 'Modifica dati contrattuali';
        cni.Subprocess__c = 'DOM_Componenti residenti';
        cni.RecordTypeId = rtId;
        Case cs = new Case(); //case variazioni - superficie(no documentale) - ko heroku
        cs.Phase__c = 'Comunicazione verso Heroku KO';
        cs.Type = 'Modifica dati contrattuali';
        cs.Subprocess__c = 'Superficie';
        cs.ModuleFromContributor__c = true;
        cs.RequestSource__c = 'Da Contribuente';
        cs.RecordTypeId = rtId;
		Case csf = new Case(); //case variazioni - superficie(documentale) - ko heroku
        csf.Phase__c = 'Comunicazione verso Heroku KO';
        csf.Type = 'Modifica dati contrattuali';
        csf.Subprocess__c = 'Superficie';
        csf.ModuleFromContributor__c = false;
        csf.RequestSource__c = 'Da Contribuente';
        csf.RecordTypeId = rtId;
        wrts_prcgvr__Activity__c abo = new wrts_prcgvr__Activity__c(); //activity back office positiva
        abo.Type__c = 'Istruttoria Back Office';
        abo.ActivityOutcome__c = 'Positivo';
        wrts_prcgvr__Activity__c abon = new wrts_prcgvr__Activity__c(); //activity back office negativa
        abon.Type__c = 'Istruttoria Back Office';
        abon.ActivityOutcome__c = 'Negativo';
        wrts_prcgvr__Activity__c ap = new wrts_prcgvr__Activity__c(); //activity manuale positiva
        ap.ActivityOutcome__c = 'Positivo';
        wrts_prcgvr__Activity__c an = new wrts_prcgvr__Activity__c(); //activity manuale negativa
        an.ActivityOutcome__c = 'Negativo';
        HDT_UTL_ActivityCloseActions.HDT_WRP_Actions action;

        Case selectedCase = new Case(); // Variazione indirizzo di fornitura - update ServicePoint
        selectedCase.Phase__c = 'Esito KO da SAP';
        selectedCase.Type = 'Variazione indirizzo di fornitura';
        selectedCase.Subprocess__c = 'DOM_Componenti residenti';
        selectedCase.RecordTypeId = rtId;
        selectedCase.ServicePoint__c = HDT_UTL_DataFactoryTst.createServicePoint(1, true)[0].Id;
        selectedCase.SupplyCity__c ='';
        selectedCase.SupplyCountry__c ='';
        selectedCase.SupplyPlace__c ='';
        selectedCase.SupplyPostalCode__c ='';
        selectedCase.SupplyProvince__c ='';
        selectedCase.SupplyCityCode__c ='';
        selectedCase.SupplyStreetCode__c ='';
        selectedCase.SupplyStreetName__c ='';
        selectedCase.SupplyStreetNumberExtension__c ='';
        selectedCase.SupplyStreetNumber__c ='';
        selectedCase.SupplyStreetName__c ='';

        Test.startTest();
            action = HDT_UTL_ActivityCloseActions.tariLogicVarDis(c, ap);
       		system.assertEquals(action.phase, 'Da Inviare', 'OK');
            action = HDT_UTL_ActivityCloseActions.tariLogicVarDis(c, an);
        	system.assertEquals(((Case) action.sobjToUpdate).Phase__c, 'Annullato', 'OK');
            action = HDT_UTL_ActivityCloseActions.tariLogicVarDis(cni, ap);
        	system.assertEquals(action.phase, 'Completata', 'OK');
            action = HDT_UTL_ActivityCloseActions.tariLogicVarDis(cni, an);
        	system.assertEquals(((Case) action.sobjToUpdate).Phase__c, 'Annullato', 'OK');
        	action = HDT_UTL_ActivityCloseActions.tariLogicVarDis(cs, abo);
        	system.assertEquals(action.phase, 'Da Inviare', 'OK');
        	action = HDT_UTL_ActivityCloseActions.tariLogicVarDis(csf, abo);
        	system.assertEquals(action.phase, 'Gestione Documentale', 'OK');
        	action = HDT_UTL_ActivityCloseActions.tariLogicVarDis(csf, abon);
        	system.assertEquals(((Case) action.sobjToUpdate).Phase__c, 'Annullato', 'OK');
        	action = HDT_UTL_ActivityCloseActions.tariLogicVarDis(csap, ap);
        	system.assertEquals(action.phase, 'Da Inviare', 'OK');
        	action = HDT_UTL_ActivityCloseActions.tariLogicVarDis(csap, an);
        	system.assertEquals(((Case) action.sobjToUpdate).Phase__c, 'Annullato', 'OK');
            action = HDT_UTL_ActivityCloseActions.tariLogicVarDis(selectedCase, ap);
        Test.stopTest();
    }

    @isTest
    static void posContenitoreLogicTst(){
        Id rtId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_PosizionamentoContenitore').getRecordTypeId();
        Case c = new Case();    //case reclamo posizionamento contenitore
        c.Phase__c = 'In Lavorazione';
        c.Type = 'Posizionamento contenitore';
        c.RecordTypeId = rtId;
        wrts_prcgvr__Activity__c ap = new wrts_prcgvr__Activity__c(); //activity manuale positiva
        ap.ActivityOutcome__c = 'Positivo';
        wrts_prcgvr__Activity__c an = new wrts_prcgvr__Activity__c(); //activity manuale negativa
        an.ActivityOutcome__c = 'Negativo';
        HDT_UTL_ActivityCloseActions.HDT_WRP_Actions action;
        Test.startTest();
            action = HDT_UTL_ActivityCloseActions.posContenitoreLogic(c, ap);
            system.assertEquals(action.phase, 'Completata', 'OK');
            action = HDT_UTL_ActivityCloseActions.posContenitoreLogic(c, an);
            system.assertEquals(((Case) action.sobjToUpdate).Phase__c, 'Annullato', 'OK');
        Test.stopTest();
    }

}