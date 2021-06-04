trigger HDT_Contact on Contact (before insert, after insert , before update) {
    new HDT_TRH_Contact().run();
    
//     if(Trigger.isInsert && Trigger.isAfter){
//         for(Contact contact : Trigger.New){
//             HDT_UTL_GestionePrivacy.setPrivacyForContact(contact);
//         }
//     }
    
//      /**
//      * @author Elfrida Kora(elfrida.kora@dunegroup.it)
//      * @description trigger Contact new and old
//      */
   
//     if(Trigger.isUpdate && Trigger.isBefore){

//         Map<String,Contact> mapContact = new Map<String,Contact>();
//         List<Contact> listNewContact = trigger.new;
//         List<ContactPointEmail> insertEmails= new List<ContactPointEmail>();
//         List<ContactPointEmail> updateEmails= new List<ContactPointEmail>();
//         List<Contact> listOldContact= trigger.old;

//         for(Contact c: listOldContact){
//             mapContact.put(c.id, c);
//         }
//         for (Contact con: listNewContact){
//             Contact oldContact= mapContact.get(con.id);
            
//             if(con.Email != oldContact.Email ){
            
//                 ContactPointEmail oldEmail= HDT_QR_ContactPoint.getoldcontactemail(con.IndividualId, con.Email);
//                 if(oldEmail.Status__c == 'Verificato'){
//                     ContactPointEmail newEmail= new ContactPointEmail (EmailAddress= con.Email,ParentId= con.IndividualId,isPrimary= true);
//                     insertEmails.add(newEmail);
//                 }else{
//                     oldEmail= new ContactPointEmail (Id= oldEmail.Id, EmailAddress=con.Email);
//                     updateEmails.add(oldEmail);
//                 }
//             }

//             Map<String,Contact> mapsContact = new Map<String,Contact>();
//             List<Contact> listsNewContact = trigger.new;
//             List<ContactPointPhone> insertPhones= new List<ContactPointPhone>();
//             List<ContactPointPhone> updatePhones= new List<ContactPointPhone>();
//             List<Contact> listsOldContact= trigger.old;

//             for(Contact c: listsOldContact){
//                 mapsContact.put(c.id, c);
//             }

//             for (Contact cont: listsNewContact){
//                 Contact oldContacts= mapsContact.get(cont.id);
                
//                 if(cont.Phone != oldContacts.Phone ){
                
//                     ContactPointPhone oldPhone= HDT_QR_ContactPoint.getoldcontactphone(cont.IndividualId, cont.Phone);
//                     if(oldPhone.Status__c == 'Verificato'){
//                         ContactPointPhone newPhone= new ContactPointPhone (TelephoneNumber= cont.Phone,ParentId= cont.IndividualId,isPrimary= true);
//                         insertPhones.add(newPhone);
//                     }else{
//                         oldPhone= new ContactPointPhone (Id= oldPhone.Id, TelephoneNumber= cont.Phone);
//                         updatePhones.add(oldPhone);
//                     }
//                 }

//                 update updatePhones;
//                 insert insertPhones;
            
//         }
//             update updateEmails;
//             insert insertEmails;
        
       
//     }
//  }
}



