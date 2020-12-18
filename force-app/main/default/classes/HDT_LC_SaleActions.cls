/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 14/12/2020
* @description Apex controller for hdtSaleActions.js component
* @history Keltin Mesonjesi – 14/12/2020 – Created class
*/
public inherited sharing class HDT_LC_SaleActions {
    
    private static HDT_SRV_Sale saleSrv = new HDT_SRV_Sale();
    private static HDT_SRV_QuoteLine quoteLineSrv = new HDT_SRV_QuoteLine();
    private static HDT_QR_QuoteLine quoteLineQr = new HDT_QR_QuoteLine();
    private static HDT_SRV_Opportunity opportunitySrv = new HDT_SRV_Opportunity();
    private static HDT_QR_Opportunity opportunityQr = new HDT_QR_Opportunity();
    private static HDT_SRV_Quote quoteSrv = new HDT_SRV_Quote();
    private static HDT_QR_Quote quoteQr = new HDT_QR_Quote();
    private static HDT_SRV_QuoteLineGroup quoteLineGroupSrv = new HDT_SRV_QuoteLineGroup();
    private static HDT_SRV_QuoteProcess quoteProcessSrv = new HDT_SRV_QuoteProcess();
    private static HDT_QR_QuoteProcess quoteProcessQr = new HDT_QR_QuoteProcess();

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Save sale as draft
     * @param Sale__c sale
     */
    @AuraEnabled
    public static void saveDraft(Sale__c sale){
        saleSrv.updateRecord(sale);
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Save sale
     * @param Sale__c sale
     */
    @AuraEnabled
    public static void save(Sale__c sale){
        
        //1 - Check if QuoteLines have BillingProfiles associated
        quoteLineSrv.checkReadAccess('Name,Billing_Profile__c,SBQQ__Quote__c');
        List<SBQQ__QuoteLine__c> quoteLinesList = quoteLineQr.getRecordsBySaleFilteredPaymentMethodNotNull(sale.Id);

        List<String> quoteLinesWithoutBilling = new List<String>();

        for (SBQQ__QuoteLine__c quoteLine : quoteLinesList) {
            if (quoteLine.Billing_Profile__c == null) {
                quoteLinesWithoutBilling.add(quoteLine.Name);
            }
        }
        
        if (!quoteLinesWithoutBilling.isEmpty()) {
            throw new AuraHandledException('Attenzione! Ai bundle “' + String.join(quoteLinesWithoutBilling, ',') +'” non è stato associato un Metodo di Pagamento');
        }

        //2 - Update Opportunity stage
        opportunitySrv.checkReadAccess('StageName');
        List<Opportunity> opps = opportunityQr.getRecordsBySaleFilterStageName(sale.Id, 'StageName', 'Proposal');
        
        for (Opportunity opp : opps) {
            opp.StageName = 'Closed Won';
        }

        //3 - Update SBQQ__Quote
        quoteSrv.checkReadAccess('SBQQ__Status__c,SBQQ__Ordered__c,SBQQ__LineItemsGrouped__c,SBQQ__OrderByQuoteLineGroup__c');
        List<SBQQ__Quote__c> quoteList = quoteQr.getRecordsBySaleFilterStatus(sale.Id, 'Rejected'); //quotes that have a status of not rejected

        for (SBQQ__Quote__c quote : quoteList) {
            quote.SBQQ__Status__c = 'Accepted';
            quote.SBQQ__Ordered__c = true;
            quote.SBQQ__LineItemsGrouped__c = true;
            quote.SBQQ__OrderByQuoteLineGroup__c = true;
        }

        //4 - Update Sale
        Sale__c saleToUpdate = new Sale__c(Id = sale.Id, Status__c = 'Chiusa');

        //5 - SBQQ__QuoteLineGroup__c
        //Creazione di un QuoteLineGroup per ogni QuoteLine principale.
        //Associazione su ogni QuoteLineGroup del record configurato su SBQQ__QuoteProcess__c
        Map<String,SBQQ__QuoteLineGroup__c> mapLineGroup = new Map<String,SBQQ__QuoteLineGroup__c>();

        quoteProcessSrv.checkReadAccess('SBQQ__Default__c,SBQQ__GuidedOnly__c,SBQQ__ProductAutoSelected__c,SBQQ__ProductConfigurationInitializer__c,SBQQ__ProductSearchExecutor__c,SBQQ__SortOrder__c,Name');
        List<SBQQ__QuoteProcess__c> quoteProcessList = quoteProcessQr.getProcessForGroupAssoc();

        for (SBQQ__QuoteLine__c quoteLine : quoteLinesList) {
            SBQQ__QuoteLineGroup__c quoteLineGroup = new SBQQ__QuoteLineGroup__c(
                SBQQ__Account__c = sale.Account__c,
                Name = quoteLine.Name + ' Group',
                SBQQ__Quote__c = quoteLine.SBQQ__Quote__c,
                SBQQ__QuoteProcess__c = quoteProcessList[0].Id
            );

            mapLineGroup.put(quoteLine.Id, quoteLineGroup);

        }

        //6 - SBQQ__QuoteLine__c
        //SBQQ__Group: Valorizzazione con l’id Gruppo di riferimento
        quoteLineGroupSrv.createRecords(mapLineGroup.values()); //create QuoteLineGroups to update group id in quoteLine
        for(SBQQ__QuoteLine__c quoteLine : quoteLinesList){
            system.debug(mapLineGroup.get(quoteLine.Id).Id);
            quoteLine.SBQQ__Group__c = mapLineGroup.get(quoteLine.Id).Id;
        }

        //7 - Execute actions
        opportunitySrv.updateRecords(opps);
        quoteSrv.updateRecords(quoteList);
        saleSrv.updateRecord(saleToUpdate);
        quoteLineSrv.updateRecords(quoteLinesList);
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Cancel sale
     * @param Sale__c sale
     */
    @AuraEnabled
    public static void cancel(Sale__c sale){
        
        //1 - Update sale
        Sale__c saleToUpdate = new Sale__c(Id = sale.Id, Status__c = 'Annullata');

        //2- Update Opportunity
        opportunitySrv.checkReadAccess('StageName');
        List<Opportunity> opps = opportunityQr.getRecordsBySaleFilterStageName(sale.Id, 'StageName', 'Proposal');
        for (Opportunity opp : opps) {
            opp.StageName = 'Closed Lost';
        }

        //3 - Update Quotes
        quoteSrv.checkReadAccess('SBQQ__Status__c');
        List<SBQQ__Quote__c> quoteList = quoteQr.getRecordsBySaleFilterStatus(sale.Id, 'Rejected'); //quotes that have a status of not rejected

        for (SBQQ__Quote__c quote : quoteList) {
            quote.SBQQ__Status__c = 'Rejected';
        }

        //4 - Excecute actions
        saleSrv.updateRecord(saleToUpdate);
        opportunitySrv.updateRecords(opps);
        quoteSrv.updateRecords(quoteList);

    }
}
