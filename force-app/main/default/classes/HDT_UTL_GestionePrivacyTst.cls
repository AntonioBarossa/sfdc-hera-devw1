/**
* @author Elfrida Kora (elfrida.kora@dunegroup.it)
* @date 08/09/2021
* @description HDT_UTL_GestionePrivacy for Test Classes
* @history Elfrida Kora – 08/09/2021 – Created class
* @history Sabina Levonja – 8/10/2021
*/

@IsTest
public class HDT_UTL_GestionePrivacyTst {
	private static HDT_UTL_Constants constants = new HDT_UTL_Constants();    
    @TestSetup
    static void myData(){
        
        List<Lead> leadsList = HDT_UTL_DataFactoryTst.createLead(2,false);
        leadsList[0].MobilePhone ='069565852';
        leadsList[0].MobilePhonePrefix__c ='+39';
        leadsList[0].PhonePrefix__c='+39';
        leadsList[0].Phone ='0035555777';
        leadsList[0].VATNumber__c = '12345678100';
        leadsList[0].CustomerMarking__c= 'Azienda';
        leadsList[0].CompanyOwner__c ='HERA COMM';
        leadsList[0].Category__c ='Aziende SME';
        leadsList[0].CityCode__c='Roma';
		leadsList[0].StreetName__c='via roma';
		leadsList[0].StreetNumber__c='55';
        leadsList[0].IsAddressVerified__c = true;        
        insert leadsList;
                    
        HDT_UTL_DataFactoryTst.createContactPointPhone(1, true, leadsList[0].IndividualId);
        List<ContactPointEmail> cpe = HDT_UTL_DataFactoryTst.createContactPointEmail(1, false, leadsList[0].IndividualId);
        cpe[0].Status__c='Verificato';
        cpe[0].EmailAddress='test@gmail.com';
        insert cpe;
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Contact> conList = HDT_UTL_DataFactoryTst.createContact(2,false,accList[0].Id);
        conList[0].MobilePhone ='069565852';
        conList[0].MobilePhonePrefix__c ='+39';
        conList[0].PhonePrefix__c='+39';
        conList[0].Email='test@gmail.com';
        conList[0].Phone ='0695655852';

        insert conList;
        
        HDT_UTL_DataFactoryTst.createWebServiceConfiguration('BP_CA', 'test.com', 'post', 'testUser');
		HDT_UTL_DataFactoryTst.createWebServiceCredential('testUser', '12345', 'usernameTest');
    }
    
    @isTest
    public static void testSetPrivacyForLead(){
        Test.startTest();
        
        List<Lead> leads = [SELECT Id,MobilePhone,MobilePhonePrefix__c,ConvertedContactId,Phone,Email,IndividualId, PhonePrefix__c FROM Lead];
        HDT_UTL_GestionePrivacy.setPrivacyForLead(leads);
        
        Test.stopTest();
        List<Lead> leadList = [SELECT Id,MobilePhone,MobilePhonePrefix__c,ConvertedContactId,Phone,Email,IndividualId, PhonePrefix__c FROM Lead];
        List<ContactPointPhone> phones= [Select Id,ParentId,TelephoneNumber from ContactPointPhone where ParentId= :leadList[0].IndividualId and TelephoneNumber=:leadList[0].Phone];
        System.assertEquals(leads[0].Phone, phones[0].TelephoneNumber, 'The contact point has not been created');
        System.assertNotEquals(true, phones.isEmpty(), 'The ContactPointPhone list is empty');

    }
    @isTest
    public static void testUpdateContactPointFromObjectLead(){
        Test.startTest();
        List<Lead> oldLead = [SELECT Id,MobilePhone,MobilePhonePrefix__c,ConvertedContactId,Phone,Email,IndividualId, PhonePrefix__c FROM Lead];
        List<Lead> newLead = oldLead.deepClone(true);
        for(Lead l: newLead){
            l.Email = 'test@gmail.com';
            l.MobilePhone ='1116668883';
            l.Phone= '0099555633';
        }
        HDT_UTL_GestionePrivacy.updateContactPointFromObjectLead(newLead,oldLead);
     	
        Test.stopTest();
        
        List<Lead> leadList = [SELECT Id,MobilePhone,MobilePhonePrefix__c,ConvertedContactId,Phone,Email,IndividualId, PhonePrefix__c FROM Lead];
		List<ContactPointPhone> phones= [Select Id,ParentId,TelephoneNumber from ContactPointPhone where ParentId= :leadList[0].IndividualId and TelephoneNumber=:newLead[0].Phone];
        System.assertEquals(newLead[0].Phone, phones[0].TelephoneNumber, 'The contact point has not been updated');
        System.assertNotEquals(true, phones.isEmpty(), 'The ContactPointPhone list is empty');
      
    }
    
