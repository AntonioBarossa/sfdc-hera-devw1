public with sharing class HDT_BA_AlignSapOfferCodeTable implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts{
    
    public void execute(SchedulableContext sc) { 
        Id batchId = Database.executeBatch(new HDT_BA_AlignSapOfferCodeTable(), Integer.valueOf(Label.HDT_AlignOfferCodeSapTableMaxItem));
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, OfferCode32__c, OfferProductCode__c, OfferProductVersion__c, CodT0__c, Driver1__c, Driver2__c, Driver3__c, MarketType__c, Service__c, Company__c,EffectiveDate__c, Exported__c FROM OfferCode32Admin__c WHERE Exported__c = false';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<OfferCode32Admin__c> scope) {
        List<HDT_WRP_AlignSapOfferCodeTable.HDT_WRP_AlignSapOfferCodeTableData> listOfData = new List<HDT_WRP_AlignSapOfferCodeTable.HDT_WRP_AlignSapOfferCodeTableData>();
        for(OfferCode32Admin__c offerCodeAdmin : scope){
            HDT_WRP_AlignSapOfferCodeTable.HDT_WRP_AlignSapOfferCodeTableData item = new HDT_WRP_AlignSapOfferCodeTable.HDT_WRP_AlignSapOfferCodeTableData();
            item.Id = offerCodeAdmin.Id;
            item.offerCode32 = offerCodeAdmin.OfferCode32__c;
            item.offerProductCode = offerCodeAdmin.OfferProductCode__c;
            item.offerProductVersion = offerCodeAdmin.OfferProductVersion__c;
            item.codT0 = offerCodeAdmin.CodT0__c;
            item.effectiveMonths = String.valueOf(offerCodeAdmin.EffectiveDate__c);
            item.driver1 = offerCodeAdmin.Driver1__c;
            item.driver2 = offerCodeAdmin.Driver2__c;
            item.driver3 = offerCodeAdmin.Driver3__c;
            item.commodity = offerCodeAdmin.Service__c;
            item.company = offerCodeAdmin.Company__c;
            item.market = offerCodeAdmin.MarketType__c;
            listOfData.add(item);
        }
        HDT_WRP_AlignSapOfferCodeTable.HDT_WRP_AlignSapOfferCodeTableRequest request = new HDT_WRP_AlignSapOfferCodeTable.HDT_WRP_AlignSapOfferCodeTableRequest();
        request.data = listOfData;
        HDT_WRP_AlignSapOfferCodeTable.HDT_WRP_AlignSapOfferCodeTableResponse response = HDT_WS_AlignSapOfferCodeTable.doCallout(request);
        List<OfferCode32Admin__c> listOfOfferCodeAdminToUpdate = new List<OfferCode32Admin__c>();
        if(response.data != null && !response.data.isEmpty()){
            for(HDT_WRP_AlignSapOfferCodeTable.HDT_WRP_AlignSapOfferCodeTableData item : response.data){
                OfferCode32Admin__c offerCodeAdminToUpdate = new OfferCode32Admin__c();
                if(item.outcome != null && item.outcome.equals('OK')){
                    offerCodeAdminToUpdate.Id = item.Id;
                    offerCodeAdminToUpdate.Exported__c = true;
                    listOfOfferCodeAdminToUpdate.add(offerCodeAdminToUpdate);
                }
            }
            if(!listOfOfferCodeAdminToUpdate.isEmpty()){
                HDT_UTL_DatabaseService.updateSObject(listOfOfferCodeAdminToUpdate);
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('Finish batch HDT_BA_AlignSapOfferCodeTable');
    }

}