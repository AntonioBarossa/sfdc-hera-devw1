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
     * @param String ServicePoint__r.RecordType.DeveloperName
     * @param String ServicePoint__r.MarketOrigin__c
     * @return List<SaleServiceItem__c>
     */
    public List<SaleServiceItem__c> queryExsistingCityAndType(String saleId, String city, String type, String marketOrigin){

        return [SELECT Id,
        Opportunity__c,
        Opportunity__r.Name,
        Quote__c,
        ServicePoint__c,
        ServicePoint__r.SupplyCity__c,
        ServicePoint__r.RecordType.Name,
        ServicePoint__r.RecordType.DeveloperName,
        ServicePoint__r.MarketOrigin__c,
        Opportunity__r.Sale__c
        FROM SaleServiceItem__c
        WHERE Opportunity__r.Sale__c = :saleId
        AND ServicePoint__r.SupplyCity__c = :city
        AND ServicePoint__r.RecordType.DeveloperName = :type
        AND ServicePoint__r.MarketOrigin__c = :marketOrigin
        AND Quote__r.AmendmentAllowed__c = false
        AND Opportunity__r.StageName NOT IN ('Closed Lost')
        WITH SECURITY_ENFORCED];
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Get records filtered by Opportunity__r.Sale__c
     * @param String saleId
     * @return List<SaleServiceItem__c>
     */
    public List<SaleServiceItem__c> getRecordsBySaleId(String saleId){

        return [SELECT 
        Id,
        Opportunity__c,
        Opportunity__r.Sale__c,
        Opportunity__r.Name,
        Opportunity__r.CreatedDate,
        Quote__c,
        Quote__r.Name,
        ServicePoint__c,
        ServicePoint__r.ServicePointCode__c,
        ServicePoint__r.RecordType.Name,
        ServicePoint__r.RecordType.DeveloperName,
        ServicePoint__r.SupplyCity__c,
        ServicePoint__r.MarketOrigin__c
        FROM SaleServiceItem__c
        WHERE Opportunity__r.Sale__c = :saleId
        WITH SECURITY_ENFORCED
        ORDER BY Opportunity__r.CreatedDate ASC
        ];
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Get active records filtered by Opportunity__r.Sale__c
     * @param String saleId
     * @return List<SaleServiceItem__c>
     */
    public List<SaleServiceItem__c> getActiveRecordsBySaleId(String saleId){

        return [SELECT 
        Id,
        Opportunity__c,
        Opportunity__r.Sale__c,
        Opportunity__r.Name,
        Opportunity__r.CreatedDate,
        Quote__c,
        Quote__r.Name,
        ServicePoint__c,
        ServicePoint__r.ServicePointCode__c,
        ServicePoint__r.RecordType.Name,
        ServicePoint__r.RecordType.DeveloperName,
        ServicePoint__r.SupplyCity__c
        FROM SaleServiceItem__c
        WHERE Opportunity__r.Sale__c = :saleId
        AND Quote__r.SBQQ__Status__c NOT IN ('Cancelled','Rejected')
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
    * @description Get single record by quote id that has ServicePoint__r.RecordType.DeveloperName
    * @param String quoteId – SBQQ__Quote__c.Id
    * @return List<SaleServiceItem__c>
    */
    public List<SaleServiceItem__c> getRecordsByQuote(String quoteId){

        return [
            SELECT  
            Quote__c,
            ServicePoint__c,
            ServicePoint__r.RecordType.Name,
            ServicePoint__r.RecordType.DeveloperName
            FROM SaleServiceItem__c
            WHERE Quote__c = :quoteId
            WITH SECURITY_ENFORCED
        ];
    }
}
