public inherited sharing class HDT_LC_BillingProfileForm {

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
