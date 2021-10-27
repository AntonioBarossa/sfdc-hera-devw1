/**
* @author Andrea Arosio (andrea.arosio@webresults.it)
* @date 23/07/2021
* @description Test Class for HDT_UTL_Dependencies – Classe di utilità per la gestione della sequenzializzazione dei processi
*/
@SuppressWarnings('PMD.AvoidDebugStatements')
@isTest
public with sharing class HDT_UTL_DependenciesTestWithoutData {

    private static final String ORDER_TYPE = 'Cambio Offerta';
    private static final String PROCESS_TYPE = 'Cambio offerta - EE';
    private static final String PROCESS_TYPE2 = 'Cambio offerta - GAS';
    private static final String PROCESS_TYPE3 = 'Cambio uso fittizio';
    // private final String PHASE_BLK = 'In attesa conferma cliente';
    private static final String PHASE_INC = 'Bozza';
    private static final String PHASE_INC_NEXT_ORDER = 'Comunicazione verso Heroku';
    private static final String PHASE_INC_NEXT_CASE = 'Comunicazione verso Heroku OK';
    private static final String PHASE_INC_SEQ = 'Sequenzializzato';
    private static final String DEPENDENCY_MATCH_SP = 'Service Point';
    private static final String DEPENDENCY_MATCH_AC = 'Account';
    private static final String DEPENDENCY_MATCH_BP = 'Billing Profile';

    private static HDT_UTL_Constants utlConstants = new HDT_UTL_Constants();

    @testSetup
    static void setup() {

        wrts_prcgvr.PostInstall postinstall = new wrts_prcgvr.PostInstall();
        Test.testInstall(postinstall, null);

        HDT_UTL_DataFactoryTst.installPhaseManagerSObjectSetting('Order');
        HDT_UTL_DataFactoryTst.installCSDependecyPhaseCheckSetting('Comunicazione verso Heroku');
        HDT_UTL_DataFactoryTst.installPhaseManagerSObjectSetting('Case');
        HDT_UTL_DataFactoryTst.installCSDependecyPhaseCheckSetting('Comunicazione verso Heroku OK');

        List<wrts_prcgvr__PhaseTransition__c> phaseTransitions = new List<wrts_prcgvr__PhaseTransition__c>();

        //Order Phase Transations
        phaseTransitions.add(HDT_UTL_DataFactoryTst.insertPhaseTransition(null,null,null,null, '','From Bozza To Heroku',
            PHASE_INC_NEXT_ORDER,null,null,null,false, PHASE_INC, null,null,
            utlConstants.ORDER_RECORDTYPEID_CAMBIO_OFFERTA, utlConstants.ORDER_RECORDTYPE_CAMBIO_OFFERTA, null, 'A', false));
        phaseTransitions.add(HDT_UTL_DataFactoryTst.insertPhaseTransition(null,null,null,null, '','From Bozza To Sequenzializzazione',
            PHASE_INC_SEQ,null,null,null,false, PHASE_INC, null,null,
            utlConstants.ORDER_RECORDTYPEID_CAMBIO_OFFERTA, utlConstants.ORDER_RECORDTYPE_CAMBIO_OFFERTA, null, 'A', false));
        phaseTransitions.add(HDT_UTL_DataFactoryTst.insertPhaseTransition(null,null,null,null, '','From Sequenzializzazione To Heroku',
            PHASE_INC_NEXT_ORDER,null,null,null,false, PHASE_INC_SEQ, null,null,
            utlConstants.ORDER_RECORDTYPEID_CAMBIO_OFFERTA, utlConstants.ORDER_RECORDTYPE_CAMBIO_OFFERTA, null, 'A', false));

        //Case Phase Transations
        phaseTransitions.add(HDT_UTL_DataFactoryTst.insertPhaseTransition(null,null,null,null, '','From Bozza To Heroku',
            PHASE_INC_NEXT_CASE,null,null,null,false, PHASE_INC, null,null,
            utlConstants.CASE_RECORDTYPEID_MOROSITA, utlConstants.CASE_RECORDTYPE_DEVELOPERNAME_MOROSITA, null, 'A', false));
        phaseTransitions.add(HDT_UTL_DataFactoryTst.insertPhaseTransition(null,null,null,null, '','From Bozza To Sequenzializzazione',
            'In Lavorazione',null,null,null,false, PHASE_INC, null,null,
            utlConstants.CASE_RECORDTYPEID_MOROSITA, utlConstants.CASE_RECORDTYPE_DEVELOPERNAME_MOROSITA, null, 'A', false));
        phaseTransitions.add(HDT_UTL_DataFactoryTst.insertPhaseTransition(null,null,null,null, '','From Sequenzializzazione To Heroku',
            PHASE_INC_NEXT_CASE,null,null,null,false, 'In Lavorazione', null,null,
            utlConstants.CASE_RECORDTYPEID_MOROSITA, utlConstants.CASE_RECORDTYPE_DEVELOPERNAME_MOROSITA, null, 'A', false));
        
        insert phaseTransitions;

        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordListBlk = HDT_UTL_DataFactoryTst.createOrder(1, false, accList[0].id, PHASE_INC);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, false, accList[0].id); 
        contactList[0].Company__c = 'HCM';
        insert contactList; 
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);

        Order order = ordListBlk[0];

        order.RecordTypeId = utlConstants.ORDER_RECORDTYPEID_CAMBIO_OFFERTA;
        order.Status = HDT_UTL_Dependencies.STATUS_LAVORAZIONE;
        insert order;

        List<Case> cases = HDT_UTL_DataFactoryTst.createCaseMorosita(1, true, accList[0].Id, contactList[0].Id, servPointList[0].Id, null, null);

        List<ServiceRequest__c> serviceRequests = HDT_UTL_DataFactoryTst.createServiceRequest(2, false);

        serviceRequests[0].ServicePoint__c = servPointList[0].Id;
        serviceRequests[0].ServicePointCode__c = servPointList[0].ServicePointCode__c;
        serviceRequests[0].Case__c = cases[0].Id;
        serviceRequests[0].Type__c = HDT_UTL_Dependencies.TIPOLOGY_POSTSALES;
        serviceRequests[0].Status__c = HDT_UTL_Dependencies.STATUS_LAVORAZIONE;
        serviceRequests[0].ProcessType__c = PROCESS_TYPE;

        serviceRequests[1].ServicePoint__c = servPointList[0].Id;
        serviceRequests[1].ServicePointCode__c = servPointList[0].ServicePointCode__c;
        serviceRequests[1].Order__c = order.Id;
        serviceRequests[1].Type__c = HDT_UTL_Dependencies.TIPOLOGY_SALES;
        serviceRequests[1].Status__c = HDT_UTL_Dependencies.STATUS_BOZZA;
        serviceRequests[1].ProcessType__c = PROCESS_TYPE;

        insert serviceRequests;

    }    

    @isTest
    static void sequentializationOrderTest() {

        Contact con = [SELECT Id FROM Contact WHERE Contact.Company__c = :'HCM' LIMIT 1];
        HDT_UTL_DataFactoryTst.createDependenciesMatrix(1, true, PROCESS_TYPE, PROCESS_TYPE, PHASE_INC_NEXT_ORDER, DEPENDENCY_MATCH_SP);
       
        Test.startTest();

        List<Order> ordListInc = [SELECT Id, Phase__c, Contact__c FROM Order LIMIT 1]; 

        ordListInc[0].Phase__c = PHASE_INC_NEXT_ORDER;
        ordListInc[0].Contact__c = con.Id;
            
        update ordListInc;

        Order orderAfterUpdate = [SELECT ID, Status, Phase__c FROM Order WHERE ID =: ordListInc[0].Id];
        
        System.assertEquals('Sequenzializzato', orderAfterUpdate.Status, 'Wrong Order Status - Mathing Service Point');
        System.assertEquals('Sequenzializzato', orderAfterUpdate.Phase__c, 'Wrong Order Phase - Mathing Service Point');
        Test.stopTest();

    }

    @isTest
    static void sequentializationOrderTestAccount() {

        Contact con = [SELECT Id FROM Contact WHERE Contact.Company__c = :'HCM' LIMIT 1];
        HDT_UTL_DataFactoryTst.createDependenciesMatrix(1, true, PROCESS_TYPE, PROCESS_TYPE, PHASE_INC_NEXT_ORDER, DEPENDENCY_MATCH_AC);
       
        Test.startTest();

        List<Order> ordListInc = [SELECT Id, Phase__c, Contact__c FROM Order LIMIT 1]; 

        ordListInc[0].Phase__c = PHASE_INC_NEXT_ORDER;
        ordListInc[0].Contact__c = con.Id;
            
        update ordListInc;

        Order orderAfterUpdate = [SELECT ID, Status, Phase__c FROM Order WHERE ID =: ordListInc[0].Id];
        
        System.assertEquals('In Lavorazione', orderAfterUpdate.Status, 'Wrong Order Status - Mathing Account');
        System.assertEquals('Comunicazione verso Heroku', orderAfterUpdate.Phase__c, 'Wrong Order Phase - Mathing Account');
        Test.stopTest();

    }

    @isTest
    static void sequentializationOrderTestBillingProfile() {

        Contact con = [SELECT Id FROM Contact WHERE Contact.Company__c = :'HCM' LIMIT 1];
        HDT_UTL_DataFactoryTst.createDependenciesMatrix(1, true, PROCESS_TYPE, PROCESS_TYPE, PHASE_INC_NEXT_ORDER, DEPENDENCY_MATCH_BP);
       
        Test.startTest();

        List<Order> ordListInc = [SELECT Id, Phase__c, Contact__c FROM Order LIMIT 1]; 

        ordListInc[0].Phase__c = PHASE_INC_NEXT_ORDER;
        ordListInc[0].Contact__c = con.Id;
            
        update ordListInc;

        Order orderAfterUpdate = [SELECT ID, Status, Phase__c FROM Order WHERE ID =: ordListInc[0].Id];
        
        System.assertEquals('In Lavorazione', orderAfterUpdate.Status, 'Wrong Order Status - Billing Profile');
        System.assertEquals('Comunicazione verso Heroku', orderAfterUpdate.Phase__c, 'Wrong Order Phase - Billing Profile');
        Test.stopTest();

    }
    
    @isTest
    static void sequentializationCaseTest() {

        HDT_UTL_DataFactoryTst.createDependenciesMatrix(1, true, PROCESS_TYPE, PROCESS_TYPE, PHASE_INC_NEXT_CASE, DEPENDENCY_MATCH_SP);
       
        Test.startTest();

        List<Case> caseListInc = [SELECT Id, Phase__c FROM Case LIMIT 1];

        caseListInc[0].Phase__c = PHASE_INC_NEXT_CASE;
            
        update caseListInc;

        Case caseAfterUpdate = [SELECT ID, Status, Phase__c FROM Case WHERE ID =: caseListInc[0].Id];

        System.assertEquals('In Lavorazione', caseAfterUpdate.Status, 'Wrong Case Status - Mathing Service Point');
        System.assertEquals('Comunicazione verso Heroku OK', caseAfterUpdate.Phase__c, 'Wrong Case Phase - Mathing Service Point');
        Test.stopTest();

    }

    @isTest
    static void sequentializationCaseTestMatchAccount() {

        HDT_UTL_DataFactoryTst.createDependenciesMatrix(1, true, PROCESS_TYPE, PROCESS_TYPE, PHASE_INC_NEXT_CASE, DEPENDENCY_MATCH_AC);
       
        Test.startTest();

        List<Case> caseListInc = [SELECT Id, Phase__c FROM Case LIMIT 1];

        caseListInc[0].Phase__c = PHASE_INC_NEXT_CASE;
            
        update caseListInc;

        Case caseAfterUpdate = [SELECT ID, Status, Phase__c FROM Case WHERE ID =: caseListInc[0].Id];

        System.assertEquals('In Lavorazione', caseAfterUpdate.Status, 'Wrong Case Status - Mathing Account');
        System.assertEquals('Comunicazione verso Heroku OK', caseAfterUpdate.Phase__c, 'Wrong Case Phase - Mathing Account');
        Test.stopTest();

    }

    @isTest
    static void sequentializationCaseTestMatchBillingProfile() {

        HDT_UTL_DataFactoryTst.createDependenciesMatrix(1, true, PROCESS_TYPE, PROCESS_TYPE, PHASE_INC_NEXT_CASE, DEPENDENCY_MATCH_BP);
       
        Test.startTest();

        List<Case> caseListInc = [SELECT Id, Phase__c FROM Case LIMIT 1];

        caseListInc[0].Phase__c = PHASE_INC_NEXT_CASE;
            
        update caseListInc;

        Case caseAfterUpdate = [SELECT ID, Status, Phase__c FROM Case WHERE ID =: caseListInc[0].Id];

        System.assertEquals('In Lavorazione', caseAfterUpdate.Status, 'Wrong Case Status - Billing Profile');
        System.assertEquals('Comunicazione verso Heroku OK', caseAfterUpdate.Phase__c, 'Wrong Case Phase - Billing Profile');
        Test.stopTest();

    }

}

