/**
 * @author Valere (valere@noeli-it.net)
 * @date 15/09/2021
 * @description HDT_QR_PercentageRulesForAssigningVisits Test Class
 * @history valere - 15/09/2021– Created Class
 */
@isTest
public class HDT_QR_PercentagRuleForAssignVisitsTst {
@testSetup
    static void setup(){
        VisitAssignmentRules__c va = HDT_UTL_DataFactoryTst.createVisitAssignmentRules (1, true,'Default')[0];
        HDT_UTL_DataFactoryTst.createPercentageRulesForAssigningVisits(1, true,'pfTest',va.id);
    }
    @isTest
    static void getRecordByIdTest(){
        string id = [SELECT id,name FROM PercentageRulesForAssigningVisits__c limit 1].id;
        PercentageRulesForAssigningVisits__c pf = HDT_QR_PercentageRulesForAssigningVisits.getRecordById(id);
        system.assertEquals('pfTest',pf.name);
        system.assertNotEquals(null,pf.name,'because the name value of this record has been provided');
    }
    @isTest
    static void getRecordsByVisitAssignmentRulesTest(){
         string id = [SELECT id,name FROM VisitAssignmentRules__c limit 1].id;
       PercentageRulesForAssigningVisits__c[] pfList = HDT_QR_PercentageRulesForAssigningVisits.getRecordsByVisitAssignmentRules(id);
        system.assertEquals(1,pfList.size());
        system.assertNotEquals(0,pfList.size(),'because we have inserted a PercentageRulesForAssigningVisits__c record linked to the assignment rule whose we are passing the id');
    }
     @isTest
    static void getDefaultValueTest(){
       PercentageRulesForAssigningVisits__c[] pfList = HDT_QR_PercentageRulesForAssigningVisits.getDefaultValue();
        system.assertEquals(1,pfList.size());
        system.assertNotEquals(0,pfList.size(),'we have 1 record with the default value');
    }
}