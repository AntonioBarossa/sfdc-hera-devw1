@IsTest
public with sharing class HDT_UTL_BillingProfileTst {
    @TestSetup
    static void makeData(){
        List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,false,'MMS','G3 - MMS Azienda','Aziende SME');
        accs[0].FirstName__c = 'Mario';
        accs[0].LastName__c = 'Rossi';
        accs[0].FiscalCode__c = 'RSSMRA80A01H501U';
        insert accs;
    }

    @IsTest
    public static void billingProfileWithoutAccount(){
        BillingProfile__c bp = new BillingProfile__c(ContractAccountCode__c = '200008867681',
        PaymentMethod__c = 'RID',
        SignatoryType__c = 'Stesso Sottoscrittore');
        Test.startTest();
            insert bp;
            bp.Account__c = [SELECT id FROM Account LIMIT 1].Id;
            update bp;
        Test.stopTest();
        bp = [SELECT id, Account__r.FirstName__c, Account__r.LastName__c, Account__r.FiscalCode__c, BankAccountSignatoryFirstName__c, BankAccountSignatoryLastName__c, BankAccountSignatoryFiscalCode__c FROM BillingProfile__c WHERE Id =:bp.Id];
        System.assertEquals(bp.Account__r.FirstName__c, bp.BankAccountSignatoryFirstName__c, 'Nome non corretto');
        System.assertEquals(bp.Account__r.LastName__c, bp.BankAccountSignatoryLastName__c, 'Cognome non corretto');
        System.assertEquals(bp.Account__r.FiscalCode__c, bp.BankAccountSignatoryFiscalCode__c, 'Codice Fiscale non corretto');
    }

    @IsTest
    public static void billingProfileRid(){
        BillingProfile__c bp = new BillingProfile__c(
            ContractAccountCode__c = '200008867681',
            PaymentMethod__c = 'RID',
            SignatoryType__c = 'Stesso Sottoscrittore',
            Account__c = [SELECT id FROM Account LIMIT 1].Id
        );
        Test.startTest();
            insert bp;
        Test.stopTest();
        bp = [SELECT id, Account__r.FirstName__c, Account__r.LastName__c, Account__r.FiscalCode__c, BankAccountSignatoryFirstName__c, BankAccountSignatoryLastName__c, BankAccountSignatoryFiscalCode__c FROM BillingProfile__c WHERE Id =:bp.Id];
        System.assertEquals(bp.Account__r.FirstName__c, bp.BankAccountSignatoryFirstName__c, 'Nome non corretto');
        System.assertEquals(bp.Account__r.LastName__c, bp.BankAccountSignatoryLastName__c, 'Cognome non corretto');
        System.assertEquals(bp.Account__r.FiscalCode__c, bp.BankAccountSignatoryFiscalCode__c, 'Codice Fiscale non corretto');
    }

    @IsTest
    public static void billingProfileRidWithFields(){
        BillingProfile__c bp = new BillingProfile__c(
            ContractAccountCode__c = '200008867681',
            PaymentMethod__c = 'RID',
            SignatoryType__c = 'Stesso Sottoscrittore',
            BankAccountSignatoryFirstName__c = 'TEST'
        );
        Test.startTest();
            insert bp;
        Test.stopTest();
        bp = [SELECT id, BankAccountSignatoryFirstName__c, BankAccountSignatoryLastName__c, BankAccountSignatoryFiscalCode__c FROM BillingProfile__c WHERE Id =:bp.Id];
        System.assertEquals('TEST', bp.BankAccountSignatoryFirstName__c, 'Nome non corretto');
    }

    @IsTest
    public static void billingProfileNoRid(){
        BillingProfile__c bp = new BillingProfile__c(
            ContractAccountCode__c = '200008867681',
            PaymentMethod__c = 'Bollettino postale',
            BillSendingMethod__c = 'Bolletta per e-mail',
            Account__c = [SELECT id FROM Account LIMIT 1].Id
        );
        Test.startTest();
            insert bp;
        Test.stopTest();
        bp = [SELECT id, Account__r.FirstName__c, Account__r.LastName__c, Account__r.FiscalCode__c, BankAccountSignatoryFirstName__c, BankAccountSignatoryLastName__c, BankAccountSignatoryFiscalCode__c FROM BillingProfile__c WHERE Id =:bp.Id];
        System.assert(bp.Account__r.FirstName__c != bp.BankAccountSignatoryFirstName__c, 'Nome non corretto');
        System.assert(bp.Account__r.LastName__c != bp.BankAccountSignatoryLastName__c, 'Cognome non corretto');
        System.assert(bp.Account__r.FiscalCode__c != bp.BankAccountSignatoryFiscalCode__c, 'Codice Fiscale non corretto');
    }
}