/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 17/11/2020
* @description HDT_QR_QuoteLine – Contains queries for SBQQ__QuoteLine__c
* @history Keltin Mesonjesi – 17/11/2020 – Created class
*/

public inherited sharing class HDT_QR_QuoteLine {
    
    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 17/11/2020
    * @description Get records related to SBQQ__Quote__c.Vendita__c
    * @param String saleId – Sale__c.Id
    * @return List<SBQQ__QuoteLine__c>
    */
    public List<SBQQ__QuoteLine__c> getRecordsBySale(String saleId){

        return [
            SELECT
            Id,
            Name,
            SBQQ__Product__r.Name,
            SBQQ__Quote__r.Name,
            SBQQ__Quote__r.SBQQ__Opportunity2__r.Name
            FROM SBQQ__QuoteLine__c
            WHERE SBQQ__Quote__r.Vendita__c = :saleId
            WITH SECURITY_ENFORCED
        ];

    }

}
