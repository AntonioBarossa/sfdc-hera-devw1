public without sharing class HDT_UTL_ProcessTakeOver extends  HDT_UTL_ProcessExecution {
   private HDT_WRP_ProcessEntities currentProcess;

   final String PROCESS_NAME='Subentro';

   public  HDT_UTL_ProcessTakeOver(){}
   public  HDT_UTL_ProcessTakeOver(MassiveLoaderRequestItem__c varRequestItem){
        System.debug('HDT_UTL_ProcessTakeOver : '+varRequestItem);
        if (varRequestItem==null) {
            throw new HDT_WRP_ProcessEntitiesException('Null Pointer Exceptions','varRequestItem can\'t be null');
        } 
        
        currentProcess=new HDT_WRP_ProcessEntities();
        this.currentProcess.currentRequestItem=varRequestItem;   
   }

    public override void checks(){
        setProcessName(PROCESS_NAME);
       

        Map<String, String> mapAccountFields = new Map<String, String>{
            'Nome'=>'FirstName__c',
            'Cognome/Ragione Sociale'=>'LastName__c',
            'Codice Fiscale'=>'FiscalCode__c',
            'P.IVA'=>'VATNumber__c',
            'BP'=>'BPSAPModel__c',
            'Marcatura'=>'CustomerMarking__c',
            'Categoria'=>'Category__c',
            //'Ruolo'=>'role',
            'Silos'=>'CompanyOwner__c',
           // 'Barrato'=>'',
            'Prefisso Cellulare'=>'MobilePhonePrefix__c',
            'Cellulare'=>'MobilePhone__c',
            'Prefisso telefono fisso'=>'PhonePrefix__c',
            'Telefono fisso'=>'Phone',
            'Altro Telefono'=>'OtherPhone__c',
            'Email'=>'PrimaryEmail__c',
            'FAX'=>'FAX__c',
            'Data nascita'=>'BirthDate__c',
            'Comune di nascita'=>'BirthProvince__c',
            'Sesso'=>'Gender__c',
            'Tipo di Account'=>'RecordTypeId',
            'Titolo di studio'=>'DegreeOfStudies__c',
            'Professione'=>'Profession__c',
            // indirizzo
            'Nome Via [Residenziale/Sede Legale]'=>'BillingStreetName__c',
            'Comune'=>'BillingCity',
            'CAP'=>'BillingPostalCode',
            'Stato'=>'BillingCountry',
            'Provincia'=>'BillingState',
            'Codice Via Stradario SAP'=>'BillingStreetCode__c',
            'Estens.Civico'=>'BillingStreetNumberExtension__c',
            'Civico'=>'BillingStreetNumber__c',
            'Indirizzo Estero'=>'ShippingAddressIsForeign__c',
            'Localita'=>'BillingPlace__c',
            'Codice Localita'=>'BillingPlaceCode__c',
            'Flag Verificato'=>'BillingIsAddressVerified__c'
            // inserire domicilio



        };
        if ( String.isNotBlank( currentProcess.currentRequestItem.Data__c)) {
         
            Integer count=0;
           
            for (String tempField : currentProcess.currentRequestItem.Data__c.split(',')) {
                
                
                // Controllo campi required
                // if (mapRequiredByPosition.get(count)!=null && String.isBlank(tempField) ) {
                //     throw new HDT_WRP_ProcessEntitiesException( 'Missing required field',mapHeaderByPosition.get(count)+' can\'t be null');
                // }

                // Start AccountContactRelation
                if ( 'Ruolo'.equalsIgnoreCase(mapHeaderByPosition.get(count))) {
                    currentProcess.role=tempField;
                }
                // fine AccountContactRelation

                // Creazione Accoun
                if (mapAccountFields.get(mapHeaderByPosition.get(count))!=null) {
                    System.debug('column N° :'+count+' FieldapiName : '+mapAccountFields.get(mapHeaderByPosition.get(count))+'  HeaderName : '+mapHeaderByPosition.get(count) + ' FieldValue : '+tempField );
                    if ('ShippingAddressIsForeign__c'.equalsIgnoreCase(mapAccountFields.get(mapHeaderByPosition.get(count))) ||'BillingIsAddressVerified__c'.equalsIgnoreCase(mapAccountFields.get(mapHeaderByPosition.get(count)))   ) {
                        currentProcess.currentAccount.put(mapAccountFields.get(mapHeaderByPosition.get(count)),'true'.equalsIgnoreCase(tempField)?true:false);
                    }
                    else if('Tipo di Account'.equalsIgnoreCase(mapHeaderByPosition.get(count))){
                            // selezione recordtype Account 
                            if ('Business'.equalsIgnoreCase(tempField)) {
                                currentProcess.currentAccount.put('RecordTypeId',recordTypeBus);
                            }
                            else if ('Residenziale'.equalsIgnoreCase(tempField))  {
                                currentProcess.currentAccount.put('RecordTypeId',recordTypeRes);
                            }
                            else {
                                throw new HDT_WRP_ProcessEntitiesException( 'Missing required field',mapHeaderByPosition.get(count)+' not valid!');
                            }
                    }
                    else if('BirthDate__c'.equalsIgnoreCase(mapAccountFields.get(mapHeaderByPosition.get(count)))){
                       currentProcess.currentAccount.put('BirthDate__c',Date.valueOf(tempField));
                     
                    }
                    else {
                        currentProcess.currentAccount.put(mapAccountFields.get(mapHeaderByPosition.get(count)),tempField);
                    } 
                }
                //Fine Creazione Account
                count++;
            }
        }

    }
    public override void getRecords(){
        /* Controllo se l'account esiste già se esiste recuperare anche il Contact 
        */
        makeContact();
        List<Account> lAccount=new List<Account>();
        if (currentProcess.currentAccount!=null && 
        String.isNotBlank(currentProcess.currentAccount.CompanyOwner__c)
        &&
        String.isNotBlank(currentProcess.currentAccount.CustomerMarking__c)
        &&
        String.isNotBlank(currentProcess.currentAccount.Category__c)
        &&
        ( String.isNotBlank(currentProcess.currentAccount.FiscalCode__c) 
        || String.isNotBlank(currentProcess.currentAccount.VATNumber__c))
         ) {
            String filter='CompanyOwner__c=\''+currentProcess.currentAccount.CompanyOwner__c+'\' AND CustomerMarking__c = \''+currentProcess.currentAccount.CustomerMarking__c+'\' AND Category__c=\''+currentProcess.currentAccount.Category__c+'\' AND (FiscalCode__c=\''+currentProcess.currentAccount.FiscalCode__c+'\' OR VATNumber__c=\''+currentProcess.currentAccount.VATNumber__c+'\')';
            System.debug('filter: '+filter);
            lAccount= qrAcc.getAccountList(filter) ;
            
        }
        if (lAccount!=null && lAccount.size()>0) {
            currentProcess.currentAccount.Id=lAccount.get(0).Id;  
            System.debug('currentProcess.currentAccount: '+currentProcess.currentAccount); 
        }
       
    }

    public override void registryCreation(){
        if (currentProcess.currentAccount!=null &&currentProcess.currentAccount.Id==null ) {
            insert currentProcess.currentAccount;
            currentProcess.currentPrimaryContact.AccountId=currentProcess.currentAccount.id;
            insert currentProcess.currentPrimaryContact;
            if(currentProcess.role!=null){
                List<AccountContactRelation> listAccCon= accoContRelQr.getAccountContactRelation(currentProcess.currentPrimaryContact.AccountId,currentProcess.currentPrimaryContact.Id, 'Id');
                if(listAccCon != null && listAccCon.size() > 0){
                    currentProcess.currentAccountContactRelation = new AccountContactRelation(Id= listAccCon[0].Id,ContactId= currentProcess.currentPrimaryContact.Id, AccountId=currentProcess.currentPrimaryContact.AccountId, Roles=currentProcess.role );
                    insert currentProcess.currentAccountContactRelation;
                   
                }
    
            }
        }

    }



    //public void postSalesCreation(){}
   // public void finalUpdate(){}
   private void makeContact(){
    currentProcess.currentPrimaryContact.DegreeOfStudies__c                 =  currentProcess.currentAccount.DegreeOfStudies__c                  ;
    currentProcess.currentPrimaryContact.CompanyOwner__c                    =  currentProcess.currentAccount.CompanyOwner__c                     ;
    //currentProcess.currentPrimaryContact.Company__c                       =               
    //currentProcess.currentPrimaryContact.AccountId                        =               
    currentProcess.currentPrimaryContact.LastName                           =  currentProcess.currentAccount.LastName__c                         ;
    currentProcess.currentPrimaryContact.Gender__c                          =  currentProcess.currentAccount.Gender__c                           ;
    currentProcess.currentPrimaryContact.FirstName                          =  currentProcess.currentAccount.FirstName__c                        ;
    currentProcess.currentPrimaryContact.Birthdate                          =  currentProcess.currentAccount.BirthDate__c                        ;
    currentProcess.currentPrimaryContact.FiscalCode__c                      =  currentProcess.currentAccount.FiscalCode__c                       ;
    currentProcess.currentPrimaryContact.Birthcity__c                       =  currentProcess.currentAccount.BirthProvince__c                    ;
    currentProcess.currentPrimaryContact.MobilePhonePrefix__c               =  currentProcess.currentAccount.MobilePhonePrefix__c                ;
    currentProcess.currentPrimaryContact.Phone                              =  currentProcess.currentAccount.Phone                               ;
    currentProcess.currentPrimaryContact.MobilePhone                        =  currentProcess.currentAccount.MobilePhone__c                      ;
    currentProcess.currentPrimaryContact.Email                              =  currentProcess.currentAccount.PrimaryEmail__c                     ;
    currentProcess.currentPrimaryContact.PhonePrefix__c                     =  currentProcess.currentAccount.PhonePrefix__c                      ;
    currentProcess.currentPrimaryContact.Fax                                =  currentProcess.currentAccount.FAX__c                              ;                       
    currentProcess.currentPrimaryContact.Profession__c                      = currentProcess.currentAccount.Profession__c                        ;             
    currentProcess.currentPrimaryContact.MailingCity                        = currentProcess.currentAccount.BillingCity                          ;           
    currentProcess.currentPrimaryContact.MailingCityCode__c                 = currentProcess.currentAccount.BillingCityCode__c                   ;                  
    currentProcess.currentPrimaryContact.MailingCountry                     = currentProcess.currentAccount.BillingCountry                       ;              
    currentProcess.currentPrimaryContact.MailingPostalCode                  = currentProcess.currentAccount.BillingPostalCode                    ;                 
    currentProcess.currentPrimaryContact.MailingState                       = currentProcess.currentAccount.BillingState                         ;            
    currentProcess.currentPrimaryContact.MailingStreet                      = currentProcess.currentAccount.BillingStreet                        ;             
    currentProcess.currentPrimaryContact.MailingStreetName__c               = currentProcess.currentAccount.BillingStreetName__c                 ;                    
    currentProcess.currentPrimaryContact.MailingStreetCode__c               = currentProcess.currentAccount.BillingStreetCode__c                 ;                    
    currentProcess.currentPrimaryContact.MailingStreetNumber__c             = currentProcess.currentAccount.BillingStreetNumber__c               ;                      
    currentProcess.currentPrimaryContact.MailingStreetNumberExtension__c    = currentProcess.currentAccount.BillingStreetNumberExtension__c      ;                               
    currentProcess.currentPrimaryContact.MailingStreetToponym__c            = currentProcess.currentAccount.BillingStreetToponym__c              ;                       
    currentProcess.currentPrimaryContact.MailingRegion__c                   = currentProcess.currentAccount.BillingRegion__c                     ;                
    currentProcess.currentPrimaryContact.MailingPlace__c                    = currentProcess.currentAccount.BillingPlace__c                      ;                
    currentProcess.currentPrimaryContact.MailingPlaceCode__c                = currentProcess.currentAccount.BillingPlaceCode__c                  ;                    
    currentProcess.currentPrimaryContact.MailingIsAddressVerified__c        = currentProcess.currentAccount.BillingIsAddressVerified__c          ;                           

   }
   
   
}
