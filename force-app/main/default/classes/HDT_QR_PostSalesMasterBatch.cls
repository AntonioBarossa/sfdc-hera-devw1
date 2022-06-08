/*
    @Author:        Francesco Vitiello
    CreatedDate:    12/11/2021
    Reason: Modifiche per gestione Annullamento Case con Phase "In Bozza", Case con Type "Blocco Sollecito/Interessi"
*/
public inherited sharing class HDT_QR_PostSalesMasterBatch {

    Date todayDate = System.today();
    String phaseInstallments = 'Pratica In Attesa';
    String typeInstallments = 'Piano Rateizzazione';
    String dunningBlock = 'Blocco Sollecito/Interessi';
    Set<String> typeSet = new Set<String>{typeInstallments,dunningBlock};
    String nonRequestedContract = 'Contratto Non Richiesto';
    String phaseQuotations = 'Attesa conferma preventivo cliente';
    String bozzaCase = 'Bozza';
    String autoletturaCase = 'Autolettura';

    public List<Knowledge__kav> getExpiredArticle(){

        return [SELECT Id,
        KnowledgeArticleId,
        ExpirationDate__c
        FROM Knowledge__kav
        WHERE ExpirationDate__c < :this.todayDate
        AND PublishStatus = 'Online'
        WITH SECURITY_ENFORCED
        ];

    }


    public List<Case> getExpiredCase(){

        return [SELECT Id,
        Phase__c,
        Type,
        Cluster__c,
        DepositPaymentMode__c,
        SuspensionEndDate__c
        FROM Case
        WHERE Phase__c = :this.phaseInstallments
        AND Type IN :this.typeSet
        AND SuspensionEndDate__c <= :this.todayDate
        WITH SECURITY_ENFORCED
        ];

    }

    public List<Case> getNonReqContract(){
        return [SELECT Id,
        Phase__c,
        EffectiveDate__c,
        Type,
        Cluster__c,
        Order__c
        FROM Case
        WHERE Type = :this.nonRequestedContract
        AND Phase__c = : this.phaseInstallments
        WITH SECURITY_ENFORCED
        ];
    }

    public Order getRelatedOrder(String orderId){
        return [SELECT Id,
        EffectiveDate__c
        FROM Order
        WHERE Id = :orderId
        WITH SECURITY_ENFORCED
        LIMIT 1];
    }

    public List<Case> getQuotationCase(){
        
        return [SELECT Id,
        Phase__c,
        Type,
        Cluster__c,
        QuotationType__c,
        QuotationValidityDate__c
        FROM Case
        WHERE QuotationValidityDate__c < :this.todayDate
        AND Phase__c = :this.phaseQuotations
        WITH SECURITY_ENFORCED];

    }

    public List<Case> getAutoletturaBozzaCase(){
        return [SELECT Id,
        Type,
        Phase__c,
        Cluster__c,        
        CreatedDate,
        DepositPaymentMode__c,
        SuspensionEndDate__c,
        EffectiveDate__c,
        Order__c,
        QuotationType__c,
        QuotationValidityDate__c
        FROM Case
        WHERE Phase__c = :this.bozzaCase
        AND Cluster__c = : this.autoletturaCase
        WITH SECURITY_ENFORCED
        ];
    }

    public List<Case> getSegnalazioniBozzaCase(){
        Id processTypeId = (new Case()).getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_RT_Segnalazioni').getRecordTypeId();
        CS_DaysToExpiration__c cs = CS_DaysToExpiration__c.getInstance('Segnalazioni_Ambiente');
        Integer strNumberOfDays = integer.valueof(STRING.isBlank(cs?.NumberOfDays__c)? '0' : cs.NumberOfDays__c);
        strNumberOfDays=-strNumberOfDays;
        Date d = Date.today().addDays(strNumberOfDays);
        return [SELECT 
            Id,
            Type,
            Phase__c,
            Cluster__c
            FROM Case
            WHERE 
            RecordTypeId = :processTypeId
            AND Phase__c = :this.bozzaCase
            AND Type ='Segnalazioni Ambientali'
            AND CreatedDate < :d
            WITH SECURITY_ENFORCED
        ];
    }

    public List<Case> getRifiutiBozzaCase(){
        Id processTypeId = (new Case()).getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_RT_Segnalazioni').getRecordTypeId();
        CS_DaysToExpiration__c cs = CS_DaysToExpiration__c.getInstance('Gestione_Rifiuti');
        Integer strNumberOfDays = integer.valueof(STRING.isBlank(cs?.NumberOfDays__c)? '0' : cs.NumberOfDays__c);
        strNumberOfDays=-strNumberOfDays;
        Date d = Date.today().addDays(strNumberOfDays);
        return [SELECT 
            Id,
            Type,
            Phase__c,
            Cluster__c
            FROM Case
            WHERE 
            RecordTypeId = :processTypeId
            AND (
                ( Phase__c = :this.bozzaCase AND CreatedDate < :d) 
                OR ( Phase__c ='Inviata a SAP' AND StartAppointment__c!=null AND StartAppointment__c < TODAY)
            )
            WITH SECURITY_ENFORCED
        ];
    }

    public List<Case> getPostSalesBozzaCase(){
        Id segnalazioniRtId = (new Case()).getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_RT_Segnalazioni').getRecordTypeId();
        return [SELECT Id,
        Type,
        Phase__c,
        Cluster__c,
        CreatedDate,
        DepositPaymentMode__c,
        SuspensionEndDate__c,
        EffectiveDate__c,
        Order__c,
        QuotationType__c,
        QuotationValidityDate__c
        FROM Case
        WHERE Phase__c = :this.bozzaCase
        AND Cluster__c != : this.autoletturaCase
        AND RecordTypeId != :segnalazioniRtId
        WITH SECURITY_ENFORCED
        ];
    }

    public List<Case> getCaseVolturaTecnica(){
        
        return [SELECT Id,
        AccountId,
        Cluster__c,
        CompanyOwner__c,
        ContactId,
        Contract__c,
        CreatorGroup__c,
        DistributorNote__c,
        Origin,
        Order__c,
        Phase__c,
        RecordTypeId,
        ServicePoint__c,
        Station__c,
        Type,
        PhoneNumber__c,
        Email__c,
        SuspensionDays__c,
        EffectiveDate__c,
        SuspensionDate__c,
        BillingProfile__c,
        SupplyCity__c,
        SupplyCityCode__c,
        SupplyCountry__c,
        SupplyPostalCode__c,
        SupplyProvince__c,
        SupplyStreetName__c,
        SupplyStreetNumber__c,
        InvoicingCity__c,
        InvoicingCityCode__c,
        InvoicingCountry__c,
        InvoicingPostalCode__c,
        InvoicingProvince__c,
        InvoicingStreetName__c,
        InvoicingStreetNumber__c,
        BillingCity__c,
        BillingCityCode__c,
        BillingCountry__c,
        BillingPostalCode__c,
        BillingProvince__c,
        BillingStreetName__c,
        BillingStreetNumber__c,
        SalesCompany__c,
        SalesCompanyCode__c,
        DistributorCode__c,
        Taxes__c,
        TaxRate__c,
        Resident__c,
        Market__c,
        SupplyType__c,
        AnnualConsumption__c,
        CaliberAvailable__c,
        CausalCode__c
        FROM Case
        WHERE Type = 'Voltura Tecnica'
        AND Phase__c = 'In attesa Data Decorrenza'
        AND SuspensionDate__c <= :this.todayDate
        WITH SECURITY_ENFORCED
        ];
    }

}