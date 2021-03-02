/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 07/01/2020
* @description HDT_QR_OrderItem – Contains queries for OrderItem
* @history Keltin Mesonjesi – 07/01/2020 – Created class
*/
public inherited sharing class HDT_QR_OrderItem {
    
    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 07/01/2020
    * @description Get list of records by listOrderId and filtered by Product2 IN ('PDR','POD')
    * @param List<Id> listOrderId
    * @return List<OrderItem>
    */
    public List<OrderItem> getRecordsByOrderIdListFilteredPdrPod(List<Id> listOrderId){
        return [
            SELECT
            ServicePoint__c,
            ServicePoint__r.Name,
            ServicePoint__r.ServicePointCode__c,
            OrderId,
            Product2.Name
            FROM 
            OrderItem 
            WHERE
            OrderId IN :listOrderId 
            AND Product2.Name IN ('PDR','POD')
            WITH SECURITY_ENFORCED
        ];
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 08/01/2020
    * @description Get record by orderId and filtered by Product2 IN ('PDR','POD')
    * @param String orderId
    * @return List<OrderItem>
    */
    public List<OrderItem> getRecordsByOrderIdFilteredPdrPod(String orderId){
        return [
            SELECT 
            ServicePoint__r.Name,
            ServicePoint__r.ServicePointCode__c,
            OrderId,
            Product2.Name
            FROM 
            OrderItem 
            WHERE
            OrderId = :orderId 
            AND Product2.Name IN ('PDR','POD')
            WITH SECURITY_ENFORCED
        ];
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 10/02/2021
    * @description Get record that have BillingProfile__c value set
    * @param List<Id> listOrderId
    * @return List<OrderItem>
    */
    public List<OrderItem> getRecordsWithBillingProfile(List<Id> listOrderId){
        return [
            SELECT 
            OrderId,
            BillingProfile__c
            FROM 
            OrderItem 
            WHERE
            OrderId IN :listOrderId  
            AND BillingProfile__c != null
            WITH SECURITY_ENFORCED
        ];
    }

}
