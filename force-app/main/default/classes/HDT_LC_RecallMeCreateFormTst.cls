/*
 * @author Laureta Demishaj (laureta.demishaj@dunegroup.it)
 * @date 29/09/2021
 * @description HDT_LC_RecallMeCreateForm for Test Classes
 * @history Laureta Demishaj – 29/09/2021 – Created class
*/
@isTest
public with sharing class HDT_LC_RecallMeCreateFormTst {

 private static HDT_UTL_Constants constants = new HDT_UTL_Constants();

    @TestSetup
    static void myData(){
        List<Account> accList       = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].id);
        List<Campaign> campaignList = HDT_UTL_DataFactoryTst.createCampaign(1, false);
        campaignList[0].Category__c = 'Campagna Outbound';
        campaignList[0].Channel__c  = 'Bolletta'; 
        insert campaignList;
        List<Lead> leadList = HDT_UTL_DataFactoryTst.createLead(1, false);
        leadList[0].CampaignSource__c  = campaignList[0].Id;
        leadList[0].SourceAgency__c    = 'Linetech';
        leadList[0].InterestProduct__c = 'Hera Bebè Gas';
        leadList[0].InterestArea__c    = 'Green';
        leadList[0].ContactReason__c   = 'Info commerciali';
        leadList[0].MobilePhone        = '0123456789';
        insert leadList;

        HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
    }
    @isTest
    public static void createCampaignMemberFromLeadNegativeTst(){
        List<Lead> ld      = [SELECT Id, SourceAgency__c, InterestProduct__c, MobilePhone FROM Lead];
        List<Campaign> cmp = [SELECT Id FROM Campaign];
        List<Account> acc  = [SELECT Id FROM Account];
        List<Contact> con = [SELECT Id FROM Contact];
        HDT_UTL_DataFactoryTst.createCampaignMember(true, cmp[0].Id, ld, con);
        try{ 
        List<CampaignMemberLeadAssigment__c> camMemLeadAss = new List<CampaignMemberLeadAssigment__c>();
        CampaignMemberLeadAssigment__c cmlA = new CampaignMemberLeadAssigment__c();
        cmlA.Name               = 'prova';
        cmlA.Agency__c          = acc[0].Id;
        cmlA.InterestProduct__c = ld[0].InterestProduct__c;
        cmlA.SourceAgency__c    = ld[0].SourceAgency__c;
        insert cmlA;
        camMemLeadAss.add(cmlA);
        Test.startTest();
        HDT_LC_RecallMeCreateForm.createCampaignMemberFromLead(ld[0].Id, ld[0].SourceAgency__c, ld[0].InterestProduct__c, cmp[0].Id, ld[0].MobilePhone);
        Test.stopTest();
        } catch(Exception e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'The exception throws an error message in case the given lead has a campaign member');
            System.assertNotEquals('', e.getMessage(), 'An exception is expected');
        }

    }
    @isTest
    public static void createCampaignMemberFromLeadNullTst(){
        List<Lead> ld = [SELECT Id, SourceAgency__c, InterestProduct__c, MobilePhone FROM Lead];
        List<Campaign> cmp = [SELECT Id FROM Campaign];
        List<Contact> con = [SELECT Id FROM Contact];
        HDT_UTL_DataFactoryTst.createCampaignMember(true, cmp[0].Id, ld, con);
        try{ 
        
        Test.startTest();
        Id response = HDT_LC_RecallMeCreateForm.createCampaignMemberFromLead(ld[0].Id, ld[0].SourceAgency__c, ld[0].InterestProduct__c, cmp[0].Id, ld[0].MobilePhone);
        System.assertEquals(null, response, 'When the list of CampaignMemberLeadAssigment__c is empty the method returns null');
        Test.stopTest();
        } catch(Exception e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'The exception throws an error message in case the given lead has a campaign member');
            System.assertNotEquals('', e.getMessage(), 'An exception is expected');
        }
    }
    @isTest
    public static void createCampaignMemberFromLeadPositivetiveTst() {
        List<Lead> ld      = [SELECT Id, SourceAgency__c, InterestProduct__c, MobilePhone FROM Lead];
        List<Campaign> cmp = [SELECT Id FROM Campaign];
        List<Account> acc  = [SELECT Id FROM Account];
        try{ 
        List<CampaignMemberLeadAssigment__c> camMemLeadAss = new List<CampaignMemberLeadAssigment__c>();
        CampaignMemberLeadAssigment__c cmlA = new CampaignMemberLeadAssigment__c();
        cmlA.Name               = 'prova';
        cmlA .Agency__c         = acc[0].Id;
        cmlA.InterestProduct__c = ld[0].InterestProduct__c;
        cmlA.SourceAgency__c    = ld[0].SourceAgency__c;
        insert cmlA;
        camMemLeadAss.add(cmlA);
        Test.startTest();
        Id response = HDT_LC_RecallMeCreateForm.createCampaignMemberFromLead(ld[0].Id, ld[0].SourceAgency__c, ld[0].InterestProduct__c, cmp[0].Id, ld[0].MobilePhone);
        List<CampaignMember> campaignMemmberResult = [SELECT Id FROM CampaignMember WHERE LeadId = :ld[0].Id LIMIT 1];       
        System.assertEquals(campaignMemmberResult[0].Id, response, 'The method creates a campaign member from a Lead');
        System.assertNotEquals(null, response, 'The method is expected to create a campaign member from a Lead');
        Test.stopTest();
        } catch(Exception e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'The exception throws an error message');
            System.assertNotEquals('', e.getMessage(), 'An exception is expected');
        }
    }
    //** [START MOD 21/10/2021] @Author:Cesare Bagnolini WR (cesare.bagnolini@webresults.it) @Description: Added Test Methods
    @isTest static void testCreateCampaignMemberFromContact(){
        String acc = [Select id FROM Account][0].id;
        String con = [Select id FROM Contact][0].id;
        String cam = [Select id FROM Campaign][0].id;
        
        new List<CampaignMemberLeadAssigment__c>();
        CampaignMemberLeadAssigment__c cmlA = new CampaignMemberLeadAssigment__c();
        cmlA.Name               = 'prova';
        cmlA .Agency__c         =  acc;
        cmlA.InterestProduct__c = 'Hera Bebè Gas';
        cmlA.SourceAgency__c    = 'Linetech';
        insert cmlA;
        
        Test.startTest();
        
        String result = HDT_LC_RecallMeCreateForm.createCampaignMemberFromContact(con, 'Linetech', 'Hera Bebè Gas', cam, '3333453344');
        
        Test.stopTest();
        
        String member = [Select id FROM CampaignMember][0].id;
        
        System.assertEquals(member, result, 'CreateCampaignMemberFromContact did not work correctly');
        System.assertNotEquals(null, result, 'CreateCampaignMemberFromContact did not work correctly');        
    }

    @isTest static void testGetActivePicklistValues(){

        Test.startTest();
        
        List<String> result = HDT_LC_RecallMeCreateForm.getActivePicklistValues('Contact','Company__c');
        
        Test.stopTest();
        
        System.assertEquals(10, result.size(), 'GetActivePicklistValues did not work correctly');
        System.assertNotEquals(null, result, 'GetActivePicklistValues did not work correctly');        
    }
    //** [END MOD 21/10/2021] @Author:Cesare Bagnolini WR (cesare.bagnolini@webresults.it) @Description: Added Test Methods
}