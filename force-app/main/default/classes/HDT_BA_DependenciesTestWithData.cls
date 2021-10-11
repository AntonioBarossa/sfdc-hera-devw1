/**
* @author Andrea Arosio (andrea.arosio@webresults.it)
* @date 22/07/2021
* @description Test Class for HDT_BA_Dependencies – Classe Batch per lo sblocco dei processi sequenzializzati
*/
@isTest
public with sharing class HDT_BA_DependenciesTestWithData {
    
    @isTest(SeeAllData=true)
    static void batchDesquentializationTest(){
        final String ORDER_TYPE = 'Cambio Offerta';
        final String PROCESS_TYPE = 'Cambio offerta - EE';
        final String ORDER_RECORDTYPEID_CONFERMA =
        Schema.SObjectType.Order.getRecordTypeInfosByName().get(ORDER_TYPE).getRecordTypeId();
        final String STATUS_CANCELLED = 'Annullato';
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
        ServiceRequest__c sr = new ServiceRequest__c();
        for(Order order : ordListBlk){
            
            order.RecordTypeId = ORDER_RECORDTYPEID_CONFERMA;
            order.Phase__c = PHASE_BLK;
            order.Status = STATUS_CANCELLED;
            insert order;

            sr.ServicePoint__c = servPointList[0].Id;
            sr.ServicePointCode__c = servPointList[0].ServicePointCode__c;
            sr.Order__c = order.Id;
            sr.Type__c = HDT_UTL_Dependencies.TIPOLOGY_SALES;
            sr.Status__c = STATUS_CANCELLED;
            sr.ProcessType__c = PROCESS_TYPE;
            insert sr;
            System.debug(sr);
        }
        List<Order> ordListInc = HDT_UTL_DataFactoryTst.createOrder(1, false, accList[0].id, 'Bozza'); 
        
        for(Order order : ordListInc){
            
            order.RecordTypeId = ORDER_RECORDTYPEID_CONFERMA;
            order.Phase__c = PHASE_INC_NEXT;
            order.Contact__c = contactList[0].Id;
            insert order;

            ServiceRequest__c srSeq = new ServiceRequest__c();

            srSeq.ServicePoint__c = servPointList[0].Id;
            srSeq.ServicePointCode__c = servPointList[0].ServicePointCode__c;
            srSeq.Order__c = order.Id;
            srSeq.Type__c = HDT_UTL_Dependencies.TIPOLOGY_SALES;
            srSeq.Status__c = HDT_UTL_Dependencies.STATUS_SEQUENZIALIZZATO;
            srSeq.DependOn__c = sr.Id;
            srSeq.NextPhase__c = PHASE_INC_NEXT;
            srSeq.ProcessType__c = PROCESS_TYPE;
            insert srSeq;
            System.debug(srSeq);
        }

        HDT_BA_Dependencies bad = new HDT_BA_Dependencies();
        Id batchId = Database.executeBatch(bad);

        Test.stopTest();
        System.debug([SELECT count() FROM wrts_prcgvr__AsyncJob__c]);
        System.assertEquals(0, [select count() from ServiceRequest__c where Status__c =: HDT_UTL_Dependencies.STATUS_SEQUENZIALIZZATO], 'Value of parameter is matching');
        System.assertNotEquals(1, [select count() from ServiceRequest__c where Status__c =: HDT_UTL_Dependencies.STATUS_SEQUENZIALIZZATO], 'Value of parameter is not matching');
    }
}