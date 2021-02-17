/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 30/10/2020
* @description HDT_QR_Opportunity – Contains queries for Opportunity
* @history Keltin Mesonjesi – 30/10/2020 – Created class
*/
public inherited sharing class HDT_QR_Opportunity {
    
    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Counts all records
     * @param String Sale__c.Id
     * @return Integer
     */

    public Integer countRecordsBySale(String saleId){
        return [SELECT count() FROM Opportunity WHERE Sale__c = :saleId WITH SECURITY_ENFORCED];
    }


    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Get Opportunities by Sale__c filtered by StageName
     * @param String Sale__c.Id
     * @param String fields
     * @param String stageNameFilter
     * @return List<Opportunity>
     */
    public List<Opportunity> getRecordsBySaleFilterStageName(String saleId, String fields, String stageNameFilter){
        
        String query = 'SELECT '+ fields +

                ' FROM Opportunity WHERE Sale__c = :saleId AND StageName != :stageNameFilter ORDER BY CreatedDate ASC';
        return Database.query(query);

    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Get Opportunities by Sale__c filtered by StageName
     * @param String Sale__c.Id
     * @param String fields
     * @param String stageNameFilter
     * @return List<Opportunity>
     */
    public List<Opportunity> getRecordsBySaleFilterStageNameNotVas(String saleId, String fields, String stageNameFilter){
        
        String query = 'SELECT '+ fields +

                ' FROM Opportunity WHERE Sale__c = :saleId AND SBQQ__PrimaryQuote__r.ContractReference__c = null AND SBQQ__PrimaryQuote__r.OrderReference__c = null AND StageName != :stageNameFilter ORDER BY CreatedDate ASC';
        return Database.query(query);

    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Get record by Id
     * @param String opportunityId
     * @return Opportunity
     */
    public Opportunity getRecordById(String opportunityId){

        List<Opportunity> records = [
            SELECT
            Id,
            StageName
            FROM Opportunity
            WHERE Id = :opportunityId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        return records[0];
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Get record by Id and filtered by status
     * @param String opportunityId
     * @param String status
     * @return Opportunity
     */
    public Opportunity getRecordByIdFilterStatus(String opportunityId, String status){

        List<Opportunity> records = [
            SELECT
            Id,
            StageName
            FROM Opportunity
            WHERE Id = :opportunityId
            AND StageName != :status
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        return records[0];
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Get records by Sale and filtered by type VAS
     * @param String opportunityId
     * @param String status
     * @return Opportunity
     */
    public List<Opportunity> getRecordsBySaleFilteredVas(String saleId){
        return [
            SELECT
            Id,
            Name,
            SBQQ__PrimaryQuote__r.OrderReference__c,
            SBQQ__PrimaryQuote__r.OrderReference__r.Name,
            SBQQ__PrimaryQuote__r.OrderReference__r.OrderNumber,
            SBQQ__PrimaryQuote__r.ContractReference__c,
            SBQQ__PrimaryQuote__r.ContractReference__r.ContractNumber,
            SBQQ__PrimaryQuote__r.SupplyCity__c,
            CreatedDate
            FROM Opportunity
            WHERE Sale__c = :saleId
            AND (SBQQ__PrimaryQuote__r.OrderReference__c != null 
            OR SBQQ__PrimaryQuote__r.ContractReference__c != null
            OR Name LIKE '%VAS%')
            WITH SECURITY_ENFORCED
            ORDER BY CreatedDate ASC
        ];
    }
}