    @isTest
    public static void testUpdateContactPointFromObjectLeadUpdateEmail(){
        Test.startTest();
        List<Lead> oldLead = [SELECT Id,MobilePhone,MobilePhonePrefix__c,ConvertedContactId,Phone,Email,IndividualId, PhonePrefix__c FROM Lead];
        oldLead[0].Email='';
        update oldLead;
        
        List<Lead> newLead = oldLead.deepClone(true);
        
            newLead[0].Email = 'test@gmail.com';
            newLead[0].MobilePhone ='';
            newLead[0].Phone= '0099555633';

        update newLead;
        Database.LeadConvert convLead=new Database.LeadConvert();
			convLead.setLeadId(newLead[0].Id);
			leadStatus convertStatus=[SELECT Id, MasterLabel
			                          FROM LeadStatus
			                          WHERE IsConverted=true
			                          LIMIT 1];
			convLead.setConvertedStatus(convertStatus.MasterLabel);

			Database.convertLead(convLead);
        List<Lead> leads = [SELECT Id,MobilePhone,MobilePhonePrefix__c,ConvertedContactId,Phone,Email,IndividualId, PhonePrefix__c FROM Lead Where isConverted=true];
		leads[0].IndividualId= oldLead[0].IndividualId;
        HDT_UTL_GestionePrivacy.updateContactPointFromObjectLead(leads,oldLead);
     	
        Test.stopTest();
        
        List<Lead> leadList = [SELECT Id,MobilePhone,MobilePhonePrefix__c,ConvertedContactId,Phone,Email,IndividualId, PhonePrefix__c FROM Lead Where isConverted=true];
        List<ContactPointEmail> emails= [Select Id,ParentId,EmailAddress from ContactPointEmail where ParentId= :leadList[0].IndividualId And EmailAddress='test@gmail.com'];
        System.assertEquals(newLead[0].Email, emails[0].EmailAddress, 'The ContactPointEmail has not been created');
        System.assertNotEquals(true, emails.isEmpty(), 'The ContactPointEmail list is empty');

    }
    
