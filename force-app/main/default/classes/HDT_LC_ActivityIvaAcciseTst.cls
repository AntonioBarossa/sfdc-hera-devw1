/*
 * @author Laureta Demishaj (laureta.demishaj@dunegroup.it)
 * @date 05/10/2021
 * @description HDT_LC_ActivityIvaAccise for Test Classes
 * @history Laureta Demishaj – 05/10/2021 – Created class
*/
@isTest
public class HDT_LC_ActivityIvaAcciseTst {
    
    @TestSetup
    static void myData(){
     List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
     List<wrts_prcgvr__Activity__c> actCustomList = HDT_UTL_DataFactoryTst.createActivityCustom(1, true, accList[0].Id);
    }
    
    @isTest
    public static void getInitActivityTst(){
        List<wrts_prcgvr__Activity__c> actCust = [SELECT Id FROM wrts_prcgvr__Activity__c];
        Id recordId = actCust[0].Id;
        Test.startTest();
        wrts_prcgvr__Activity__c response = HDT_LC_ActivityIvaAccise.getInitActivity(recordId);
        Test.stopTest();
        List<wrts_prcgvr__Activity__c> expectedResponse = [SELECT Id FROM wrts_prcgvr__Activity__c];
        System.assertEquals(expectedResponse[0].Id, response.Id, 'There is no initial activity custom');
        System.assertNotEquals(null, response, 'The response is null');
    }
    
    @isTest
    public static void saveActivityTst(){
      List<wrts_prcgvr__Activity__c> actCust = [SELECT Id, CreatedDate, wrts_prcgvr__Status__c, ageing__c, CompletationDateDocument__c FROM wrts_prcgvr__Activity__c];
      Test.startTest();
      HDT_LC_ActivityIvaAccise.saveActivity(actCust[0], true);
      Test.stopTest();
      List<wrts_prcgvr__Activity__c> expectedResponse = [SELECT Id FROM wrts_prcgvr__Activity__c WHERE wrts_prcgvr__Status__c = 'Completed'];
      System.assertEquals(expectedResponse[0].Id, actCust[0].Id, 'The closed Activity wasnt updated');
      System.assertNotEquals(null, expectedResponse[0].Id, 'The closed Activity wasnt updated');    
    }
    
    @isTest
    public static void sospendiActivityTst(){
        List<wrts_prcgvr__Activity__c> actCust = [SELECT Id FROM wrts_prcgvr__Activity__c];
        Test.startTest();
        boolean response = HDT_LC_ActivityIvaAccise.sospendiActivity(actCust[0].Id);
        Test.stopTest();
        System.assertEquals(true, response,'The activity wasn\'t sospended');
        System.assertNotEquals(false, response,'The activity wasn\'t sospended');
    }
    
     @isTest
    public static void sospendiActivityNegativeTst(){
        Test.startTest();
        boolean response = HDT_LC_ActivityIvaAccise.sospendiActivity(null);
        Test.stopTest();
        System.assertEquals(false, response,'The method shouldn\'t work since the parameter was null');
        System.assertNotEquals(true, response,'The method shouldn\'t work since the parameter was null');
    } 
        
    @isTest
    public static void riprendiActivityTst(){
        List<wrts_prcgvr__Activity__c> actCust = [SELECT Id FROM wrts_prcgvr__Activity__c];
        Test.startTest();
        boolean response = HDT_LC_ActivityIvaAccise.riprendiActivity(actCust[0].Id);
        Test.stopTest();
        System.assertEquals(true, response,'The activity wasn\'t resumed');
        System.assertNotEquals(false, response,'The activity wasn\'t resumed');
    }
    
    @isTest
    public static void riprendiActivityNegativeTst(){
        Test.startTest();
        boolean response = HDT_LC_ActivityIvaAccise.riprendiActivity(null);
        Test.stopTest();
        System.assertEquals(false, response,'The method shouldn\'t work since the parameter was null');
        System.assertNotEquals(true, response,'The method shouldn\'t work since the parameter was null');
        }
   
     @isTest
     public static void saveAttemptTst(){
     List<wrts_prcgvr__Activity__c> actCust = [SELECT Id FROM wrts_prcgvr__Activity__c];
     Test.startTest();
     boolean response = HDT_LC_ActivityIvaAccise.saveAttempt(actCust[0].Id, '3');
     Test.stopTest();
     System.assertEquals(true, response,'The activity wasn\'t saved');
     System.assertNotEquals(false, response,'The activity wasn\'t saved');
     }
    
     @isTest
     public static void saveAttemptNegativeTst(){
     Test.startTest();
     boolean response = HDT_LC_ActivityIvaAccise.saveAttempt(null,'3');
     Test.stopTest();
     System.assertEquals(false, response,'The method shouldn\'t work since the parameter was null');
     System.assertNotEquals(true, response,'The method shouldn\'t work since the parameter was null');
     }
}