/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 16/11/2020
* @description HDT_LC_EditQuote – Back-end controller for hdtEditQuote.js lwc component
* @history Keltin Mesonjesi – 16/11/2020 – Created class
*/


public inherited sharing class HDT_LC_EditQuote {

    private static HDT_QR_SaleServiceItem saleServiceItemQR = new HDT_QR_SaleServiceItem();
    
    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 16/11/2020
    * @description Create two SBQQ__QuoteLine__c records
    * @param String quoteId – SBQQ__Quote__c.Id
    * @return Descrizione di quanto ritorna il metodo
    */
    @AuraEnabled
    public static void createQuoteLine(String quoteId){

        SaleServiceItem__c item = saleServiceItemQR.getRecordByQuote(quoteId);

        switch on item.ServicePoint__r.RecordType.Name {
            when 'Elettrico'{
                //Get id of product 'Test luce'
            }
            when 'Gas' {
                //Get id of product 'Test gas'
            }
        }

        //Get id of product 'POD'

        //Build SBQQ__QuoteLine__c nr.1 with product 'Test Luce or gas'

        //Build SBQQ__QuoteLine__c nr.2 with product 'POD'

        //Put QuoteLines in a list

        //Pass list as param to method that creates QuoteLines

        system.debug(item.ServicePoint__r.RecordType.Name);

    }
}
