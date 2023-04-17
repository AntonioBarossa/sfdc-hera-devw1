public with sharing class HDT_UTL_BillingProfile {
    public static Map<Id,SObject> getSubscriberData(List<SObject> newRecords){
        Map<Id,SObject> resp = new Map<Id,SObject>();
        List<Id> accountsId = new List<Id>();
        List<Id> contactsId = new List<Id>();
        for (SObject obj : newRecords){
            BillingProfile__c bp = (BillingProfile__c)obj;
            if (!'RID'.equalsIgnoreCase(bp.PaymentMethod__c)
            || String.isBlank(bp.SignatoryType__c)
            || String.isNotBlank(bp.BankAccountSignatoryFirstName__c)
            || String.isNotBlank(bp.BankAccountSignatoryLastName__c)
            || String.isNotBlank(bp.BankAccountSignatoryFiscalCode__c)) {
                continue;
            }
            if('Legale Rappresentante'.equalsIgnoreCase(bp.SignatoryType__c) && bp.LegalAgent__c != null && !contactsId.contains(bp.LegalAgent__c)){
                contactsId.add(bp.LegalAgent__c);
                continue;
            }
            if('Stesso Sottoscrittore'.equalsIgnoreCase(bp.SignatoryType__c) && bp.Account__c != null && !accountsId.contains(bp.Account__c)){
                accountsId.add(bp.Account__c);
            }
        }
        if (!accountsId.isEmpty()){
            HDT_QR_Account accountQr = new HDT_QR_Account();
            resp.putAll(new Map<Id,SObject>(accountQr.getRecordsById(accountsId, 'FirstName__c,LastName__c,FiscalCode__c')));
        }
        if (!contactsId.isEmpty()){
            resp.putAll(new Map<Id,SObject>(HDT_QR_GenericQuery.getGenericRecords('FirstName,LastName,FiscalCode__c', 'Contact', 'Id IN (\''+String.join(contactsId, '\',\'')+'\')')));
        }
        return resp;
    }

    public static void setSubscriberData(BillingProfile__c bp, Map<Id,SObject> bpSubscriber){
        if (!'RID'.equalsIgnoreCase(bp.PaymentMethod__c)
        || String.isBlank(bp.SignatoryType__c)
        || String.isNotBlank(bp.BankAccountSignatoryFirstName__c)
        || String.isNotBlank(bp.BankAccountSignatoryLastName__c)
        || String.isNotBlank(bp.BankAccountSignatoryFiscalCode__c)) {
            return;
        }
        Id keyMap = 'Stesso Sottoscrittore'.equalsIgnoreCase(bp.SignatoryType__c) ? bp.Account__c :
                    'Legale Rappresentante'.equalsIgnoreCase(bp.SignatoryType__c) ? bp.LegalAgent__c : null;
        if (bpSubscriber.containsKey(keyMap)){
            HDT_WRP_Subscriber sub = new HDT_WRP_Subscriber(bpSubscriber.get(keyMap));
            bp.BankAccountSignatoryFirstName__c = sub.getFirstName();
            bp.BankAccountSignatoryLastName__c = sub.getLastName();
            bp.BankAccountSignatoryFiscalCode__c = sub.getFiscalCode();
        }
    }

    private class HDT_WRP_Subscriber{
        private String firstName;
        private String lastName;
        private String fiscalCode;
        private Map<Schema.SObjectType,Map<String,String>> fieldsMap = new Map<Schema.SObjectType,Map<String,String>>{
            Schema.Account.getSObjectType() => new Map<String,String>{
                'NOME' => 'FirstName__c',
                'COGNOME' => 'LastName__c',
                'CODFISC' => 'FiscalCode__c'
            },
            Schema.Contact.getSObjectType() => new Map<String,String>{
                'NOME' => 'FirstName',
                'COGNOME' => 'LastName',
                'CODFISC' => 'FiscalCode__c'
            }
        };
        
        public HDT_WRP_Subscriber(SObject person){
            Map<String,String> fields = this.fieldsMap.get(person.getSObjectType());
            this.firstName = (String)person.get(fields.get('NOME'));
            this.lastName = (String)person.get(fields.get('COGNOME'));
            this.fiscalCode = (String)person.get(fields.get('CODFISC'));
        }
        
        public String getFirstName(){
            return this.firstName;
        }

        public String getLastName(){
            return this.lastName;
        }

        public String getFiscalCode(){
            this.fiscalCode = String.isNotBlank(this.fiscalCode) && this.fiscalCode.isNumeric()? null :this.fiscalCode;
            return this.fiscalCode;
        }

    }
}