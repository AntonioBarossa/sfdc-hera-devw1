public with sharing class HDT_UTL_BillingProfile {
    public static Map<Id,Account> getSubscriberData(List<SObject> newRecords){
        HDT_QR_Account accountQr = new HDT_QR_Account();
        List<Id> accountsId = new List<Id>();
        for (SObject obj : newRecords){
            BillingProfile__c bp = (BillingProfile__c)obj;
            if ('RID'.equalsIgnoreCase(bp.PaymentMethod__c) 
                &&'Stesso Sottoscrittore'.equalsIgnoreCase(bp.SignatoryType__c) 
                && String.isBlank(bp.BankAccountSignatoryFirstName__c)
                && String.isBlank(bp.BankAccountSignatoryLastName__c)
                && String.isBlank(bp.BankAccountSignatoryFiscalCode__c)
                && bp.Account__c != null
                && !accountsId.contains(bp.Account__c)){
                    accountsId.add(bp.Account__c);
            }
        }
        if (accountsId.isEmpty()){
            return new Map<Id,Account>();
        }
        return new Map<Id,Account>(accountQr.getRecordsById(accountsId, 'FirstName__c,LastName__c,FiscalCode__c'));
    }

    public static void setSubscriberData(BillingProfile__c bp, Map<Id,Account> bpSubscriber){
        if (bpSubscriber.containsKey(bp.Account__c)){
            Account acc = bpSubscriber.get(bp.Account__c);
            String fiscalcode = acc.FiscalCode__c;
            fiscalcode = String.isNotBlank(fiscalcode) && fiscalcode.isNumeric()?'':fiscalcode;
            bp.BankAccountSignatoryFirstName__c = acc.FirstName__c;
            bp.BankAccountSignatoryLastName__c = acc.LastName__c;
            bp.BankAccountSignatoryFiscalCode__c = fiscalcode;
        }
    }
}