public with sharing class HDT_LC_FormAccountBusiness {

    private static HDT_SRV_Account accountSrv = new HDT_SRV_Account();
    private static HDT_QR_AccountContactRelation accoContRelQr = new HDT_QR_AccountContactRelation();
    private static HDT_QR_Contact contactQr = new HDT_QR_Contact();
    private static HDT_SRV_AccountContactRelation accoContRelSrv = new HDT_SRV_AccountContactRelation();
    private static HDT_SRV_Contact contactSrv = new HDT_SRV_Contact();
    private static HDT_QR_RecordType recordtypeQR = new HDT_QR_RecordType();
    @AuraEnabled
    public static Account insertAccount(Map<String,String> dataAccount, Map<String,String> accountAddress){

        String name;
        Account account= new Account(RecordTypeId= dataAccount.get('recordTypeId') ,VATNumber__c= dataAccount.get('vatNumber'), FiscalCode__c= dataAccount.get('fiscalCode'), LegalFormType__c= dataAccount.get('legalForm'), CustomerMarking__c= dataAccount.get('customerMarking'), Category__c= dataAccount.get('category'), PrimaryEmail__c= dataAccount.get('email'), FAX__c= dataAccount.get('numberFax'), CompanyOwner__c=dataAccount.get('companyOwner'));
        System.debug('PROVAACCOUNT:' + dataAccount);
        if(dataAccount.get('businessName')!= null){
            name =dataAccount.get('businessName');
            account.put('LastName__c', dataAccount.get('businessName'));
        }
        if(dataAccount.get('firstIndividualName') != null && dataAccount.get('firstIndividualName') != ''){
            account.put('FirstName__c', dataAccount.get('firstIndividualName'));
            name= dataAccount.get('firstIndividualName');
        }
        if(dataAccount.get('lastIndividualName') != null && dataAccount.get('firstIndividualName') != ''){
            account.put('LastName__c', dataAccount.get('lastIndividualName'));
            name= name + ' '+ dataAccount.get('lastIndividualName');
        }
        account.put('Name', name);
        for(String s: accountAddress.keySet()){
            account.put(s, accountAddress.get(s));
        }
        System.debug('ACCOUNT:' + account);
        accountSrv.checkCreateAccess(account);
        Account acct= accountSrv.createRecord(account);
        
        String lastName = (acct.LastName__c != null && acct.LastName__c != '' ? acct.LastName__c : acct.Name);
        Contact contact= new Contact(AccountId= acct.Id, LastName= lastName, FiscalCode__c= acct.FiscalCode__c, VATNumber__c= acct.VATNumber__c,mobilephone=dataAccount.get('mobilephoneNumber') , MobilePhonePrefix__c=dataAccount.get('prefixMobilePhoneNumber'), phonePrefix__c = dataAccount.get('prefixPhoneNumber'),Phone= dataAccount.get('phoneNumber'), Email= acct.PrimaryEmail__c, Fax= acct.FAX__c, CertifiedEmail__c= dataAccount.get('electronicMail'), MailingCity= acct.BillingCity, MailingCityCode__c= acct.BillingCityCode__c, MailingCountry= acct.BillingCountry, MailingPlace__c= acct.BillingPlace__c, MailingPostalCode= acct.BillingPostalCode, MailingState= acct.BillingState, MailingStreet= acct.BillingStreet,MailingStreetName__c= acct.BillingStreetName__c, MailingStreetCode__c= acct.BillingStreetCode__c, MailingStreetNumber__c= acct.BillingStreetNumber__c, MailingStreetNumberExtension__c= acct.BillingStreetNumberExtension__c, MailingStreetToponym__c= acct.BillingStreetToponym__c, MailingRegion__c= acct.BillingRegion__c);
        contactSrv.checkCreateAccess(contact);
        Contact cont= contactSrv.createRecord(contact);

        List<AccountContactRelation> listAccCon= accoContRelQr.getAccountContactRelation(acct.Id, cont.Id, 'Id');
        if(listAccCon != null && listAccCon.size() > 0){
            AccountContactRelation acr= new AccountContactRelation(Id= listAccCon[0].Id,ContactId= cont.Id, AccountId= acct.Id, Roles= 'Titolare');
           // HDT_SRV_AccountContactRelation.checkUpdateAccess(acr);
           accoContRelSrv.updateRecord(acr);
        }
        // String recordTypeResId='';
        // RecordType recordtype=HDT_QR_RecordType.getRecordType('HDT_RT_Residenziale', 'Account');
        // if(recordtype != null){
        //     recordTypeResId= recordtype.Id;
        // }
        Contact personCon = contactQr.getRecordByFiscalCode(dataAccount.get('personFiscalCode'));
        if(personCon!=null){
            Boolean sameEmail=false;
            Boolean sameMobile=false;
            Boolean samePhone=false;

            if(personCon.Email ==null||(personCon.Email !=null && personCon.Email== dataAccount.get('contactEmail'))){
                System.debug('1');
                sameEmail=true;
            }
            if(sameEmail && (personCon.MobilePhone ==null||(personCon.MobilePhone!=null && personCon.MobilePhone== dataAccount.get('mobilePhone')))){
                System.debug('2');
                sameMobile=true;
            }
            if(sameMobile && (personCon.Phone ==null ||(personCon.Phone !=null&& personCon.Phone== dataAccount.get('contactPhoneNumber')))){
                System.debug('3');
                samePhone=true;
            }
            if(samePhone){
                System.debug('contact not null');
                Contact c= new Contact(Id= personCon.Id,AccountId= acct.Id);
                if(personCon.Email ==null && String.isNotBlank(dataAccount.get('contactEmail'))){
                    c.put('Email', dataAccount.get('contactEmail'));
                }
                if(personCon.MobilePhone ==null && String.isNotBlank(dataAccount.get('mobilePhone'))){
                    c.put('MobilePhone', dataAccount.get('mobilePhone'));
                }
                if(personCon.Phone ==null && String.isNotBlank(dataAccount.get('contactPhoneNumber'))){
                    c.put('Phone', dataAccount.get('contactPhoneNumber'));
                }
                contactSrv.checkUpdateAccess(c);
                contactSrv.updateRecord(c);

                List<AccountContactRelation> listAccCon1 = accoContRelQr.getAccountContactRelation(acct.Id, personCon.Id, 'Id');
                System.debug(listAccCon1);

                if(dataAccount.get('role')!=null && listAccCon1 != null && listAccCon1.size() > 0){
           
                    AccountContactRelation ac= listAccCon1[0];
                    ac.Roles = dataAccount.get('role');
                    accoContRelSrv.updateRecord(ac);

                }
                else{
                    AccountContactRelation ac = new AccountContactRelation();
                    ac.accountId = acct.id;
                    ac.contactId = personCon.id;
                    ac.roles = dataAccount.get('role');
                    accoContRelSrv.createRecord(ac);
                }
            }else{
                System.debug('contact to be updated ');

                Date birthdate = (dataAccount.get('birthDate') != null && dataAccount.get('birthDate') != '' ? Date.valueOf(dataAccount.get('birthDate')) : null );
                Contact newCon = new Contact(AccountId= acct.Id,LastName= dataAccount.get('lastName'),FirstName= dataAccount.get('firstName') ,Birthdate= birthdate,FiscalCode__c= dataAccount.get('personFiscalCode') ,Email= dataAccount.get('contactEmail'),Fax= dataAccount.get('contactFax') ,MobilePhonePrefix__c= dataAccount.get('mobilePhonePrefix'), MobilePhone= dataAccount.get('mobilePhone') ,PhonePrefix__c= dataAccount.get('phonePrefix'), Phone= dataAccount.get('contactPhoneNumber'));
                contactSrv.checkCreateAccess(newCon);
                contactSrv.createRecord(newCon);
                List<AccountContactRelation> listAccCon2 = accoContRelQr.getAccountContactRelation(acct.Id, newCon.Id, 'Id');
                System.debug(listAccCon2);

                if(dataAccount.get('role')!=null && listAccCon2 != null && listAccCon2.size() > 0){
           
                    AccountContactRelation ac= listAccCon2[0];//new AccountContactRelation(ContactId= personCont.Id, AccountId= acct.Id, Roles= dataAccount.get('role'));
                    ac.Roles = dataAccount.get('role');
                    accoContRelSrv.updateRecord(ac);

                }
            }
        }else{
            System.debug('contact is null');

            String recordTypeResId='';
            RecordType recordtype=recordtypeQR.getRecordType('HDT_RT_Residenziale', 'Account');
            if(recordtype != null){
                recordTypeResId= recordtype.Id;
            }
            Date birthdate = (dataAccount.get('birthDate') != null && dataAccount.get('birthDate') != '' ? Date.valueOf(dataAccount.get('birthDate')) : null );
            String namePerson= dataAccount.get('firstName') + ' '+ dataAccount.get('lastName');
            Account accountPerson= new Account(Name= namePerson, LastName__c= dataAccount.get('lastName') , FirstName__c= dataAccount.get('firstName'),RecordTypeId= recordTypeResId , FiscalCode__c= dataAccount.get('personFiscalCode'),PhonePrefix__c= dataAccount.get('phonePrefix'), PrimaryEmail__c= dataAccount.get('contactEmail'),FAX__c= dataAccount.get('contactFax'),MobilePhonePrefix__c= dataAccount.get('mobilePhonePrefix'), MobilePhone__c= dataAccount.get('mobilePhone'),Phone= dataAccount.get('contactPhoneNumber'),Profession__c= dataAccount.get('profession'),Gender__c= dataAccount.get('gender'),DegreeOfStudies__c= dataAccount.get('education'), CompanyOwner__c=dataAccount.get('companyOwner'), CustomerMarking__c= 'Persona fisica', Category__c='Famiglie');
            for(String s: accountAddress.keySet()){
                accountPerson.put(s, accountAddress.get(s));
            }
            accountSrv.checkCreateAccess(accountPerson);
            Account accPerson= accountSrv.createRecord(accountPerson);

            Contact personContact= new Contact(AccountId= accPerson.Id,LastName= accountPerson.LastName__c,FirstName=accountPerson.FirstName__c ,Birthcity__c= dataAccount.get('birthplace'),Birthdate= birthdate,FiscalCode__c= accountPerson.FiscalCode__c,Email= accountPerson.PrimaryEmail__c,Fax= accountPerson.FAX__c,MobilePhonePrefix__c= accountPerson.MobilePhonePrefix__c, MobilePhone= accountPerson.MobilePhone__c ,PhonePrefix__c= accountPerson.PhonePrefix__c, Phone= accountPerson.Phone ,Profession__c= accountPerson.Profession__c);
            contactSrv.checkCreateAccess(personContact);
            Contact personCont= contactSrv.createRecord(personContact);
            //List<AccountContactRelation> listAccCon3 = accoContRelQr.getAccountContactRelation(accPerson.Id, personCont.Id, 'Id');
            AccountContactRelation ac = new AccountContactRelation();
            ac.accountId = acct.id;
            ac.contactId = personCont.id;
            if(dataAccount.get('role')!=null){
                ac.Roles = dataAccount.get('role');
            }
            accoContRelSrv.createRecord(ac);
            // List<String> emails= new List<String>();
            // emails.add(cont.Email);
            // List<String> phones= new List<String>();
            // phones.add(cont.Phone);
            // HDT_UTL_GestionePrivacy.createDefaultPrivacyContact(cont.Id, emails, phones);
        }
        
    
        return acct;
    }
}