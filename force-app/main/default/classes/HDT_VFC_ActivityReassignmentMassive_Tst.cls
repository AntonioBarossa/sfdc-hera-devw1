@isTest
public with sharing class HDT_VFC_ActivityReassignmentMassive_Tst {
    @TestSetup
    static void makeData(){
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.createActivityCustom(1, true, null);
    }

    @isTest
    public static void test() {
        Test.startTest();
        List<wrts_prcgvr__Activity__c> activities = [SELECT Id FROM wrts_prcgvr__Activity__c];
        new HDT_VFC_ActivityReassignmentMassive(new ApexPages.StandardSetController(activities));
        Test.stopTest();
    }
}