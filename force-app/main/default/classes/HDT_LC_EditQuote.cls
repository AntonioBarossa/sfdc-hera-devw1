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

    /*
    private static HDT_QR_Product productQr = new HDT_QR_Product();
    private static final String ELECTRIC = 'Elettrico';
    private static final String GAS = 'Gas';
    private static final String PRODUCTELECTRICCODE = 'test_luce';
    private static final String PRODUCTGASCODE = 'test_gas';
    private static final String PRODUCTPODCODE = 'pod';
    private static final String PRODUCTPDRCODE = 'pdr';
    private static final String PAYMENTTYPERID = 'RID';
    private static final String PAYMENTTYPEBOLL = 'Bollettino postale';
    */
    
    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 16/11/2020
    * @description Create two SBQQ__QuoteLine__c records
    * @param String quoteId – SBQQ__Quote__c.Id
    * @return List<SBQQ__QuoteLine__c>
    */
    /*
    @AuraEnabled
    public static List<SBQQ__QuoteLine__c> createQuoteLine(String quoteId){

        List<SaleServiceItem__c> items = saleServiceItemQr.getRecordsByQuote(quoteId);

        //Init primary product
        Product2 primaryProductElectric = productQr.getRecordByProductCode(PRODUCTELECTRICCODE);
        Product2 primaryProductGas = productQr.getRecordByProductCode(PRODUCTGASCODE);
        Product2 productPod = productQr.getRecordByProductCode(PRODUCTPODCODE);
        Product2 productPdr = productQr.getRecordByProductCode(PRODUCTPDRCODE);
        String paymentType;
        String productName;
        List<SBQQ__QuoteLine__c> quoteLineObjects = new List<SBQQ__QuoteLine__c>{};
        List<SBQQ__QuoteLine__c> quoteLinePrimaryList = new List<SBQQ__QuoteLine__c>{};
        List<HDT_WRP_QuoteLineAssoc> quoteLineWrapList = new List<HDT_WRP_QuoteLineAssoc>{};
        Map<SBQQ__QuoteLine__c,SBQQ__QuoteLine__c> mapQuoteLines = new Map<SBQQ__QuoteLine__c,SBQQ__QuoteLine__c>();


        for (SaleServiceItem__c item : items) {
            
            Product2 primaryProduct = new Product2();

            //Get id of product 'POD'
            Product2 secondaryProduct = new Product2();

            if (item.ServicePoint__r.RecordType.Name == ELECTRIC) {
                //Get id of product 'Test luce'
                primaryProduct = primaryProductElectric;
                secondaryProduct = productPod;
                paymentType = PAYMENTTYPERID;
                productName = 'POD';
            } else if (item.ServicePoint__r.RecordType.Name == GAS) {
                //Get id of product 'Test gas'
                primaryProduct = primaryProductGas;
                secondaryProduct = productPdr;
                paymentType = PAYMENTTYPEBOLL;
                productName = 'PDR';
            }

            

            //Build SBQQ__QuoteLine__c nr.1 with product 'Test Luce or gas'
            SBQQ__QuoteLine__c primaryQuoteLine = new SBQQ__QuoteLine__c(
                PaymentMode__c = paymentType,
                SBQQ__Product__c = primaryProduct.Id,
                SBQQ__Quote__c = quoteId,
                SBQQ__Number__c = 1,
                SBQQ__Bundle__c = true,
                // SBQQ__PricebookEntryId__c = '01s2o00000142oqAAA',
                SBQQ__PricebookEntryId__c = '01u0E00000IbG8dQAF',
                SBQQ__Quantity__c = 1,
                SBQQ__NetPrice__c = 1,
                SBQQ__UnitCost__c = 1
            );

            //Build SBQQ__QuoteLine__c nr.2 with product 'POD'
            SBQQ__QuoteLine__c secondaryQuoteLine = new SBQQ__QuoteLine__c(
                SBQQ__Product__c = secondaryProduct.Id,
                SBQQ__Quote__c = quoteId,
                SBQQ__UnitCost__c = 1,
                SBQQ__NetPrice__c = 1,
                SBQQ__Number__c = 2,
                SBQQ__OptionLevel__c = 1,
                // SBQQ__PricebookEntryId__c = '01s2o00000142oqAAA',
                SBQQ__PricebookEntryId__c = '01u0E00000IbG8dQAF',
                SBQQ__RequiredBy__c = primaryQuoteLine.Id,
                SBQQ__Quantity__c = 1,
                ServicePoint__c = item.ServicePoint__r.Id
                // SBQQ__EffectiveQuantity__c = 1
            );

            //Put QuoteLines in a list

            HDT_WRP_QuoteLineAssoc wrapQuoteLinePri = new HDT_WRP_QuoteLineAssoc();
            wrapQuoteLinePri.primary = primaryQuoteLine;
            wrapQuoteLinePri.secondary = secondaryQuoteLine;

            // mapQuoteLines.put(primaryQuoteLine,secondaryQuoteLine);
            quoteLinePrimaryList.add(primaryQuoteLine);
            quoteLineWrapList.add(wrapQuoteLinePri);


            // quoteLineObjects.add(primaryQuoteLine);
            // quoteLineObjects.add(secondaryQuoteLine);
        }



        // List<SBQQ__QuoteLine__c> quoteLinesPriList = new List<SBQQ__QuoteLine__c>();
        // quoteLinesPriList.addAll(mapQuoteLines.keySet());

        //Pass list as param to method that creates QuoteLines
         quoteLineSrv.createRecords(quoteLinePrimaryList);
         system.debug('quoteLinePrimaryList: ' + quoteLinePrimaryList);

         for (HDT_WRP_QuoteLineAssoc quoteLineWrap : quoteLineWrapList) {
            SBQQ__QuoteLine__c quoteLineSecUpdate = quoteLineWrap.secondary;
            system.debug('quoteLineSecWrap: ' + quoteLineWrap.secondary);
            quoteLineSecUpdate.SBQQ__RequiredBy__c = quoteLineWrap.primary.Id;
            system.debug('quoteLineSecUpdate: ' + quoteLineSecUpdate);
            quoteLineObjects.add(quoteLineSecUpdate);
         }

         quoteLineSrv.createRecords(quoteLineObjects);

         quoteLineObjects.addAll(quoteLinePrimaryList);

         return quoteLineObjects;

    }*/

    /*public inherited sharing class HDT_WRP_QuoteLineAssoc {

        SBQQ__QuoteLine__c primary = new SBQQ__QuoteLine__c();
        SBQQ__QuoteLine__c secondary = new SBQQ__QuoteLine__c();
    }*/

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

            } else {
                system.debug('HDT_LC_EditQuote - assocPodToQuoteLine - All Service Points have been assigned!');
            }

        } else {
            system.debug('HDT_LC_EditQuote - assocPodToQuoteLine - Configurare i prodotti per tutti i Service Point!');
        }

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

        return haveProductsBeenCreated(quoteId);

    }

}
