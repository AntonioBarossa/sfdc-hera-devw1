public inherited sharing class HDT_TRH_Lead extends HDT_TRH_TriggerHandler {
   
    //public override void beforeInsert(){}
    //public override void beforeDelete(){}
    //public override void afterInsert(){}
    //public override void afterUndelete(){}
    private static HDT_QR_AccountContactRelation accoContRelQr = new HDT_QR_AccountContactRelation();


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

        for(Lead l : listlead){
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
          
        public override void afterUpdate(){

            List<Lead> listslead = trigger.New;
            HDT_QR_Account accPerson = new HDT_QR_Account();
            HDT_QR_RecordType recordtypeQr= new HDT_QR_RecordType();
            HDT_SRV_AccountContactRelation accoContRelSrv = new HDT_SRV_AccountContactRelation();

            HDT_UTL_GestionePrivacy.updateContactPointFromObject(trigger.new,trigger.old);
            List<Account> accounts=new List<Account>();
            List<String> accountIdList = new List<String>();
            Map<String,Lead> mapAccountLead = new Map<String,Lead>();
            for(Lead l : listslead){
                if(l.IsConverted){
                    if (l.ConvertedAccountId != null) {
                        accountIdList.add(l.ConvertedAccountId);
                        mapAccountLead.put(l.ConvertedAccountId,l);
                  	}  
                            
                }
            }
            if(accountIdList != null && accountIdList.size()> 0){
                List<Account> accToUpdate = new List<Account>();
                List<Contact> conList = new List<Contact>();
                List<String> accId = new List<String>();
                List<String> contId = new List<String>();
                Recordtype r = recordtypeQr.getRecordType('HDT_RT_Business', 'Account');
            
                accounts = accPerson.getRecordsById(accountIdList,'id,Name, firstname__c,LastName__c,PrimaryEmail__c,Description,FiscalCode__c,recordtypeid,Phone,FAX__c' );
                For(Account a : accounts){
                    accId.add(a.id);
                    if(mapAccountLead.get(a.id) != null){
                        String lastName = (a.LastName__c != null && a.LastName__c != '' ? a.LastName__c : a.Name);
            
                        if(r.id == a.recordtypeid){
                            Contact contact= new Contact(AccountId= a.Id, LastName= lastName, FiscalCode__c= a.FiscalCode__c, Phone= a.Phone, Email= a.PrimaryEmail__c, Fax= a.FAX__c);
                            conList.add(contact);
            
                        }
                                
                                
                        Lead li = mapAccountLead.get(a.id);
            
                        a.FirstName__c = li.FirstName;
                        a.LastName__c = li.LastName;
                        a.PrimaryEmail__c= li.Email;
                        a.Description= li.Description;
                        accToUpdate.add(a);
                    }
                        
                }
            
                update accToUpdate;
                insert conList;
                for(Contact c : conList){
                    contId.add(c.id);
                }
                List<AccountContactRelation> listAccCon= accoContRelQr.getAccountContactRelation(accId, contId, 'Id');
                for(AccountContactRelation acc : listAccCon){
                    acc.Roles='Azienda';
                }
                accoContRelSrv.upsertRecord(listAccCon);       
            }
            
        }
}
