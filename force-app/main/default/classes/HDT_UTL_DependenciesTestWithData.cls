/**
* @author Andrea Arosio (andrea.arosio@webresults.it)
* @date 19/07/2021
* @description Test Class for HDT_UTL_Dependencies – Classe di utilità per la gestione della sequenzializzazione dei processi
*/
@isTest
public with sharing class HDT_UTL_DependenciesTestWithData {

    @isTest(SeeAllData=true)
    static void sequentializationOrderTest() {
        
        final String ORDER_TYPE = 'Cambio Offerta';
        final String PROCESS_TYPE = 'Cambio offerta - EE';
        final String ORDER_RECORDTYPEID_CONFERMA =
        Schema.SObjectType.Order.getRecordTypeInfosByName().get(ORDER_TYPE).getRecordTypeId();
        final String PHASE_BLK = 'In attesa conferma cliente';
        final String PHASE_INC = 'Bozza';
        final String PHASE_INC_NEXT = 'Comunicazione verso Heroku';
        
        Test.startTest();
        
        List<Account> accList = [Select CompanyOwner__c From Account WHERE CompanyOwner__c like 'HERA%' LIMIT 2];
        if(accList.size()==0){
            accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        }
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
            System.assertEquals('Sequenzializzato', orderAfterUpdate.Phase__c);
        }
        Test.stopTest();

    }
}
