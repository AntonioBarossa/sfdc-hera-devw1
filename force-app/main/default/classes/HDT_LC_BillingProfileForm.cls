/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 27/11/2020
* @description Apex controller for hdtBillingProfileForm.js component
* @history Keltin Mesonjesi – 27/11/2020 – Created class
*/

public inherited sharing class HDT_LC_BillingProfileForm {

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @date 27/11/2020
     * @description Get form fields based on selected payment method
     * @param String paymentMethod
     * @return List<String>
     */
    @AuraEnabled
    public static List<String> getFormFields(String paymentMethod){
        
        List<String> result = new List<String>();

        List<String> bollettionoPostale = new List<String>{
            'InvoiceEmailAddress__c',
            'InvoiceCertifiedEmailAddress__c'
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

        switch on paymentMethod {
            when  'Bollettino postale'{
                result = bollettionoPostale;
            }
            when 'RID' {
                result = rid;
            }
        }

        return result;

    }

}
