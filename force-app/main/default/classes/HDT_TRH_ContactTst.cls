/**
* @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
* @date 17/09/2021
* @description HDT_TRH_Contact Test Class
* @history Lucas da Silva Fernandes – 17/09/2021 – Created Class
*/
@isTest
public with sharing class HDT_TRH_ContactTst {
    
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    
    @TestSetup
    static void setup(){
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
        
        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
        
        internalUser.UserPermissionsMarketingUser=true;
        
        insert internalUser;
        
        System.runAs(internalUser) {
            
            List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, false, 'HERA COMM', 'Azienda', 'Aziende SME');
            accList[0].VATNumber__c='13288870150';
            accList[0].FiscalCode__c='KNMKST92D20Z100D';
            insert accList;
            List<Contact> contList=HDT_UTL_DataFactoryTst.createContact(1, false, accList[0].Id);
            contList[0].VATNumber__c='13288870150';
            contList[0].FiscalCode__c='KNMKST92D20Z100D';
            insert contList;
        }
    }
    
    @isTest
    public static void testInsert() {
        
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
        
        System.runAs(u){
            
            Test.startTest();
            
            Account acc = [SELECT Id FROM Account WHERE Category__c = 'Aziende SME'];
            List<Contact> ct = HDT_UTL_DataFactoryTst.createContact(1, false, acc.Id);
            ct[0].FirstName='Princess';
            ct[0].LastName='Toadstool';
            insert ct;
            
            List<Contact> ctList = [SELECT Id FROM Contact WHERE FirstName = 'Princess'];
            
            Test.stopTest();
            
            System.assertEquals(false, ctList.isEmpty(), 'Contact created.');
            System.assertNotEquals(true, ctList.isEmpty(), 'Contact creation failed.');
        }
    }
    
    @isTest
    public static void testUpdate() {
        
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
        
        System.runAs(u){
            
            Test.startTest();
            
            List<Contact> ctList = [SELECT Id, FirstName, LastName FROM Contact WHERE CompanyOwner__c = 'HERA COMM'];
            ctList[0].FirstName = 'Joe';
            ctList[0].LastName = 'Frazier';
            update ctList;
            
            List<Contact> contacts = [SELECT Id FROM Contact WHERE FirstName = 'Joe'];
            
            Test.stopTest();
            
            System.assertEquals(false, contacts.isEmpty(), 'Contact created.');
            System.assertNotEquals(true, contacts.isEmpty(), 'Contact creation failed.');
        }
    }
}