public with sharing class HDT_QBL_SIE34_2MMEE implements Queueable  {
    private String runId                   ;   
    private Date filterDate                ;
    private String fileType                ;
    private List<String> contentVersionIds ;
    private final String NOTMAPPED=''      ;

 
 
    /**
    * @description 
    * @param varRunId 
    * @param varDate 
    * @param varFileType 
    * @param varContentVersionIds 
    **/
    
    public HDT_QBL_SIE34_2MMEE(String varRunId,Date varDate,String varFileType,List<String> varContentVersionIds) {
       this.runId             = varRunId                    ;
       this.filterDate        = varDate                     ;
       this.fileType          = varFileType                 ;
       this.contentVersionIds = varContentVersionIds        ;
    }
 
 
    public void execute(QueueableContext context) {
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
       String separator  = ';';

    
       try {
          
          List<Case> listCase = Database.query(query+condition);
          
         // String header='codice_offerta,numero_sr,data_richiesta,codice_cliente,rag_sociale + " " + Nome,p_iva,cod_fiscale,tel,fax,e-mail,nome legale rappresentante,cognome legale rappresentante ,indirizzo_sede_legale,civico_sede_legale,cap_sede_legale,comune_sede_legale,provincia_sede_legale,cognome_venditore,nome_venditore,canale,indirizzo_fornitura,civico_fornitura,cap_fornitura,comune_fornitura,provincia_fornitura,cod_istat_comune,indirizzo_spedizione,civico_spedizione,cap_spedizione,comune_spedizione,provincia_spedizione,tipologia_pagamento,pagamento,banca_denominazione,Agenzia Banca,Paese,CIN-IBAN,banca_cin,banca_abi,banca_cab,banca_cc,nome_sottoscritore_rid,cognome_sottoscritore_rid,cf_sottoscrittore_rid,pod,servizio,consumi_anno,Cod istat ateco,tipo_impianto,opzione,potenza_contrattuale,potenza_tecnica,tensione,cod_distributore,distributore,percentuale_iva,tipologia_imposta,suffisso_sede_legale,localita_sede_legale,suffisso_fornitura,localita_fornitura,suffisso_spedizione,localita_spedizione,INDIRIZZO CONTO CONTRATTUALE,RdS Creata Da,annotazioni,recapito telefonico,Disalimentazione,Categoria di disalimentazione,CATEGORIA CLIENTE,CELLULARE_CLIENTE,TELEGESTITO_PER_SDD,DATA_RICHIESTA_CLIENTE,IMPORTO_PREVENTIVO,CONFERMA_CLIENTE,CODICE_PREVENTIVO_DISTRIBUTORE,TIPO_CONNESSIONE,USO_ENERGIA,TIPO_CLIENTE,DISTANZA_SPOSTAMENTO,Data fine,MODALITA_INVIO_BOLLETTA,EMAIL_INVIO_BOLLETTA,NOME CLIENTE,COD CONTATTO DEST DIVERGENTE,COGNOME/RAG SOC DEST DIVERGENTE,NOME DEST DIVERGENTE,CF DEST DIVERGENTE,VIA DEST DIVERGENTE,NUM CIVICO DEST DIVERGENTE,CAP DEST DIVERGENTE,COMUNE DEST DIVERGENTE,PROVINCIA DEST DIVERGENTE,EMAIL_INVIO_BOLLETTA_PEC,DATA_CONSENSO_PEC,TIPO_FORNITURA,TIPO_MERCATO,TIPO_OPERAZIONE,TIPO_PREVENTIVO,Codice Causale \n';
         
         
         
          String body  ='';
      
          for (Case tempCase : listCase) {   
               String name=String.isNotBlank(tempCase.FirstName__c)?' '+tempCase.FirstName__c:'';
               String row = 
             
               tempCase.CaseNumber                                                                +separator+                                               
               tempCase.CaseNumber                                                                +separator+                                               
               tempCase.CreatedDate                                                               +separator+                                                
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                                             
               tempCase.Account.CustomerCode__c                                                   +separator+                                                            
               tempCase.Account.LastName__c + name                                                +separator+                                                               
               tempCase.Account.VATNumber__c                                                      +separator+                                                         
               tempCase.Account.FiscalCode__c                                                     +separator+                                                          
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               tempCase.Contact.MobilePhone                                                       +separator+                                                           
               tempCase.Contact.FAX                                                               +separator+                                                   
               tempCase.Contact.Email                                                             +separator+                                                            
               tempCase.Contact.FirstName                                                         +separator+                                                      
               tempCase.Contact.LastName                                                          +separator+                                                     
               tempCase.Account.BillingStreetName__c                                              +separator+                                                                 
               tempCase.Account.BillingStreetNumber__c                                            +separator+                                                                    
               tempCase.Account.BillingPostalCode                                                 +separator+                                                               
               tempCase.Account.BillingCity                                                       +separator+                                                         
               tempCase.Account.BillingState                                                      +separator+                                                          
               tempCase.FirstName__c                                                              +separator+                                              
               tempCase.LastName__c                                                               +separator+                                             
               NOTMAPPED                                                                          +separator+                                     
               tempCase.ComplaintEntryChannel__c                                                  +separator+                                                             
               NOTMAPPED                                                                          +separator+                                     
               tempCase.ServicePoint__r.SupplyStreet__c                                           +separator+                                                                    
               tempCase.ServicePoint__r.SupplyStreetNumber__c                                     +separator+                                                                          
               tempCase.ServicePoint__r.SupplyPostalCode__c                                       +separator+                                                                        
               tempCase.ServicePoint__r.SupplyCity__c                                             +separator+                                                                  
               tempCase.ServicePoint__r.SupplyProvince__c                                         +separator+                                                                      
               tempCase.ServicePoint__r.SupplyCityCode__c                                         +separator+                                                                      
               tempCase.BillingProfile__r.InvoicingStreetName__c                                  +separator+                                                                             
               tempCase.BillingProfile__r.InvoicingStreetNumber__c                                +separator+                                                                               
               tempCase.BillingProfile__r.InvoicingPostalCode__c                                  +separator+                                                                             
               tempCase.BillingProfile__r.InvoicingCity__c                                        +separator+                                                                       
               tempCase.BillingProfile__r.InvoicingProvince__c                                    +separator+                                                                           
               tempCase.BillingProfile__r.PaymentMethod__c                                        +separator+                                                                       
               tempCase.BillingProfile__r.PaymentMethod__c                                        +separator+                                                                       
               tempCase.BillingProfile__r.BankName__c                                             +separator+                                                                  
               tempCase.BillingProfile__r.BankAgency__c                                           +separator+                                                                    
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               tempCase.BillingProfile__r.IbanCountry__c                                          +separator+                                                                     
               tempCase.BillingProfile__r.IbanCIN_IBAN__c                                         +separator+                                                                      
               tempCase.BillingProfile__r.IbanCIN__c                                              +separator+                                                                 
               tempCase.BillingProfile__r.IbanABI__c                                              +separator+                                                                 
               tempCase.BillingProfile__r.IbanCAB__c                                              +separator+                                                                 
               tempCase.BillingProfile__r.IbanCodeNumber__c                                       +separator+                                                                        
               tempCase.BillingProfile__r.BankAccountSignatoryFirstName__c                        +separator+                                                                                       
               tempCase.BillingProfile__r.BankAccountSignatoryLastName__c                         +separator+                                                                                      
               tempCase.BillingProfile__r.BankAccountSignatoryFiscalCode__c                       +separator+                                                                                        
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               tempCase.PODPDRFormula__c                                                          +separator+                                                     
               tempCase.CommodityFormula__c                                                       +separator+                                                        
               NOTMAPPED                                                                          +separator+                                     
               tempCase.AnnualConsumption__c                                                      +separator+                                                         
               NOTMAPPED                                                                          +separator+                                     
               tempCase.AtecoCode__c                                                              +separator+                                                 
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               tempCase.ServicePointType__c                                                       +separator+                                                        
               tempCase.TensionOption__c                                                          +separator+                                                     
               tempCase.PowerContractualFormula__c                                                +separator+                                                               
               tempCase.Power__c                                                                  +separator+                                             
               tempCase.Voltage__c                                                                +separator+                                               
               NOTMAPPED                                                                          +separator+                                     
               tempCase.DistributorCode__c                                                        +separator+                                                       
               tempCase.Distributor__c                                                            +separator+                                                   
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               tempCase.VATPercentage__c                                                          +separator+                                                     
               tempCase.Taxes__c                                                                  +separator+                                             
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               tempCase.Account.BillingStreetNumberExtension__c                                   +separator+                                                                            
               tempCase.Account.BillingPlace__c                                                   +separator+                                                            
               tempCase.ServicePoint__r.SupplyStreetNumberExtension__c                            +separator+                                                                                   
               tempCase.ServicePoint__r.SupplyPlace__c                                            +separator+                                                                   
               tempCase.BillingProfile__r.InvoicingStreetNumberExtension__c                       +separator+                                                                                        
               tempCase.BillingProfile__r.InvoicingPlace__c                                       +separator+                                                                        
               tempCase.BillingProfile__r.InvoicingAddressFormula__c                              +separator+                                                                                 
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               tempCase.CreatedBy.Name                                                            +separator+                                                   
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               tempCase.DistributorNote__c                                                        +separator+                                                       
               tempCase.PhoneNumber__c                                                            +separator+                                                   
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               tempCase.Disconnectable__c                                                         +separator+                                                      
               tempCase.DisconnectibilityType__c                                                  +separator+                                                             
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               tempCase.Account.Category__c                                                       +separator+                                                        
               tempCase.Mobile__c                                                                 +separator+                                              
               tempCase.RemoteManagementSystem__c                                                 +separator+                                                              
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               tempCase.CustomerRequestDate__c                                                    +separator+                                                           
               tempCase.Amount__c                                                                 +separator+                                              
               tempCase.Phase__c                                                                  +separator+                                                                       
               tempCase.QuotationNumber__c                                                        +separator+                                                       
               tempCase.ConnectionType__c                                                         +separator+                                                      
               tempCase.UseTypeEnergy__c                                                          +separator+                                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               tempCase.Account.CustomerType__c                                                   +separator+                                                            
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               tempCase.DisplacementDistance__c                                                   +separator+                                                            
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               tempCase.EndDate__c                                                                +separator+                                               
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               tempCase.BillingProfile__r.BillSendingMethod__c                                    +separator+                                                                           
               tempCase.BillingProfile__r.InvoiceEmailAddress__c                                  +separator+                                                                             
               tempCase.Account.FirstName__c                                                      +separator+                                                      
               tempCase.BillingProfile__r.ContractAccountCode__c                                  +separator+                                                                     
               tempCase.BillingProfile__r.BankAccountSignatoryLastName__c                         +separator+                                                               
               tempCase.BillingProfile__r.BankAccountSignatoryFirstName__c                        +separator+                                                                
               tempCase.BillingProfile__r.BankAccountSignatoryFiscalCode__c                       +separator+                                                                    
               tempCase.BillingProfile__r.InvoicingStreetName__c                                  +separator+                                                                            
               tempCase.BillingProfile__r.InvoicingStreetNumber__c                                +separator+                                                                             
               NOTMAPPED                                                                          +separator+                                                        
               tempCase.BillingProfile__r.InvoicingPostalCode__c                                  +separator+                                                                        
               tempCase.BillingProfile__r.InvoicingCity__c                                        +separator+                                                                   
               tempCase.BillingProfile__r.InvoicingProvince__c                                    +separator+                                                                    
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               tempCase.BillingProfile__r.InvoiceCertifiedEmailAddress__c                         +separator+                                                                                      
               tempCase.BillingProfile__r.SendCertifiedEmailConsentDate__c                        +separator+                                                                                       
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               tempCase.SupplyType__c                                                             +separator+                                                  
               tempCase.Market__c                                                                 +separator+                                              
               tempCase.OperationCode__c                                                          +separator+                                                     
               tempCase.QuotationType__c                                                          +separator+                                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               tempCase.CausalCode__c                                                             +separator+                                                  
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          +separator+                                     
               NOTMAPPED                                                                          ;    
               row = row.replaceAll('null', '');                                       
             
             if (String.isBlank(body)) {
                body=row;
             }
             else {
                body=body+'\n'+row; 
             }
          }
         if (listCase!=null && listCase.size()>0) {
            contentVersionIds.add(HDT_UTL_ContentVersion.makeFile(body,'PP(EE)OUT_PREVENTIVI_MM.txt','PP(EE)OUT_PREVENTIVI_MM'));
         }
         Id jobID2File = System.enqueueJob(new HDT_QBL_SIE34_2MMGas(runId,filterDate, fileType,contentVersionIds));
       } 
       catch (Exception e) {
          errorMessage=e.getMessage();
          status='failed';
          Id jobID = System.enqueueJob(new HDT_QBL_SIE34CallService(runId,status, fileType, errorMessage,new List<String>()));
       }
      
    }
  
 }
 