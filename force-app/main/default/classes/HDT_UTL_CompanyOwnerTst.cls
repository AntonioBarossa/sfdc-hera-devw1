/**
 * @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
 * @date 20/09/2021
 * @description HDT_UTL_CompanyOwner Test Classes
 * @history Lucas Fernandes 20/09/2021 – Created class
 */
@isTest
public with sharing class HDT_UTL_CompanyOwnerTst {
    
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
	
	@TestSetup
    static void setup(){
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
        User adminUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
        adminUser.UserPermissionsMarketingUser=true;
        adminUser.UserRoleId = HDT_UTL_DataFactoryTst.getUserRoleId(constants.USERROLE_DEVELOPERNAME_BACKOFFICE);
        insert adminUser;
 
        System.runAs(adminUser) {
 
            List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
            List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
            List<BillingProfile__c> bpList = HDT_UTL_DataFactoryTst.createBillingProfile(1, true, accList[0].Id);
            
            List<Lead> leadList = HDT_UTL_DataFactoryTst.createLead(1, false);
            leadList[0].CompanyOwner__c = 'HERA COMM';
            insert leadList;

            List<ServicePoint__c> spList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
            List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].Id);
            List<Order> orderList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].Id, 'Bozza');
            List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].Id, contactList[0].Id, spList[0].Id, contractList[0].Id, orderList[0].Id);
            List<Opportunity> oppList = HDT_UTL_DataFactoryTst.createOpportunity(1, true);
            List<Sale__c> saleList = HDT_UTL_DataFactoryTst.createSale(1, true, accList[0].Id, 'Bozza');
            
            List<SBQQ__Quote__c> quoteList = HDT_UTL_DataFactoryTst.createQuote(1, false, orderList[0].Id, oppList[0].Id, saleList[0].Id, 'Quote');
            quoteList[0].SBQQ__Account__c = accList[0].Id;
            insert quoteList;

            List<DocumentalActivity__c> daList = HDT_UTL_DataFactoryTst.createDocumentalActivity(1, true, orderList[0].Id, caseList[0].Id);
            
            List<SMSTracking__c> smsTrackingList = HDT_UTL_DataFactoryTst.createSmsTracking(1, false, contactList[0].Id);
            smsTrackingList[0].LeadID__c = leadList[0].Id;
            smsTrackingList[0].ContactID__c = contactList[0].Id;
            smsTrackingList[0].CaseID__c = caseList[0].Id;
            smsTrackingList[0].OrderID__c = orderList[0].Id;
            insert smsTrackingList;

            List<et4ae5__Automated_Send__c> autoSendList = HDT_UTL_DataFactoryTst.createTriggeredSend(1, true);
            
            List<et4ae5__IndividualEmailResult__c> indEmailResultList = HDT_UTL_DataFactoryTst.createIndividualEmailResult(1, false, autoSendList[0].Id);
            indEmailResultList[0].et4ae5__Lead__c = leadList[0].Id;
            indEmailResultList[0].CaseID__c = caseList[0].Id;
            indEmailResultList[0].et4ae5__Contact__c = contactList[0].Id;
            indEmailResultList[0].OrderID__c = orderList[0].Id;
            insert indEmailResultList;

            List<wrts_prcgvr__Activity__c> activityList = HDT_UTL_DataFactoryTst.createActivityCustom(1, false, accList[0].Id);
            activityList[0].Lead__c = leadList[0].Id;
            activityList[0].Case__c = caseList[0].Id;
            activityList[0].Order__c = orderList[0].Id;
            activityList[0].wrts_prcgvr__ObjectId__c = caseList[0].Id;
            insert activityList;
        }
    }

	// Test must be split into more tests due to Governor Limits issue
	@isTest
    public static void testFillCompanyOwnerLead() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            List<Account> accounts = [SELECT Id, CompanyOwner__c FROM Account WHERE BillingCityCode__c='Roma' LIMIT 1];
            List<Lead> leadList = [SELECT Id, CompanyOwner__c FROM Lead WHERE CompanyOwner__c='HERA COMM' LIMIT 1];
            leadList[0].CompanyOwner__c = null;
            update leadList;

            leadList = [SELECT Id, CompanyOwner__c FROM Lead WHERE Status='New' LIMIT 1];

            HDT_UTL_CompanyOwner.feedCompanyOwner(leadList);

            leadList = [SELECT Id, CompanyOwner__c FROM Lead WHERE CompanyOwner__c = null LIMIT 1];

            Test.stopTest();

            System.assertEquals(false, leadList.isEmpty(), 'CompanyOwner updated.');
            System.assertNotEquals(true, leadList.isEmpty(), 'CompanyOwner update failed.');
        }
    }

    @isTest
    public static void testFillCompanyOwnerActivityCustomAccount() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            List<Account> accounts = [SELECT Id, CompanyOwner__c FROM Account WHERE BillingCityCode__c='Roma' LIMIT 1];
            List<Lead> leadList = [SELECT Id, CompanyOwner__c FROM Lead WHERE CompanyOwner__c='HERA COMM' LIMIT 1];
            List<Case> caseList = [SELECT Id, CompanyOwner__c FROM Case WHERE Phase__c = 'Bozza' LIMIT 1];
            List<Order> orderList = [SELECT Id, CompanyOwner__c FROM Order WHERE Phase__c = 'Bozza' LIMIT 1];
            List<wrts_prcgvr__Activity__c> activityList = [SELECT Id, Account__c, Lead__c, Case__c, Order__c, wrts_prcgvr__ObjectId__c, CompanyOwner__c
                                                           FROM wrts_prcgvr__Activity__c LIMIT 1];

            HDT_UTL_CompanyOwner.feedCompanyOwner(activityList);

            activityList[0].wrts_prcgvr__ObjectId__c = accounts[0].Id;
            update activityList;
            HDT_UTL_CompanyOwner.feedCompanyOwner(activityList);
           
            activityList = [SELECT Id, CompanyOwner__c FROM wrts_prcgvr__Activity__c WHERE CompanyOwner__c = 'HERA COMM' LIMIT 1];

            Test.stopTest();

            System.assertEquals(false, activityList.isEmpty(), 'CompanyOwner updated.');
            System.assertNotEquals(true, activityList.isEmpty(), 'CompanyOwner update failed.');
        }
    }       
    
    @isTest
    public static void testFillCompanyOwnerActivityCustomLead() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            List<Account> accounts = [SELECT Id, CompanyOwner__c FROM Account WHERE BillingCityCode__c='Roma' LIMIT 1];
            List<Lead> leadList = [SELECT Id, CompanyOwner__c FROM Lead WHERE CompanyOwner__c='HERA COMM' LIMIT 1];
            List<Case> caseList = [SELECT Id, CompanyOwner__c FROM Case WHERE Phase__c = 'Bozza' LIMIT 1];
            List<Order> orderList = [SELECT Id, CompanyOwner__c FROM Order WHERE Phase__c = 'Bozza' LIMIT 1];
            List<wrts_prcgvr__Activity__c> activityList = [SELECT Id, Account__c, Lead__c, Case__c, Order__c, wrts_prcgvr__ObjectId__c, CompanyOwner__c
                                                           FROM wrts_prcgvr__Activity__c LIMIT 1];

            activityList[0].wrts_prcgvr__ObjectId__c = leadList[0].Id;
            activityList[0].Account__c = null;
            update activityList;
            HDT_UTL_CompanyOwner.feedCompanyOwner(activityList);

            activityList = [SELECT Id, CompanyOwner__c FROM wrts_prcgvr__Activity__c WHERE CompanyOwner__c = 'HERA COMM' LIMIT 1];
            
            Test.stopTest();

            System.assertEquals(false, activityList.isEmpty(), 'CompanyOwner updated.');
            System.assertNotEquals(true, activityList.isEmpty(), 'CompanyOwner update failed.');
        }       
    }
    
    @isTest
    public static void testFillCompanyOwnerActivityCustomCase() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            List<Account> accounts = [SELECT Id, CompanyOwner__c FROM Account WHERE BillingCityCode__c='Roma' LIMIT 1];
            List<Lead> leadList = [SELECT Id, CompanyOwner__c FROM Lead WHERE CompanyOwner__c='HERA COMM' LIMIT 1];
            List<Case> caseList = [SELECT Id, CompanyOwner__c FROM Case WHERE Phase__c = 'Bozza' LIMIT 1];
            List<Order> orderList = [SELECT Id, CompanyOwner__c FROM Order WHERE Phase__c = 'Bozza' LIMIT 1];
            List<wrts_prcgvr__Activity__c> activityList = [SELECT Id, Account__c, Lead__c, Case__c, Order__c, wrts_prcgvr__ObjectId__c
                                                           FROM wrts_prcgvr__Activity__c LIMIT 1];

            activityList[0].wrts_prcgvr__ObjectId__c = caseList[0].Id;
            activityList[0].Account__c = null;
            activityList[0].Lead__c = null;
            update activityList;
            HDT_UTL_CompanyOwner.feedCompanyOwner(activityList);

            activityList[0].Case__c = null;
            update activityList;
            HDT_UTL_CompanyOwner.feedCompanyOwner(activityList);

            activityList = [SELECT Id, CompanyOwner__c FROM wrts_prcgvr__Activity__c WHERE CompanyOwner__c = 'HERA COMM' LIMIT 1];
            
            Test.stopTest();

            System.assertEquals(false, activityList.isEmpty(), 'CompanyOwner updated.');
            System.assertNotEquals(true, activityList.isEmpty(), 'CompanyOwner update failed.');
        }       
    }

    @isTest
    public static void testFillCompanyOwnerActivityCustomOrder() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            List<Account> accounts = [SELECT Id, CompanyOwner__c FROM Account WHERE BillingCityCode__c='Roma' LIMIT 1];
            List<Lead> leadList = [SELECT Id, CompanyOwner__c FROM Lead WHERE CompanyOwner__c='HERA COMM' LIMIT 1];
            List<Case> caseList = [SELECT Id, CompanyOwner__c FROM Case WHERE Phase__c = 'Bozza' LIMIT 1];
            List<Order> orderList = [SELECT Id, CompanyOwner__c FROM Order WHERE Phase__c = 'Bozza' LIMIT 1];
            List<wrts_prcgvr__Activity__c> activityList = [SELECT Id, Account__c, Lead__c, Case__c, Order__c, wrts_prcgvr__ObjectId__c
                                                           FROM wrts_prcgvr__Activity__c LIMIT 1];

            activityList[0].wrts_prcgvr__ObjectId__c = orderList[0].Id;
            activityList[0].Account__c = null;
            activityList[0].Lead__c = null;
            activityList[0].Case__c = null;
            update activityList;
            HDT_UTL_CompanyOwner.feedCompanyOwner(activityList);

            activityList[0].Order__c = null;
            update activityList;
            HDT_UTL_CompanyOwner.feedCompanyOwner(activityList);

            activityList = [SELECT Id, CompanyOwner__c FROM wrts_prcgvr__Activity__c WHERE CompanyOwner__c = 'HERA COMM' LIMIT 1];
            
            Test.stopTest();

            System.assertEquals(false, activityList.isEmpty(), 'CompanyOwner updated.');
            System.assertNotEquals(true, activityList.isEmpty(), 'CompanyOwner update failed.');
        }       
    }

    @isTest
    public static void testFillCompanyOwnerQuote() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            List<Account> accounts = [SELECT Id, CompanyOwner__c FROM Account WHERE BillingCityCode__c='Roma' LIMIT 1];
            List<SBQQ__Quote__c> quotes = [SELECT Id, SBQQ__Account__c, CompanyOwner__c FROM SBQQ__Quote__c WHERE SBQQ__Type__c = 'Quote' LIMIT 1];

            HDT_UTL_CompanyOwner.feedCompanyOwner(quotes);

            quotes = [SELECT Id, CompanyOwner__c FROM SBQQ__Quote__c WHERE CompanyOwner__c = 'HERA COMM' LIMIT 1];

            Test.stopTest();

            System.assertEquals(false, quotes.isEmpty(), 'CompanyOwner updated.');
            System.assertNotEquals(true, quotes.isEmpty(), 'CompanyOwner update failed.');
        }
    }

    @isTest
    public static void testFillCompanyOwnerSmsTracking() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            List<Account> accounts = [SELECT Id, CompanyOwner__c FROM Account WHERE BillingCityCode__c = 'Roma' LIMIT 1];
            List<Lead> leadList = [SELECT Id, CompanyOwner__c FROM Lead WHERE CompanyOwner__c = 'HERA COMM' LIMIT 1];
            List<Case> caseList = [SELECT Id, CompanyOwner__c FROM Case WHERE Phase__c = 'Bozza' LIMIT 1];
            List<Contact> cttList = [SELECT Id, CompanyOwner__c FROM Contact WHERE CompanyOwner__c = 'HERA COMM'];
            List<SMSTracking__c> smsTrackList = [SELECT Id, Account__c, CompanyOwner__c, LeadID__c, ContactID__c, CaseID__c, OrderID__c FROM SMSTracking__c WHERE Mobile__c='234234234' LIMIT 1];
            smsTrackList[0].LeadID__c = null;
            update smsTrackList;

            smsTrackList = [SELECT Id, Account__c, CompanyOwner__c, LeadID__c, ContactID__c, CaseID__c, OrderID__c FROM SMSTracking__c WHERE Mobile__c='234234234' LIMIT 1];
            HDT_UTL_CompanyOwner.feedCompanyOwner(smsTrackList);

            smsTrackList = [SELECT Id, Account__c, CompanyOwner__c, LeadID__c, ContactID__c, CaseID__c, OrderID__c FROM SMSTracking__c WHERE Mobile__c='234234234' LIMIT 1];
            smsTrackList[0].LeadID__c = leadList[0].Id;
            smsTrackList[0].ContactID__c = null;
            update smsTrackList;

            smsTrackList = [SELECT Id, Account__c, CompanyOwner__c, LeadID__c, ContactID__c, CaseID__c, OrderID__c FROM SMSTracking__c WHERE Mobile__c='234234234' LIMIT 1];
            HDT_UTL_CompanyOwner.feedCompanyOwner(smsTrackList);

            smsTrackList = [SELECT Id, Account__c, CompanyOwner__c, LeadID__c, ContactID__c, CaseID__c, OrderID__c FROM SMSTracking__c WHERE Mobile__c='234234234' LIMIT 1];
            smsTrackList[0].ContactID__c = cttList[0].Id;
            smsTrackList[0].CaseID__c = null;
            update smsTrackList;

            smsTrackList = [SELECT Id, Account__c, CompanyOwner__c, LeadID__c, ContactID__c, CaseID__c, OrderID__c FROM SMSTracking__c WHERE Mobile__c='234234234' LIMIT 1];
            HDT_UTL_CompanyOwner.feedCompanyOwner(smsTrackList);

            smsTrackList = [SELECT Id, Account__c, CompanyOwner__c, LeadID__c, ContactID__c, CaseID__c, OrderID__c FROM SMSTracking__c WHERE Mobile__c='234234234' LIMIT 1];
            smsTrackList[0].CaseID__c = caseList[0].Id;
            smsTrackList[0].OrderID__c = null;
            update smsTrackList;

            smsTrackList = [SELECT Id, Account__c, CompanyOwner__c, LeadID__c, ContactID__c, CaseID__c, OrderID__c FROM SMSTracking__c WHERE Mobile__c='234234234' LIMIT 1];
            HDT_UTL_CompanyOwner.feedCompanyOwner(smsTrackList);

            smsTrackList = [SELECT Id, CompanyOwner__c FROM SMSTracking__c WHERE CompanyOwner__c = 'HERA COMM' LIMIT 1];

            Test.stopTest();

            System.assertEquals(false, smsTrackList.isEmpty(), 'CompanyOwner updated.');
            System.assertNotEquals(true, smsTrackList.isEmpty(), 'CompanyOwner update failed.');
        }
    }

    @isTest
    public static void testFillCompanyOwnerIndividualEmailResult() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            List<Lead> leadList = [SELECT Id, CompanyOwner__c FROM Lead WHERE CompanyOwner__c='HERA COMM' LIMIT 1];
            List<Case> caseList = [SELECT Id, CompanyOwner__c FROM Case WHERE Phase__c = 'Bozza' LIMIT 1];
            List<Contact> cttList = [SELECT Id, CompanyOwner__c FROM Contact WHERE CompanyOwner__c='HERA COMM'];
            List<et4ae5__IndividualEmailResult__c> ierList = [SELECT Id, Account__c, CompanyOwner__c, et4ae5__Lead__c, et4ae5__Contact__c, CaseID__c, OrderID__c 
                                                              FROM et4ae5__IndividualEmailResult__c 
                                                              WHERE EmailAddress__c = 'my@email.com' LIMIT 1];
 
            update ierList;

            ierList = [SELECT Id, Account__c, CompanyOwner__c, et4ae5__Lead__c, et4ae5__Contact__c, CaseID__c, OrderID__c 
                                                              FROM et4ae5__IndividualEmailResult__c 
                                                              WHERE EmailAddress__c = 'my@email.com' LIMIT 1];
            HDT_UTL_CompanyOwner.feedCompanyOwner(ierList);

            ierList = [SELECT Id, Account__c, CompanyOwner__c, et4ae5__Lead__c, et4ae5__Contact__c, CaseID__c, OrderID__c 
                        FROM et4ae5__IndividualEmailResult__c 
                        WHERE EmailAddress__c = 'my@email.com' LIMIT 1];
            
            ierList[0].et4ae5__Lead__c = null;
            update ierList;

            ierList = [SELECT Id, Account__c, CompanyOwner__c, et4ae5__Lead__c, et4ae5__Contact__c, CaseID__c, OrderID__c 
                                                              FROM et4ae5__IndividualEmailResult__c 
                                                              WHERE EmailAddress__c = 'my@email.com' LIMIT 1];
            HDT_UTL_CompanyOwner.feedCompanyOwner(ierList);

            ierList = [SELECT Id, Account__c, CompanyOwner__c, et4ae5__Lead__c, et4ae5__Contact__c, CaseID__c, OrderID__c 
                        FROM et4ae5__IndividualEmailResult__c 
                        WHERE EmailAddress__c = 'my@email.com' LIMIT 1];

            ierList[0].et4ae5__Lead__c = leadList[0].Id;
            ierList[0].CaseID__c = null;
            update ierList;

            ierList = [SELECT Id, Account__c, CompanyOwner__c, et4ae5__Lead__c, et4ae5__Contact__c, CaseID__c, OrderID__c 
                                                              FROM et4ae5__IndividualEmailResult__c 
                                                              WHERE EmailAddress__c = 'my@email.com' LIMIT 1];
            HDT_UTL_CompanyOwner.feedCompanyOwner(ierList);

            ierList = [SELECT Id, Account__c, CompanyOwner__c, et4ae5__Lead__c, et4ae5__Contact__c, CaseID__c, OrderID__c 
                        FROM et4ae5__IndividualEmailResult__c 
                        WHERE EmailAddress__c = 'my@email.com' LIMIT 1];

            ierList[0].et4ae5__Lead__c = leadList[0].Id;
            ierList[0].CaseID__c = caseList[0].Id;
            ierList[0].OrderID__c = null;
            update ierList;

            ierList = [SELECT Id, Account__c, CompanyOwner__c, et4ae5__Lead__c, et4ae5__Contact__c, CaseID__c, OrderID__c 
                                                              FROM et4ae5__IndividualEmailResult__c 
                                                              WHERE EmailAddress__c = 'my@email.com' LIMIT 1];
            HDT_UTL_CompanyOwner.feedCompanyOwner(ierList);

            ierList = [SELECT Id, CompanyOwner__c FROM et4ae5__IndividualEmailResult__c WHERE CompanyOwner__c='HERA COMM' LIMIT 1];

            Test.stopTest();

            System.assertEquals(false, ierList.isEmpty(), 'CompanyOwner updated.');
            System.assertNotEquals(true, ierList.isEmpty(), 'CompanyOwner update failed.');
        }
    }

    @isTest
    public static void testFillCompanyOwnerAaaebtUserRole() {
 
        Test.startTest();

        User u = [SELECT Id, UserRoleId FROM User WHERE Alias='crmuser' LIMIT 1];
        u.UserRoleId = HDT_UTL_DataFactoryTst.getUserRoleId(constants.USERROLE_DEVELOPERNAME_FRONTOFFICE_AAAEBT);
        update u;

        u = [SELECT Id, UserRoleId FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            List<Contact> contactList = [SELECT Id, CompanyOwner__c FROM Contact WHERE CompanyOwner__c='HERA COMM' LIMIT 1];
            contactList[0].CompanyOwner__c = null;
            update contactList;

            contactList = [SELECT Id, CompanyOwner__c FROM Contact WHERE CompanyOwner__c = null LIMIT 1];
            HDT_UTL_CompanyOwner.feedCompanyOwner(contactList);
        }

        u.UserRoleId = HDT_UTL_DataFactoryTst.getUserRoleId(constants.USERROLE_DEVELOPERNAME_FRONTOFFICE_MMS);
        update u;

        u = [SELECT Id, UserRoleId FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){

            List<Contact> contactList = [SELECT Id, CompanyOwner__c FROM Contact WHERE CompanyOwner__c = null LIMIT 1];
            HDT_UTL_CompanyOwner.feedCompanyOwner(contactList);
        }

        u.UserRoleId = HDT_UTL_DataFactoryTst.getUserRoleId(constants.USERROLE_DEVELOPERNAME_FRONTOFFICE_RESELLER);
        update u;

        u = [SELECT Id, UserRoleId FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){

            List<Contact> contactList = [SELECT Id, CompanyOwner__c FROM Contact WHERE CompanyOwner__c = null LIMIT 1];
            HDT_UTL_CompanyOwner.feedCompanyOwner(contactList);
        }

        Test.stopTest();
    }
}
