
@isTest
public with sharing class HDT_OpportunityTst {

    @isTest
    public static void HDT_OpportunityTst() {

      //  List<Account> testAcc =  HDT_UTL_DataFactoryTst.createAccountPartner(1, true , 'testact');
      //  Account acct = [SELECT id,Name FROM Account WHERE Name =: 'testact'];
        
        //Account acct = new Account(Name='Test Account');
        //insert acct;
        //Opportunity oppt =  new Opportunity (Name=acct.Name + 'ing', CloseDate = system.today().addMonths(1), AccountId = acct.Id )
        List<Opportunity> testOpt =  HDT_UTL_DataFactoryTst.createOpportunity(1, false);

        testOpt[0].CompanyOwner__c = 'HERA COMM';

        insert testOpt;
        
        system.assertEquals(true, testOpt[0].Id != null, 'The opportunity was not inserted correctly');
        system.assertNotEquals(true,  testOpt[0].Id == null, 'The Id of the inserted opportunity is null');

    }
}
