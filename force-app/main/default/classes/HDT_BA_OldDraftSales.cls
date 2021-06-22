public with sharing class HDT_BA_OldDraftSales implements Database.Batchable<sObject> {

    private static HDT_SRV_Sale saleSrv = new HDT_SRV_Sale();
    private static HDT_SRV_Quote quoteSrv = new HDT_SRV_Quote();
    private static HDT_SRV_Opportunity opportunirySrv = new HDT_SRV_Opportunity();
    

    public Database.QueryLocator start(Database.BatchableContext bc) {

        String numberOfDays = setNumberOfDays();

        String query = 'SELECT Id, Status__c, CreatedDate, (SELECT Id, SBQQ__Status__c from Quotes__r), (SELECT Id, StageName from Opportunities__r) from Sale__c where Status__c=\'Bozza\' and CreatedDate <= LAST_N_DAYS:' + numberOfDays;
        return Database.getQueryLocator(query);
        
    }

    public void execute(Database.BatchableContext bc, List<Sale__c> scope) {
       
        List<Sale__c> sales = new List<Sale__c>();
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        List<Opportunity> opps = new List<Opportunity>();


        for (Sale__c sale : scope) {
            
            //cancel vendita
            sale.Status__c = 'Annullata';
            sales.add(sale); 
            // cancel quote
            for(SBQQ__Quote__c quote : sale.Quotes__r) {
                quote.SBQQ__Status__c = 'Annullata';
                quotes.add(quote);
            }
            // cancel opportunity
            for(Opportunity opp : sale.Opportunities__r) {           
                opp.StageName = 'Chiusa/Annullata';
                opps.add(opp);
            }
        }
  
        saleSrv.updateRecords(sales);
        quoteSrv.updateRecords(quotes);
        opportunirySrv.updateRecords(opps);
        
    }

    public void finish(Database.BatchableContext bc) {
        
    }

    public String setNumberOfDays() {
        List<CS_DaysToExpiration__c> numberOfDays = [SELECT NumberOfDays__c FROM CS_DaysToExpiration__c WHERE Type__c='Vendita'];
        
        return numberOfDays[0].NumberOfDays__c;
    }
}
