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
        String sourceA = leadList[0].SourceAgency__c;
        String intProd = leadList[0].InterestProduct__c;
        String mobPh   = leadList[0].MobilePhone ;
    }
    @isTest
    public static void createCampaignMemberFromLeadNegativeTst(){
        List<Lead> ld      = [SELECT Id, SourceAgency__c, InterestProduct__c, MobilePhone FROM Lead];
        List<Campaign> cmp = [SELECT Id FROM Campaign];
        List<Account> acc  = [SELECT Id FROM Account];
        List<CampaignMember> campaignListMember = HDT_UTL_DataFactoryTst.createCampaignMember(1, true, cmp[0].Id,ld[0].Id,null);
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
        Id response = HDT_LC_RecallMeCreateForm.createCampaignMemberFromLead(ld[0].Id, ld[0].SourceAgency__c, ld[0].InterestProduct__c, cmp[0].Id, ld[0].MobilePhone);
        List<CampaignMember> campaignMemmberResult = [SELECT Id FROM CampaignMember WHERE LeadId = :ld[0].Id LIMIT 1];
        Test.stopTest();
        } catch(Exception e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'The exception throws an error message in case the given lead has a campaign member');
            System.assertNotEquals('', e.getMessage(), 'An exception is expected');
        }

    }
    @isTest
    public static void createCampaignMemberFromLeadNullTst(){
        List<Lead> ld      = [SELECT Id, SourceAgency__c, InterestProduct__c, MobilePhone FROM Lead];
        List<Campaign> cmp = [SELECT Id FROM Campaign];
        List<Account> acc  = [SELECT Id FROM Account];
        List<CampaignMember> campaignListMember = HDT_UTL_DataFactoryTst.createCampaignMember(1, true, cmp[0].Id,ld[0].Id,null);
        try{ 
        List<CampaignMemberLeadAssigment__c> camMemLeadAss = new List<CampaignMemberLeadAssigment__c>();
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
}