/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 27/11/2020
* @description Apex controller for hdtSaleServiceItemsTiles.js component
* @history Keltin Mesonjesi – 27/11/2020 – Created class
*/
public inherited sharing class HDT_LC_SaleServiceItemsTiles {
    
    private static HDT_QR_Opportunity opportunityQuery = new HDT_QR_Opportunity();
    private static HDT_QR_SaleServiceItem saleServiceItemQuery = new HDT_QR_SaleServiceItem();
    private static HDT_SRV_SaleServiceItem saleServiceItemSrv = new HDT_SRV_SaleServiceItem();
    private static HDT_SRV_SaleServiceItem itemsService = new HDT_SRV_SaleServiceItem();
    private static HDT_SRV_Opportunity opportunityService = new HDT_SRV_Opportunity();
    private static HDT_QR_Quote quoteQr = new HDT_QR_Quote();
    private static HDT_SRV_Quote quoteSrv = new HDT_SRV_Quote();

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Get list of tiles
     * @param String saleId
     * @return List<SaleServiceItems__c>
     */
    @AuraEnabled
    public static Map<String,List<List<SObject>>> getTiles(String saleId){

        opportunityService.checkReadAccess('Name, CreatedDate');
        saleServiceItemSRV.checkReadAccess('Opportunity__c,Opportunity__r.Sale__c,Opportunity__r.Name,Opportunity__r.CreatedDate,Quote__c,Quote__r.Name,ServicePoint__c,ServicePoint__r.ServicePointCode__c,ServicePoint__r.RecordType.Name,ServicePoint__r.RecordType.DeveloperName,ServicePoint__r.SupplyCity__c');

        List<Opportunity> opps = opportunityQuery.getRecordsBySaleFilterStageNameNotVas(saleId, 'Id,Name,CreatedDate', 'Closed Lost');
        List<SaleServiceItem__c> items = saleServiceItemQuery.getRecordsBySaleId(saleId);
        List<List<SaleServiceItem__c>> saleServiceItemsTiles = itemsService.groupRecordsByOpportunity(opps, items);

        opportunityService.checkReadAccess('Name,SBQQ__PrimaryQuote__r.OrderReference__c,SBQQ__PrimaryQuote__r.OrderReference__r.Name,SBQQ__PrimaryQuote__r.OrderReference__r.OrderNumber,SBQQ__PrimaryQuote__r.ContractReference__c,SBQQ__PrimaryQuote__r.ContractReference__r.ContractNumber,SBQQ__PrimaryQuote__r.SupplyCity__c,CreatedDate');
        List<Opportunity> oppsVasList = opportunityQuery.getRecordsBySaleFilteredVas(saleId);
        List<List<Opportunity>> vasTiles = new List<List<Opportunity>>();
        vasTiles.add(oppsVasList);

        Map<String,List<List<SObject>>> results = new Map<String,List<List<SObject>>>();
        results.put('saleServiceItemsTiles', saleServiceItemsTiles);
        results.put('vasTiles', vasTiles);

        return results;

    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Delete single tile
     * @param String opportunityId
     */
    /**@frpanico 03/02/2022
     * Aggiunto update IsTransition__c = false sul Sale__c
     * Ottimizzate DML statements
     */
    @AuraEnabled
    public static void deleteTile(String opportunityId, String cancellationReason){

        List<SObject> sobjsToUpdate = new List<SObject>();
        Sale__c sale = new Sale__c();

        Opportunity opp = opportunityQuery.getRecordById(opportunityId);
        sale.Id = opp.Sale__c;
        sale.IsTransition__c = false;
        /* IsTransition a false sulla vendita va messo solo ed esclusivamente se non vi sono altre quote con IsTransition a true*/
        List<SBQQ__Quote__c> otherQuotes = [SELECT Id, IsTransition__c FROM SBQQ__Quote__c WHERE Id != :opp.SBQQ__PrimaryQuote__c AND SBQQ__Status__c NOT IN ('Cancelled','Rejected') AND Sale__c = :opp.Sale__c AND IsTransition__c = true WITH SECURITY_ENFORCED];
        if(!otherQuotes.isEmpty())
        {
            sale.IsTransition__c = true;
        }
        SBQQ__Quote__c quoteToUpdate = new SBQQ__Quote__c(
            Id = opp.SBQQ__PrimaryQuote__c,
            CancellationReason__c = cancellationReason
        );

        switch on cancellationReason {
            when  'Errata operativita'{
                quoteToUpdate.SBQQ__Status__c = 'Cancelled';
            }
            when 'Volonta cliente'{
                quoteToUpdate.SBQQ__Status__c = 'Rejected';
            }
        }

        Opportunity oppToUpdate = new Opportunity(
            Id = opportunityId,
            StageName = 'Closed Lost'
        );
        
        sobjsToUpdate.add(quoteToUpdate);
        sobjsToUpdate.add(oppToUpdate);
        sobjsToUpdate.add(sale);

        HDT_UTL_DatabaseService.updateSObject(sobjsToUpdate);

        /*
        quoteSrv.updateRecord(quoteToUpdate);
        opportunityService.updateRecord(oppToUpdate);
        */
    }

}
