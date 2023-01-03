/**
 * @author 'Sabina Levonja' (sabina.levonja@dunegroup.it)
 * @description HDT_TRH_Contact - 
 */

 public inherited sharing class HDT_TRH_Contact extends HDT_TRH_TriggerHandler {

    // public override void beforeInsert(){}
    // public override void beforeDelete(){}
    // public override void afterDelete(){}
    // public override void afterUndelete(){}


    public override void beforeInsert(){
        List<Contact> listCnt = (List<Contact>)trigger.new;

        for (Contact tempCnt : listCnt) {
            if((String.isNotBlank(tempCnt.FiscalCode__c) && (tempCnt.FiscalCode__c.length()!=16 && tempCnt.FiscalCode__c.length()!=11)) || (String.isNotBlank(tempCnt.VATNumber__c) && tempCnt.VATNumber__c.length()!=11 && !tempCnt.VATNumber__c.isNumeric())){
                tempCnt.addError('Inserire una Partita Iva o un Codice Fiscale Valido');
            }

            if (String.isNotBlank(tempCnt.FiscalCode__c) && tempCnt.FiscalCode__c.length()==16) {
                tempCnt.FiscalCode__c = tempCnt.FiscalCode__c.toUpperCase();
                String lastLetter = tempCnt.FiscalCode__c.right(1);
                String fiscalCodeToCheck = tempCnt.FiscalCode__c.left(15);
                String letterControled = HDT_UTL_CalculateFiscalCode.getControlLetter(fiscalCodeToCheck);

                if(lastLetter != letterControled ){
                    tempCnt.addError('Codice fiscale non valido');
                }
            }
            else if(String.isNotBlank(tempCnt.FiscalCode__c) && tempCnt.FiscalCode__c.length()==11 && tempCnt.FiscalCode__c.isNumeric()){
                String lastNum = tempCnt.FiscalCode__c.right(1);
                String pIvaToCheck = tempCnt.FiscalCode__c.left(10);
                String numControled = HDT_UTL_CalculateFiscalCode.getControlNumberPiva(pIvaToCheck);

                if(lastNum != numControled ){
                    tempCnt.addError('Partita Iva non valida');
                }
            }

            if(String.isNotBlank(tempCnt.VATNumber__c)){
                String lastNumVat = tempCnt.VATNumber__c.right(1);
                String vatToCheck = tempCnt.VATNumber__c.left(10);
                String numVatControled = HDT_UTL_CalculateFiscalCode.getControlNumberPiva(vatToCheck);

                if(lastNumVat != numVatControled ){
                    tempCnt.addError('Partita Iva non valida');
                }
            }
        }

        HDT_UTL_CompanyOwner.feedCompanyOwner(trigger.new);
        HDT_UTL_GestionePrivacy.checkCloneCompany(trigger.new);
        changeRecordType(trigger.new);
    }

    public override void afterInsert(){

        List<Contact> contList = Trigger.New;
        // for(Contact contact : contList){
        //     HDT_UTL_GestionePrivacy.setPrivacyForContact(contact);
        // }
        //HRDTR-00_HRAWRM-881 11/10/2021
        List<Contact> contactToCreatePrivacy = new List<Contact>();
        for (Contact tempContact : contList) {
            if (String.isBlank(tempContact.IndividualId)) {
                contactToCreatePrivacy.add(tempContact);
            }
            
        }
        //HRDTR-00_HRAWRM-881 11/10/2021
        HDT_UTL_GestionePrivacy.setPrivacyForContact(contactToCreatePrivacy);
        createAmministratoreCondominio(contList);

    }

    public override void beforeUpdate(){
        // System.debug('*******TriggerContact');
        HDT_UTL_GestionePrivacy.updateContactPointFromObjectContact(trigger.new,trigger.old);
    }
    private static void changeRecordType(List<Contact> listContract ){
        Id recordTypeIdAfter = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('HDT_RT_AfterCreate').getRecordTypeId();
        for (Contact con : listContract) {
            con.recordTypeId=recordTypeIdAfter;
        }
    }
    /**@frpanico 2022-06-03
     * Registra Amministratore Condominio su SAP 
     * funziona solo se viene creato un solo contatto
     */
    private static void createAmministratoreCondominio(List<Contact> contactList)
    {
        if(contactList.size() > 1)
        {
            return;
        }
        Contact con = contactList[0];
        List<AccountContactRelation> acrList = [SELECT Id,
            Roles
            FROM AccountContactRelation
            WHERE contactId = :con.Id
            WITH SECURITY_ENFORCED
        ];
    }

   /* public override void afterUpdate(){
        System.debug('*******TriggerContact');
        HDT_UTL_GestionePrivacy.updateContactPointFromObjectContact(trigger.new,trigger.old);
    }*/
/*    Map<String,Contact> mapContact = new Map<String,Contact>();
    List<Contact> listNewContact = trigger.new;
    List<ContactPointEmail> insertEmails= new List<ContactPointEmail>();
    List<ContactPointEmail> updateEmails= new List<ContactPointEmail>();
    List<Contact> listOldContact= trigger.old;

    for(Contact c: listOldContact){
        mapContact.put(c.id, c);
    }

    List<Contact> contactsToUpdate= new List<Contact>();
    List<String> individualIds= new List<String>();
    List<String> emails= new List<String>();
    Map<String,ContactPointEmail> em= new Map<String,ContactPointEmail>();


    for (Contact con: listNewContact){
        Contact oldContact= mapContact.get(con.id);
        
        if(con.Email != oldContact.Email ){
            individualIds.add(con.IndividualId);
            emails.add(con.Email);  
            contactsToUpdate.add(con);
        }
    }

    List<ContactPointEmail> oldEmails= HDT_QR_ContactPoint.getOldContactEmails(individualIds, emails);

    for(ContactPointEmail c: oldEmails ){
        em.put(c.ParentId, c);
    }
    for(Contact con: contactsToUpdate){
        if(em.size()>0){
            if(em.get(con.IndividualId) != null){
                ContactPointEmail c= em.get(con.IndividualId);
                if(c.Status__c == 'Verificato'){
                        System.debug('new');
                        ContactPointEmail newEmail= new ContactPointEmail (EmailAddress= con.Email,ParentId= con.IndividualId,isPrimary= true);
                        insertEmails.add(newEmail);
                    }else{
                        System.debug('old');
                        c= new ContactPointEmail (Id= c.Id, EmailAddress=con.Email);
                        updateEmails.add(c);
                    }
            }
        }else{
            ContactPointEmail newEmail= new ContactPointEmail (EmailAddress= con.Email,ParentId= con.IndividualId,isPrimary= true);
                insertEmails.add(newEmail);
        }
        
    }

    Map<String,Contact> mapsContact = new Map<String,Contact>();
    List<Contact> listsNewContact = trigger.new;
    List<ContactPointPhone> insertPhones= new List<ContactPointPhone>();
    List<ContactPointPhone> updatePhones= new List<ContactPointPhone>();
    List<Contact> listsOldContact= trigger.old;

    for(Contact c: listsOldContact){
        mapsContact.put(c.id, c);
    }



    List<Contact> contactsToUpd= new List<Contact>();
    List<String> indvIds= new List<String>();
    List<String> phones= new List<String>();
    Map<String,ContactPointPhone> phone= new Map<String,ContactPointPhone>();


    for (Contact con: listNewContact){
        Contact oldContact= mapContact.get(con.id);
        
        if(con.Phone != oldContact.Phone ){
            indvIds.add(con.IndividualId);
            phones.add(con.Phone);  
            contactsToUpd.add(con);
        }
    }

    List<ContactPointPhone> oldPhones= HDT_QR_ContactPoint.getOldContactsPhone(indvIds, phones);

    for(ContactPointPhone c: oldPhones ){
        phone.put(c.ParentId, c);
    }
    for(Contact cont: contactsToUpd){
        if(phone.size()>0){
            if(phone.get(cont.IndividualId) != null){
                ContactPointPhone c= phone.get(cont.IndividualId);
                if(c.Status__c == 'Verificato'){
                        ContactPointPhone newPhone= new ContactPointPhone (TelephoneNumber= cont.Phone, Prefix__c= cont.PhonePrefix__c, ParentId= cont.IndividualId,isPrimary= true, Type__c='Casa');
                        insertPhones.add(newPhone);
                    }else{
                        c= new ContactPointPhone (Id= c.Id, TelephoneNumber= cont.Phone, Prefix__c= cont.PhonePrefix__c);
                        updatePhones.add(c);
                    }
            }
        }else{
            ContactPointPhone newPhone= new ContactPointPhone (TelephoneNumber= cont.Phone, Prefix__c= cont.PhonePrefix__c,ParentId= cont.IndividualId,isPrimary= true, Type__c='Casa');
            insertPhones.add(newPhone);
        }
        
    }
        update updatePhones;
        insert insertPhones;
        update updateEmails;
        insert insertEmails;
    } */
}
