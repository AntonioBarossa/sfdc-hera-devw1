/**
* @author Andrea Arosio (andrea.arosio@webresults.it)
* @date 19/07/2021
* @description Test Class for DT_UTL_Dependencies – Classe di utilità per la gestione della sequenzializzazione dei processi
*/
@isTest
public with sharing class HDT_UTL_DependenciesTest {

    // @testSetup
    // static void setup() {
    //     wrts_prcgvr.PostInstall postinstall = new wrts_prcgvr.PostInstall();
    //     Test.testInstall(postinstall, null);
    //     List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
    //     List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(2, true, accList[0].id, 'Bozza');
    // }

    @isTest(SeeAllData=true)
    static void sequentializationTest() {
        
        final String PROCESS_TYPE = 'Cambio offerta - EE';
        final String ORDER_RECORDTYPEID_CONFERMA =
        Schema.SObjectType.Order.getRecordTypeInfosByName().get(PROCESS_TYPE).getRecordTypeId();
        final String SERVICE_POINT_CODE = 'IT001E00031754';
        final String PHASE_BLK = 'In attesa conferma cliente';
        final String PHASE_INC = 'Bozza';
        final String PHASE_INC_NEXT = 'Comunicazione verso Heroku';
        
        Test.startTest();
        
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordListBlk = HDT_UTL_DataFactoryTst.createOrder(1, false, accList[0].id, PHASE_INC); 
        ServicePoint__c sp = [SELECT id, ServicePointCode__c FROM ServicePoint__c WHERE ServicePointCode__c =: SERVICE_POINT_CODE];

        for(Order order : ordListBlk){
            
            order.RecordTypeId = ORDER_RECORDTYPEID_CONFERMA;
            order.Phase__c = PHASE_BLK;
            order.Status = HDT_UTL_Dependencies.STATUS_LAVORAZIONE;
            insert order;

            ServiceRequest__c sr = new ServiceRequest__c();

            sr.ServicePoint__c = sp.Id;
            sr.ServicePointCode__c = sp.ServicePointCode__c;
            sr.Order__c = order.Id;
            sr.Type__c = HDT_UTL_Dependencies.TIPOLOGY_SALES;
            sr.Status__c = HDT_UTL_Dependencies.STATUS_LAVORAZIONE;
            sr.ProcessType__c = PROCESS_TYPE;
            insert sr;
            System.debug(sr);
        }

        List<Order> ordListInc = HDT_UTL_DataFactoryTst.createOrder(1, false, accList[0].id, 'Bozza'); 
        
        for(Order order : ordListInc){
            
            order.RecordTypeId = ORDER_RECORDTYPEID_CONFERMA;
            insert order;

            ServiceRequest__c sr = new ServiceRequest__c();

            sr.ServicePoint__c = sp.Id;
            sr.ServicePointCode__c = sp.ServicePointCode__c;
            sr.Order__c = order.Id;
            sr.Type__c = HDT_UTL_Dependencies.TIPOLOGY_SALES;
            sr.Status__c = HDT_UTL_Dependencies.STATUS_BOZZA;
            sr.ProcessType__c = PROCESS_TYPE;
            insert sr;
            System.debug(sr);

            order.Phase__c = PHASE_INC_NEXT;
            order.Contact__c = '0031X00000gI5K8QAK';
            
            update order;

            Order orderAfterUpdate = [SELECT ID, Status, Phase__c FROM Order WHERE ID =: order.Id];
            System.debug(orderAfterUpdate);
        }
        Test.stopTest();

    }
}
