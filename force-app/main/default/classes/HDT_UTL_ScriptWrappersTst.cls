/**
 * @description       : Test class for HDT_UTL_ScriptWrappers
 * @author            : gabriele.rota@webresults.it
 * @group             : WR
 * @last modified on  : 2021-11-02
 * @last modified by  : gabriele.rota@webresults.it
**/
@isTest
public class HDT_UTL_ScriptWrappersTst {
    
    /**
    * @description Testing HDT_WRP_ScriptOutput full constructor
    * @author gabriele.rota@webresults.it | 2021-11-02 
    **/
    @isTest
    static void scriptOutputTestFull() {
        ScriptConfig__c section = new ScriptConfig__c();
        section.SectionLabel__c = 'Title';
        section.ScriptType__c = 'Decisionale';
        section.NextSection__c = 2;
        section.LabelOption1__c = 'Si::3';
        section.LabelOption2__c = 'No::4';
        section.LabelOption3__c = 'Forse::5';

        Test.startTest();
        HDT_UTL_ScriptWrappers.HDT_WRP_ScriptOutput scrOutput = new HDT_UTL_ScriptWrappers.HDT_WRP_ScriptOutput(section, 'Content', null);
        Test.stopTest();

        System.assertEquals(2, scrOutput.nextSection, 'Next Section has not been read properly');
        System.assertEquals('Si', scrOutput.decisions[0].label, 'Decision Label has not been read properly');
        System.assertEquals(4, scrOutput.decisions[1].targetPage, 'Decision Target Page has not been read properly');
        System.assertNotEquals(null, scrOutput.decisions[2].targetPage, 'Decision Target Page has not been read properly');
    }

    /**
    * @description Testing HDT_WRP_ScriptOutput empty constructor
    * @author gabriele.rota@webresults.it | 2021-11-02 
    **/
    @isTest
    static void scriptOutputTestEmpty() {
        ScriptConfig__c section = new ScriptConfig__c();
        section.SectionLabel__c = 'Title';
        section.NextSection__c = 2;
        section.LabelOption1__c = 'Si::3';

        Test.startTest();
        HDT_UTL_ScriptWrappers.HDT_WRP_ScriptOutput scrOutput = new HDT_UTL_ScriptWrappers.HDT_WRP_ScriptOutput(section);
        Test.stopTest();

        System.assertEquals(2, scrOutput.nextSection, 'Next Section has not been read properly');
        System.assertNotEquals('Title', scrOutput.sectionLabel, 'Section Title is not null');
        System.assertEquals(null, scrOutput.decisions, 'Decisions are not null');
    }

    /**
    * @description Testing HDT_WRP_ScriptCondition
    * @author gabriele.rota@webresults.it | 2021-11-02 
    **/
    @isTest
    static void scriptConditionTest() {
        
        Test.startTest();
        HDT_UTL_ScriptWrappers.HDT_WRP_ScriptCondition scrCondEqual = new HDT_UTL_ScriptWrappers.HDT_WRP_ScriptCondition('Name == XXX');
        HDT_UTL_ScriptWrappers.HDT_WRP_ScriptCondition scrCondNotEqual = new HDT_UTL_ScriptWrappers.HDT_WRP_ScriptCondition('Name != XXX');
        HDT_UTL_ScriptWrappers.HDT_WRP_ScriptCondition scrCondLike = new HDT_UTL_ScriptWrappers.HDT_WRP_ScriptCondition('Name LIKE XXX');
        HDT_UTL_ScriptWrappers.HDT_WRP_ScriptCondition scrCondNotLike = new HDT_UTL_ScriptWrappers.HDT_WRP_ScriptCondition('Name NOT LIKE XXX');

        Boolean testEqual = scrCondEqual.checkCondition('XXX');
        Boolean testNotEqual = scrCondNotEqual.checkCondition('XXX');
        Boolean testLike = scrCondLike.checkCondition('AAXXX');
        Boolean testNotLike = scrCondNotLike.checkCondition('AAXXX');

        Test.stopTest();

        System.assertEquals(true, testEqual, 'Condition has not been evaluated properly');
        System.assertNotEquals(true, testNotEqual, 'Condition has not been evaluated properly');
        System.assertEquals(true, testLike, 'Condition has not been evaluated properly');
        System.assertNotEquals(true, testNotLike, 'Condition has not been evaluated properly');
    }
}
