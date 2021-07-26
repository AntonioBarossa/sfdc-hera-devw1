/**
* @author Andrea Arosio (andrea.arosio@webresults.it)
* @date 19/07/2021
* @description Test Class for HDT_UTL_Dependencies – Classe di utilità per la gestione della sequenzializzazione dei processi
*/
@isTest
public with sharing class HDT_UTL_DependenciesTest {

    @isTest(SeeAllData=true)
    static void sequentializationOrderTest() {
        
        final String ORDER_TYPE = 'Cambio offerta';
        final String PROCESS_TYPE = 'Cambio offerta - EE';
        final String ORDER_RECORDTYPEID_CONFERMA =
        Schema.SObjectType.Order.getRecordTypeInfosByName().get(ORDER_TYPE).getRecordTypeId();
        final String PHASE_BLK = 'In attesa conferma cliente';
        final String PHASE_INC = 'Bozza';
        final String PHASE_INC_NEXT = 'Comunicazione verso Heroku';
        
        Test.startTest();
        
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordListBlk = HDT_UTL_DataFactoryTst.createOrder(1, false, accList[0].id, PHASE_INC);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, false, accList[0].id); 
        contactList[0].Company__c = 'HCM';
        insert contactList;
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);

        for(Order order : ordListBlk){
            
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

        List<Order> ordListInc = HDT_UTL_DataFactoryTst.createOrder(1, false, accList[0].id, 'Bozza'); 
        
        for(Order order : ordListInc){
            
            order.RecordTypeId = ORDER_RECORDTYPEID_CONFERMA;
            insert order;

            ServiceRequest__c sr = new ServiceRequest__c();

            sr.ServicePoint__c = servPointList[0].Id;
            sr.ServicePointCode__c = servPointList[0].ServicePointCode__c;
            sr.Order__c = order.Id;
            sr.Type__c = HDT_UTL_Dependencies.TIPOLOGY_SALES;
            sr.Status__c = HDT_UTL_Dependencies.STATUS_BOZZA;
            sr.ProcessType__c = PROCESS_TYPE;
            insert sr;

            order.Phase__c = PHASE_INC_NEXT;
            order.Contact__c = contactList[0].Id;
            
            update order;

            Order orderAfterUpdate = [SELECT ID, Status, Phase__c FROM Order WHERE ID =: order.Id];
            ServiceRequest__c srAfterUpdate = [SELECT ID, Status__c, DependOn__c, NextPhase__c FROM ServiceRequest__c WHERE Order__c =: order.Id];
            System.debug(orderAfterUpdate);
            System.debug(srAfterUpdate);
            System.assertEquals('Sequenzializzato', orderAfterUpdate.Status);
            System.assertEquals('In sequenzializzazione', orderAfterUpdate.Phase__c);
        }
        Test.stopTest();

    }
    // @isTest(SeeAllData=true)
    // static void sequentializationCaseTest() {
        
    //     final String PROCESS_TYPE = 'Cambio offerta - EE';
    //     final String CASE_RECORDTYPEID_CONFERMA =
    //     Schema.SObjectType.Case.getRecordTypeInfosByName().get(PROCESS_TYPE).getRecordTypeId();
    //     final String PHASE_BLK = 'In Attesa Approvazione';
    //     final String PHASE_INC = 'Bozza';
    //     final String PHASE_INC_NEXT = 'Comunicazione verso Heroku OK';
        
    //     Test.startTest();
        
    //     List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
    //     List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
    //     List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
    //     List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].id);
    //     List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
    //     List<Case> caseListBlk = HDT_UTL_DataFactoryTst.createCase(1, false, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);

    //     for(Case casePr : caseListBlk){
            
    //         casePr.RecordTypeId = CASE_RECORDTYPEID_CONFERMA;
    //         casePr.Phase__c = PHASE_BLK;
    //         casePr.Status = HDT_UTL_Dependencies.STATUS_LAVORAZIONE;
    //         casePr.VulturePracticeReference__c = ordList[0].Id;
    //         insert casePr;

    //         ServiceRequest__c sr = new ServiceRequest__c();

    //         sr.ServicePoint__c = servPointList[0].Id;
    //         sr.ServicePointCode__c = servPointList[0].ServicePointCode__c;
    //         sr.Case__c = casePr.Id;
    //         sr.Type__c = HDT_UTL_Dependencies.TIPOLOGY_SALES;
    //         sr.Status__c = HDT_UTL_Dependencies.STATUS_LAVORAZIONE;
    //         sr.ProcessType__c = PROCESS_TYPE;
    //         insert sr;
    //     }

    //     List<Case> caseListInc = HDT_UTL_DataFactoryTst.createCase(1, false, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id); 
        
    //     for(Case casePr : caseListInc){
            
    //         casePr.RecordTypeId = CASE_RECORDTYPEID_CONFERMA;
    //         casePr.Phase__c = PHASE_INC;
    //         casePr.VulturePracticeReference__c = ordList[0].Id;
    //         insert casePr;

    //         ServiceRequest__c sr = new ServiceRequest__c();

    //         sr.ServicePoint__c = servPointList[0].Id;
    //         sr.ServicePointCode__c = servPointList[0].ServicePointCode__c;
    //         sr.Case__c = casePr.Id;
    //         sr.Type__c = HDT_UTL_Dependencies.TIPOLOGY_SALES;
    //         sr.Status__c = HDT_UTL_Dependencies.STATUS_BOZZA;
    //         sr.ProcessType__c = PROCESS_TYPE;
    //         insert sr;

    //         casePr.Phase__c = PHASE_INC_NEXT;
            
    //         update casePr;

    //         Case casePrAfterUpdate = [SELECT ID, Status, Phase__c FROM Case WHERE ID =: casePr.Id];
    //         ServiceRequest__c srAfterUpdate = [SELECT ID, Status__c, DependOn__c, NextPhase__c FROM ServiceRequest__c WHERE Case__c =: casePr.Id];
    //         System.debug(casePrAfterUpdate);
    //         System.debug(srAfterUpdate);
    //         System.assertEquals('Sequenzializzato', casePrAfterUpdate.Status);
    //         System.assertEquals('In sequenzializzazione', casePrAfterUpdate.Phase__c);
    //     }
    //     Test.stopTest();

    //}
}
