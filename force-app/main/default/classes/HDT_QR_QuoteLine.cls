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


    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description Get records related to SBQQ__Quote__c.Vendita__c and filtered by Modalit_di_pagamento__c
    * @param String saleId – Sale__c.Id
    * @param String paymentMethod
    * @return List<SBQQ__QuoteLine__c>
    */
    public List<SBQQ__QuoteLine__c> getRecordsBySaleFilteredPaymentMethod(String saleId, String paymentMethod){

        return [
            SELECT
            Id,
            Name,
            SBQQ__Product__r.Name,
            SBQQ__Quote__r.Name,
            SBQQ__Quote__r.SBQQ__Opportunity2__r.Name
            FROM SBQQ__QuoteLine__c
            WHERE SBQQ__Quote__r.Vendita__c = :saleId
            AND Modalit_di_pagamento__c = :paymentMethod
            WITH SECURITY_ENFORCED
        ];
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description Get records related to SBQQ__Quote__c.Vendita__c and filtered by Modalit_di_pagamento__c not null
    * @param String saleId – Sale__c.Id
    * @param String paymentMethod
    * @return List<SBQQ__QuoteLine__c>
    */
    public List<SBQQ__QuoteLine__c> getRecordsBySaleFilteredPaymentMethodNotNull(String saleId){

        return [
            SELECT
            Id,
            Name,
            Billing_Profile__c,
            SBQQ__Quote__c
            FROM SBQQ__QuoteLine__c
            WHERE SBQQ__Quote__r.Vendita__c = :saleId
            AND Modalit_di_pagamento__c != null
            WITH SECURITY_ENFORCED
        ];
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description Get records related to SBQQ__Quote__c.Vendita__c and filtered by SBQQ__RequiredBy__c
    * @param String saleId – Sale__c.Id
    * @param List<String> listIdToQuery
    * @return List<SBQQ__QuoteLine__c>
    */
    public List<SBQQ__QuoteLine__c> getRecordsBySaleFilteredByRequired(String saleId, List<String> listIdToQuery){
        return [
            SELECT
             Id,
             SBQQ__Product__r.Name,
             SBQQ__Quote__c,
             Name,
             SBQQ__Number__c,
             SBQQ__RequiredBy__c 
             FROM SBQQ__QuoteLine__c
             WHERE SBQQ__Quote__r.Vendita__c = :saleId 
             AND SBQQ__RequiredBy__c IN :listIdToQuery
             WITH SECURITY_ENFORCED
        ];
    }
}
