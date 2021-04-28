/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 27/11/2020
* @description Apex controller for hdtBillingProfileForm.js component
* @history Keltin Mesonjesi – 27/11/2020 – Created class
*/

public inherited sharing class HDT_LC_BillingProfileForm {

    private static HDT_SRV_BillingProfile billingProfileSrv = new HDT_SRV_BillingProfile();
    private static HDT_QR_BillingProfile billingProfileQr = new HDT_QR_BillingProfile();
    private static HDT_SRV_Account accountSrv = new HDT_SRV_Account();
    private static HDT_QR_Account accountQr = new HDT_QR_Account();
    private static HDT_SRV_Contact contactSrv = new HDT_SRV_Contact();
    private static HDT_QR_Contact contactQr = new HDT_QR_Contact();

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @date 27/11/2020
     * @description Get form fields based on selected payment method
     * @param String paymentMethod
     * @return Map<String,Set<String>>
     */
    @AuraEnabled
    public static Map<String,List<String>> getFormFields(String paymentMethod, String accountId){
        
        Map<String,List<String>> resultMap = new Map<String,List<String>>();

        List<String> bollettionoPostale = new List<String>{
            'BillSendingMethod__c',
            'InvoiceEmailAddress__c',
            'InvoiceCertifiedEmailAddress__c',
            'SendCertifiedEmailConsentDate__c',
            'DivergentSubject__c',
            'CreateContractAccount__c'
        };

        List<String> rid = new List<String>{
            'BillSendingMethod__c',
            'XMLType__c',
            'InvoiceEmailAddress__c',
            'InvoiceCertifiedEmailAddress__c',
            'SendCertifiedEmailConsentDate__c',
            'CreateContractAccount__c',
            'IbanIsForeign__c',
            'IBAN__c',
            'IbanCountry__c',
            'IbanCIN_IBAN__c',
            'IbanCIN__c',
            'IbanABI__c',
            'IbanCAB__c',
            'IbanCodeNumber__c'
        };

        List<String> fatturazioneElettronica = new List<String>{
            'ElectronicInvoicingMethod__c',
            'SubjectCode__c',
            'SubjectCodeStartDate__c',
            'SubjectCodeEndDate__c',
            'CIG__c',
            'CUP__c'
        };

        List<String> tipologiaIntestatario = new List<String>{
            'SignatoryType__c',
            'OtherPayer__c',
            'LegalAgent__c',
            'BankAccountSignatoryFiscalCode__c',
            'BankAccountSignatoryFirstName__c',
            'BankAccountSignatoryLastName__c'
        };

        List<String> fieldsToCheck = new List<String>();
        fieldsToCheck.addAll(bollettionoPostale);
        fieldsToCheck.addAll(rid);
        fieldsToCheck.addAll(fatturazioneElettronica);
        fieldsToCheck.addAll(tipologiaIntestatario);
        billingProfileSRV.checkReadAccess(String.join(fieldsToCheck,','));

        switch on paymentMethod {
            when  'Bollettino'{
                resultMap.put('choosenFields', bollettionoPostale);
            }
            when 'RID' {
                resultMap.put('choosenFields', rid);
                resultMap.put('tipologiaIntestatario', tipologiaIntestatario);
            }
        }

        accountSrv.checkReadAccess('RecordType.DeveloperName');
        Account currentAccount = accountQr.getRecordById(accountId, 'RecordType.DeveloperName ');
        if (currentAccount.RecordType.DeveloperName  == 'HDT_RT_Business') {
            resultMap.put('fatturazioneElettronica', fatturazioneElettronica);
        }

        return resultMap;

    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Create BillingProfile__C record
     * @param BillingProfile__c
     * @return BillingProfile__c
     */
    @AuraEnabled
    public static BillingProfile__c createBillingProfile(BillingProfile__c billingProfile){
        return billingProfileSrv.createRecord(billingProfile);
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Get Owner info when 'Stesso Sottoscrittore' is selected in 'SignatoryType__c' or 'OtherPayer__c'
     * @param String accountId
     * @return Account
     */
    @AuraEnabled
    public static Account getAccountOwnerInfo(String accountId){
        accountSrv.checkReadAccess('FirstName__c,LastName__c,FiscalCode__c');
        return accountQr.getRecordById(accountId, 'FirstName__c,LastName__c,FiscalCode__c');
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Get contact info when 'Legale Rapresentante' is selected in 'SignatoryType__c'
     * @param String contactId
     * @return Contact
     */
    @AuraEnabled
    public static Contact getLegalAccount(String contactId){
        contactSrv.checkReadAccess('FirstName,LastName,FiscalCode__c');
        return contactQr.getRecordById(contactId);
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Get Billing Profile clone
     * @param String billingProfileId
     * @return BillingProfile__c
     */
    @AuraEnabled
    public static BillingProfile__c getCloneBillingProfile(String billingProfileId){
        return billingProfileQr.getRecordById(billingProfileId);
    }
}