    @isTest
    public static void testUpdateContactPointFromObjectContact(){
        Test.startTest();
        List<Contact> oldContact = [SELECT Id,MobilePhone,MobilePhonePrefix__c,Phone,Email,IndividualId,PhonePrefix__c FROM Contact];
        List<Contact> newContact = oldContact.deepClone(true);
        for(Contact c: newContact){
            c.Email = 'test3@gmail.com';
            c.MobilePhone ='1116668883';
            c.Phone= '0099555633';
        }
        HDT_UTL_GestionePrivacy.updateContactPointFromObjectContact(newContact,oldContact);
       	Test.stopTest();   
        
        List<Contact> contList = [SELECT Id,MobilePhone,MobilePhonePrefix__c,Phone,Email,IndividualId,PhonePrefix__c FROM Contact];
        List<ContactPointPhone> phones= [Select Id,ParentId,TelephoneNumber from ContactPointPhone where ParentId= :contList[0].IndividualId and TelephoneNumber='1116668883'];
        System.assertEquals(newContact[0].MobilePhone, phones[0].TelephoneNumber, 'The contact point has not been created');
        System.assertNotEquals(true, phones.isEmpty(), 'The ContactPointPhone list is empty');
    }
    @isTest
    public static void testUpdateContactPointFromObjectContactIfElse(){
        Test.startTest();
        List<Contact> oldContact = [SELECT Id,MobilePhone,MobilePhonePrefix__c,Phone,Email,IndividualId,PhonePrefix__c FROM Contact];
        List<Contact> newContact = oldContact.deepClone(true);
        for(Contact c: newContact){
            c.Email = 'sales@force.com';
            c.MobilePhone ='';
            c.Phone= '';
        }
        update newContact;
        HDT_UTL_GestionePrivacy.updateContactPointFromObjectContact(newContact,oldContact);
       	Test.stopTest(); 
        List<Contact> contList = [SELECT Id,MobilePhone,MobilePhonePrefix__c,Phone,Email,IndividualId,PhonePrefix__c FROM Contact];
        List<ContactPointEmail> emails= [Select Id,ParentId,EmailAddress from ContactPointEmail where ParentId= :contList[0].IndividualId and EmailAddress='sales@force.com'];
        System.assertEquals(newContact[0].Email, emails[0].EmailAddress, 'The contact point has not been created');
        System.assertNotEquals(true, emails.isEmpty(), 'The ContactPointEmail list is empty');
    }
    @isTest
    public static void testCreateContactDefaultPrivacy(){
        Test.startTest();
                        
        Account acc = [SELECT Id FROM Account limit 1];
        List<Contact> conList = HDT_UTL_DataFactoryTst.createContact(1,false,acc.Id);
        conList[0].LastName='Prova4';
        HDT_UTL_GestionePrivacy.createContactDefaultPrivacy(conList[0]);
        
        Test.stopTest();
        List<Contact> conts= [Select Id,AccountId From Contact Where AccountId=:acc.Id And LastName='Prova4'];
        System.assertEquals(1, conts.size(), 'The contact has not been created');
        System.assertNotEquals(true, conts.isEmpty(), 'The contact list is empty');
    }
    @isTest
    public static void testSetPrivacyForContact(){
        Test.startTest();
        
        List<Contact> conList = [SELECT Id,MobilePhone,MobilePhonePrefix__c,Phone,Email,IndividualId,PhonePrefix__c FROM Contact];
        HDT_UTL_GestionePrivacy.setPrivacyForContact(conList);
        
        Test.stopTest();
        List<Contact> contList = [SELECT Id,MobilePhone,MobilePhonePrefix__c,Phone,Email,IndividualId,PhonePrefix__c FROM Contact];
        List<ContactPointPhone> phones= [Select Id,ParentId,TelephoneNumber from ContactPointPhone where ParentId= :contList[0].IndividualId and TelephoneNumber=:contList[0].Phone];
        System.assertEquals(contList[0].Phone, phones[0].TelephoneNumber, 'The contact point has not been created');
        System.assertNotEquals(true, phones.isEmpty(), 'The ContactPointPhone list is empty');

    }
    
