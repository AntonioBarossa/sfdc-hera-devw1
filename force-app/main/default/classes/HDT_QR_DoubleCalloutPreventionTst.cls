/**
* @author Elvin Iluca
* @date 12/12/2022
* @description Test Class for HDT_QR_DoubleCalloutPrevention.cls
* @history Elvin Iluca – 12/12/2022 – Created class
*/

@isTest
public with sharing class HDT_QR_DoubleCalloutPreventionTst {
     /**​
    * @author Elvin Iluca
    * @date 12/12/2022
    * @description HDT_QR_DoubleCalloutPreventionTst – Test Class for HDT_QR_DoubleCalloutPrevention.cls
    */

    @TestSetup
	static void setup(){
        wrts_prcgvr__AsyncJob__c tst = new wrts_prcgvr__AsyncJob__c();
        tst.wrts_prcgvr__ApexClassName__c = 'HDT_SRV_SelfReadingsFacade';
        Id testId = [SELECT Id FROM ApexClass WITH SECURITY_ENFORCED LIMIT 1][0].Id;
        tst.wrts_prcgvr__JobItem__c = testId;
        tst.wrts_prcgvr__JobType__c = 'Callout';
        tst.wrts_prcgvr__ObjectType__c = 'Case';
        tst.wrts_prcgvr__MethodName__c = 'execute';
        insert tst;

    }

    @isTest
    static void getExistingCalloutByJobItem(){
        Map<Id, List<wrts_prcgvr__AsyncJob__c>> ret;
        Map<String,Object> args = new Map<String,Object>();
        Set<String> apexClasses = new Set<String>();
        apexClasses.add('HDT_SRV_SelfReadingsFacade'); 
        Set<String> methods = new Set<String>();
        methods.add('execute'); 
        Set<Id> recordIdList = new Set<Id>();
        Id testId = [SELECT Id, wrts_prcgvr__JobItem__c FROM wrts_prcgvr__AsyncJob__c WITH SECURITY_ENFORCED LIMIT 1][0].wrts_prcgvr__JobItem__c;
        recordIdList.add(testId);
        String objectType = 'Case';
        Datetime lastJobDate = Date.today().addDays(-1);
        args.put('apexClasses', apexClasses);
        args.put('recordIdList', recordIdList);
        args.put('methods', methods);
        args.put('objectName', objectType);
        args.put('date', lastJobDate);
        
        Test.startTest();
        ret = HDT_QR_DoubleCalloutPrevention.getExistingCalloutByJobItem(args);
        Test.stopTest();

        System.assertNotEquals(ret.isEmpty() , true, 'Error Double callout prevention');
    }

    @isTest
    static void getDoubleCalloutPreventionRecords(){
        List<HDT_DoubleCalloutPrevention__mdt> ret;

        Test.startTest();
        ret = HDT_QR_DoubleCalloutPrevention.getDoubleCalloutPreventionRecords(new Set<String>(), new Set<String>(), 'Case');
        Test.stopTest();
        System.assertNotEquals(ret.isEmpty() , true, 'Error Double callout prevention');
    }
}
