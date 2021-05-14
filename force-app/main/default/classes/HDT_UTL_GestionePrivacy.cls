public with sharing class HDT_UTL_GestionePrivacy {
    
    private static HDT_QR_Contact contactQr = new HDT_QR_Contact();
    private static HDT_QR_Lead leadQr = new HDT_QR_Lead();
    private static HDT_SRV_Contact contactSrv = new HDT_SRV_Contact();
    // @AuraEnabled
    // public static void createDefaultPrivacyContact(Id ContactId,List<String> Email,List<String> Phone) {
       
    //     Individual ind =   HDT_UTL_Individual.createIndividualContact(ContactId);
    //     if(email != null && email.size() > 0){
    //         String emPrimary = email[0];
    //         email.remove(0);
    //         HDT_UTL_ContactPoint.createContactPointEmail(emPrimary, ind.Id ,Email);
    //     }
    //     if(Phone != null && Phone.size() > 0){
    //         String emPhone = Phone[0];
    //         Phone.remove(0);
    //         HDT_UTL_ContactPoint.createContactPointPhone(emPhone, ind.Id ,Phone);
            
    //     }

    // }
	// @AuraEnabled
    // public static void createDefaultPrivacyContact(Id ContactId,List<String> Email,List<String> Phone,List<String> Mobile) {
    //     Boolean check = false;
    //     Individual ind =   HDT_UTL_Individual.createIndividualContact(ContactId);
    //     if(email != null && email.size() > 0){
    //         String emPrimary = email[0];
    //         email.remove(0);
    //         HDT_UTL_ContactPoint.createContactPointEmail(emPrimary, ind.Id ,Email);
    //     }
    //     if(Mobile != null && Mobile.size() > 0){
    //         check = true;
    //         String emMobile = Mobile[0];
    //         Mobile.remove(0);
    //         HDT_UTL_ContactPoint.createContactPointPhone(emMobile, ind.Id ,Mobile,'Mobile');

    //     }
    //     if(Phone != null && Phone.size() > 0){
    //         if(check){
    //         	HDT_UTL_ContactPoint.createContactPointPhone('', ind.Id ,Phone,'Casa');
    //         }else{
    //             String emPhone = Phone[0];
    //         	Phone.remove(0);
    //        	 	HDT_UTL_ContactPoint.createContactPointPhone(emPhone, ind.Id ,Phone,'Casa');
    //         }
    //     }
    // }
    public static void createDefaultPrivacyContact(List<String> contactIds, Map<String,List<String>> mapMobilePhone ,Map<String,List<String>> mapPhone ,Map<String,List<String>> mapEmail, Map<String,String> mobilePrefixes, Map<String,String> phonePrefixes) {

        List<Individual> indv = HDT_UTL_Individual.createIndividualContact(contactIds);
        List<Contact> contacts = contactQr.getRecordsById(contactIds);
        Map<String,Contact> contactsOb=new Map<String,Contact>();
        Map<String,String> primaryEmail= new Map<String,String>();
        Map<String,List<String>> emails= new Map<String,List<String>>();
        Map<String,String> primaryMobile= new Map<String,String>();
        Map<String,List<String>> mobiles= new Map<String,List<String>>();
        Map<String,String> primaryPhone= new Map<String,String>();
        Map<String,List<String>> phones= new Map<String,List<String>>();
        Map<String,List<String>> phonesHome= new Map<String,List<String>>();
        boolean check = false;
        List<String> phone= new List<String>();
        for(Contact c: contacts){
            contactsOb.put(c.Id, c);
        }
        for(String id: mapEmail.keySet()){
            Contact contact= contactsOb.get(id);
            List<String> email= mapEmail.get(id);
            if(email != null && email.size() > 0){
                String emPrimary = email[0];
                email.remove(0);
                primaryEmail.put(contact.IndividualId, emPrimary);
                emails.put(contact.IndividualId, email);
            }
        }
        HDT_UTL_ContactPoint.createContactPointEmail(primaryEmail, emails);

        for(String id: mapMobilePhone.keySet()){
            Contact contact= contactsOb.get(id);
            List<String> mobile= mapMobilePhone.get(id);
            if(mobile != null && mobile.size() > 0){
                check = true;
                String emMobile = mobile[0];
                mobile.remove(0);
                primaryMobile.put(contact.IndividualId, emMobile);
                mobiles.put(contact.IndividualId, mobile);
            }
        }
        HDT_UTL_ContactPoint.createContactPointPhone(primaryMobile, mobiles,mobilePrefixes, 'Mobile');

        for(String id: mapPhone.keySet()){
            Contact contact= contactsOb.get(id);
            phone= mapPhone.get(id);
            if(phone != null && phone.size() > 0){
                phonesHome.put(contact.IndividualId, phone);
                String emPhone = phone[0];
                //phone.remove(0);
                primaryPhone.put(contact.IndividualId, emPhone);
                phones.put(contact.IndividualId, phone);
            }
        }
        if((mapPhone != null && !mapPhone.isEmpty()) || (mapMobilePhone != null && !mapMobilePhone.isEmpty()) ){
            if(check){
                primaryPhone= new Map<String,String>();
                HDT_UTL_ContactPoint.createContactPointPhone(primaryPhone,phonesHome ,phonePrefixes ,'Casa');
            }else{
                phone.remove(0);
                HDT_UTL_ContactPoint.createContactPointPhone(primaryPhone,phones, phonePrefixes,'Casa');
            }
        }
    }

     public static void updateContactPointFromObject(List<Lead> leadNew,List<Lead> leadOld){
        
            Map<String,String> mapMobilePhone = new Map<String,String>();
            Map<String,String> mapPhone = new Map<String,String>();
            Map<String,String> mapEmail = new Map<String,String>();
            Map<String,String> mapCreateMobilePhone = new Map<String,String>();
            Map<String,String> mapCreatePhone = new Map<String,String>();
            Map<String,String> mobilePrefixesToCreate = new Map<String,String>();
            Map<String,String> phonePrefixesToCreate = new Map<String,String>();
            Map<String,String> mapCreateEmail = new Map<String,String>();
            map<String,String> mapToUpdateMobile = new Map<String,String>();
            map<String,String> mapToUpdatePhone = new Map<String,String>();
            Map<String,String> mobilePrefixesToUpdate= new Map<String,String>();
            Map<String,String> phonePrefixesToUpdate = new Map<String,String>();
            map<String,String> mapToUpdateEmail = new Map<String,String>();
            map<String,String> mapLeadInd = new Map<String,String>();
            List<String> listIndividual = new List<String>();
            Boolean phCheck = false;
            Boolean emCheck = false;
            for(Lead l : leadOld){
                mapMobilePhone.put(l.id,l.mobilePhone == null ? '' : l.mobilePhone);
                mapPhone.put(l.id,l.phone == null ? '' : l.phone);
                mapEmail.put(l.id,l.email == null ? '' : l.email);
            }
            for(Lead l : leadNew){
                boolean check = false;
                if(mapMobilePhone.get(l.id) != null && mapMobilePhone.get(l.id) != l.MobilePhone && l.MobilePhone != '' && l.MobilePhone != null){
                    if(mapMobilePhone.get(l.id) == ''){
                        mapCreateMobilePhone.put(l.Id,l.MobilePhone);
                        mobilePrefixesToCreate.put(l.MobilePhone, l.MobilePhonePrefix__c);
                    }
                    else{
                        mapToUpdateMobile.put(mapMobilePhone.get(l.id), l.MobilePhone);
                        mobilePrefixesToUpdate.put(l.MobilePhone, l.MobilePhonePrefix__c);
                    	check = true;
                    	phCheck = true;
                    }
                }
                if(mapPhone.get(l.id) != null && mapPhone.get(l.id) != l.Phone && l.phone != '' && l.phone != null){
                    if(mapPhone.get(l.id) == ''){
                        mapCreatePhone.put(l.Id,l.Phone);
                        phonePrefixesToCreate.put(l.Phone, l.PhonePrefix__c);
                    }
                    else{
                        mapToUpdatePhone.put(mapPhone.get(l.id), l.Phone);
                        phonePrefixesToUpdate.put(l.Phone, l.PhonePrefix__c);
                        check = true;
                        phCheck = true;
    
                    }
                }
                if(mapEmail.get(l.id) != null && mapEmail.get(l.id) != l.Email  && l.Email != '' && l.Email != null){
                    if(mapEmail.get(l.id) == ''){
                        mapCreateEmail.put(l.Id,l.Email);
                    }
                    else{
                        mapToUpdateEmail.put(mapEmail.get(l.id), l.Email);
                    	check = true;
                    	emCheck = true;
                    }
                }
                if(check){
                    listIndividual.add(l.individualid);
                }
                mapLeadInd.put(l.id,l.IndividualId);
            }
            List<ContactPointPhone> cpToUpdate = new list<ContactPointPhone>();
            List<ContactPointEmail> ceToUpdate = new list<ContactPointEmail>();
            if(phCheck){
                List<ContactPointPhone> listCpp = HDT_QR_ContactPoint.getIndividualContactsPhoneList(listIndividual,'id,TelephoneNumber,Status__c,parentid');
                For(ContactPointPhone cp : listCpp){
                    if(mapToUpdatePhone.get(cp.TelephoneNumber) != null){
                        if(cp.Status__c == 'Non Verificato'){
                            cp.TelephoneNumber = mapToUpdatePhone.get(cp.TelephoneNumber);
                            cp.Prefix__c= phonePrefixesToUpdate.get(cp.TelephoneNumber);
                            cpToUpdate.add(cp);
                        }
                        else{
                            ContactPointPhone c = HDT_UTL_ContactPoint.instanceContactPointPhone(mapToUpdatePhone.get(cp.TelephoneNumber),phonePrefixesToUpdate.get(cp.TelephoneNumber),false);
                            c.parentid = cp.parentId;
                            cpToUpdate.add(c);
                        }
                    }
                    if(mapToUpdateMobile.get(cp.TelephoneNumber) != null){
                        if(cp.Status__c == 'Non Verificato'){
                            cp.TelephoneNumber = mapToUpdateMobile.get(cp.TelephoneNumber);
                            cp.Prefix__c= mobilePrefixesToUpdate.get(cp.TelephoneNumber);
                            cpToUpdate.add(cp);
                        }
                        else{
                            ContactPointPhone c = HDT_UTL_ContactPoint.instanceContactPointPhone(mapToUpdateMobile.get(cp.TelephoneNumber),mobilePrefixesToUpdate.get(cp.TelephoneNumber),false);
                            c.parentid = cp.parentId;
                            cpToUpdate.add(c);
                        }
                    }
                }
            }
            if(emCheck){
                List<ContactPointEmail> listCpe = HDT_QR_ContactPoint.getIndividualContactsEmailList(listIndividual,'id,EmailAddress,Status__c,parentid');
                For(ContactPointEmail cp : listCpe){
                    if(mapToUpdateEmail.get(cp.EmailAddress) != null){
                        if(cp.Status__c == 'Non Verificato'){
                            cp.EmailAddress = mapToUpdateEmail.get(cp.EmailAddress);
                            ceToUpdate.add(cp);
                        }
                        else{
                            ContactPointEmail c = HDT_UTL_ContactPoint.instanceContactPointEmail(mapToUpdateEmail.get(cp.EmailAddress),false);
                            c.parentid = cp.parentId;
                            ceToUpdate.add(c);
                        }
                    }
                }
            }
          
            if(mapCreateMobilePhone.size() > 0){
                for(String key : mapCreateMobilePhone.keyset()){
                    ContactPointPhone c = HDT_UTL_ContactPoint.instanceContactPointPhone(mapCreateMobilePhone.get(key),mobilePrefixesToCreate.get(mapCreateMobilePhone.get(key)), true);
                    c.parentid = mapLeadInd.get(key);
                    cpToUpdate.add(c);
                }
            }
            if(mapCreatePhone.size() > 0){
                 for(String key : mapCreatePhone.keyset()){
                    ContactPointPhone c = HDT_UTL_ContactPoint.instanceContactPointPhone(mapCreatePhone.get(key),phonePrefixesToCreate.get(mapCreatePhone.get(key)),true);
                    c.parentid = mapLeadInd.get(key);
                     cpToUpdate.add(c);
                }
            }
            if(mapCreateEmail.size() > 0){
                 for(String key : mapCreateEmail.keyset()){
                    ContactPointEmail c = HDT_UTL_ContactPoint.instanceContactPointEmail(mapCreateEmail.get(key),true);
                    c.parentid = mapLeadInd.get(key);
                     ceToUpdate.add(c);
                }
            }
    
            if(ceToUpdate != null && ceToUpdate.size() > 0){
                HDT_SRV_ContactPoint.upsertContactPointEmail(ceToUpdate);
            }
            if(cpToUpdate != null && cpToUpdate.size() > 0){
                HDT_SRV_ContactPoint.upsertContactPointPhone(cpToUpdate);
            }
        }

    // public static void createDefaultPrivacyLead(Id LeadId,List <String> Email,List <String> Phone) {

    //     Individual indv = HDT_UTL_Individual.createIndividualLead(LeadId);
    //     if(email != null && email.size() > 0){
    //         String emPrimary = email[0];
    //         email.remove(0);
    //         HDT_UTL_ContactPoint.createContactPointEmail(emPrimary, indv.Id ,Email);
    //     }
    //     if(Phone != null && Phone.size() > 0){
    //         String emPhone = Phone[0];
    //         Phone.remove(0);
    //         HDT_UTL_ContactPoint.createContactPointPhone(emPhone, indv.Id ,Phone);

    //     }
    // }
    // public static void createDefaultPrivacyLead(Id LeadId,List <String> Email,List <String> Phone,List<String> Mobile) {
	// 	boolean check = false;
    //     Individual indv = HDT_UTL_Individual.createIndividualLead(LeadId);
    //     if(email != null && email.size() > 0){
    //         String emPrimary = email[0];
    //         email.remove(0);
    //         HDT_UTL_ContactPoint.createContactPointEmail(emPrimary, indv.Id ,Email);
    //     }
    //     if(Mobile != null && Mobile.size() > 0){
    //         check = true;
    //         String emMobile = Mobile[0];
    //         Mobile.remove(0);
    //         HDT_UTL_ContactPoint.createContactPointPhone(emMobile, indv.Id ,Mobile,'Mobile');

    //     }
    //     if(Phone != null && Phone.size() > 0){
    //         if(check){
    //         	HDT_UTL_ContactPoint.createContactPointPhone('', indv.Id ,Phone,'Casa');
    //         }else{
    //             String emPhone = Phone[0];
    //         	Phone.remove(0);
    //        	 	HDT_UTL_ContactPoint.createContactPointPhone(emPhone, indv.Id ,Phone,'Casa');
    //         }

    //     }
    
    // }
    public static void createDefaultPrivacyLead(List<String> leadIds, Map<String,List<String>> mapMobilePhone ,Map<String,List<String>> mapPhone ,Map<String,List<String>> mapEmail, Map<String,String> mobilePrefixes, Map<String,String> phonePrefixes) {

        List<Individual> indv = HDT_UTL_Individual.createIndividualLead(leadIds);
        List<Lead> leads = leadQr.getRecordsById(leadIds);
        Map<String,Lead> leadsOb=new Map<String,Lead>();
        Map<String,String> primaryEmail= new Map<String,String>();
        Map<String,List<String>> emails= new Map<String,List<String>>();
        Map<String,String> primaryMobile= new Map<String,String>();
        Map<String,List<String>> mobiles= new Map<String,List<String>>();
        Map<String,String> primaryPhone= new Map<String,String>();
        Map<String,List<String>> phones= new Map<String,List<String>>();
        Map<String,List<String>> phonesHome= new Map<String,List<String>>();
        boolean check = false;
        List<String> phone= new List<String>();
        for(Lead l: leads){
            leadsOb.put(l.Id, l);
        }
        for(String id: mapEmail.keySet()){
            Lead lead= leadsOb.get(id);
            List<String> email= mapEmail.get(id);
            if(email != null && email.size() > 0){
                String emPrimary = email[0];
                email.remove(0);
                primaryEmail.put(lead.IndividualId, emPrimary);
                emails.put(lead.IndividualId, email);
            }
        }
        HDT_UTL_ContactPoint.createContactPointEmail(primaryEmail, emails);

        for(String id: mapMobilePhone.keySet()){
            Lead lead= leadsOb.get(id);
            List<String> mobile= mapMobilePhone.get(id);
            if(mobile != null && mobile.size() > 0){
                check = true;
                String emMobile = mobile[0];
                mobile.remove(0);
                primaryMobile.put(lead.IndividualId, emMobile);
                mobiles.put(lead.IndividualId, mobile);
            }
        }
        HDT_UTL_ContactPoint.createContactPointPhone(primaryMobile, mobiles,mobilePrefixes, 'Mobile');

        for(String id: mapPhone.keySet()){
            Lead lead= leadsOb.get(id);
            phone= mapPhone.get(id);
            if(phone != null && phone.size() > 0){
                phonesHome.put(lead.IndividualId, phone);
                String emPhone = phone[0];
                //phone.remove(0);
                primaryPhone.put(lead.IndividualId, emPhone);
                phones.put(lead.IndividualId, phone);
                System.debug(phonesHome);
            }
        }
        if(check){
            primaryPhone= new Map<String,String>();
            HDT_UTL_ContactPoint.createContactPointPhone(primaryPhone,phonesHome, phonePrefixes, 'Casa');
        }else{
            if(phone.size()>0){
                phone.remove(0);
            }
            HDT_UTL_ContactPoint.createContactPointPhone(primaryPhone,phones, phonePrefixes, 'Casa');
        }
    }

    /**
     * @author Elfrida Kora(elfrida.kora@dunegroup.it)
     */

   
    public static void convertLeadPrivacy(Id ContactId,Id LeadId) {

        Lead l = leadQr.getRecordById(String.valueOf(LeadId));
        

        Contact cont = HDT_UTL_Individual.convertLeadToContact(ContactId,l.IndividualId);
        
        l.IndividualId = null;
        contactSrv.updateRecord(cont);
        HDT_SRV_Lead.updateRecord(l);    

    }


    // public static void  setPrivacyForLead (Lead lead){

    //     List<String> emails= new List<String>();
    //     List<String> mobile = new List<String>();
        
    //     if(Lead.Email != null && Lead.Email != '')
    //     	emails.add(lead.Email);
    //     List<String> phones= new List<String>();
    //     if(Lead.MobilePhone != null && Lead.MobilePhone != '')
    //         mobile.add(lead.MobilePhone);
    //     if(Lead.Phone != null && Lead.Phone != '')
    //     	phones.add(lead.Phone);
    //     createDefaultPrivacyLead(lead.Id, emails, phones,mobile);

    // }
    public static void  setPrivacyForLead (List<Lead> leads){
        Map<String,List<String>> mapMobilePhone = new Map<String,List<String>>();
        Map<String,List<String>> mapPhone = new Map<String,List<String>>();
        Map<String,List<String>> mapEmail = new Map<String,List<String>>();
        Map<String,String> mobilePrefixes= new Map<String,String>();
        Map<String,String> phonePrefixes= new Map<String,String>();
        List<String> leadIds= new List<String>(); 

        for(Lead lead: leads){
            List<String> emails= new List<String>();
            List<String> mobile = new List<String>();
            List<String> phones= new List<String>();

            if(lead.Email != null && lead.Email != ''){
                emails.add(lead.Email);
            }
            if(lead.MobilePhone != null && lead.MobilePhone != ''){
                mobile.add(lead.MobilePhone);
                mobilePrefixes.put(lead.MobilePhone, lead.MobilePhonePrefix__c);
            }
            if(lead.Phone != null && lead.Phone != ''){
                phones.add(lead.Phone);
                phonePrefixes.put(lead.Phone, lead.PhonePrefix__c);
            }
            
            mapEmail.put(lead.Id, emails);
            mapMobilePhone.put(lead.Id, mobile);
            mapPhone.put(lead.Id, phones);
            leadIds.add(lead.Id);
        }
        createDefaultPrivacyLead(leadIds,mapMobilePhone,mapPhone,mapEmail, mobilePrefixes,phonePrefixes );
    }

    public static void updatePrivacyConsentPostSales(Id recordId,String VersioneInformativaMarketing,String IniziativaConsensoMarketing,Date DataConsensoMarketing,String CompanyConsensoMarketing,String VersioneInformativaProfilazione,String IniziativaConsensoProfilazione, Date DataConsensoProfilazione,String CompanyConsensoProfilazione){
                                                      
        Individual ind =new Individual(Id = recordId ,  MarketingPrivacyVersion__c = VersioneInformativaMarketing,MarketingCompanyConsent__c = CompanyConsensoMarketing,
         PrivacyMarketingConsentInitiative__c = IniziativaConsensoMarketing,PrivacyMarketingChoiceDate__c = DataConsensoMarketing,ProfilingPrivacyVersion__c = VersioneInformativaProfilazione,
         PrivacyProfilingConsentInitiative__c = IniziativaConsensoProfilazione,PrivacyProfilingChoiceDate__c = DataConsensoProfilazione,ProfilingCompanyConsent__c = CompanyConsensoProfilazione);
        
                
        HDT_SRV_Individual.checkCreateAccess(ind);
        Individual indvid= HDT_SRV_Individual.updateRecord(ind);

    }

    public static void updatePrivacyConsentContractualEnvelope(Id recordId,String VersioneInformativaMarketing,String IniziativaConsensoMarketing,Date DataConsensoMarketing,String CompanyConsensoMarketing,String VersioneInformativaProfilazione,String IniziativaConsensoProfilazione, Date DataConsensoProfilazione,String CompanyConsensoProfilazione){

        Individual ind =new Individual(Id = recordId ,  MarketingPrivacyVersion__c = VersioneInformativaMarketing,MarketingCompanyConsent__c = CompanyConsensoMarketing,
         PrivacyMarketingConsentInitiative__c = IniziativaConsensoMarketing,PrivacyMarketingChoiceDate__c = DataConsensoMarketing,ProfilingPrivacyVersion__c = VersioneInformativaProfilazione,
         PrivacyProfilingConsentInitiative__c = IniziativaConsensoProfilazione,PrivacyProfilingChoiceDate__c = DataConsensoProfilazione,ProfilingCompanyConsent__c = CompanyConsensoProfilazione);
        
                
        HDT_SRV_Individual.checkCreateAccess(ind);
        Individual indvid= HDT_SRV_Individual.updateRecord(ind);

    }

    public static void updatePrivacyConsentFormWebEvent(Id leadId,String VersioneInformativaMarketing,String IniziativaConsensoMarketing,Date DataConsensoMarketing,String CompanyConsensoMarketing){

        Individual ind =new Individual(Id = leadId,MarketingPrivacyVersion__c = VersioneInformativaMarketing,MarketingCompanyConsent__c = CompanyConsensoMarketing,
        PrivacyMarketingConsentInitiative__c = IniziativaConsensoMarketing,PrivacyMarketingChoiceDate__c = DataConsensoMarketing);

        HDT_SRV_Individual.checkCreateAccess(ind);
        Individual indvid= HDT_SRV_Individual.updateRecord(ind);
    }

    public static void updatePrivacyConsentFormWebWinback(Id leadId,String VersioneInformativaMarketing,String IniziativaConsensoMarketing,Date DataConsensoMarketing,String CompanyConsensoMarketing){

        Individual ind =new Individual(Id = leadId,MarketingPrivacyVersion__c = VersioneInformativaMarketing,MarketingCompanyConsent__c = CompanyConsensoMarketing,
        PrivacyMarketingConsentInitiative__c = IniziativaConsensoMarketing,PrivacyMarketingChoiceDate__c = DataConsensoMarketing);

        HDT_SRV_Individual.checkCreateAccess(ind);
        Individual indvid= HDT_SRV_Individual.updateRecord(ind);
    }

    public static void updatePrivacyConsentFormWebCallback(Id leadId,String VersioneInformativaMarketing,String IniziativaConsensoMarketing,Date DataConsensoMarketing,String CompanyConsensoMarketing){

        Individual ind =new Individual(Id = leadId,MarketingPrivacyVersion__c = VersioneInformativaMarketing,MarketingCompanyConsent__c = CompanyConsensoMarketing,
        PrivacyMarketingConsentInitiative__c = IniziativaConsensoMarketing,PrivacyMarketingChoiceDate__c = DataConsensoMarketing);

        HDT_SRV_Individual.checkCreateAccess(ind);
        Individual indvid= HDT_SRV_Individual.updateRecord(ind);
    }

    public static void updatePrivacyConsentSol(Id contactId,String VersioneInformativaMarketing,String IniziativaConsensoMarketing,Date DataConsensoMarketing,String CompanyConsensoMarketing,String email){
		Contact cont = contactQr.getRecordById(contactId);
        Individual ind =new Individual(Id = cont.IndividualId,MarketingPrivacyVersion__c = VersioneInformativaMarketing,MarketingCompanyConsent__c = CompanyConsensoMarketing, 
        PrivacyMarketingConsentInitiative__c = IniziativaConsensoMarketing,PrivacyMarketingChoiceDate__c = DataConsensoMarketing);
        
        ContactPointEmail contemail = HDT_QR_ContactPoint.searchContactPointEmail(email);
        if(contemail !=null){
            ContactPointEmail emailContact = new ContactPointEmail(Id = contemail.Id,Type__c = 'E-mail SOL');
            HDT_SRV_ContactPointEmail.updateRecord(emailContact);
        }else
            ContactPointEmail emailContact = new ContactPointEmail(ParentId = ind.id,EmailAddress = email,Type__c = 'E-mail SOL');
         	HDT_SRV_ContactPointEmail.checkUpdateAccess(contemail);

            HDT_SRV_Individual.checkCreateAccess(ind);
            Individual indvid= HDT_SRV_Individual.updateRecord(ind);
        }

        public static void updatePrivacyConsentLeadExternalList(Map<Id,Map<String,Object>> mapLeadIdFieldsValues){
            Map<String, Object> leadIdObject= new Map<String, Object> ();

            for(Id leadId:mapLeadIdFieldsValues.keySet() ){
                Lead lead=new Lead();
                lead.put('Id',LeadId);
                leadIdObject= mapLeadIdFieldsValues.get(leadId);
                for(String field: leadIdObject.keySet() ){
                    lead.put(field, leadIdObject.get(field));
                }
                HDT_SRV_Lead.checkUpdateAccess(lead);
                HDT_SRV_Lead.updateRecord(lead);
            }    
        }

        public static void updatePrivacyConsentContactExternalList(Map<Id,Map<String,Object>> mapContactIdFieldsValues){
            Map<String, Object> contactIdObject= new Map<String, Object> ();

            for(Id contactId:mapContactIdFieldsValues.keySet() ){
                Contact cont=new Contact();
                cont.put('Id',contactId);
                contactIdObject= mapContactIdFieldsValues.get(contactId);
                for(String field: contactIdObject.keySet() ){
                    cont.put(field, contactIdObject.get(field));
                }
                contactSrv.checkUpdateAccess(cont);
                contactSrv.updateRecord(cont);
            }
        }

        public static Map<String,Object> generateMapMarketingFieldsValue(String VersioneInformativaMarketing,String IniziativaConsensoMarketing,Date DataConsensoMarketing,String CompanyConsensoMarketing){
            Map<String,Object> maps = new Map<String,Object> ();

          
            maps.put('MarketingPrivacyVersion__c ',VersioneInformativaMarketing);
            maps.put('PrivacyMarketingConsentInitiative__c',IniziativaConsensoMarketing);
            maps.put('PrivacyMarketingChoiceDate__c',DataConsensoMarketing);
            maps.put('MarketingCompanyConsent__c',CompanyConsensoMarketing);
            
            return maps;

          }

        //   public static void createIndividualDefaultPrivacy(List<Lead> leads){

            
        //     for(Lead lead:leads){
        //         HDT_UTL_Individual.createIndividualLead(lead.Id);     
        //     }   

        // }

        public static void createContactDefaultPrivacy(Contact contact){

            contactSrv.checkCreateAccess(contact);
            //HDT_SRV_Contact.updateRecord(cont);
            contactSrv.createRecord(contact);
        }

        // public static void  setPrivacyForContact (Contact contact){

        //     List<String> emails= new List<String>();
        //     List<String> mobiles = new List<String>();
        //     if(contact.Email != null && String.IsNotBlank(contact.Email)){
        //         emails.add(contact.Email);
        //     }
        //     List<String> phones= new List<String>();
        //     if(contact.MobilePhone != null && String.IsNotBlank(contact.MobilePhone)){
        //         mobiles.add(contact.MobilePhone);
        //     }
        //     if(contact.Phone != null && String.IsNotBlank(contact.Phone)){
        //         phones.add(contact.Phone);
        //     }
        //     if(contact.OtherPhone != null && String.IsNotBlank(contact.OtherPhone)){
        //         phones.add(contact.OtherPhone);
        //     }
        //     createDefaultPrivacyContact(contact.Id, emails, phones,mobiles);
    
        // }
        public static void  setPrivacyForContact (List<Contact> contacts){
            Map<String,List<String>> mapMobilePhone = new Map<String,List<String>>();
            Map<String,List<String>> mapPhone = new Map<String,List<String>>();
            Map<String,List<String>> mapEmail = new Map<String,List<String>>();
            Map<String,String> mobilePrefixes= new Map<String,String>();
            Map<String,String> phonePrefixes= new Map<String,String>();
            List<String> contactIds= new List<String>(); 
    
            for(Contact contact: contacts){
                List<String> emails= new List<String>();
                List<String> mobile = new List<String>();
                List<String> phones= new List<String>();
    
                if(contact.Email != null && contact.Email != ''){
                    emails.add(contact.Email);
                }
                if(contact.MobilePhone != null && contact.MobilePhone != ''){
                    mobile.add(contact.MobilePhone);
                    mobilePrefixes.put(contact.MobilePhone, contact.MobilePhonePrefix__c);
                }
                if(contact.Phone != null && contact.Phone != ''){
                    phones.add(contact.Phone);
                    phonePrefixes.put(contact.Phone, contact.PhonePrefix__c);
                }
                
                mapEmail.put(contact.Id, emails);
                mapMobilePhone.put(contact.Id, mobile);
                mapPhone.put(contact.Id, phones);
                contactIds.add(contact.Id);
            }
            createDefaultPrivacyContact(contactIds,mapMobilePhone,mapPhone,mapEmail,mobilePrefixes,phonePrefixes);
        }


}