/**
* @author Luis Bispo (luis.bispo@engdb.com.br)
* @date 24/08/2021
* @description HDT_QR_Sale for Test Classes
* @history Luis Bispo – 24/08/2021 – Created class
*/
@isTest
public with sharing class HDT_QR_SaleTst {
    @TestSetup
    static void setup(){
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Sale__c> saleList = HDT_UTL_DataFactoryTst.createSale(1, true, accList[0].Id, 'Attiva');
    }

    @isTest
    static void testGetRecordById() {
        Test.startTest();

        Sale__c tSale = [SELECT Id, Status__c FROM Sale__c WHERE Status__c = 'Attiva' LIMIT 1];
    
        Sale__c qrSale = new HDT_QR_Sale().getRecordById(tSale.Id, 'Status__c');
    
        System.assertEquals('Attiva', qrSale.Status__c, 'Sale__c Status not populated correctly');
        System.assertNotEquals('Bozza', qrSale.Status__c, 'Value of parameter is not matching');
    
        Test.stopTest(); 

    }
}