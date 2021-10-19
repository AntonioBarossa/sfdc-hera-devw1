/**
 * @author 'Sabina Levonja' (sabina.levonja@dunegroup.it)
 * @description HDT_UTL_GestionePrivacy - 
 */

 public with sharing class HDT_UTL_GestionePrivacy {
    
    private static HDT_QR_Contact contactQr = new HDT_QR_Contact();
    private static HDT_QR_Lead leadQr = new HDT_QR_Lead();
    private static HDT_SRV_Contact contactSrv = new HDT_SRV_Contact();

    @AuraEnabled
    public static void checkCloneCompany(List<Contact> contList){
        map<String,String> contactId = new map<String,string>();
        map<String,String> contactToCheck = new map<String,string>();
        for(Contact c : contList){
            if(c.isClone()){
                contactId.put(c.id,c.getCloneSourceId());
            }
        }
        if(contactId.values() != null && !contactId.values().isEmpty()){
            List<Contact> listContaToCheck = contactQr.getRecordsById(contactId.values());
            for(Contact c : listContaToCheck){
                contactToCheck.put(c.id,c.company__c);
            }
            for(Contact c : contList){
                if(c.company__c == contactToCheck.get(contactId.get(c.id))){
                    c.addError('Valorizzare il Company in modo differente');
                }
            }
        }
    }





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

        List<Contact> contacts = contactQr.getRecordsById(contactIds);
        /*List<Individual> indv =*/ HDT_UTL_Individual.createIndividualContact(contacts);
       // List<Contact> contacts = contactQr.getRecordsById(contactIds);
        Map<String,Contact> contactsOb=new Map<String,Contact>();
        Map<String,String> primaryEmail= new Map<String,String>();
        Map<String,List<String>> emails= new Map<String,List<String>>();
        Map<String,String> primaryMobile= new Map<String,String>();
        Map<String,List<String>> mobiles= new Map<String,List<String>>();
        Map<String,String> primaryPhone= new Map<String,String>();
        Map<String,List<String>> phones= new Map<String,List<String>>();
        //Map<String,List<String>> phonesHome= new Map<String,List<String>>();
        boolean check = false;
        List<String> phone= new List<String>();
        for(Contact c: contacts){
            contactsOb.put(c.Id, c);
        }
        Map<String, String> mapContactByIndividual = new Map<String, String>();
        for(String id: mapEmail.keySet()){
            Contact contact= contactsOb.get(id);
            List<String> email= mapEmail.get(id);
            if(email != null && email.size() > 0){
                String emPrimary = email[0];
                email.remove(0);
                primaryEmail.put(contact.IndividualId, emPrimary);
                emails.put(contact.IndividualId, email);
                mapContactByIndividual.put(contact.IndividualId,id);
            }
        }
        HDT_UTL_ContactPoint.createContactPointEmailContact(primaryEmail, emails,mapContactByIndividual);
        Map<String,boolean> mapCheck = new map<String,Boolean>();
        Map<String, String> mapContactByIndividualPhone = new Map<String, String>();

        for(String id: mapMobilePhone.keySet()){
            Contact contact= contactsOb.get(id);
            List<String> mobile= mapMobilePhone.get(id);
            if(mobile != null && mobile.size() > 0){
                mapCheck.put(contact.IndividualId,true);
                check = true;
                String emMobile = mobile[0];
                mobile.remove(0);
                primaryMobile.put(contact.IndividualId, emMobile);
                mobiles.put(contact.IndividualId, mobile);
                mapContactByIndividualPhone.put(contact.IndividualId,id);
            }
            else{
                mapCheck.put(contact.IndividualId,false);
            }
        }
        HDT_UTL_ContactPoint.createContactPointPhoneContact(primaryMobile, mobiles,mobilePrefixes, 'Mobile',mapContactByIndividualPhone);

        for(String id: mapPhone.keySet()){
            Contact contact= contactsOb.get(id);
            phone= mapPhone.get(id);
        
            if(phone != null && phone.size() > 0){
                if(mapCheck.get(contact.IndividualId)!= null && mapCheck.get(contact.IndividualId)){
                    phones.put(contact.IndividualId, phone);
                }
                else{
                    String emPhone = phone[0];
                    phone.remove(0);
                    primaryPhone.put(contact.IndividualId, emPhone);
                    phones.put(contact.IndividualId, phone);
                }
                //phonesHome.put(contact.IndividualId, phone);
                //String emPhone = phone[0];
                //phone.remove(0);
               // primaryPhone.put(contact.IndividualId, emPhone);
               // phones.put(contact.IndividualId, phone);
            }
        }
        if((mapPhone != null && !mapPhone.isEmpty()) ){
            if(primaryPhone == null){
                primaryPhone= new Map<String,String>();
            }    
            HDT_UTL_ContactPoint.createContactPointPhoneContact(primaryPhone,phones ,phonePrefixes ,'Casa',mapContactByIndividualPhone);
            //else{
               // if(phonesHome.size()>0){
              //      phonesHome.remove(primaryPhone);
              //  }
              //  HDT_UTL_ContactPoint.createContactPointPhone(primaryPhone,phones, phonePrefixes,'Casa');
           // }
        }
    }

     public static void updateContactPointFromObjectLead(List<Lead> leadNew,List<Lead> leadOld){
        
            Map<String,String> mapMobilePhone = new Map<String,String>();
            Map<String,String> mapPhone = new Map<String,String>();
            Map<String,String> mapEmail = new Map<String,String>();
            Map<String,String> mapMobilePhoneBlank = new Map<String,String>();
            Map<String,String> mapPhoneBlank = new Map<String,String>();
            Map<String,String> mapEmailBlank = new Map<String,String>();
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
            Boolean phCheck = true;
            Boolean emCheck = true;
            for(Lead l : leadOld){
                mapMobilePhone.put(l.id,l.mobilePhone == null ? '' : l.mobilePhone);
                mapPhone.put(l.id,l.phone == null ? '' : l.phone);
                mapEmail.put(l.id,l.email == null ? '' : l.email);
            }
            Map<id, id> mapContactByIndividual = new Map<id, id>();

            for(Lead l : leadNew){
                if (String.isNotBlank(l.ConvertedContactId) &&  String.isNotBlank(l.IndividualId)) {
                    mapContactByIndividual.put(l.IndividualId,l.ConvertedContactId);
                }
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
                if(mapMobilePhone.get(l.id) != null && mapMobilePhone.get(l.id) != l.MobilePhone && (l.MobilePhone == '' || l.MobilePhone == null)){
                    mapMobilePhoneBlank.put(mapMobilePhone.get(l.id),l.id);
                    phCheck = true;
                    check = true;
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
                if(mapPhone.get(l.id) != null && mapPhone.get(l.id) != l.Phone && (l.phone == '' || l.phone == null)){
                    mapPhoneBlank.put(mapPhone.get(l.id),l.id);
                    phCheck = true;
                    check = true;
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
                if(mapEmail.get(l.id) != null && mapEmail.get(l.id) != l.Email  && (l.Email == '' || l.Email == null)){
                    mapEmailBlank.put(mapEmail.get(l.id),l.id);
                    check = true;
                    emCheck = true;
                }
                if(check){
                    listIndividual.add(l.individualid);
                }
                mapLeadInd.put(l.id,l.IndividualId);
            }
            List<ContactPointPhone> cpToUpdate = new list<ContactPointPhone>();
            List<ContactPointEmail> ceToUpdate = new list<ContactPointEmail>();
            Map<String,ContactPointPhone> individualPrimary = new map<String,ContactPointPhone>();
            map<string,String> isAlreadyExistContact = new map<String,String>();
            if(phCheck){
                List<ContactPointPhone> listCpp = HDT_QR_ContactPoint.getIndividualContactsPhoneList(listIndividual,'id,isPrimary,TelephoneNumber,Status__c,parentid');
                For(ContactPointPhone cp : listCpp){
                    isAlreadyExistContact.put(cp.parentId + '-' + cp.telephoneNumber,cp.id);
                    if(cp.isPrimary){
                        if(individualPrimary.get(cp.parentId) == null){
                            individualPrimary.put(cp.parentid,cp);
                        }
                    }
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
                    else if(mapToUpdateMobile.get(cp.TelephoneNumber) != null){
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
                    else if(mapMobilePhoneBlank.get(cp.TelephoneNumber) != null){
                        cp.IsPrimary = false;
                        cpToUpdate.add(cp);
                    }
                    else if(mapPhoneBlank.get(cp.TelephoneNumber) != null){
                        cp.IsPrimary = false;
                        cpToUpdate.add(cp);
                    }

                }
            }
            if(emCheck){
                List<ContactPointEmail> listCpe = HDT_QR_ContactPoint.getIndividualContactsEmailList(listIndividual,'id,isPrimary,EmailAddress,Status__c,parentid');
                for(ContactPointEmail cp : listCpe){
                    isAlreadyExistContact.put(cp.parentId + '-' + cp.EmailAddress,cp.id);
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
                    else if(mapEmailBlank.get(cp.EmailAddress) != null){
                        cp.IsPrimary = false;
                        ceToUpdate.add(cp);
                    }
                }
            }


            if(mapCreateMobilePhone.size() > 0){
                for(String key : mapCreateMobilePhone.keyset()){
                    String keyToCheck = mapLeadInd.get(key) + '-' + mapCreateMobilePhone.get(key);
                    if(isAlreadyExistContact.get(keyToCheck) == null){          
                        ContactPointPhone c = HDT_UTL_ContactPoint.instanceContactPointPhone(mapCreateMobilePhone.get(key),mobilePrefixesToCreate.get(mapCreateMobilePhone.get(key)), true);
                        if(individualPrimary.get(mapLeadInd.get(key)) != null){
                            ContactPointPhone cp1 = new ContactPointPhone();
                            cp1.id = individualPrimary.get(mapLeadInd.get(key)).id;
                            cp1.isPrimary = false;
                            cpToUpdate.add(cp1);

                        }
                        c = HDT_UTL_ContactPoint.instanceContactPointPhone(mapCreateMobilePhone.get(key),mobilePrefixesToCreate.get(mapCreateMobilePhone.get(key)), true,'Mobile');
                        c.parentid = mapLeadInd.get(key);
                        c.SendToMarketingCloud__c = true;
                        cpToUpdate.add(c);
                    }
                    else{
                        if(individualPrimary.get(mapLeadInd.get(key)) != null){
                            ContactPointPhone cp2 = new ContactPointPhone();
                            cp2.id = individualPrimary.get(mapLeadInd.get(key)).id;
                            cp2.isPrimary = false;
                            cpToUpdate.add(cp2);

                        }
                        ContactPointPhone cp1 = new ContactPointPhone();
                        cp1.id = isAlreadyExistContact.get(keyToCheck);
                        cp1.isPrimary = true;
                        cpToUpdate.add(cp1);
                    }   
                }
            }
            if(mapCreatePhone.size() > 0){
                 for(String key : mapCreatePhone.keyset()){
                    String keyToCheck = mapLeadInd.get(key) + '-' + mapCreatePhone.get(key);
                    if(isAlreadyExistContact.get(keyToCheck) == null){          
                        boolean ck = false;
                        if(individualPrimary.get(mapLeadInd.get(key)) == null){
                            ck = true;
                        }
                        ContactPointPhone c = HDT_UTL_ContactPoint.instanceContactPointPhone(mapCreatePhone.get(key),phonePrefixesToCreate.get(mapCreatePhone.get(key)),ck,'Casa');
                        c.parentid = mapLeadInd.get(key);
                        c.SendToMarketingCloud__c = true;
                        cpToUpdate.add(c);
                    }
                    else{
                        if(individualPrimary.get(mapLeadInd.get(key)) == null){
                            ContactPointPhone cp1 = new ContactPointPhone();
                            cp1.id = isAlreadyExistContact.get(keyToCheck);
                            cp1.isPrimary = true;
                            cpToUpdate.add(cp1);
                        }
                    }
                }
            }
            if(mapCreateEmail.size() > 0){
                 for(String key : mapCreateEmail.keyset()){
                    String keyToCheck = mapLeadInd.get(key) + '-' + mapCreateEmail.get(key);
                    if(isAlreadyExistContact.get(keyToCheck) == null){      
                        ContactPointEmail c = HDT_UTL_ContactPoint.instanceContactPointEmail(mapCreateEmail.get(key),true);
                        c.parentid = mapLeadInd.get(key);
                        c.SendToMarketingCloud__c = true;
                        ceToUpdate.add(c);
                    }
                    else{
                        ContactPointEmail cp1 = new ContactPointEmail();
                        cp1.id = isAlreadyExistContact.get(keyToCheck);
                        cp1.isPrimary = true;
                        ceToUpdate.add(cp1);
                    }
                }
            }


            /*if(mapCreateMobilePhone.size() > 0){
                for(String key : mapCreateMobilePhone.keyset()){
                    ContactPointPhone c = HDT_UTL_ContactPoint.instanceContactPointPhone(mapCreateMobilePhone.get(key),mobilePrefixesToCreate.get(mapCreateMobilePhone.get(key)), true);
                    if(individualPrimary.get(mapLeadInd.get(key)) != null){
                        ContactPointPhone cp1 = new ContactPointPhone();
                        cp1.id = individualPrimary.get(mapLeadInd.get(key)).id;
                        cp1.isPrimary = false;
                        cpToUpdate.add(cp1);

                    }
                    c = HDT_UTL_ContactPoint.instanceContactPointPhone(mapCreateMobilePhone.get(key),mobilePrefixesToCreate.get(mapCreateMobilePhone.get(key)), true,'Mobile');
                    c.parentid = mapLeadInd.get(key);
                    c.SendToMarketingCloud__c = true;
                    cpToUpdate.add(c);
                }
            }
            if(mapCreatePhone.size() > 0){
                 for(String key : mapCreatePhone.keyset()){
                    boolean ck = false;
                    if(individualPrimary.get(mapLeadInd.get(key)) == null){
                        ck = true;
                    }
                    ContactPointPhone c = HDT_UTL_ContactPoint.instanceContactPointPhone(mapCreatePhone.get(key),phonePrefixesToCreate.get(mapCreatePhone.get(key)),ck,'Casa');
                    c.parentid = mapLeadInd.get(key);
                    c.SendToMarketingCloud__c = true;
                     cpToUpdate.add(c);
                }
            }
            if(mapCreateEmail.size() > 0){
                 for(String key : mapCreateEmail.keyset()){
                    ContactPointEmail c = HDT_UTL_ContactPoint.instanceContactPointEmail(mapCreateEmail.get(key),true);
                    c.parentid = mapLeadInd.get(key);
                    c.SendToMarketingCloud__c = true;
                     ceToUpdate.add(c);
                }
            } */
/*
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
    */       
            if (!mapContactByIndividual.isEmpty()) {
                for (ContactPointEmail tempContEmail : ceToUpdate) {
                    if (mapContactByIndividual.get(tempContEmail.ParentId)!=null) {
                        tempContEmail.Contact__c=mapContactByIndividual.get(tempContEmail.ParentId);
                    }
                }
                for (ContactPointPhone tempContp : cpToUpdate) {
                    if (mapContactByIndividual.get(tempContp.ParentId)!=null) {
                        tempContp.Contact__c=mapContactByIndividual.get(tempContp.ParentId);
                    }
                }
            }
            if(ceToUpdate != null && ceToUpdate.size() > 0){
                HDT_SRV_ContactPoint.upsertContactPointEmail(ceToUpdate);
            }
            if(cpToUpdate != null && cpToUpdate.size() > 0){
                HDT_SRV_ContactPoint.upsertContactPointPhone(cpToUpdate);
            }
        }

        public static void updateContactPointFromObjectContact(List<Contact> contactNew,List<contact> contactOld){
        
            Map<String,String> mapMobilePhone = new Map<String,String>();
            Map<String,String> mapPhone = new Map<String,String>();
            Map<String,String> mapEmail = new Map<String,String>();
            Map<String,String> mapMobilePhoneBlank = new Map<String,String>();
            Map<String,String> mapPhoneBlank = new Map<String,String>();
            Map<String,String> mapEmailBlank = new Map<String,String>();
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
            Boolean phCheck = true;
            Boolean emCheck = true;
            System.debug('*****CONTROL');
            for(contact l : contactOld){
                mapMobilePhone.put(l.id,l.mobilePhone == null ? '' : l.mobilePhone);
                mapPhone.put(l.id,l.phone == null ? '' : l.phone);
                mapEmail.put(l.id,l.email == null ? '' : l.email);
            }
            System.debug('*****CONTROL4:' + mapPhone);
            for(contact l : contactNew){
                boolean check = false;
                if(mapMobilePhone.get(l.id) != null && mapMobilePhone.get(l.id) != l.MobilePhone && l.MobilePhone != '' && l.MobilePhone != null){
                    if(mapMobilePhone.get(l.id) == ''){
                        mapCreateMobilePhone.put(l.Id,l.MobilePhone);
                        mobilePrefixesToCreate.put(l.MobilePhone, l.MobilePhonePrefix__c);
                        check = true;
                    }
                    else{
                        mapToUpdateMobile.put(mapMobilePhone.get(l.id), l.MobilePhone);
                        mobilePrefixesToUpdate.put(l.MobilePhone, l.MobilePhonePrefix__c);
                    	check = true;
                    	phCheck = true;
                    }
                }
                if(mapMobilePhone.get(l.id) != null && mapMobilePhone.get(l.id) != l.MobilePhone && (l.MobilePhone == '' || l.MobilePhone == null)){
                    
                    mapMobilePhoneBlank.put(mapMobilePhone.get(l.id),l.id);
                    phCheck = true;
                    check = true;
                }
                System.debug('*****CONTROL');
                if(mapPhone.get(l.id) != null && mapPhone.get(l.id) != l.Phone && l.phone != '' && l.phone != null){
                    System.debug('*****CONTROL2');
                    if(mapPhone.get(l.id) == ''){
                        System.debug('*****CONTRO3');
                        mapCreatePhone.put(l.Id,l.Phone);
                        check = true;
                        phonePrefixesToCreate.put(l.Phone, l.PhonePrefix__c);
                    }
                    else{
                        mapToUpdatePhone.put(mapPhone.get(l.id), l.Phone);
                        phonePrefixesToUpdate.put(l.Phone, l.PhonePrefix__c);
                        check = true;
                        phCheck = true;
    
                    }
                }
                if(mapPhone.get(l.id) != null && mapPhone.get(l.id) != l.Phone && (l.phone == '' || l.phone == null)){
                    mapPhoneBlank.put(mapPhone.get(l.id),l.id);
                    phCheck = true;
                    check = true;
                }
                if(mapEmail.get(l.id) != null && mapEmail.get(l.id) != l.Email  && l.Email != '' && l.Email != null){
                    if(mapEmail.get(l.id) == ''){
                        mapCreateEmail.put(l.Id,l.Email);
                        check = true;
                    }
                    else{
                        mapToUpdateEmail.put(mapEmail.get(l.id), l.Email);
                    	check = true;
                    	emCheck = true;
                    }
                }
                if(mapEmail.get(l.id) != null && mapEmail.get(l.id) != l.Email  && (l.Email == '' || l.Email == null)){
                    mapEmailBlank.put(mapEmail.get(l.id),l.id);
                    check = true;
                    emCheck = true;
                }
                //if(check){
                    listIndividual.add(l.individualid);
                //}
                mapLeadInd.put(l.id,l.IndividualId);
            }
            // List<ContactPointPhone> cpToUpdate = new list<ContactPointPhone>();
            List<ContactPointEmail> ceToUpdate = new list<ContactPointEmail>();
            // map<String,ContactPointPhone> cpToUpdatePrim = new map<String,ContactPointPhone>();
            // map<string,ContactPointEmail> ceToUpdatePrim = new map<string,ContactPointEmail>();
            
            /** Andrei Necsulescu - 27/08/2021
             * Added cpToUpdateMap map to avoid duplicated ids when removing one phone number and inserting another
             */
            map<String,ContactPointPhone> cpToUpdateMap = new map<String,ContactPointPhone>();
            List<ContactPointPhone> cpToUpsert = new list<ContactPointPhone>();

            
            map<string,ContactPointPhone> individualPrimary = new map<String,ContactPointPhone>();
            map<string,String> isAlreadyExistContact = new map<String,String>();
            if(phCheck){
                List<ContactPointPhone> listCpp = HDT_QR_ContactPoint.getIndividualContactsPhoneList(listIndividual,'id,TelephoneNumber,isPrimary,Status__c,parentid');
                For(ContactPointPhone cp : listCpp){
                    if(cp.isPrimary){
                        if(individualPrimary.get(cp.parentId)== null){
                            individualPrimary.put(cp.parentid,cp);
                        }
                    }
                    isAlreadyExistContact.put(cp.parentId + '-' + cp.telephoneNumber,cp.id);
                    if(mapToUpdatePhone.get(cp.TelephoneNumber) != null){
                        if(cp.Status__c == 'Non Verificato'){
                            cp.TelephoneNumber = mapToUpdatePhone.get(cp.TelephoneNumber);
                            cp.Prefix__c = phonePrefixesToUpdate.get(cp.TelephoneNumber);
                            // System.debug('***LINE 504 added cp: ' + cp);
                            // cpToUpdate.add(cp);

                            if (cpToUpdateMap.containsKey(cp.Id)) {
                                cpToUpdateMap.get(cp.Id).TelephoneNumber = mapToUpdatePhone.get(cp.TelephoneNumber);
                                cpToUpdateMap.get(cp.Id).Prefix__c = phonePrefixesToUpdate.get(cp.TelephoneNumber);
                            } else {
                                cpToUpdateMap.put(cp.Id, cp);
                            }

                        }
                        else{
                            ContactPointPhone c = HDT_UTL_ContactPoint.instanceContactPointPhone(mapToUpdatePhone.get(cp.TelephoneNumber),phonePrefixesToUpdate.get(cp.TelephoneNumber),false);
                            c.parentid = cp.parentId;
                            c.isPrimary = cp.isPrimary;
                            cp.isPrimary = false;
                            c.SendToMarketingCloud__c = true;
                            // System.debug('***LINE 602 added c: ' + c);
                            // cpToUpdate.add(c);
                            // System.debug('***LINE 605 added cp: ' + cp);
                            // cpToUpdate.add(cp);

                            cpToUpsert.add(c);
                            if (cpToUpdateMap.containsKey(cp.Id)) {
                                cpToUpdateMap.get(cp.Id).IsPrimary = false;
                            } else {
                                cpToUpdateMap.put(cp.Id, cp);
                            }
                            
                        }
                    }
                    else if(mapToUpdateMobile.get(cp.TelephoneNumber) != null){
                        if(cp.Status__c == 'Non Verificato'){
                            cp.TelephoneNumber = mapToUpdateMobile.get(cp.TelephoneNumber);
                            cp.Prefix__c= mobilePrefixesToUpdate.get(cp.TelephoneNumber);
                            // System.debug('***LINE 614 added cp: ' + cp);
                            // cpToUpdate.add(cp);

                            if (cpToUpdateMap.containsKey(cp.Id)) {
                                cpToUpdateMap.get(cp.Id).TelephoneNumber = mapToUpdateMobile.get(cp.TelephoneNumber);
                                cpToUpdateMap.get(cp.Id).Prefix__c = mobilePrefixesToUpdate.get(cp.TelephoneNumber);
                            } else {
                                cpToUpdateMap.put(cp.Id, cp);
                            }
                        }
                        else{
                            ContactPointPhone c = HDT_UTL_ContactPoint.instanceContactPointPhone(mapToUpdateMobile.get(cp.TelephoneNumber),mobilePrefixesToUpdate.get(cp.TelephoneNumber),false);
                            c.parentid = cp.parentId;
                            c.SendToMarketingCloud__c = true;
                            c.isPrimary = cp.isPrimary;
                            cp.isPrimary = false;
                            c.SendToMarketingCloud__c = true;
                            // System.debug('***LINE 624 added c: ' + c);
                            // cpToUpdate.add(c);
                            // System.debug('***LINE 625 added cp: ' + cp);
                            // cpToUpdate.add(cp);

                            cpToUpsert.add(c);
                            if (cpToUpdateMap.containsKey(cp.Id)) {
                                cpToUpdateMap.get(cp.Id).IsPrimary = false;
                            } else {
                                cpToUpdateMap.put(cp.Id, cp);
                            }
                            
                        }
                    }
                    else if(mapMobilePhoneBlank.get(cp.TelephoneNumber) != null){
                        cp.IsPrimary = false;
                        // System.debug('***LINE 632 added cp: ' + cp);
                        // cpToUpdate.add(cp);

                        if (cpToUpdateMap.containsKey(cp.Id)) {
                            cpToUpdateMap.get(cp.Id).IsPrimary = false;
                        } else {
                            cpToUpdateMap.put(cp.Id, cp);
                        }
                    }
                    else if(mapPhoneBlank.get(cp.TelephoneNumber) != null){
                        cp.IsPrimary = false;
                        // System.debug('***LINE 637 added cp: ' + cp);
                        // cpToUpdate.add(cp);

                        if (cpToUpdateMap.containsKey(cp.Id)) {
                            cpToUpdateMap.get(cp.Id).IsPrimary = false;
                        } else {
                            cpToUpdateMap.put(cp.Id, cp);
                        }
                    }

                }
            }
            if(emCheck){
                List<ContactPointEmail> listCpe = HDT_QR_ContactPoint.getIndividualContactsEmailList(listIndividual,'id,EmailAddress,Status__c,parentid');
                for(ContactPointEmail cp : listCpe){
                    isAlreadyExistContact.put(cp.parentId + '-' + cp.EmailAddress,cp.id);
                    if(mapToUpdateEmail.get(cp.EmailAddress) != null){
                        if(cp.Status__c == 'Non Verificato'){
                            cp.EmailAddress = mapToUpdateEmail.get(cp.EmailAddress);
                            ceToUpdate.add(cp);
                        }
                        else{
                            ContactPointEmail c = HDT_UTL_ContactPoint.instanceContactPointEmail(mapToUpdateEmail.get(cp.EmailAddress),false);
                            c.SendToMarketingCloud__c = true;
                            c.parentid = cp.parentId;
                            c.isPrimary = cp.isPrimary;
                            cp.isPrimary = false;
                            c.SendToMarketingCloud__c = true;
                            ceToUpdate.add(c);
                            ceToUpdate.add(cp);
                        }
                    }
                    else if(mapEmailBlank.get(cp.EmailAddress) != null){
                        cp.IsPrimary = false;
                        ceToUpdate.add(cp);
                    }
                }
            }
          
            if(mapCreateMobilePhone.size() > 0){
                for(String key : mapCreateMobilePhone.keyset()){
                    String keyToCheck = mapLeadInd.get(key) + '-' + mapCreateMobilePhone.get(key);
                    if(isAlreadyExistContact.get(keyToCheck) == null){          
                        ContactPointPhone c = HDT_UTL_ContactPoint.instanceContactPointPhone(mapCreateMobilePhone.get(key),mobilePrefixesToCreate.get(mapCreateMobilePhone.get(key)), true);
                        if(individualPrimary.get(mapLeadInd.get(key)) != null){
                            ContactPointPhone cp1 = new ContactPointPhone();
                            cp1.id = individualPrimary.get(mapLeadInd.get(key)).id;
                            cp1.isPrimary = false;
                            // System.debug('***LINE 679 added cp1: ' + cp1);
                            // cpToUpdate.add(cp1);

                            if (cpToUpdateMap.containsKey(cp1.Id)) {
                                cpToUpdateMap.get(cp1.Id).IsPrimary = false;
                            } else {
                                cpToUpdateMap.put(cp1.Id, cp1);
                            }

                        }
                        c = HDT_UTL_ContactPoint.instanceContactPointPhone(mapCreateMobilePhone.get(key),mobilePrefixesToCreate.get(mapCreateMobilePhone.get(key)), true,'Mobile');
                        c.parentid = mapLeadInd.get(key);
                        c.SendToMarketingCloud__c = true;
                        // System.debug('***LINE 686 added c: ' + c);
                        // cpToUpdate.add(c);

                        cpToUpsert.add(c);
                    }
                    else{
                        if(individualPrimary.get(mapLeadInd.get(key)) != null){
                            ContactPointPhone cp2 = new ContactPointPhone();
                            cp2.id = individualPrimary.get(mapLeadInd.get(key)).id;
                            cp2.isPrimary = false;
                            // System.debug('***LINE 694 added cp2: ' + cp2);
                            // cpToUpdate.add(cp2);

                            if (cpToUpdateMap.containsKey(cp2.Id)) {
                                cpToUpdateMap.get(cp2.Id).IsPrimary = false;
                            } else {
                                cpToUpdateMap.put(cp2.Id, cp2);
                            }

                        }
                        ContactPointPhone cp1 = new ContactPointPhone();
                        cp1.id = isAlreadyExistContact.get(keyToCheck);
                        cp1.isPrimary = true;
                        // System.debug('***LINE 701 added cp1: ' + cp1);
                        // cpToUpdate.add(cp1);

                        if (cpToUpdateMap.containsKey(cp1.Id)) {
                            cpToUpdateMap.get(cp1.Id).IsPrimary = true;
                        } else {
                            cpToUpdateMap.put(cp1.Id, cp1);
                        }
                    }   
                }
            }
            if(mapCreatePhone.size() > 0){
                 for(String key : mapCreatePhone.keyset()){
                    String keyToCheck = mapLeadInd.get(key) + '-' + mapCreatePhone.get(key);
                    if(isAlreadyExistContact.get(keyToCheck) == null){          
                        boolean ck = false;
                        if(individualPrimary.get(mapLeadInd.get(key)) == null){
                            ck = true;
                        }
                        ContactPointPhone c = HDT_UTL_ContactPoint.instanceContactPointPhone(mapCreatePhone.get(key),phonePrefixesToCreate.get(mapCreatePhone.get(key)),ck,'Casa');
                        c.parentid = mapLeadInd.get(key);
                        c.SendToMarketingCloud__c = true;
                        // System.debug('***LINE 717 added c: ' + c);
                        // cpToUpdate.add(c);

                        cpToUpsert.add(c);
                    }
                    else{
                        if(individualPrimary.get(mapLeadInd.get(key)) == null){
                            ContactPointPhone cp1 = new ContactPointPhone();
                            cp1.id = isAlreadyExistContact.get(keyToCheck);
                            cp1.isPrimary = true;
                            // System.debug('***LINE 725 added cp1: ' + cp1);
                            // cpToUpdate.add(cp1);

                            if (cpToUpdateMap.containsKey(cp1.Id)) {
                                cpToUpdateMap.get(cp1.Id).IsPrimary = true;
                            } else {
                                cpToUpdateMap.put(cp1.Id, cp1);
                            }
                        }
                    }
                }
            }
            if(mapCreateEmail.size() > 0){
                 for(String key : mapCreateEmail.keyset()){
                    String keyToCheck = mapLeadInd.get(key) + '-' + mapCreateEmail.get(key);
                    if(isAlreadyExistContact.get(keyToCheck) == null){      
                        ContactPointEmail c = HDT_UTL_ContactPoint.instanceContactPointEmail(mapCreateEmail.get(key),true);
                        c.parentid = mapLeadInd.get(key);
                        c.SendToMarketingCloud__c = true;
                        ceToUpdate.add(c);
                    }
                    else{
                        ContactPointEmail cp1 = new ContactPointEmail();
                        cp1.id = isAlreadyExistContact.get(keyToCheck);
                        cp1.isPrimary = true;
                        ceToUpdate.add(cp1);
                    }
                }
            }
    
            if(ceToUpdate != null && ceToUpdate.size() > 0){
                HDT_SRV_ContactPoint.upsertContactPointEmail(ceToUpdate);
            }
            // if(cpToUpdate != null && cpToUpdate.size() > 0){
            //     HDT_SRV_ContactPoint.upsertContactPointPhone(cpToUpdate);
            // }

            cpToUpsert.addAll(cptoUpdateMap.values());
            if(cpToUpsert != null && cpToUpsert.size() > 0){
                HDT_SRV_ContactPoint.upsertContactPointPhone(cpToUpsert);
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
        List<Lead> leads = leadQr.getRecordsById(leadIds);
        /*List<Individual> indv =*/ HDT_UTL_Individual.createIndividualLead(leads);
       // List<Lead> leads = leadQr.getRecordsById(leadIds);
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

   
    public static void convertLeadPrivacy(Id contactId,Id leadId) {

        Lead l = leadQr.getRecordById(String.valueOf(leadId));
        

        Contact cont = HDT_UTL_Individual.convertLeadToContact(contactId,l.IndividualId);
        
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

    public static void updatePrivacyConsentPostSales(Id recordId,String versioneInformativaMarketing,String iniziativaConsensoMarketing,Date dataConsensoMarketing,String companyConsensoMarketing,String versioneInformativaProfilazione,String iniziativaConsensoProfilazione, Date dataConsensoProfilazione,String companyConsensoProfilazione){
                                                      
        Individual ind =new Individual(Id = recordId ,  MarketingPrivacyVersion__c = versioneInformativaMarketing,MarketingCompanyConsent__c = companyConsensoMarketing,
         PrivacyMarketingConsentInitiative__c = iniziativaConsensoMarketing,PrivacyMarketingChoiceDate__c = dataConsensoMarketing,ProfilingPrivacyVersion__c = versioneInformativaProfilazione,
         PrivacyProfilingConsentInitiative__c = iniziativaConsensoProfilazione,PrivacyProfilingChoiceDate__c = dataConsensoProfilazione,ProfilingCompanyConsent__c = companyConsensoProfilazione);
        
                
        HDT_SRV_Individual.checkCreateAccess(ind);
        /*Individual indvid=*/ HDT_SRV_Individual.updateRecord(ind);

    }

    public static void updatePrivacyConsentContractualEnvelope(Id recordId,String versioneInformativaMarketing,String iniziativaConsensoMarketing,Date dataConsensoMarketing,String companyConsensoMarketing,String versioneInformativaProfilazione,String iniziativaConsensoProfilazione, Date dataConsensoProfilazione,String companyConsensoProfilazione){

        Individual ind =new Individual(Id = recordId ,  MarketingPrivacyVersion__c = versioneInformativaMarketing,MarketingCompanyConsent__c = companyConsensoMarketing,
         PrivacyMarketingConsentInitiative__c = iniziativaConsensoMarketing,PrivacyMarketingChoiceDate__c = dataConsensoMarketing,ProfilingPrivacyVersion__c = versioneInformativaProfilazione,
         PrivacyProfilingConsentInitiative__c = iniziativaConsensoProfilazione,PrivacyProfilingChoiceDate__c = dataConsensoProfilazione,ProfilingCompanyConsent__c = companyConsensoProfilazione);
        
                
        HDT_SRV_Individual.checkCreateAccess(ind);
        /*Individual indvid=*/ HDT_SRV_Individual.updateRecord(ind);

    }

    public static void updatePrivacyConsentFormWebEvent(Id leadId,String versioneInformativaMarketing,String iniziativaConsensoMarketing,Date dataConsensoMarketing,String companyConsensoMarketing){

        Individual ind =new Individual(Id = leadId,MarketingPrivacyVersion__c = versioneInformativaMarketing,MarketingCompanyConsent__c = companyConsensoMarketing,
        PrivacyMarketingConsentInitiative__c = iniziativaConsensoMarketing,PrivacyMarketingChoiceDate__c = dataConsensoMarketing);

        HDT_SRV_Individual.checkCreateAccess(ind);
        /*Individual indvid=*/ HDT_SRV_Individual.updateRecord(ind);
    }

    public static void updatePrivacyConsentFormWebWinback(Id leadId,String versioneInformativaMarketing,String iniziativaConsensoMarketing,Date dataConsensoMarketing,String companyConsensoMarketing){

        Individual ind =new Individual(Id = leadId,MarketingPrivacyVersion__c = versioneInformativaMarketing,MarketingCompanyConsent__c = companyConsensoMarketing,
        PrivacyMarketingConsentInitiative__c = iniziativaConsensoMarketing,PrivacyMarketingChoiceDate__c = dataConsensoMarketing);

        HDT_SRV_Individual.checkCreateAccess(ind);
        /*Individual indvid=*/ HDT_SRV_Individual.updateRecord(ind);
    }

    public static void updatePrivacyConsentFormWebCallback(Id leadId,String versioneInformativaMarketing,String iniziativaConsensoMarketing,Date dataConsensoMarketing,String companyConsensoMarketing){

        Individual ind =new Individual(Id = leadId,MarketingPrivacyVersion__c = versioneInformativaMarketing,MarketingCompanyConsent__c = companyConsensoMarketing,
        PrivacyMarketingConsentInitiative__c = iniziativaConsensoMarketing,PrivacyMarketingChoiceDate__c = dataConsensoMarketing);

        HDT_SRV_Individual.checkCreateAccess(ind);
        /*Individual indvid=*/ HDT_SRV_Individual.updateRecord(ind);
    }

    public static void updatePrivacyConsentSol(Id contactId,String versioneInformativaMarketing,String iniziativaConsensoMarketing,Date dataConsensoMarketing,String companyConsensoMarketing,String email){
		Contact cont = contactQr.getRecordById(contactId);
        Individual ind =new Individual(Id = cont.IndividualId,MarketingPrivacyVersion__c = versioneInformativaMarketing,MarketingCompanyConsent__c = companyConsensoMarketing, 
        PrivacyMarketingConsentInitiative__c = iniziativaConsensoMarketing,PrivacyMarketingChoiceDate__c = dataConsensoMarketing);
        
        ContactPointEmail contemail = HDT_QR_ContactPoint.searchContactPointEmail(email);
        if(contemail !=null){
            ContactPointEmail emailContact = new ContactPointEmail(Id = contemail.Id,Type__c = 'E-mail SOL');
            HDT_SRV_ContactPointEmail.updateRecord(emailContact);
        }else{
            ContactPointEmail emailContact = new ContactPointEmail(ParentId = ind.id,EmailAddress = email,Type__c = 'E-mail SOL');
         	HDT_SRV_ContactPointEmail.checkCreateAccess(emailContact);
            HDT_SRV_ContactPointEmail.createRecord(emailContact);
        }
            HDT_SRV_Individual.checkCreateAccess(ind);
            /*Individual indvid=*/ HDT_SRV_Individual.updateRecord(ind);
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

        public static Map<String,Object> generateMapMarketingFieldsValue(String versioneInformativaMarketing,String iniziativaConsensoMarketing,Date dataConsensoMarketing,String companyConsensoMarketing){
            Map<String,Object> maps = new Map<String,Object> ();

          
            maps.put('MarketingPrivacyVersion__c ',versioneInformativaMarketing);
            maps.put('PrivacyMarketingConsentInitiative__c',iniziativaConsensoMarketing);
            maps.put('PrivacyMarketingChoiceDate__c',dataConsensoMarketing);
            maps.put('MarketingCompanyConsent__c',companyConsensoMarketing);
            
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
            System.debug('*******Preparazione Alla Creazione Individual');
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
        @AuraEnabled
        public static boolean  resendContactEmailToMarketing (String contactEmailId){
            boolean res = true;
            try{
                    ContactPointEmail cpe = new ContactPointEmail();
                    cpe.id = contactEmailId;
                    cpe.SendToMarketingCloud__c = true;
                    HDT_SRV_ContactPoint.upsertContactPointEmail(new List<ContactPointEmail>{cpe});
            }catch(Exception e){
                res = false;
            }
            return res;
        }
        @AuraEnabled
        public static boolean  resendContactPhoneToMarketing (String contactPhoneId){
            boolean res = true;
            try{
                    ContactPointPhone cpe = new ContactPointPhone();
                    cpe.id = contactPhoneId;
                    cpe.SendToMarketingCloud__c = true;
                    HDT_SRV_ContactPoint.updateContactPointPhone(new List<ContactPointPhone>{cpe});
            }catch(Exception e){
                res = false;
            }
            return res;
        }

}