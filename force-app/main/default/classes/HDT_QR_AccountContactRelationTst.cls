@isTest
public with sharing class HDT_QR_AccountContactRelationTst {
    
    private static HDT_QR_Account qrAcc = new HDT_QR_Account();
    
    @TestSetup
    static void setup(){
        
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, false, 'HERA COMM', 'Azienda', 'Aziende SME');
        accList[0].BillingStreetNumberExtension__c = 'nExt';
        accList[0].BillingCity = 'Torino';
        accList[0].BillingPostalCode = '10123';
        accList[0].BillingCountry = 'Vatican';
        accList[0].BillingStreetCode__c = 'myStreetCode';
        accList[0].BillingCityCode__c = 'TO';
        accList[0].Code__c = 'iddqd';
        insert accList;
        
        List<Contact> cntList = HDT_UTL_DataFactoryTst.createContact(3, false, accList[0].Id);
        
        insert cntList;
        
        AccountContactRelation acr = [SELECT Id, Roles, IsManagerSOL__c, IsActive FROM AccountContactRelation Where AccountId =: accList[0].Id AND ContactId =: cntList[0].Id];
        acr.IsActive = True;
        acr.Roles = 'Titolare';
        acr.IsManagerSOL__c = True;
        update acr; 
        
        AccountContactRelation acrOne = [SELECT Id, Roles, IsActive FROM AccountContactRelation Where AccountId =: accList[0].Id AND ContactId =: cntList[1].Id];
        acrOne.IsActive = True;
        acrOne.Roles = 'Legale rappresentante';
        update acrOne; 
        
        AccountContactRelation acrTwo = [SELECT Id, Roles, IsActive FROM AccountContactRelation Where AccountId =: accList[0].Id AND ContactId =: cntList[2].Id];
        acrTwo.IsActive = True;
        acrTwo.Roles = 'Amministratore condominio';
        update acrTwo; 
        
    }
    
    @isTest
    public static void testgetRelatedAccountsTest() {
        
        Test.startTest();
        HDT_QR_AccountContactRelation acr = new HDT_QR_AccountContactRelation();
        Contact cnt = [SELECT Id, AccountId FROM Contact WHERE Company__c='HC+HCM+EENE' LIMIT 1];
        List<AccountContactRelation> accQrTest = new List<AccountContactRelation>();
        accQrTest = acr.getRelatedAccounts(cnt.Id);
        
        System.assertEquals(cnt.AccountId, accQrTest[0].AccountId, 'Account Id match.');
        
        Test.stopTest();   
    }
    
    
    
    @isTest
    public static void getAccountContactRelationTest() {
        
        Test.startTest();
        
        HDT_QR_AccountContactRelation acr = new HDT_QR_AccountContactRelation();
        Contact cnt = [SELECT Id, AccountId FROM Contact WHERE Company__c='HC+HCM+EENE' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Id=:cnt.AccountId];
        
        List<AccountContactRelation> accQrTest = new List<AccountContactRelation>();
        accQRTest = acr.getAccountContactRelation(acc.Id, cnt.Id,  'Id, AccountId');
        
        System.assertEquals(cnt.AccountId, accQrTest[0].AccountId, 'Account Id match.');
        HDT_QR_AccountContactRelation testClass = new HDT_QR_AccountContactRelation();
        List<String> cnts = new List<String>();
        List<String> accs = new List<String>();
        cnts.add(String.valueOf(cnt.Id));
        accs.add(String.valueOf(cnt.AccountId));
        List<AccountContactRelation> accQrTestl = new List<AccountContactRelation>();
        accQRTestL = testClass.getAccountContactRelation(cnts, accs,  'Id, AccountId');
        
        //System.assertEquals(cnt.AccountId, accQRTestL[0].AccountId, 'Account Id match.');
        
        Test.stopTest();   
    }
    
    
    
    @isTest
    public static void getRecordsFilteredByAccountAndContactTest() {
        
        Test.startTest();
        
        HDT_QR_AccountContactRelation acr = new HDT_QR_AccountContactRelation();
        Contact cnt = [SELECT Id, AccountId FROM Contact WHERE Company__c='HC+HCM+EENE' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Id=:cnt.AccountId];
        
        List<AccountContactRelation> accQrTest = new List<AccountContactRelation>();
        accQrTest = acr.getRecordsFilteredByAccountAndContact(String.valueOf(acc.Id), String.valueOf(cnt.Id));
        
        System.assertEquals('Titolare', accQrTest[0].Roles, 'Account Id match.');
        
        Test.stopTest();   
    }
    
    
    @isTest
    public static void getRecordByAccountIdTest() {
        
        Test.startTest();
        
        HDT_QR_AccountContactRelation acr = new HDT_QR_AccountContactRelation();
        Contact cnt = [SELECT Id, AccountId FROM Contact WHERE Company__c='HC+HCM+EENE' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Id=:cnt.AccountId];
        
        List<AccountContactRelation> accQrTest = new List<AccountContactRelation>();
        accQrTest = acr.getRecordByAccountId(String.valueOf(acc.Id));
        
        System.assertNotEquals(null, accQrTest[0].Id, 'Account Id match.');
        
        Test.stopTest();   
    }
    
    @isTest
    public static void getContactsByAccountWithRolesTest() {
        
        Test.startTest();
        
        HDT_QR_AccountContactRelation acr = new HDT_QR_AccountContactRelation();
        Contact cnt = [SELECT Id, AccountId FROM Contact WHERE Company__c='HC+HCM+EENE' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Id=:cnt.AccountId];
        
        List<AccountContactRelation> accQrTest = new List<AccountContactRelation>();
        accQrTest = acr.getContactsByAccountWithRoles(String.valueOf(acc.Id));
        
        System.assertNotEquals(null, accQrTest[0].Id, 'Account Id match.');
        
        Test.stopTest();   
    }
    @isTest
    public static void getContactsByAccountWithRolesListTest() {
        
        Test.startTest();
        Contact cnt = [SELECT Id, AccountId FROM Contact WHERE Company__c='HC+HCM+EENE' LIMIT 1];      
        List<String> cnts = new List<String>();
        List<String> accs = new List<String>();
        cnts.add(String.valueOf(cnt.Id));
        accs.add(String.valueOf(cnt.AccountId));
        HDT_QR_AccountContactRelation testClass = new HDT_QR_AccountContactRelation();
        List<AccountContactRelation> accQrTestl = new List<AccountContactRelation>();
        accQRTestL = testClass.getContactsByAccountWithRoles(accs);
        
        System.assertNotEquals(null, accQrTestl[0].Id, 'Account Id match.');
        
        Test.stopTest();   
    }
    
    @isTest
    public static void getPrimaryContactRelationsTest() {
        
        Test.startTest();
        Contact cnt = [SELECT Id, AccountId FROM Contact WHERE Company__c='HC+HCM+EENE' LIMIT 1];      
        List<String> cnts = new List<String>();
        Set<Id> accs = new Set<Id>();
        cnts.add(String.valueOf(cnt.Id));
        accs.add(cnt.AccountId);
        HDT_QR_AccountContactRelation testClass = new HDT_QR_AccountContactRelation();
        List<AccountContactRelation> accQrTestl = new List<AccountContactRelation>();
        
        accQRTestL = testClass.getPrimaryContactRelations(accs);
        System.assertNotEquals(null, accQrTestl[0].AccountId, 'Account Id match.');
        
        AccountContactRelation accQrTest = new AccountContactRelation();
        accQrTest = testClass.getPrimaryContactRelation(cnt.AccountId);
        System.assertNotEquals(null, accQrTest.AccountId, 'Account Id match.');
        
        accQrTest = testClass.getLegalRepresentativeRelation(cnt.AccountId);
        System.assertNotEquals(null, accQrTest.AccountId, 'Account Id match.');
        
        accQrTest = testClass.getActiveAdministratorRelation(cnt.AccountId);
        System.assertNotEquals(null, accQrTest.AccountId, 'Account Id match.');
        
        accQrTest = testClass.getPrimaryContactRelationBusiness(cnt.AccountId);
        System.assertNotEquals(null, accQrTest.AccountId, 'Account Id match.');
        Test.stopTest();   
        
        accQrTestl = testClass.getAdministratorRelations();
        System.assertNotEquals(null, accQrTestl[0].AccountId, 'Account Id match.');
        
        accQrTestl = testClass.getSolContactRelations(String.valueOf(cnt.AccountId));
        System.assertNotEquals(null, accQrTestl[0].AccountId, 'Account Id match.');
        
        accQrTestl = testClass.getSolContactRelation(String.valueOf(cnt.AccountId), String.valueOf(cnt.Id));
        System.assertNotEquals(null, accQrTestl[0].AccountId, 'Account Id match.');
    }
    @isTest
    public static void getPrimaryRelationsByContactsTest() {
        
        Test.startTest();
        Contact cnt = [SELECT Id, AccountId FROM Contact WHERE Company__c='HC+HCM+EENE' LIMIT 1];      
        Set<Id> cnts = new Set<Id>();
        Set<Id> accs = new Set<Id>();
        cnts.add(cnt.Id);
        accs.add(cnt.AccountId);
        HDT_QR_AccountContactRelation testClass = new HDT_QR_AccountContactRelation();
        List<AccountContactRelation> accQrTestl = new List<AccountContactRelation>();
        accQrTestl = testClass.getPrimaryRelationsByContacts(cnts);
        
        System.assertNotEquals(null, accQrTestl[0].AccountId, 'Account Id match.');
        
        
        
        Test.stopTest();   
    }

    @isTest
    public static void getBpCaCreateTst()
    {
        List<Account> accList = [SELECT Id FROM Account];
        List<AccountContactRelation> acrList = [SELECT Id,Roles FROM AccountContactRelation WHERE AccountId= :accList[0].Id];

        acrList[0].Roles = 'Titolare;Legale rappresentante;Amministratore condominio';
        update acrList;
        HDT_QR_AccountContactRelation testClass = new HDT_QR_AccountContactRelation();
        Test.startTest();
            List<AccountContactRelation> result = testClass.getCreateBpCa(accList[0].Id);
        Test.stopTest();
        System.assertEquals(true, !result.isEmpty(), 'Acr non trovato');
    }
    
    
}