/**
* @author Andrea Arosio (andrea.arosio@webresults.it)
* @date 22/07/2021
* @description Test Class for HDT_BA_Dependencies – Classe Batch per lo sblocco dei processi sequenzializzati
*/
@SuppressWarnings('PMD.AvoidDebugStatements')
@isTest
public with sharing class HDT_BA_DependenciesTestWithoutData {

    @testSetup
    static void setup() {
        final String ORDER_TYPE = 'Cambio Offerta';
        final String PROCESS_TYPE = 'Cambio offerta - EE';
        final String ORDER_RECORDTYPEID_CONFERMA =
        Schema.SObjectType.Order.getRecordTypeInfosByName().get(ORDER_TYPE).getRecordTypeId();
        final String STATUS_CANCELLED = 'Annullato';
        final String PHASE_BLK = 'In attesa conferma cliente';
        final String PHASE_INC = 'Bozza';
        final String PHASE_INC_NEXT = 'Comunicazione verso Heroku';
        final String PHASE_INC_SEQ = 'Sequenzializzato';
        final String DEPENDENCY_MATCH = 'Service Point';

        wrts_prcgvr.PostInstall postinstall = new wrts_prcgvr.PostInstall();
        Test.testInstall(postinstall, null);

        HDT_UTL_DataFactoryTst.installPhaseManagerSObjectSetting('Order');
        HDT_UTL_DataFactoryTst.installCSDependecyPhaseCheckSetting('Comunicazione verso Heroku');

        HDT_UTL_DataFactoryTst.insertPhaseTransition(null,null,null,null, '','From Bozza To Heroku',
            PHASE_INC_NEXT,null,null,null,false, PHASE_INC, null,null,
            ORDER_RECORDTYPEID_CONFERMA, [Select DeveloperName from RecordType where Id =:ORDER_RECORDTYPEID_CONFERMA][0].DeveloperName, null, 'A', true);
        HDT_UTL_DataFactoryTst.insertPhaseTransition(null,null,null,null, '','From Bozza To Sequenzializzazione',
            PHASE_INC_SEQ,null,null,null,false, PHASE_INC, null,null,
            ORDER_RECORDTYPEID_CONFERMA, [Select DeveloperName from RecordType where Id =:ORDER_RECORDTYPEID_CONFERMA][0].DeveloperName, null, 'A', true);
        HDT_UTL_DataFactoryTst.insertPhaseTransition(null,null,null,null, '','From Sequenzializzazione To Heroku',
            PHASE_INC_NEXT,null,null,null,false, PHASE_INC_SEQ, null,null,
            ORDER_RECORDTYPEID_CONFERMA, [Select DeveloperName from RecordType where Id =:ORDER_RECORDTYPEID_CONFERMA][0].DeveloperName, null, 'A', true);
        HDT_UTL_DataFactoryTst.createDependenciesMatrix(1, true, PROCESS_TYPE, PROCESS_TYPE, PHASE_INC_NEXT, DEPENDENCY_MATCH);
        
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordListBlk = HDT_UTL_DataFactoryTst.createOrder(1, false, accList[0].id, PHASE_INC);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, false, accList[0].id); 
        contactList[0].Company__c = 'HCM';
        insert contactList; 
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);

        Order order = ordListBlk[0];
        
        order.RecordTypeId = ORDER_RECORDTYPEID_CONFERMA;
        order.Phase__c = PHASE_BLK;
        order.Status = STATUS_CANCELLED;
        insert order;

        ServiceRequest__c sr = new ServiceRequest__c();

        sr.ServicePoint__c = servPointList[0].Id;
        sr.ServicePointCode__c = servPointList[0].ServicePointCode__c;
        sr.Order__c = order.Id;
        sr.Type__c = HDT_UTL_Dependencies.TIPOLOGY_SALES;
        sr.Status__c = STATUS_CANCELLED;
        sr.ProcessType__c = PROCESS_TYPE;
        insert sr;
        System.debug(LoggingLevel.DEBUG, sr);
    }
    
    @isTest
    static void batchDesquentializationTest(){
        final String ORDER_TYPE = 'Cambio Offerta';
        final String PROCESS_TYPE = 'Cambio offerta - EE';
        final String ORDER_RECORDTYPEID_CONFERMA =
        Schema.SObjectType.Order.getRecordTypeInfosByName().get(ORDER_TYPE).getRecordTypeId();
        final String PHASE_INC_NEXT = 'Comunicazione verso Heroku';

        Account acc = [SELECT Id FROM Account WHERE Account.Name LIKE :'test account%' LIMIT 1];
        Contact contact = [SELECT Id FROM Contact WHERE Contact.Company__c = :'HCM' LIMIT 1];
        ServicePoint__c servPoint = [SELECT Id, ServicePointCode__c FROM ServicePoint__c WHERE ServicePointCode__c = :'testServicePointCode' LIMIT 1];
        ServiceRequest__c sr = [SELECT Id FROM ServiceRequest__c WHERE ServicePointCode__c = :'testServicePointCode' LIMIT 1];

        Test.startTest();

        List<Order> ordListInc = HDT_UTL_DataFactoryTst.createOrder(1, false, acc.id, 'Bozza'); 

        Order order = ordListInc[0];
        
        order.RecordTypeId = ORDER_RECORDTYPEID_CONFERMA;
        order.Phase__c = PHASE_INC_NEXT;
        order.Contact__c = contact.Id;
        insert order;

        ServiceRequest__c srSeq = new ServiceRequest__c();

        srSeq.ServicePoint__c = servPoint.Id;
        srSeq.ServicePointCode__c = servPoint.ServicePointCode__c;
        srSeq.Order__c = order.Id;
        srSeq.Type__c = HDT_UTL_Dependencies.TIPOLOGY_SALES;
        srSeq.Status__c = HDT_UTL_Dependencies.STATUS_SEQUENZIALIZZATO;
        srSeq.DependOn__c = sr.Id;
        srSeq.NextPhase__c = PHASE_INC_NEXT;
        srSeq.ProcessType__c = PROCESS_TYPE;
        insert srSeq;
        System.debug(LoggingLevel.DEBUG, srSeq);

        HDT_BA_Dependencies bad = new HDT_BA_Dependencies();
        Database.executeBatch(bad);

        Test.stopTest();
        System.assertEquals(0, [select count() from ServiceRequest__c where Status__c =: HDT_UTL_Dependencies.STATUS_SEQUENZIALIZZATO], 'Test OK');
    }
}