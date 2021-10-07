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
     * @param sale
     * @param servicePoint
     * @param calculatedStringValues
     * @param calculatedDecimalValues
     * @return List<SaleServiceItem__c>
     */
    public List<SaleServiceItem__c> queryExsistingCityAndType(Sale__c sale, ServicePoint__c servicePoint, Map<String,String> calculatedStringValues, Map<String,Decimal> calculatedDecimalValues){

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
        WHERE Opportunity__r.Sale__c = :sale.Id
        AND ServicePoint__r.SupplyCity__c = :servicePoint.SupplyCity__c
        AND ServicePoint__r.RecordType.DeveloperName = :servicePoint.RecordType.DeveloperName
        AND ServicePoint__r.MarketOrigin__c = :servicePoint.MarketOrigin__c
        AND ServicePoint__r.SupplyProvince__c = :servicePoint.SupplyProvince__c
        AND ServicePoint__r.MeterType__c = :servicePoint.MeterType__c
        AND ServicePoint__r.UseCategory__c = :servicePoint.UseCategory__c
        AND Opportunity__r.Sale__r.Agency__c = :sale.Agency__c
        // AND Opportunity__r.Sale__r.Channel__c = :sale.Channel__c
        AND Opportunity__r.Sale__r.Campaign__c = :sale.Campaign__c
        AND Quote__r.Login__c = :calculatedStringValues.get('login')
        AND Quote__r.LoginGroup__c = :calculatedStringValues.get('loginGroup')
        AND Quote__r.Role__c = :calculatedStringValues.get('role')
        AND Quote__r.Profile__c = :calculatedStringValues.get('profile')
        AND Quote__r.NewClient__c = :calculatedStringValues.get('newClient')
        AND Quote__r.ResidentDeliveryAddress__c = :calculatedStringValues.get('residentDeliveryAddress')
        AND Quote__r.ConsumptionRangeEE__c = :calculatedDecimalValues.get('consumptionRangeEle')
        AND Quote__r.ConsumptionRangeGAS__c = :calculatedDecimalValues.get('consumptionRangeGas')
        AND Quote__r.PowerFlow__c = :calculatedDecimalValues.get('powerFlow')
        AND Quote__r.AmendmentAllowed__c = false
        AND Opportunity__r.StageName NOT IN ('Closed Lost')
        WITH SECURITY_ENFORCED];
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Get records filtered by Opportunity__r.Sale__c
     * @param saleId
     * @return List<SaleServiceItem__c>
     */
    public List<SaleServiceItem__c> getRecordsBySaleId(String saleId){

        return [SELECT 
        Id,
        Opportunity__c,
        Opportunity__r.Sale__c,
        Opportunity__r.Sale__r.Account__c,
        Opportunity__r.Name,
        Opportunity__r.CreatedDate,
        Quote__c,
        Quote__r.Name,
        ServicePoint__c,
        ServicePoint__r.ServicePointCode__c,
        ServicePoint__r.Account__c,
        ServicePoint__r.CommoditySector__c,
        ServicePoint__r.MeterStatus__c,
        ServicePoint__r.PlugPresence__c,
        ServicePoint__r.PowerRequested__c,
        ServicePoint__r.PowerContractual__c,
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
     * @description getRecordsBySaleIdFilter
     * @param saleId
     * @return List<SaleServiceItem__c>
     */
    public List<SaleServiceItem__c> getRecordsBySaleIdFilter(String saleId){

        return [SELECT 
        Id,
        Opportunity__c,
        Opportunity__r.Sale__c,
        Opportunity__r.Sale__r.Account__c,
        Opportunity__r.Name,
        Opportunity__r.CreatedDate,
        Quote__c,
        Quote__r.Name,
        ServicePoint__c,
        ServicePoint__r.ServicePointCode__c,
        ServicePoint__r.Account__c,
        ServicePoint__r.CommoditySector__c,
        ServicePoint__r.MeterStatus__c,
        ServicePoint__r.PlugPresence__c,
        ServicePoint__r.PowerRequested__c,
        ServicePoint__r.PowerContractual__c,
        ServicePoint__r.RecordType.Name,
        ServicePoint__r.RecordType.DeveloperName,
        ServicePoint__r.SupplyCity__c,
        ServicePoint__r.MarketOrigin__c
        FROM SaleServiceItem__c
        WHERE Opportunity__r.Sale__c = :saleId
        AND Quote__r.SBQQ__Status__c NOT IN ('Cancelled','Rejected')
        WITH SECURITY_ENFORCED
        ORDER BY Opportunity__r.CreatedDate ASC
        ];
    }

    /**
     * @description getSaleByServicePoint
     * @param servicepoint
     * @return List<SaleServiceItem__c>
     */
    public List<SaleServiceItem__c> getSaleByServicePoint(String servicepoint){

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
        ServicePoint__r.PlugPresence__c,
        ServicePoint__r.PowerRequested__c,
        ServicePoint__r.PowerContractual__c,
        ServicePoint__r.RecordType.Name,
        ServicePoint__r.RecordType.DeveloperName,
        ServicePoint__r.SupplyCity__c,
        ServicePoint__r.MarketOrigin__c,
        createdDate
        FROM SaleServiceItem__c
        WHERE ServicePoint__c = :servicepoint
        WITH SECURITY_ENFORCED
        ORDER BY CreatedDate DESC
        ];
    }

    /**
     * @description getSaleByServicePointFilter
     * @param servicepoint
     * @return List<SaleServiceItem__c>
     */
    public List<SaleServiceItem__c> getSaleByServicePointFilter(String servicepoint){

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
        ServicePoint__r.CommoditySector__c,
        ServicePoint__r.PlugPresence__c,
        ServicePoint__r.PowerRequested__c,
        ServicePoint__r.PowerContractual__c,
        ServicePoint__r.RecordType.Name,
        ServicePoint__r.RecordType.DeveloperName,
        ServicePoint__r.SupplyCity__c,
        ServicePoint__r.MarketOrigin__c,
        createdDate
        FROM SaleServiceItem__c
        WHERE ServicePoint__c = :servicepoint
        AND Quote__r.SBQQ__Status__c NOT IN ('Cancelled','Rejected')
        WITH SECURITY_ENFORCED
        ORDER BY CreatedDate DESC
        ];
    }

    /**
     * @description getSaleByServicePointFilterCode
     * @param servicepointCode
     * @return List<SaleServiceItem__c>
     */
    public List<SaleServiceItem__c> getSaleByServicePointFilterCode(String servicepointCode){

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
        ServicePoint__r.CommoditySector__c,
        ServicePoint__r.PlugPresence__c,
        ServicePoint__r.PowerRequested__c,
        ServicePoint__r.PowerContractual__c,
        ServicePoint__r.RecordType.Name,
        ServicePoint__r.RecordType.DeveloperName,
        ServicePoint__r.SupplyCity__c,
        ServicePoint__r.MarketOrigin__c,
        createdDate
        FROM SaleServiceItem__c
        WHERE ServicePoint__r.ServicePointCode__c = :servicepointCode
        AND Quote__r.SBQQ__Status__c NOT IN ('Cancelled','Rejected')
        WITH SECURITY_ENFORCED
        ORDER BY CreatedDate DESC
        ];
    }
    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Get active records filtered by Opportunity__r.Sale__c
     * @param saleId
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
     * @param opportunityId
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
    * @param quoteId – SBQQ__Quote__c.Id
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

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 13/03/2021
    * @description Get single record by quote id that has ServicePoint__r.RecordType.DeveloperName
    * @param contractId – Quote__r.ContractReference__c
    * @param saleId
    * @return List<SaleServiceItem__c>
    */
    public List<SaleServiceItem__c> getRecordsByContract(String contractId, String saleId){

        return [
            SELECT  
            Quote__c,
            ServicePoint__c,
            ServicePoint__r.RecordType.Name,
            ServicePoint__r.RecordType.DeveloperName
            FROM SaleServiceItem__c
            WHERE Quote__r.ContractReference__c = :contractId
            AND Quote__r.Sale__c = :saleId
            AND Quote__r.SBQQ__Status__c NOT IN ('Cancelled','Rejected')
            WITH SECURITY_ENFORCED
        ];
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description getActiveRecordsByQuoteAndOpportunity
    * @param quotes
    * @param opportunities
    * @return List<SaleServiceItem__c>
    */
    public List<SaleServiceItem__c> getActiveRecordsByQuoteAndOpportunity(List<String> quotes, List<String> opportunities){

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
        WHERE Quote__c IN :quotes
        AND Opportunity__c IN :opportunities
        AND Quote__r.SBQQ__Status__c NOT IN ('Cancelled','Rejected')
        WITH SECURITY_ENFORCED
        ORDER BY Opportunity__r.CreatedDate ASC
        ];
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description getRecordsWithContractsByServicePointAndAccount
    * @param servicePointId
    * @param accountId
    * @return List<SaleServiceItem__c>
    */
    public List<SaleServiceItem__c> getRecordsWithContractsByServicePointAndAccount(String servicePointId, String accountId){

        return [
            SELECT 
            Id,
            Quote__c,
            Quote__r.ContractReference__c,
            Opportunity__c,
            Opportunity__r.CreatedDate
            FROM SaleServiceItem__c
            WHERE ServicePoint__c = :servicePointId
            AND Quote__r.SBQQ__Account__c = :accountId
            AND Quote__r.ContractReference__c != null
            AND Quote__r.SBQQ__Status__c NOT IN ('Cancelled','Rejected')
            WITH SECURITY_ENFORCED
            ORDER BY Opportunity__r.CreatedDate ASC
        ];
    }
}
