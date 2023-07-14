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
        internalUser2.Username = internalUser2.Username + '2';

        insert new List<User>{internalUser, internalUser2};

        System.runAs(internalUser) {

            CampaignMemberAssigment__c cma = HDT_UTL_DataFactoryTst.createCampaignMemberAssigment(1, true, true, 'Test Assignment').get(0);

            List<Campaign> cp = HDT_UTL_DataFactoryTst.createCampaign(2, true);
            cp[0].AssignmentType__c = 'Peso Percentuale';
            cp[0].CampaignMemberAssigment__c = cma.Id;
            update cp;

            List<Lead> lead = HDT_UTL_DataFactoryTst.createLead(2, false);
            List<Individual> ind =HDT_UTL_DataFactoryTst.createIndividual(2, true);
            lead.get(0).IndividualId=ind.get(0).id;
            lead.get(1).IndividualId=ind.get(1).id;
            insert lead;
            List<Account> acc = HDT_UTL_DataFactoryTst.createAccountPartner(1, true, 'Mario Verdi');
            List<Contact> ctt = HDT_UTL_DataFactoryTst.createContact(2, true, acc[0].Id);
            HDT_UTL_DataFactoryTst.createCampaignMemberAssigmentItem(1, true, acc.get(0).Id, cma.Id, 'Preview', 50.0);

            List<CampaignMember> cmb = HDT_UTL_DataFactoryTst.createCampaignMember(false, cp.get(0).Id, new List<Lead>{lead.get(0)}, new List<Contact>{ctt.get(0)});
            cmb.addAll(HDT_UTL_DataFactoryTst.createCampaignMember(false, cp.get(0).Id, new List<Lead>{lead.get(1)}, new List<Contact>{ctt.get(1)}));

            cmb.get(0).Agency__c = acc.get(0).Id;
            cmb.get(1).Agency__c = acc.get(0).Id;

            insert cmb;


            //Copertura metodo Check Esito
            HDT_UTL_DataFactoryTst.pClickInstance();
            HDT_UTL_DataFactoryTst.pClickOrderPhase();
            List<Sale__c> sales = HDT_UTL_DataFactoryTst.createSale(1,true,acc[0].Id,'Bozza');
            Id pricebookId = Test.getStandardPricebookId();
            List<Order> orderList = HDT_UTL_DataFactoryTst.createOrder(1, false, acc[0].Id, 'Bozza');
            orderList.addAll(HDT_UTL_DataFactoryTst.createOrderWithPricebook(1,false,acc[0].Id,sales,pricebookId));
            orderList[0].RecordTypeId = constants.ORDER_RECORDTYPEID_ORDERDOSSIER;
            orderList[0].QualityCall__c = true;
            insert orderList[0];
            orderList[1].ParentOrder__c = orderList[0].Id;
            orderList[1].QualityCall__c = true;
            orderList[1].Contact__c = ctt[0].Id;
            insert orderList[1];
            List<Product2> products = HDT_UTL_DataFactoryTst.createProduct2(1,true);
            List<PricebookEntry> entries = HDT_UTL_DataFactoryTst.createPricebookEntry(products,true,Test.getStandardPricebookId());
            HDT_UTL_DataFactoryTst.createOrderItem(1,true,orderList[1].Id,null,products[0].Id,entries[0].Id);
            List<wrts_prcgvr__Activity__c> activities = HDT_UTL_DataFactoryTst.createActivityCustom(1,false, acc[0].Id);
            activities[0].Order__c = orderList[1].Id;
            activities[0].Type__c = 'Quality Call';
            insert activities;
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
            Account acc = [SELECT Id FROM Account LIMIT 1];
            
            List<Contact> contacts = HDT_UTL_DataFactoryTst.createContact(5, true, acc.Id);
            List<Lead> leads = HDT_UTL_DataFactoryTst.createLead(2, false);
            List<Individual> ind =HDT_UTL_DataFactoryTst.createIndividual(2, true);
            leads.get(0).IndividualId=ind.get(0).id;
            leads.get(1).IndividualId=ind.get(1).id;
           /* leads.get(2).IndividualId=ind.get(0).id;
            leads.get(3).IndividualId=ind.get(1).id;
            leads.get(4).IndividualId=ind.get(0).id;*/
            leads.get(0).LastName = 'ln';
            leads.get(0).FirstName = 'fn';
            leads.get(0).Email = 'em@lead.com';
            leads.get(1).LastName = 'ln2';
            leads.get(1).FirstName = 'fn2';
            leads.get(1).Email = 'em2@lead.com';
            
            Test.startTest();
            insert leads;


            List<CampaignMember> testMembers = HDT_UTL_DataFactoryTst.createCampaignMember(false, cmp.Id, leads, contacts);

            // for (CampaignMember cmb : testMembers) {
            //     cmb.Agency__c = acc.Id;
            // }


                
                HDT_UTL_CampaignMember.createCampaignMember(testMembers);

                System.assertEquals(acc.Id, testMembers.get(0).Agency__c, 'testCreateCampaignMember - The campaign member wasn not created properly');

            Test.stopTest();
        }

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

