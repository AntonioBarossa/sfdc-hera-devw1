public inherited sharing class HDT_QR_BillingProfile {
    
    public List<BillingProfile__c> getRecordsByAccount(String accountId){

        String fieldsToCheck = 'PaymentMethod__c,InvoicingCountry__c,BillSendingMethod__c,IBAN__c';
        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('BillingProfile__c', fieldsToCheck, 'read');
        securityAccess.checkSecurityAccess();

        return [
            SELECT
            PaymentMethod__c,
            InvoicingCountry__c,
            BillSendingMethod__c,
            IBAN__c
            FROM BillingProfile__c
            WHERE Account__c = :accountId
            WITH SECURITY_ENFORCED
        ];
    }

}
