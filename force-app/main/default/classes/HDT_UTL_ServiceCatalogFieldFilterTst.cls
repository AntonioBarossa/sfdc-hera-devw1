/*
    @Author:        Davide Viola
    CreatedDate:    16/11/2021
*/

@isTest
public class HDT_UTL_ServiceCatalogFieldFilterTst {

    @TestSetup
    static void setup(){

        HDT_UTL_DataFactoryTst.createAccountBusiness(2, true, 'HERA COMM', 'Azienda', 'Aziende SME');
    }

    @isTest public static void testEvaluate(){

        Map<String, Object> argsMap = new Map<String, Object>();

        Account acc = [SELECT Id, IsDigitalMarking__c, IsWrongFiscalData__c FROM Account LIMIT 1];
        argsMap.put('record', acc);

        Test.startTest();

        HDT_UTL_ServiceCatalogFieldFilter servCatalFilter = new HDT_UTL_ServiceCatalogFieldFilter();
        Boolean res = servCatalFilter.evaluate(argsMap);
        
        Test.stopTest();

        System.assertEquals(res, False, 'Condizione verificata');
    }
}