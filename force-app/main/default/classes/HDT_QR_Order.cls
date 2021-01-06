/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 05/01/2020
* @description HDT_QR_Order – Contains queries for Order
* @history Keltin Mesonjesi – 05/01/2020 – Created class
*/
public inherited sharing class HDT_QR_Order {
    
    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 05/01/2020
    * @description Get list of records by Sale__c.Id
    * @param String saleId – Sale__c.Id
    * @return List<Order>
    */
    public List<Order> getRecordBySale(String saleId){
        return [
            SELECT
            Status
            FROM Order 
            WHERE Vendita__c = :saleId
            WITH SECURITY_ENFORCED
            ];
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 06/01/2020
    * @description Get list of records by Sale__c.Id and filtered by recordTypeId
    * @param String saleId – Sale__c.Id
    * @param String recordTypeId
    * @return List<Order>
    */
    public List<Order> getRecordBySaleFilterRecordTypeId(String saleId, String recordTypeId){
        return [
            SELECT
            Status
            FROM Order 
            WHERE Vendita__c = :saleId
            AND RecordTypeId = :recordTypeId
            WITH SECURITY_ENFORCED
            ];
    }

}
