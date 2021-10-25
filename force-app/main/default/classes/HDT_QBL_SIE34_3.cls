/**
 * @description       : 
 * @last modified on  : 30-09-2021
**/
public with sharing class HDT_QBL_SIE34_3 implements Queueable  {
   private String runId                   ;   
   private Datetime filterDate            ;
   private String fileType                ;
   private List<String> contentVersionIds ;
   private final String NOTMAPPED='';



   /**
   * @description :  
   * @param varRunId 
   * @param varDate 
   * @param varFileType 
   **/
   public HDT_QBL_SIE34_3(String varRunId,String varDate,String varFileType) {
      this.runId             = varRunId                                           ;
      this.filterDate        = HDT_UTL_LeadProcess.getDateTimeFromString(varDate) ;
      this.fileType          = varFileType                                        ;
      this.contentVersionIds = new List<String>()                                 ;
   }


   /**
   * @description 
   * @param context 
   **/
   public void execute(QueueableContext context) {
      String status                  = 'success'   ;
      String errorMessage            = ''          ;

      String condition = ' WHERE Cluster__c IN (\'Disattivazioni\',\'Morosità\') AND Type=\'Interruzione Fornitura\' AND Status !=\'Closed\' AND LastModifiedDate >=:filterDate ';
      String query     = 'SELECT Contract__r.ContractSalesCompany__c,Account.BillingCity,Account.BillingPlace__c,Account.BillingPostalCode, Account.BillingState, Account.BillingStreetName__c,Account.BillingStreetNumber__c, Account.CustomerCode__c,Account.FirstName__c, Account.FiscalCode__c,Account.LastName__c, Account.VATNumber__c,CASE.CaseNumber, CausalCode__c,CommodityFormula__c,SalesCompany__c,CreatedBy.Name,Distributor__c,NotPerformedBefore__c,PhoneNumber__c,PODPDRFormula__c,ServicePoint__r.MeterType__c,ServicePoint__r.SupplyCity__c,ServicePoint__r.SupplyPlace__c,ServicePoint__r.SupplyPostalCode__c,ServicePoint__r.SupplyProvince__c,ServicePoint__r.SupplyStreetNumber__c,ServicePoint__r.SupplyStreet__c,SubProcess__c,VATPercentage__c,DeliveryAddress__c,Contract__c, BillingProfile__r.InvoicingAddressFormula__c,Subscription__r.SBQQ__ProductName__c FROM Case';
      String separator = ';';

   
      try {
         
    
         List<Case> listCase = Database.query(query+condition);
         
        // String header='rag_sociale,nome,cognome,business_partner,pod,apparecchiatura,data_cessazione,cod_fiscale,p_iva,via,civico,cap,localita,comune,provincia,codice_offerta,via_legale,civico_legale,cap_legale,localita_legale,comune_legale,provincia_legale,percentuale_iva,tipo_ordine,decode,X_CODICE_CAUSALE,telefono,distributore,servizio,rds_creata_da,indirizzo_esteso_recapito,via_recapito,offerta_commerciale    \n';
         String body  ='';
         for (Case tempCase : listCase) {
            String row =
            tempCase.Account.LastName__c                                                        +separator+                                              
            tempCase.Account.FirstName__c                                                       +separator+                                               
            tempCase.Account.LastName__c                                                        +separator+                                              
            tempCase.Account.CustomerCode__c                                                    +separator+                                                  
            tempCase.PODPDRFormula__c                                                           +separator+                                                
            NOTMAPPED                                                                           +separator+                                      
            tempCase.ServicePoint__r.MeterType__c                                               +separator+                                                       
            tempCase.NotPerformedBefore__c                                                      +separator+                                                     
            tempCase.Account.FiscalCode__c                                                      +separator+                                                
            tempCase.Account.VATNumber__c                                                       +separator+                                               
            tempCase.PhoneNumber__c                                                             +separator+                                              
            tempCase.Distributor__c                                                             +separator+                                              
            tempCase.CommodityFormula__c                                                        +separator+                                                   
            tempCase.CreatedBy.Name                                                             +separator+                                              
            tempCase.ServicePoint__r.SupplyStreet__c                                            +separator+                                                          
            tempCase.ServicePoint__r.SupplyStreetNumber__c                                      +separator+                                                                
            NOTMAPPED                                                                           +separator+                                      
            tempCase.ServicePoint__r.SupplyPostalCode__c                                        +separator+                                                              
            tempCase.ServicePoint__r.SupplyPlace__c                                             +separator+                                                         
            tempCase.ServicePoint__r.SupplyCity__c                                              +separator+                                                        
            tempCase.ServicePoint__r.SupplyProvince__c                                          +separator+                                                            
            tempCase.CaseNumber                                                                 +separator+                                          
            tempCase.DeliveryAddress__c                                                         +separator+                                                                                   
            NOTMAPPED                                                                           +separator+                                      
            NOTMAPPED                                                                           +separator+                                      
            NOTMAPPED                                                                           +separator+                                      
            NOTMAPPED                                                                           +separator+                                      
            NOTMAPPED                                                                           +separator+                                      
            NOTMAPPED                                                                           +separator+                                      
            tempCase.Account.BillingStreetName__c                                               +separator+                                                       
            tempCase.Account.BillingStreetNumber__c                                             +separator+                                                          
            NOTMAPPED                                                                           +separator+                                      
            tempCase.Account.BillingPostalCode                                                  +separator+                                                     
            tempCase.Account.BillingPlace__c                                                    +separator+                                                  
            tempCase.Account.BillingCity                                                        +separator+                                               
            tempCase.Account.BillingState                                                       +separator+                                                
            tempCase.VATPercentage__c                                                           +separator+                                                
            tempCase.SubProcess__c                                                              +separator+                                             
            NOTMAPPED                                                                           +separator+                                        
            tempCase.DeliveryAddress__c                                                         +separator+                                                                                   
            NOTMAPPED                                                                           +separator+                                        
            tempCase.Subscription__r.SBQQ__ProductName__c                                       +separator+
            tempCase.Contract__r.ContractSalesCompany__c                                        +separator+                                                    
            tempCase.CausalCode__c                                                                 ;


            row = row.replaceAll('null', '');  
            if (String.isBlank(body)) {
               body=row;
            }
            else {
               body=body+'\n'+row; 
            }
         }
         if (listCase!=null && listCase.size()>0 ) {
            contentVersionIds.add(HDT_UTL_ContentVersion.makeFile(body,'OUT_CESSAZIONE_IN_RETE.txt','OUT_CESSAZIONE_IN_RETE'));
         }
         if( !Test.isRunningTest()){
            System.enqueueJob(new HDT_QBL_SIE34_3File2(runId,filterDate, fileType,contentVersionIds));
         }
      } 
      catch (Exception e) {
         errorMessage=e.getMessage();
         status='failed';
         if( !Test.isRunningTest()){
            System.enqueueJob(new HDT_QBL_SIE34CallService(runId,status, fileType, errorMessage,new List<String>()));
         }
      }
     
   }
 
}
