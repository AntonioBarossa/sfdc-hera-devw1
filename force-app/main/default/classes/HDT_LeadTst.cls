@isTest
public with sharing class HDT_LeadTst {

    @isTest
    public static void HDT_LeadTst() {

        List<Lead> testLead = HDT_UTL_DataFactoryTst.createLead(1, false);

        insert testLead;

        testLead[0].CompanyOwner__c = 'HERA COMM';

        update testLead;


        Lead l = [SELECT id,CompanyOwner__c FROM Lead WHERE id =: testLead[0].id LIMIT 1];
        
        system.assertEquals('HERA COMM', testLead[0].CompanyOwner__c , 'lead is inserted correctly');
        system.assertNotEquals('',  testLead[0].CompanyOwner__c , 'is not Empty');






    }
}
