public with sharing class HDT_QBL_SIE34_3 implements Queueable  {
   private String runId;   
   private Date filterDate;

   public HDT_QBL_SIE34_3(String varRunId,Date varDate) {
      System.debug('Start HDT_QBL_SIE34_3');
      this.runId=varRunId;
      this.filterDate=varDate;
   }


   public void execute(QueueableContext context) {
      System.debug('HDT_QBL_SIE34_3.execute');
      String condition=' WHERE Cluster__c IN (\'Disattivazioni\',\'Morosità\') AND Type=\'Interruzione Fornitura\' AND Status !=\'Closed\' AND LastModifiedDate >=:filterDate ';
      String query = 'SELECT Account.BillingCity,Account.BillingPlace__c,Account.BillingPostalCode, Account.BillingState, Account.BillingStreetName__c,Account.BillingStreetNumber__c, Account.CustomerCode__c,Account.FirstName__c, Account.FiscalCode__c,Account.LastName__c, Account.VATNumber__c,CASE.CaseNumber, CausalCode__c,CommodityFormula__c,SalesCompany__c,CreatedBy.Name,Distributor__c,NotPerformedBefore__c,PhoneNumber__c,PODPDRFormula__c,ServicePoint__r.MeterType__c,ServicePoint__r.SupplyCity__c,ServicePoint__r.SupplyPlace__c,ServicePoint__r.SupplyPostalCode__c,ServicePoint__r.SupplyProvince__c,ServicePoint__r.SupplyStreetNumber__c,ServicePoint__r.SupplyStreet__c,SubProcess__c,VATPercentage__c,DeliveryAddress__c,Contract__c, BillingProfile__r.InvoicingAddressFormula__c,via_recapito,Subscription__r.SBQQ__ProductName__c FROM Case';
      try {
         
    
         List<Case> listCase = Database.query(query+condition);
         
         String header='rag_sociale,nome,cognome,business_partner,pod,apparecchiatura,data_cessazione,cod_fiscale,p_iva,via,civico,cap,localita,comune,provincia,codice_offerta,via_legale,civico_legale,cap_legale,localita_legale,comune_legale,provincia_legale,percentuale_iva,tipo_ordine,decode,X_CODICE_CAUSALE,telefono,distributore,servizio,rds_creata_da,indirizzo_esteso_recapito,offerta_commerciale    \n';
         String body  ='';
         
         for (Case tempCase : listCase) {
            String row = tempCase.Account.LastName__c     +','+
            tempCase.Account.FirstName__c                 +','+
            tempCase.Account.LastName__c                  +','+
            tempCase.Account.CustomerCode__c              +','+
            tempCase.PODPDRFormula__c                     +','+
            tempCase.ServicePoint__r.MeterType__c         +','+
            tempCase.NotPerformedBefore__c                +','+
            tempCase.Account.FiscalCode__c                +','+
            tempCase.Account.VATNumber__c                 +','+
            tempCase.ServicePoint__r.SupplyStreet__c      +','+
            tempCase.ServicePoint__r.SupplyStreetNumber__c+','+
            tempCase.ServicePoint__r.SupplyPostalCode__c  +','+
            tempCase.ServicePoint__r.SupplyPlace__c       +','+
            tempCase.ServicePoint__r.SupplyCity__c        +','+
            tempCase.ServicePoint__r.SupplyProvince__c    +','+
            tempCase.CaseNumber                           +','+
            tempCase.Account.BillingStreetName__c         +','+
            tempCase.Account.BillingStreetNumber__c       +','+
            tempCase.Account.BillingPostalCode            +','+
            tempCase.Account.BillingPlace__c              +','+
            tempCase.Account.BillingCity                  +','+
            tempCase.Account.BillingState                 +','+
            tempCase.VATPercentage__c                     +','+
            tempCase.SubProcess__c                        +','+		
            //tempCase.ContractSalesCompany__c              +','+		
            tempCase.CausalCode__c                        +','+		
            tempCase.PhoneNumber__c                       +','+		
            tempCase.Distributor__c                       +','+		
            tempCase.CommodityFormula__c                  +','+		
            tempCase.CreatedBy.Name	                      +','+	
            tempCase.DeliveryAddress__c                   +','+
            tempCase.DeliveryAddress__c                   +','+		
            tempCase.Subscription__r.SBQQ__ProductName__c;
            if (String.isBlank(body)) {
               body=row;
            }
            else {
               body='\n'+row; 
            }
         }

         HDT_UTL_ContentVersion.makeFile(header+body,'OUT_CESSAZIONE_IN_RETE.txt','OUT_CESSAZIONE_IN_RETE');
      } 
      catch (Exception e) {
         System.debug('errore :'+e.getMessage());
      }
   }
 
}
