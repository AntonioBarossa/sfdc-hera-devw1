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
    * @param listOrderId
    * @return List<OrderItem>
    */
    /**@frpanico
     * A valle della nuova modifica non vanno presi tutti i bonus ma soltanto quelli di analisi consumi
     */
    public List<OrderItem> getRecordsByOrderIdListFilteredPdrPod(List<Id> listOrderId){
        Set<String> famils = new Set<String>();/*HDT_UTL_OrderProcessAssignment.getFamilySconto();*/
        famils.add('VAS Prodotto');
        famils.add('VAS Servizio');
        /**@frpanico 21/01/2022
         * Aggiunta famiglia VAS Fatturabili
         * Per includere gli order di Analisi Consumi
         */
        famils.add('VAS Fatturabili');
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
            AND (Product2.Name IN ('PDR','POD') OR (Product2.Family IN  :famils AND (NOT Product2.Description LIKE '%Sconto%')))
            WITH SECURITY_ENFORCED
        ];
    }

    public List<OrderItem> getRecordsByOrderIdFilteredFamilyBonus(List<Id> listOrderId){
        Set<String> famils = HDT_UTL_OrderProcessAssignment.getFamilySconto();
        return [
            SELECT
            ServicePoint__c,
            ServicePoint__r.Name,
            ServicePoint__r.ServicePointCode__c,
            OrderId,
            Order.OrderNumber,
            SBQQ__QuoteLine__r.SBQQ__RequiredBy__c,
            SBQQ__RequiredBy__c,
            Product2.Name
            FROM 
            OrderItem 
            WHERE
            OrderId IN :listOrderId 
            AND Product2.Family IN :famils
            WITH SECURITY_ENFORCED
            Order by BillingProfile__c NULLS LAST
        ];
    }



    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 08/01/2020
    * @description Get record by orderId and filtered by Product2 IN ('PDR','POD')
    * @param orderId
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
    * @param listOrderId
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

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description getRecordsWithAmend
    * @param listOrderId
    * @return List<OrderItem>
    */
    public List<OrderItem> getRecordsWithAmend(List<Id> listOrderId){
        Set<String> famils = HDT_UTL_OrderProcessAssignment.getFamilySconto();
        //famils.add('VAS Prodotto');
        //famils.add('VAS Servizio');
        return [
            SELECT 
            OrderId,
            BillingProfile__c,
            ServicePoint__c
            FROM 
            OrderItem 
            WHERE
            OrderId IN :listOrderId  
            AND Order.SBQQ__Quote__r.SBQQ__Type__c = 'Amendment'
            AND (Product2.Name IN ('PDR','POD') OR Product2.Family IN :famils)
            WITH SECURITY_ENFORCED
        ];
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description getMainItem
    * @param orderId
    * @return List<OrderItem>
    */
    public List<OrderItem> getMainItem(String orderId){
        return [
            SELECT 
            OrderId,
            BillingProfile__c,
            Product2Id,
            Product2.Family,
            Product2.Version__c,
            Product2.ProductCode,
            Product2.Name,
            Product2.DescriptionSAP__c,
            Product2.ReferenceMarket__c,
            VASBillingMode__c,
            SBQQ__QuoteLine__r.SBQQ__RequiredBy__c,
            SBQQ__QuoteLine__r.ServicePointLinkItem__r.ServicePoint__c,
            DelayEffectiveDate__c
            FROM 
            OrderItem 
            WHERE OrderId = :orderId
            AND SBQQ__RequiredBy__c = null
            WITH SECURITY_ENFORCED
        ];
    }
    

    /**
    * @description 
    * @author federico.defelice@webresults.it | 11-10-2021 
    * @param quoteId 
    * @param quoteLineId 
    * @return List<Order> 
    **/
    public List<OrderItem> getPodOrderFromQuote(Id quoteId, Id qlOrServPointId){
        return [
            SELECT
            OrderId,
            Order.ServicePoint__r.ServicePointCode__c,
            Order.ServicePoint__c
            FROM
            OrderItem
            WHERE
            Order.SBQQ__Quote__c =:quoteId
            AND (SBQQ__QuoteLine__c =:qlOrServPointId OR Order.ServicePoint__c=:qlOrServPointId)
            AND Order.ServicePoint__c!=null
            WITH SECURITY_ENFORCED
        ];
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description getAnalisiConsumi
    * @param orderId
    * @return List<OrderItem>
    */
    public List<OrderItem> getAnalisiConsumi(String orderId){
        return [
            SELECT 
            OrderId,
            BillingProfile__c,
            Product2Id,
            Product2.Family,
            Product2.Name
            FROM 
            OrderItem 
            WHERE OrderId = :orderId
            AND Product2.Family = 'VAS Fatturabili'
            WITH SECURITY_ENFORCED
        ];
    }

    public List<OrderItem> getAnalisiConsumi(String parentOrderId, String servicePointId){
        return [
            SELECT 
            OccupantsNumber__c, Surface__c, DwellingType__c,OwnerAC__c 
            FROM 
            OrderItem 
            WHERE Order.ParentOrder__c = :parentOrderId
            AND Order.ServicePoint__c  =:servicePointId
            AND Product2.Family = 'VAS Fatturabili'
            WITH SECURITY_ENFORCED
        ];
    }

    /**
    * @author NTTDATA
    * @description getPromo
    * @param orderId
    * @return List<OrderItem>
    */
    public List<OrderItem> getPromoItems(String parentOrderId, String servicePoint){
        return [
            SELECT 
            Id,
            Product2.Name 
            FROM
            OrderItem
            WHERE  Product2.Family = 'Promozione'
            AND ServicePoint__c =:servicePoint
            AND Order.ProcessType__c like 'Aggiunta Sconti o Bonus VAS%' 
            AND Order.ParentOrder__c =:parentOrderId
            WITH SECURITY_ENFORCED
        ];
    }

    /**
    * @author NTTDATA
    * @description getPromo
    * @param orderId
    * @return List<OrderItem>
    */
    public OrderItem getOfferActivationItem(String parentOrderId, String servicePoint){
        return [
            SELECT 
            Id,
            Product2.Name,
            Product2.ProductCode,
            Product2.Version__c
            FROM
            OrderItem
            WHERE  Product2.Family = 'Offerta commerciale'
            AND Order.ServicePoint__c =:servicePoint 
            AND Order.ParentOrder__c =:parentOrderId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
    }
    
    public static List<OrderItem> getItemFromOrderIdList(List<String> ordIdList){

        List<OrderItem> ordItemList = new List<OrderItem>();
        ordItemList = [SELECT Id, OrderId, Product2.CancelableQC__c FROM OrderItem WHERE OrderId IN :ordIdList WITH SECURITY_ENFORCED];
        return ordItemList;
    }
}