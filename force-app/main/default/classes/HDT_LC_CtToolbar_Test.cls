@isTest
public class HDT_LC_CtToolbar_Test {
    /*private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
	private static HDT_QR_Order orderQr=new HDT_QR_Order();


    static void setup(){
		////
		
		List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(1, false, 'HERA COMM', 'Azienda', 'Aziende SME');
		accounts[0].ActiveMonitoring__c=true;
		insert accounts;

		List<Opportunity> opps=HDT_UTL_DataFactoryTst.createOpportunity(1, true);
		List<Contact> contacts=HDT_UTL_DataFactoryTst.createContact(1, true, accounts[0].Id);
		List<Sale__c> sales=HDT_UTL_DataFactoryTst.createSale(2, true, accounts[0].Id, 'Attiva');
		List<Pricebook2> pricebook=HDT_UTL_DataFactoryTst.createPricebook(1, true);
		List<Order> orders=HDT_UTL_DataFactoryTst.createOrderWithPricebook(2, false, accounts[0].Id, sales, pricebook[0].Id);
		id orderdossier=constants.ORDER_RECORDTYPEID_ORDERDOSSIER;
		orders[1].RecordTypeId=orderdossier;
		orders[0].Username__c='test';
		orders[0].Password__c='test1';
		insert orders;

		List<Order> childOrders=HDT_UTL_DataFactoryTst.createChildOrder(1, false, accounts[0].Id, sales, orders[0].Id, contacts[0].Id);
		childOrders[0].QualityCall__c=true;
		insert childOrders;

		List<ServicePoint__c> servPoints=HDT_UTL_DataFactoryTst.createServicePoint(1, true);
		List<SBQQ__Quote__c> quotes=HDT_UTL_DataFactoryTst.createQuote(1, false, orders[0].Id, opps[0].Id, sales[0].Id, 'Amendment');
		quotes[0].IsVAS__c=false;
		quotes[0].AmendmentAllowed__c=false;
		insert quotes;

		orders[0].ServicePoint__c=servPoints[0].Id;
		orders[0].SBQQ__Quote__c=quotes[0].id;
		update orders;
        
        ////
		
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

            List<Lead> lead = HDT_UTL_DataFactoryTst.createLead(2, true);
            List<Account> acc = HDT_UTL_DataFactoryTst.createAccountResidenziale(1, true, 'HERA COMM', 'D1 - Persona fisica', 'Enti');
            List<Contact> ctt = HDT_UTL_DataFactoryTst.createContact(2, true, acc[0].Id);
            HDT_UTL_DataFactoryTst.createCampaignMemberAssigmentItem(1, true, acc.get(0).Id, cma.Id, 'Preview', 50.0);

            List<CampaignMember> cmb = HDT_UTL_DataFactoryTst.createCampaignMember(false, cp.get(0).Id, new List<Lead>{lead.get(0)}, new List<Contact>{ctt.get(0)});
            cmb.addAll(HDT_UTL_DataFactoryTst.createCampaignMember(false, cp.get(0).Id, new List<Lead>{lead.get(1)}, new List<Contact>{ctt.get(1)}));

            cmb.get(0).Agency__c = acc.get(0).Id;
            cmb.get(1).Agency__c = acc.get(0).Id;

            insert cmb;

        }

    }
    @isTest
 private static void testCampaignMember(){
    	Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
        internalUser.UserPermissionsMarketingUser=true;

        insert internalUser;
    	System.runAs(internalUser){
            
             CampaignMemberAssigment__c cma = HDT_UTL_DataFactoryTst.createCampaignMemberAssigment(1, true, true, 'Test Assignment').get(0);

            List<Campaign> cp = HDT_UTL_DataFactoryTst.createCampaign(2, true);
            cp[0].AssignmentType__c = 'Peso Percentuale';
            cp[0].CampaignMemberAssigment__c = cma.Id;
            update cp;

            List<Lead> lead = HDT_UTL_DataFactoryTst.createLead(2, true);
            List<Account> acc = HDT_UTL_DataFactoryTst.createAccountResidenziale(1, true, 'HERA COMM', 'D1 - Persona fisica', 'Enti');
            acc[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HDT_RT_Partner').getRecordTypeId();
            update acc;
            List<Contact> ctt = HDT_UTL_DataFactoryTst.createContact(2, true, acc[0].Id);
            HDT_UTL_DataFactoryTst.createCampaignMemberAssigmentItem(1, true, acc.get(0).Id, cma.Id, 'Preview', 50.0);

            List<CampaignMember> cmb = HDT_UTL_DataFactoryTst.createCampaignMember(false, cp.get(0).Id, new List<Lead>{lead.get(0)}, new List<Contact>{ctt.get(0)});
            cmb.addAll(HDT_UTL_DataFactoryTst.createCampaignMember(false, cp.get(0).Id, new List<Lead>{lead.get(1)}, new List<Contact>{ctt.get(1)}));

            cmb.get(0).Agency__c = acc.get(0).Id;
            cmb.get(1).Agency__c = acc.get(0).Id;

            insert cmb;

			Campaign cmp = [SELECT Id  FROM Campaign LIMIT 1];
            Account acc1 = [SELECT Id FROM Account LIMIT 1];
            
            List<Contact> contacts = HDT_UTL_DataFactoryTst.createContact(5, true, acc1.Id);
            List<Lead> leads = HDT_UTL_DataFactoryTst.createLead(5, false);
            leads.get(0).LastName = 'ln';
            leads.get(0).FirstName = 'fn';
            leads.get(0).Email = 'em@lead.com';
            leads.get(1).LastName = 'ln2';
            leads.get(1).FirstName = 'fn2';
            leads.get(1).Email = 'em2@lead.com';

            insert leads;

            List<CampaignMember> testMembers = HDT_UTL_DataFactoryTst.createCampaignMember(false, cmp.Id, leads, contacts);
        }
  		List<CampaignMember> testMembers = [SELECT Id FROM CampaignMember LIMIT 2];
        boolean b = HDT_LC_CtToolbar.updateCampaignMember('1', testMembers[0].Id, '');
        
        System.assertEquals(true, b, 'evaluate did not work correctly');
        System.assertNotEquals(null, b, 'evaluate did not work correctly');
    	
    
    
   		String s = HDT_LC_CtToolbar.getStatusByEcid('1');

    	boolean b1 = HDT_LC_CtToolbar.updateCampaignMemberStatus('test', testMembers[0].Id, true);
    
    }
    @isTest private static void testActivity(){
        
        HDT_UTL_DataFactoryTst.pClickInstance();
		HDT_UTL_DataFactoryTst.pClickOrderPhase();

            	Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
        internalUser.UserPermissionsMarketingUser=true;

        insert internalUser;
    	System.runAs(internalUser){
            
             CampaignMemberAssigment__c cma = HDT_UTL_DataFactoryTst.createCampaignMemberAssigment(1, true, true, 'Test Assignment').get(0);

            List<Campaign> cp = HDT_UTL_DataFactoryTst.createCampaign(2, true);
            cp[0].AssignmentType__c = 'Peso Percentuale';
            cp[0].CampaignMemberAssigment__c = cma.Id;
            update cp;

            List<Lead> lead = HDT_UTL_DataFactoryTst.createLead(2, true);
            List<Account> acc = HDT_UTL_DataFactoryTst.createAccountResidenziale(1, true, 'HERA COMM', 'D1 - Persona fisica', 'Enti');
            acc[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HDT_RT_Partner').getRecordTypeId();
            update acc;
            List<Contact> ctt = HDT_UTL_DataFactoryTst.createContact(2, true, acc[0].Id);
            HDT_UTL_DataFactoryTst.createCampaignMemberAssigmentItem(1, true, acc.get(0).Id, cma.Id, 'Preview', 50.0);

            List<CampaignMember> cmb = HDT_UTL_DataFactoryTst.createCampaignMember(false, cp.get(0).Id, new List<Lead>{lead.get(0)}, new List<Contact>{ctt.get(0)});
            cmb.addAll(HDT_UTL_DataFactoryTst.createCampaignMember(false, cp.get(0).Id, new List<Lead>{lead.get(1)}, new List<Contact>{ctt.get(1)}));

            cmb.get(0).Agency__c = acc.get(0).Id;
            cmb.get(1).Agency__c = acc.get(0).Id;

            insert cmb;

			Campaign cmp = [SELECT Id  FROM Campaign LIMIT 1];
            Account acc1 = [SELECT Id FROM Account LIMIT 1];
            
            List<Contact> contacts = HDT_UTL_DataFactoryTst.createContact(5, true, acc1.Id);
            List<Lead> leads = HDT_UTL_DataFactoryTst.createLead(5, false);
            leads.get(0).LastName = 'ln';
            leads.get(0).FirstName = 'fn';
            leads.get(0).Email = 'em@lead.com';
            leads.get(1).LastName = 'ln2';
            leads.get(1).FirstName = 'fn2';
            leads.get(1).Email = 'em2@lead.com';

            insert leads;

            List<CampaignMember> testMembers = HDT_UTL_DataFactoryTst.createCampaignMember(false, cmp.Id, leads, contacts);
        }
  		List<CampaignMember> testMembers = [SELECT Id FROM CampaignMember LIMIT 2];

        
        
  		String s = HDT_LC_CtToolbar.createActivityInbound('test','test','test1');

        wrts_prcgvr__Activity__c actv = HDT_LC_CtToolbar.createActivity(null, null,  null, testMembers[0].Id, null);
        
        boolean b = HDT_LC_CtToolbar.updateActivity(null, '20222403',3,4);
        
        
      try
      {
         boolean b1 = HDT_LC_CtToolbar.saveEcidInSales(null, null);
      }
      catch(exception e)
         {
             System.debug(e);
			}     
       
    }
    
    String s1 = HDT_LC_CtToolbar.getCachedUuid();*/
}