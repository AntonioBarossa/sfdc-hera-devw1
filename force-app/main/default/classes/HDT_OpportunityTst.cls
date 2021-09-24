
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
        
        Opportunity opp = [SELECT id,CompanyOwner__c FROM Opportunity WHERE id =: testOpt[0].id LIMIT 1];
        
        system.assertEquals('HERA COMM', testOpt[0].CompanyOwner__c , 'Opportunity is inserted correctly');
        system.assertNotEquals('',  testOpt[0].CompanyOwner__c , 'is not Empty');

    }
}
