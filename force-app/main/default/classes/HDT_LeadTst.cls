@isTest
public with sharing class HDT_LeadTst {

    @isTest
    public static void HDT_LeadTst() {

        List<Lead> testLead = HDT_UTL_DataFactoryTst.createLead(1, false);

        insert testLead;

        testLead[0].CompanyOwner__c = 'HERA COMM';

        update testLead;
        
        system.assertEquals('HERA COMM', testLead[0].CompanyOwner__c , 'lead is inserted correctly');
        system.assertNotEquals('',  testLead[0].CompanyOwner__c , 'is not Empty');






    }
}
