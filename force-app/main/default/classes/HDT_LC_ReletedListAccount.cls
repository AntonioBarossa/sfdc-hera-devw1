public with sharing class HDT_LC_ReletedListAccount {

    private static HDT_SRV_Account accountSrv = new HDT_SRV_Account();
    private static HDT_QR_AccountContactRelation accoContRelQr = new HDT_QR_AccountContactRelation();
    private static HDT_QR_Contact contactQr = new HDT_QR_Contact();
    private static HDT_SRV_AccountContactRelation accoContRelSrv = new HDT_SRV_AccountContactRelation();
    private static HDT_SRV_Contact contactSrv = new HDT_SRV_Contact();
    private static HDT_QR_RecordType recordtypeQR = new HDT_QR_RecordType();
    private static HDT_QR_Account accountQr = new HDT_QR_Account();

    @AuraEnabled
    public static Contact insertContact(Map<String,String> dataContact, Map<String,String> contactAddress){
       // System.debug('HDT_LC_ReletedListAccount');
        Date birthdate = (dataContact.get('birthDate') != null && dataContact.get('birthDate') != '' ? Date.valueOf(dataContact.get('birthDate')) : null );
        Account account= new Account(BirthDate__c=birthdate,BirthProvince__c=dataContact.get('birthplace'),FirstName__c= dataContact.get('firstName'), LastName__c= dataContact.get('lastName'), FiscalCode__c= dataContact.get('fiscalCode') ,PhonePrefix__c= dataContact.get('phonePrefix') ,Phone= dataContact.get('phoneNumber'),MobilePhonePrefix__c= dataContact.get('mobilePhonePrefix'),MobilePhone__c =dataContact.get('mobilePhone'),Name= dataContact.get('name'),PrimaryEmail__c= dataContact.get('email') ,RecordTypeId= dataContact.get('recordTypeId'),Category__c= dataContact.get('category'),CustomerMarking__c= dataContact.get('customerMarking'), Gender__c= dataContact.get('gender'), OtherPhone__c= dataContact.get('otherPhoneNumber'),DegreeOfStudies__c= dataContact.get('education'),Profession__c=dataContact.get('profession')
        );
        for(String s: contactAddress.keySet()){
            if('BillingIsAddressVerified__c' == s){
                account.put(s, contactAddress.get(s) == 'true' ? true : false);
            }
            else{ 
                account.put(s, contactAddress.get(s));
            }
        }
        //HRAWRM-491 27/09/2021 Controllo codice fiscale stimato
        Map<String, String> infoData = new Map<String, String>();
        infoData.put('lastName'     , dataContact.get('lastName')   );
        infoData.put('firstName'    , dataContact.get('firstName')  );
        infoData.put('birthDate'    , dataContact.get('birthDate')  );
        infoData.put('birthPlace'   , dataContact.get('birthplace') );
        infoData.put('gender'       , dataContact.get('gender')     );
        if (!HDT_UTL_CheckFiscalCodeTaxNumber.matchEstimatedFCode(infoData,dataContact.get('fiscalCode') )) {
            throw new AuraHandledException('Inserire un codice fiscale valido');
        }
        //HRAWRM-491 27/09/2021

        Contact contact= new Contact(AccountId= dataContact.get('accountId'), DegreeOfStudies__c= dataContact.get('education'),LastName= account.LastName__c,Gender__c= account.Gender__c ,FirstName=account.FirstName__c ,Birthdate=birthdate, FiscalCode__c= account.FiscalCode__c,Birthcity__c=dataContact.get('birthplace') ,Phone= account.Phone, Email= account.PrimaryEmail__c,MobilePhonePrefix__c= account.MobilePhonePrefix__c, MobilePhone= account.MobilePhone__c, PhonePrefix__c= account.PhonePrefix__c, Fax= account.FAX__c,Profession__c= account.Profession__c, MailingCity= account.BillingCity, MailingCityCode__c= account.BillingCityCode__c, MailingCountry= account.BillingCountry, MailingPostalCode= account.BillingPostalCode, MailingState= account.BillingState, MailingStreet= account.BillingStreet, MailingStreetName__c= account.BillingStreetName__c, MailingStreetCode__c= account.BillingStreetCode__c, MailingStreetNumber__c= account.BillingStreetNumber__c, MailingStreetNumberExtension__c= account.BillingStreetNumberExtension__c, MailingRegion__c= account.BillingRegion__c,MailingPlace__c = account.BillingPlace__c ,MailingPlaceCode__c = account.BillingPlaceCode__c , MailingIsAddressVerified__c = account.BillingIsAddressVerified__c);
        contactSrv.checkCreateAccess(contact);
        Contact cont= contactSrv.createRecord(contact);
        Boolean updateAcr = true;
        if(dataContact.get('role')!=null){
            List<AccountContactRelation> listAccCon= accoContRelQr.getAccountContactRelation(dataContact.get('accountId'), cont.Id, 'Id, AccountId');
            if(listAccCon != null && listAccCon.size() > 0){
                AccountContactRelation acr= new AccountContactRelation(Id= listAccCon[0].Id,ContactId= cont.Id, AccountId= dataContact.get('accountId'), Roles= dataContact.get('role'));
                if(acr.Roles.containsIgnoreCase('Titolare'))
                {
                    List<AccountContactRelation> otherAcr= [SELECT Id 
                    FROM AccountContactRelation 
                    WHERE AccountId = :dataContact.get('accountId') 
                    AND (Id != :listAccCon[0].Id) 
                    AND Roles INCLUDES ('Titolare')
                    WITH SECURITY_ENFORCED];
                    updateAcr = otherAcr.isEmpty();
                }
                if(updateAcr)
                {
                    accoContRelSrv.updateRecord(acr);
                }
                else
                {
                    throw new AuraHandledException('Non è possibile avere più di un Contatto Titolare sotto lo stesso Account.');
                }
            }
            if(dataContact.get('role').equalsIgnoreCase('Amministratore Condominio'))
            {
                String accountId = listAccCon[0].AccountId;
                Account acc = [SELECT Id,
                RecordTypeId,
                Category__c,
                FirstName__c,
                FiscalCode__c,
                BillingStreetNumber__c,
                BillingStreetName__c,
                BillingCountry,
                BillingState,
                BillingCity,
                BillingPostalCode,
                VATNumber__c,
                LastName__c,
                CustomerCode__c,
                MobilePhone__c,
                fax,
                customerMarking__c,
                BuildingFloor__c,
                PrimaryEmail__c,
                VATGroup__c,
                VATGroupStartDate__c,
                VATGroupEndDate__c
                FROM Account
                WHERE Id = :accountId
                WITH SECURITY_ENFORCED
                LIMIT 1
                ];
                System.enqueueJob(new HDT_QBL_BpCaRequest(acc, contact));
            }
        }
        return contact;
    }

    @AuraEnabled
    public static String getContList(String accountId) {
        if (String.isBlank(accountId)) {
            return null;
        }
        //HRAWRM-500 Start 04/10/2021
        List<AccountContactRelation> listAccountContactRelation = accoContRelQr.getContactsByAccountWithRoles(accountId);
        List<HDT_WRP_AccountContactRelation> lWrap = new List<HDT_WRP_AccountContactRelation>();

        for (AccountContactRelation temp : listAccountContactRelation) {
            HDT_WRP_AccountContactRelation n= new HDT_WRP_AccountContactRelation();
            Date endDate = temp.EndDate;
            Date startDate = temp.StartDate;
            n.AccountId             = temp.AccountId                ;
            n.contactId             = temp.ContactId                ;
            n.contactName           = temp.Contact.name             ;
            n.roles                 = temp.Roles                    ;
            n.contactHomePhone      = temp.Contact.Phone            ;
            n.contactMobilePhone    = temp.Contact.MobilePhone      ;
            n.contactEmail          = temp.Contact.Email            ;
            n.contactIndividualId   = temp.Contact.IndividualId     ;
            n.contactCode           = temp.Contact.ContactCode__c   ;
            if(endDate != null && startDate != null){
            n.endDate               = String.valueOf(endDate.day() + '/' + endDate.month() + '/' + endDate.year());
            n.startDate             = String.valueOf(startDate.day() + '/' + startDate.month() + '/' + startDate.year());
            }
            n.contactUrl            = '/lightning/r/Contact/' +temp.ContactId +'/view';
           lWrap.add(n);
        }
        //HRAWRM-500 End 04/10/2021

        return JSON.serialize(lWrap) ;

    }
    @AuraEnabled
    public static String getRecordTypeAccount(String accountId) {
       // System.debug('getContactList accId: '+accountId);
        if (String.isBlank(accountId)) {
            return null;
        }
        Account acc= accountQr.getRecordById(accountId,'recordType.developerName');
        return acc.recordType.developerName;
    }
    //HRAWRM-500 Start 04/10/2021

    public class HDT_WRP_AccountContactRelation {

       public String AccountId=''           ;
       public String contactId=''           ;
       public String contactName=''         ;
       public String roles=''               ;
       public String contactHomePhone=''    ;
       public String contactMobilePhone=''  ;
       public String contactEmail=''        ;
       public String contactIndividualId='' ;
     //public String bpInterlocutor=''      ;
       public String contactCode=''         ;
       public String endDate=''             ;
       public String startDate=''           ;
       public String contactUrl=''          ;
    }
    //HRAWRM-500 End 04/10/2021

}