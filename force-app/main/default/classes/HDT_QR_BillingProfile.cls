/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 23/11/2020
* @description HDT_QR_BillingProfile – Contains queries for BillingProfile
* @history Keltin Mesonjesi – 23/11/2020 – Created class
*/
public inherited sharing class HDT_QR_BillingProfile {
    
    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Get record by Id
     * @param String billingProfileId
     * @return BillingProfile__c
     */
    public BillingProfile__c getRecordById(String billingProfileId){

        return [
            SELECT
            PaymentMethod__c,
            BillSendingMethod__c,
            InvoiceEmailAddress__c,
            InvoiceCertifiedEmailAddress__c,
            SendCertifiedEmailConsentDate__c,
            DivergentSubject__c,
            CreateContractAccount__c,
            XMLType__c,
            IbanIsForeign__c,
            IBAN__c,
            IbanCIN_IBAN__c,
            IbanCIN__c,
            IbanABI__c,
            IbanCAB__c,
            IbanCodeNumber__c,
            ElectronicInvoicingMethod__c,
            SubjectCode__c,
            SubjectCodeStartDate__c,
            SubjectCodeEndDate__c,
            CIG__c,
            CUP__c,
            SignatoryType__c,
            OtherPayer__c,
            LegalAgent__c,
            BankAccountSignatoryFiscalCode__c,
            BankAccountSignatoryFirstName__c,
            BankAccountSignatoryLastName__c,
            InvoicingStreetName__c,
            InvoicingCity__c,
            InvoicingPostalCode__c,
            InvoicingCountry__c,
            InvoicingProvince__c,
            InvoicingStreetNumberExtension__c,
            InvoicingStreetNumber__c,
            InvoicingCityCode__c,
            IbanCountry__c,
            AccountClass__c,
            ContractAccountCode__c
            FROM BillingProfile__c
            WHERE Id = :billingProfileId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Get records related to account
     * @param String accountId
     * @return List<BillingProfile__c>
     */
    public List<BillingProfile__c> getRecordsByAccount(String accountId){

        return [
            SELECT
            Name,
            PaymentMethod__c,
            InvoicingAddressFormula__c,
            PaymentConditions__c,
            BillSendingMethod__c,
            IBAN__c,
            InvoiceEmailAddress__c,
            InvoicingCity__c,
            IsThirtyDaysDue__c,
            CompanyOwner__c,
            IbanABI__c,
            IbanCAB__c,
            IbanCIN_IBAN__c,
            IbanCIN__c,
            IbanCodeNumber__c,
            IbanCountry__c,
            IbanIsForeign__c,
            InvoicingStreetName__c,
            InvoicingStreetNumber__c,
            InvoicingStreetNumberExtension__c,
            InvoicingPlace__c,
            InvoicingProvince__c,
            InvoicingPostalCode__c,
            InvoicingCountry__c
            FROM BillingProfile__c
            WHERE Account__c = :accountId
            WITH SECURITY_ENFORCED
        ];
    }

    // INIZIO SVILUPPI EVERIS

    public BillingProfile__c getRecordByContractAccount(String contractAccount) {

        List<BillingProfile__c> records = [
            SELECT
            Id,
            InvoicingPlace__c, 
            InvoicingPostalCode__c, 
            InvoicingCity__c, 
            InvoicingStreetNumber__c, 
            InvoicingCountry__c, 
            //InvoicingStreetToponym__c, 
            InvoicingStreetName__c, 
            InvoicingStreetNumberExtension__c	,
            InvoicingProvince__c,
            BankAccountSignatoryLastName__c
            FROM BillingProfile__c
            WHERE ContractAccountCode__c = :contractAccount
            WITH SECURITY_ENFORCED
        ];

        if (records.size() > 0) {
            return records[0];
        }

        return null;
    }

    public BillingProfile__c getRecordByIdVolturaSol(Id billingProfileId) {
        return [
                SELECT
                        Id,
                        InvoicingPlace__c,
                        InvoicingPostalCode__c,
                        InvoicingCity__c,
                        InvoicingStreetNumber__c,
                        InvoicingCountry__c,
                        InvoicingStreetName__c,
                        InvoicingStreetNumberExtension__c,
                        InvoicingProvince__c,
                        BankAccountSignatoryLastName__c,
                        ContractAccountCode__c,
                        BillSendingMethod__c,
                        InvoiceEmailAddress__c,
                        InvoiceCertifiedEmailAddress__c,
                        SendCertifiedEmailConsentDate__c,
                        DivergentSubject__c,
                        InvoicingCityCode__c
                FROM BillingProfile__c
                WHERE Id=:billingProfileId
                WITH SECURITY_ENFORCED
        ];
    }

    public BillingProfile__c getNewestByAccountId(String accountId){
        List<BillingProfile__c> bpList = [
                SELECT
                        Id,
                        InvoicingPlace__c,
                        InvoicingPostalCode__c,
                        InvoicingCity__c,
                        InvoicingStreetNumber__c,
                        InvoicingCountry__c,
                        InvoicingStreetName__c,
                        InvoicingStreetNumberExtension__c,
                        InvoicingProvince__c,
                        BankAccountSignatoryLastName__c,
                        ContractAccountCode__c,
                        BillSendingMethod__c,
                        InvoiceEmailAddress__c,
                        InvoiceCertifiedEmailAddress__c,
                        SendCertifiedEmailConsentDate__c,
                        DivergentSubject__c,
                        InvoicingCityCode__c
                FROM BillingProfile__c
                WHERE Account__c=:accountId
                WITH SECURITY_ENFORCED
                ORDER BY CreatedDate DESC
                LIMIT 1
        ];
        if(bpList.isEmpty()){
           return null; 
        }else {
            return bpList[0];
        }
    }

    public List<BillingProfile__c> getRecordByContractAccount(Set<String> contractAccounts) {

        return [
                SELECT
                        Id,
                        InvoicingPlace__c,
                        InvoicingPostalCode__c,
                        InvoicingCity__c,
                        InvoicingStreetNumber__c,
                        InvoicingCountry__c,
                        //InvoicingStreetToponym__c,
                        InvoicingStreetName__c,
                        InvoicingStreetNumberExtension__c,
                        InvoicingProvince__c,
                        BankAccountSignatoryLastName__c,
                        ContractAccountCode__c
                FROM BillingProfile__c
                WHERE ContractAccountCode__c IN :contractAccounts
                WITH SECURITY_ENFORCED
        ];
    }
    // FINE SVILUPPI EVERIS

}