    @isTest
    public static void testGenerateMapMarketingFieldsValue(){
        Test.startTest();
        
        Map<String,Object> result = HDT_UTL_GestionePrivacy.generateMapMarketingFieldsValue('test','test',Date.today(),'test');
        
        Test.stopTest();
        
        System.assertEquals(true, !result.isEmpty(), 'The map is empty');
        System.assertNotEquals(false, !result.isEmpty(), 'The map has not been populated');
    }
    @isTest
    public static void testUpdatePrivacyConsentContactExternalList(){
        Test.startTest();
        Map<Id,Map<String,Object>> mapContactIdFieldsValues= new Map<Id,Map<String,Object>>();
        Map<String, Object> contactIdObject= new Map<String, Object> ();
        Contact con = [SELECT Id FROM Contact limit 1];
        contactIdObject.put('FirstName','test1');
        contactIdObject.put('CompanyOwner__c','MMS');
        mapContactIdFieldsValues.put(con.Id,contactIdObject);

        HDT_UTL_GestionePrivacy.updatePrivacyConsentContactExternalList(mapContactIdFieldsValues);
        
        Test.stopTest();
        List<Contact> contacts= [Select Id, FirstName, CompanyOwner__c From Contact Where Id=:con.Id];
        System.assertEquals(contactIdObject.get('FirstName'), contacts[0].FirstName, 'The firstname has not been updated');
        System.assertNotEquals(true, contacts[0].CompanyOwner__c != contactIdObject.get('CompanyOwner__c') , 'The CompanyOwner has not been updated');
    }
    @isTest
    public static void testUpdatePrivacyConsentLeadExternalList(){
        Test.startTest();
        Map<Id,Map<String,Object>> mapLeadFieldsValues= new Map<Id,Map<String,Object>>();
        Map<String, Object> leadfields= new Map<String, Object> ();
        Lead l = [SELECT Id FROM Lead limit 1];
        leadfields.put('MobilePhone','004448883');
        leadfields.put('CompanyOwner__c','MMS');
        mapLeadFieldsValues.put(l.Id,leadfields);

        HDT_UTL_GestionePrivacy.updatePrivacyConsentLeadExternalList(mapLeadFieldsValues);
        
        Test.stopTest();
        Lead lead=[Select Id, MobilePhone,CompanyOwner__c From Lead Where Id=:l.Id ];
        
        System.assertEquals(leadfields.get('MobilePhone'), lead.MobilePhone, 'The MobilePhone has not been updated');
        System.assertNotEquals(true, lead.CompanyOwner__c != leadfields.get('CompanyOwner__c') , 'The CompanyOwner has not been updated');
    }
    @isTest
    public static void testResendContactEmailToMarketing(){
        Test.startTest();
        
        ContactPointEmail cpe = [Select Id from ContactPointEmail limit 1];

        Boolean res= HDT_UTL_GestionePrivacy.resendContactEmailToMarketing(cpe.Id);
        
        Test.stopTest();
        ContactPointEmail contPoint= [Select Id, SendToMarketingCloud__c From ContactPointEmail Where Id=:cpe.Id];
        System.assertEquals(true, res, 'The ContactPointEmail has not been updated');
        System.assertNotEquals(false, contPoint.SendToMarketingCloud__c, 'The field SendToMarketingCloud__c has not been updated');
        
    }      
	@isTest
    public static void testResendContactPhoneToMarketing(){
        Test.startTest();
        
        ContactPointPhone cpp = [Select Id from ContactPointPhone limit 1];

        Boolean res= HDT_UTL_GestionePrivacy.resendContactPhoneToMarketing(cpp.Id);
        
        Test.stopTest();
        ContactPointPhone contPoint= [Select Id, SendToMarketingCloud__c From ContactPointPhone Where Id=:cpp.Id];
        System.assertEquals(true, res, 'The ContactPointPhone has not been updated');
        System.assertNotEquals(false, contPoint.SendToMarketingCloud__c, 'The field SendToMarketingCloud__c has not been updated');
    } 
    @isTest
    public static void testResendContactPhoneToMarketingCatch(){
        Test.startTest();
            Boolean resp= HDT_UTL_GestionePrivacy.resendContactPhoneToMarketing(null);
        Test.stopTest();
        
        System.assertEquals(false,resp,'The exception has not been catched');
    }
	@isTest
    public static void testResendContactEmailToMarketingCatch(){       
       
        Test.startTest();
        Boolean resp= HDT_UTL_GestionePrivacy.resendContactEmailToMarketing(null);
        Test.stopTest();
            
        System.assertEquals(false,resp, 'The exception has not been catched');
 
    }
    
