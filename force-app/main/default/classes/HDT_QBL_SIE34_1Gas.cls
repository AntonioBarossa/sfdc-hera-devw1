public with sharing class HDT_QBL_SIE34_1Gas implements Queueable  {
    private String runId                   ;   
    private Date filterDate                ;
    private String fileType                ;
    private List<String> contentVersionIds ;
 
 
    public HDT_QBL_SIE34_1Gas(String varRunId,Date varDate,String varFileType) {
       System.debug('Start HDT_QBL_SIE34_1Gas')             ;
       this.runId             = varRunId                    ;
       this.filterDate        = varDate                     ;
       this.fileType          = varFileType                 ;
       this.contentVersionIds = new List<String>()          ;
    }
 
 
    public void execute(QueueableContext context) {
       System.debug('HDT_QBL_SIE34_1Gas.execute')      ;
       String status                  = 'success'      ;
       String errorMessage            = ''             ;
   
       String condition = ' WHERE Phase__c IN (\'Inviato a DL\',\'Completata\') AND Commodity__c =\'GAS\' AND LastModifiedDate >=:filterDate ';
       String query     = 'SELECT Order.Account.CustomerCode__c, Order.Account.Category__c, Order.Account.FiscalCode__c,  Order.Account.VATNumber__c, Order.Account.LegalFormType__c, Order.BillingProfile__r.BankAccountSignatoryFirstName__c, Order.BillingProfile__r.BankAccountSignatoryFiscalCode__c, Order.BillingProfile__r.BankAccountSignatoryLastName__c, Order.BillingProfile__r.BankAgency__c, Order.BillingProfile__r.BankName__c, Order.BillingProfile__r.IbanABI__c, Order.BillingProfile__r.IbanCAB__c, Order.BillingProfile__r.IbanCIN_IBAN__c, Order.BillingProfile__r.IbanCIN__c, Order.BillingProfile__r.IbanCodeNumber__c, Order.BillingProfile__r.IbanCountry__c, Order.BillingProfile__r.PaymentMethod__c,  Order.Account.FAX, Order.Contact__r.Email, Order.Contact__r.Phone, Order.Agency__c, Order.AggregateBilling__c, Order.AnnualConsumption__c, Order.AtecoCode__c, Order.Channel__c, Order.CommentForDL__c, Order.CommercialAction__c, Order.CommercialProductVersion__c, Order.ConnectionMandate__c, Order.ContractId, Order.CreatedBy__c, Order.createddate, Order.CustomerCompanyName__c, Order.CustomerFiscalCode__c, Order.CustomerLastName__c, Order.CustomerName__c, Order.Disconnectable__c, Order.DisconnectibilityType__c, Order.DistributorCode__c, Order.EffectiveDate, Order.ExciseGAS__c, Order.ImplantType__c, Order.MarketOrigin__c, Order.MaxRequiredPotential__c, Order.MeterClass__c, Order.MeterSN__c, Order.OrderNumber, Order.PhoneNumber__c, Order.PowerAvailable__c, Order.Pressure__c, Order.PreviousHolderFirstName__c, Order.PreviousHolderFiscalCode__c, Order.PreviousHolderLastName__c, Order.PreviousHolderVatNumber__c, Order.PreviousTrader__c, Order.ProcessType__c, Order.Profile__c, Order.RemiCode__c, Order.ResidentialStreetName__c, Order.SalesContact__r.FirstName, Order.SalesContact__r.LastName, Order.SelfCertificationConnection__c, Order.ServicePointCodeFormula__c, Order.ShippingCity__c, Order.ShippingPlaceCode__c, Order.ShippingPostalCode__c, Order.ShippingProvince__c, Order.ShippingStreetName__c, Order.ShippingStreetNumber__c, Order.SignedDate__c, Order.SupplyCityCode__c, Order.SupplyCity__c, Order.SupplyPlace__c, Order.SupplyPostalCode__c, Order.SupplyState__c, Order.SupplyStreetName__c, Order.SupplyStreetNumber__c, Order.TemporaryConnectionEndDate__c, Order.TemporaryConnectionStartDate__c, Order.UseCategory__c, Order.VAT__c, Order.VendorFirstName__c, Order.VendorLastName__c, Order.WithdrawalClass__c, PriceGas__c, PriceGreenOption__c from OrderItem ';
    
    
       try {
          
          System.debug('query: '+query+condition);
          List<OrderItem> listOrderItem = Database.query(query+condition);
          
          String header='Prezzo Opzione Verde,Prezzo GAS,classe di prelievo,cognome_venditore,nome_venditore,percentuale_iva,categoria d\'uso,Attività stagionale dal,al,civico_fornitura,indirizzo_fornitura,provincia_fornitura,cap_fornitura,localita_fornitura,cod_istat_comune,comune_fornitura,Data firma contratto,civico_spedizione,indirizzo_spedizione,provincia_spedizione,cap_spedizione,localita_spedizione,comune_spedizione,pod,autocertificazione contr connessione,INDIRIZZO CONTO CONTRATTUALE,codice_remi,profilo,tipo ordine,societa_uscente,PIVA_PRECEDENTE_INTESTATARIO,COGNOME_PRECEDENTE_INTESTATARIO,CF_PRECEDENTE_INTESTATARIO,NOME_PRECEDENTE_INTESTATARIO,pressione di fornitura,potenzialità totale installata presso l’impianto del cliente finale,recapito telefonico,numero_sr,matricola,classe contatore,potenzialità massima richiesta dal cliente finale (in kW),provenienza,uso,tipologia_imposta,data_inizio,cod_distributore,Categoria di disalimentazione,Disalimentazione,Cognome,Nome,societa_erogatrice,ragione sociale (in alternativa a nome/cognome),data_richiesta,RdS Creata Da,tacito_rinnovo,mandato di connessione,VERSIONE,azione_commerciale,annotazioni,canale,tipologia_pagamento,pagamento,Paese,banca_cc,CIN-IBAN,banca_cin,banca_cab,banca_abi,banca_denominazione,Agenzia Banca,cognome_sottoscritore_rid,cf_sottoscrittore_rid,nome_sottoscritore_rid,Cod istat ateco,consumi_anno,fatturazione_congiunta,agenzia,cognome legale rappresentante ,nome legale rappresentante,tel,e-mail,fax,p_iva,civico_sede_legale,indirizzo_sede_legale,provincia_sede_legale,cap_sede_legale,localita_sede_legale,comune_sede_legale,consorzio,cod_fiscale,rag_sociale + " " + Nome,rag_sociale + " " + Nome,codice_cliente,CATEGORIA CLIENTE \n';
         
         
         
          String body  ='';
      
          for (OrderItem tempOrderItem: listOrderItem) {
              // String name=String.isNotBlank(tempCase.FirstName__c)?' ' + tempCase.FirstName__c:'';
   
               String row = tempOrderItem.PriceGreenOption__c                               +','+
               tempOrderItem.PriceGas__c                                                    +','+
               tempOrderItem.Order.WithdrawalClass__c                                       +','+                                             
               tempOrderItem.Order.VendorLastName__c                                        +','+                                             
               tempOrderItem.Order.VendorFirstName__c                                       +','+                                              
               tempOrderItem.Order.VAT__c                                                   +','+                                 
               tempOrderItem.Order.UseCategory__c                                           +','+                                         
               tempOrderItem.Order.TemporaryConnectionStartDate__c                          +','+                                                          
               tempOrderItem.Order.TemporaryConnectionEndDate__c                            +','+                                                        
               tempOrderItem.Order.SupplyStreetNumber__c                                    +','+                                                
               tempOrderItem.Order.SupplyStreetName__c                                      +','+                                              
               tempOrderItem.Order.SupplyState__c                                           +','+                                         
               tempOrderItem.Order.SupplyPostalCode__c                                      +','+                                              
               tempOrderItem.Order.SupplyPlace__c                                           +','+                                         
               tempOrderItem.Order.SupplyCityCode__c                                        +','+                                            
               tempOrderItem.Order.SupplyCity__c                                            +','+                                        
               tempOrderItem.Order.SignedDate__c                                            +','+                                        
               tempOrderItem.Order.ShippingStreetNumber__c                                  +','+                                                  
               tempOrderItem.Order.ShippingStreetName__c                                    +','+                                                
               tempOrderItem.Order.ShippingProvince__c                                      +','+                                              
               tempOrderItem.Order.ShippingPostalCode__c                                    +','+                                                
               tempOrderItem.Order.ShippingPlaceCode__c                                     +','+                                               
               tempOrderItem.Order.ShippingCity__c                                          +','+                                          
               tempOrderItem.Order.ServicePointCodeFormula__c                               +','+                                                     
               tempOrderItem.Order.SelfCertificationConnection__c                           +','+                                                         
               tempOrderItem.Order.ResidentialStreetName__c                                 +','+                                                   
               tempOrderItem.Order.RemiCode__c                                              +','+                                      
               tempOrderItem.Order.Profile__c                                               +','+                                     
               tempOrderItem.Order.ProcessType__c                                           +','+                                         
               tempOrderItem.Order.PreviousTrader__c                                        +','+                                            
               tempOrderItem.Order.PreviousHolderVatNumber__c                               +','+                                                      
               tempOrderItem.Order.PreviousHolderLastName__c                                +','+                                                     
               tempOrderItem.Order.PreviousHolderFiscalCode__c                              +','+                                                       
               tempOrderItem.Order.PreviousHolderFirstName__c                               +','+                                                      
               tempOrderItem.Order.Pressure__c                                              +','+                                      
               tempOrderItem.Order.PowerAvailable__c                                        +','+                                            
               tempOrderItem.Order.PhoneNumber__c                                           +','+                                         
               tempOrderItem.Order.OrderNumber                                              +','+                                      
               tempOrderItem.Order.MeterSN__c                                               +','+                                     
               tempOrderItem.Order.MeterClass__c                                            +','+                                        
               tempOrderItem.Order.MaxRequiredPotential__c                                  +','+                                                  
               tempOrderItem.Order.MarketOrigin__c                                          +','+                                          
               tempOrderItem.Order.ImplantType__c                                           +','+                                         
               tempOrderItem.Order.ExciseGAS__c                                             +','+                                       
               tempOrderItem.Order.EffectiveDate                                            +','+                                        
               tempOrderItem.Order.DistributorCode__c                                       +','+                                             
               tempOrderItem.Order.DisconnectibilityType__c                                 +','+                                                   
               tempOrderItem.Order.Disconnectable__c                                        +','+                                            
               tempOrderItem.Order.CustomerName__c                                          +','+                                          
               tempOrderItem.Order.CustomerLastName__c                                      +','+                                              
               tempOrderItem.Order.CustomerFiscalCode__c                                    +','+                                                
               tempOrderItem.Order.CustomerCompanyName__c                                   +','+                                                 
               tempOrderItem.Order.createddate                                              +','+                                      
               tempOrderItem.Order.CreatedBy__c                                             +','+                                        
               tempOrderItem.Order.ContractId                                               +','+                                     
               tempOrderItem.Order.ConnectionMandate__c                                     +','+                                               
               tempOrderItem.Order.CommercialProductVersion__c                              +','+                                                      
               tempOrderItem.Order.CommercialAction__c                                      +','+                                              
               tempOrderItem.Order.CommentForDL__c                                          +','+                                          
               tempOrderItem.Order.Channel__c                                               +','+                                      
              //TODO verificare PaymentMode__c
               tempOrderItem.Order.BillingProfile__r.PaymentMethod__c                       +','+                                                            
               tempOrderItem.Order.BillingProfile__r.PaymentMethod__c                       +','+                                                             
               tempOrderItem.Order.BillingProfile__r.IbanCountry__c                         +','+                                                            
               tempOrderItem.Order.BillingProfile__r.IbanCodeNumber__c                      +','+                                                               
               tempOrderItem.Order.BillingProfile__r.IbanCIN_IBAN__c                        +','+                                                             
               tempOrderItem.Order.BillingProfile__r.IbanCIN__c                             +','+                                                        
               tempOrderItem.Order.BillingProfile__r.IbanCAB__c                             +','+                                                        
               tempOrderItem.Order.BillingProfile__r.IbanABI__c                             +','+                                                        
               tempOrderItem.Order.BillingProfile__r.BankName__c                            +','+                                                        
               tempOrderItem.Order.BillingProfile__r.BankAgency__c                          +','+                                                          
               tempOrderItem.Order.BillingProfile__r.BankAccountSignatoryLastName__c        +','+                                                                             
               tempOrderItem.Order.BillingProfile__r.BankAccountSignatoryFiscalCode__c      +','+                                                                               
               tempOrderItem.Order.BillingProfile__r.BankAccountSignatoryFirstName__c       +','+                                                                              
               tempOrderItem.Order.AtecoCode__c                                             +','+                                       
               tempOrderItem.Order.AnnualConsumption__c                                     +','+                                               
               tempOrderItem.Order.AggregateBilling__c                                      +','+                                              
               tempOrderItem.Order.Agency__c                                                +','+                                     
               tempOrderItem.Order.SalesContact__r.LastName                                 +','+                                                   
               tempOrderItem.Order.SalesContact__r.FirstName                                +','+                                                    
               tempOrderItem.order.Contact__r.MobilePhone                                   +','+                                            
               tempOrderItem.order.Contact__r.Email                                         +','+                                      
               tempOrderItem.order.Contact__r.Account.FAX__c                                +','+                                              
               tempOrderItem.order.Account.VATNumber__c                                     +';'+                                       
               tempOrderItem.order.ResidentialStreetNumber__c                               +','+                                                        
               tempOrderItem.order.ResidentialStreetName__c                                 +','+                                                      
               tempOrderItem.order.ResidentialState__c                                      +','+                                                 
               tempOrderItem.order.ResidentialPostalCode__c                                 +','+                                                      
               tempOrderItem.order.ResidentialPlace__c                                      +','+                                                 
               tempOrderItem.order.ResidentialCity__c                                       +','+                                                
               tempOrderItem.order.Account.LegalFormType__c                                 +','+                                             
               tempOrderItem.order.Account.FiscalCode__c                                    +','+                                                   
               tempOrderItem.order.CustomerCompanyName__c                                   +','+                                                    
               tempOrderItem.order.CustomerCompanyName__c                                   +','+                                                    
               tempOrderItem.order.Account.CustomerCode__c                                  +','+                                            
               tempOrderItem.order.Account.Category__c                                        ;      
                                                          
               row = row.replaceAll('null', '');  
                
                                                     
             
             if (String.isBlank(body)) {
                body=row;
             }
             else {
                body=body+'\n'+row; 
             }
          }
        contentVersionIds.add(HDT_UTL_ContentVersion.makeFile(header+body,'OUT_OP_GAS.txt','OUT_OP_GAS'));
        System.debug('contentVersionIds'+contentVersionIds);
        Id jobID = System.enqueueJob(new HDT_QBL_SIE34CallService(runId,status, fileType, errorMessage,contentVersionIds));

       } 
       catch (Exception e) {
          errorMessage=e.getMessage();
          status='failed';
          System.debug('contentVersionIds'+contentVersionIds);
          Id jobID2 = System.enqueueJob(new HDT_QBL_SIE34CallService(runId,status, fileType, errorMessage,new List<String>()));
          System.debug('jobId: '+jobID2);
       }
      
    }
  
 }
 