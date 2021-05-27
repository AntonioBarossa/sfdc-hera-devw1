public with sharing class HDT_LC_FormAccountResidenziale {

    private static HDT_SRV_Account accountSrv = new HDT_SRV_Account();
    private static HDT_QR_AccountContactRelation accoContRelQr = new HDT_QR_AccountContactRelation();
    private static HDT_QR_Contact contactQr = new HDT_QR_Contact();
    private static HDT_SRV_AccountContactRelation accoContRelSrv = new HDT_SRV_AccountContactRelation();
    private static HDT_SRV_Contact contactSrv = new HDT_SRV_Contact();
    private static HDT_QR_RecordType recordtypeQR = new HDT_QR_RecordType();

    @AuraEnabled
    public static Account insertAccount(Map<String,String> dataAccount, Map<String,String> accountAddress){
        
        Date birthdate = (dataAccount.get('birthDate') != null && dataAccount.get('birthDate') != '' ? Date.valueOf(dataAccount.get('birthDate')) : null );
        Account account= new Account(FirstName__c= dataAccount.get('firstName'), LastName__c= dataAccount.get('lastName'), FiscalCode__c= dataAccount.get('fiscalCode') ,PhonePrefix__c= dataAccount.get('phonePrefix') ,Phone= dataAccount.get('phoneNumber'),MobilePhonePrefix__c= dataAccount.get('mobilePhonePrefix'),MobilePhone__c =dataAccount.get('mobilePhone'),Name= dataAccount.get('name'),PrimaryEmail__c= dataAccount.get('email') ,RecordTypeId= dataAccount.get('recordTypeId'),Category__c= dataAccount.get('category'),CustomerMarking__c= dataAccount.get('customerMarking'), Gender__c= dataAccount.get('gender'), OtherPhone__c= dataAccount.get('otherPhoneNumber'),DegreeOfStudies__c= dataAccount.get('education'),Profession__c= dataAccount.get('profession'), CompanyOwner__c=dataAccount.get('companyOwner'));
        for(String s: accountAddress.keySet()){
            account.put(s, accountAddress.get(s));
        }
        accountSrv.checkCreateAccess(account);
        Account acct= accountSrv.createRecord(account);
        Contact contact= new Contact(AccountId= acct.Id, LastName= acct.LastName__c, FirstName=acct.FirstName__c ,Birthdate=birthdate, FiscalCode__c= acct.FiscalCode__c,Birthcity__c=dataAccount.get('birthplace') ,Phone= acct.Phone, Email= acct.PrimaryEmail__c,MobilePhonePrefix__c= acct.MobilePhonePrefix__c, MobilePhone= acct.MobilePhone__c, PhonePrefix__c= acct.PhonePrefix__c, Fax= acct.FAX__c,Profession__c= acct.Profession__c, MailingCity= acct.BillingCity, MailingCityCode__c= acct.BillingCityCode__c, MailingCountry= acct.BillingCountry, MailingPlace__c= acct.BillingPlace__c, MailingPostalCode= acct.BillingPostalCode, MailingState= acct.BillingState, MailingStreet= acct.BillingStreet, MailingStreetName__c= acct.BillingStreetName__c, MailingStreetCode__c= acct.BillingStreetCode__c, MailingStreetNumber__c= acct.BillingStreetNumber__c, MailingStreetNumberExtension__c= acct.BillingStreetNumberExtension__c, MailingStreetToponym__c= acct.BillingStreetToponym__c, MailingRegion__c= acct.BillingRegion__c);
        contactSrv.checkCreateAccess(contact);
        Contact cont= contactSrv.createRecord(contact);
        if(dataAccount.get('role')!=null){
            List<AccountContactRelation> listAccCon= accoContRelQr.getAccountContactRelation(acct.Id, cont.Id, 'Id');
            if(listAccCon != null && listAccCon.size() > 0){
                AccountContactRelation acr= new AccountContactRelation(Id= listAccCon[0].Id,ContactId= cont.Id, AccountId= acct.Id, Roles= dataAccount.get('role'));
                //HDT_SRV_AccountContactRelation.checkUpdateAccess(acr);
                accoContRelSrv.updateRecord(acr);
            }

        }
        // List<String> emails= new List<String>();
        // emails.add(cont.Email);
        // List<String> phones= new List<String>();
        // phones.add(cont.Phone);
        // HDT_UTL_GestionePrivacy.createDefaultPrivacyContact(cont.Id, emails, phones);

        return acct;
    }
}