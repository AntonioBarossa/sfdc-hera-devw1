/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 27/11/2020
* @description Apex controller for hdtBillingProfileForm.js component
* @history Keltin Mesonjesi – 27/11/2020 – Created class
*/

public inherited sharing class HDT_LC_BillingProfileForm {

    private static HDT_SRV_BillingProfile billingProfileSRV = new HDT_SRV_BillingProfile();
    private static HDT_SRV_Account accountSRV = new HDT_SRV_Account();
    private static HDT_QR_Account accountQR = new HDT_QR_Account();

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @date 27/11/2020
     * @description Get form fields based on selected payment method
     * @param String paymentMethod
     * @return List<String>
     */
    @AuraEnabled
    public static List<String> getFormFields(String paymentMethod, String accountId){
        
        List<String> result = new List<String>();

        List<String> bollettionoPostale = new List<String>{
            'InvoiceEmailAddress__c',
            'InvoiceCertifiedEmailAddress__c',
            'BillSendingMethod__c'
        };

        List<String> rid = new List<String>{
            'InvoiceEmailAddress__c',
            'InvoiceCertifiedEmailAddress__c',
            'IbanIsForeign__c',
            'IbanCIN__c',
            'IbanABI__c',
            'IbanCAB__c',
            'IbanCodeNumber__c',
            'SignatoryType__c',
            'OtherPayer_c__c',
            'BankAccountSignatoryFiscalCode__c',
            'BankAccountSignatoryFirstName__c',
            'BankAccountSignatoryLastName__c'
        };

        List<String> fatturazioneElettronica = new List<String>{
            'BillSendingMethod__c',
            'SubjectCode__c',
            'InvoiceCertifiedEmailAddress__c',
            'SubjectCodeStartDate__c',
            'SubjectCodeEndDate__c'
        };

        List<String> fieldsToCheck = new List<String>();
        fieldsToCheck.addAll(bollettionoPostale);
        fieldsToCheck.addAll(rid);
        fieldsToCheck.addAll(fatturazioneElettronica);
        billingProfileSRV.checkReadAccess(String.join(fieldsToCheck,','));

        switch on paymentMethod {
            when  'Bollettino postale'{
                result = bollettionoPostale;
            }
            when 'RID' {
                result = rid;
            }
        }

        accountSRV.checkReadAccess('RecordType.Name');
        Account currentAccount = accountQR.getRecordById(accountId, 'RecordType.Name');
        if (currentAccount.RecordType.Name == 'Business') {
            result.addAll(fatturazioneElettronica);
        }

        return result;

    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Create BillingProfile__C record
     * @param BillingProfile__c
     * @return BillingProfile__c
     */
    @AuraEnabled
    public static BillingProfile__c createBillingProfile(BillingProfile__c billingProfile){
        return billingProfileSRV.createRecord(billingProfile);
    }

}
