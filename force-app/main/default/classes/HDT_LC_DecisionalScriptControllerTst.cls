/**
* @author Elfrida Kora (elfrida.kora@dunegroup.it)
* @date 30/09/2021
* @description HDT_LC_DecisionalScriptController for Test Classes
* @history Elfrida Kora – 30/09/2021 – Created class
*/


@IsTest
public class HDT_LC_DecisionalScriptControllerTst {
    
    
    @TestSetup
    static void allData(){
       
      
      List<ScriptConfig__c> scList = HDT_UTL_DataFactoryTst.createScriptConfig(2,false);

        insert scList[0];
        
        ScriptConfig__c scon= scList[1];
        scon.TextScript__c= '<p>Fine</p>';
        scon.ScriptType__c = 'Processo';
        scon.SectionOrder__c = 1;
        scon.ParentSection__c = scList[0].Id;

        insert scon;


    }
    
    @isTest
    public static void testGetScriptPage(){
              Test.startTest();
         List<ScriptConfig__c> myConfList = new List<ScriptConfig__c>();
       myConfList = [SELECT Id,Name,CheckVisibility__c,ContextObject__c,textScript__c, SectionLabel__c, isChildLoopEvaluated__C,
                ScriptType__c, LabelOption1__c, LabelOption2__c, LabelOption3__c, NextSection__c from ScriptConfig__c];
                Id myConfId = myConfList[0].Id;
        
        List<ScriptConfig__c> checkList =[SELECT Name, contextObject__c, ChildRelationName__c,
            (SELECT textScript__c, SectionLabel__c, checkVisibility__c, isChildLoopEvaluated__C,
                ScriptType__c, LabelOption1__c, LabelOption2__c, LabelOption3__c, NextSection__c
                FROM ChildSections__r WHERE SectionOrder__c=1)
            FROM ScriptConfig__c WHERE Name='Hera' AND ScriptType__c='Processo' LIMIT 1];       

        HDT_LC_DecisionalScriptController.getScriptPage('Hera',myConfId,1);
        
         System.assertEquals(false,checkList.isEmpty(),'The method didnt returned the expected HDT_WRP_ScriptOutput given the right parameters');
         System.assertNotEquals(true,checkList.isEmpty(),'The confList is not expected to be empty');
                Test.stopTest();

    }
        }