/*
 * @author Laureta Demishaj (laureta.demishaj@dunegroup.it)
 * @date 22/09/2021
 * @description HDT_LC_ComfortQualityCallResult for Test Classes
 * @history Laureta Demishaj – 22/09/2021 – Created class
*/
@isTest
public with sharing class HDT_LC_ComfortQualityCallResultTst {

    @isTest
    public static void initTest() {
        HDT_UTL_DataFactoryTst.pClickInstanceActivityIntegration();
        List<Account> accList                       = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<wrts_prcgvr__Activity__c> activityList = HDT_UTL_DataFactoryTst.createActivityCustom(1, false, accList[0].Id);
        activityList[0].Type__c                     = 'Quality Call';
        insert activityList[0];
        Test.startTest();
        Boolean result = HDT_LC_ComfortQualityCallResult.init(activityList[0].Id);
        System.assertEquals(true, result, 'The method worked when given the Id of an Activity(Custom) with Type__c equals Quality Call');
        System.assertNotEquals(false, result, 'The method worked, the result is not false');
        Test.stopTest();    
    }
    @isTest
	public static void checkPermissionTst() {
        Test.startTest();
        Boolean res = HDT_LC_ComfortQualityCallResult.checkPermission();
        Test.stopTest();
	}
}