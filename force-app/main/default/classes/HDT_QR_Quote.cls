/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 30/10/2020
* @description HDT_QR_Quote – Contains queries for SBQQ__Quote__c
* @history Keltin Mesonjesi – 30/10/2020 – Created class
*/
public inherited sharing class HDT_QR_Quote {

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Get records by Sale__c.Id
     * @param String Sale__c.Id
     * @return List<SBQQ__Quote__c>
     */
    public List<SBQQ__Quote__c> getRecordsBySaleFilterStatus(String saleId, String status){

        return [
            SELECT
            Id,
            Name,
            SBQQ__Opportunity2__r.Name,
            SBQQ__Type__c,
            SBQQ__Status__c,
            SBQQ__Ordered__c,
            SBQQ__LineItemsGrouped__c,
            SBQQ__OrderByQuoteLineGroup__c
            FROM SBQQ__Quote__c
            WHERE Sale__c = :saleId
            AND SBQQ__Status__c != :status

            WITH SECURITY_ENFORCED
            ORDER BY CreatedDate ASC
        ];
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Get records to show in "Configura Prodotti" section on wizard
     * @param String Sale__c.Id
     * @return List<SBQQ__Quote__c>
     */
    public List<SBQQ__Quote__c> getActiveRecords(String saleId){

        return [
            SELECT
            Id,
            Name,
            SBQQ__Opportunity2__r.Name,
            SBQQ__Type__c,
            SBQQ__Status__c,
            SBQQ__Ordered__c,
            SBQQ__LineItemsGrouped__c,
            SBQQ__OrderByQuoteLineGroup__c,
            AmendmentAllowed__c,
            ContractReference__c
            FROM SBQQ__Quote__c
            WHERE Sale__c = :saleId
            AND SBQQ__Status__c NOT IN ('Cancelled','Rejected')
            WITH SECURITY_ENFORCED
            ORDER BY CreatedDate ASC
        ];
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Get record by Id
     * @param String quoteId
     * @return SBQQ__Quote__c
     */
    public SBQQ__Quote__c getRecordById(String quoteId){

        List<SBQQ__Quote__c> records = [
            SELECT
            Id,
            SBQQ__Status__c,
            SBQQ__Opportunity2__c,
            SBQQ__Type__c,
            ContractReference__c,
            OrderReference__c,
            IsVAS__c,
            AmendmentAllowed__c
            FROM SBQQ__Quote__c
            WHERE Id = :quoteId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        return records[0];
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Get record by Id and filtered by status
     * @param String quoteId
     * @param String status
     * @return SBQQ__Quote__c
     */
    public SBQQ__Quote__c getRecordByIdFilterStatus(String quoteId, String status){

        List<SBQQ__Quote__c> records = [
            SELECT
            Id,
            SBQQ__Status__c,
            SBQQ__Opportunity2__c,
            SBQQ__Type__c
            FROM SBQQ__Quote__c
            WHERE Id = :quoteId
            AND SBQQ__Status__c != :status
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        return records[0];
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Get records that will be updated on Sale save Event
     * @param String Sale__c.Id
     * @return List<SBQQ__Quote__c>
     */
    public List<SBQQ__Quote__c> getRecordsForSaleSaveEvent(String saleId){

        return [
            SELECT
            SBQQ__Status__c,
            SBQQ__Ordered__c,
            SBQQ__LineItemsGrouped__c,
            SBQQ__OrderByQuoteLineGroup__c
            FROM SBQQ__Quote__c
            WHERE Sale__c = :saleId
            AND SBQQ__Status__c NOT IN ('Cancelled','Rejected')
            WITH SECURITY_ENFORCED
            ORDER BY CreatedDate ASC
        ];
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Get records that will be updated on Sale cancel Event
     * @param String Sale__c.Id
     * @return List<SBQQ__Quote__c>
     */
    public List<SBQQ__Quote__c> getRecordsForSaleCancelEvent(String saleId){

        return [
            SELECT
            SBQQ__Status__c
            FROM SBQQ__Quote__c
            WHERE Sale__c = :saleId
            AND SBQQ__Status__c NOT IN ('Cancelled','Rejected')
            WITH SECURITY_ENFORCED
            ORDER BY CreatedDate ASC
        ];
    }

    public List<SBQQ__Quote__c> getRecordByTypeAndAmendementAllowed(String status, Boolean amendementAllowed, String type, List<String> accountIds){
        return [
            SELECT
            Sale__c,
            Campaign__c,
            Channel__c,
            AmendmentAllowed__c,
            Agency__c,
            FriendCode__c,
            SaleBy__c,
            SalesCompany__c,
            Market__c,
            SupplyCity__c,
            ContractReference__c
            FROM SBQQ__Quote__c
            WHERE SBQQ__Status__c = :status
            AND AmendmentAllowed__c = :amendementAllowed
            AND SBQQ__Type__c = :type
            AND SBQQ__Account__c IN :accountIds
            WITH SECURITY_ENFORCED
        ];
    }

    public List<SBQQ__Quote__c> getRecordByTypeAndAmendementAllowedAndSaleId(Boolean amendementAllowed, String type, List<String> saleIds, List<String> contracts, List<String> excludedQuotes){
        return [
            SELECT
            Sale__c,
            Campaign__c,
            Channel__c,
            AmendmentAllowed__c,
            Agency__c,
            FriendCode__c,
            SaleBy__c,
            SalesCompany__c,
            Market__c,
            SupplyCity__c,
            ContractReference__c,
            SBQQ__Opportunity2__c
            FROM SBQQ__Quote__c
            WHERE AmendmentAllowed__c = :amendementAllowed
            AND SBQQ__Type__c = :type
            AND Sale__c IN :saleIds
            AND ContractReference__c IN :contracts
            AND Id NOT IN :excludedQuotes
            WITH SECURITY_ENFORCED
        ];
    }
}
