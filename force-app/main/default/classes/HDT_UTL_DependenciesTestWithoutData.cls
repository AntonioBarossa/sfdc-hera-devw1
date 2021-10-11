/**
* @author Andrea Arosio (andrea.arosio@webresults.it)
* @date 23/07/2021
* @description Test Class for HDT_UTL_Dependencies – Classe di utilità per la gestione della sequenzializzazione dei processi
*/
@SuppressWarnings('PMD.AvoidDebugStatements')
@isTest
public with sharing class HDT_UTL_DependenciesTestWithoutData {

    @testSetup
    static void setup() {
        final String ORDER_TYPE = 'Cambio Offerta';
        final String PROCESS_TYPE = 'Cambio offerta - EE';
        final String ORDER_RECORDTYPEID_CONFERMA =
        Schema.SObjectType.Order.getRecordTypeInfosByName().get(ORDER_TYPE).getRecordTypeId();
        final String PHASE_BLK = 'In attesa conferma cliente';
        final String PHASE_INC = 'Bozza';
        final String PHASE_INC_NEXT = 'Comunicazione verso Heroku';
        final String PHASE_INC_SEQ = 'Sequenzializzato';
        final String DEPENDENCY_MATCH = 'Service Point';

        wrts_prcgvr.PostInstall postinstall = new wrts_prcgvr.PostInstall();
        Test.testInstall(postinstall, null);

        HDT_UTL_DataFactoryTst.installPhaseManagerSObjectSetting();
        HDT_UTL_DataFactoryTst.installCSDependecyPhaseCheckSetting();

        HDT_UTL_DataFactoryTst.insertPhaseTransition(null,null,null,null, '','From Bozza To Heroku',
            PHASE_INC_NEXT,null,null,null,false, PHASE_INC, null,null,
            ORDER_RECORDTYPEID_CONFERMA, [Select DeveloperName from RecordType where Id =:ORDER_RECORDTYPEID_CONFERMA][0].DeveloperName, null, 'A', true);
        HDT_UTL_DataFactoryTst.insertPhaseTransition(null,null,null,null, '','From Bozza To Sequenzializzazione',
            PHASE_INC_SEQ,null,null,null,false, PHASE_INC, null,null,
            ORDER_RECORDTYPEID_CONFERMA, [Select DeveloperName from RecordType where Id =:ORDER_RECORDTYPEID_CONFERMA][0].DeveloperName, null, 'A', true);
        HDT_UTL_DataFactoryTst.insertPhaseTransition(null,null,null,null, '','From Sequenzializzazione To Heroku',
            PHASE_INC_NEXT,null,null,null,false, PHASE_INC_SEQ, null,null,
            ORDER_RECORDTYPEID_CONFERMA, [Select DeveloperName from RecordType where Id =:ORDER_RECORDTYPEID_CONFERMA][0].DeveloperName, null, 'A', true);
        List<DependenciesMatrix__c> dmtxs = HDT_UTL_DataFactoryTst.createDependenciesMatrix(1, true, PROCESS_TYPE, PROCESS_TYPE, PHASE_INC_NEXT, DEPENDENCY_MATCH);

        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordListBlk = HDT_UTL_DataFactoryTst.createOrder(1, false, accList[0].id, PHASE_INC);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, false, accList[0].id); 
        contactList[0].Company__c = 'HCM';
        insert contactList; 
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);

        Order order = ordListBlk[0];

        order.RecordTypeId = ORDER_RECORDTYPEID_CONFERMA;
        order.Phase__c = PHASE_BLK;
        order.Status = HDT_UTL_Dependencies.STATUS_LAVORAZIONE;
        insert order;

        ServiceRequest__c sr = new ServiceRequest__c();

        sr.ServicePoint__c = servPointList[0].Id;
        sr.ServicePointCode__c = servPointList[0].ServicePointCode__c;
        sr.Order__c = order.Id;
        sr.Type__c = HDT_UTL_Dependencies.TIPOLOGY_SALES;
        sr.Status__c = HDT_UTL_Dependencies.STATUS_LAVORAZIONE;
        sr.ProcessType__c = PROCESS_TYPE;
        insert sr;
    }

    @isTest
    static void sequentializationOrderTest() {

        final String ORDER_TYPE = 'Cambio Offerta';
        final String PROCESS_TYPE = 'Cambio offerta - EE';
        final String ORDER_RECORDTYPEID_CONFERMA =
        Schema.SObjectType.Order.getRecordTypeInfosByName().get(ORDER_TYPE).getRecordTypeId();
        final String PHASE_INC_NEXT = 'Comunicazione verso Heroku';

        Account acc = [SELECT Id FROM Account WHERE Account.Name LIKE :'test account%' LIMIT 1];
        Contact contact = [SELECT Id FROM Contact WHERE Contact.Company__c = :'HCM' LIMIT 1];
        ServicePoint__c servPoint = [SELECT Id, ServicePointCode__c FROM ServicePoint__c WHERE ServicePointCode__c = :'testServicePointCode' LIMIT 1];
       
        Test.startTest();

        List<Order> ordListInc = HDT_UTL_DataFactoryTst.createOrder(1, false, acc.id, 'Bozza'); 
        
        Order order = ordListInc[0];
        order.RecordTypeId = ORDER_RECORDTYPEID_CONFERMA;
        insert order;

        ServiceRequest__c sr = new ServiceRequest__c();

        sr.ServicePoint__c = servPoint.Id;
        sr.ServicePointCode__c = servPoint.ServicePointCode__c;
        sr.Order__c = order.Id;
        sr.Type__c = HDT_UTL_Dependencies.TIPOLOGY_SALES;
        sr.Status__c = HDT_UTL_Dependencies.STATUS_BOZZA;
        sr.ProcessType__c = PROCESS_TYPE;
        insert sr;

        order.Phase__c = PHASE_INC_NEXT;
        order.Contact__c = contact.Id;
            
        update order;

        Order orderAfterUpdate = [SELECT ID, Status, Phase__c FROM Order WHERE ID =: order.Id];
        ServiceRequest__c srAfterUpdate = [SELECT ID, Status__c, DependOn__c, NextPhase__c FROM ServiceRequest__c WHERE Order__c =: order.Id];
        System.debug(LoggingLevel.DEBUG,orderAfterUpdate);
        System.debug(LoggingLevel.DEBUG,srAfterUpdate);
        System.assertEquals('Sequenzializzato', orderAfterUpdate.Status, 'Test OK Status');
        System.assertEquals('Sequenzializzato', orderAfterUpdate.Phase__c, 'Test OK Phase');
        Test.stopTest();

    }
}

