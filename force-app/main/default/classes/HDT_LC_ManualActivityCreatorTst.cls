@isTest
public with sharing class HDT_LC_ManualActivityCreatorTst {
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();

    @TestSetup
	static void setup(){

        HDT_UTL_DataFactoryTst.pClickInstanceActivityIntegration();
        List<wrts_prcgvr__ActivityTemplate__c> actTmpList = HDT_UTL_DataFactoryTst.createActivityTemplate(1, false);
        actTmpList[0].wrts_prcgvr__ObjectType__c = 'Account';
        insert actTmpList;
        
        HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
    }

    @isTest
    private static void createActivityTst()
    {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        wrts_prcgvr__ActivityTemplate__c actTmp = [SELECT Name FROM wrts_prcgvr__ActivityTemplate__c LIMIT 1];

        Test.startTest();
        String result = HDT_LC_ManualActivityCreator.createActivity(actTmp.Name, acc.Id);
        Test.stopTest();

        List<wrts_prcgvr__Activity__c> actList = [SELECT Id FROM wrts_prcgvr__Activity__c WHERE Id = :result LIMIT 1];
         
        System.assertEquals( true, actList.size()>0, 'Not correctly insert');

    }

    @isTest
    private static void getAccountsTst()
    {
        Test.startTest();
        List<Account> accList = HDT_LC_ManualActivityCreator.getAccounts();
        Test.stopTest();
         
        System.assertEquals( false, accList.isEmpty(), 'Not correctly insert');
    }
}