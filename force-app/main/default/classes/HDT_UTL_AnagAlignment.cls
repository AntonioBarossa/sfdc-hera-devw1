public with sharing class HDT_UTL_AnagAlignment {

    private static final Map<String,String> ACCOUNT_TO_CONTACT_MAP = new Map<String, String>{
        'FirstName__c' => 'FirstName',
        'LastName__c' => 'LastName',
        'FiscalCode__c' => 'FiscalCode__c',
        'VatNumber__c' => 'VATNumber__c',
        'BillingCity' => 'MailingCity',
        'BillingCityCode__c' => 'MailingCityCode__c',
        'BillingCountry' => 'MailingCountry',
        'BillingIsAddressVerified__c' => 'MailingIsAddressVerified__c',
        'BillingPlace__c' => 'MailingPlace__c',
        'BillingPostalCode' => 'MailingPostalCode',
        'BillingState' => 'MailingState',
        'BillingStreetCode__c' => 'MailingStreetCode__c',
        'BillingStreetName__c' => 'MailingStreetName__c',
        'BillingStreet' => 'MailingStreet',
        'BillingStreetNumber__c' => 'MailingStreetNumber__c',
        'BillingStreetNumberExtension__c' => 'MailingStreetNumber__c'
    };


    public List<Contact> alignContacts (Account oldAccount, Account newAccount, List<Contact> contactList)
    {
        List<Contact> contactToAlign = new List<Contact>();
        for(Contact c : contactList){
            for(String key : ACCOUNT_TO_CONTACT_MAP.keySet())
            {
                if(oldAccount.get(key) != null && c.get(ACCOUNT_TO_CONTACT_MAP.get(key)) != null && oldAccount.get(key) == c.get(ACCOUNT_TO_CONTACT_MAP.get(key)))
                {
                    c.put(ACCOUNT_TO_CONTACT_MAP.get(key), newAccount.get(key));
                }
            }
            contactToAlign.add(c);
        }

        return contactToAlign;
    }

}