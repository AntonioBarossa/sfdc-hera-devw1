public with sharing class HDT_QBL_SIE34_2SMEGas implements Queueable  {
    private String runId                   ;   
    private Date filterDate                ;
    private String fileType                ;
    private List<String> contentVersionIds ;
 
 
    public HDT_QBL_SIE34_2SMEGas(String varRunId,Date varDate,String varFileType,List<String> varContentVersionIds) {
       System.debug('Start HDT_QBL_SIE34_2SMEGas')          ;
       this.runId             = varRunId                    ;
       this.filterDate        = varDate                     ;
       this.fileType          = varFileType                 ;
       this.contentVersionIds = varContentVersionIds        ;
    }
 
 
    public void execute(QueueableContext context) {
       System.debug('HDT_QBL_SIE34_2SMEGas.execute')   ;
       String status                  = 'success'      ;
       String errorMessage            = ''             ;
       String condition = ' WHERE Cluster__c =\'Preventivi\' AND Status =\'Closed\' AND LastModifiedDate >=:filterDate ';
       String query     = 'SELECT Contract__r.ContractSalesCompany__c,BillingProfile__r.InvoicingCountry__c,BillingProfile__r.ContractAccountCode__c,Contact.Email,Account.LastName__c,Account.BillingCity,Account.BillingPlace__c, Account.BillingPostalCode,Account.BillingState,Account.BillingStreetName__c,Account.BillingStreetNumberExtension__c, Account.BillingStreetNumber__c, Account.Category__c, Account.CustomerCode__c,'+
       'Account.CustomerType__c,Account.FirstName__c, Account.FiscalCode__c,Account.VATNumber__c,BillingProfile__r.BillSendingMethod__c, BillingProfile__r.InvoiceCertifiedEmailAddress__c,BillingProfile__r.InvoiceEmailAddress__c, BillingProfile__r.SendCertifiedEmailConsentDate__c,'+
       'BillingProfile__r.BankAccountSignatoryFirstName__c,BillingProfile__r.BankAccountSignatoryFiscalCode__c,BillingProfile__r.BankAccountSignatoryLastName__c,BillingProfile__r.BankAgency__c,BillingProfile__r.BankName__c,BillingProfile__r.IbanABI__c,BillingProfile__r.IbanCAB__c,'+
       'BillingProfile__r.IbanCIN_IBAN__c,BillingProfile__r.IbanCIN__c,BillingProfile__r.IbanCodeNumber__c,BillingProfile__r.IbanCountry__c,BillingProfile__r.InvoicingAddressFormula__c, BillingProfile__r.InvoicingCity__c,'+
       'BillingProfile__r.InvoicingPlace__c,BillingProfile__r.InvoicingPostalCode__c,BillingProfile__r.InvoicingProvince__c,BillingProfile__r.InvoicingStreetName__c,BillingProfile__r.InvoicingStreetNumberExtension__c,'+
       'BillingProfile__r.InvoicingStreetNumber__c, BillingProfile__r.PaymentMethod__c,SubProcess__c, Amount__c,AnnualConsumption__c, AtecoCode__c, CaseNumber,CausalCode__c,CommodityFormula__c,ComplaintEntryChannel__c,'+
       'ConnectionType__c,CreatedBy.Name,CreatedDate,CustomerRequestDate__c,Disconnectable__c,DisconnectibilityType__c,DisplacementDistance__c,DistributorCode__c,DistributorNote__c,Distributor__c,EndDate__c,FirstName__c,'+
       'LastName__c,Market__c,Mobile__c,OperationCode__c,PODPDRFormula__c,Phase__c,PhoneNumber__c,PowerContractualFormula__c,Power__c,QuotationNumber__c,QuotationType__c,RemoteManagementSystem__c,ServicePointType__c,'+
       'SupplyType__c,Taxes__c,TensionOption__c,UseTypeEnergy__c,VATPercentage__c,Voltage__c,Contact.FAX,Contact.FirstName,Contact.LastName,Contact.MobilePhone,ServicePoint__r.SupplyCityCode__c,ServicePoint__r.SupplyCity__c,'+
       'ServicePoint__r.SupplyPlace__c,ServicePoint__r.SupplyPostalCode__c,ServicePoint__r.SupplyProvince__c,ServicePoint__r.SupplyStreetNumberExtension__c,ServicePoint__r.SupplyStreetNumber__c,ServicePoint__r.SupplyStreet__c'+
       ' FROM Case ';
    
    
       try {
          
          System.debug('query: '+query+condition);
          List<Case> listCase = Database.query(query+condition);
          
          String header='codice_offerta,numero_sr,data_richiesta,tipo ordine,codice_cliente,rag_sociale + " " + Nome,p_iva,cod_fiscale,tel,fax,e-mail,nome legale rappresentante,cognome legale rappresentante,indirizzo_sede_legale,civico_sede_legale,cap_sede_legale,comune_sede_legale,provincia_sede_legale,cognome_venditore,nome_venditore,canale,indirizzo_fornitura,civico_fornitura,cap_fornitura,comune_fornitura,provincia_fornitura,cod_istat_comune,indirizzo_spedizione,civico_spedizione,cap_spedizione,comune_spedizione,provincia_spedizione,tipologia_pagamento,pagamento,banca_denominazione,Agenzia Banca,Paese,CIN-IBAN,banca_cin,banca_abi,banca_cab,banca_cc,nome_sottoscritore_rid,cognome_sottoscritore_rid,cf_sottoscrittore_rid,pod,servizio,consumi_anno,Cod istat ateco,cod_distributore,distributore,percentuale_iva,tipologia_imposta,suffisso_sede_legale,localita_sede_legale,suffisso_fornitura,localita_fornitura,suffisso_spedizione,localita_spedizione,INDIRIZZO CONTO CONTRATTUALE,RdS Creata Da,annotazioni,recapito telefonico,Disalimentazione,Categoria di disalimentazione,CATEGORIA CLIENTE,CELLULARE_CLIENTE,TIPO_CLIENTE,DISTANZA_SPOSTAMENTO,CONFERMA_CLIENTE,CODICE_PREVENTIVO_DISTRIBUTORE,Data fine,IMPORTO_PREVENTIVO,MODALITA_INVIO_BOLLETTA,EMAIL_INVIO_BOLLETTA,NOME CLIENTE,COD CONTATTO DEST DIVERGENTE,COGNOME/RAG SOC DEST DIVERGENTE,NOME DEST DIVERGENTE,CF DEST DIVERGENTE,VIA DEST DIVERGENTE,NUM CIVICO DEST DIVERGENTE,CAP DEST DIVERGENTE,COMUNE DEST DIVERGENTE,PROVINCIA DEST DIVERGENTE,EMAIL_INVIO_BOLLETTA_PEC,DATA_CONSENSO_PEC,TIPO_FORNITURA,TIPO_MERCATO,TIPO_OPERAZIONE,TIPO_PREVENTIVO,SOCIETA_VENDITA,Codice Causale \n';
         
         
         
          String body  ='';
      
          for (Case tempCase : listCase) {
               String name=String.isNotBlank(tempCase.FirstName__c)? ' ' +tempCase.FirstName__c:'';

                String row = 
                tempCase.CaseNumber                                                              +','+       
                tempCase.CaseNumber                                                              +','+                                          
                tempCase.CaseNumber                                                              +','+                                   
                tempCase.CreatedDate                                                             +','+                                    
                tempCase.SubProcess__c                                                           +','+                                      
                tempCase.Account.CustomerCode__c                                                 +','+                                                
                tempCase.Account.LastName__c + name                                              +','+                                                                 
                tempCase.Account.VATNumber__c                                                    +','+                                             
                tempCase.Account.FiscalCode__c                                                   +','+                                              
                tempCase.Contact.MobilePhone                                                     +','+                                               
                tempCase.Contact.Fax                                                             +','+                                       
                tempCase.Contact.Email                                                           +','+                                                
                tempCase.Contact.FirstName                                                       +','+                                          
                tempCase.Contact.LastName                                                        +','+                                         
                tempCase.Account.BillingStreetName__c                                            +','+                                                     
                tempCase.Account.BillingStreetNumber__c                                          +','+                                                        
                tempCase.Account.BillingPostalCode                                               +','+                                                   
                tempCase.Account.BillingCity                                                     +','+                                             
                tempCase.Account.BillingState                                                    +','+                                              
                tempCase.FirstName__c                                                            +','+                                  
                tempCase.LastName__c                                                             +','+                                 
                tempCase.ComplaintEntryChannel__c                                                +','+                                                 
                tempCase.ServicePoint__r.SupplyStreet__c                                         +','+                                                        
                tempCase.ServicePoint__r.SupplyStreetNumber__c                                   +','+                                                              
                tempCase.ServicePoint__r.SupplyPostalCode__c                                     +','+                                                            
                tempCase.ServicePoint__r.SupplyCity__c                                           +','+                                                      
                tempCase.ServicePoint__r.SupplyProvince__c                                       +','+                                                          
                tempCase.ServicePoint__r.SupplyCityCode__c                                       +','+                                                          
                tempCase.BillingProfile__r.InvoicingStreetName__c                                +','+                                                               
                tempCase.BillingProfile__r.InvoicingStreetNumber__c                              +','+                                                                 
                tempCase.BillingProfile__r.InvoicingPostalCode__c                                +','+                                                               
                tempCase.BillingProfile__r.InvoicingCity__c                                      +','+                                                         
                tempCase.BillingProfile__r.InvoicingProvince__c                                  +','+                                                             
                tempCase.BillingProfile__r.PaymentMethod__c                                      +','+                                                         
                tempCase.BillingProfile__r.PaymentMethod__c                                      +','+                                                         
                tempCase.BillingProfile__r.BankName__c                                           +','+                                                    
                tempCase.BillingProfile__r.BankAgency__c                                         +','+                                                      
                tempCase.BillingProfile__r.IbanCountry__c                                        +','+                                                       
                tempCase.BillingProfile__r.IbanCIN_IBAN__c                                       +','+                                                        
                tempCase.BillingProfile__r.IbanCIN__c                                            +','+                                                   
                tempCase.BillingProfile__r.IbanABI__c                                            +','+                                                   
                tempCase.BillingProfile__r.IbanCAB__c                                            +','+                                                   
                tempCase.BillingProfile__r.IbanCodeNumber__c                                     +','+                                                          
                tempCase.BillingProfile__r.BankAccountSignatoryFirstName__c                      +','+                                                                         
                tempCase.BillingProfile__r.BankAccountSignatoryLastName__c                       +','+                                                                        
                tempCase.BillingProfile__r.BankAccountSignatoryFiscalCode__c                     +','+                                                                          
                tempCase.PODPDRFormula__c                                                        +','+                                         
                tempCase.CommodityFormula__c                                                     +','+                                            
                tempCase.AnnualConsumption__c                                                    +','+                                             
                tempCase.AtecoCode__c                                                            +','+                                     
                tempCase.DistributorCode__c                                                      +','+                                           
                tempCase.Distributor__c                                                          +','+                                       
                tempCase.VATPercentage__c                                                        +','+                                         
                tempCase.Taxes__c                                                                +','+                                 
                tempCase.Account.BillingStreetNumberExtension__c                                 +','+                                                                
                tempCase.Account.BillingPlace__c                                                 +','+                                                
                tempCase.ServicePoint__r.SupplyStreetNumberExtension__c                          +','+                                                                       
                tempCase.ServicePoint__r.SupplyPlace__c                                          +','+                                                       
                tempCase.BillingProfile__r.InvoicingStreetNumberExtension__c                     +','+                                                                          
                tempCase.BillingProfile__r.InvoicingPlace__c                                     +','+                                                          
                tempCase.BillingProfile__r.InvoicingAddressFormula__c                            +','+                                                                   
                tempCase.CreatedBy.Name                                                          +','+                                       
                tempCase.DistributorNote__c                                                      +','+                                           
                tempCase.PhoneNumber__c                                                          +','+                                       
                tempCase.Disconnectable__c                                                       +','+                                          
                tempCase.DisconnectibilityType__c                                                +','+                                                 
                tempCase.Account.Category__c                                                     +','+                                            
                tempCase.Mobile__c                                                               +','+                                  
                tempCase.Account.CustomerType__c                                                 +','+                                                
                tempCase.DisplacementDistance__c                                                 +','+                                                
                tempCase.Phase__c                                                                +','+                                 
                tempCase.QuotationNumber__c                                                      +','+                                           
                tempCase.EndDate__c                                                              +','+                                   
                tempCase.Amount__c                                                               +','+                                  
                tempCase.BillingProfile__r.BillSendingMethod__c                                  +','+                                                             
                tempCase.BillingProfile__r.InvoiceEmailAddress__c                                +','+                                                               
                tempCase.Account.FirstName__c                                                    +','+                                          
                tempCase.BillingProfile__r.ContractAccountCode__c                                +','+                                                       
                tempCase.BillingProfile__r.BankAccountSignatoryLastName__c                       +','+                                                 
                tempCase.BillingProfile__r.BankAccountSignatoryFirstName__c                      +','+                                                  
                tempCase.BillingProfile__r.BankAccountSignatoryFiscalCode__c                     +','+                                                      
                tempCase.BillingProfile__r.InvoicingStreetName__c                                +','+                                                              
                tempCase.BillingProfile__r.InvoicingStreetNumber__c                              +','+                                                               
                tempCase.BillingProfile__r.InvoicingPostalCode__c                                +','+                                                          
                tempCase.BillingProfile__r.InvoicingCity__c                                      +','+                                                     
                tempCase.BillingProfile__r.InvoicingProvince__c                                  +','+                                                      
                tempCase.BillingProfile__r.InvoiceCertifiedEmailAddress__c                       +','+                                                                        
                tempCase.BillingProfile__r.SendCertifiedEmailConsentDate__c                      +','+                                                                         
                tempCase.SupplyType__c                                                           +','+                                      
                tempCase.Market__c                                                               +','+                                  
                tempCase.OperationCode__c                                                        +','+                                         
                tempCase.QuotationType__c                                                        +','+                                         
                tempCase.Contract__r.ContractSalesCompany__c                                     +','+                                                
                tempCase.CausalCode__c                                                             ;        
                                                     
             
             if (String.isBlank(body)) {
                body=row;
             }
             else {
                body=body+'\n'+row; 
             }
          }
         contentVersionIds.add(HDT_UTL_ContentVersion.makeFile(header+body,'PP(GAS)OUT_PREVENTIVI_SME.txt','PP(GAS)OUT_PREVENTIVI_SME'));
         System.debug('contentVersionIds'+contentVersionIds);
         Id jobID2File = System.enqueueJob(new HDT_QBL_SIE34_2MMEE(runId,filterDate, fileType,contentVersionIds));
       } 
       catch (Exception e) {
          errorMessage=e.getMessage();
          status='failed';
          System.debug('contentVersionIds'+contentVersionIds);
          Id jobID = System.enqueueJob(new HDT_QBL_SIE34CallService(runId,status, fileType, errorMessage,new List<String>()));
          System.debug('jobId: '+jobID);
       }
      
    }
  
 }
 