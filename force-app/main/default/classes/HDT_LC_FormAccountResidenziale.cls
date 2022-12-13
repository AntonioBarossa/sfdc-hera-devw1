/**
* @author Sabina Levonja (sabina.levonja@dunegroup.it)
* @date 21/04/2021
* @description HDT_LC_FormAccountResidenziale
* @history Sabina Levonja – 21/04/2021 – created class 
*/
public with sharing class HDT_LC_FormAccountResidenziale {

    private static HDT_SRV_Account accountSrv = new HDT_SRV_Account();
    private static HDT_QR_AccountContactRelation accoContRelQr = new HDT_QR_AccountContactRelation();
    private static HDT_QR_Contact contactQr = new HDT_QR_Contact();
    private static HDT_SRV_AccountContactRelation accoContRelSrv = new HDT_SRV_AccountContactRelation();
    private static HDT_SRV_Contact contactSrv = new HDT_SRV_Contact();
    private static HDT_QR_RecordType recordtypeQR = new HDT_QR_RecordType();
    
    @AuraEnabled //create account, account Amministratore e contatto Amministratore
    public static Account insertAccount(Map<String,String> dataAccount, Map<String,String> accountAddress, Map<String,String> accountAddressRes){
        //System.debug('accountAddressRes'+accountAddressRes);

        //create account with value and insert
        Account account = createAccountResidencial(dataAccount);
        checkFiscalCode(dataAccount); // if FC does not corresponde, throw an error
        account = valorizeAddressAccount( account, accountAddress, accountAddressRes );
        accountSrv.checkCreateAccess(account);
        Account acct= accountSrv.createRecord(account);

        //create contact with value and insert
        Contact contact= new Contact(DegreeOfStudies__c=dataAccount.get('education'),       CompanyOwner__c=dataAccount.get('companyOwner'),
                                     Company__c=dataAccount.get('company'),                 AccountId= acct.Id, 
                                     LastName= acct.LastName__c,                            Gender__c= acct.Gender__c,
                                     FirstName=acct.FirstName__c,                           Birthdate=acct.BirthDate__c, 
                                     FiscalCode__c= acct.FiscalCode__c,                     Birthcity__c=dataAccount.get('birthplace'),
                                     Phone= acct.Phone,                                     Email= acct.PrimaryEmail__c,
                                     MobilePhonePrefix__c= acct.MobilePhonePrefix__c,       MobilePhone= acct.MobilePhone__c,
                                     PhonePrefix__c= acct.PhonePrefix__c,                   Fax= acct.FAX__c,
                                     MailingCity= acct.BillingCity,                         MailingCityCode__c= acct.BillingCityCode__c, 
                                     MailingCountry= acct.BillingCountry,                   MailingPostalCode= acct.BillingPostalCode, 
                                     MailingState= acct.BillingState,                       MailingStreet= acct.BillingStreet, 
                                     MailingStreetName__c= acct.BillingStreetName__c,       MailingStreetCode__c= acct.BillingStreetCode__c, 
                                     MailingStreetNumber__c= acct.BillingStreetNumber__c,   MailingStreetNumberExtension__c= acct.BillingStreetNumberExtension__c, 
                                     MailingRegion__c= acct.BillingRegion__c,
                                     MailingPlace__c = acct.BillingPlace__c,                MailingPlaceCode__c = acct.BillingPlaceCode__c, 
                                     Profession__c= acct.Profession__c,                     MailingIsAddressVerified__c = acct.BillingIsAddressVerified__c
                                     );
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
        
       // HDT_UTL_Account.makeRequest(account,contact);
        //Id jobID = System.enqueueJob(new HDT_QBL_BpCaRequest(account,contact));
        System.enqueueJob(new HDT_QBL_BpCaRequest(account,contact));
        //System.debug('jobId: '+jobID);
        // List<String> emails= new List<String>(); emails.add(cont.Email); List<String> phones= new List<String>(); phones.add(cont.Phone); HDT_UTL_GestionePrivacy.createDefaultPrivacyContact(cont.Id, emails, phones);

        return acct;
    }

    @AuraEnabled
    public static Account valorizeAddressAccount( Account account, Map<String,String> accountAddress, Map<String,String> accountAddressRes ){
        for(String s: accountAddress.keySet()){
            if('BillingIsAddressVerified__c' == s || 'ShippingAddressIsForeign__c' == s || 'BillingAddressIsForeign__c' == s){
                account.put(s, accountAddress.get(s) == 'true' ? true : false);
            }
            else{ 
                account.put(s, accountAddress.get(s));
            }
        }

        for(String s: accountAddressRes.keySet()){
                //System.debug('s+ :'+s);
                //System.debug('accountAddressRes.get(s) :'+accountAddressRes.get(s));
                if('ShippingIsAddressVerified__c' == s){
                    account.put(s, accountAddressRes.get(s) == 'true' ? true : false);
                }
                else{ 
                    account.put(s, accountAddressRes.get(s));
                }
        }
        return account;
    }

    @AuraEnabled
    public static void checkFiscalCode(Map<String,String> dataAccount ){
        //HRAWRM-491 Start 27/09/2021 Controllo codice fiscale stimato 
        //Cod Fis o P.Iva
        Map<String, String> infoData = new Map<String, String>();
        infoData.put('lastName'     , dataAccount.get('lastName')   );
        infoData.put('firstName'    , dataAccount.get('firstName')  );
        infoData.put('birthDate'    , dataAccount.get('birthDate')  );
        infoData.put('birthPlace'   , dataAccount.get('birthplace') );
        infoData.put('gender'       , dataAccount.get('gender')     );
        if (!HDT_UTL_CheckFiscalCodeTaxNumber.matchEstimatedSetFiscalCode(infoData, dataAccount.get('fiscalCode') )) {
            throw new AuraHandledException('Inserire un codice fiscale valido');
        }
        //HRAWRM-491 End 27/09/2021 Controllo codice fiscale stimato
    }

    @AuraEnabled
    public static Account createAccountResidencial(Map<String,String> dataAccount ){
        Date birthdate = (dataAccount.get('birthDate') != null && dataAccount.get('birthDate') != '' ? Date.valueOf(dataAccount.get('birthDate')) : null );
        Account account= new Account(CustomerType__c=       dataAccount.get('customerType'),        CustomerAccountStatus__c=   'Prospect',
                                     BirthDate__c=          birthdate,                              BirthProvince__c=           dataAccount.get('birthplace'), 
                                     FirstName__c=          dataAccount.get('firstName'),           LastName__c=                dataAccount.get('lastName'),
                                     FiscalCode__c=         dataAccount.get('fiscalCode'),          Profession__c=              dataAccount.get('profession'),  
                                     PhonePrefix__c=        dataAccount.get('phonePrefix'),         Phone=                      dataAccount.get('phoneNumber'),
                                     MobilePhonePrefix__c=  dataAccount.get('mobilePhonePrefix'),   MobilePhone__c =            dataAccount.get('mobilePhone'),
                                     Name=                  dataAccount.get('name'),                PrimaryEmail__c=            dataAccount.get('email'),
                                     RecordTypeId=          dataAccount.get('recordTypeId'),        Category__c=                dataAccount.get('category'),
                                     CustomerMarking__c=    dataAccount.get('customerMarking'),     Gender__c=                  dataAccount.get('gender'), 
                                     OtherPhone__c=         dataAccount.get('otherPhoneNumber'),    DegreeOfStudies__c=         dataAccount.get('education'),                        CompanyOwner__c=dataAccount.get('companyOwner')
                                     );
        //account.FiscalCode__c = account.FiscalCode__c.toUpperCase();
        
        return account;
    }

    @AuraEnabled
    public static Account insertAccount(Map<String,String> dataAccount, Map<String,String> accountAddress){
        
        Date birthdate = (dataAccount.get('birthDate') != null && dataAccount.get('birthDate') != '' ? Date.valueOf(dataAccount.get('birthDate')) : null );
        Account account= new Account(CustomerType__c=dataAccount.get('customerType'),CustomerAccountStatus__c='Prospect',BirthDate__c=birthdate,BirthProvince__c=dataAccount.get('birthplace'),FirstName__c= dataAccount.get('firstName'), LastName__c= dataAccount.get('lastName'), FiscalCode__c= dataAccount.get('fiscalCode') ,PhonePrefix__c= dataAccount.get('phonePrefix') ,Phone= dataAccount.get('phoneNumber'),MobilePhonePrefix__c= dataAccount.get('mobilePhonePrefix'),MobilePhone__c =dataAccount.get('mobilePhone'),Name= dataAccount.get('name'),PrimaryEmail__c= dataAccount.get('email') ,RecordTypeId= dataAccount.get('recordTypeId'),Category__c= dataAccount.get('category'),CustomerMarking__c= dataAccount.get('customerMarking'), Gender__c= dataAccount.get('gender'), OtherPhone__c= dataAccount.get('otherPhoneNumber'),DegreeOfStudies__c= dataAccount.get('education'),Profession__c= dataAccount.get('profession'), 
        CompanyOwner__c=dataAccount.get('companyOwner')
        );
        for(String s: accountAddress.keySet()){
            if('BillingIsAddressVerified__c' == s){
                account.put(s, accountAddress.get(s) == 'true' ? true : false);
            }
            else{ 
                account.put(s, accountAddress.get(s));
            }
        }
        accountSrv.checkCreateAccess(account);
        Account acct= accountSrv.createRecord(account);
        Contact contact= new Contact(DegreeOfStudies__c=dataAccount.get('education'),CompanyOwner__c=dataAccount.get('companyOwner'),Company__c=dataAccount.get('company'),AccountId= acct.Id, LastName= acct.LastName__c,Gender__c= acct.Gender__c ,FirstName=acct.FirstName__c ,Birthdate=birthdate, FiscalCode__c= acct.FiscalCode__c,Birthcity__c=dataAccount.get('birthplace') ,Phone= acct.Phone, Email= acct.PrimaryEmail__c,MobilePhonePrefix__c= acct.MobilePhonePrefix__c, MobilePhone= acct.MobilePhone__c, PhonePrefix__c= acct.PhonePrefix__c, Fax= acct.FAX__c,Profession__c= acct.Profession__c, MailingCity= acct.BillingCity, MailingCityCode__c= acct.BillingCityCode__c, MailingCountry= acct.BillingCountry, MailingPostalCode= acct.BillingPostalCode, MailingState= acct.BillingState, MailingStreet= acct.BillingStreet, MailingStreetName__c= acct.BillingStreetName__c, MailingStreetCode__c= acct.BillingStreetCode__c, MailingStreetNumber__c= acct.BillingStreetNumber__c, MailingStreetNumberExtension__c= acct.BillingStreetNumberExtension__c, MailingRegion__c= acct.BillingRegion__c,MailingPlace__c = acct.BillingPlace__c ,MailingPlaceCode__c = acct.BillingPlaceCode__c , MailingIsAddressVerified__c = acct.BillingIsAddressVerified__c);
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
       // HDT_UTL_Account.makeRequest(account,contact);
        //Id jobID = System.enqueueJob(new HDT_QBL_BpCaRequest(account,contact));
        System.enqueueJob(new HDT_QBL_BpCaRequest(account,contact));
        //System.debug('jobId: '+jobID);

        // List<String> emails= new List<String>();
        // emails.add(cont.Email);
        // List<String> phones= new List<String>();
        // phones.add(cont.Phone);
        // HDT_UTL_GestionePrivacy.createDefaultPrivacyContact(cont.Id, emails, phones);

        return acct;
    }
}