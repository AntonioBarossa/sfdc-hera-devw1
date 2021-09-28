

@isTest
public with sharing class HDT_QuoteTst {

    @isTest
    public static void HDT_QuoteTst() {


       // List<SBQQ__Quote__c> Qq = [SELECT id,Name,OrderReference__c,SBQQ__Opportunity2__c,Sale__c FROM SBQQ__Quote__c WHERE id = 'a181X000000FmqlQAC' LIMIT 1];

       // System.debug('Qq  ............... '+ Qq);
        List<Account> Acctest = HDT_UTL_DataFactoryTst.createAccountPartner(1,false,'accTest');
        Acctest[0].CompanyOwner__c  = 'HERA COMM';

        insert Acctest;
        
        Account acct = [SELECT id,Name FROM Account WHERE id =: Acctest[0].id ];
        List<Order> Ordertest = HDT_UTL_DataFactoryTst.createOrder( 1, true, acct.id ,'Bozza');
        List<Opportunity> OppTest = HDT_UTL_DataFactoryTst.createOpportunity(1, true);
        List<Sale__c> SaleTest = HDT_UTL_DataFactoryTst.createSale(1,true,acct.id, 'Bozza');


        List<SBQQ__Quote__c> testQ = HDT_UTL_DataFactoryTst.createQuote(1,true,  Ordertest[0].id , OppTest[0].id , SaleTest[0].id ,'Quote');
        

       // insert testQ;


       // testQ[0].SBQQ__Type__c  = 'Amendment';

      //  update testQ;



        SBQQ__Quote__c Q = [SELECT id,SBQQ__Type__c FROM SBQQ__Quote__c WHERE id =: testQ[0].id LIMIT 1];
        
        system.assertEquals('Quote', testQ[0].SBQQ__Type__c , 'Quote is inserted correctly');
        system.assertNotEquals('',  testQ[0].SBQQ__Type__c , 'is not Empty');

    }
}
