public with sharing class HDT_QBL_SIE34_3File2 implements Queueable  {
    private String runId                    ;   
    private Date filterDate                 ;
    private String fileType                 ;
    private String errorMessage             ;
    private List<String> contentVersionIds  ;

 
    public HDT_QBL_SIE34_3File2(String varRunId,Date varDate,String varFileType, List<String> varContentVersionIds ) {
       System.debug('Start HDT_QBL_SIE34_3File2');
       this.runId               = varRunId;
       this.filterDate          = varDate;
       this.fileType            = varFileType;
       this.contentVersionIds   = varContentVersionIds;
    }
 
 
    public void execute(QueueableContext context) {
       System.debug('HDT_QBL_SIE34_3File2.execute');
 
       String status     = 'success'            ;
       String condition  = ' WHERE Cluster__c IN (\'Disattivazioni\',\'Morosità\') AND Type=\'Interruzione Fornitura\' AND Status !=\'Closed\' AND LastModifiedDate >=:filterDate ';
       String query      = 'SELECT Account.BillingCity,Account.BillingPlace__c,Account.BillingPostalCode, Account.BillingState, Account.BillingStreetName__c,Account.BillingStreetNumber__c, Account.CustomerCode__c,Account.FirstName__c, Account.FiscalCode__c,Account.LastName__c, Account.VATNumber__c,CASE.CaseNumber, CausalCode__c,CommodityFormula__c,SalesCompany__c,CreatedBy.Name,Distributor__c,NotPerformedBefore__c,PhoneNumber__c,PODPDRFormula__c,ServicePoint__r.MeterType__c,ServicePoint__r.SupplyCity__c,ServicePoint__r.SupplyPlace__c,ServicePoint__r.SupplyPostalCode__c,ServicePoint__r.SupplyProvince__c,ServicePoint__r.SupplyStreetNumber__c,ServicePoint__r.SupplyStreet__c,SubProcess__c,VATPercentage__c,DeliveryAddress__c,Contract__c, BillingProfile__r.InvoicingAddressFormula__c,Subscription__r.SBQQ__ProductName__c FROM Case';
       
    
       try {
        
            String body  ='';
            String header='rag_sociale,nome,cognome,business_partner,pod,apparecchiatura,data_cessazione,cod_fiscale,p_iva,telefono,distributore,servizio,rds_creata_da,via,civico,suffisso,cap,localita,comune,provincia,codice_offerta,via_recapito,via_legale,civico_legale,suffisso_legale,cap_legale,localita_legale,comune_legale,provincia_legale,percentuale_iva,tipo_ordine,indirizzo_esteso_recapito,offerta_commerciale,decode,X_CODICE_CAUSALE';
            condition=' WHERE Cluster__c IN (\'Disattivazioni\',\'Morosità\') AND Type=\'Interruzione Fornitura\' AND Status !=\'Closed\' AND LastModifiedDate >=:filterDate ';
            query = 'SELECT CancellationReasonCode__c,ServicePoint__r.SupplyStreetNumberExtension__c,Account.BillingStreetNumberExtension__c,Account.BillingCity,Account.BillingPlace__c,Account.BillingPostalCode, Account.BillingState, Account.BillingStreetName__c,Account.BillingStreetNumber__c, Account.CustomerCode__c,Account.FirstName__c, Account.FiscalCode__c,Account.LastName__c, Account.VATNumber__c,CASE.CaseNumber, CausalCode__c,CommodityFormula__c,SalesCompany__c,CreatedBy.Name,Distributor__c,NotPerformedBefore__c,PhoneNumber__c,PODPDRFormula__c,ServicePoint__r.MeterType__c,ServicePoint__r.SupplyCity__c,ServicePoint__r.SupplyPlace__c,ServicePoint__r.SupplyPostalCode__c,ServicePoint__r.SupplyProvince__c,ServicePoint__r.SupplyStreetNumber__c,ServicePoint__r.SupplyStreet__c,SubProcess__c,VATPercentage__c,DeliveryAddress__c,Contract__c, BillingProfile__r.InvoicingAddressFormula__c,Subscription__r.SBQQ__ProductName__c FROM Case';
            List<Case> listCase2 = Database.query(query+condition);
            for (Case tempCase : listCase2) {
             String row = tempCase.Account.LastName__c                       +','+           
             tempCase.Account.FirstName__c                                   +','+            
             tempCase.Account.LastName__c                                    +','+           
             tempCase.Account.CustomerCode__c                                +','+               
             tempCase.PODPDRFormula__c                                       +','+        
             tempCase.ServicePoint__r.MeterType__c                           +','+                    
             tempCase.NotPerformedBefore__c                                  +','+             
             tempCase.Account.FiscalCode__c                                  +','+             
             tempCase.Account.VATNumber__c                                   +','+            
             tempCase.PhoneNumber__c                                         +','+      
             tempCase.Distributor__c                                         +','+      
             tempCase.CommodityFormula__c                                    +','+           
             tempCase.CreatedBy.Name                                         +','+      
             tempCase.ServicePoint__r.SupplyStreet__c                        +','+                       
             tempCase.ServicePoint__r.SupplyStreetNumber__c                  +','+                             
             tempCase.ServicePoint__r.SupplyStreetNumberExtension__c         +','+                                      
             tempCase.ServicePoint__r.SupplyPostalCode__c                    +','+                           
             tempCase.ServicePoint__r.SupplyPlace__c                         +','+                      
             tempCase.ServicePoint__r.SupplyCity__c                          +','+                     
             tempCase.ServicePoint__r.SupplyProvince__c                      +','+                         
             tempCase.CaseNumber                                             +','+  
             //tempCase.Account.DeliveryAddress__c                           +','+ 
             tempCase.DeliveryAddress__c                                     +','+                 
             tempCase.Account.BillingStreetName__c                           +','+                    
             tempCase.Account.BillingStreetNumber__c                         +','+                       
             tempCase.Account.BillingStreetNumberExtension__c                +','+                               
             tempCase.Account.BillingPostalCode                              +','+                  
             tempCase.Account.BillingPlace__c                                +','+               
             tempCase.Account.BillingCity                                    +','+            
             tempCase.Account.BillingState                                   +','+             
             tempCase.VATPercentage__c                                       +','+        
             tempCase.SubProcess__c                                          +','+     
             //tempCase.Account.DeliveryAddress__c                           +','+  
             tempCase.DeliveryAddress__c                                     +','+
             tempCase.Subscription__r.SBQQ__ProductName__c                   +','+                                           
             tempCase.SalesCompany__c                                        +','+               
             tempCase.CancellationReasonCode__c                                ; 
 
             if (String.isBlank(body)) {
                body=row;
             }
             else {
                body=body+'\n'+row; 
             }
       }
       contentVersionIds.add(HDT_UTL_ContentVersion.makeFile(header+body,'OUT_CESSAZIONE_FUORI_RETE.txt','OUT_CESSAZIONE_FUORI_RETE'));
 
       } 
       catch (Exception e) {
          errorMessage=e.getMessage();
          status='failed';
       }
       System.debug('contentVersionIds'+contentVersionIds);
       Id jobID = System.enqueueJob(new HDT_QBL_SIE34CallService(runId,status, fileType, errorMessage,contentVersionIds));
       System.debug('jobId: '+jobID);
    }
  
 }
 