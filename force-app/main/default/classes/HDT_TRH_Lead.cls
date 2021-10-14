public inherited sharing class HDT_TRH_Lead extends HDT_TRH_TriggerHandler {
   
    //public override void beforeDelete(){}
    //public override void afterInsert(){}
    //public override void afterUndelete(){}
    private static HDT_QR_AccountContactRelation accoContRelQr = new HDT_QR_AccountContactRelation();
    private static HDT_QR_Account accountQr = new HDT_QR_Account();
    private static HDT_QR_Contact contactQr = new HDT_QR_Contact();
    private static HDT_SRV_Account accountSrv = new HDT_SRV_Account();
    private static HDT_SRV_Contact contactSrv = new HDT_SRV_Contact();

    private static Map<Id, Lead> mapOld =(Map<Id, Lead>)Trigger.oldMap;
    private static Map<Id, Lead> mapNew =(Map<Id, Lead>)Trigger.newMap;


    public override void afterInsert(){
        List<Lead> listlead = Trigger.New;
        system.debug('test');

        // for(Lead lead :listlead){
        //     HDT_UTL_GestionePrivacy.setPrivacyForLead(lead);
        // }
    HDT_UTL_GestionePrivacy.setPrivacyForLead(listlead);
    }

    public override void beforeInsert(){
        List<Lead> listlead = Trigger.New;
        Map<String,String> mapResBlacklist = HDT_UTL_Lead.getBlackListMap();
        List<Lead> listNew = trigger.new;
       // List<Lead> leadToCheck = new List<Lead>();
        //Map<String,String> leadDomain = new Map<String,String>();
        for(Lead l : listNew){
            if(l.email != null){
                String s = l.email.split('@')[1];
                if(mapResBlacklist.get(s.toUpperCase()) != null){
                    l.addError('Error:' + mapResBlacklist.get(s.toUpperCase()));
                }
                else{
                    if('Default'.equals(l.company)){
                        if(String.isBlank(l.FirstName))
                        {
                            l.company = l.lastname;    
                        }
                        else{
                            l.company = l.firstname + ' '  + l.lastname; 
                        }
                        }
                }
            }
            else{
                if('Default'.equals(l.company)){
                    if(String.isBlank(l.FirstName))
                    {
                        l.company = l.lastname;    
                    }
                    else{
                        l.company = l.firstname + ' '  + l.lastname; 
                    }
                    }
            } 
        }
      /*  for(Lead l : listlead){
            if('Default'.equals(l.company)){
                if(String.isBlank(l.FirstName))
                {
                    l.company = l.lastname;    
                }
                else{
                    l.company = l.firstname + ' '  + l.lastname; 
                }
                }
        }*/
        HDT_UTL_CompanyOwner.feedCompanyOwner(trigger.new);
        }
          
        public override void afterUpdate(){
            System.debug('afterUpdate');
            Map<Id, Lead> mapOld =(Map<Id, Lead>)Trigger.oldMap;
            for (Lead tempLead :   (List<Lead> ) Trigger.New) {

                if (tempLead.IndividualId==null&& mapOld.get(tempLead.id)!=null &&
                mapOld.get(tempLead.id).IndividualId!=null && !tempLead.IsConverted) {
                    tempLead.addError('Operazione non consentita');
                  
                }
                
            }

            List<Lead> listslead = trigger.New;
            HDT_QR_Account accPerson = new HDT_QR_Account();
            HDT_QR_RecordType recordtypeQr= new HDT_QR_RecordType();
            HDT_SRV_AccountContactRelation accoContRelSrv = new HDT_SRV_AccountContactRelation();

            HDT_UTL_GestionePrivacy.updateContactPointFromObjectLead(trigger.new,trigger.old);
            List<Account> accounts=new List<Account>();
            List<String> accountIdList = new List<String>();
            Map<String,Lead> mapAccountLead = new Map<String,Lead>();
            
            for(Lead l : listslead){
                if(l.IsConverted){
                    if (l.ConvertedAccountId != null) {
                        accountIdList.add(l.ConvertedAccountId);
                        mapAccountLead.put(l.ConvertedAccountId,l);
                        String leadName = l.FirstName + ' ' + l.LastName;
                        Account acc = accountQr.getRecordById(l.ConvertedAccountId, 'Name');
                        Contact con = contactQr.getRecordById(l.ConvertedContactId);
                        if(leadName == acc.Name && leadName != con.Name){
                            l.addError('Non è possibile creare un nuovo Account e selezionare un Contact già esistente!');
                        }
                  	}  
                            
                }
            }
            if(accountIdList != null && accountIdList.size()> 0){
                List<Account> accToUpdate = new List<Account>();
                List<Contact> conList = new List<Contact>();
                List<String> accId = new List<String>();
                List<String> contId = new List<String>();
                Recordtype r = recordtypeQr.getRecordType('HDT_RT_Business', 'Account');  
                accounts = accPerson.getRecordsById(accountIdList,'id,Name, firstname__c,LastName__c,PrimaryEmail__c,Description,FiscalCode__c,recordtypeid,Phone,FAX__c,MobilePhone__c' );
                
                for(Account a : accounts){
                    accId.add(a.id);
                    if(mapAccountLead.get(a.id) != null){
                        String lastName = (a.LastName__c != null && a.LastName__c != '' ? a.LastName__c : a.Name);
                        if ( a.LastName__c==null) {
                            if(r.id == a.recordtypeid){

                                Lead li = mapAccountLead.get(a.id);
                               // a.FirstName__c = li.FirstName;
                            
                                a.LastName__c = li.Company;
                                a.Name=li.Company;
                                a.PrimaryEmail__c= li.Email;
                                a.Description= li.Description;
                                Contact contact= new Contact(AccountId= a.Id, LastName= lastName, FiscalCode__c= a.FiscalCode__c, Phone=mapAccountLead.get(a.id).Phone, Email=mapAccountLead.get(a.id).email ,MobilePhone= mapAccountLead.get(a.id).MobilePhone, Fax= a.FAX__c);
                                conList.add(contact);
                                accToUpdate.add(a);

                            }
                            else{       
                                Lead li = mapAccountLead.get(a.id);
                                a.FirstName__c = li.FirstName;
                                a.LastName__c = li.LastName;
                                a.PrimaryEmail__c= li.Email;
                                a.Description= li.Description;
                                String expectedNewName = String.isBlank(a.FirstName__c) ? a.LastName__c : a.FirstName__c + ' ' + a.LastName__c;
                                a.Name=expectedNewName;
                                accToUpdate.add(a);
                            }
                        }
                    }     
                }
                if (accToUpdate.size()>0) {
                    accountSRV.updateRecordsWithCheckTrigger(accToUpdate);
                }
                if (conList.size()>0) {
                    contactSrv.createRecords(conList);

                    for(Contact c : conList){
                        contId.add(c.id);
                    }
                    List<AccountContactRelation> listAccCon= accoContRelQr.getContactsByAccountWithRoles(accId);
                    List<Contact> listContactToClean = new List<Contact>();
                    Set<id> setInd = new Set<id>();
                    for(AccountContactRelation acc : listAccCon){
                        if (contId.contains(acc.ContactId)) {
                            acc.Roles='Azienda'; 
                        }
                        else {
                            //contatti da sbiancare #HRAWRM-387 01/09/2021
                            Contact tempContact=new Contact();
                            tempContact.Id=acc.ContactId;
                            tempContact.Email=null;
                            tempContact.MobilePhone=null;
                            tempContact.phone=null;
                            listContactToClean.add(tempContact);
                            setInd.add(acc.Contact.IndividualId);
                        }  
                    }
                    if (setInd.size()>0) {
                        //Start #HRAWRM-387 01/09/2021
                        List< ContactPointEmail> listToDeleteEm = HDT_QR_ContactPoint.getIndividualContactEmailList(setInd);
                        List<ContactPointPhone> listToDeletePh  = HDT_QR_ContactPoint.getIndividualContactsPhoneList(setInd);
                        if(!listToDeleteEm.isEmpty() && listToDeleteEm.size()>0){
                          //  HDT_SRV_ContactPointEmail.deleteRecord(listToDeleteEm);
                            delete listToDeleteEm;
                        }
                        if(!listToDeletePh.isEmpty() && listToDeletePh.size()>0){
                           // HDT_SRV_ContactPointPhone.deleteRecord(listToDeletePh);
                            delete listToDeletePh;
                        }
                        // List<sObject> listToDelete = new List<sObject>();
                        // listToDelete.addAll(listToDeleteEm);
                        // listToDelete.addAll(listToDeletePh);
                        // if (listToDelete.size()>0) {
                        //   delete listToDelete;
                        // }
                        contactSrv.updateRecord(listContactToClean);
                        //End #HRAWRM-387 01/09/2021

                        accoContRelSrv.upsertRecord(listAccCon);
                    }
                   
                }
            System.debug('before Call Batch ');
        // Start HRAWRM-450 07/09/2021 

            //Start  Lorenzo 
            HDT_BA_AccountBpCaCallout ba = new  HDT_BA_AccountBpCaCallout();
            ba.dtos = accToUpdate;  
            Database.executeBatch(ba,80);
            //End  Lorenzo 

        // End HRAWRM-450 07/09/2021
    
            }
            
        }
        public override void   beforeUpdate(){
            System.debug('HDT_TRH_Lead.beforeUpdate');
            Map<Id, Lead> mapOld =(Map<Id, Lead>)Trigger.oldMap;
            Set<String> setFiscalCodes = new Set<String>();
            Map<String,String> mapResBlacklist = HDT_UTL_Lead.getBlackListMap();
            List<Lead> listNew = trigger.new;
            List<Lead> leadToCheck = new List<Lead>();
            //Map<String,String> leadDomain = new Map<String,String>();
            //id currentUserId=UserInfo.getUserId();
            Map<Id, Id> mapLeadOwner = new Map<Id, Id>();
            for(Lead l : listNew){
                id currentUserId=UserInfo.getUserId();
              /*  if (l.OwnerId!=currentUserId) {
                   // l.OwnerId=currentUserId;
                   mapLeadOwner.put(l.id,currentUserId);
                }*/
                if(l.email != null){
                    String s = l.email.split('@')[1];
                    if(mapResBlacklist.get(s.toUpperCase()) != null){
                        l.addError('Error:' + mapResBlacklist.get(s.toUpperCase()));
                    }
                }
                if (String.isNotBlank(l.FiscalCode__c) && mapOld.get(l.Id)!=null && (mapOld.get(l.Id).FiscalCode__c!=l.FiscalCode__c)     ) {
                    setFiscalCodes.add(l.FiscalCode__c);
                    leadToCheck.add(l);
                }
            }  
           /* if (!mapLeadOwner.isEmpty()) {
                System.enqueueJob(new HDT_QBL_Lead(mapLeadOwner));
            }*/ 
            // Start 27-08-2021 HRAWRM-351
            if (leadToCheck.size()>0) {
                
            
                Map<String,HDT_UTL_CheckFiscalCodeTaxNumber.HDT_WRP_FiscalObject> mapCodeToCheck = HDT_UTL_CheckFiscalCodeTaxNumber.getDataFromFiscalCode(setFiscalCodes);
                for (Lead tempLead : leadToCheck) {
                    HDT_UTL_CheckFiscalCodeTaxNumber.HDT_WRP_FiscalObject wrp = new HDT_UTL_CheckFiscalCodeTaxNumber.HDT_WRP_FiscalObject();
                    if (mapCodeToCheck.get(tempLead.FiscalCode__c)!=null ) {
                        wrp=mapCodeToCheck.get(tempLead.FiscalCode__c);
                       
                       try { // Start RDTR-00_HRAWRM-491 08/09/2021
                            if ( wrp.isValid) {
                                Date myDate = Date.newInstance(Integer.valueOf( wrp.year),Integer.valueOf(wrp.month),Integer.valueOf( wrp.day));
                                tempLead.Birthdate__c=tempLead.Birthdate__c==null?myDate:tempLead.Birthdate__c;
                                tempLead.Birthcity__c=String.isBlank( tempLead.Birthcity__c)? wrp.city: tempLead.Birthcity__c;
                                tempLead.Gender__c=String.isBlank( tempLead.Gender__c)? wrp.gender: tempLead.Gender__c;
                                //HRAWRM-491 Start 27/09/2021 Controllo codice fiscale stimato
                                Map<String,String> infoData=new  Map<String,String>();
                                infoData.put('lastName',tempLead.LastName);
                                infoData.put('firstName',tempLead.FirstName);
                                infoData.put('birthDate', String.valueOf(tempLead.Birthdate__c));
                                infoData.put('birthPlace',tempLead.Birthcity__c);
                                infoData.put('gender',tempLead.Gender__c);
       
                                System.debug('return ' +HDT_UTL_CheckFiscalCodeTaxNumber.matchEstimatedFCode(infoData,tempLead.FiscalCode__c));
                                if ( ! HDT_UTL_CheckFiscalCodeTaxNumber.matchEstimatedFCode(infoData,tempLead.FiscalCode__c)) {
                                    tempLead.addError('Inserire un codice fiscale valido');
                                }
                                //HRAWRM-491 End 27/09/2021 Controllo codice fiscale stimato

                            }
                            else{
                                tempLead.addError('Inserire un codice fiscale valido');
                            }
                        }
                        catch (Exception e) {
                           System.debug('errore: '+e.getMessage());
                            tempLead.addError('Inserire un codice fiscale valido');
                       }// End RDTR-00_HRAWRM-491 08/09/2021
                       
                    }
                }
            }
        }
        // End 27-08-2021 HRAWRM-351
}