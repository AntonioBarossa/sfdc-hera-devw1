trigger HDT_Lead on Lead (before insert, after update, after insert) {
    new HDT_TRH_Lead().run();
   //HDT_TRH_Lead handler = new HDT_TRH_Lead();


   //  if(Trigger.isUpdate && Trigger.isAfter){
   // 	System.debug('order trigger: do after update');
   //     handler.OnAfterUpdate();       
   // } else if(Trigger.isInsert && Trigger.isBefore){
   // 	System.debug('order trigger: do before insert');
   // 	handler.OnBeforeInsert();
   // } else if(Trigger.isInsert && Trigger.isAfter){
   // 	System.debug('order trigger: do after insert');
   // 	handler.OnAfterInsert();
   // }
  
//    //if(Trigger.isInsert && Trigger.isAfter){
//         //for(Lead lead : Trigger.New){
//            // HDT_UTL_GestionePrivacy.setPrivacyForLead(lead);
//        // }
//     // }
       
//     if(Trigger.isInsert && Trigger.isBefore){
//         for(Lead l : trigger.new){
//             if('Default'.equals(l.company)){
//                 if(String.isBlank(l.FirstName))
//                 {
//                 	l.company = l.lastname;    
//                 }
//                 else{
//                     l.company = l.firstname + ' '  + l.lastname; 
//                 }
//                 }
//         }
//     }
//     if(Trigger.isUpdate && Trigger.isAfter){
//         HDT_UTL_GestionePrivacy.updateContactPointFromObject(trigger.new,trigger.old);
//         List<Account> accounts=new List<Account>();
//         List<String> accountIdList = new List<String>();
//         Map<String,Lead> mapAccountLead = new Map<String,Lead>();
//         for(Lead l : trigger.new){
//             if(l.IsConverted){
//                 if (l.ConvertedAccountId != null) {
//                     accountIdList.add(l.ConvertedAccountId);
//                     mapAccountLead.put(l.ConvertedAccountId,l);
//                    /* Account a = [Select a.Id From Account a Where a.Id = :l.ConvertedAccountId];
//                     a.FirstName__c = l.FirstName;
//                     a.LastName__c = l.LastName;
//                     a.PrimaryEmail__c= l.Email;
//                     a.Description= l.Description;
//                     accounts.add(a);*/
//       			}  
               
//             }
//         }
//         if(accountIdList != null && accountIdList.size()> 0){
//             List<Account> accToUpdate = new List<Account>();
//             List<Contact> conList = new List<Contact>();
//             List<String> accID = new List<String>();
//             List<String> contID = new List<String>();
//             Recordtype r = HDT_QR_RecordType.getRecordType('Business', 'Account');

//             accounts = HDT_QR_Account.getRecordsById(accountIdList,'id,Name, firstname__c,LastName__c,PrimaryEmail__c,Description,FiscalCode__c,recordtypeid,Phone,FAX__c' );
//             For(Account a : accounts){
//                 accID.add(a.id);
//                 if(mapAccountLead.get(a.id) != null){
//                     String lastName = (a.LastName__c != null && a.LastName__c != '' ? a.LastName__c : a.Name);

//                     if(r.id == a.recordtypeid){
//                         Contact contact= new Contact(AccountId= a.Id, LastName= lastName, FiscalCode__c= a.FiscalCode__c, Phone= a.Phone, Email= a.PrimaryEmail__c, Fax= a.FAX__c);
//                         //HDT_SRV_Contact.checkCreateAccess(contact);
//                         conList.add(contact);

//                     }
                   
                   
//                 	Lead li = mapAccountLead.get(a.id);

//                     a.FirstName__c = li.FirstName;
//                     a.LastName__c = li.LastName;
//                     a.PrimaryEmail__c= li.Email;
//                     a.Description= li.Description;
//                     accToUpdate.add(a);
//                 }
           
//             }

//             update accToUpdate;
//             insert conList;
//             for(Contact c : conList){
//                 contID.add(c.id);
//             }
//             List<AccountContactRelation> listAccCon= HDT_QR_AccountContactRelation.getAccountContactRelation(accID, contID, 'Id');
//             for(AccountContactRelation acc : listAccCon){
//                 acc.Roles='Azienda';
//             }
//             HDT_SRV_AccountContactRelation.upsertRecord(listAccCon);
           
           
//         }

//          // update accounts;
//     }

}