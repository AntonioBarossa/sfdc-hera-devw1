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
        
        Set<String> resultSet = new Set<String>();
        List<String> resultList = new List<String>();

        Set<String> bollettionoPostale = new Set<String>{
            'InvoiceEmailAddress__c',
            'InvoiceCertifiedEmailAddress__c',
            'BillSendingMethod__c'
        };

        Set<String> rid = new Set<String>{
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

        Set<String> fatturazioneElettronica = new Set<String>{
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
                resultSet = bollettionoPostale;
            }
            when 'RID' {
                resultSet = rid;
            }
        }

        accountSRV.checkReadAccess('RecordType.Name');
        Account currentAccount = accountQR.getRecordById(accountId, 'RecordType.Name');
        if (currentAccount.RecordType.Name == 'Business') {
            resultSet.addAll(fatturazioneElettronica);
        }

        resultList.addAll(resultSet);

        return resultList;

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