    @isTest
    public static void testUpdatePrivacyConsentSol(){
        Test.startTest();
        
        Contact con = [SELECT Id,IndividualId FROM Contact limit 1];

        HDT_UTL_GestionePrivacy.updatePrivacyConsentSol(con.Id,'test','prodotti HVAC',Date.today(),'HCM','test20@gmail.com');
        
        Test.stopTest();
        ContactPointEmail cpe= [Select Id,Type__c From ContactPointEmail Where ParentId=:con.IndividualId And EmailAddress='test20@gmail.com'];
        System.assertEquals('E-mail SOL', cpe.Type__c, 'The ContactPointEmail has not been updated');
        System.assertNotEquals(true, String.isBlank(cpe.Type__c), 'The field Type__c has not been updated');
    } 
    @isTest
    public static void testUpdatePrivacyConsentSolIfElse(){
        Test.startTest();
        
        Contact con = [SELECT Id FROM Contact limit 1];

        HDT_UTL_GestionePrivacy.updatePrivacyConsentSol(con.Id,'test','prodotti HVAC',Date.today(),'HCM','test@gmail.com');
        
        Test.stopTest();
        ContactPointEmail cpe= [Select Id,Type__c From ContactPointEmail Where EmailAddress='test@gmail.com' And Type__c='E-mail SOL' limit 1];
        System.assertEquals('E-mail SOL', cpe.Type__c, 'The ContactPointEmail has not been updated');
        System.assertNotEquals(true, String.isBlank(cpe.Type__c), 'The field Type__c has not been updated');
    } 
    @isTest
    public static void testUpdatePrivacyConsentFormWebCallback(){
        Test.startTest();
        
        Lead l = [SELECT Id,IndividualId FROM Lead Where IndividualId != null limit 1];

        HDT_UTL_GestionePrivacy.updatePrivacyConsentFormWebCallback(l.IndividualId,'test','sito standard',Date.today(),'EBT');
        
        Test.stopTest();
        Individual ind= [Select Id,MarketingPrivacyVersion__c,PrivacyMarketingConsentInitiative__c From Individual Where Id=:l.IndividualId];
        System.assertEquals('test', ind.MarketingPrivacyVersion__c, 'The MarketingPrivacyVersion__c has not been updated');
        System.assertNotEquals(true, String.isBlank(ind.PrivacyMarketingConsentInitiative__c), 'The field PrivacyMarketingConsentInitiative__c has not been updated');
    }
    @isTest
    public static void testUpdatePrivacyConsentFormWebWinback(){
        Test.startTest();
        
        Lead l = [SELECT Id,IndividualId FROM Lead Where IndividualId != null limit 1];

        HDT_UTL_GestionePrivacy.updatePrivacyConsentFormWebWinback(l.IndividualId,'test','chat',Date.today(),'Reseller');
        
        Test.stopTest();
        Individual ind= [Select Id,MarketingCompanyConsent__c,PrivacyMarketingConsentInitiative__c From Individual Where Id=:l.IndividualId];
        System.assertEquals('Reseller', ind.MarketingCompanyConsent__c, 'The MarketingCompanyConsent__c has not been updated');
        System.assertNotEquals(true, String.isBlank(ind.PrivacyMarketingConsentInitiative__c), 'The field PrivacyMarketingConsentInitiative__c has not been updated');
    }
    @isTest
    public static void testUpdatePrivacyConsentFormWebEvent(){
        Test.startTest();
        
        Lead l = [SELECT Id,IndividualId FROM Lead Where IndividualId != null limit 1];

        HDT_UTL_GestionePrivacy.updatePrivacyConsentFormWebEvent(l.IndividualId,'test','sito standard proattivo',Date.today(),'Reseller');
        
        Test.stopTest();
        Individual ind= [Select Id,MarketingCompanyConsent__c,PrivacyMarketingConsentInitiative__c From Individual Where Id=:l.IndividualId];
        System.assertEquals('Reseller', ind.MarketingCompanyConsent__c, 'The MarketingCompanyConsent__c has not been updated');
        System.assertNotEquals(true, String.isBlank(ind.PrivacyMarketingConsentInitiative__c), 'The field PrivacyMarketingConsentInitiative__c has not been updated');
    }
    @isTest
    public static void testUpdatePrivacyConsentContractualEnvelope(){
        Test.startTest();
        
        Individual ind = [SELECT Id FROM Individual limit 1];

        HDT_UTL_GestionePrivacy.updatePrivacyConsentContractualEnvelope(ind.Id,'test','sito standard proattivo',Date.today(),'Reseller','test','sito standard',Date.today(),'AAA');
        
        Test.stopTest();
        Individual indv= [Select Id,MarketingCompanyConsent__c,PrivacyMarketingConsentInitiative__c From Individual Where Id=:ind.Id];
        System.assertEquals('Reseller', indv.MarketingCompanyConsent__c, 'The MarketingCompanyConsent__c has not been updated');
        System.assertNotEquals(true, String.isBlank(indv.PrivacyMarketingConsentInitiative__c), 'The field PrivacyMarketingConsentInitiative__c has not been updated');
    }
    @isTest
    public static void testUpdatePrivacyConsentPostSales(){
        Test.startTest();
        
        Individual ind = [SELECT Id FROM Individual limit 1];

        HDT_UTL_GestionePrivacy.updatePrivacyConsentPostSales(ind.Id,'test','sito standard',Date.today(),'MMS','test','sito standard',Date.today(),'AAA');
        
        Test.stopTest();
        Individual indv= [Select Id,MarketingCompanyConsent__c,PrivacyMarketingConsentInitiative__c From Individual Where Id=:ind.Id];
        System.assertEquals('MMS', indv.MarketingCompanyConsent__c, 'The MarketingCompanyConsent__c has not been updated');
        System.assertNotEquals(true, String.isBlank(indv.PrivacyMarketingConsentInitiative__c), 'The field PrivacyMarketingConsentInitiative__c has not been updated');
    }
    @isTest
    public static void testConvertLeadPrivacy(){
        Test.startTest();

        Lead l = [SELECT Id FROM Lead WHERE CompanyOwner__c = 'HERA COMM' limit 1];
        Contact con = [SELECT Id, AccountId FROM Contact limit 1];
        Database.LeadConvert convLead=new Database.LeadConvert();
			convLead.setLeadId(l.Id);
			leadStatus convertStatus=[SELECT Id, MasterLabel
			                          FROM LeadStatus
			                          WHERE IsConverted=true
			                          LIMIT 1];
			convLead.setConvertedStatus(convertStatus.MasterLabel);

			Database.convertLead(convLead);

        HDT_UTL_GestionePrivacy.convertLeadPrivacy(con.Id,l.Id);
        
        Test.stopTest();
        Lead lead= [Select Id, IndividualId From Lead Where IsConverted= true And Id= :l.Id];
        System.assertEquals(null, lead.IndividualId, 'The IndividualId has not been updated');
        System.assertNotEquals(false, String.isBlank(lead.IndividualId), 'The lead has not been updated');
    }
    @isTest
    public static void testCheckCloneCompany(){
        Test.startTest();
        
        List<Contact> conts= new List<Contact>();
        Contact con = [SELECT Id,MobilePhone,MobilePhonePrefix__c,Phone,Email,IndividualId,PhonePrefix__c,LastName, FirstName,Company__c,CompanyOwner__c FROM Contact limit 1];
        Contact c= con.clone(false,true,false,true);
        c.Company__c='HCM';
        c.LastName = con.LastName + 'clone';
        insert c;
        conts.add(c);
        HDT_UTL_GestionePrivacy.checkCloneCompany(conts);
        
        Test.stopTest();
        Contact cont = [SELECT Id,Phone,Email,IndividualId,LastName,Company__c FROM Contact Where Company__c='HCM' limit 1];
        System.assertEquals(con.Phone, cont.Phone, 'The Contact has not been cloned');
        System.assertNotEquals(true, String.isBlank(cont.Company__c), 'The Contact has not been cloned');
    }

