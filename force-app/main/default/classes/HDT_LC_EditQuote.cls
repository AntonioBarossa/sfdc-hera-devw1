/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 16/11/2020
* @description HDT_LC_EditQuote – Back-end controller for hdtEditQuote.js lwc component
* @history Keltin Mesonjesi – 16/11/2020 – Created class
*/


public inherited sharing class HDT_LC_EditQuote {

    private static HDT_QR_SaleServiceItem saleServiceItemQr = new HDT_QR_SaleServiceItem();
    private static HDT_QR_Product productQr = new HDT_QR_Product();
    private static HDT_SRV_QuoteLine quoteLineSrv = new HDT_SRV_QuoteLine();
    private static final String ELECTRIC = 'Elettrico';
    private static final String GAS = 'Gas';
    private static final String PRODUCTELECTRICCODE = 'test_luce';
    private static final String PRODUCTGASCODE = 'test_gas';
    private static final String PRODUCTPODCODE = 'pod';
    private static final String PAYMENTTYPERID = 'RID';
    private static final String PAYMENTTYPEBOLL = 'Bollettino';
    
    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 16/11/2020
    * @description Create two SBQQ__QuoteLine__c records
    * @param String quoteId – SBQQ__Quote__c.Id
    * @return List<SBQQ__QuoteLine__c>
    */
    @AuraEnabled
    public static List<SBQQ__QuoteLine__c> createQuoteLine(String quoteId){

        List<SaleServiceItem__c> items = saleServiceItemQr.getRecordsByQuote(quoteId);

        //Init primary product
        Product2 primaryProductElectric = productQr.getRecordByProductCode(PRODUCTELECTRICCODE);
        Product2 primaryProductGas = productQr.getRecordByProductCode(PRODUCTGASCODE);
        Product2 productPod = productQr.getRecordByProductCode(PRODUCTPODCODE);
        String paymentType;
        List<SBQQ__QuoteLine__c> quoteLineObjects = new List<SBQQ__QuoteLine__c>{};

        for (SaleServiceItem__c item : items) {
            
            Product2 primaryProduct = new Product2();

            if (item.ServicePoint__r.RecordType.Name == ELECTRIC) {
                //Get id of product 'Test luce'
                primaryProduct = primaryProductElectric;
                paymentType = PAYMENTTYPERID;
            } else if (item.ServicePoint__r.RecordType.Name == GAS) {
                //Get id of product 'Test gas'
                primaryProduct = primaryProductGas;
                paymentType = PAYMENTTYPEBOLL;
            }

            //Get id of product 'POD'
            Product2 secondaryProduct = productPod;

            //Build SBQQ__QuoteLine__c nr.1 with product 'Test Luce or gas'
            SBQQ__QuoteLine__c primaryQuoteLine = new SBQQ__QuoteLine__c(
                Modalit_di_pagamento__c = paymentType,
                SBQQ__Product__c = primaryProduct.Id,
                SBQQ__Quote__c = quoteId
            );

            //Build SBQQ__QuoteLine__c nr.2 with product 'POD'
            SBQQ__QuoteLine__c secondaryQuoteLine = new SBQQ__QuoteLine__c(
                SBQQ__Product__c = secondaryProduct.Id,
                SBQQ__Quote__c = quoteId
            );

            //Put QuoteLines in a list
            quoteLineObjects.add(primaryQuoteLine);
            quoteLineObjects.add(secondaryQuoteLine);
        }

        //Pass list as param to method that creates QuoteLines
        return quoteLineSrv.createRecords(quoteLineObjects);

    }

}
