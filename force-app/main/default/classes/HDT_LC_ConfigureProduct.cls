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
        quoteLineSrv.checkReadAccess('Name,SBQQ__Product__r.Name,SBQQ__Quote__r.Name,SBQQ__Quote__r.SBQQ__Opportunity2__r.Name');

        List<SBQQ__Quote__c> quoteList = quoteQr.getRecordsBySaleFilterStatus(saleId, 'Rejected');
        List<SBQQ__QuoteLine__c> quoteLineList = quoteLineQr.getRecordsBySale(saleId);

        resultsList = quoteLineSrv.groupRecordsByQuote(quoteList, quoteLineList);

        return resultsList;
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @date 19/11/2020
     * @description Cancel SBQQ__Quote__c record by changing its status (Status=”Annullata”) and related Opportunity (StageName= “Chiusa/Annullata”)
     * @param String quoteId
     */
    @AuraEnabled
    public static void cancelQuote(String quoteId){

        quoteSrv.checkReadAccess('SBQQ__Status__c');
        SBQQ__Quote__c quoteToUpdate = quoteQr.getRecordById(quoteId);
        quoteToUpdate.SBQQ__Status__c = 'Rejected';

        opportunitySrv.checkReadAccess('StageName');
        Opportunity oppToUpdate = opportunityQr.getRecordById(quoteToUpdate.SBQQ__Opportunity2__c);
        oppToUpdate.StageName = 'Closed Lost';

        quoteSrv.updateRecord(quoteToUpdate);
        opportunitySrv.updateRecord(oppToUpdate);
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Update Sale
     * @param Sale__c sale
     */
    @AuraEnabled
    public static void updateSale(Sale__c sale){
        saleSrv.updateRecord(sale);
    }
}
