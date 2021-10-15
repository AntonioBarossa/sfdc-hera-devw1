@isTest
public with sharing class HDT_LC_AccountSelectorControllerTst {
    
    //DEBUG
    
    
    //DATA
    private static Boolean isAccount = false;
    private static Boolean isLead = false;
    
    
    //TEST SETUP
    private static void mySetup() {
        HDT_UTL_DataFactoryTst.pClickInstance();
        //ACCOUNT
        Account account = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Enti')[0];
        
        //CONTACT
        Contact contact;
        if(!isLead){
            contact = new Contact(
                AccountId = account.Id,
                LastName = 'Rossi'
            );
            insert contact;
        }
        
        //LEAD
        Lead myLead = HDT_UTL_DataFactoryTst.createLead(1, false)[0];
        myLead.VATNumber__c = account.VATNumber__c;
        insert myLead;
        
        //ACTIVITY
        wrts_prcgvr__Activity__c activity;
        if(isAccount){
            //FISCAL CODE
            activity = new wrts_prcgvr__Activity__c(
                wrts_prcgvr__Status__c = 'Not Started',
                Type__c = 'Sportello',
                FiscalCode__c = 'Rossi'
            );
        } else if(isLead){
            //VAT NUMBER
            activity = new wrts_prcgvr__Activity__c(
                wrts_prcgvr__Status__c = 'Not Started',
                Type__c = 'Sportello',
                FiscalCode__c = '%LastNameTest%'
            );
        } else {
            activity = new wrts_prcgvr__Activity__c(
                wrts_prcgvr__Status__c = 'Not Started',
                Type__c = 'Sportello',
                Contact__c = contact.Id
            );
        }

        insert activity;
        // activityId = activity.Id;
    }
    
    
    //TESTS
    @isTest 
    private static void initTest_NoAccount() {
        
        //SETUP
        mySetup();
        wrts_prcgvr__Activity__c activity = [SELECT Id FROM wrts_prcgvr__Activity__c];
        
        //TESTING
        String result = HDT_LC_AccountSelectorController.init(activity.Id);
        
        //RETRIEVING DATA
        wrts_prcgvr__Activity__c updatedActivity = [SELECT Id, Account__c, Contact__c FROM wrts_prcgvr__Activity__c];
        Account acc = [SELECT Id FROM Account];
        Contact con = [SELECT Id FROM Contact];
        
        //ASSERTS
        HDT_LC_AccountSelectorController.HDT_UTL_Struct utlStruct = (HDT_LC_AccountSelectorController.HDT_UTL_Struct) JSON.deserialize(result, HDT_LC_AccountSelectorController.HDT_UTL_Struct.class);
        System.assertEquals(1, utlStruct.accounts.size(), 'Non è stato recuperato il numero corretto di Account.');
        System.assertEquals(acc.Id, updatedActivity.Account__c, 'Non è stata aggiornata Activity (Account).');
        System.assertEquals(con.Id, updatedActivity.Contact__c, 'Problema rilevato su Activity (Contact).');
        System.assertEquals(1, utlStruct.accounts.size(), 'Non è stato recuperato il numero corretto di Account.');
        
    }
    
    
    @isTest 
    private static void initTest_NoContact() {
        
        //SETUP
        isAccount = true;
        mySetup();
        wrts_prcgvr__Activity__c activity = [SELECT Id FROM wrts_prcgvr__Activity__c];
        
        //TESTING
        String result = HDT_LC_AccountSelectorController.init(activity.Id);
        
        //RETRIEVING DATA
        wrts_prcgvr__Activity__c updatedActivity = [SELECT Id, Account__c, Contact__c FROM wrts_prcgvr__Activity__c];
        Account acc = [SELECT Id FROM Account];
        Contact con = [SELECT Id FROM Contact];
        
        //ASSERTS
        HDT_LC_AccountSelectorController.HDT_UTL_Struct utlStruct = (HDT_LC_AccountSelectorController.HDT_UTL_Struct) JSON.deserialize(result, HDT_LC_AccountSelectorController.HDT_UTL_Struct.class);
        System.assertEquals(1, utlStruct.accounts.size(), 'Non è stato recuperato il numero corretto di Account.');
        System.assertEquals(1, utlStruct.contacts.size(), 'Non è stato recuperato il numero corretto di Contact.');
        System.assertEquals(acc.Id, updatedActivity.Account__c, 'Non è stata aggiornata Activity (Account).');
        System.assertEquals(con.Id, updatedActivity.Contact__c, 'Non è stata aggiornata Activity (Contact).');
        System.assertEquals(acc.Id, utlStruct.accountId, 'Result accountId non è corretto.');
        System.assertEquals(1, utlStruct.accounts.size(), 'Non è stato recuperato il numero corretto di Account.');
    }
    
    
    @isTest 
    private static void initTest_IsLead() {
        
        //SETUP
        isLead = true;
        mySetup();
        wrts_prcgvr__Activity__c activity = [SELECT Id FROM wrts_prcgvr__Activity__c];
        
        //TESTING
        String result = HDT_LC_AccountSelectorController.init(activity.Id);
        
        //RETRIEVING DATA
        wrts_prcgvr__Activity__c updatedActivity = [SELECT Id, Lead__c FROM wrts_prcgvr__Activity__c];
        Lead lea = [SELECT Id FROM Lead];
        
        //ASSERTS
        HDT_LC_AccountSelectorController.HDT_UTL_Struct utlStruct = (HDT_LC_AccountSelectorController.HDT_UTL_Struct) JSON.deserialize(result, HDT_LC_AccountSelectorController.HDT_UTL_Struct.class);
        System.assertEquals(lea.Id, updatedActivity.Lead__c, 'Non è stata aggiornata Activity (Lead).');
        System.assertEquals(utlStruct.leadId, updatedActivity.Lead__c, 'Non è stato restituito il result corretto.');
    }
    
    

    @isTest 
    private static void search() {
        mySetup();
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
    
    
    @isTest 
    private static void handleAccountSerialized() {
        mySetup();
        wrts_prcgvr__Activity__c activity = [SELECT Id FROM wrts_prcgvr__Activity__c];
        Contact contact = [SELECT Id FROM Contact];
        HDT_LC_AccountSelectorController.handleAccountSerialized(contact.Id, activity.Id);
        
        //CATCH ERROR TEST
        Boolean caught = false;
        try{
            HDT_LC_AccountSelectorController.handleAccountSerialized('Fake Id', activity.Id);
        } catch (Exception e) {
            caught = true;
            System.debug('seach - exception message: ' + e.getMessage());
            System.debug('seach - exception type name: ' + e.getTypeName());
            System.debug('seach - exception stack trace string: ' + e.getStackTraceString());
        }
        System.assert(caught, 'Eccezione non avvenuta.');
        
    }
    
    
    @isTest 
    public static void reset() {
        mySetup();
        wrts_prcgvr__Activity__c activity = [SELECT Id FROM wrts_prcgvr__Activity__c];
        HDT_LC_AccountSelectorController.reset(activity.Id);
    }
    
}