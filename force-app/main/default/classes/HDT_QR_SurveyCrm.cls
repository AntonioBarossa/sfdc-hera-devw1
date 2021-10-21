/**
* @author Lorenzo (lorenzo.gulotta@webresults.it)
* @date 31/05/2021
* @description HDT_QR_SurveyCrm
* @history Lorenzo – 31/05/2021 – created class
*/
public with sharing class HDT_QR_SurveyCrm {

    // public static List<SurveyCRM__c> getSurveys(List<String> campaignIds, String fields) {

    //     String query = 'SELECT '+ fields +' FROM SurveyCRM__c WHERE Campaign__c IN :campaignIds';
    //     List<SurveyCRM__c> surveys = Database.query(query);

    //     return surveys;

    // }

    public static List<SurveyCRM__c> getSurveys(List<String> campaignIds, String fields) {
        List<Campaign> campaigns = [SELECT Id, SurveyCRM__c FROM Campaign WHERE Id IN :campaignIds WITH SECURITY_ENFORCED];
        List<String> surveyIds = new List<String>();
        for (Campaign campaign : campaigns) {
            if (campaign.SurveyCRM__c != null) {
                surveyIds.add(campaign.SurveyCRM__c );
            }
        }
        //system.debug(surveyIds);
        //String query = 'SELECT '+ fields +' FROM SurveyCRM__c WHERE Id IN ' + surveyIds;


        SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.READABLE,Database.query( 'SELECT '+ String.escapeSingleQuotes( fields) +' FROM SurveyCRM__c WHERE Id IN :  surveyIds'));
        List<SurveyCRM__c> surveys =( List<SurveyCRM__c> ) securityDecision.getRecords();

        return surveys;

    }

    public static List<SurveyCRM__c> getSurvey(String id, String fields) {

        String query = 'SELECT '+ fields +' FROM SurveyCRM__c WHERE id = :id';
        List<SurveyCRM__c> surveys = Database.query( String.escapeSingleQuotes(query));
        return surveys;
    }
}