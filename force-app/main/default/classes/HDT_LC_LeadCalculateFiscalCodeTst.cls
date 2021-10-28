/**
* @author Luis Bispo (luis.bispo@engdb.com.br)
* @date 13/07/2021
* @description HDT_LC_LeadCalculateFiscalCodeTst for Test Classes
* @history Luis Bispo – 13/07/2021 – Created class
*/

@isTest
public with sharing class HDT_LC_LeadCalculateFiscalCodeTst {

    @testSetup
    static void setup(){

        HDT_UTL_DataFactoryTst.createLead(1, true);
        HDT_UTL_DataFactoryTst.createCity();

    }

    @isTest
    public static void testCalculateLeadFiscalCode(){
        
        Lead testLead = [SELECT id From Lead LIMIT 1];
        
        Test.startTest();

        String result;
        result =  HDT_LC_LeadCalculateFiscalCode.CalculateLeadFiscalCode(testLead.Id);

        System.assertEquals('', result, 'Lead is not correct!');
        System.assertNotEquals('LastNameTest', result, 'CalculateLeadFiscalCode did not work correctly');

        Test.stopTest();
    }

    @isTest
    public static void testCalculateLeadFiscalCodeFail(){

        Lead testLead = [SELECT id, LastName, FirstName, Birthdate__c, Gender__c, Birthcity__c From Lead LIMIT 1];
        testLead.Birthdate__c = null;
        testLead.Gender__c = '';
        testLead.Birthcity__c = '';
        update testLead;

        Test.startTest();

        String result;
        result =  HDT_LC_LeadCalculateFiscalCode.CalculateLeadFiscalCode(testLead.Id);

        System.assertEquals('Birthdate Gender Birthcity must be completed!', result, 'CalculateLeadFiscalCode did not work correctly');
        System.assertNotEquals('', result, 'CalculateLeadFiscalCode did not work correctly');
        
        Test.stopTest();

    }
}
