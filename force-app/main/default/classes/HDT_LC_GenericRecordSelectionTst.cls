@isTest
public class HDT_LC_GenericRecordSelectionTst {

    @TestSetup
    static void setup(){

        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');

    }

    @isTest
    static void testGetConfiguration(){

        String searchKey = 'BillingProfile';

        Test.startTest();

        String configuration = HDT_LC_GenericRecordSelection.getConfiguration(searchKey);

        System.assert(!String.isBlank(configuration), 'Si è verificato un errore in fase di get della configurazione richiesta');
        Test.stopTest();

    }

    @isTest
    static void testGetListRecordsSOQL(){

        String paramsSOQL = '{"queryType":"SOQL","fields":"Name,BillingCityCode__c,CustomerCode__c,FiscalCode__c","limitStr":"1","objectName":"Account"}';
        
        Test.startTest();
        
        //SOQL Test
        
        List<List<SObject>> recordListSOQL = (List<List<SObject>>) JSON.deserialize((HDT_LC_GenericRecordSelection.getListRecords(paramsSOQL)), List<List<SObject>>.class);
        
        System.debug('recordList SOQL: ' + recordListSOQL);
        
        System.assert(recordListSOQL.get(0).size() > 0, 'Si è verificato un errore in fase di get del record');
       
        Test.stopTest();

    }

    @isTest
    static void testGetListRecordsSOSL(){

        String paramsSOSL = '{"queryType":"SOSL","fields":"Name,BillingCityCode__c,CustomerCode__c,FiscalCode__c","limitStr":"1","soslSearchTerm":"test account","objectName":"Account"}';

        Test.startTest();

        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        List<Id> idList = new List<Id>();
        idList.add(accId);

        //SOSL Test
        Test.setFixedSearchResults(idList);
        List<List<SObject>> recordListSOSL = (List<List<SObject>>) JSON.deserialize((HDT_LC_GenericRecordSelection.getListRecords(paramsSOSL)), List<List<SObject>>.class);

        System.debug('recordList SOSL: ' + recordListSOSL);

        System.assert(recordListSOSL.get(0).size() > 0, 'Si è verificato un errore in fase di get del record');

        Test.stopTest();
    }


    @isTest
    static void testGetDistinctRecords(){

        String paramsSOQL = '{"queryType":"SOQL","fields":"Name,BillingCityCode__c,CustomerCode__c,FiscalCode__c","limitStr":"1","objectName":"Account","distinct":"true"}';
        
        Test.startTest();
        
        //SOQL Test
        
        List<List<SObject>> recordListSOQL = (List<List<SObject>>) JSON.deserialize((HDT_LC_GenericRecordSelection.getListRecords(paramsSOQL)), List<List<SObject>>.class);
        
        System.debug('recordList SOQL: ' + recordListSOQL);
        
        System.assert(recordListSOQL.get(0).size() > 0, 'Si è verificato un errore in fase di get del record');
       
        Test.stopTest();
    
    }

}
