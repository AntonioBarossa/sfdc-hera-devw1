/**
* @author Luis Bispo (luis.bispo@engdb.com.br)
* @date 30/09/2021
* @description HDT_LC_CampaignSurvey for Test Classes
* @history Luis Bispo – 30/09/2021 – Created class
*/
@isTest
public with sharing class HDT_LC_CampaignSurveyTst {
    
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();

    @TestSetup
    static void setup(){
        
        Id adminUserProfileId = HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
 
        User internalUser = HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
 
        internalUser.UserPermissionsMarketingUser=true;
 
        insert internalUser;
 
        System.runAs(internalUser) {
            //seu testSetup   
            List<Account> accountList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
            List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1,true,accountList[0].Id); 
            List<SurveyCRM__c> surveyCrmList = HDT_UTL_DataFactoryTst.createSurveyCrm(1, true);
            List<Campaign> campaignList = HDT_UTL_DataFactoryTst.createCampaign(1, false);
            campaignList[0].Category__c = 'Campagna Outbound';
            campaignList[0].Channel__c = 'Bolletta';
            campaignList[0].SurveyCRM__c = surveyCrmList[0].Id;
            insert campaignList;
            List<Lead> leadList = HDT_UTL_DataFactoryTst.createLead(1, true);
			List<CampaignMember> campaignMemberList = HDT_UTL_DataFactoryTst.createCampaignMember(1, true, campaignList[0].Id, leadList[0].Id, contactList[0].Id);  
        }
    }   

    @isTest
    static void testGetSurveyAccount() {
        User tUser = [SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1]; 
        System.runAs(tUser){

            Test.startTest(); 
            Account tAccount = [SELECT Id FROM Account LIMIT 1];
            SurveyCRM__c newAccount = HDT_LC_CampaignSurvey.getSurvey('Account', tAccount.Id);

            System.assertEquals(true, tAccount != null, 'tAccount Id is not null');
			System.assertNotEquals(true, tAccount == null, 'tAccount Id is null');
        
            Test.stopTest();
        }
    }
    @isTest
    static void testGetSurveyCampaignMember() {
        User tUser = [SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1]; 
        System.runAs(tUser){

            Test.startTest(); 
            Account tAccount = [SELECT Id FROM Account LIMIT 1];
            CampaignMember tCampaignMember = [SELECT Id FROM CampaignMember LIMIT 1];
            SurveyCRM__c newCampaignMember = HDT_LC_CampaignSurvey.getSurvey('campaignmember', tCampaignMember.Id);
            
            System.assertEquals(true, tCampaignMember != null, 'tCampaignMember Id is not null');
			System.assertNotEquals(true, tCampaignMember == null, 'tCampaignMember Id is null');
            Test.stopTest();
        }
    }
    @isTest
    static void testGetSurveyNull() {
        User tUser = [SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1]; 
        System.runAs(tUser){

            Test.startTest(); 
            Account tAccount = [SELECT Id FROM Account LIMIT 1];
            CampaignMember tCampaignMember = [SELECT Id FROM CampaignMember LIMIT 1];
            SurveyCRM__c newCampaignMember = HDT_LC_CampaignSurvey.getSurvey('surveyNull', tCampaignMember.Id);
            
            System.assertEquals(true, newCampaignMember == null, 'newCampaignMember is null');
			System.assertNotEquals(false, tCampaignMember != null, 'newCampaignMember is not null');
            Test.stopTest();
        }
    }
    @isTest
    static void testSaveSurveyResponse() {
        User tUser = [SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1]; 
        System.runAs(tUser){

            Test.startTest(); 

            Account tAccount = [SELECT Id FROM Account LIMIT 1];
            Campaign tCampaign = [SELECT Id FROM Campaign LIMIT 1];
            Map<String, String> responses = new Map<String, String>();
            responses.put('Response1__c', 'FF0000');
            responses.put('Response2__c', '0000A0');
            SurveyResponse__c newSurveyResponse = HDT_LC_CampaignSurvey.saveSurveyResponse(responses, tCampaign.Id);
            
            System.assertEquals(true, tCampaign != null, 'tCampaign Id is not null');
			System.assertNotEquals(true, tCampaign == null, 'tCampaign Id is null');
            
            Test.stopTest();
        }
    }
}
