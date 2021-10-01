/**
 * Header of the class "HDT_TRH_AssignmentRuleTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_TRH_AssignmentRule"
 * @history
 * @Created 01/10/2021
 * Modified By:
 **/

@isTest
public class HDT_TRH_AssignmentRuleTst {

    @isTest
    static void test1(){
        
        Test.startTest();
        
        List<AssignmentRule__c> rules = HDT_UTL_DatafactoryTst.createAssignmentRule(1,true,1,'Annullamento');
        for(AssignmentRule__c ar : rules){
            ar.RulePriority__c = 1.1;
        }
        update rules;
        
        Test.stopTest();
        
        System.assertNotEquals(1.0, rules[0].RulePriority__c, 'AssignmentRule not updated');
        
        System.assertEquals(1, [SELECT id FROM AssignmentRule__c].size(), 'AssignmentRule not inserted');
        
    }
}