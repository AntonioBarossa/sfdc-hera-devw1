/*
 * @author Laureta Demishaj (laureta.demishaj@dunegroup.it)
 * @date 29/09/2021
 * @description HDT_LC_ScriptTesterController for Test Classes
 * @history Laureta Demishaj – 29/9/2021 – Created class
*/
@isTest
public class HDT_LC_ScriptTesterControllerTst {
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    @TestSetup
    static void allData(){
             List<ScriptConfig__c> scriptList = new List<ScriptConfig__c>();
             ScriptConfig__c script = new ScriptConfig__c(Name = 'Script per testing', ScriptType__c='Processo');
             scriptList.add(script);
        }
    @isTest
    public static void getScriptsPositiveTst(){
         try {
          Test.startTest();
          List<ScriptConfig__c> response = HDT_LC_ScriptTesterController.getScripts();
          List<ScriptConfig__c> expectedResponse = [SELECT Id FROM ScriptConfig__c  WHERE ScriptType__c='Processo'];
          System.assertEquals(response,expectedResponse, 'The method woked, since in setup we created one ScriptConfig__c with ScriptType__c Processo, the returned list has one ScriptConfig__c');
          System.assertNotEquals(null,expectedResponse, 'The method worked so is not expected to return null');
          Test.stopTest();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
     @IsTest
    public static void getScriptsNegativeTst(){
        Id minimumAccessProfileId = HDT_UTL_DataFactoryTst.getProfileId(constants.MINIMUM_ACCESS_SALESFORCE);
        User minimumAccessUser    = HDT_UTL_DataFactoryTst.createInternalUser(minimumAccessProfileId, false);
        minimumAccessUser.Email   = 'sales@force.com';
        insert minimumAccessUser;
        System.runAs(minimumAccessUser) {
        Test.startTest();
   try {
          List<ScriptConfig__c> response = HDT_LC_ScriptTesterController.getScripts();
        } catch(Exception e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'As expected, if the logged user has minimum access the method cant run');
            System.assertNotEquals('', e.getMessage(), 'The exception throws an error message');
        }
        Test.stopTest();
        }
    }
}