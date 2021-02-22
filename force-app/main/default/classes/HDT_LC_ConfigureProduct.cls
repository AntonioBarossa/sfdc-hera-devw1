/**
 * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
 * @date 30/10/2020
 * @description HDT_LC_ConfigureProduct.cls - Class that holds methods that are called from hdtConfigureProduct.js
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */
public inherited sharing class HDT_LC_ConfigureProduct {
    
    private static HDT_QR_Quote quoteQr = new HDT_QR_Quote();
    private static HDT_SRV_Quote quoteSrv = new HDT_SRV_Quote();
    private static HDT_QR_SaleServiceItem saleServiceItemQr = new HDT_QR_SaleServiceItem();
    private static HDT_SRV_SaleServiceItem saleServiceItemSrv = new HDT_SRV_SaleServiceItem();
    private static HDT_QR_QuoteLine quoteLineQr = new HDT_QR_QuoteLine();
    private static HDT_SRV_QuoteLine quoteLineSrv = new HDT_SRV_QuoteLine();
    private static HDT_QR_Opportunity opportunityQr = new HDT_QR_Opportunity();
    private static HDT_SRV_Opportunity opportunitySrv = new HDT_SRV_Opportunity();
    private static HDT_SRV_Sale saleSrv = new HDT_SRV_Sale();

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @date 18/11/2020
     * @description Get SBQQ__Quote__c and SBQQ__QuoteLine__c records to fill table
     * @param String Sale.Id
     * @return List<Map<String,List<SObject>>>
     */
    @AuraEnabled
    public static List<Map<String,List<SObject>>> getQuotes(String saleId){

        List<Map<String,List<SObject>>> resultsList = new List<Map<String,List<SObject>>>();

        quoteSrv.checkReadAccess('Name,SBQQ__Opportunity2__r.Name,SBQQ__Type__c');
        quoteLineSrv.checkReadAccess('Name,ServicePoint__c,ServicePoint__r.ServicePointCode__c,SBQQ__Product__r.Name,SBQQ__Quote__r.Name,SBQQ__Quote__r.SBQQ__Opportunity2__r.Name');

        List<SBQQ__Quote__c> quoteList = quoteQr.getActiveRecords(saleId);
        List<SBQQ__QuoteLine__c> quoteLineList = quoteLineQr.getRecordsBySale(saleId);

        resultsList = quoteLineSrv.groupRecordsByQuote(quoteList, quoteLineList);

        return resultsList;
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @date 19/11/2020
     * @description Cancel SBQQ__Quote__c record by changing its status (Status=”Annullata”) and related Opportunity (StageName= “Chiusa/Annullata”)
     * @param String quoteId
     * @param String opportunityId
     * @param String cancellationReason
     */
    @AuraEnabled
    public static void cancelQuote(String quoteId, String opportunityId, String cancellationReason){
        
        SBQQ__Quote__c quoteToUpdate = new SBQQ__Quote__c(
            Id = quoteId,
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

        quoteSrv.updateRecord(quoteToUpdate);
        opportunitySrv.updateRecord(oppToUpdate);
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @date 02/02/2021
     * @description Check if all Quotes have QuoteLines configured
     * @param Sale__c sale
     */
    public static void checkQuotesHaveQuoteLines(Sale__c sale){
        //all quotes should have quotelines
        quoteLineSrv.checkReadAccess('Name,SBQQ__Product__r.Name,SBQQ__Quote__r.Name,SBQQ__Quote__r.SBQQ__Opportunity2__r.Name,ServicePoint__c');
        List<SBQQ__QuoteLine__c> quoteLinesActive = quoteLineQr.getActiveRecords(sale.Id);

        quoteSrv.checkReadAccess('Name,SBQQ__Opportunity2__r.Name,SBQQ__Type__c,SBQQ__Status__c,SBQQ__Ordered__c,SBQQ__LineItemsGrouped__c,SBQQ__OrderByQuoteLineGroup__c');
        List<SBQQ__Quote__c> quotesActive = quoteQr.getActiveRecords(sale.Id);

        Set<String> quotesWithQuoteLines = new Set<String>();
        for (SBQQ__QuoteLine__c quoteLineActive : quoteLinesActive) {
            quotesWithQuoteLines.add(quoteLineActive.SBQQ__Quote__c);
        }

        List<String> quotesWithoutQuoteLines = new List<String>();

        for (SBQQ__Quote__c quoteActive : quotesActive) {
            if (!quotesWithQuoteLines.contains(quoteActive.Id)) {
                quotesWithoutQuoteLines.add(quoteActive.Name);
            }
        }

        if (!quotesWithoutQuoteLines.isEmpty()) {
            throw new AuraHandledException('Attenzione Non hai configurato i prodotti per le seguenti quote ' + String.join(quotesWithoutQuoteLines, ','));
        }
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @date 02/02/2021
     * @description Check if all QuoteLines have Service Points associated
     * @param Sale__c sale
     */
    public static void checkServicePointAssocs(Sale__c sale){
        quoteLineSrv.checkReadAccess('Name,SBQQ__Product__r.Name,SBQQ__Quote__r.Name,SBQQ__Quote__r.SBQQ__Opportunity2__r.Name,ServicePoint__c,ServicePoint__r.ServicePointCode__c');
        List<SBQQ__QuoteLine__c> quoteLinePods = quoteLineQr.getActiveRecordsBySaleIdAndProductPod(sale.Id);

        List<String> quoteLinePodsWithoutServicePoints = new List<String>();

        for (SBQQ__QuoteLine__c quoteLinePod : quoteLinePods) {
            if (quoteLinePod.ServicePoint__c == null) {
                quoteLinePodsWithoutServicePoints.add(quoteLinePod.Name);
            }
        }

        //part 1 - check if all ql have sp assoc
        if (!quoteLinePodsWithoutServicePoints.isEmpty()) {
            throw new AuraHandledException('Attenzione ai QLI - ' + String.join(quoteLinePodsWithoutServicePoints, ',') + ' non risulta associato nessun service point');
        }

        //part2 - check if quotes have enough sp assoc
        saleServiceItemSrv.checkReadAccess('Opportunity__c,Opportunity__r.Sale__c,Opportunity__r.Name,Opportunity__r.CreatedDate,Quote__c,Quote__r.Name,ServicePoint__c,ServicePoint__r.ServicePointCode__c,ServicePoint__r.RecordType.Name,ServicePoint__r.RecordType.DeveloperName,ServicePoint__r.SupplyCity__c');
        List<SaleServiceItem__c> saleServiceItems = saleServiceItemQr.getActiveRecordsBySaleId(sale.Id);

        if (quoteLinePods.size() != saleServiceItems.size()) {
            throw new AuraHandledException('Configurare i prodotti per tutti i Service Point!');
        }

        //part3 - check duplicated service point assoc
        checkDuplicatedServicePointAssocs(quoteLinePods);
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @date 02/02/2021
     * @description Check if Service Points are not associated twice
     * @param List<SBQQ__QuoteLine__c> quoteLinePods
     */
    public static void checkDuplicatedServicePointAssocs(List<SBQQ__QuoteLine__c> quoteLinePods){

        Set<String> encounteredServicePoints = new Set<String>();
        Set<String> duplicateServicePoints = new Set<String>();

        for (SBQQ__QuoteLine__c quoteLinePod : quoteLinePods) {
            if(encounteredServicePoints.contains(quoteLinePod.ServicePoint__r.ServicePointCode__c)){
                duplicateServicePoints.add(quoteLinePod.ServicePoint__r.ServicePointCode__c);
            }else{
                encounteredServicePoints.add(quoteLinePod.ServicePoint__r.ServicePointCode__c);
            }
        }

        List<String> duplicateServicePointsList = new List<String>(duplicateServicePoints);

        if (!duplicateServicePointsList.isEmpty()) {
            throw new AuraHandledException('Attenzione i Punti di fornitura '+String.join(duplicateServicePointsList, ',')+' sonno stati abbinati a più offerte');
        }

    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @date 02/02/2021
     * @description Perform all check validations on next event
     * @param Sale__c sale
     */
    public static void performChecks(Sale__c sale){
        checkQuotesHaveQuoteLines(sale);
        checkServicePointAssocs(sale);
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Update Sale
     * @param Sale__c sale
     */
    @AuraEnabled
    public static void updateSale(Sale__c sale){
        performChecks(sale);
        saleSrv.updateRecord(sale);
    }
}