    @isTest
    public static void testCreateDefaultPrivacyContact(){
        
        Test.startTest();
        Contact cont = [SELECT Id,IndividualId FROM Contact limit 1];
        List<String> contactIds= new List<String>();
		contactIds.add(cont.Id);
        List<String> mobPhones= new List<String>();
        mobPhones.add('2229990000');
        mobPhones.add('3229990010');
        mobPhones.add('4229990020');
        Map<String,List<String>> mapMobilePhone= new Map<String,List<String>>();
        mapMobilePhone.put(cont.Id,mobPhones);
        List<String> phones= new List<String>();
        phones.add('0088889987');
        phones.add('0088889988');
        phones.add('0088889989');
        Map<String,List<String>> mapPhone= new Map<String,List<String>>();
        mapPhone.put(cont.Id, phones);
        List<String> emails= new List<String>();
        emails.add('test1@gmail.com');
        emails.add('test2@gmail.com');
        Map<String,List<String>> mapEmail= new Map<String,List<String>>();
        mapEmail.put(cont.Id,emails);
        Map<String,String> mobilePrefixes= new Map<String,String>();
        mobilePrefixes.put('2229990000','+39');
        mobilePrefixes.put('3229990010','+39');
        mobilePrefixes.put('4229990020','+39');

        Map<String,String> phonePrefixes= new Map<String,String>();
        phonePrefixes.put('0088889987','+39');
        phonePrefixes.put('0088889988','+39');
        phonePrefixes.put('0088889989','+39');

        HDT_UTL_GestionePrivacy.createDefaultPrivacyContact(contactIds,mapMobilePhone,mapPhone,mapEmail,mobilePrefixes,phonePrefixes);     
		Contact c= [SELECT Id,IndividualId FROM Contact Where Id= :cont.Id];
        
        ContactPointPhone contPhone = [SELECT Id,TelephoneNumber FROM ContactPointPhone Where ParentId=:c.IndividualId And TelephoneNumber='0088889987'];
        System.assertEquals('0088889987', contPhone.TelephoneNumber, 'The ContactPointPhone has not been updated');
        System.assertNotEquals(null, contPhone, 'The ContactPointPhone has not been created');
    }
    @isTest
    public static void testCreateDefaultPrivacyContactIfElse(){
        
        Test.startTest();
        List<Contact> conts = [SELECT Id,IndividualId FROM Contact];
        conts[0].IndividualId=null;
        update conts;
        System.debug('conts*****'+conts);
        List<String> contactIds= new List<String>();
		contactIds.add(conts[0].Id);
        List<String> mobPhones= new List<String>();
        mobPhones.add('2229990000');
        mobPhones.add('3229990010');
        mobPhones.add('4229990020');
        Map<String,List<String>> mapMobilePhone= new Map<String,List<String>>();
        mapMobilePhone.put(conts[0].Id,mobPhones);
        List<String> phones= new List<String>();
        phones.add('0088889987');
        phones.add('0088889988');
        phones.add('0088889989');
        Map<String,List<String>> mapPhone= new Map<String,List<String>>();
        mapPhone.put(conts[0].Id, phones);
        List<String> emails= new List<String>();
        emails.add('test1@gmail.com');
        emails.add('test2@gmail.com');
        Map<String,List<String>> mapEmail= new Map<String,List<String>>();
        mapEmail.put(conts[0].Id,emails);
        Map<String,String> mobilePrefixes= new Map<String,String>();
        mobilePrefixes.put('2229990000','+39');
        mobilePrefixes.put('3229990010','+39');
        mobilePrefixes.put('4229990020','+39');

        Map<String,String> phonePrefixes= new Map<String,String>();
        phonePrefixes.put('0088889987','+39');
        phonePrefixes.put('0088889988','+39');
        phonePrefixes.put('0088889989','+39');

        HDT_UTL_GestionePrivacy.createDefaultPrivacyContact(contactIds,mapMobilePhone,mapPhone,mapEmail,mobilePrefixes,phonePrefixes);     
		Test.stopTest();
        
		Contact c= [SELECT Id,IndividualId FROM Contact Where Id= :conts[0].Id];
        
        ContactPointPhone contPhone = [SELECT Id,TelephoneNumber FROM ContactPointPhone Where ParentId=:c.IndividualId And TelephoneNumber='0088889989'];
        System.assertEquals('0088889989', contPhone.TelephoneNumber, 'The ContactPointPhone has not been updated');
        System.assertNotEquals(null, contPhone, 'The ContactPointPhone has not been created');
    }

