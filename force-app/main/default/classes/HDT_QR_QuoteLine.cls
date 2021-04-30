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
            ServicePoint__c,
            ServicePoint__r.ServicePointCode__c,
            BillingProfile__c,
            BillingProfile__r.Name,
            SBQQ__Product__r.Name,
            SBQQ__Quote__r.Name,
            SBQQ__Quote__r.SBQQ__Opportunity2__r.Name,
            SBQQ__RequiredBy__c,
            SBQQ__RequiredBy__r.SBQQ__RequiredBy__c,
            SBQQ__RequiredBy__r.BillingProfile__c
            FROM SBQQ__QuoteLine__c
            WHERE SBQQ__Quote__r.Sale__c = :saleId
            AND SBQQ__Quote__r.SBQQ__Status__c NOT IN ('Cancelled','Rejected')
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
            SBQQ__RequiredBy__c,
            SBQQ__RequiredBy__r.Name,
            ServicePoint__c,
            ServicePoint__r.ServicePointCode__c,
            SBQQ__RequiredBy__r.SBQQ__Product__r.Name,
            SBQQ__Quote__r.Name,
            SBQQ__Quote__r.SBQQ__Opportunity2__r.Name,
            SBQQ__RequiredBy__r.BillingProfile__c,
            SBQQ__RequiredBy__r.BillingProfile__r.Name
            FROM SBQQ__QuoteLine__c
            WHERE SBQQ__Quote__r.Sale__c = :saleId
            AND SBQQ__Product__r.Name IN ('POD', 'PDR')
            AND SBQQ__RequiredBy__r.PaymentMode__c = :paymentMethod
            AND SBQQ__Quote__r.SBQQ__Status__c NOT IN ('Cancelled','Rejected')
            WITH SECURITY_ENFORCED
        ];
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description Get records related to SBQQ__Quote__c.Vendita__c and filtered by Modalit_di_pagamento__c that have no ContractReference__c or OrderReference__c
    * @param String saleId – Sale__c.Id
    * @param String paymentMethod
    * @return List<SBQQ__QuoteLine__c>
    */
    public List<SBQQ__QuoteLine__c> getRecordsBySaleFilteredPaymentMethodPodPdr(String saleId, String paymentMethod){

        return [
            SELECT
            Id,
            SBQQ__RequiredBy__c,
            SBQQ__RequiredBy__r.Name,
            ServicePoint__c,
            ServicePoint__r.ServicePointCode__c,
            SBQQ__RequiredBy__r.SBQQ__Product__r.Name,
            SBQQ__Quote__r.Name,
            SBQQ__Quote__r.SBQQ__Opportunity2__r.Name,
            SBQQ__RequiredBy__r.BillingProfile__c,
            SBQQ__RequiredBy__r.BillingProfile__r.Name
            FROM SBQQ__QuoteLine__c
            WHERE SBQQ__Quote__r.Sale__c = :saleId
            // AND SBQQ__Quote__r.ContractReference__c = null
            // AND SBQQ__Quote__r.OrderReference__c = null
            // AND (SBQQ__Product__r.Name IN ('POD', 'PDR') OR ((SBQQ__ProductFamily__c = 'VAS Opzione prodotto' OR SBQQ__ProductFamily__c	= 'VAS prodotto') AND SBQQ__Number__c = 2))
            AND SBQQ__Product__r.Name IN ('POD', 'PDR')
            AND SBQQ__RequiredBy__r.PaymentMode__c = :paymentMethod
            AND SBQQ__Quote__r.SBQQ__Status__c NOT IN ('Cancelled','Rejected')
            WITH SECURITY_ENFORCED
        ];
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description Get records related to SBQQ__Quote__c.Vendita__c and filtered by Modalit_di_pagamento__c that have no ContractReference__c or OrderReference__c
    * @param String saleId – Sale__c.Id
    * @param String paymentMethod
    * @return List<SBQQ__QuoteLine__c>
    */
    public List<SBQQ__QuoteLine__c> getRecordsBySaleFilteredPaymentMethodforVas(String saleId, String paymentMethod){

        return [
            SELECT
            Id,
            SBQQ__RequiredBy__c,
            Name,
            ServicePoint__c,
            ServicePoint__r.ServicePointCode__c,
            SBQQ__Product__r.Name,
            SBQQ__Quote__r.Name,
            SBQQ__Quote__r.SBQQ__Opportunity2__r.Name,
            BillingProfile__c,
            BillingProfile__r.Name
            FROM SBQQ__QuoteLine__c
            WHERE SBQQ__Quote__r.Sale__c = :saleId
            AND SBQQ__Quote__r.ContractReference__c = null
            AND SBQQ__Quote__r.OrderReference__c = null
            AND (SBQQ__ProductFamily__c = 'VAS Fatturabili' OR SBQQ__ProductFamily__c = 'VAS Prodotto')
            AND PaymentMode__c = :paymentMethod
            AND SBQQ__Quote__r.SBQQ__Status__c NOT IN ('Cancelled','Rejected')
            WITH SECURITY_ENFORCED
        ];
    }

    public List<SBQQ__QuoteLine__c> getChildAnalisi(List<String> mainQuoteLineId){

        return [
            SELECT
            Id,
            BillingProfile__c,
            SBQQ__RequiredBy__r.BillingProfile__c
            FROM SBQQ__QuoteLine__c
            WHERE SBQQ__RequiredBy__c = :mainQuoteLineId
            AND SBQQ__ProductFamily__c = 'VAS Fatturabili'
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
            BillingProfile__c,
            SBQQ__Quote__c
            FROM SBQQ__QuoteLine__c
            WHERE SBQQ__Quote__r.Sale__c = :saleId
            // AND PaymentMode__c != null
            AND SBQQ__Quote__r.SBQQ__Status__c NOT IN ('Cancelled','Rejected')
            WITH SECURITY_ENFORCED
        ];
    }

    public List<SBQQ__QuoteLine__c> getRecordsBySaleForBillingCheck(String saleId){

        return [
            SELECT
            Id,
            Name,
            BillingProfile__c,
            SBQQ__Quote__c
            FROM SBQQ__QuoteLine__c
            WHERE SBQQ__Quote__r.Sale__c = :saleId
            AND PaymentMode__c != null
            AND SBQQ__Quote__r.SBQQ__Status__c NOT IN ('Cancelled','Rejected')
            WITH SECURITY_ENFORCED
        ];
    }

    public List<SBQQ__QuoteLine__c> getRecordsByQuoteFilteredPaymentMethodNotNull(String quoteId){

        return [
            SELECT
            Id,
            Name,
            BillingProfile__c,
            SBQQ__Quote__c
            FROM SBQQ__QuoteLine__c
            WHERE SBQQ__Quote__c = :quoteId
            AND PaymentMode__c != null
            AND SBQQ__Quote__r.SBQQ__Status__c NOT IN ('Cancelled','Rejected')
            WITH SECURITY_ENFORCED
        ];
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description Get records related to SBQQ__Quote__c.Vendita__c and filtered by Modalit_di_pagamento__c not null
    * @param String contractId – SBQQ__Quote__r.ContractReference__c
    * @param String paymentMethod
    * @return List<SBQQ__QuoteLine__c>
    */
    public List<SBQQ__QuoteLine__c> getRecordsByContractFilteredPaymentMethodNotNull(String contractId, String saleId){

        return [
            SELECT
            Id,
            Name,
            BillingProfile__c,
            SBQQ__Quote__c
            FROM SBQQ__QuoteLine__c
            WHERE SBQQ__Quote__r.ContractReference__c = :contractId
            AND PaymentMode__c != null
            AND SBQQ__Quote__r.Sale__c = :saleId
            AND SBQQ__Quote__r.SBQQ__Status__c NOT IN ('Cancelled','Rejected')
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
             BillingProfile__c,
             Name,
             SBQQ__Number__c,
             SBQQ__RequiredBy__c,
             SBQQ__RequiredBy__r.BillingProfile__c,
             SBQQ__RequiredBy__r.SBQQ__RequiredBy__c 
             FROM SBQQ__QuoteLine__c
             WHERE SBQQ__Quote__r.Sale__c = :saleId 
             AND SBQQ__RequiredBy__c IN :listIdToQuery
             WITH SECURITY_ENFORCED
        ];
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 17/11/2020
    * @description Get records by quoteId and Product.Name "POD"
    * @param String quoteId - SBQQ__Quote__c
    * @return List<SBQQ__QuoteLine__c>
    */
    public List<SBQQ__QuoteLine__c> getRecordsByQuoteIdAndProductPod(String quoteId){

        return [
            SELECT
            Id,
            Name,
            SBQQ__Product__r.Name,
            SBQQ__Product__r.ProductCode,
            SBQQ__Product__r.Version__c,
            SBQQ__Quote__r.Name,
            SBQQ__Quote__r.SBQQ__Opportunity2__r.Name,
            ServicePoint__c
            FROM SBQQ__QuoteLine__c
            WHERE SBQQ__Quote__c = :quoteId
            AND SBQQ__Product__r.Name IN ('POD','PDR')
            WITH SECURITY_ENFORCED
        ];

    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 26/04/2021
    * @description Get primary quoteLine
    * @param String quoteId - SBQQ__Quote__c
    * @return List<SBQQ__QuoteLine__c>
    */
    public List<SBQQ__QuoteLine__c> getPrimaryRecord(String quoteId){

        return [
            SELECT
            Id,
            SBQQ__Product__r.Name,
            SBQQ__Product__r.ProductCode,
            SBQQ__Product__r.Version__c
            FROM SBQQ__QuoteLine__c
            WHERE SBQQ__Quote__c = :quoteId
            AND SBQQ__RequiredBy__c = null
            WITH SECURITY_ENFORCED
        ];

    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 25/03/2021
    * @description Get records by quoteId
    * @param String quoteId - SBQQ__Quote__c
    * @return List<SBQQ__QuoteLine__c>
    */
    public List<SBQQ__QuoteLine__c> getRecordsByQuoteId(String quoteId){

        return [
            SELECT
            Id,
            Name,
            SBQQ__Product__r.Name,
            SBQQ__Quote__r.Name,
            SBQQ__Quote__r.SBQQ__Opportunity2__r.Name,
            ServicePoint__c
            FROM SBQQ__QuoteLine__c
            WHERE SBQQ__Quote__c = :quoteId
            WITH SECURITY_ENFORCED
        ];

    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 17/11/2020
    * @description Get records by quoteId and Product.Name "POD"
    * @param String contractId - SBQQ__Quote__r.ContractReference__c
    * @return List<SBQQ__QuoteLine__c>
    */
    public List<SBQQ__QuoteLine__c> getRecordsByContractAndProductPod(String contractId, String saleId){

        return [
            SELECT
            Id,
            Name,
            SBQQ__Product__r.Name,
            SBQQ__Quote__r.Name,
            SBQQ__Quote__r.SBQQ__Opportunity2__r.Name,
            ServicePoint__c
            FROM SBQQ__QuoteLine__c
            WHERE SBQQ__Quote__r.ContractReference__c = :contractId
            AND SBQQ__Quote__r.Sale__c = :saleId
            AND SBQQ__Product__r.Name IN ('POD','PDR')
            AND SBQQ__Quote__r.SBQQ__Status__c NOT IN ('Cancelled','Rejected')
            WITH SECURITY_ENFORCED
        ];

    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 17/11/2020
    * @description Get records by saleId and Product.Name "POD"
    * @param String saleId - Sale__c
    * @return List<SBQQ__QuoteLine__c>
    */
    public List<SBQQ__QuoteLine__c> getActiveRecordsBySaleIdAndProductPod(String saleId){

        return [
            SELECT
            Id,
            Name,
            SBQQ__Product__r.Name,
            SBQQ__Quote__r.Name,
            SBQQ__Quote__r.SBQQ__Opportunity2__r.Name,
            ServicePoint__c,
            ServicePoint__r.ServicePointCode__c
            FROM SBQQ__QuoteLine__c
            WHERE SBQQ__Quote__r.Sale__c = :saleId
            AND SBQQ__Quote__r.SBQQ__Status__c NOT IN ('Cancelled','Rejected')
            AND SBQQ__Product__r.Name IN ('POD','PDR')
            WITH SECURITY_ENFORCED
        ];

    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 02/02/2021
    * @description Get records that are displayed on "Configura Prodotti" section of Selling Wizard
    * @param String saleId - Sale__c
    * @return List<SBQQ__QuoteLine__c>
    */
    public List<SBQQ__QuoteLine__c> getActiveRecords(String saleId){
        return [
            SELECT
            Id,
            Name,
            SBQQ__Product__r.Name,
            SBQQ__Quote__c,
            SBQQ__Quote__r.Name,
            SBQQ__Quote__r.SBQQ__Opportunity2__r.Name,
            ServicePoint__c
            FROM SBQQ__QuoteLine__c
            WHERE SBQQ__Quote__r.Sale__c = :saleId
            AND SBQQ__Quote__r.SBQQ__Status__c NOT IN ('Cancelled','Rejected')
            WITH SECURITY_ENFORCED
        ];
    }
}
