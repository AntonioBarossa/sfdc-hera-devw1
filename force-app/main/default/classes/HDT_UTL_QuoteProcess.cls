public inherited sharing class HDT_UTL_QuoteProcess {

    private static HDT_QR_Quote quoteQr = new HDT_QR_Quote();
    private static HDT_SRV_Quote quoteSrv = new HDT_SRV_Quote();
    private static HDT_QR_SaleServiceItem saleServiceItemQr = new HDT_QR_SaleServiceItem();
    private static HDT_SRV_SaleServiceItem itemsSrv = new HDT_SRV_SaleServiceItem();
    private static HDT_SRV_Opportunity oppSrv = new HDT_SRV_Opportunity();

    private static list<SBQQ__Quote__c> filterAmendedQuote(list<SBQQ__Quote__c> quoteList){
        list<SBQQ__Quote__c> filteredList = new list<SBQQ__Quote__c>();

        for (SBQQ__Quote__c quote : quoteList) {
            if (quote.SBQQ__Type__c == 'Amendment') {
                filteredList.add(quote);
            }
        }

        return filteredList;
    }

    private static list<SBQQ__Quote__c> getQuoteToAssign(list<SBQQ__Quote__c> quotes){
        
        Set<String> idList = new Set<String>();

        for (SBQQ__Quote__c quote : quotes) {
            idList.add(quote.SBQQ__Account__c);
        }

        List<String> accountIds = new List<String>();
        accountIds.addAll(idList);

        System.debug('accountIds: ' +  accountIds);

        return quoteQr.getRecordByTypeAndAmendementAllowed('In Review', true, 'Quote', accountIds);
    }

    private static List<HDT_WRP_QuoteAmend> mapQuoteAmend(list<SBQQ__Quote__c> quoteAmend, list<SBQQ__Quote__c> quoteNotAmend){

        Map<String,SBQQ__Quote__c> contractQuote = new Map<String,SBQQ__Quote__c>();

        List<HDT_WRP_QuoteAmend> quoteAmendWrpList = new List<HDT_WRP_QuoteAmend>();

        // for (SBQQ__Quote__c quote : quoteAmend) {
        //     quoteAmendContract.put(quote.Id, quote.ContractReference__c);
        // }

        system.debug('quoteNotAmend: ' + quoteNotAmend);

        for (SBQQ__Quote__c quote : quoteNotAmend) {
            if (quote.ContractReference__c != null && contractQuote.get(quote.ContractReference__c) == null) {
                contractQuote.put(quote.ContractReference__c, quote);
            }
        }

        system.debug('contractQuote: ' + contractQuote);
        for (SBQQ__Quote__c quote : quoteAmend) {
            System.debug('SBQQ__MasterContract__c: ' + quote.SBQQ__MasterContract__c);
        }

        for (SBQQ__Quote__c quote : quoteAmend) {
            if (quote.SBQQ__MasterContract__c != null && contractQuote.get(quote.SBQQ__MasterContract__c) != null) {
                HDT_WRP_QuoteAmend q = new HDT_WRP_QuoteAmend();
                q.newQuote = quote;
                q.oldQuote = contractQuote.get(quote.SBQQ__MasterContract__c);

                quoteAmendWrpList.add(q);
            }
        }

        system.debug('quoteAmendWrpList: ' + quoteAmendWrpList);

        return quoteAmendWrpList;

    }

    private static void assignValueToNewQuote(SBQQ__Quote__c newQuote, SBQQ__Quote__c oldQuote){
        
        newQuote.Sale__c = oldQuote.Sale__c;
        newQuote.Campaign__c = oldQuote.Campaign__c;
        newQuote.Channel__c = oldQuote.Channel__c;
        newQuote.AmendmentAllowed__c = oldQuote.AmendmentAllowed__c;
        newQuote.Agency__c = oldQuote.Agency__c;
        newQuote.FriendCode__c = oldQuote.FriendCode__c;
        newQuote.SaleBy__c = oldQuote.SaleBy__c;
        newQuote.SalesCompany__c = oldQuote.SalesCompany__c;
        newQuote.Market__c = oldQuote.Market__c;
        newQuote.SupplyCity__c = oldQuote.SupplyCity__c;
        newQuote.ContractReference__c = oldQuote.ContractReference__c;
    }

    private static list<SBQQ__Quote__c> getSaleAmendOldQuotes(list<SBQQ__Quote__c> newQuoteList){
        Set<String> saleIdsSet = new Set<String>();
        List<String> saleIdsList = new List<String>();
        Set<String> contractsSet = new Set<String>();
        List<String> contractsList = new List<String>();
        Set<String> quotesToExcludeSet = new Set<String>();
        List<String> quotesToExcludeList = new List<String>();

        for (SBQQ__Quote__c quote : newQuoteList) {
            if (quote.ContractReference__c != null) {
                saleIdsSet.add(quote.Sale__c);
                contractsSet.add(quote.ContractReference__c);
                quotesToExcludeSet.add(quote.Id);
            }
        }

        saleIdsList.addAll(saleIdsSet);
        contractsList.addAll(contractsSet);
        quotesToExcludeList.addAll(quotesToExcludeSet);

        return quoteQr.getRecordByTypeAndAmendementAllowedAndSaleId(true, 'Quote', saleIdsList, contractsList, quotesToExcludeList);
    }

    private static List<String> getSaleAmendOldOpp(List<SBQQ__Quote__c> oldSaleAmendQuotes){
        Set<String> oppIdsSet = new Set<String>();
        List<String> oppIdsList = new List<String>();

        for (SBQQ__Quote__c quote : oldSaleAmendQuotes) {
            oppIdsSet.add(quote.SBQQ__Opportunity2__c);
        }

        oppIdsList.addAll(oppIdsSet);
        return oppIdsList;
    }

    private static List<String> getSaleAmendOldQuote(List<SBQQ__Quote__c> oldSaleAmendQuotes){
        Set<String> oppIdsSet = new Set<String>();
        List<String> oppIdsList = new List<String>();

        for (SBQQ__Quote__c quote : oldSaleAmendQuotes) {
            oppIdsSet.add(quote.Id);
        }

        oppIdsList.addAll(oppIdsSet);
        return oppIdsList;
    }

    private static Map<String, SBQQ__Quote__c> mapOldAndNewQuotes(List<SBQQ__Quote__c> oldSaleAmendQuotes, List<SBQQ__Quote__c> newSaleAmendQuotes){
        Map<String, SBQQ__Quote__c> mapOldToNew = new Map<String, SBQQ__Quote__c>();

        for (SBQQ__Quote__c oldQuote : oldSaleAmendQuotes) {
            for (SBQQ__Quote__c newQuote : newSaleAmendQuotes) {
                if (oldQuote.ContractReference__c == newQuote.ContractReference__c) {
                    mapOldToNew.put(oldQuote.Id, newQuote);
                }
            }
        }

        return mapOldToNew;
    }

    private static void updateItems(Map<String, SBQQ__Quote__c> mapOldToNew, List<SaleServiceItem__c> items){

        List<SaleServiceItem__c> itemsToUpdate = new List<SaleServiceItem__c>();

        for (SaleServiceItem__c item : items) {
            if (mapOldToNew.containsKey(item.Quote__c)) {

                SBQQ__Quote__c newQuote = mapOldToNew.get(item.Quote__c);

                itemsToUpdate.add(new SaleServiceItem__c(
                    Id = item.Id,
                    Quote__c = newQuote.Id,
                    Opportunity__c = newQuote.SBQQ__Opportunity2__c
                ));
            }
        }

        itemsSrv.updateRecords(itemsToUpdate);

    }

    private static void setSaleIdToOpportunity(List<SBQQ__Quote__c> newSaleAmendQuotes){
        List<Opportunity> oppToUpdate = new List<Opportunity>();

        for (SBQQ__Quote__c quote : newSaleAmendQuotes) {
            oppToUpdate.add(new Opportunity(
                Id = quote.SBQQ__Opportunity2__c,
                Sale__c = quote.Sale__c
            ));
        }

        oppSrv.updateRecords(oppToUpdate);
    }

    private class HDT_WRP_QuoteAmend {
        SBQQ__Quote__c newQuote;
        SBQQ__Quote__c oldQuote;
    }

    public static void amendProcessManagementBefore(list<SBQQ__Quote__c> newQuoteList){

        list<SBQQ__Quote__c> amendList = filterAmendedQuote(newQuoteList);
        System.debug('before - amendList ' + amendList);

        list<SBQQ__Quote__c> quoteToAssignList = getQuoteToAssign(amendList);
        System.debug('before - quoteToAssignList ' + quoteToAssignList);
        
        List<HDT_WRP_QuoteAmend> wrapQuote = mapQuoteAmend(amendList, quoteToAssignList);
        System.debug('before - wrapQuote ' + wrapQuote);

        for (HDT_WRP_QuoteAmend wrp : wrapQuote) {
            assignValueToNewQuote(wrp.newQuote, wrp.oldQuote);
        }
        System.debug('before - assignValueToNewQuote ' + wrapQuote);
        
    }

    public static void amendProcessManagementAfter(List<SBQQ__Quote__c> newQuoteList){
        
        List<SBQQ__Quote__c> newSaleAmendQuotes = filterAmendedQuote(newQuoteList);
        System.debug('after - newSaleAmendQuotes ' + newSaleAmendQuotes);

        setSaleIdToOpportunity(newSaleAmendQuotes);
        System.debug('after - setSaleIdToOpportunity ' + newSaleAmendQuotes);

        List<SBQQ__Quote__c> oldSaleAmendQuotes = getSaleAmendOldQuotes(newSaleAmendQuotes);
        System.debug('after - oldSaleAmendQuotes ' + oldSaleAmendQuotes);

        List<String> oldOppList = getSaleAmendOldOpp(oldSaleAmendQuotes);
        System.debug('after - oldOppList ' + oldOppList);
        List<String> oldQuoteList = getSaleAmendOldQuote(oldSaleAmendQuotes);
        System.debug('after - oldQuoteList ' + oldQuoteList);

        Map<String, SBQQ__Quote__c> mapOldToNew = mapOldAndNewQuotes(oldSaleAmendQuotes, newSaleAmendQuotes);
        System.debug('after - mapOldToNew ' + mapOldToNew);

        List<SaleServiceItem__c> items = saleServiceItemQr.getActiveRecordsByQuoteAndOpportunity(oldQuoteList, oldOppList);
        System.debug('after - items ' + items);

        updateItems(mapOldToNew, items);

        List<SBQQ__Quote__c> quoteToCancel = new List<SBQQ__Quote__c>();
        for (String quote : oldQuoteList) {
            quoteToCancel.add(new SBQQ__Quote__c(
                Id = quote,
                SBQQ__Status__c = 'Cancelled'
            ));
        }

        quoteSrv.updateRecords(quoteToCancel);

        List<Opportunity> oppToCancel = new List<Opportunity>();
        for (String opp : oldOppList) {
            oppToCancel.add(new Opportunity(
                Id = opp,
                StageName = 'Chiusa/Annullata'
            ));
        }

        
        oppSrv.updateRecords(oppToCancel);

        // quoteSrv.deleteRecords(oldQuoteList);
        // oppSrv.deleteRecords(oldQuoteList);
    }

}
