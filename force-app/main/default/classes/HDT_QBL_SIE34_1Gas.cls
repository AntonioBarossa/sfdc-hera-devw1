public with sharing class HDT_QBL_SIE34_1Gas implements Queueable  {
    private String runId                   ;   
    private Datetime filterDate            ;
    private String fileType                ;
    private List<String> contentVersionIds ;
    private final String NOTMAPPED=''      ;

 
    public HDT_QBL_SIE34_1Gas(String varRunId,String varDate,String varFileType) {
       this.runId             = varRunId                                           ;
       System.debug('filterDate: '+HDT_UTL_LeadProcess.getDateTimeFromString(varDate));
       this.filterDate        = HDT_UTL_LeadProcess.getDateTimeFromString(varDate) ;

       this.fileType          = varFileType                                        ;
       this.contentVersionIds = new List<String>()                                 ;
    }
 
 
    public void execute(QueueableContext context) {
       String status                  = 'success'      ;
       String errorMessage            = ''             ;
   
       String condition = ' WHERE Order.Phase__c IN (\'Inviato al DL\',\'Completata\') AND Order.Commodity__c =\'GAS\' AND LastModifiedDate >=:filterDate ';
       String query     = 'SELECT  Order.Account.Fax__c,Order.Account.FirstName__c, Order.Account.lastName__c, order.ResidentialState__c,order.ResidentialPostalCode__c,order.ResidentialPlace__c,order.ResidentialCity__c,Order.ResidentialStreetNumber__c,order.Contact__r.Account.FAX__c,Order.Contact__r.MobilePhone,Order.Account.CustomerCode__c, Order.Account.Category__c, Order.Account.FiscalCode__c,  Order.Account.VATNumber__c, Order.Account.LegalFormType__c, Order.BillingProfile__r.BankAccountSignatoryFirstName__c, Order.BillingProfile__r.BankAccountSignatoryFiscalCode__c, Order.BillingProfile__r.BankAccountSignatoryLastName__c, Order.BillingProfile__r.BankAgency__c, Order.BillingProfile__r.BankName__c, Order.BillingProfile__r.IbanABI__c, Order.BillingProfile__r.IbanCAB__c, Order.BillingProfile__r.IbanCIN_IBAN__c, Order.BillingProfile__r.IbanCIN__c, Order.BillingProfile__r.IbanCodeNumber__c, Order.BillingProfile__r.IbanCountry__c, Order.BillingProfile__r.PaymentMethod__c,  Order.Account.FAX, Order.Contact__r.Email, Order.Contact__r.Phone, Order.Agency__c, Order.AggregateBilling__c, Order.AnnualConsumption__c, Order.AtecoCode__c, Order.Channel__c, Order.CommentForDL__c, Order.CommercialAction__c, Order.CommercialProductVersion__c, Order.ConnectionMandate__c, Order.ContractId, Order.CreatedBy__c, Order.createddate, Order.CustomerCompanyName__c, Order.CustomerFiscalCode__c, Order.CustomerLastName__c, Order.CustomerName__c, Order.Disconnectable__c, Order.DisconnectibilityType__c, Order.DistributorCode__c, Order.EffectiveDate, Order.ExciseGAS__c, Order.ImplantType__c, Order.MarketOrigin__c, Order.MaxRequiredPotential__c, Order.MeterClass__c, Order.MeterSN__c, Order.OrderNumber, Order.PhoneNumber__c, Order.PowerAvailable__c, Order.Pressure__c, Order.PreviousHolderFirstName__c, Order.PreviousHolderFiscalCode__c, Order.PreviousHolderLastName__c, Order.PreviousHolderVatNumber__c, Order.PreviousTrader__c, Order.ProcessType__c, Order.Profile__c, Order.RemiCode__c, Order.ResidentialStreetName__c, Order.SalesContact__r.FirstName, Order.SalesContact__r.LastName, Order.SelfCertificationConnection__c, Order.ServicePointCodeFormula__c, Order.ShippingCity__c, Order.ShippingPlaceCode__c, Order.ShippingPostalCode__c, Order.ShippingProvince__c, Order.ShippingStreetName__c, Order.ShippingStreetNumber__c, Order.SignedDate__c, Order.SupplyCityCode__c, Order.SupplyCity__c, Order.SupplyPlace__c, Order.SupplyPostalCode__c, Order.SupplyState__c, Order.SupplyStreetName__c, Order.SupplyStreetNumber__c, Order.TemporaryConnectionEndDate__c, Order.TemporaryConnectionStartDate__c, Order.UseCategory__c, Order.VAT__c, Order.VendorFirstName__c, Order.VendorLastName__c, Order.WithdrawalClass__c, PriceGas__c, PriceGreenOption__c from OrderItem ';
       String separator = ';';

              
       try {
          List<OrderItem> listOrderItem = Database.query(query+condition);
          
         // String header='Prezzo Opzione Verde,Prezzo GAS,classe di prelievo,cognome_venditore,nome_venditore,percentuale_iva,categoria d\'uso,Attività stagionale dal,al,civico_fornitura,indirizzo_fornitura,provincia_fornitura,cap_fornitura,localita_fornitura,cod_istat_comune,comune_fornitura,Data firma contratto,civico_spedizione,indirizzo_spedizione,provincia_spedizione,cap_spedizione,localita_spedizione,comune_spedizione,pod,autocertificazione contr connessione,INDIRIZZO CONTO CONTRATTUALE,codice_remi,profilo,tipo ordine,societa_uscente,PIVA_PRECEDENTE_INTESTATARIO,COGNOME_PRECEDENTE_INTESTATARIO,CF_PRECEDENTE_INTESTATARIO,NOME_PRECEDENTE_INTESTATARIO,pressione di fornitura,potenzialità totale installata presso l’impianto del cliente finale,recapito telefonico,numero_sr,matricola,classe contatore,potenzialità massima richiesta dal cliente finale (in kW),provenienza,uso,tipologia_imposta,data_inizio,cod_distributore,Categoria di disalimentazione,Disalimentazione,Cognome,Nome,societa_erogatrice,ragione sociale (in alternativa a nome/cognome),data_richiesta,RdS Creata Da,tacito_rinnovo,mandato di connessione,VERSIONE,azione_commerciale,annotazioni,canale,tipologia_pagamento,pagamento,Paese,banca_cc,CIN-IBAN,banca_cin,banca_cab,banca_abi,banca_denominazione,Agenzia Banca,cognome_sottoscritore_rid,cf_sottoscrittore_rid,nome_sottoscritore_rid,Cod istat ateco,consumi_anno,fatturazione_congiunta,agenzia,cognome legale rappresentante ,nome legale rappresentante,tel,e-mail,fax,p_iva,civico_sede_legale,indirizzo_sede_legale,provincia_sede_legale,cap_sede_legale,localita_sede_legale,comune_sede_legale,consorzio,cod_fiscale,rag_sociale + " " + Nome,codice_cliente,CATEGORIA CLIENTE \n';
         
         
         
          String body  ='';
      
          for (OrderItem tempOrderItem: listOrderItem) {
            //String name=String.isNotBlank(tempOrderItem.order.Account.FirstName__c)? ' ' +tempOrderItem.order.Account.FirstName__c:'';

            String row =                                     
            //    tempOrderItem.order.Account.lastName__c +name                                +','+                                                    
            tempOrderItem.PriceGreenOption__c                                                 +separator+                                                 
            tempOrderItem.PriceGas__c                                                         +separator+                                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            tempOrderItem.Order.WithdrawalClass__c                                            +separator+                                                      
            tempOrderItem.Order.VendorLastName__c                                             +separator+                                                      
            tempOrderItem.Order.VendorFirstName__c                                            +separator+                                                       
            tempOrderItem.Order.VAT__c                                                        +separator+                                          
            tempOrderItem.Order.UseCategory__c                                                +separator+                                                  
            tempOrderItem.Order.TemporaryConnectionStartDate__c                               +separator+                                                                   
            tempOrderItem.Order.TemporaryConnectionEndDate__c                                 +separator+                                                                 
            tempOrderItem.Order.SupplyStreetNumber__c                                         +separator+                                                         
            tempOrderItem.Order.SupplyStreetName__c                                           +separator+                                                       
            tempOrderItem.Order.SupplyState__c                                                +separator+                                                  
            tempOrderItem.Order.SupplyPostalCode__c                                           +separator+                                                       
            tempOrderItem.Order.SupplyPlace__c                                                +separator+                                                  
            tempOrderItem.Order.SupplyCityCode__c                                             +separator+                                                     
            tempOrderItem.Order.SupplyCity__c                                                 +separator+                                                 
            tempOrderItem.Order.SignedDate__c                                                 +separator+                                                 
            tempOrderItem.Order.ShippingStreetNumber__c                                       +separator+                                                           
            tempOrderItem.Order.ShippingStreetName__c                                         +separator+                                                         
            tempOrderItem.Order.ShippingProvince__c                                           +separator+                                                       
            tempOrderItem.Order.ShippingPostalCode__c                                         +separator+                                                         
            tempOrderItem.Order.ShippingPlaceCode__c                                          +separator+                                                        
            tempOrderItem.Order.ShippingCity__c                                               +separator+                                                   
            tempOrderItem.Order.ServicePointCodeFormula__c                                    +separator+                                                              
            tempOrderItem.Order.SelfCertificationConnection__c                                +separator+                                                                  
            tempOrderItem.Order.ResidentialStreetName__c                                      +separator+                                                            
            tempOrderItem.Order.RemiCode__c                                                   +separator+                                               
            tempOrderItem.Order.Profile__c                                                    +separator+                                              
            tempOrderItem.Order.ProcessType__c                                                +separator+                                                  
            tempOrderItem.Order.PreviousTrader__c                                             +separator+                                                     
            tempOrderItem.Order.PreviousHolderVatNumber__c                                    +separator+                                                               
            tempOrderItem.Order.PreviousHolderLastName__c                                     +separator+                                                              
            tempOrderItem.Order.PreviousHolderFiscalCode__c                                   +separator+                                                                
            tempOrderItem.Order.PreviousHolderFirstName__c                                    +separator+                                                               
            tempOrderItem.Order.Pressure__c                                                   +separator+                                               
            tempOrderItem.Order.PowerAvailable__c                                             +separator+                                                     
            tempOrderItem.Order.PhoneNumber__c                                                +separator+                                                  
            tempOrderItem.Order.OrderNumber                                                   +separator+                                               
            tempOrderItem.Order.MeterSN__c                                                    +separator+                                              
            tempOrderItem.Order.MeterClass__c                                                 +separator+                                                 
            tempOrderItem.Order.MaxRequiredPotential__c                                       +separator+                                                           
            tempOrderItem.Order.MarketOrigin__c                                               +separator+                                                   
            tempOrderItem.Order.ImplantType__c                                                +separator+                                                  
            tempOrderItem.Order.ExciseGAS__c                                                  +separator+                                                
            tempOrderItem.Order.EffectiveDate                                                 +separator+                                                 
            tempOrderItem.Order.DistributorCode__c                                            +separator+                                                      
            tempOrderItem.Order.DisconnectibilityType__c                                      +separator+                                                            
            tempOrderItem.Order.Disconnectable__c                                             +separator+                                                     
            tempOrderItem.Order.CustomerName__c                                               +separator+                                                   
            tempOrderItem.Order.CustomerLastName__c                                           +separator+                                                       
            tempOrderItem.Order.CustomerFiscalCode__c                                         +separator+                                                         
            tempOrderItem.Order.CustomerCompanyName__c                                        +separator+                                                          
            tempOrderItem.Order.createddate                                                   +separator+                                               
            tempOrderItem.Order.CreatedBy__c                                                  +separator+                                                 
            tempOrderItem.Order.ContractId                                                    +separator+                                              
            tempOrderItem.Order.ConnectionMandate__c                                          +separator+                                                        
            tempOrderItem.Order.CommercialProductVersion__c                                   +separator+                                                               
            tempOrderItem.Order.CommercialAction__c                                           +separator+                                                       
            tempOrderItem.Order.CommentForDL__c                                               +separator+                                                   
            tempOrderItem.Order.Channel__c                                                    +separator+                                               
            NOTMAPPED                                                                         +separator+                                                                     
            tempOrderItem.Order.BillingProfile__r.PaymentMethod__c                            +separator+                                                                      
            tempOrderItem.Order.BillingProfile__r.IbanCountry__c                              +separator+                                                                     
            tempOrderItem.Order.BillingProfile__r.IbanCodeNumber__c                           +separator+                                                                        
            tempOrderItem.Order.BillingProfile__r.IbanCIN_IBAN__c                             +separator+                                                                      
            tempOrderItem.Order.BillingProfile__r.IbanCIN__c                                  +separator+                                                                 
            tempOrderItem.Order.BillingProfile__r.IbanCAB__c                                  +separator+                                                                 
            tempOrderItem.Order.BillingProfile__r.IbanABI__c                                  +separator+                                                                 
            tempOrderItem.Order.BillingProfile__r.BankName__c                                 +separator+                                                                 
            tempOrderItem.Order.BillingProfile__r.BankAgency__c                               +separator+                                                                   
            tempOrderItem.Order.BillingProfile__r.BankAccountSignatoryLastName__c             +separator+                                                                                      
            tempOrderItem.Order.BillingProfile__r.BankAccountSignatoryFiscalCode__c           +separator+                                                                                        
            tempOrderItem.Order.BillingProfile__r.BankAccountSignatoryFirstName__c            +separator+                                                                                       
            NOTMAPPED                                                                         +separator+                                                       
            NOTMAPPED                                                                         +separator+                                                       
            tempOrderItem.Order.AtecoCode__c                                                  +separator+                                                
            tempOrderItem.Order.AnnualConsumption__c                                          +separator+                                                        
            tempOrderItem.Order.AggregateBilling__c                                           +separator+                                                       
            tempOrderItem.Order.Agency__c                                                     +separator+                                              
            tempOrderItem.Order.SalesContact__r.LastName                                      +separator+                                                            
            tempOrderItem.Order.SalesContact__r.FirstName                                     +separator+                                                             
            tempOrderItem.Order.Contact__r.Phone                                              +separator+                                                     
            tempOrderItem.Order.Contact__r.email                                              +separator+                                            
            tempOrderItem.Order.Account.FAX__c                                                +separator+                                                       
            tempOrderItem.Order.Account.VATNumber__c                                          +separator+                                                  
            tempOrderItem.Order.ResidentialStreetNumber__c                                    +separator+                                                                 
            tempOrderItem.Order.ResidentialStreetName__c                                      +separator+                                                               
            tempOrderItem.Order.ResidentialState__c                                           +separator+                                                          
            tempOrderItem.Order.ResidentialPostalCode__c                                      +separator+                                                               
            tempOrderItem.Order.ResidentialPlace__c                                           +separator+                                                          
            tempOrderItem.Order.ResidentialCity__c                                            +separator+                                                         
            tempOrderItem.Order.Account.LegalFormType__c                                      +separator+                                                      
            tempOrderItem.Order.Account.FiscalCode__c                                         +separator+                                                            
            tempOrderItem.Order.CustomerCompanyName__c                                        +separator+                                                             
            tempOrderItem.Order.CustomerCompanyName__c                                        +separator+                                                             
            tempOrderItem.Order.Account.CustomerCode__c                                       +separator+                                                     
            tempOrderItem.Order.Account.Category__c                                           +separator+                                                          
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                         +separator+                         
            NOTMAPPED                                                                              ;  
                                                          
            row = row.replaceAll('null', '');  
                
                                                     
             
             if (String.isBlank(body)) {
                body=row;
             }
             else {
                body=body+'\n'+row; 
             }
          }
        if (listOrderItem!=null && listOrderItem.size()>0 ) {
            contentVersionIds.add(HDT_UTL_ContentVersion.makeFile(body,'OUT_OP_GAS.txt','OUT_OP_GAS'));
         }
         System.enqueueJob(new HDT_QBL_SIE34_1EE(runId,filterDate, fileType,contentVersionIds));
         
       } 
       catch (Exception e) {
          errorMessage=e.getMessage();
          status='failed';
          System.enqueueJob(new HDT_QBL_SIE34CallService(runId,status, fileType, errorMessage,new List<String>()));
       }
      
    }
  
 }
 