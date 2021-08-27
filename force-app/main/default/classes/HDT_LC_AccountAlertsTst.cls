@isTest
public with sharing class HDT_LC_AccountAlertsTst {
    
    //DEBUG
    public static final String TEST_NAME = 'HDT_LC_AccountAlertsTst';
    
    
    //TEST SETUP
    
    
    //TODO: NOTA AI POSTERI
    /*
    Relativamente alla porzione di codice seguente:
    HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
    
    Da una veloce analisi del codice degli Apex Test risulta che numerose invocazioni di questi metodi usino (come è infatti buona practice) 
    gli stessi parametri in contesti diversi.
    
    Potrebbe pertanto essere utile realizzare un'altra classe Utility che velocizza ulteriormente la stesura e il debug dei test andando a wrappare questi 
    metodi factory in modo che non sia più necessario passare argomenti espliciti quando vengono invocate nei test setup. 
    
    In questo modo, in caso sia necessario manutenere un test setup a causa di evoluzioni del progetto, si ridurrebbe il numero di interventi manuali 
    necessari ad aggiustare le porzioni di codice ora non più.
    
    Come bonus, si potrebbero realizzare anche dei metodi che realizzano "bulk" di dati / predispongono i dati per processi conosciuti e frequentemente utilizzati.
    
    */
    
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
        System.assert(String.isNotBlank(jsonResult));
        System.assert(result != null);
        System.assertEquals(myAlertConfig.Id, result.Id);
    }
    
    //getAvailableRulesFor
    @isTest
    private static void getAvailableRulesForTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'getAccountAlertsTest';
        System.debug(debugString);
        
        //SETUP
        Account acc = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME')[0];
        AlertConfiguration__c myAlertConfig = new AlertConfiguration__c(AccountCategory__c = acc.Category__c);
        insert myAlertConfig;
        
        //TESTING
        String jsonResult = HDT_LC_AccountAlerts.getAvailableRulesFor(acc.Category__c, acc.Id);
        AlertConfiguration__c result = ((List<AlertConfiguration__c>) JSON.deserialize(jsonResult, List<AlertConfiguration__c>.class))[0];
        
        //ASSERTS
        System.assert(String.isNotBlank(jsonResult));
        System.assert(result != null);
        System.assertEquals(myAlertConfig.Id, result.Id);
        
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
        System.assert(result);
        System.assert(accountAlert != null);
        System.assertEquals(accountAlert.Account__c, acc.Id);
        System.assertEquals(accountAlert.AlertConfiguration__c, myAlert.Id);
        
        
    }
    
}
