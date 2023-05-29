/**
 * @description       : 
 * @author            : Giacinto Florio
 * @group             : 
 * @last modified on  : 24-08-2022
 * @last modified by  : Giacinto Florio
**/
@isTest
public with sharing class HDT_UTL_TariCaseValidationTst {
    
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
    public static void scontiCollettiviValidateTest() {

        Case caso = [SELECT Id, Type FROM Case LIMIT 1];
        caso.InvoicingCity__c='';
        caso.Type = 'Sconti Collettivi Pap';
        update caso;
        HDT_UTL_TariCaseValidation tariValidation = new HDT_UTL_TariCaseValidation();
        Test.startTest();
        String fields= '{"Description":null}';
        String result = tariValidation.validate(fields, caso.Id);
        Map<String,Object> response = (Map<String,Object>) JSON.deserializeUntyped(result);
        System.assertEquals(String.valueOf(response.get('outcomeDescription')), 'Popolare il campo descrizione', 'Unexpected Result');
        Test.stopTest();
    }

    @isTest
    public static void annullamentoContrattiValidation() {

        Case caso = [SELECT Id, Type FROM Case LIMIT 1];
        caso.InvoicingCity__c='';
        caso.Type = 'Annullamento Contratti';
        update caso;
        HDT_UTL_TariCaseValidation tariValidation = new HDT_UTL_TariCaseValidation();
        Test.startTest();
        String fields= '{"Description":null}';
        String result = tariValidation.validate(fields, caso.Id);
        
        Map<String,Object> response = (Map<String,Object>) JSON.deserializeUntyped(result);
        System.assertEquals(String.valueOf(response.get('outcomeDescription')), 'Caricare almeno un allegato', 'Unexpected Result');

        caso.Channel__c ='Protocollo';
        update caso;
        result = tariValidation.validate(fields, caso.Id);
        response = (Map<String,Object>) JSON.deserializeUntyped(result);
        System.assertEquals(String.valueOf(response.get('outcomeDescription')), 'Caricare almeno un allegato', 'Unexpected Result');

        fields= '{"Description":null, "RequestSource__c" : "Da contribuente"}';
        result = tariValidation.validate(fields, caso.Id);
        response = (Map<String,Object>) JSON.deserializeUntyped(result);
        System.assertEquals(String.valueOf(response.get('outcomeCode')), 'OK', 'Unexpected KO');

        Test.stopTest();
    }

    @isTest
    public static void formulariValidateTest() {

        Case caso = [SELECT Id, Type FROM Case LIMIT 1];
        caso.InvoicingCity__c='';
        caso.Type = 'Formulari Richiesta Sconto';
        update caso;
        HDT_UTL_TariCaseValidation tariValidation = new HDT_UTL_TariCaseValidation();
        Test.startTest();
        String fields= '{"Description":null}';
        String result = tariValidation.validate(fields, caso.Id);
        Map<String,Object> response = (Map<String,Object>) JSON.deserializeUntyped(result);
        System.assertEquals(String.valueOf(response.get('outcomeDescription')), 'Caricare almeno un allegato', 'Unexpected Result');
        Test.stopTest();
    }   
}
