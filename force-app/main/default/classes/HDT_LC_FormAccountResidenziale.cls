public with sharing class HDT_LC_FormAccountResidenziale {

    private static HDT_SRV_Account accountSrv = new HDT_SRV_Account();
    private static HDT_QR_AccountContactRelation accoContRelQr = new HDT_QR_AccountContactRelation();
    private static HDT_SRV_AccountContactRelation accoContRelSrv = new HDT_SRV_AccountContactRelation();
    private static HDT_SRV_Contact contactSrv = new HDT_SRV_Contact();
    
    @AuraEnabled
    public static Account insertAccount(Map<String,String> dataAccount){

        Account account= new Account(FirstName__c= dataAccount.get('firstName'), LastName__c= dataAccount.get('lastName'),FiscalCode__c= dataAccount.get('fiscalCode'),PhonePrefix__c= dataAccount.get('phonePrefix') ,Phone= dataAccount.get('phoneNumber'),MobilePhonePrefix__c= dataAccount.get('mobilePhonePrefix'),MobilePhone__c =dataAccount.get('mobilePhone'),Name= dataAccount.get('name'),PrimaryEmail__c= dataAccount.get('email') ,RecordTypeId= dataAccount.get('recordTypeId'),Category__c= dataAccount.get('category'),CustomerMarking__c= dataAccount.get('customerMarking'), Gender__c= dataAccount.get('gender'), OtherPhone__c= dataAccount.get('otherPhoneNumber'),DegreeOfStudies__c= dataAccount.get('education'),Profession__c= dataAccount.get('profession'), CompanyOwner__c=dataAccount.get('companyOwner'));
        accountSrv.checkCreateAccess(account);
        Account acct= accountSrv.createRecord(account);
        Contact contact= new Contact(AccountId= acct.Id, LastName= acct.LastName__c, FirstName=acct.FirstName__c ,FiscalCode__c= acct.FiscalCode__c, Phone= acct.Phone, Email= acct.PrimaryEmail__c,MobilePhonePrefix__c= acct.MobilePhonePrefix__c, MobilePhone= acct.MobilePhone__c, PhonePrefix__c= acct.PhonePrefix__c, Fax= acct.FAX__c,Profession__c= acct.Profession__c);
        if(dataAccount.get('birthDate')!= null && String.isNotBlank(dataAccount.get('birthDate'))){
            contact.put('Birthdate', Date.valueOf(dataAccount.get('birthDate')));
        }
        contactSrv.checkCreateAccess(contact);
        Contact cont= contactSrv.createRecord(contact);
        if(dataAccount.get('role')!=null){
            List<AccountContactRelation> listAccCon= accoContRelQr.getAccountContactRelation(acct.Id, cont.Id, 'Id');
            if(listAccCon != null && listAccCon.size() > 0){
                AccountContactRelation acr= new AccountContactRelation(Id= listAccCon[0].Id,ContactId= cont.Id, AccountId= acct.Id, Roles= dataAccount.get('role'));
                accoContRelSrv.updateRecord(acr);
            }

        }

        return acct;
    }
}
