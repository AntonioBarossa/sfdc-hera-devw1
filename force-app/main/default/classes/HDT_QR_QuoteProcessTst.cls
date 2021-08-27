/**
 * @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
 * @date 25/08/2021
 * @description HDT_QR_QuoteProcess Test Classes
 * @history Lucas da Silva Fernandes – 25/08/2021 – Created Class
 */

@isTest
public with sharing class HDT_QR_QuoteProcessTst {

    private static HDT_QR_QuoteProcess qrProcess = new HDT_QR_QuoteProcess();

    @TestSetup
    static void setup(){
        
        List<SBQQ__QuoteProcess__c> qProcessList = HDT_UTL_DataFactoryTst.createQuoteProcess(1, false);
        qProcessList[0].Name = 'Vendita Guidata Offerte';

        insert qProcessList;
    }

    @isTest
    public static void testGetProcessForGroupAssoc() {

        Test.startTest();

        SBQQ__QuoteProcess__c quoteProcess = [SELECT Id, SBQQ__ProductSearchExecutor__c FROM SBQQ__QuoteProcess__c WHERE SBQQ__ProductConfigurationInitializer__c = 'initializerTest'];

        List<SBQQ__QuoteProcess__c> qpList = qrProcess.getProcessForGroupAssoc();

        System.assertEquals(quoteProcess.SBQQ__ProductSearchExecutor__c, qpList[0].SBQQ__ProductSearchExecutor__c, 'Quote Process match.');
        System.assertNotEquals(null, qpList[0].SBQQ__ProductSearchExecutor__c, 'Quote Process does not match');        

        Test.stopTest();
    }
    
    
}