    @isTest
    public static void testCreateDefaultPrivacyLead(){
        
        Test.startTest();
        Lead l = [SELECT Id,IndividualId FROM Lead limit 1];
        List<String> leadIds= new List<String>();
		leadIds.add(l.Id);
        List<String> mobPhones= new List<String>();
        Map<String,List<String>> mapMobilePhone= new Map<String,List<String>>();
        mapMobilePhone.put(l.Id,mobPhones);
        List<String> phones= new List<String>();
        phones.add('0088889987');
        phones.add('0088889988');
        phones.add('0088889989');
        Map<String,List<String>> mapPhone= new Map<String,List<String>>();
        mapPhone.put(l.Id, phones);
        List<String> emails= new List<String>();
        emails.add('test1@gmail.com');
        emails.add('test2@gmail.com');
        Map<String,List<String>> mapEmail= new Map<String,List<String>>();
        mapEmail.put(l.Id,emails);
        Map<String,String> mobilePrefixes= new Map<String,String>();
        mobilePrefixes.put('2229990000','+39');
        mobilePrefixes.put('3229990010','+39');
        mobilePrefixes.put('4229990020','+39');

        Map<String,String> phonePrefixes= new Map<String,String>();
        phonePrefixes.put('0088889987','+39');
        phonePrefixes.put('0088889988','+39');
        phonePrefixes.put('0088889989','+39');

        HDT_UTL_GestionePrivacy.createDefaultPrivacyLead(leadIds,mapMobilePhone,mapPhone,mapEmail,mobilePrefixes,phonePrefixes);     
		Test.stopTest();
        Lead lead = [SELECT Id,IndividualId FROM Lead Where Id=:l.Id];
        
        ContactPointEmail contEm = [SELECT Id,EmailAddress FROM ContactPointEmail Where ParentId=:lead.IndividualId And EmailAddress='test1@gmail.com'];
        System.assertEquals('test1@gmail.com', contEm.EmailAddress, 'The ContactPointEmail has not been updated');
        System.assertNotEquals(null, contEm, 'The ContactPointEmail has not been created');
    }
        
    }