

@isTest
public with sharing class HDT_QuoteTst {

    @isTest
    public static void quoteTest() {

        List<Account> acctest = HDT_UTL_DataFactoryTst.createAccountPartner(1,false,'accTest');
        acctest[0].CompanyOwner__c  = 'HERA COMM';

        insert acctest;
        
        id acctId = Acctest[0].id;
        List<Order> orderTest = HDT_UTL_DataFactoryTst.createOrder( 1, true, acctId ,'Bozza');
        List<Opportunity> oppTest = HDT_UTL_DataFactoryTst.createOpportunity(1, true);
        List<Sale__c> saleTest = HDT_UTL_DataFactoryTst.createSale(1,true,acctId, 'Bozza');


        List<SBQQ__Quote__c> testQ = HDT_UTL_DataFactoryTst.createQuote(1,true,  orderTest[0].id , oppTest[0].id , saleTest[0].id ,'Quote');

        
        system.assertEquals(true, testQ[0].Id != null , 'Quote was not inserted correctly');
        system.assertNotEquals(true,  testQ[0].Id == null , 'The Id of the inserted quote is empty');

    }
}
