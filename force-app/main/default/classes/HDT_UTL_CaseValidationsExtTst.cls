@isTest
public with sharing class HDT_UTL_CaseValidationsExtTst 
{

    @TestSetup
    static void setup()
    {
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickCasePhase();
        
        List<Account> acc = HDT_UTL_DataFactoryTst.createAccountResidenziale(1, true, 'HERA COMM','D1 - Persona fisica', 'Famiglie');
        List<Contact> con = HDT_UTL_DataFactoryTst.createContact(1,true, acc[0].Id);
        List<ServicePoint__c> sp = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Case> c  = HDT_UTL_DataFactoryTst.createCase(1, false, acc[0].Id, con[0].Id, sp[0].Id, null, null);
        c[0].Type = 'Piano Rateizzazione';
        c[0].DepositPaymentMode__c = 'Bonifico Pagato';
        insert c;
    }

    @isTest
    static void validatePianoRataTst()
    {
        HDT_UTL_CaseValidationsExt tstClass = new HDT_UTL_CaseValidationsExt();
        List<Case> c = [SELECT Id, DepositPaymentMode__C FROM Case WHERE Type = 'Piano Rateizzazione'];
        Map<String, String> fields = new Map<String,String>{'name' => 'nome'};
        Test.startTest();
            String result = tstClass.validate(JSON.serialize(fields), c[0].Id);
            c[0].DepositPaymentMode__c = '';
            update c;
            String resultTwo = tstClass.validate(JSON.serialize(fields), c[0].Id);
        Test.stopTest();

        System.assertEquals(true, !result.containsIgnoreCase('OK') && resultTwo.containsIgnoreCase('OK'), 'Test piano rata non superato');
    }
}