/**
* @author Lorenzo (lorenzo.gulotta@webresults.it)
* @date July/2021
* @description HDT_LC_CampaignSurvey
* @history Lorenzo – July/2021 – created class 
*/

public with sharing class HDT_LC_CampaignSurvey {
    private static HDT_QR_Contact contactQR = new HDT_QR_Contact();
    private static HDT_QR_CampaignMember campaignMemberQr = new HDT_QR_CampaignMember();
    private static HDT_QR_Campaign campaignQr = new HDT_QR_Campaign();

    @AuraEnabled(cacheable=true)
    public static SurveyCRM__c getSurvey(String objectApiName, String recordId){
        List<SurveyCRM__c> surveys= new List<SurveyCRM__c>();
        String fields = '';
        Map<String,Schema.SObjectField> surveymap = Schema.SObjectType.SurveyCRM__c.fields.getMap();
        for(String s: surveymap.keySet()){
            if(String.isNotBlank(fields)){
                fields+= ',';
            }
            fields+= surveymap.get(s);
        }
        system.debug(fields);
        if (objectApiName == 'Account') {
            String accountRecordId = recordId;
            List<Contact> contacts= contactQR.getContactsByAccount(accountRecordId);
            List<CampaignMember> campaignMember= new List<CampaignMember>();
            List<String> campaignMembersIds= new List<String>();

            if(contacts != null && contacts.size()>0){
                campaignMember= HDT_QR_CampaignMember.getCampaignMembersByContacts(contacts);
            }
            for(CampaignMember c: campaignMember){
                campaignMembersIds.add(c.CampaignId);
            }
            
            if(campaignMembersIds.size()>0){
                surveys= HDT_QR_SurveyCrm.getSurveys(campaignMembersIds, fields);
            }
        } else if (objectApiName == 'campaignmember') {
            String campaignMemberRecordId = recordId;
            CampaignMember campaignMemberRec = campaignMemberQr.getAccountAndCampaign(campaignMemberRecordId);
            String campaignId = campaignMemberRec.CampaignId;
            Campaign campaignRec = campaignQr.getSurveyCampaignById(campaignId);
            String surveyId = campaignRec.SurveyCRM__c;

            if(surveyId != ''){
                surveys= HDT_QR_SurveyCrm.getSurvey(surveyId, fields);
                System.debug(surveys);
            }
        } else {
            surveys = null;
        }
        return surveys != null ? surveys[0] : null;
    }

    @AuraEnabled
    public static SurveyResponse__c saveSurveyResponse(Map<String,String> responses, String campaignId){

        SurveyResponse__c surveyRes= new SurveyResponse__c();

        for(String field: responses.keySet()){
            surveyRes.put(field, responses.get(field));
        }

        HDT_SRV_SurveyResponse.checkCreateAccess(surveyRes);
        SurveyResponse__c s=HDT_SRV_SurveyResponse.createRecord(surveyRes);
        return s;
    }
}