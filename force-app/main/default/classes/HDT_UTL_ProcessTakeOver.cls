public without sharing class HDT_UTL_ProcessTakeOver extends  HDT_UTL_ProcessExecution {
    private  Map<String, String> mapAccountFields;
    private Map<String, String> mapSaleFields;
    private Map<String, String> mapServicePointFields;
    private Map<String, String> mapBillingProfileFields;
    private Map<String, String> mapOrderFields;
    private Map<String, String> mapOrderItemFields;
    private List<SObject> listUpdateGeneric ;

       //final String PROCESS_NAME='Subentro';

   public  HDT_UTL_ProcessTakeOver(){
       System.debug('HDT_UTL_ProcessTakeOver');

   }

    public override void checks(){
        
        mapFieldsObject();

       
        if (String.isNotBlank( currentProcess.currentRequestItem.Data__c)) {
         
            Integer count=0;
            for (String tempField : currentProcess.currentRequestItem.Data__c.split(',')) {
                //! Controllo campi required
                // if (mapRequiredByPosition.get(count)!=null && String.isBlank(tempField) ) {
                //     throw new HDT_WRP_ProcessEntitiesException( 'Missing required field',mapHeaderByPosition.get(count)+' can\'t be null');
                // }
              
                if (String.isBlank(tempField)) {
                    count++;
                    continue;
                }
                // Start AccountContactRelation
                if ( 'Ruolo'.equalsIgnoreCase(mapHeaderByPosition.get(count))) {
                    currentProcess.role=tempField;
                }
                // fine AccountContactRelation

                // Creazione Account
                if (mapAccountFields.get(mapHeaderByPosition.get(count))!=null) {
                   // System.debug('Acc column N° :'+count+' FieldapiName : '+mapAccountFields.get(mapHeaderByPosition.get(count))+'  HeaderName : '+mapHeaderByPosition.get(count) + ' FieldValue : '+tempField );

                    mapTypeField(currentProcess.currentAccount,mapAccountFields,count,tempField);
                    if('Tipo di Account'.equalsIgnoreCase(mapHeaderByPosition.get(count))){
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
                   
                }
                //Fine Creazione Account

                // Creazione Sales
                else if(mapSaleFields.get(mapHeaderByPosition.get(count))!=null ){
                    mapTypeField(currentProcess.currentSale,mapSaleFields,count,tempField);

                }
                // fine creazione sales

                // start Service Point 
                else if(mapServicePointFields.get(mapHeaderByPosition.get(count))!=null ){
                   mapTypeField(currentProcess.currentServicePoint,mapServicePointFields,count,tempField);
                }
                // Start Billing Profile

                else if(mapBillingProfileFields.get(mapHeaderByPosition.get(count))!=null ){
                    mapTypeField(currentProcess.currentBillingProfile,mapBillingProfileFields,count,tempField);
                }
                // End Billing Profile;

                // Start Order
                else if(mapOrderFields.get(mapHeaderByPosition.get(count))!=null ){
                    mapTypeField(currentProcess.currentChildOrder,mapOrderFields,count,tempField);
                    
                    if ('SelfCertificationConnection__c'.equalsIgnoreCase(mapOrderFields.get(mapHeaderByPosition.get(count)))) {
                        currentProcess.currentChildOrder.put(mapOrderFields.get(mapHeaderByPosition.get(count)),'Procura'.equalsIgnoreCase(tempField) ? '001':'Contratto firmato'.equalsIgnoreCase(tempField)?'002':null );
                    }
                    
                } // End Order
                // Start OrderItem
                else if(mapOrderItemFields.get(mapHeaderByPosition.get(count))!=null ){
                    mapTypeField(currentProcess.currentOrderItem,mapOrderItemFields,count,tempField);                 
                } // End OrderItem
                count++;
            }
        }

    }
    public override void getRecords(){
        /* Controllo se l'account esiste già se esiste recuperare anche il Contact 
        */
        makeContact();
        List<Account> lAccount=new List<Account>();
        List<ServicePoint__c> listServicePoint=new List<ServicePoint__c>();
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
            System.debug('Update Account esistente');
            currentProcess.currentAccount.Id=lAccount.get(0).Id;  
            System.debug('currentProcess.currentAccount: '+currentProcess.currentAccount); 
            String filterContact='FiscalCode__c=\''+currentProcess.currentAccount.FiscalCode__c+ '\' AND AccountId=\''+ currentProcess.currentAccount.Id+'\' LIMIT 10';
            List<Contact> listContact = qrCont.getContactList(filterContact);
            if (listContact!=null && listContact.size()>0) {
                currentProcess.currentPrimaryContact.Id=listContact.get(0).Id;
            }
        }
        // Start Controllo Service Point
        if (String.isNotBlank(currentProcess.currentServicePoint.Name)) {
            currentProcess.currentServicePoint.ServicePointCode__c=currentProcess.currentServicePoint.Name;
            listServicePoint=qrSerPoint.getServicePointsByCodeWithFilter(currentProcess.currentServicePoint.ServicePointCode__c,'id','');
            if (listServicePoint!=null &&listServicePoint.size()>0 ) {
                // se esiste il Service Point
                currentProcess.currentServicePoint.Id=listServicePoint.get(0).Id;
            }
        }
        // Fine controllo Service Point

       
    }

    public override void registryCreation(){
        listUpdateGeneric = new List<SObject>();
        verifyAccountAddress();
        HDT_UTL_Account.makeRequest(currentProcess.currentAccount,currentProcess.currentPrimaryContact); 
        if (currentProcess.currentAccount!=null &&currentProcess.currentAccount.Id==null ) {
            // solo se non esiste
            System.debug('Creazione Account');
            String expectedNewName = String.isBlank( currentProcess.currentAccount.FirstName__c) ?  currentProcess.currentAccount.LastName__c :  currentProcess.currentAccount.FirstName__c + ' ' +  currentProcess.currentAccount.LastName__c;
            currentProcess.currentAccount.Name=expectedNewName;
            //  currentProcess.currentAccount.BillingIsAddressVerified__c=true; 
            insert currentProcess.currentAccount;
            currentProcess.currentPrimaryContact.AccountId=currentProcess.currentAccount.id;
            insert currentProcess.currentPrimaryContact;   
        }
        else {
           

            listUpdateGeneric.add(currentProcess.currentAccount);
            listUpdateGeneric.add(currentProcess.currentPrimaryContact);

        }
        
        if(currentProcess.role!=null){
            System.debug('currentProcess.currentAccount.id '+currentProcess.currentAccount.id);
            System.debug('currentProcess.currentPrimaryContact.Id '+currentProcess.currentPrimaryContact.Id);
            List<AccountContactRelation> listAccCon= accoContRelQr.getAccountContactRelation(currentProcess.currentAccount.id,currentProcess.currentPrimaryContact.Id, 'Id');
            if(listAccCon != null && listAccCon.size() > 0){
                currentProcess.currentAccountContactRelation = new AccountContactRelation(Id= listAccCon[0].Id,Roles=currentProcess.role );
                System.debug('listAccCon '+ currentProcess.currentAccountContactRelation);     
                listUpdateGeneric.add(currentProcess.currentAccountContactRelation);
               
            }
        }

        currentProcess.currentSale.Account__c                       = currentProcess.currentAccount.Id;
        currentProcess.currentServicePoint.Account__c               = currentProcess.currentAccount.Id;
        currentProcess.currentBillingProfile.Account__c             = currentProcess.currentAccount.Id;
        currentProcess.currentChildOrder.AccountId                  = currentProcess.currentAccount.Id;
        currentProcess.currentRequestItem.Account__c                = currentProcess.currentAccount.Id;
        currentProcess.currentOrderItem.SBQQ__ShippingAccount__c    = currentProcess.currentAccount.Id;

        currentProcess.currentChildOrder.RecordTypeId               = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_Subentro').getRecordTypeId();

        if(currentProcess.currentServicePoint.CommoditySector__c.equalsIgnoreCase('Energia Elettrica')){
            currentProcess.currentChildOrder.ProcessType__c = 'Subentro Ele';
        }else if(currentProcess.currentServicePoint.CommoditySector__c.equalsIgnoreCase('Gas')){
            currentProcess.currentChildOrder.ProcessType__c = 'Subentro Gas';
        }else{
            throw new HDT_WRP_ProcessEntitiesException( 'Missing required field','Servizio not valid!');
        }
        
        makeFatherOrder();

        listUpdateGeneric.add(0, currentProcess.currentSale)           ;
        listUpdateGeneric.add(1, currentProcess.currentServicePoint)   ;
        listUpdateGeneric.add(2, currentProcess.currentBillingProfile) ;
       // listUpdateGeneric.add(currentProcess.currentOrder)          ;


       

    }

    public override void finalUpdate(){
        System.debug('finalUpdate');
        if (listUpdateGeneric.size()>0) {
            Savepoint sp = Database.setSavePoint();
            try {
                upsert listUpdateGeneric;
                
                currentProcess.currentFatherOrder.Sale__c                    = ((Sale__c)listUpdateGeneric.get(0)).Id           ;
                currentProcess.currentFatherOrder.ServicePoint__c            = ((ServicePoint__c)listUpdateGeneric.get(1)).Id   ;
                currentProcess.currentFatherOrder.BillingProfile__c          = ((BillingProfile__c)listUpdateGeneric.get(2)).Id ;
                insert currentProcess.currentFatherOrder                                                                        ;

                currentProcess.currentChildOrder.ParentOrder__c              = currentProcess.currentFatherOrder.Id             ;
                currentProcess.currentChildOrder.Sale__c                    = ((Sale__c)listUpdateGeneric.get(0)).Id            ;
                currentProcess.currentChildOrder.ServicePoint__c            = ((ServicePoint__c)listUpdateGeneric.get(1)).Id    ;
                currentProcess.currentChildOrder.BillingProfile__c          = ((BillingProfile__c)listUpdateGeneric.get(2)).Id  ;
                insert currentProcess.currentChildOrder                                                                         ;

                System.debug('OrderId:'+currentProcess.currentChildOrder.Id)                                                    ;

                makeServiceRequest();
                ServiceRequest__c sReq = HDT_SRV_ServiceRequest.createRecord(currentProcess.currentServiceRequest)              ;
                wrts_prcgvr.ObjectCompatibility_1_0.CheckResult result = HDT_UTL_MatrixCompatibility.checkCompatibility(sReq)   ;

                if(!result.incompatibilities.isEmpty()){
                    String compatibilityMessage = HDT_UTL_MatrixCompatibility.getIncompatibilityMessage((ServiceRequest__c[])result.incompatibilities);
                    HDT_SRV_ServiceRequest.deleteRecord(sReq);
                    throw new HDT_WRP_ProcessEntitiesException( 'Compatibility Alert',compatibilityMessage);
                }

                currentProcess.currentOrderItem.OrderId             = currentProcess.currentChildOrder.Id       ;
                currentProcess.currentOrderItem.BillingProfile__c   = currentProcess.currentBillingProfile.id   ;
                currentProcess.currentOrderItem.ServicePoint__c     = currentProcess.currentServicePoint.id     ;
                // insert currentProcess.currentOrderItem;
                
            } catch (Exception ex) {

                System.debug(ex.getMessage());
                Database.rollback(sp);
            }
        }
        currentProcess.currentRequestItem.Status__c=constant.MASSIVLOADER_STATUS_CHIUSO;
        update currentProcess.currentRequestItem;
    }



   /**
   * @description mapping Contact by Account
   **/
   private void makeContact(){
        currentProcess.currentPrimaryContact.DegreeOfStudies__c                 = currentProcess.currentAccount.DegreeOfStudies__c                   ;
        currentProcess.currentPrimaryContact.CompanyOwner__c                    = currentProcess.currentAccount.CompanyOwner__c                      ;
        currentProcess.currentPrimaryContact.LastName                           = currentProcess.currentAccount.LastName__c                          ;
        currentProcess.currentPrimaryContact.Gender__c                          = currentProcess.currentAccount.Gender__c                            ;
        currentProcess.currentPrimaryContact.FirstName                          = currentProcess.currentAccount.FirstName__c                         ;
        currentProcess.currentPrimaryContact.Birthdate                          = currentProcess.currentAccount.BirthDate__c                         ;
        currentProcess.currentPrimaryContact.FiscalCode__c                      = currentProcess.currentAccount.FiscalCode__c                        ;
        currentProcess.currentPrimaryContact.Birthcity__c                       = currentProcess.currentAccount.BirthProvince__c                     ;
        currentProcess.currentPrimaryContact.MobilePhonePrefix__c               = currentProcess.currentAccount.MobilePhonePrefix__c                 ;
        currentProcess.currentPrimaryContact.Phone                              = currentProcess.currentAccount.Phone                                ;
        currentProcess.currentPrimaryContact.MobilePhone                        = currentProcess.currentAccount.MobilePhone__c                       ;
        currentProcess.currentPrimaryContact.Email                              = currentProcess.currentAccount.PrimaryEmail__c                      ;
        currentProcess.currentPrimaryContact.PhonePrefix__c                     = currentProcess.currentAccount.PhonePrefix__c                       ;
        currentProcess.currentPrimaryContact.Fax                                = currentProcess.currentAccount.FAX__c                               ;                       
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

   private void makeFatherOrder(){

        currentProcess.currentFatherOrder.AccountId             = currentProcess.currentChildOrder.AccountId                                                               ;
        currentProcess.currentFatherOrder.Sale__c               = currentProcess.currentChildOrder.Sale__c                                                                 ;
        currentProcess.currentFatherOrder.ServicePoint__c       = currentProcess.currentChildOrder.ServicePoint__c                                                         ;
        currentProcess.currentFatherOrder.RecordTypeId          = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_OrderDossier').getRecordTypeId();

        currentProcess.currentFatherOrder.ContractSigned__c     = currentProcess.currentChildOrder.ContractSigned__c                                                       ;
        currentProcess.currentFatherOrder.SignatureMethod__c    = currentProcess.currentChildOrder.SignatureMethod__c                                                      ;
        currentProcess.currentFatherOrder.DocSendingMethod__c   = currentProcess.currentChildOrder.DocSendingMethod__c                                                     ;
        currentProcess.currentFatherOrder.Status                = currentProcess.currentChildOrder.Status                                                                  ;
        currentProcess.currentFatherOrder.EffectiveDate         = currentProcess.currentChildOrder.EffectiveDate                                                           ;
   }

   private void makeServiceRequest(){

        currentProcess.currentServiceRequest.ServicePointCode__c = currentProcess.currentServicePoint.Name; 
        currentProcess.currentServiceRequest.Status__c = 'Bozza';
        currentProcess.currentServiceRequest.Order__c = currentProcess.currentChildOrder.Id;
        currentProcess.currentServiceRequest.CommoditySector__c = currentProcess.currentServicePoint.CommoditySector__c;
        currentProcess.currentServiceRequest.Type__c = 'Order'; 
        if(currentProcess.currentServicePoint.Id != null){
            currentProcess.currentServiceRequest.ServicePoint__c = currentProcess.currentServicePoint.Id;
        }else{
            currentProcess.currentServiceRequest.Account__c = currentProcess.currentChildOrder.AccountId;
            currentProcess.currentServiceRequest.BillingProfile__c = currentProcess.currentChildOrder.BillingProfile__c;
        }
        currentProcess.currentServiceRequest.ProcessType__c= HDT_UTL_MatrixCompatibility.getProcessType(currentProcess.currentChildOrder.ProcessType__c, 'Order', String.valueOf(currentProcess.currentServicePoint.CommoditySector__c));
   }
   
   private void mapFieldsObject(){
        mapAccountFields = new Map<String, String>{
            'Nome'                                                  =>  'FirstName__c'                                  ,
            'Cognome/Ragione Sociale'                               =>  'LastName__c'                                   ,
            'Codice Fiscale'                                        =>  'FiscalCode__c'                                 ,
            'P.IVA'                                                 =>  'VATNumber__c'                                  ,
            'BP'                                                    =>  'BPSAPModel__c'                                 ,
            'Marcatura'                                             =>  'CustomerMarking__c'                            ,
            'Categoria'                                             =>  'Category__c'                                   ,
            'Silos'                                                 =>  'CompanyOwner__c'                               ,
           // 'Barrato'=>'',
            'Prefisso Cellulare'                                    =>  'MobilePhonePrefix__c'                          ,
            'Cellulare'                                             =>  'MobilePhone__c'                                ,
            'Prefisso telefono fisso'                               =>  'PhonePrefix__c'                                ,
            'Telefono fisso'                                        =>  'Phone'                                         ,
            'Altro Telefono'                                        =>  'OtherPhone__c'                                 ,
            'Email'                                                 =>  'PrimaryEmail__c'                               ,
            'FAX'                                                   =>  'FAX__c'                                        ,
            'Data nascita'                                          =>  'BirthDate__c'                                  ,
            'Comune di nascita'                                     =>  'BirthProvince__c'                              ,
            'Sesso'                                                 =>  'Gender__c'                                     ,
            'Tipo di Account'                                       =>  'RecordTypeId'                                  ,
            'Titolo di studio'                                      =>  'DegreeOfStudies__c'                            ,
            'Professione'                                           =>  'Profession__c'                                 ,
            // indirizzo
            'Nome Via [Residenziale/Sede Legale]'                   =>  'BillingStreetName__c'                          ,
            'Comune'                                                =>  'BillingCity'                                   ,
            'CAP'                                                   =>  'BillingPostalCode'                             ,
            'Stato'                                                 =>  'BillingCountry'                                ,
            'Provincia'                                             =>  'BillingState'                                  ,
            'Codice Via Stradario SAP'                              =>  'BillingStreetCode__c'                          ,
            'Estens.Civico'                                         =>  'BillingStreetNumberExtension__c'               ,
            'Civico'                                                =>  'BillingStreetNumber__c'                        ,
            'Indirizzo Estero'                                      =>  'ShippingAddressIsForeign__c'                   ,
            'Localita'                                              =>  'BillingPlace__c'                               ,
            'Codice Localita'                                       =>  'BillingPlaceCode__c'                           ,
            'Flag Verificato'                                       =>  'BillingIsAddressVerified__c'
            // inserire domicilio
        };
        mapSaleFields = new Map<String, String>{
            'Canale'                                                =>  'Channel__c'                                    ,
            'Codice Amico'                                          =>  'FriendCode__c '                                ,
            'Agenzia'                                               =>  'Agency__c'                                     ,
            'Venduto Da'                                            =>  'SaleBy__c'                                     ,
            'Nome Agente'                                           =>  'VendorFirstName__c'                            ,
            'Cognome Agente'                                        =>  'VendorLastName__c'                             ,
            'Campagna'                                              =>  'Campaign__c'                                   ,
            'Campagna Commissioning'                                =>  'CommissioningCampaign__c'
        };
        mapServicePointFields=new Map<String, String>{  
            'SP_Codice POD/PDR'                                     =>  'Name'                                          ,
            'Servizio'                                              =>  'CommoditySector__c'                            ,
            'Distributore'                                          =>  'Distributor__c'                                ,
            'Tipo Fornitura'                                        =>  'SupplyType__c'                                 ,
            'Tipologia Impianto'                                    =>  'ImplantType__c'                                ,
            'Consumo annuo'                                         =>  'AnnualConsumption__c'                          ,
            'Mercato di provenienza'                                =>  'MarketOrigin__c'                               ,
            'Classe Contatore'                                      =>  'MeterClass__c'                                 ,
            'Categoria D\'Uso'                                      =>  'UseCategory__c'                                ,
            'Disalimentabile'                                       =>  'Disconnectable__c'                             ,
            'Tipologia Disalimentabilità'                           =>  'DisconnectibilityType__c'                      ,
            'Telefono non disalimentabilità'                        =>  'DisconnectibilityPhone__c'                     ,
            'Residente'                                             =>  'Resident__c'                                   ,
            'Potenza contrattuale'                                  =>  'PowerContractual__c'                           ,
            'Potenza disponibile'                                   =>  'PowerAvailable__c'                             ,
            'Tensione di Consegna'                                  =>  'VoltageLevel__c'                               ,
            'Presenza Allaccio'                                     =>  'PlugPresence__c'                               ,
            'Fase Richiesta'                                        =>  'RequestPhase__c'                               ,
            'Tipo Apparecchiatura'                                  =>  'MeterType__c'                                  ,
            'Potenza Richiesta'                                     =>  'PowerRequested__c'                             ,
            'Matricola Contatore'                                   =>  'MeterSN__c'                                    ,
            'Codice Remi'                                           =>  'RemiCode__c'                                   ,
            'Livello pressione'                                     =>  'PressureLevel__c'                              ,
            'Classe di prelievo'                                    =>  'WithdrawalClass__c'                            ,
            'Potenzialità massima richiesta'                        =>  'MaxRequiredPotential__c'                       ,
            'SP_Comune'                                             =>  'SupplyCity__c'                                 ,
            'SP_Via'                                                =>  'SupplyStreetName__c'                           ,
            'SP_Civico'                                             =>  'SupplyStreetNumber__c'                         ,
            'SP_Indirizzo Estero'                                   =>  'SupplyAddessIsForeign__c'
        };
        mapBillingProfileFields=new Map<String, String>{
            'Modalità di Pagamento'                                 =>  'PaymentMethod__c'                              ,
            'Modalità invio bolletta'                               =>  'BillSendingMethod__c'                          ,
            'Email invio Bolletta'                                  =>  'InvoiceEmailAddress__c'                        ,
            'Destinatario Divergente'                               =>  'DivergentSubject__c'                           ,
            'Tiplo XML'                                             =>  'XMLType__c'                                    ,
            'IBAN Estero'                                           =>  'IbanIsForeign__c'                              ,
            'IBAN'                                                  =>  'IBAN__c'                                       ,
            'Paese'                                                 =>  'IbanCountry__c'                                ,
            'CIN-IBAN'                                              =>  'IbanCIN_IBAN__c'                               ,
            'CIN'                                                   =>  'IbanCIN__c'                                   ,
            'ABI'                                                   =>  'IbanABI__c'                                    ,
            'CAB'                                                   =>  'IbanCAB__c'                                    ,
            'Numero Conto'                                          =>  'IbanCodeNumber__c'                             ,
            'Tipo Sottoscrittore'                                   =>  'SignatoryType__c'                              ,
            'Nome Sottoscrittore CC'                                =>  'BankAccountSignatoryFirstName__c'              ,
            'Cognome Sottoscrittore CC'                             =>  'BankAccountSignatoryLastName__c'               , 
            'Codice Fiscale sottoscrittore CC'                      =>  'BankAccountSignatoryFiscalCode__c'             ,
            'Modalità invio Fatturazion Elettronica'                =>  'ElectronicInvoicingMethod__c'                  ,
            'Pec Fatturazione Elettronica'                          =>  'ElectronicInvoiceCertifiedEmailAddress__c'     ,
            'Codice Destinatario'                                   =>  'SubjectCode__c'                                ,
            'BP_Comune'                                             =>  'InvoicingCity__c'                              ,
            'BP_Via'                                                =>  'InvoicingStreetName__c'                        ,
            'BP_Civico'                                             =>  'InvoicingStreetNumber__c'
        };
        mapOrderFields=new Map<String, String>{
            'Contratto Firmato'                                     =>  'ContractSigned__c'                              ,
            'Data Firma'                                            =>  'SignedDate__c'                                  ,
            'Metodo Firma'                                          =>  'SignatureMethod__c'                             ,
            'Modalità invio doc'                                    =>  'DocSendingMethod__c'                            ,
            'Uso Energia'                                           =>  'UseTypeEnergy__c'                               ,
            'Mandato di Connessione'                                =>  'ConnectionMandate__c'                           ,
            'Autocert.Contr.Connessione'                            =>  'SelfCertificationConnection__c'                 ,
            'Tipo di Connessione'                                   =>  'ConnectionType__c'                              ,
            'Opzione di distribuzione'                              =>  'RequestOption__c '                              ,
            'Recapito Telefonico'                                   =>  'PhoneNumber__c'                                 ,
            'Azione Commerciale'                                    =>  'CommercialAction__c'                            ,
            'Codice ISTAT/Ateco'                                    =>  'AtecoCode__c'                                   ,
            'Autocert.Istanza'                                      =>  'InstanceSelfCertification__c'                   ,
            'Note per il DL'                                        =>  'CommentForDL__c'                                ,
            'Convenzione/Associazione'                              =>  'ConventionAssociation__c'                       ,
            'Superficie Servita'                                    =>  'SurfaceServed__c'                               ,
            'Esclusione Deposito cauzionale'                        =>  'SecurityDepositExcluded__c'                     ,
            'Fatturazione Aggregata'                                =>  'AggregateBilling__c'                            ,
            'IVA'                                                   =>  'VAT__c'                                         ,
            'OR_Date Inizio'                                        =>  'EffectiveDate'                                  ,
            'OR_Status'                                             =>  'Status'    
        };
        mapOrderItemFields=new Map<String, String>{
        //  'Descrizione Offerta'                                   =>  'ProductName__c'                                 ,
            'Modalità di Pagamento'                                 =>  'PaymentMode__c'                                 ,
            'Modalità invio Belletta'                               =>  'SendingBillMode__c'                             ,
            'Contributi'                                            =>  'DescriptionSAPBonusContributo__c'               ,
            'Superficie MQ'                                         =>  'Surface__c'                                     ,
            'Numero Occupanti'                                      =>  'OccupantsNumber__c'                             ,
            'Proprietario'                                          =>  'OwnerAC__c'                                     ,
            'Tipo Abitazione'                                       =>  'DwellingType__c'                                ,
            'Mantieni Analisi Consumi'                              =>  'KeepConsumptionsAnalysis__c'                    ,
            'VAS - Data attivazione'                                =>  'VasActivationDate__c'
        };
    } 
}
