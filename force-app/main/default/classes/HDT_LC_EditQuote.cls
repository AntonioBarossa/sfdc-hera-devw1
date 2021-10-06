/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 16/11/2020
* @description HDT_LC_EditQuote – Back-end controller for hdtEditQuote.js lwc component
* @history Keltin Mesonjesi – 16/11/2020 – Created class
*/


public inherited sharing class HDT_LC_EditQuote {

    private static HDT_QR_QuoteLine quoteLineQr = new HDT_QR_QuoteLine();
    private static HDT_SRV_QuoteLine quoteLineSrv = new HDT_SRV_QuoteLine();
    private static HDT_QR_SaleServiceItem saleServiceItemQr = new HDT_QR_SaleServiceItem();
    private static HDT_SRV_SaleServiceItem saleServiceItemSrv = new HDT_SRV_SaleServiceItem();
    private static HDT_QR_Order orderQr = new HDT_QR_Order();
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();
    private static HDT_SRV_Contract contractSrv = new HDT_SRV_Contract();
    private static HDT_QR_Contract contractQr = new HDT_QR_Contract();
    private static HDT_QR_Quote quoteQr = new HDT_QR_Quote();
    private static HDT_SRV_Quote quoteSrv = new HDT_SRV_Quote();
    private static HDT_QR_Opportunity oppQr = new HDT_QR_Opportunity();
    private static HDT_SRV_Opportunity oppSrv = new HDT_SRV_Opportunity();

    private static void assocBillingProfileContract(String contractId, String quoteId){
        contractSrv.checkReadAccess('Name,AccountId,ContractNumber,BillingProfile__c,Status');
        List<Contract> contract = contractQr.getRecordById(contractId);
        List<SBQQ__QuoteLine__c> quoteLine = quoteLineQr.getRecordsForContractOrderRefVas(quoteId);

        system.debug('HDT_LC_EditQuote - contract: ' + contract);
        system.debug('HDT_LC_EditQuote - quoteLine: ' + quoteLine);

        if (!contract.isEmpty() && !quoteLine.isEmpty()) {
            quoteLineSrv.updateRecord(new SBQQ__QuoteLine__c(
                Id = quoteLine[0].Id,
                BillingProfile__c = contract[0].BillingProfile__c
            ));
        } else {
            system.debug('HDT_LC_EditQuote - assocBillingProfileContract - nessun contract o quoteLine trovato');
        }

    }

    private static void assocBillingProfileOrder(String orderId, String quoteId){
        contractSrv.checkReadAccess('Name,AccountId,ContractNumber,BillingProfile__c,Status');
        Order order = orderQr.getRecordById(orderId);
        List<SBQQ__QuoteLine__c> quoteLine = quoteLineQr.getRecordsForContractOrderRefVas(quoteId);

        system.debug('HDT_LC_EditQuote - order: ' + order);
        system.debug('HDT_LC_EditQuote - quoteLine: ' + quoteLine);

        if (order != null && !quoteLine.isEmpty()) {
            quoteLineSrv.updateRecord(new SBQQ__QuoteLine__c(
                Id = quoteLine[0].Id,
                BillingProfile__c = order.BillingProfile__c
            ));
        } else {
            system.debug('HDT_LC_EditQuote - assocBillingProfileContract - nessun contract o quoteLine trovato');
        }

    }
    
    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description Manually Associate ServicePoint to QuoteLines of type "POD"
    * @param String quoteId - SBQQ__Quote__c
    */
    private static void manualAssocPodToQuoteLine(String quoteId) {

        List<SBQQ__QuoteLine__c> linkedQuoteLines = quoteLineQr.getLinkedQuoteLines(quoteId);

        system.debug('manualAssocPodToQuoteLine - linkedQuoteLines: ' + linkedQuoteLines);

        if(!linkedQuoteLines.isEmpty()) {
            List<SBQQ__QuoteLine__c> quoteLinesToUpdate = new List<SBQQ__QuoteLine__c>();

            for (SBQQ__QuoteLine__c ql : linkedQuoteLines) {
                quoteLinesToUpdate.add(new SBQQ__QuoteLine__c(
                    Id = ql.Id,
                    ServicePoint__c = ql.ServicePointLinkItem__r.ServicePoint__c
                ));
            }

            system.debug('manualAssocPodToQuoteLine - quoteLinesToUpdate: ' + quoteLinesToUpdate);

            quoteLineSrv.updateRecords(quoteLinesToUpdate);
        }

    }
    
    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description Automatically Associate ServicePoint to QuoteLines of type "POD"
    * @param String saleId – Sale__c.Id
    * @param String quoteId - SBQQ__Quote__c
    */
    private static void autoAssocPodToQuoteLine(String saleId, String quoteId){
       
        //get all quoteLine pods
        quoteLineSrv.checkReadAccess('Name,SBQQ__Product__r.Name,SBQQ__Quote__r.Name,SBQQ__Quote__r.SBQQ__Opportunity2__r.Name,ServicePoint__c');
        List<SBQQ__QuoteLine__c> quoteLinePods = quoteLineQr.getRecordsByQuoteIdAndProductPod(quoteId);

        //get all saleServiceItems for this quote
        saleServiceItemSrv.checkReadAccess('Quote__c,ServicePoint__c,ServicePoint__r.RecordType.Name,ServicePoint__r.RecordType.DeveloperName');
        List<SaleServiceItem__c> saleServiceItems = saleServiceItemQr.getRecordsByQuote(quoteId);

        //check ql number equal to number of service points
        if (quoteLinePods.size() == saleServiceItems.size()) {
            
            List<SBQQ__QuoteLine__c> quoteLinesWithoutServicePoint = new List<SBQQ__QuoteLine__c>();
            List<String> notAvailableServicePoints = new List<String>();
            List<String> availableServicePoints = new List<String>();

            //split ql without service point from those with service points
            for (SBQQ__QuoteLine__c quoteLinePod : quoteLinePods) {
                if (quoteLinePod.ServicePoint__c == null) {
                    quoteLinesWithoutServicePoint.add(quoteLinePod);
                } else {
                    notAvailableServicePoints.add(quoteLinePod.ServicePoint__c);
                }
            }

            //continue with assignment if there ql without service points
            if (!quoteLinesWithoutServicePoint.isEmpty()) {
                //get service points that haven't been assigned yet
                for (SaleServiceItem__c saleServiceItem : saleServiceItems) {
                    if (!notAvailableServicePoints.contains(saleServiceItem.ServicePoint__c)) {
                        availableServicePoints.add(saleServiceItem.ServicePoint__c);
                    }
                }

                //new list with ql to update
                List<SBQQ__QuoteLine__c> quoteLinesToUpdate = new List<SBQQ__QuoteLine__c>();

                for (Integer i = 0; i < availableServicePoints.size(); i++) {
                    quoteLinesToUpdate.add(new SBQQ__QuoteLine__c(
                        Id = quoteLinesWithoutServicePoint[i].Id,
                        ServicePoint__c = availableServicePoints[i]
                    ));
                }

                quoteLineSrv.updateRecords(quoteLinesToUpdate);

                bonusScontiNotAmend(quoteId);


            } else {
                system.debug('HDT_LC_EditQuote - assocPodToQuoteLine - All Service Points have been assigned!');
            }

        } else {
            system.debug('HDT_LC_EditQuote - assocPodToQuoteLine - Configurare i prodotti per tutti i Service Point!');
        }

    }

    private static void bonusScontiNotAmend(Id quoteId){
        List<SBQQ__QuoteLine__c> primaryQlSconto=HDT_LC_ApplyBillingProfileModal.getBonusPerOffer(quoteLineQr.getRecordsByQuoteFilteredFamilyBonus(quoteId));
        

        
        if(primaryQlSconto.isEmpty())     return;
        List<SBQQ__QuoteLine__c> quoteLinePods = quoteLineQr.getRecordsByQuoteIdAndProductPod(quoteId);
        Map<id, SBQQ__QuoteLine__c> offertaToPod = new Map<id, SBQQ__QuoteLine__c>();

        for(SBQQ__QuoteLine__c ql : quoteLinePods){
            if(ql.servicePoint__c!=null && ql.SBQQ__RequiredBy__c!=null){
                offertaToPod.put(ql.SBQQ__RequiredBy__c, ql);
            }
        }
        list<SBQQ__QuoteLine__c> listToUpdate = new list<SBQQ__QuoteLine__c>();

        for(SBQQ__QuoteLine__c ql : primaryQlSconto ){
            if(ql.servicePoint__c==null){
                SBQQ__QuoteLine__c qlUp = new SBQQ__QuoteLine__c(Id=ql.Id, ServicePoint__c=offertaToPod.get(ql.SBQQ__RequiredBy__c).ServicePoint__c);
                listToUpdate.add(qlUp);
            }
            
        }

        quoteLineSrv.updateRecords(listToUpdate);


    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description Check if products have been created for quote
    * @param String quoteId
    */
    private static Boolean haveProductsBeenCreated(String quoteId){
        List<SBQQ__QuoteLine__c> createdQuoteLines = quoteLineQr.getRecordsByQuoteId(quoteId);

        return !createdQuoteLines.isEmpty();
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description Execute actions when products are created for amend Quote
    * @param String quoteId
    */
    private static void execAmendAllowQuoteProdConfigured(String quoteId){

        if (haveProductsBeenCreated(quoteId)) {
            SBQQ__Quote__c quote = new SBQQ__Quote__c(
                Id = quoteId,
                AmendmentAllowed__c = false
            );

            quoteSrv.updateRecord(quote);
        }
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description Execute actions on Opportunity & Quote
    * @param String quoteId
    */
    private static void execOpportunityAndQuoteActions(String quoteId){

        if (haveProductsBeenCreated(quoteId)) {
            List<Opportunity> oppToUpdate = oppQr.getRecordByQuote(quoteId);
            oppSrv.updateRecord(new Opportunity(
                Id = oppToUpdate[0].Id,
                StageName = 'Negotiation'
            ));
            quoteSrv.updateRecord(new SBQQ__Quote__c(
                Id = quoteId,
                SBQQ__Status__c = 'In Review'
            ));
        }
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description Execute actions when exiting modal
    * @param String saleId
    * @params String quoteId
    * @return Boolean - true(if products have been created), false (if no products)
    */
    @AuraEnabled
    public static Boolean execModalExitActions(String saleId, String quoteId){

        SBQQ__Quote__c quote = quoteQr.getRecordById(quoteId);

        system.debug('******************* quote' + quote);

        if (quote.ContractReference__c != null) {
            assocBillingProfileContract(quote.ContractReference__c, quoteId);
        }

        system.debug('******************* quote.OrderReference__c' + quote.OrderReference__c);

        if (quote.OrderReference__c != null) {
            assocBillingProfileOrder(quote.OrderReference__c, quoteId);
        }

        if (!quote.IsVAS__c) {
            manualAssocPodToQuoteLine(quoteId);
            autoAssocPodToQuoteLine(saleId,quoteId);
        }

        if (quote.AmendmentAllowed__c) {
            execAmendAllowQuoteProdConfigured(quoteId);
        }

        execOpportunityAndQuoteActions(quoteId);

        return haveProductsBeenCreated(quoteId);

    }

}