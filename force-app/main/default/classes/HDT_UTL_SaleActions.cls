/**@frpanico 2022-09-08
 * Utility class of the SaleActions controller HDT_LC_SaleActions
 */
public with sharing class HDT_UTL_SaleActions
{
    /**@frpanico 2022-09-08
     * This method creates the GroupLines to perform order split
     * It takes in input the SaleId
     * Returns a wrapper that contains group and/or an error message if needed
     */
    public static HDT_WRP_SaleActions groupQuoteLines(String saleId)
    {
        HDT_WRP_SaleActions result = new HDT_WRP_SaleActions();
        List<SBQQ__QuoteLine__c> allQuoteLines = [SELECT Id
            BillingProfile__c,
            ServicePoint__c,
            ServicePoint__r.CommoditySector__c
            FROM SBQQ__QuoteLine__c 
            WHERE SBQQ__Quote__r.Sale__c = :saleId 
            WITH SECURITY_ENFORCED];


        return result;
    }

    class HDT_WRP_SaleActions
    {
        public String errorMessage;
        public List<SBQQ__QuoteLineGroup__c> quoteLineGroups;
    }
}
