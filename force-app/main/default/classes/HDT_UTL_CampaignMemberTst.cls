/**
* @author Luis Bispo (luis.bispo@engdb.com.br)
* @date 29/07/2021
* @description HDT_UTL_CampaignMember for Test Classes
* @history Luis Bispo – 29/07/2021 – Created class
* @Fix 12/08/2021 - Other Methods
*/

@isTest
public with sharing class HDT_UTL_CampaignMemberTst {

    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    
    @TestSetup
    static void setup(){

        String profileId = HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);

        User internalUser = HDT_UTL_DataFactoryTst.createInternalUser(profileId, false);
        internalUser.UserPermissionsMarketingUser = true;

        User internalUser2 = HDT_UTL_DataFactoryTst.createInternalUser(profileId, false);
        internalUser2.Alias = 'standard';

        insert new List<User>{internalUser, internalUser2};

        System.runAs(internalUser) {

            CampaignMemberAssigment__c cma = HDT_UTL_DataFactoryTst.createCampaignMemberAssigment(1, true, true, 'Test Assignment').get(0);

            List<Campaign> cp = HDT_UTL_DataFactoryTst.createCampaign(2, true);
            cp[0].AssignmentType__c = 'Peso Percentuale';
            cp[0].CampaignMemberAssigment__c = cma.Id;
            update cp;

            List<Lead> lead = HDT_UTL_DataFactoryTst.createLead(2, true);
            List<Account> acc = HDT_UTL_DataFactoryTst.createAccountResidenziale(1, true, 'HERA COMM', 'D1 - Persona fisica', 'Enti');
            List<Contact> ctt = HDT_UTL_DataFactoryTst.createContact(2, true, acc[0].Id);
            List<CampaignMemberAssigmentItem__c> cmai = HDT_UTL_DataFactoryTst.createCampaignMemberAssigmentItem(1, true, acc.get(0).Id, cma.Id, 'Preview', 50.0);

            List<CampaignMember> cmb = HDT_UTL_DataFactoryTst.createCampaignMember(1, false, cp.get(0).Id, lead.get(0).Id, ctt.get(0).Id);
            cmb.addAll(HDT_UTL_DataFactoryTst.createCampaignMember(1, false, cp.get(0).Id, lead.get(1).Id, ctt.get(1).Id));

            cmb.get(0).Agency__c = acc.get(0).Id;
            cmb.get(1).Agency__c = acc.get(0).Id;

            insert cmb;

        }

    }
    
    @isTest
    public static void testCreateCampaignMemberStatus(){

        User u = [SELECT Id FROM User WHERE Alias = 'crmuser' LIMIT 1];

        system.runAs(u) {

            List<Campaign> lstCampaign = [SELECT Id, Status FROM Campaign LIMIT 2];
            lstCampaign[0].Status = 'Bozza';
            lstCampaign[1].Status = 'Pianificata';
            update lstCampaign;

            Test.startTest();
            HDT_UTL_CampaignMember.createCampaignMemberStatus(lstCampaign, lstCampaign);

            List<CampaignMemberStatus> createdmemberStatuses = [SELECT Id FROM CampaignMemberStatus WHERE CampaignId IN :lstCampaign ];

            System.assertEquals(false, createdmemberStatuses.isEmpty(), 'testCreateCampaignMemberStatus - Campaign member status were not created');

            Test.stopTest();
        }

    }

    @isTest
    public static void testCreateCampaignMemberStatusCampagnaOutbound(){

        User u = [SELECT Id FROM User WHERE Alias = 'crmuser' LIMIT 1];

        system.runAs(u) {

            List<Campaign> lstCampaign = [SELECT Id, Status, Category__c, Channel__c FROM Campaign LIMIT 2];
            lstCampaign[0].Status = 'Bozza';
            lstCampaign[0].Category__c = 'Campagna Outbound';
            lstCampaign[0].Channel__c = 'Telefonico Outbound';
            lstCampaign[1].Status = 'Pianificata';
            lstCampaign[1].Category__c = 'Campagna Outbound';
            lstCampaign[1].Channel__c = 'Telefonico Outbound';
            update lstCampaign;
            Test.startTest();
            HDT_UTL_CampaignMember.createCampaignMemberStatus(lstCampaign, lstCampaign);

            List<CampaignMemberStatus> createdmemberStatuses = [SELECT Id FROM CampaignMemberStatus WHERE CampaignId IN :lstCampaign ];

            System.assertEquals(false, createdmemberStatuses.isEmpty(), 'testCreateCampaignMemberStatusCampagnaOutbound - Campaign member status were not created');

            Test.stopTest();
        }
    }

    @isTest
    public static void testCreateCampaignMemberStatusCartaceo(){

        User u = [SELECT Id FROM User WHERE Alias = 'crmuser' LIMIT 1];

        system.runAs(u) {

            List<Campaign> lstCampaign = [SELECT Id, Status, Category__c, Channel__c FROM Campaign LIMIT 2];
            lstCampaign[0].Status = 'Bozza';
            lstCampaign[0].Category__c = 'Campagna Outbound';
            lstCampaign[0].Channel__c = 'Cartaceo';
            lstCampaign[1].Status = 'Pianificata';
            lstCampaign[1].Category__c = 'Campagna Outbound';
            lstCampaign[1].Channel__c = 'Cartaceo';
            update lstCampaign;
            Test.startTest();
            HDT_UTL_CampaignMember.createCampaignMemberStatus(lstCampaign, lstCampaign);
            
            List<CampaignMemberStatus> createdmemberStatuses = [SELECT Id FROM CampaignMemberStatus WHERE CampaignId IN :lstCampaign ];

            System.assertEquals(false, createdmemberStatuses.isEmpty(), 'testCreateCampaignMemberStatusCartaceo - Campaign member status were not created');

            Test.stopTest();
        }

    }

    @isTest
    public static void testCreateCampaignMemberStatusMarketingCloud(){

        User u = [SELECT Id FROM User WHERE Alias = 'crmuser' LIMIT 1];

        system.runAs(u) {

            List<Campaign> lstCampaign = [SELECT Id, Status, Category__c, Channel__c FROM Campaign LIMIT 2];
            lstCampaign[0].Status = 'Bozza';
            lstCampaign[0].Category__c = 'Campagna Marketing Cloud';
            lstCampaign[1].Status = 'Pianificata';
            lstCampaign[1].Category__c = 'Campagna Marketing Cloud';
            update lstCampaign;
            Test.startTest();
            HDT_UTL_CampaignMember.createCampaignMemberStatus(lstCampaign, lstCampaign);
            
            List<CampaignMemberStatus> createdmemberStatuses = [SELECT Id FROM CampaignMemberStatus WHERE CampaignId IN :lstCampaign ];

            System.assertEquals(false, createdmemberStatuses.isEmpty(), 'testCreateCampaignMemberStatusMarketingCloud - Campaign member status were not created');

            Test.stopTest();
        }

    }

    @IsTest
    static void createCampaignMemberStatusException(){
        
        User u = [SELECT Id FROM User WHERE Alias = 'standard' LIMIT 1];

        system.runAs(u) {

            List<Campaign> lstCampaign = [SELECT Id, Status FROM Campaign LIMIT 2];
            lstCampaign[0].Status = 'Bozza';
            lstCampaign[1].Status = 'Pianificata';
            update lstCampaign;

            Test.startTest();
            HDT_UTL_CampaignMember.createCampaignMemberStatus(lstCampaign, lstCampaign);

            List<CampaignMemberStatus> createdmemberStatuses = [SELECT Id FROM CampaignMemberStatus WHERE CampaignId IN :lstCampaign ];

            System.assertNotEquals(false, createdmemberStatuses.isEmpty(), 'createCampaignMemberStatusException - There should have been an exception');

            Test.stopTest();
        }
        
    }
        
    @isTest
    public static void testCreateCampaignMember(){

        User u = [SELECT Id FROM User WHERE Alias = 'crmuser' LIMIT 1];

        system.runAs(u) {

            Campaign cmp = [SELECT Id  FROM Campaign LIMIT 1];
            Lead ld = [SELECT Id  FROM Lead LIMIT 1];
            Contact con = [SELECT Id  FROM Contact LIMIT 1];
            Account acc = [SELECT Id FROM Account LIMIT 1];
            
            List<CampaignMember> testMembers = HDT_UTL_DataFactoryTst.createCampaignMember(5, false, cmp.Id, ld.Id, con.Id);

            // for (CampaignMember cmb : testMembers) {
            //     cmb.Agency__c = acc.Id;
            // }

            Test.startTest();
                
                HDT_UTL_CampaignMember.createCampaignMember(testMembers);

                System.assertEquals(acc.Id, testMembers.get(0).Agency__c, 'testCreateCampaignMember - The campaign member wasn not created properly');

            Test.stopTest();
        }

    }

    @isTest
    public static void testCreateCommercialCode(){

        Campaign campaign = [SELECT Id, Channel__c FROM Campaign LIMIT 1];

        System.debug('Campaign CCode-> ' + campaign);
        campaign.Category__c = 'Campagna Outbound';
        campaign.Channel__c = 'Bolletta';
        campaign.CodeManagementModel__c = 'Per singolo Campaign Member';
        campaign.CodeGenerationRule__c = 'PrefissoProgressivo';

        update campaign;

        List<CampaignMember> lstCampaignMember = [SELECT Id, CampaignId, PromoCommercialCode__c FROM CampaignMember WHERE CampaignId =: campaign.Id];

        Test.startTest();

            HDT_UTL_CampaignMember.createCommercialCode(lstCampaignMember);

        Test.stopTest();

        List<CampaignMember> lstCampaignMemberAfter = [SELECT Id, CampaignId, PromoCommercialCode__c FROM CampaignMember WHERE CampaignId =: campaign.Id];

        System.debug('Newly generated code ' + lstCampaignMemberAfter.get(0).PromoCommercialCode__c);
        System.assertNotEquals(lstCampaignMember.get(0).PromoCommercialCode__c, lstCampaignMemberAfter.get(0).PromoCommercialCode__c, 'testCreateCommercialCode - the code was not updated correctly');

    }

    @isTest
    public static void testCampaignSuspension(){

        Boolean finished = false;

        List<Campaign> lstCampaign = [SELECT Id, Status FROM Campaign LIMIT 1];

        List<Campaign> newCampaigns = new List<Campaign>{new Campaign(Id = lstCampaign.get(0).Id, Status = 'Cancellata', Channel__c = 'Telefonico Outbound')};

        List<Campaign> oldCampaigns = new List<Campaign>{new Campaign(Id = lstCampaign.get(0).Id, Status = 'In Corso', Channel__c = 'Telefonico Outbound')};

        Test.startTest();

        HDT_UTL_CampaignMember.campaignSuspension(newCampaigns, oldCampaigns);

        finished = true;

        Test.stopTest();

        System.assertEquals(true, finished, 'Test Ended');
    }

   @isTest
   public static void testFutureCampaignOutboundSuspensionRequest(){
    
        Boolean finished = false;

        List<String> lstString = new List<String>();
        
        Campaign campaignIds = [SELECT Id FROM Campaign LIMIT 1];
        lstString.add(campaignIds.Id);

        Test.startTest();

        HDT_UTL_CampaignMember.futureCampaignOutboundSuspensionRequest(lstString);

        finished = true;

        Test.stopTest();

        System.assertEquals(true, finished, 'Test Ended');

    }

    @isTest
    public static void testActivateCampaign(){

        Boolean finished = false;

        List<Campaign> lstCampaign = [SELECT Id, Status FROM Campaign LIMIT 1];

        List<Campaign> newCampaigns = new List<Campaign>{new Campaign(Id = lstCampaign.get(0).Id, Status = 'In Corso', Channel__c = 'Telefonico Outbound')};

        List<Campaign> oldCampaigns = new List<Campaign>{new Campaign(Id = lstCampaign.get(0).Id, Status = 'Pianificata', Channel__c = 'Telefonico Outbound')};

        Test.startTest();

        HDT_UTL_CampaignMember.activateCampaign(newCampaigns, oldCampaigns);

        finished = true;

        Test.stopTest();

        System.assertEquals(true, finished, 'Test Ended');
    }
}
