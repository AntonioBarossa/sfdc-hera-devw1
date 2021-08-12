/**
* @author Luis Bispo (luis.bispo@engdb.com.br)
* @date 29/07/2021
* @description HDT_UTL_CampaignMember for Test Classes
* @history Luis Bispo – 29/07/2021 – Created class
*/

@isTest
public with sharing class HDT_UTL_CampaignMemberTst {
    
    @TestSetup
    static void setup(){
        CampaignMemberAssigment__c cma = new CampaignMemberAssigment__c();
        cma.Active__c = true;
        insert cma;
        List<Campaign> cp = HDT_UTL_DataFactoryTst.createCampaign(2, true);
        cp[0].AssignmentType__c = 'Peso Percentuale';
        cp[0].CampaignMemberAssigment__c = cma.Id;
        update cp;
        List<Lead> lead = HDT_UTL_DataFactoryTst.createLead(1, true);
        List<Account> acc = HDT_UTL_DataFactoryTst.createAccountResidenziale(1, true, 'HERA COMM', 'D1 - Persona fisica', 'Enti');
        List<Contact> ctt = HDT_UTL_DataFactoryTst.createContact(1, true, acc[0].Id);
        //List<CampaignMemberAssigmentItem__c> cma = HDT_UTL_DataFactoryTst.createCampaignMemberAssigmentItem(Integer amount, Boolean doInsert, Id accountId, Id CampaingMemberAssigmentId, String ProcessingType, Decimal PercentageAllocation);
        CampaignMember cm = new CampaignMember();
        cm.CampaignId = cp[0].Id;
        cm.LeadId = lead[0].Id;
        cm.ContactId = ctt[0].Id;
        insert cm;
    }
    
    @isTest
    public static void testCreateCampaignMemberStatus(){

        List<Campaign> lstCampaign = [SELECT Id, Status From Campaign LIMIT 2];
        lstCampaign[0].Status = 'Bozza';
        lstCampaign[1].Status = 'Pianificata';
        update lstCampaign;

        Test.startTest();
        HDT_UTL_CampaignMember.createCampaignMemberStatus(lstCampaign, lstCampaign);
        System.assert(lstCampaign != null);
        System.assertNotEquals(null, lstCampaign);
        Test.stopTest();
    }

    @isTest
    public static void testCreateCampaignMemberStatusCampagnaOutbound(){
        List<Campaign> lstCampaign = [SELECT Id, Status, Category__c, Channel__c From Campaign LIMIT 2];
        lstCampaign[0].Status = 'Bozza';
        lstCampaign[0].Category__c = 'Campagna Outbound';
        lstCampaign[0].Channel__c = 'Telefonico Outbound';
        lstCampaign[1].Status = 'Pianificata';
        lstCampaign[1].Category__c = 'Campagna Outbound';
        lstCampaign[1].Channel__c = 'Telefonico Outbound';
        update lstCampaign;
        Test.startTest();
        HDT_UTL_CampaignMember.createCampaignMemberStatus(lstCampaign, lstCampaign);
        System.assert(lstCampaign != null);
        System.assertNotEquals(null, lstCampaign);
        Test.stopTest();
    }

    @isTest
    public static void testCreateCampaignMemberStatusCartaceo(){
        List<Campaign> lstCampaign = [SELECT Id, Status, Category__c, Channel__c From Campaign LIMIT 2];
        lstCampaign[0].Status = 'Bozza';
        lstCampaign[0].Category__c = 'Campagna Outbound';
        lstCampaign[0].Channel__c = 'Cartaceo';
        lstCampaign[1].Status = 'Pianificata';
        lstCampaign[1].Category__c = 'Campagna Outbound';
        lstCampaign[1].Channel__c = 'Cartaceo';
        update lstCampaign;
        Test.startTest();
        HDT_UTL_CampaignMember.createCampaignMemberStatus(lstCampaign, lstCampaign);
        System.assert(lstCampaign != null);
        System.assertNotEquals(null, lstCampaign);
        Test.stopTest();
    }

    @isTest
    public static void testCreateCampaignMemberStatusMarketingCloud(){
        List<Campaign> lstCampaign = [SELECT Id, Status, Category__c, Channel__c From Campaign LIMIT 2];
        lstCampaign[0].Status = 'Bozza';
        lstCampaign[0].Category__c = 'Campagna Marketing Cloud';
        lstCampaign[1].Status = 'Pianificata';
        lstCampaign[1].Category__c = 'Campagna Marketing Cloud';
        update lstCampaign;
        Test.startTest();
        HDT_UTL_CampaignMember.createCampaignMemberStatus(lstCampaign, lstCampaign);
        System.assert(lstCampaign != null);
        System.assertNotEquals(null, lstCampaign);
        Test.stopTest();
    }
        
    @isTest
    public static void testCreateCampaignMember(){
        List<Campaign> lstCampaign = [SELECT Id  From Campaign LIMIT 2];
        List<CampaignMember> lstCampaignMember = [SELECT Id, CampaignId From CampaignMember LIMIT 2];
        Test.startTest();
            HDT_UTL_CampaignMember.createCampaignMember(lstCampaignMember);
            System.assert(lstCampaignMember != null);
            System.assertNotEquals(null, lstCampaignMember);
        Test.stopTest();
    }

    @isTest
    public static void testCreateCommercialCode(){
        Campaign campaign = [SELECT Id, Channel__c From Campaign LIMIT 1];
        System.debug('Campaign CCode-> ' + campaign);
        campaign.Category__c = 'Campagna Outbound';
        campaign.Channel__c = 'Bolletta';
        update campaign;
        List<CampaignMember> lstCampaignMember = [SELECT Id, CampaignId From CampaignMember LIMIT 1];
        Test.startTest();
        HDT_UTL_CampaignMember.createCommercialCode(lstCampaignMember);
        System.assert(lstCampaignMember != null);
        System.assertNotEquals(null, lstCampaignMember);
        Test.stopTest();
    }

    @isTest
    public static void testCampaignSuspension(){

        List<Campaign> lstCampaign = [SELECT Id, Status From Campaign LIMIT 2];
        Test.startTest();
        HDT_UTL_CampaignMember.campaignSuspension(lstCampaign, lstCampaign);
        System.assert(lstCampaign != null);
        System.assertNotEquals(null, lstCampaign);
        Test.stopTest();
    }

   @isTest
   public static void testFutureCampaignOutboundSuspensionRequest(){
        List<String> lstString = new List<String>();
        Campaign campaignIds = [SELECT Id FROM Campaign LIMIT 1];
        lstString.add(campaignIds.Id);
        Test.startTest();
            HDT_UTL_CampaignMember.futureCampaignOutboundSuspensionRequest(lstString);
            System.assert(campaignIds != null);
            System.assertNotEquals(null, campaignIds);
        Test.stopTest();
    }

    @isTest
    public static void testActivateCampaign(){

        List<Campaign> lstCampaign = [SELECT Id, Status From Campaign LIMIT 2];
        lstCampaign[0].Status = 'In Corso';
        lstCampaign[1].Status = 'Pianificata';
        update lstCampaign;
        Test.startTest();
        HDT_UTL_CampaignMember.activateCampaign(lstCampaign, lstCampaign);
        System.assert(lstCampaign != null);
        System.assertNotEquals(null, lstCampaign);
        Test.stopTest();
    }
}
