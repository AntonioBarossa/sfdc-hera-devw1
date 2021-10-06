@isTest
public with sharing class HDT_LC_AccountSelectorControllerTst {
    // private static String contactId;
    // private static String activityId;

    @testsetup 
    private static void createData() {
        Account account = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Enti')[0];
        
        Contact contact = new Contact(
            AccountId = account.Id,
            LastName = 'Rossi'
        );

        insert contact;
        // contactId = contact.Id;

        wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c(
            wrts_prcgvr__Status__c = 'Not Started',
            Type__c = 'Sportello',
            Contact__c = contact.Id
        );

        insert activity;
        // activityId = activity.Id;
    }

    @isTest 
    private static void init() {
        wrts_prcgvr__Activity__c activity = [SELECT Id FROM wrts_prcgvr__Activity__c];
        HDT_LC_AccountSelectorController.init(activity.Id);
    }

    @isTest 
    private static void search() {
        HDT_LC_AccountSelectorController.search('queryString');
        
        Account acc = [SELECT Id, CustomerCode__c FROM Account];
        HDT_LC_AccountSelectorController.search(acc.CustomerCode__c);
        
        Boolean caught = false;
        try{
            HDT_LC_AccountSelectorController.search('1000000000000000');         
        } catch (Exception e) {
            caught = true;
            System.debug('seach - exception message: ' + e.getMessage());
            System.debug('seach - exception type name: ' + e.getTypeName());
            System.debug('seach - exception stack trace string: ' + e.getStackTraceString());
        }
        System.assert(caught, 'Eccezione non avvenuta.');
        
    }

    // @isTest private static void handleLead() {
    //     HDT_LC_AccountSelectorController.handleLead('leadId', 'activityId');
    // }

    @isTest 
    private static void handleAccountSerialized() {
        wrts_prcgvr__Activity__c activity = [SELECT Id FROM wrts_prcgvr__Activity__c];
        Contact contact = [SELECT Id FROM Contact];
        HDT_LC_AccountSelectorController.handleAccountSerialized(contact.Id, activity.Id);
    }

    // @isTest public static void updateActivity() {
    //     HDT_LC_AccountSelectorController.updateActivity('activityId', 'contactId', 'accountId', 'leadId');
    // }

    @isTest 
    public static void reset() {
        wrts_prcgvr__Activity__c activity = [SELECT Id FROM wrts_prcgvr__Activity__c];
        HDT_LC_AccountSelectorController.reset(activity.Id);
    }
}