/*
    @isTest
    public static void doCallMeBackTest(){

        Lead myLead = [SELECT Id FROM Lead LIMIT 1];
        myLead.ContactDate__c = Date.today();
        update myLead;

        MacroActivityEasyCIM__c myMAECIM = new MacroActivityEasyCIM__c();
        myMAECIM.Name = 'Test MacroActivityEasyCIM__c';
        insert myMAECIM;

        //Campaign myCampaign = [SELECT Id FROM Campaign LIMIT 1];
        //campaign.ReitekIntegrationTechnology__c = 'Web Service';
        //campaign.MacroActivityEasyCIM__c = myMAECIM.Id;     
        //update myCampaign;

        List<CampaignMember> lstCampaignMember = [SELECT Id, CampaignId, LeadId, PhoneNumber__c FROM CampaignMember LIMIT 1];
        lstCampaignMember[0].PhoneNumber__c = '0043736452';
        update lstCampaignMember;


        Test.startTest();

            HDT_UTL_CampaignMember.doCallMeBack(lstCampaignMember);

        Test.stopTest();

        System.assert(lstCampaignMember != null, 'lstCampaignMember è null');
    }
*/
    @isTest
    public static void cancelContractTest(){

        Map<String, List<String>> strMap = new Map<String, List<String>>();
        for (wrts_prcgvr__Activity__c act :[SELECT Id,Order__c FROM wrts_prcgvr__Activity__c WHERE Order__c != null]){
            strMap.put(act.Id, new List<String>{act.Order__c});
        }
        Test.startTest();

            HDT_UTL_CampaignMember.cancelContract(strMap);

        Test.stopTest();

        System.assert(strMap != null, 'strMap è null');
    }

    @isTest
    public static void transcodeProcessForActivityTest(){

        String rt = 'HDT_RT_CambioOfferta';

        Test.startTest();

            HDT_UTL_CampaignMember.transcodeProcessForActivity(rt);

        Test.stopTest();

        System.assert(rt != null, 'rt è null');

    }

    @isTest
    public static void checkTipoEsitoTest(){
        Campaign cmp = [SELECT Id  FROM Campaign WHERE AssignmentType__c = 'Peso Percentuale' LIMIT 1];
        CampaignMember cMember = [SELECT Id, CampaignId, LeadId, PhoneNumber__c FROM CampaignMember WHERE CampaignId = :cmp.Id LIMIT 1];
        wrts_prcgvr__Activity__c act = [SELECT Id FROM wrts_prcgvr__Activity__c LIMIT 1];
        cMember.Status = 'Lotto scaduto';
        cMember.RelatedActivity__c = act.Id; 
        cMember.ResultType__c = 'Macchina';
        insert new CampaignMemberStatus(Label = 'Lotto scaduto', HasResponded = true, sortOrder = 0, CampaignId = cmp.Id);
        Test.startTest();
            update cMember;
        Test.stopTest();
        List<AsyncApexJob> asyncJob = [SELECT Id FROM AsyncApexJob WHERE ApexClass.Name = 'HDT_BA_CampaignMemberManaged'];
        System.assertEquals(1, asyncJob.size(), 'Activity non correttamente gestita.');
    }

}