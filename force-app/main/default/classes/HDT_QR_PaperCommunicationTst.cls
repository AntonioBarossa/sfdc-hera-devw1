/**
* @author Andrea Arosio (andrea.arosio@webresults.it)
* @date 12/10/2021
* @description Test Class for HDT_QR_PaperCommunication
*/
@isTest
public with sharing class HDT_QR_PaperCommunicationTst {
    @testSetup
    static void setup() {
        HDT_UTL_DataFactoryTst.createPaperCommunication(1, true);
    }

    @isTest
    public static void testGetRecordById() {

        Test.startTest();

        PaperCommunication__c tPaperCommTest = [SELECT Id, Name FROM PaperCommunication__c WHERE Name = 'test0' LIMIT 1];
        PaperCommunication__c tPaperComm = HDT_QR_PaperCommunication.getRecordById(tPaperCommTest.ID);
        System.assertEquals('test0', tPaperComm.Name, 'The query extracted the PaperCommunitcation__c with the incorrect Name');

        Test.stopTest();
    }
}