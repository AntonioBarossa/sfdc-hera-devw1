@isTest
public with sharing class HDT_BA_OldDraftSalesTest {

    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
   
    @testSetup

    static void setup(){

        DateTime thirtyDays = System.now().addDays(-30);

        CS_DaysToExpiration__c testCS = new CS_DaysToExpiration__c(Name='Vendita',Type__c='Vendita', NumberOfDays__c='60');
        insert testCS;
        
        Account acc = new Account(name='testAccount');
        insert acc;

        List<Sale__c> sales = new List<Sale__c>();
        List<Id> saleIds = new List<Id>();
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        List<Opportunity> opps = new List<Opportunity>();

        for (Integer i=0; i<10; i++) {
            sales.add(new Sale__c(name='TestVendita' + i, Status__c='Bozza', Account__c=acc.Id));
        }

        insert sales;

        for (Sale__c s : sales) {
            saleIds.add(s.Id);
            Test.setCreatedDate(s.Id, thirtyDays);
        }

        for(Sale__c sale : [SELECT Id from Sale__c WHERE Id IN :saleIds]) {
            quotes.add(new SBQQ__Quote__c(SBQQ__Status__c='Test', Sale__c=sale.Id));
            opps.add(new Opportunity(name='TestOpp', StageName='Proposal', Sale__c=sale.Id, CloseDate=Date.today()));
        }
        insert quotes;
        insert opps;

        system.debug(sales);
        system.debug(saleIds);

        system.debug(quotes);
        system.debug(opps);

        /* List<Sale__c> myList = [SELECT Id, Status__c, CreatedDate, (SELECT Id, SBQQ__Status__c from Quotes__r), (SELECT Id, StageName from Opportunities__r) from Sale__c where Status__c='Bozza'];
        system.debug(myList); */
    }

    @isTest
    public static void testOldDratfSales() {
        
        Test.startTest();
        HDT_BA_OldDraftSales ods = new HDT_BA_OldDraftSales();
        Id batchId = Database.executeBatch(ods);
        Test.stopTest();

       List<Sale__c> mySales = [SELECT Id, Status__c, CreatedDate, (SELECT Id, SBQQ__Status__c from Quotes__r), (SELECT Id, StageName from Opportunities__r) from Sale__c];

       for (Sale__c s : mySales) {
           system.debug(s);
           system.assertEquals('Annullata', s.Status__c, 'value of parameter is matching');

           for(SBQQ__Quote__c quote : s.Quotes__r) {
               system.debug(quote);
               system.assertEquals('Annullata', quote.SBQQ__Status__c, 'value of parameter is matching');
           }
           for(Opportunity opp : s.Opportunities__r) {
               system.debug(opp);
               system.assertEquals('Chiusa/Annullata', opp.StageName, 'value of parameter is matching');
           }
       }
    }

    @isTest 
    public static void testBatchSchedule() {

        Test.startTest();
        String jobId = System.schedule('ScheduleOldDraftSalesTest', CRON_EXP, new HDT_SCH_OldDraftSalesSchedule());

        // checkinhg that batch hasn't been run yet
        List<Sale__c> mySales = [SELECT Id, Status__c FROM Sale__c WHERE Status__c='Annullata'];
        System.assertEquals(0, mySales.size(), 'Sales exist before baatch execution');
        Test.stopTest();
        
        // check schedulable is in job list
        List<AsyncApexJob> jobsScheduled = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex'];
        System.assertEquals(1, jobsScheduled.size(), 'expecting one scheduled job');
        System.assertEquals('HDT_SCH_OldDraftSalesSchedule', jobsScheduled[0].ApexClass.Name, 'expecting specific scheduled job');

        // check apex batch is in job list
        List<AsyncApexJob> jobsApexBatch = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'BatchApex'];
        System.assertEquals(1, jobsApexBatch.size(), 'expecting one apex batch job');
        System.assertEquals('HDT_BA_OldDraftSales', jobsApexBatch[0].ApexClass.Name, 'expecting specific batch job');

    }
}