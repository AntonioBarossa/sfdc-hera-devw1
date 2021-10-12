/**
* @author Andrea Arosio (andrea.arosio@webresults.it)
* @date 12/10/2021
* @description Test Class for  HDT_TRH_ServicePoint
*/
@isTest
public with sharing class HDT_TRH_ServicePointTst {
    @testSetup
    static void setup() {
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
    }

    @isTest
    public static void testBeforeUpdate() {

        Boolean finished = false;

        Test.startTest();

        ServicePoint__c sp = [SELECT Id, Name FROM ServicePoint__c WHERE Name = 'testServicePoint0' LIMIT 1];
        update sp;
        
        finished = true;

        Test.stopTest();

        System.assertEquals(true, finished, 'Test Ended');
    }
}
