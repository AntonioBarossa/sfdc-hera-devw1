/**
* @author Elfrida Kora (elfrida.kora@dunegroup.it)
* @date 12/10/2021
* @description HDT_LC_ActivityScriptLauncher for Test Classes
* @history Elfrida Kora – 12/10/2021 – Created class
*/


@IsTest
public class HDT_LC_ActivityScriptLauncherTst {
    
     @TestSetup
    static void myData(){
        
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        HDT_UTL_DataFactoryTst.pClickCasePhase();
        
     List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
     List<wrts_prcgvr__Activity__c> actCustomList = HDT_UTL_DataFactoryTst.createActivityCustom(1, true, accList[0].Id);
     Id actListId = actCustomList[0].Id;
        
    }
    
     @isTest
    public static void testOne(){
        Test.startTest();
        
         List<wrts_prcgvr__Activity__c> actList = [SELECT Id,Status__c,Account__c,Name FROM wrts_prcgvr__Activity__c ];
        
    HDT_SRV_ScriptManager.HDT_WRP_ScriptConfig response = HDT_LC_ActivityScriptLauncher.getScriptConfig(actList[0].Id);
        
         System.assertEquals(true, response!=null, 'Value of parameter is matching');
         System.assertNotEquals(null, response, 'Value of parameter is not matching');
        
        Test.stopTest();     
        
    }
    
     @isTest
    public static void testNegative(){
        try{
            Test.startTest();
        
    HDT_SRV_ScriptManager.HDT_WRP_ScriptConfig response = HDT_LC_ActivityScriptLauncher.getScriptConfig(null);
        
        Test.stopTest(); 
        }
        catch(Exception e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'The exception throws an error message');
            System.assertNotEquals('', e.getMessage(), 'An exception is expected');
        }
    }

}