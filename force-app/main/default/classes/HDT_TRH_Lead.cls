@SuppressWarnings('PMD.ApexCRUDViolation,PMD.AvoidDebugStatements')
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
        // for(Lead lead :listlead){
        //     HDT_UTL_GestionePrivacy.setPrivacyForLead(lead);
        // }
        HDT_UTL_GestionePrivacy.setPrivacyForLead(listlead);
    }

    public override void beforeInsert(){
        Map<String,String> mapResBlacklist = HDT_UTL_Lead.getBlackListMap();
        List<Lead> listNew = trigger.new;

        for(Lead l : listNew){

            if((String.isNotBlank(l.FiscalCode__c) && (l.FiscalCode__c.length()!=16 && l.FiscalCode__c.length()!=11)) || (String.isNotBlank(l.VATNumber__c) && l.VATNumber__c.length()!=11 && !l.VATNumber__c.isNumeric())){
                l.addError('Inserire una Partita Iva o un Codice Fiscale Valido');
            }

            if (String.isNotBlank(l.FiscalCode__c) && l.FiscalCode__c.length()==16) {
                l.FiscalCode__c = l.FiscalCode__c.toUpperCase();
                String lastLetter = l.FiscalCode__c.right(1);
                String fiscalCodeToCheck = l.FiscalCode__c.left(15);
                String letterControled = HDT_UTL_CalculateFiscalCode.getControlLetter(fiscalCodeToCheck);

                if(lastLetter != letterControled ){
                    l.addError('Codice fiscale non valido');
                }
            }
            else if(String.isNotBlank(l.FiscalCode__c) && l.FiscalCode__c.length()==11 && l.FiscalCode__c.isNumeric()){
                String lastNum = l.FiscalCode__c.right(1);
                String pIvaToCheck = l.FiscalCode__c.left(10);
                String numControled = HDT_UTL_CalculateFiscalCode.getControlNumberPiva(pIvaToCheck);

                if(lastNum != numControled ){
                    l.addError('Partita Iva non valida');
                }
            }

            if(String.isNotBlank(l.VATNumber__c)){
                String lastNumVat = l.VATNumber__c.right(1);
                String vatToCheck = l.VATNumber__c.left(10);
                String numVatControled = HDT_UTL_CalculateFiscalCode.getControlNumberPiva(vatToCheck);

                if(lastNumVat != numVatControled ){
                    l.addError('Partita Iva non valida');
                }
            }
            
            if(l.Country == null || l.Country == '')
            {
                l.Country = 'ITALIA';
            }
            
            if(String.isNotBlank(l.FirstName)){
                l.FirstName = l.FirstName.toUpperCase();
            }
            if(String.isNotBlank(l.LastName)){
                l.LastName= l.LastName.toUpperCase();
            }
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
            //Se la Società è MMS, viene impostato il RT "Principale" in modo da skippare il layout con messaggio di acquisizione obbligatoria della privacy, in quanto non prevista.
            if(!String.isBlank(l.CompanyOwner__c) && 'MMS'.equalsIgnoreCase(l.CompanyOwner__c)){
                l.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('HDT_RT_Main').getRecordTypeId();
            }
        }
        HDT_UTL_CompanyOwner.feedCompanyOwner(trigger.new);
    }
          
    public override void afterUpdate(){
        List<SObject> listToUpdate = new List<SObject>();
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
        HDT_UTL_GestionePrivacy.updateContactPointFromObjectLead(trigger.new,trigger.old);
        List<Account> accounts=new List<Account>();
        List<String> accountIdList = new List<String>();
        Map<String,Lead> mapAccountLead = new Map<String,Lead>();
        
        for(Lead l : listslead){
            if(l.IsConverted){
                if (l.ConvertedAccountId != null) {
                    accountIdList.add(l.ConvertedAccountId);
                    mapAccountLead.put(l.ConvertedAccountId,l);
                    Account acc = accountQr.getRecordById(l.ConvertedAccountId, 'Name, CreatedDate');
                    Contact con = contactQr.getRecordById(l.ConvertedContactId);

                    Datetime dateToCheck = l.LastModifiedDate?.addSeconds(-30);
                    Boolean isAccountJustCreated = (dateToCheck == null)? false : dateToCheck < acc.CreatedDate; 
                    Boolean isContactJustCreated = (dateToCheck == null)? false : dateToCheck < con.CreatedDate; 
                    
                    if(isAccountJustCreated && !isContactJustCreated){
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
                    Lead leadConverted = mapAccountLead.get(a.id);
                    a.OriginLeadId__c = leadConverted.Id;
                    a.ConvertedDate__c = System.Date.today();

                    String lastName = (a.LastName__c != null && a.LastName__c != '' ? a.LastName__c : a.Name);
                    if ( a.LastName__c==null) {
                        if(r.id == a.recordtypeid){
                            Lead li = mapAccountLead.get(a.id);
                        
                            a.LastName__c = li.Company;
                            a.Name=li.Company;
                            a.PrimaryEmail__c= li.Email;
                            a.Description= li.Description;
                            Contact contact= new Contact(AccountId= a.Id, LastName= lastName, FiscalCode__c= a.FiscalCode__c, Phone=mapAccountLead.get(a.id).Phone, Email=mapAccountLead.get(a.id).email ,MobilePhone= mapAccountLead.get(a.id).MobilePhone, Fax= a.FAX__c);
                            conList.add(contact);
                        }
                        else{       
                            Lead li = mapAccountLead.get(a.id);
                            a.FirstName__c = li.FirstName;
                            a.LastName__c = li.LastName;
                            a.PrimaryEmail__c= li.Email;
                            a.Description= li.Description;
                            String expectedNewName = String.isBlank(a.FirstName__c) ? a.LastName__c : a.FirstName__c + ' ' + a.LastName__c;
                            a.Name=expectedNewName;
                        }
                    }
                    accToUpdate.add(a);
                }     
            }
            if (accToUpdate.size()>0) {
                //accountSRV.updateRecordsWithCheck(accToUpdate);
                listToUpdate.addAll(accToUpdate);// HRAWRM-802 21/10/2021
                // update accToUpdate;
            }
            /**@frpanico 2022-03-11
             * Predefault ruolo Titolare
             * Quando viene convertito lead
             */
            if(accounts.size() == 1)
            {
                List<AccountContactRelation> listAccCon= accoContRelQr.getContactsByAccountWithRoles(accounts[0].Id);
                listAccCon[0].Roles = 'Titolare';
                update(listAccCon[0]);
            }
            if (conList.size()>0) {
                //contactSrv.createRecords(conList);
                insert conList;// HRAWRM-802 21/10/2021
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
                    List<sObject> listDelete = new List<sObject>();// HRAWRM-802 21/10/2021
                    if(!listToDeleteEm.isEmpty() && listToDeleteEm.size()>0){
                        //  HDT_SRV_ContactPointEmail.deleteRecord(listToDeleteEm);
                        //  delete listToDeleteEm;
                        listDelete.addAll(listToDeleteEm);// HRAWRM-802 21/10/2021
                    }
                    if(!listToDeletePh.isEmpty() && listToDeletePh.size()>0){
                        listDelete.addAll(listToDeletePh);// HRAWRM-802 21/10/2021
                        // HDT_SRV_ContactPointPhone.deleteRecord(listToDeletePh);
                        // delete listToDeletePh;
                    }
                    if(listDelete!=null && listDelete.size()>0){
                        delete listDelete;// HRAWRM-802 21/10/2021
                    }
                    // List<sObject> listToDelete = new List<sObject>();
                    // listToDelete.addAll(listToDeleteEm);
                    // listToDelete.addAll(listToDeletePh);
                    // if (listToDelete.size()>0) {
                    //   delete listToDelete;
                    // }
                    //contactSrv.updateRecord(listContactToClean);
                    listToUpdate.addAll(listContactToClean);
                    //End #HRAWRM-387 01/09/2021
                    listToUpdate.addAll(listAccCon);
                    // accoContRelSrv.upsertRecord(listAccCon);
                }
            }
            if (listToUpdate!=null && listToUpdate.size()>0) {
                update listToUpdate; // HRAWRM-802 21/10/2021
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
        List<Lead> leadVatToCheck = new List<Lead>();
        
        for(Lead l : listNew){

            if((String.isNotBlank(l.FiscalCode__c) && (l.FiscalCode__c.length()!=16 && l.FiscalCode__c.length()!=11)) || (String.isNotBlank(l.VATNumber__c) && l.VATNumber__c.length()!=11 && !l.VATNumber__c.isNumeric())){
                l.addError('Inserire una Partita Iva o un Codice Fiscale Valido');
            }
            
            if(l.email != null){
                String s = l.email.split('@')[1];
                if(mapResBlacklist.get(s.toUpperCase()) != null){
                    l.addError('Error:' + mapResBlacklist.get(s.toUpperCase()));
                }
            }
            if (String.isNotBlank(l.FiscalCode__c) && mapOld.get(l.Id)!=null && l.FiscalCode__c.length()==16 && (mapOld.get(l.Id).FiscalCode__c!=l.FiscalCode__c || mapOld.get(l.Id).Gender__c!=l.Gender__c || mapOld.get(l.Id).Birthcity__c!=l.Birthcity__c || mapOld.get(l.Id).Birthdate__c!=l.Birthdate__c || mapOld.get(l.Id).FirstName!=l.FirstName || mapOld.get(l.Id).LastName!=l.LastName)) {
                l.FiscalCode__c = l.FiscalCode__c.toUpperCase();
                setFiscalCodes.add(l.FiscalCode__c);
                leadToCheck.add(l);
            }

            if ((String.isNotBlank(l.FiscalCode__c) && mapOld.get(l.Id)!=null && l.FiscalCode__c.length()==11 && mapOld.get(l.Id).FiscalCode__c!=l.FiscalCode__c && l.FiscalCode__c.isNumeric()) || (String.isNotBlank(l.VATNumber__c) && mapOld.get(l.Id)!=null && l.VATNumber__c.length()==11 && mapOld.get(l.Id).VATNumber__c!=l.VATNumber__c && l.VATNumber__c.isNumeric())) {
                leadVatToCheck.add(l);
            }

            if(l.Country == null || l.Country == '')
            {
                l.Country = 'ITALIA';
            }
        }  

        if(leadVatToCheck.size()>0){
            for(Lead tlead : leadVatToCheck){
                String lastNum = '';
                String pIvaToCheck ='';
                String numControled = '';

                if(String.isNotBlank(tlead.FiscalCode__c) && tlead.FiscalCode__c.length()==11){
                    lastNum =tlead.FiscalCode__c.right(1);
                    pIvaToCheck =tlead.FiscalCode__c.left(10);
                    numControled = HDT_UTL_CalculateFiscalCode.getControlNumberPiva(pIvaToCheck);
                    if(lastNum != numControled ){
                        tlead.addError('Inserire una Partita Iva Valida');
                    }
                }
                if(String.isNotBlank(tlead.VATNumber__c) && tlead.VATNumber__c.length()==11){
                    lastNum =tlead.VATNumber__c.right(1);
                    pIvaToCheck =tlead.VATNumber__c.left(10);
                    numControled = HDT_UTL_CalculateFiscalCode.getControlNumberPiva(pIvaToCheck);
                    if(lastNum != numControled ){
                        tlead.addError('Inserire una Partita Iva Valida');
                    }
                }
            }
        }

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
    
                            System.debug('return ' +HDT_UTL_CheckFiscalCodeTaxNumber.matchEstimatedSetFiscalCode(infoData,tempLead.FiscalCode__c));
                            if ( ! HDT_UTL_CheckFiscalCodeTaxNumber.matchEstimatedSetFiscalCode(infoData,tempLead.FiscalCode__c)) {
                                tempLead.addError('Inserire un codice fiscale valido');
                            }
                            
                            String fiscalCode = tempLead.FiscalCode__c;
                            String lastLetter = fiscalCode.right(1);
                            String fiscalCodeToCheck = fiscalCode.left(15);
                            String letterControled = HDT_UTL_CalculateFiscalCode.getControlLetter(fiscalCodeToCheck);

                            if(lastLetter != letterControled ){
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