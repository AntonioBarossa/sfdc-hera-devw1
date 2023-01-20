/**
* @author Sabina Levonja (sabina.levonja@dunegroup.it)
* @date 21/04/21
* @description HDT_LC_FormAccountBusiness
* @history Sabina Levonja – 21/04/21 – created class
*/
public with sharing class HDT_LC_FormAccountBusiness {

    private static HDT_SRV_Account accountSrv = new HDT_SRV_Account();
    private static HDT_QR_AccountContactRelation accoContRelQr = new HDT_QR_AccountContactRelation();
    private static HDT_QR_Contact contactQr = new HDT_QR_Contact();
    private static HDT_SRV_AccountContactRelation accoContRelSrv = new HDT_SRV_AccountContactRelation();
    private static HDT_SRV_Contact contactSrv = new HDT_SRV_Contact();
    private static HDT_QR_RecordType recordtypeQR = new HDT_QR_RecordType();
    @AuraEnabled
    public static Account insertAccount(Map<String,String> dataAccount, Map<String,String> accountAddress,Map<String,String> contactAddress){

        String name;
        Id mainAcrId;
        String cType=dataAccount.get('customerMarking')=='Ditta individuale'?'Persona fisica':dataAccount.get('customerTypeValue');
        Account account= new Account(CustomerAccountStatus__c='Prospect',CustomerType__c=cType,RecordTypeId= dataAccount.get('recordTypeId') ,VATNumber__c= dataAccount.get('vatNumber'), FiscalCode__c= dataAccount.get('fiscalCode'), LegalFormType__c= dataAccount.get('legalForm'), CustomerMarking__c= dataAccount.get('customerMarking'), Category__c= dataAccount.get('category'), PrimaryEmail__c= dataAccount.get('email'), FAX__c= dataAccount.get('numberFax'), CompanyOwner__c=dataAccount.get('companyOwner'));
        //HRAWRM-491 Start 27/09/2021 Controllo codice fiscale stimato
      // System.debug('pino'+dataAccount.get('fiscalCode'));
        Map<String, String> infoData = new Map<String, String>();
        infoData.put('lastName'     , dataAccount.get('lastName')   );
        infoData.put('firstName'    , dataAccount.get('firstName')  );
        infoData.put('birthDate'    , dataAccount.get('birthDate')  );
        infoData.put('birthPlace'   , dataAccount.get('birthplace') );
        infoData.put('gender'       , dataAccount.get('gender')     );

        if (!HDT_UTL_CheckFiscalCodeTaxNumber.matchEstimatedFCode(infoData,dataAccount.get('personFiscalCode') )) {
            throw new AuraHandledException('Inserire un codice fiscale valido');
        }  
        //End HRAWRM-491 27/09/2021 Controllo codice fiscale stimato
 
     
        
      //  System.debug('PROVAACCOUNT:' + dataAccount);
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
            if('BillingIsAddressVerified__c' == s || 'BillingAddressIsForeign__c' == s){
                account.put(s, accountAddress.get(s) == 'true' ? true : false);
            }
            else{
                account.put(s, accountAddress.get(s));
            }
        }

        if( !String.isBlank(account.VATNumber__c) && !account.CustomerMarking__c.equalsIgnoreCase('Condominio') ){
            if( !checkVatNumber(account.VATNumber__c) ){
                throw new AuraHandledException('Partita Iva non corretta.');
            }
            if(!String.isBlank(account.FiscalCode__c) &&  account.FiscalCode__c.isNumeric() && !checkVatNumber(account.FiscalCode__c)){
                throw new AuraHandledException('Partita Iva non corretta.');
            }
        } else if( account.FiscalCode__c.isNumeric() ){
            if( !checkVatNumber(account.FiscalCode__c) ){
                throw new AuraHandledException('Partita Iva non corretta.');
            }
        }


        //System.debug('ACCOUNT:' + account);
        //HRDTR-00_HRAWRM-720 12/10/2021
      //  System.debug('account.CustomerMarking__c '+account.CustomerMarking__c);
        // if (!account.CustomerMarking__c.containsIgnoreCase('Condomini')&& !account.CustomerMarking__c.containsIgnoreCase('Associazione')) { //HRAWRM-775

           
        //     Account.FiscalCode__c=Account.VATNumber__c;  
        // }
        //HRADTR_GV 22/03/2022
        //account.FiscalCode__c = account.FiscalCode__c.toUpperCase();
        //HRDTR-00_HRAWRM-720 12/10/2021
        accountSrv.checkCreateAccess(account);
        Account acct= accountSrv.createRecord(account);
        
        String lastName = (acct.LastName__c != null && acct.LastName__c != '' ? acct.LastName__c : acct.Name);
        Contact contact= new Contact(Company__c=dataAccount.get('company'),AccountId= acct.Id, LastName= lastName, FiscalCode__c= acct.FiscalCode__c, VATNumber__c= acct.VATNumber__c,mobilephone=dataAccount.get('mobilephoneNumber') , MobilePhonePrefix__c=dataAccount.get('prefixMobilePhoneNumber'), phonePrefix__c = dataAccount.get('prefixPhoneNumber'),Phone= dataAccount.get('phoneNumber'), Email= acct.PrimaryEmail__c, Fax= acct.FAX__c, CertifiedEmail__c= dataAccount.get('electronicMail'), MailingCity= acct.BillingCity, MailingCityCode__c= acct.BillingCityCode__c, MailingCountry= acct.BillingCountry,  MailingPostalCode= acct.BillingPostalCode, MailingState= acct.BillingState, MailingStreet= acct.BillingStreet,MailingStreetName__c= acct.BillingStreetName__c, MailingStreetCode__c= acct.BillingStreetCode__c, MailingStreetNumber__c= acct.BillingStreetNumber__c, MailingStreetNumberExtension__c= acct.BillingStreetNumberExtension__c, MailingRegion__c= acct.BillingRegion__c,MailingPlace__c = acct.BillingPlace__c ,MailingPlaceCode__c = acct.BillingPlaceCode__c , MailingIsAddressVerified__c = acct.BillingIsAddressVerified__c);
        contactSrv.checkCreateAccess(contact);
        Contact cont= contactSrv.createRecord(contact);

        List<AccountContactRelation> listAccCon= accoContRelQr.getAccountContactRelation(acct.Id, cont.Id, 'Id');
        if(listAccCon != null && listAccCon.size() > 0){
            AccountContactRelation acr= new AccountContactRelation(Id= listAccCon[0].Id,ContactId= cont.Id, AccountId= acct.Id, Roles= 'Titolare');
            mainAcrId = listAccCon[0].Id;
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
             //   System.debug('1');
                sameEmail=true;
            }
            if(sameEmail && (personCon.MobilePhone ==null||(personCon.MobilePhone!=null && personCon.MobilePhone== dataAccount.get('mobilePhone')))){
             //   System.debug('2');
                sameMobile=true;
            }
            if(sameMobile && (personCon.Phone ==null ||(personCon.Phone !=null&& personCon.Phone== dataAccount.get('contactPhoneNumber')))){
            //    System.debug('3');
                samePhone=true;
            }
            if(samePhone){
            //   System.debug('contact not null');
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
                //HRAWRM-933 Start 08/11/2021
                for(String s: contactAddress.keySet()){
                    if('MailingIsAddressVerified__c' == s){
                        personCon.put(s, contactAddress.get(s) == 'true' ? true : false);
                    }
                    else{
                        personCon.put(s, contactAddress.get(s));
                    }
                }
                //HRAWRM-933 End 08/11/2021
                contactSrv.checkUpdateAccess(c);
                contactSrv.updateRecord(c);

                List<AccountContactRelation> listAccCon1 = accoContRelQr.getAccountContactRelation(acct.Id, personCon.Id, 'Id');
               // System.debug(listAccCon1);

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
               // System.debug('contact to be updated ');

                Date birthdate = (dataAccount.get('birthDate') != null && dataAccount.get('birthDate') != '' ? Date.valueOf(dataAccount.get('birthDate')) : null );
                Contact newCon = new Contact(Company__c=dataAccount.get('company'),AccountId= acct.Id,LastName= dataAccount.get('lastName'),FirstName= dataAccount.get('firstName'),Birthcity__c= dataAccount.get('birthplace') ,Birthdate= birthdate,Gender__c= dataAccount.get('gender'),FiscalCode__c= dataAccount.get('personFiscalCode') ,Email= dataAccount.get('contactEmail'),Fax= dataAccount.get('contactFax') ,MobilePhonePrefix__c= dataAccount.get('mobilePhonePrefix'), MobilePhone= dataAccount.get('mobilePhone') ,PhonePrefix__c= dataAccount.get('phonePrefix'), Phone= dataAccount.get('contactPhoneNumber'));
                contactSrv.checkCreateAccess(newCon);
                contactSrv.createRecord(newCon);
                List<AccountContactRelation> listAccCon2 = accoContRelQr.getAccountContactRelation(acct.Id, newCon.Id, 'Id');
               // System.debug(listAccCon2);

                if(dataAccount.get('role')!=null && listAccCon2 != null && listAccCon2.size() > 0){
           
                    AccountContactRelation ac= listAccCon2[0];//new AccountContactRelation(ContactId= personCont.Id, AccountId= acct.Id, Roles= dataAccount.get('role'));
                    ac.Roles = dataAccount.get('role');
                    accoContRelSrv.updateRecord(ac);

                }
            }
        }else{
            //System.debug('contact is null');

            String recordTypeResId='';
            //RecordType recordtype=recordtypeQR.getRecordType('HDT_RT_Residenziale', 'Account');
            recordTypeResId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HDT_RT_Residenziale').getRecordTypeId();
            // if(recordtype != null){
            //     recordTypeResId= recordtype.Id;
            // }
            //
            // Fix bug LEM006 EC  06/08/2021 
            Map<String, String> mapTranscodifica = new Map<String, String>{'AAA-EBT'=>'AAS Persona fisica','HERA COMM'=>'Persona fisica','MMS'=>'MMS Persona fisica'};
           
            Date birthdate = (dataAccount.get('birthDate') != null && dataAccount.get('birthDate') != '' ? Date.valueOf(dataAccount.get('birthDate')) : null );
            String namePerson= dataAccount.get('firstName') + ' '+ dataAccount.get('lastName');
            //System.debug('marcatura : '+dataAccount.get('companyOwner'));
            //? fix UAT 31/08/2021 verrà definita una logica in wave 3 come da feedback Analisi
            String varMarking;
            if ('Reseller'.equalsIgnoreCase(dataAccount.get('companyOwner'))){
                List<String> listSoc =dataAccount.get('customerMarking').split('-');
                if (listSoc.size()>0) {
                    varMarking=listSoc.get(0)+'-Persona fisica';
                }  
            }
            else {
                varMarking= mapTranscodifica.get(dataAccount.get('companyOwner'));
            }
            //? fix UAT 31/08/2021 verrà definita una logica in wave 3 come da feedback Analisi
            
            Account accountPerson= new Account(Name= namePerson, 
            LastName__c= dataAccount.get('lastName') , 
            FirstName__c= dataAccount.get('firstName'),
            RecordTypeId= recordTypeResId ,
            FiscalCode__c= dataAccount.get('personFiscalCode'),
            PhonePrefix__c= dataAccount.get('phonePrefix'),
            PrimaryEmail__c= dataAccount.get('contactEmail'),
            FAX__c= dataAccount.get('contactFax'),
            MobilePhonePrefix__c= dataAccount.get('mobilePhonePrefix'),
            MobilePhone__c= dataAccount.get('mobilePhone'),
            Phone= dataAccount.get('contactPhoneNumber'),
            Profession__c= dataAccount.get('profession'),
            Gender__c= dataAccount.get('gender'),
            DegreeOfStudies__c= dataAccount.get('education'),
            CompanyOwner__c=dataAccount.get('companyOwner'), 
            CustomerMarking__c=varMarking ,
            Category__c='Famiglie');
            for(String s: accountAddress.keySet()){
                if('BillingIsAddressVerified__c' == s || 'BillingAddressIsForeign__c' == s){
                    accountPerson.put(s, accountAddress.get(s) == 'true' ? true : false);
                }
                else{
                    accountPerson.put(s, accountAddress.get(s));
                }
            }
            accountSrv.checkCreateAccess(accountPerson);
            Account accPerson= accountSrv.createRecord(accountPerson);

            Contact personContact= new Contact(AccountId= accPerson.Id,LastName= accountPerson.LastName__c,FirstName=accountPerson.FirstName__c ,Birthcity__c= dataAccount.get('birthplace'),Birthdate= birthdate,FiscalCode__c= accountPerson.FiscalCode__c,Email= accountPerson.PrimaryEmail__c,Fax= accountPerson.FAX__c,MobilePhonePrefix__c= accountPerson.MobilePhonePrefix__c, MobilePhone= accountPerson.MobilePhone__c ,PhonePrefix__c= accountPerson.PhonePrefix__c, Phone= accountPerson.Phone ,Profession__c= accountPerson.Profession__c);
           //HRAWRM-933 Start 08/11/2021
            for(String s: contactAddress.keySet()){
                if('MailingIsAddressVerified__c' == s){
                    personContact.put(s, contactAddress.get(s) == 'true' ? true : false);
                }
                else{
                    personContact.put(s, contactAddress.get(s));
                }
            }
            //HRAWRM-933 End 08/11/2021
            contactSrv.checkCreateAccess(personContact);
            Contact personCont= contactSrv.createRecord(personContact);
            //Start HRDTR-00_HRAWRM-455 07/09/2021

            System.enqueueJob(new HDT_QBL_BpCaRequest(accPerson,personCont));
            //System.debug('jobId: '+jobId1);
            //End HRDTR-00_HRAWRM-455 07/09/2021

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
        List<AccountContactRelation> finalAcr = accoContRelQr.getContactsByAccountWithRoles(acct.Id);
        Boolean upMainAcr = false;
        for(AccountContactRelation signleAct : finalAcr)
        {
            if(signleAct.Id != mainAcrId && signleAct.Roles.containsIgnoreCase('Titolare'))
            {
                upMainAcr = true;
                break;
            }       
        }
        if(upMainAcr)
        {
            HDT_UTL_DatabaseService.updateSObject(new AccountContactRelation(Id = mainAcrId, Roles = 'Azienda'));
        }
        //HDT_UTL_Account.makeRequest(account,contact);
        System.enqueueJob(new HDT_QBL_BpCaRequest(account,contact));
        //System.debug('jobId: '+jobId);

    
        return acct;
    }

    public static Boolean checkVatNumber(String vatString){

        Boolean result = false;
        Integer evenSum = 0;
        Integer oddSum = 0;

        if( vatString.length() == 11 ){
            for( Integer i = 0; i < 11; i++ ){
                if ( math.mod(i+1, 2) == 0 ){ //even position
                    // i even, if vatNumber[i]*2>9 then vatNumber[i]*2 - 9, else vatNumber[i]*2
                    evenSum +=  2*Integer.ValueOf(vatString.substring(i,i+1)) > 9? 2*Integer.ValueOf(vatString.substring(i,i+1))-9:2*Integer.ValueOf(vatString.substring(i,i+1));
                } else {
                    oddSum += Integer.ValueOf(vatString.substring(i,i+1));
                }
            }

            if( math.mod(evenSum+oddSum, 10) == 0 ){
                result = true;
            }

        }
        return result;
    }

}