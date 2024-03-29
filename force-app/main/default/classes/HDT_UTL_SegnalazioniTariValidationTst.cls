/**
 * @description       : 
 * @author            : Giacinto Florio
 * @group             : 
 * @last modified on  : 29-08-2022
 * @last modified by  : Giacinto Florio
**/
@isTest
public with sharing class HDT_UTL_SegnalazioniTariValidationTst {
    
    @TestSetup
    static void setup(){

        HDT_UTL_DataFactoryTst.pClickCasePhase();
        
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);    
        
    }

    @isTest
    public static void segnalazioniAmbienteValidateTest() {

        Case caso = [SELECT Id, Type FROM Case LIMIT 1];
        caso.InvoicingCity__c='';
        caso.Type = 'Segnalazioni Ambientali';
        update caso;
        HDT_UTL_SegnalazioniTariValidation tariValidation = new HDT_UTL_SegnalazioniTariValidation();
        Test.startTest();
        String fields= '{"AlternativeAddress__c":null}';
        String result = tariValidation.validate(fields, caso.Id);
        System.assertEquals(result, '{"outcomeDescription":"Inserire Indirizzo!","outcomeCode":"Error"}','Inserire Indirizzo!');
        Test.stopTest();
    }

    @isTest
    public static void gestioneRifiutiValidateTest() {

        Case caso = [SELECT Id, Type FROM Case LIMIT 1];
        caso.InvoicingCity__c='';
        caso.Type = 'Gestione Rifiuti';
        update caso;
        HDT_UTL_SegnalazioniTariValidation tariValidation = new HDT_UTL_SegnalazioniTariValidation();
        Test.startTest();
        String fields = '{"OperationGroup__c": "null"}';
        String result = tariValidation.validate(fields, caso.Id);
        System.assertEquals(result, '{"outcomeDescription":"Inserire Indirizzo!","outcomeCode":"Error"}', 'Inserire Indirizzo!');
        
        caso.InvoicingCity__c = 'testCity';
        tariValidation.gestioneRifiutiValidate(caso, fields);
        tariValidation.segnalazioniAmbienteValidate(caso, fields);
        Test.stopTest();
    }   

    @isTest
    public static void getMetadata() {
        list<HDT_SegnalazioniAmbientali__mdt> metas = HDT_UTL_SegnalazioniTariValidation.getMaterialOptions('test1', 'test2');
        system.assertEquals(metas.size(), 0, 'Unexpected metadata retrieved');
    } 
}
