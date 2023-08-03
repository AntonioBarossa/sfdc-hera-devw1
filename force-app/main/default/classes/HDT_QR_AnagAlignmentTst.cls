@isTest
public with sharing class HDT_QR_AnagAlignmentTst {
    
    @TestSetup
    static void makeData(){
        List<ServicePoint__c> listOfServicePoint = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Account> accountList = HDT_UTL_DataFactoryTst.createAccountResidenziale(1, true, 'HERA COMM', 'Persona fisica', 'Famiglie');        
        List<Order> listOfOrder = HDT_UTL_DataFactoryTst.createOrder(1, false, accountList[0].Id, 'Registrazione validata');
        listOfOrder[0].DistributorPracticeCode__c = 'Test';
        listOfOrder[0].ServicePoint__c = listOfServicePoint[0].Id;
        listOfOrder[0].ProcessType__c = 'Prima Attivazione Ele';
        insert listOfOrder;
    }

    @isTest
    static void findServicePointByCode(){
        List<ServicePoint__c> listOfServicePoint = new List<ServicePoint__c>([SELECT Id, ServicePointCode__c FROM ServicePoint__c]);
        Test.startTest();
        HDT_QR_AnagAlignment query = new HDT_QR_AnagAlignment();
        query.findServicePointByCode(listOfServicePoint[0].ServicePointCode__c);
        Test.stopTest();
        System.assertEquals(false, listOfServicePoint.isEmpty());
    }

    @isTest
    static void findOrderByDistributorPracticeCode(){
        List<Order> listOfOrder = new List<Order>([SELECT Id, DistributorPracticeCode__c FROM Order]);
        Test.startTest();
        HDT_QR_AnagAlignment query = new HDT_QR_AnagAlignment();
        query.findOrderByDistributorPracticeCode(listOfOrder[0].DistributorPracticeCode__c);
        Test.stopTest();
        System.assertEquals(false, listOfOrder.isEmpty());
    }

    @isTest
    static void findOrderByTypeAndServicePointCode(){
        List<ServicePoint__c> listOfServicePoint = new List<ServicePoint__c>([SELECT Id, ServicePointCode__c FROM ServicePoint__c]);
        List<Order> listOfOrder = new List<Order>([SELECT Id, DocumentalProcessType__c FROM Order]);
        Test.startTest();
        HDT_QR_AnagAlignment query = new HDT_QR_AnagAlignment();
        query.findOrderByTypeAndServicePointCode(new Set<String>{listOfOrder[0].DocumentalProcessType__c}, listOfServicePoint[0].ServicePointCode__c);
        Test.stopTest();
        System.assertEquals(false, listOfServicePoint.isEmpty());
    }

    @isTest
    static void findRegionalAdditional(){
        List<HDT_RegionalAdditional__mdt> listOfCmdt = new List<HDT_RegionalAdditional__mdt>([SELECT Id FROM HDT_RegionalAdditional__mdt]);
        Test.startTest();
        HDT_QR_AnagAlignment query = new HDT_QR_AnagAlignment();
        query.findRegionalAdditional('Imposta usi non domestici iva 10% (Cod. G_ICC10)', '', 'ABRUZZO');
        Test.stopTest();
        System.assertEquals(false, listOfCmdt.isEmpty());
    }
    @isTest
    static void findRegionalAdditionalBulk(){
        List<HDT_RegionalAdditional__mdt> listOfCmdt = new List<HDT_RegionalAdditional__mdt>([SELECT Id FROM HDT_RegionalAdditional__mdt]);
        Test.startTest();
        HDT_QR_AnagAlignment query = new HDT_QR_AnagAlignment();
        query.findRegionalAdditionalBulk(new Set<String>{'Imposta usi non domestici iva 10% (Cod. G_ICC10)'}, new Set<String>{'test'}, new Set<String>{'test'});
        Test.stopTest();
        System.assertEquals(false, listOfCmdt.isEmpty());
    }
}