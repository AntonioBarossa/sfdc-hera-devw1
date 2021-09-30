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
       
      
       ScriptConfig__c sc = new ScriptConfig__c();
        sc.Name = 'Hera';
        sc.ScriptType__c = 'Processo';	
        sc.CheckVisibility__c = 'frida';
        sc.ContextObject__c = 'Case';
        sc.SectionLabel__c = 'label';
        sc.LabelOption1__c = 'Roma';
        sc.LabelOption2__c = 'Milano';
        sc.LabelOption3__c = 'Tirana';
        sc.NextSection__c = 5;
        insert sc;
        
        ScriptConfig__c scon= new ScriptConfig__c();
        scon.TextScript__c= '<p>Fine</p>';
        scon.ScriptType__c = 'Processo';
        scon.SectionOrder__c = 1;
        scon.ParentSection__c = sc.Id;

        insert scon;


    }
    @isTest
    public static void testDecisionalScript(){
                Test.startTest();

       List<ScriptConfig__c> confList = new List<ScriptConfig__c>();
       confList = [SELECT Id,Name,ScriptType__c,CheckVisibility__c,ContextObject__c from ScriptConfig__c];

        HDT_LC_DecisionalScriptController.isDecisionalScript('test');
         System.assertEquals(false,confList.isEmpty(),'Method return is right');
         System.assertNotEquals(true,confList.isEmpty(),'Method return is wrong');

        Test.stopTest();
        

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
        
         System.assertEquals(false,checkList.isEmpty(),'Process return is right');
         System.assertNotEquals(true,checkList.isEmpty(),'Process return is wrong');
                Test.stopTest();

    }
        }