/**
* @author Andrea Arosio (andrea.arosio@webresults.it)
* @date 12/10/2021
* @description Test Class for HDT_QR_PaperCommunication
*/
@isTest
public with sharing class HDT_QR_PaperCommunicationTst {
    @testSetup
    static void setup() {
        PaperCommunication__c tPaperCommTest=new PaperCommunication__c();
        tPaperCommTest.Name='test';
        insert tPaperCommTest;
    }

    @isTest
    public static void testGetRecordById() {

        Test.startTest();

        PaperCommunication__c tPaperCommTest = [SELECT Id, Name FROM PaperCommunication__c WHERE Name = 'test' LIMIT 1];
        PaperCommunication__c tPaperComm = HDT_QR_PaperCommunication.getRecordById(tPaperCommTest.ID);
        System.assertEquals('test', tPaperComm.Name, 'Name match.');

        Test.stopTest();
    }
}
