/**
* @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
* @date 10/08/2021
* @description Test Class for HDT_TRH_PushTracking
* @history Lucas da Silva Fernandes – 10/08/2021 – Created class
*/
@isTest
public with sharing class HDT_TRH_PushTrackingTst {
    
    @isTest
    public static void testPushTrackingBeforeInsert() {

        Test.startTest();

        List<PushTracking__c> pushTrackingList = new List<PushTracking__c>();

        PushTracking__c pt = new PushTracking__c(
            CompanyOwner__c = 'HERA COMM'
        );

        pushTrackingList.add(pt);

        insert pushTrackingList;

        PushTracking__c ptTest = [SELECT Id FROM PushTracking__c WHERE CompanyOwner__c = 'HERA COMM' LIMIT 1];

        System.assertEquals(ptTest.Id, pushTrackingList[0].Id, 'Asset ID match.');

        System.assertNotEquals(pushTrackingList[0].Id, '', 'Asset ID does not match.');

        Test.stopTest();
    }
}
