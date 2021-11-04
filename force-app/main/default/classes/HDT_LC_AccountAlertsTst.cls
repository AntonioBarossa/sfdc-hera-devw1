@isTest
public with sharing class HDT_LC_AccountAlertsTst {
    
    //DEBUG
    public static final String TEST_NAME = 'HDT_LC_AccountAlertsTst';
    
    
    //TEST SETUP
    private static void mySetup(){
        List<Account> acc = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        
        //BILLING PROFILE
        BillingProfile__c myBilling = HDT_UTL_DataFactoryTst.createBillingProfile(1, false, acc[0].Id)[0];
        myBilling.BillSendingMethod__c = 'Bolletta per e-mail';
        insert myBilling;
        
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, acc[0].Id, 'Bozza');
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, acc[0].Id);
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        
        //CONTRACT
        Contract myContract = HDT_UTL_DataFactoryTst.createContract(1, false, acc[0].id)[0];
        myContract.Status = 'Attivo';
        myContract.BillingProfile__c = myBilling.Id;
        insert myContract;
        
        HDT_UTL_DataFactoryTst.createCase(1, true, acc[0].id, contactList[0].Id, servPointList[0].id, myContract.id, ordList[0].id);
        HDT_UTL_DataFactoryTst.pClickCasePhase();
    }
    

    //TESTS
    
    //getAccountAlerts
    @isTest
    private static void getAccountAlertsTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'getAccountAlertsTest';
        System.debug(debugString);
        
        //SETUP
        Account acc = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME')[0];
        AlertAccountConfiguration__c myAlertConfig = new AlertAccountConfiguration__c(Account__c = acc.Id);
        insert myAlertConfig;
        
        //TESTING
        String jsonResult = HDT_LC_AccountAlerts.getAccountAlerts(acc.Id);
        AlertAccountConfiguration__c result = ((List<AlertAccountConfiguration__c>) JSON.deserialize(jsonResult, List<AlertAccountConfiguration__c>.class))[0];
        
        //ASSERTS
        System.assertEquals(true, String.isNotBlank(jsonResult), 'Json String was empty');
        System.assertEquals(true, result != null, 'Result is null');
        System.assertEquals(myAlertConfig.Id, result.Id, 'The Id from the result does not match');
    }
    
    //getAvailableRulesFor
    @isTest
    private static void getAvailableRulesForTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'getAccountAlertsTest';
        System.debug(debugString);
        
        //SETUP
        mySetup();
        
        Account acc = [SELECT Id, Category__c FROM Account];
        
        //ALERT WITH BillSendingMethod__c
        AlertConfiguration__c myAlertConfig = new AlertConfiguration__c();
        myAlertConfig.AccountCategory__c = acc.Category__c;
        myAlertConfig.BillSendingMethod__c = 'Bolletta per e-mail';
        insert myAlertConfig;
        
        //ALERT WITHOUT BillSendingMethod__c
        AlertConfiguration__c myAlertConfig2 = new AlertConfiguration__c();
        myAlertConfig2.AccountCategory__c = acc.Category__c;
        insert myAlertConfig2;
        
        //TESTING
        String jsonResult = HDT_LC_AccountAlerts.getAvailableRulesFor(acc.Category__c, acc.Id);
        List<AlertConfiguration__c> result = (List<AlertConfiguration__c>) JSON.deserialize(jsonResult, List<AlertConfiguration__c>.class);
        
        //ASSERTS
        System.assertEquals(true, String.isNotBlank(jsonResult), 'Json String was empty');
        System.assertEquals(true, result != null, 'Result is null');
        System.assertEquals(2, result.size(), 'Result inconsistente');
        
    }
    
    
    //addAlertToAccount
    @isTest
    private static void addAlertToAccountTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'addAlertToAccountTest';
        System.debug(debugString);
        
        //SETUP
        Account acc = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME')[0];
        AlertConfiguration__c myAlert = new AlertConfiguration__c();
        insert myAlert;
        
        String serializedAlert = JSON.serialize(myAlert);
        
        //TESTING
        Boolean result = HDT_LC_AccountAlerts.addAlertToAccount(serializedAlert, acc.Id);
        
        //DATA RETRIEVE
        AlertAccountConfiguration__c accountAlert = [SELECT Id, Account__c, AlertConfiguration__c FROM AlertAccountConfiguration__c WHERE Account__c = :acc.Id];
        
        //ASSERTS
        System.assertEquals(true, result, 'Result is not true');
        System.assertEquals(true, accountAlert != null, 'accountAlert is null');
        System.assertEquals(accountAlert.Account__c, acc.Id, 'The account ids do not match');
        System.assertEquals(accountAlert.AlertConfiguration__c, myAlert.Id, 'The alert ids do not match');
        
    }
    
    
    //updateAlert
    @isTest
    private static void updateAlertTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'updateAlertTest';
        System.debug(debugString);
        
        //SETUP
        AlertAccountConfiguration__c myAlert = new AlertAccountConfiguration__c();
        insert myAlert;
        
        //
        myAlert.IsActive__c = true;
        String serializedAlert = JSON.serialize(myAlert);
        
        //TESTING
        Boolean result = HDT_LC_AccountAlerts.updateAlert(serializedAlert);
        
        //DATA RETRIEVE
        AlertAccountConfiguration__c accountAlert = [SELECT Id, IsActive__c FROM AlertAccountConfiguration__c];
        
        //ASSERTS
        System.assertEquals(true, result, 'Result is not true');
        System.assertEquals(true, accountAlert != null, 'accountAlert is null');
        System.assertEquals(true, accountAlert.IsActive__c, 'The account alert is not active');
        
    }
    
    
    //getContactDetails
    @isTest
    private static void getContactDetailsTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'getContactDetailsTest';
        System.debug(debugString);
        
        //SETUP
        ///ACCOUNT
        Account acc = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME')[0];
        
        ///CONTACT
        Contact con = HDT_UTL_DataFactoryTst.createContact(1, true, acc.Id)[0];
        con.email = 'fake@email.test';
        con.mobilePhone = '0123456789';
        update con;
        
        //TESTING EMPTY RETURN
        HDT_LC_AccountAlerts.HDT_WRP_AccountContactDetails resultempty = HDT_LC_AccountAlerts.getContactDetails(acc.Id);
        
        //ASSERTS
        System.assertEquals('', resultempty.email, 'Email string is not empty');
        System.assertEquals('', resultempty.mobilePhone, 'MobilePhone string is not empty');
        
        
        //REGULAR TESTING
        //AccountContactRelation
        AccountContactRelation acr = [SELECT Id, AccountId, Roles FROM AccountContactRelation WHERE AccountId = :acc.Id];
        System.debug(debugString + ' - ACR: ' + acr);
        acr.IsActive = true;
        acr.Roles = 'Titolare';
        update acr;
        
        //TESTING
        HDT_LC_AccountAlerts.HDT_WRP_AccountContactDetails result = HDT_LC_AccountAlerts.getContactDetails(acc.Id);
        
        //ASSERTS
        System.assertEquals(con.email, result.email, 'The email does not match the contact email');
        System.assertEquals(con.mobilePhone, result.mobilePhone, 'The movielPhone does not match the contact mobile phone');
        
    }
    
    
    //COPERTURA TESTS HDT_QR_AlertConfiguration
    //getRecordsByAccountCategory
    @isTest
    private static void getRecordsByAccountCategoryTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'getRecordsByAccountCategoryTest';
        System.debug(debugString);
        
        //SETUP
        Account acc = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME')[0];
        AlertConfiguration__c myAlertConfig = new AlertConfiguration__c(AccountCategory__c = acc.Category__c);
        insert myAlertConfig;
        
        //TESTING
        HDT_QR_AlertConfiguration myObjectToTest = new HDT_QR_AlertConfiguration();
        List<AlertConfiguration__c> result = myObjectToTest.getRecordsByAccountCategory(myAlertConfig.AccountCategory__c);
        
        //ASSERTS
        System.assertEquals(1, result.size(), 'Lista result incorretta.');
        
    }
    
    
    
    
}
