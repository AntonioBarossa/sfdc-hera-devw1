public inherited sharing class HDT_LC_QuoteAmendContract {
    
    private static HDT_QR_QuoteLine quoteLineQr = new HDT_QR_QuoteLine();
    private static HDT_SRV_QuoteLine quoteLineSrv = new HDT_SRV_QuoteLine();
    private static HDT_QR_SaleServiceItem saleServiceItemQr = new HDT_QR_SaleServiceItem();
    private static HDT_SRV_SaleServiceItem saleServiceItemSrv = new HDT_SRV_SaleServiceItem();
    private static HDT_SRV_Contract contractSrv = new HDT_SRV_Contract();
    private static HDT_QR_Contract contractQr = new HDT_QR_Contract();

    private static void assocBillingProfileFromContract(String contractId, String saleId){
        contractSrv.checkReadAccess('Name,AccountId,ContractNumber,BillingProfile__c,Status');
        List<Contract> contract = contractQr.getRecordById(contractId);
        List<SBQQ__QuoteLine__c> quoteLine = quoteLineQr.getRecordsByContractFilteredPaymentMethodNotNull(contractId,saleId);

        system.debug('HDT_LC_QuoteAmendContract - contract: ' + contract);
        system.debug('HDT_LC_QuoteAmendContract - quoteLine: ' + quoteLine);

        if (!contract.isEmpty() && !quoteLine.isEmpty()) {
            quoteLineSrv.updateRecord(new SBQQ__QuoteLine__c(
                Id = quoteLine[0].Id
                // BillingProfile__c = contract[0].BillingProfile__c //to uncomment
            ));
        } else {
            system.debug('HDT_LC_QuoteAmendContract - assocBillingProfileFromContract - nessun contract o quoteLine trovato');
        }

    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description Associate ServicePoint to QuoteLines of type "POD"
    * @param String contractId - SBQQ__Quote__r.ContractReference__c
    */
    private static void assocPodToQuoteLine(String contractId, String saleId){
       
        //get all quoteLine pods
        quoteLineSrv.checkReadAccess('Name,SBQQ__Product__r.Name,SBQQ__Quote__r.Name,SBQQ__Quote__r.SBQQ__Opportunity2__r.Name,ServicePoint__c');
        List<SBQQ__QuoteLine__c> quoteLinePods = quoteLineQr.getRecordsByContractAndProductPod(contractId, saleId);
        system.debug('HDT_LC_QuoteAmendContract - quoteLinePods: ' + quoteLinePods);

        //get all saleServiceItems for this quote
        saleServiceItemSrv.checkReadAccess('Quote__c,ServicePoint__c,ServicePoint__r.RecordType.Name,ServicePoint__r.RecordType.DeveloperName');
        List<SaleServiceItem__c> saleServiceItems = saleServiceItemQr.getRecordsByContract(contractId, saleId);
        system.debug('HDT_LC_QuoteAmendContract - saleServiceItems: ' + saleServiceItems);

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

            } else {
                system.debug('HDT_LC_QuoteAmendContract - assocPodToQuoteLine - All Service Points have been assigned!');
            }

        } else {
            system.debug('HDT_LC_QuoteAmendContract - assocPodToQuoteLine - Configurare i prodotti per tutti i Service Point!');
        }

    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description Execute actions when exiting modal
    * @param String contractId - SBQQ__Quote__r.ContractReference__c
    */
    @AuraEnabled
    public static void execModalExitActions(String contractId, String saleId){
        assocBillingProfileFromContract(contractId, saleId);
        assocPodToQuoteLine(contractId, saleId);
    }

}
