
@isTest
public with sharing class HDT_OpportunityTst {

    @isTest
    public static void opportunityTest() {

        List<Opportunity> testOpt =  HDT_UTL_DataFactoryTst.createOpportunity(1, false);

        testOpt[0].CompanyOwner__c = 'HERA COMM';

        insert testOpt;
        
        system.assertEquals(true, testOpt[0].Id != null, 'The opportunity was not inserted correctly');
        system.assertNotEquals(true,  testOpt[0].Id == null, 'The Id of the inserted opportunity is null');

    }
}
