/**
 * @description       : 
 * @author            : Giacinto Florio
 * @group             : 
 * @last modified on  : 05-07-2022
 * @last modified by  : Giacinto Florio
**/
public with sharing class HDT_LC_StringGenerationForDocument {

    @AuraEnabled
    public static List<StaticStringForDocuments__c> getUniqueString(String comune, String caseProcess, String caseSubProcess){
        try {
            
            List<StaticStringForDocuments__c> result = new List<StaticStringForDocuments__c>();

            result = [SELECT Id, Municipality__c, Process__c , Subprocess__c , FixedString__c 
                      FROM StaticStringForDocuments__c
                      WHERE Process__c =:caseProcess AND Subprocess__c =:caseSubProcess AND Municipality__c =:comune
                      WITH SECURITY_ENFORCED];

            return  !result.isEmpty() ? result : [SELECT Id, Municipality__c, Process__c , Subprocess__c , FixedString__c 
                                                  FROM StaticStringForDocuments__c
                                                  WHERE Process__c =:caseProcess AND Subprocess__c =:caseSubProcess AND Municipality__c =null 
                                                  WITH SECURITY_ENFORCED];

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}