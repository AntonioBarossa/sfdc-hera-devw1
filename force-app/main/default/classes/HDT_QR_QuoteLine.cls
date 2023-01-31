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
    * @param saleId – Sale__c.Id
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
    * @param saleId – Sale__c.Id
    * @param paymentMethod
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
            AND SBQQ__Product__r.Name IN ('POD', 'PDR','Punto Fornitura Acqua','Punto Fornitura','Punto Fornitura Ambiente')
            AND SBQQ__RequiredBy__r.PaymentMode__c = :paymentMethod
            AND SBQQ__Quote__r.SBQQ__Status__c NOT IN ('Cancelled','Rejected')
            WITH SECURITY_ENFORCED
        ];
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description Get records related to SBQQ__Quote__c.Vendita__c and filtered by Modalit_di_pagamento__c that have no ContractReference__c or OrderReference__c
    * @param saleId – Sale__c.Id
    * @param paymentMethod
    * @param sendingBillMode
    * @return List<SBQQ__QuoteLine__c>
    */
    public List<SBQQ__QuoteLine__c> getRecordsBySaleFilteredPaymentMethodPodPdr(String saleId, String paymentMethod, String sendingBillMode){

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
            AND SBQQ__Product__r.Name IN ('POD', 'PDR','Punto Fornitura Acqua','Punto Fornitura','Punto Fornitura Ambiente')
            AND SBQQ__RequiredBy__r.PaymentMode__c = :paymentMethod
            AND SBQQ__RequiredBy__r.SendingBillMode__c = :sendingBillMode
            AND SBQQ__Quote__r.SBQQ__Status__c NOT IN ('Cancelled','Rejected')
            WITH SECURITY_ENFORCED
        ];
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description Get records related to SBQQ__Quote__c.Vendita__c and filtered by Modalit_di_pagamento__c that have no ContractReference__c or OrderReference__c
    * @param saleId – Sale__c.Id
    * @return List<SBQQ__QuoteLine__c>
    */
    public List<SBQQ__QuoteLine__c> getRecordsBySaleFilteredPaymentMethodforVas(String saleId){

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
            AND (SBQQ__Quote__r.ContractReference__c = null OR SBQQ__Quote__r.OrderReference__c = null)
            AND SBQQ__Product__r.Name != 'Analisi Consumi'
            AND (SBQQ__ProductFamily__c = 'VAS Fatturabili' OR SBQQ__ProductFamily__c = 'VAS Prodotto' OR SBQQ__ProductFamily__c = 'VAS Servizio')
            AND SBQQ__Quote__r.SBQQ__Status__c NOT IN ('Cancelled','Rejected')
            WITH SECURITY_ENFORCED
        ];
    }

    public List<SBQQ__QuoteLine__c> getRecordsBySaleFilteredPaymentMethodforVas(String saleId,Boolean isModal){

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
            AND (SBQQ__Quote__r.ContractReference__c = null OR SBQQ__Quote__r.OrderReference__c = null)
            AND (SBQQ__ProductFamily__c = 'VAS Fatturabili' OR SBQQ__ProductFamily__c = 'VAS Prodotto' OR SBQQ__ProductFamily__c = 'VAS Servizio')
            AND SBQQ__Quote__r.SBQQ__Status__c NOT IN ('Cancelled','Rejected')
            WITH SECURITY_ENFORCED
        ];
    }

    /**
    * @description 
    * @author federico.defelice@webresults.it | 23-09-2021 
    * @param saleId 
    * @return List<SBQQ__QuoteLine__c> 
    **/
    /**@frpanico 2022-03-25
     * La quoteLine di "sconti e bonus"
     * Deve staccare un ordine solo
     * nel caso di VAS Fatturabili
     */
    public List<SBQQ__QuoteLine__c> getRecordsBySaleFilteredFamilyBonus(String saleId){
        Set<String> famils = new Set<String>(); /*HDT_UTL_OrderProcessAssignment.getFamilySconto();*/
        famils.add('VAS Fatturabili');
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
            BillingProfile__r.Name,
            SBQQ__RequiredBy__r.BillingProfile__c
            FROM SBQQ__QuoteLine__c
            WHERE SBQQ__Quote__r.Sale__c = :saleId
            AND SBQQ__ProductFamily__c IN :famils AND SBQQ__RequiredBy__r.SBQQ__ProductFamily__c!='Promozione'
            AND SBQQ__Quote__r.SBQQ__Type__c != 'Amendment'
            WITH SECURITY_ENFORCED
            Order by BillingProfile__c NULLS LAST, Name
        ];
    }

        /**
    * @description 
    * @author federico.defelice@webresults.it | 23-09-2021 
    * @param saleId 
    * @return List<SBQQ__QuoteLine__c> 
    **/
    public List<SBQQ__QuoteLine__c> getRecordsByQuoteFilteredFamilyBonus(String quoteId){
        Set<String> famils = HDT_UTL_OrderProcessAssignment.getFamilySconto();
        famils.remove('Promozione');
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
            WHERE SBQQ__Quote__c = :quoteId
            AND SBQQ__ProductFamily__c IN :famils 
            AND SBQQ__RequiredBy__r.SBQQ__ProductFamily__c!='Promozione'
            AND SBQQ__Quote__r.SBQQ__Type__c != 'Amendment'
            WITH SECURITY_ENFORCED
            Order by BillingProfile__c NULLS LAST, Name
        ];
    }


    public List<SBQQ__QuoteLine__c> getQuoteLineAnalisiConsumi(List<String> mainQuoteLineIds){
        return [
            SELECT
            Id,
            BillingProfile__c,
            SBQQ__RequiredBy__r.BillingProfile__c
            FROM SBQQ__QuoteLine__c
            WHERE SBQQ__RequiredBy__c IN :mainQuoteLineIds
            AND SBQQ__Product__r.Name = 'Analisi Consumi'
            WITH SECURITY_ENFORCED
        ];
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description getChildAnalisi
    * @param mainQuoteLineId
    * @return List<SBQQ__QuoteLine__c>
    */
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
    * @param saleId – Sale__c.Id
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

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description getRecordsBySaleForBillingCheck
    * @param saleId
    * @return List<SBQQ__QuoteLine__c>
    */
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

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description getRecordsByQuoteFilteredPaymentMethodNotNull
    * @param quoteId
    * @return List<SBQQ__QuoteLine__c>
    */
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
    * @description getRecordsForContractOrderRefVas
    * @param quoteId
    * @return List<SBQQ__QuoteLine__c>
    */
    public List<SBQQ__QuoteLine__c> getRecordsForContractOrderRefVas(String quoteId){

        return [
            SELECT
            Id,
            Name,
            BillingProfile__c,
            SBQQ__Quote__c,
            SBQQ__ProductFamily__c
            FROM SBQQ__QuoteLine__c
            WHERE SBQQ__Quote__c = :quoteId
            AND SBQQ__Quote__r.SBQQ__Status__c NOT IN ('Cancelled','Rejected')
            WITH SECURITY_ENFORCED
        ];
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description Get records related to SBQQ__Quote__c.Vendita__c and filtered by Modalit_di_pagamento__c not null
    * @param contractId – SBQQ__Quote__r.ContractReference__c
    * @param saleId
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
    * @param saleId – Sale__c.Id
    * @param listIdToQuery
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
    * @param quoteId - SBQQ__Quote__c
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
            ServicePoint__c,
            SBQQ__RequiredBy__c
            FROM SBQQ__QuoteLine__c
            WHERE SBQQ__Quote__c = :quoteId
            AND SBQQ__Product__r.Name IN ('POD', 'PDR','Punto Fornitura Acqua','Punto Fornitura','Punto Fornitura Ambiente')
            WITH SECURITY_ENFORCED
        ];

    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 26/04/2021
    * @description Get primary quoteLine
    * @param quoteId - SBQQ__Quote__c
    * @return List<SBQQ__QuoteLine__c>
    */
    public List<SBQQ__QuoteLine__c> getPrimaryRecord(String quoteId){

        return [
            SELECT
            Id,
            SBQQ__Product__r.Name,
            SBQQ__Product__r.ProductCode,
            SBQQ__Product__r.Version__c,
            SBQQ__Product__r.ReferenceMarket__c,
            DelayEffectiveDate__c
            FROM SBQQ__QuoteLine__c
            WHERE SBQQ__Quote__c = :quoteId
            AND SBQQ__RequiredBy__c = null
            WITH SECURITY_ENFORCED
        ];

    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 27/09/2021
    * @description Get primary quoteLine list
    * @param quoteIdList - SBQQ__Quote__c
    * @return List<SBQQ__QuoteLine__c>
    */
    public List<SBQQ__QuoteLine__c> getPrimaryRecords(List<String> quoteIdList){

        return [
            SELECT
            Id,
            SBQQ__Product__r.Name,
            SBQQ__Product__r.ProductCode,
            SBQQ__Product__r.Version__c,
            DelayEffectiveDate__c,
            SBQQ__Quote__c
            FROM SBQQ__QuoteLine__c
            WHERE SBQQ__Quote__c IN :quoteIdList
            AND SBQQ__RequiredBy__c = null
            WITH SECURITY_ENFORCED
        ];

    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 25/03/2021
    * @description Get records by quoteId
    * @param quoteId - SBQQ__Quote__c
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
    * @param contractId - SBQQ__Quote__r.ContractReference__c
    * @param saleId
    * @return List<SBQQ__QuoteLine__c>
    */
    public List<SBQQ__QuoteLine__c> getRecordsByContractAndProductPod(String contractId, String saleId){
        Set<String> famils = HDT_UTL_OrderProcessAssignment.getFamilySconto();
        return [
            SELECT
            Id,
            Name,
            SBQQ__Product__r.Name,
            SBQQ__Quote__r.Name,
            SBQQ__Quote__r.SBQQ__Opportunity2__r.Name,
            SBQQ__RequiredBy__c,
            ServicePoint__c
            FROM SBQQ__QuoteLine__c
            WHERE SBQQ__Quote__r.ContractReference__c = :contractId
            AND SBQQ__Quote__r.Sale__c = :saleId
            AND (SBQQ__Product__r.Name IN ('PDR','POD','Punto Fornitura Ambiente','Punto Fornitura Acqua')  OR SBQQ__Product__r.Family IN :famils)
            AND SBQQ__Quote__r.SBQQ__Status__c NOT IN ('Cancelled','Rejected')
            WITH SECURITY_ENFORCED
        ];

    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 17/11/2020
    * @description Get records by saleId and Product.Name "POD"
    * @param saleId - Sale__c
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
            AND SBQQ__Product__r.Name IN ('POD', 'PDR','Punto Fornitura Acqua','Punto Fornitura','Punto Fornitura Ambiente')
            WITH SECURITY_ENFORCED
        ];

    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 02/02/2021
    * @description Get records that are displayed on "Configura Prodotti" section of Selling Wizard
    * @update aggiunto filtro su SBQQ__UpgradedSubscription__c poichè in caso di amend deve estrarre solo le quoteline New
    * @param saleId - Sale__c
    * @return List<SBQQ__QuoteLine__c>
    */
    public List<SBQQ__QuoteLine__c> getActiveRecords(String saleId){
        return [
            SELECT
            Id,
            Name,
            SBQQ__Product__r.Name,
            SBQQ__Product__r.EndDate__c,
            SBQQ__Product__r.Status__c,
            SBQQ__Quote__c,
            SBQQ__Quote__r.Name,
            SBQQ__Quote__r.SBQQ__Opportunity2__r.Name,
            SBQQ__Quote__r.ContractReference__r.Status,
            SBQQ__Quote__r.ContractReference__r.AccountId,
            SBQQ__Quote__r.ContractReference__r.BillingProfile__c,
            SBQQ__Quote__r.ContractReference__r.CommoditySectorFormula__c,
            SBQQ__Quote__r.SBQQ__Account__c,
            SBQQ__RequiredBy__r.BillingProfile__c,
            ServicePoint__r.CommoditySector__c,
            ServicePoint__c,
            BillingProfile__c
            FROM SBQQ__QuoteLine__c
            WHERE SBQQ__Quote__r.Sale__c = :saleId
            AND SBQQ__Quote__r.SBQQ__Status__c NOT IN ('Cancelled','Rejected')
            AND SBQQ__UpgradedSubscription__c = null
            WITH SECURITY_ENFORCED
        ];
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 04/06/2021
    * @description Get linked quotelines
    * @param quoteId - SBQQ__Quote__c
    * @return List<SBQQ__QuoteLine__c>
    */
    public List<SBQQ__QuoteLine__c> getLinkedQuoteLines(String quoteId){

        return [
            SELECT
            Id,
            Name,
            SBQQ__Product__r.Name,
            SBQQ__Product__r.ProductCode,
            SBQQ__Product__r.Version__c,
            SBQQ__Quote__r.Name,
            SBQQ__Quote__r.SBQQ__Opportunity2__r.Name,
            ServicePoint__c,
            ServicePointLinkItem__r.ServicePoint__c
            FROM SBQQ__QuoteLine__c
            WHERE SBQQ__Quote__c = :quoteId
            AND SBQQ__Product__r.Name IN ('POD','PDR')
            AND ServicePointLinkItem__c != null
            WITH SECURITY_ENFORCED
        ];

    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 16/07/2021
    * @description Get quotelines with cambio offerta
    * @param saleId
    * @return List<SBQQ__QuoteLine__c>
    */
    public List<SBQQ__QuoteLine__c> getQuoteLinesWithCambioOfferta(String saleId){

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
            BillingProfile__r.Name,
            SBQQ__Quote__r.ContractReference__c,
            SBQQ__Quote__r.ContractReference__r.BillingProfile__r.Name
            FROM SBQQ__QuoteLine__c
            WHERE SBQQ__Quote__r.Sale__c = :saleId
            AND SBQQ__Quote__r.ContractReference__c != null
            AND (SBQQ__Quote__r.AllowChangeUse__c = null OR SBQQ__Quote__r.AllowChangeUse__c = false)
            AND (SBQQ__Quote__r.AmendmentAllowed__c = null OR SBQQ__Quote__r.AmendmentAllowed__c = false)
            AND SBQQ__Product__r.Name NOT IN ('POD', 'PDR','Punto Fornitura Acqua','Punto Fornitura','Punto Fornitura Ambiente','Analisi Consumi')
            AND (SBQQ__ProductFamily__c = 'VAS Fatturabili' OR SBQQ__ProductFamily__c = 'VAS Prodotto' OR SBQQ__ProductFamily__c = 'VAS Servizio')
            AND SBQQ__Quote__r.SBQQ__Status__c NOT IN ('Cancelled','Rejected')
            WITH SECURITY_ENFORCED
        ];

    }
}