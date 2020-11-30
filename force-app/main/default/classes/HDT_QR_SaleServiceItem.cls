/**
 * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
 * @date 30/10/2020
 * @description HDT_QR_SaleServiceItem.cls - Class that holds queries for SaleServiceItem
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */

public inherited sharing class HDT_QR_SaleServiceItem {
    
    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Check for SaleServiceItem record that has a ServicePoint__c with this city and record type
     * @param String saleId
     * @param String ServicePoint__r.SupplyCity__c
     * @param String ServicePoint__r.RecordType.Name
     * @return List<SaleServiceItem__c>
     */
    public List<SaleServiceItem__c> queryExsistingCityAndType(String saleId, String city, String type){

        return [SELECT Id,
        Opportunity__c,
        Opportunity__r.Name,
        Quote__c,
        ServicePoint__c,
        ServicePoint__r.SupplyCity__c,
        ServicePoint__r.RecordType.Name,
        Opportunity__r.Vendita__c
        FROM SaleServiceItem__c
        WHERE Opportunity__r.Vendita__c = :saleId
        AND ServicePoint__r.SupplyCity__c = :city
        AND ServicePoint__r.RecordType.Name = :type
        WITH SECURITY_ENFORCED];
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Get records filtered by Opportunity__r.Vendita__c
     * @param String saleId
     * @return List<SaleServiceItem__c>
     */
    public List<SaleServiceItem__c> getRecordsBySaleId(String saleId){

        return [SELECT 
        Id,
        Opportunity__c,
        Opportunity__r.Vendita__c,
        Opportunity__r.Name,
        Quote__c,
        Quote__r.Name,
        ServicePoint__c,
        ServicePoint__r.ServicePointCode__c,
        ServicePoint__r.RecordType.Name,
        ServicePoint__r.SupplyCity__c
        FROM SaleServiceItem__c
        WHERE Opportunity__r.Vendita__c = :saleId
        WITH SECURITY_ENFORCED
        ORDER BY Opportunity__r.CreatedDate ASC
        ];
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Get records filtered by Opportunity.Id
     * @param String opportunityId
     * @return List<SaleServiceItem__c>
     */
    public List<SaleServiceItem__c> getRecordsByOpportunityId(String opportunityId){

        return [SELECT 
        Id,
        Opportunity__c,
        Quote__c,
        ServicePoint__c
        FROM SaleServiceItem__c
        WHERE Opportunity__c = :opportunityId
        WITH SECURITY_ENFORCED
        ORDER BY CreatedDate ASC
        ];
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 16/11/2020
    * @description Get single record by quote id that has ServicePoint__r.RecordType.Name
    * @param String quoteId – SBQQ__Quote__c.Id
    * @return List<SaleServiceItem__c>
    */
    public List<SaleServiceItem__c> getRecordsByQuote(String quoteId){

        return [
            SELECT  
            Quote__c,
            ServicePoint__c,
            ServicePoint__r.RecordType.Name
            FROM SaleServiceItem__c
            WHERE Quote__c = :quoteId
            WITH SECURITY_ENFORCED
        ];
    }
}
