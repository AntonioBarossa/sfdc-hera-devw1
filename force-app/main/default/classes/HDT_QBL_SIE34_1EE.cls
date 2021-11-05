public with sharing class HDT_QBL_SIE34_1EE implements Queueable  {
    private String runId                   ;   
    private Datetime filterDate            ;
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
    public HDT_QBL_SIE34_1EE(String varRunId,datetime varDate,String varFileType,List<String> varContentVersionIds) {
       this.runId             = varRunId             ;
       this.filterDate        = varDate              ;
       this.fileType          = varFileType          ;
       this.contentVersionIds = varContentVersionIds ;
    }
 
 
    public void execute(QueueableContext context) {
        String status        = 'success'      ;
        String errorMessage  = ''             ;
        String condition     = ' WHERE Order.Phase__c IN (\'Inviato al DL\',\'Completata\') AND Order.Commodity__c =\'Energia eletrica\' AND LastModifiedDate >=:filterDate ';
        String query         = 'SELECT BillingProfile__r.BankAccountSignatoryFiscalCode__c,BillingProfile__r.BankAccountSignatoryLastName__c, BillingProfile__r.BankAccountSignatoryFirstName__c, BillingProfile__r.IbanCodeNumber__c,BillingProfile__r.IbanCIN__c,BillingProfile__r.IbanABI__c, BillingProfile__r.IbanCAB__c,  BillingProfile__r.IbanCIN_IBAN__c, BillingProfile__r.IbanCountry__c,BillingProfile__r.BankAgency__c,BillingProfile__r.BankName__c,Order.Account.Category__c ,Order.ResidentialPlace__c,Order.ResidentialState__c,Order.ResidentialCity__c,Order.ResidentialPostalCode__c,Order.ResidentialStreetNumber__c,Order.Contact__r.Account.FAX__c,Order.CustomerVATNumber__c,Order.OneshotCustomer__c,order.Account.CustomerCode__c,order.Account.FiscalCode__c,order.Account.VATNumber__c ,order.Account.LegalFormType__c,order.BillingProfile__r.BankAccountSignatoryFirstName__c ,order.BillingProfile__r.BankAccountSignatoryFiscalCode__c ,order.BillingProfile__r.BankAccountSignatoryLastName__c ,order.BillingProfile__r.BankAgency__c,order.BillingProfile__r.BankName__c,order.BillingProfile__r.IbanABI__c ,order.BillingProfile__r.IbanCAB__c ,order.BillingProfile__r.IbanCIN_IBAN__c ,order.BillingProfile__r.IbanCIN__c ,order.BillingProfile__r.IbanCodeNumber__c ,order.BillingProfile__r.IbanCountry__c ,BillingProfile__r.PaymentMethod__c,order.Contact__r.FAX,order.Contact__r.Email,order.Contact__r.Phone,order.SalesContact__r.FirstName,order.SalesContact__r.LastName,Order.Agency__c,Order.AggregateBilling__c,Order.AnnualConsumption__c,Order.AtecoCode__c,Order.Channel__c ,Order.CommentForDL__c,Order.CommercialAction__c,Order.CommercialProductVersion__c,Order.ConnectionMandate__c,Order.ContractId,Order.ConventionAssociation__c,Order.CreatedBy__c ,Order.createddate,Order.CustomerCompanyName__c,Order.CustomerFiscalCode__c,Order.CustomerLastName__c,Order.CustomerName__c,Order.Disconnectable__c,Order.DisconnectibilityType__c,Order.DistributorCode__c,Order.EffectiveDate,Order.ExciseGAS__c,Order.ImplantType__c,Order.MarketOrigin__c,Order.MaxRequiredPotential__c,Order.OrderNumber,Order.PhoneNumber__c,Order.PowerAvailable__c,Order.PowerCommitted__c,Order.PreviousHolderFirstName__c ,Order.PreviousHolderFiscalCode__c ,Order.PreviousHolderLastName__c ,Order.PreviousHolderVatNumber__c ,Order.PreviousTrader__c,Order.ProcessType__c,Order.Profile__c,Order.RequestOption__c,Order.ResidentialStreetName__c,Order.SelfCertificationConnection__c,Order.ServicePointCodeFormula__c,Order.ShippingCity__c,Order.ShippingPlaceCode__c,Order.ShippingPostalCode__c,Order.ShippingProvince__c,Order.ShippingStreetName__c,Order.ShippingStreetNumber__c,Order.SignedDate__c,Order.SupplyCityCode__c,Order.SupplyCity__c,Order.SupplyPlace__c,Order.SupplyPostalCode__c,Order.SupplyState__c,Order.SupplyStreetName__c,Order.SupplyStreetNumber__c,Order.TemporaryConnectionEndDate__c,Order.TemporaryConnectionStartDate__c,Order.VAT__c,Order.VendorFirstName__c ,Order.VendorLastName__c ,Order.VoltageLevel__c,OrderItem.GreenCertificateIncluded__c,OrderItem.GreenEnergyOption__c,OrderItem.Index0PUN__c,OrderItem.Index1PUN__c,OrderItem.Index2PUN__c,OrderItem.Index3PUN__c,OrderItem.PriceF0__c,OrderItem.PriceF1__c,OrderItem.PriceF2__c,OrderItem.PriceF3__c,OrderItem.PriceGas__c,OrderItem.PriceGreenOption__c FROM OrderItem   ';
        String separator     = ';';
        // Delete Start old File
        String title                   = 'OUT_OP_EE' ;
        HDT_UTL_ContentVersion.deleteFiles(title);
       // Delete End old File
    
       try {   
        List<OrderItem> listOrderItem = Database.query(query+condition);
           
          
          
          
        String body  ='';
       
        for (OrderItem tempOrderItem: listOrderItem) {
             //String name=String.isNotBlank(tempOrderItem.order.Account.FirstName__c)? ' ' +tempOrderItem.order.Account.FirstName__c:'';
 
            String row =                                     
            NOTMAPPED                                                                         +separator+         
            tempOrderItem.Order.OrderNumber                                                   +separator+                               
            tempOrderItem.Order.createddate                                                   +separator+                               
            NOTMAPPED                                                                         +separator+         
            NOTMAPPED                                                                         +separator+         
            tempOrderItem.Order.ProcessType__c                                                +separator+                                  
            tempOrderItem.Order.Account.CustomerCode__c                                       +separator+                                     
            tempOrderItem.Order.OneshotCustomer__c                                            +separator+                                         
            tempOrderItem.Order.CustomerVATNumber__c                                          +separator+                                           
            tempOrderItem.Order.CustomerFiscalCode__c                                         +separator+                                            
            tempOrderItem.Order.CustomerFiscalCode__c                                         +separator+                                         
            tempOrderItem.Order.ConventionAssociation__c                                      +separator+                                            
            tempOrderItem.Order.Account.LegalFormType__c                                      +separator+                                      
            NOTMAPPED                                                                         +separator+         
            tempOrderItem.Order.Contact__r.Phone                                              +separator+                                     
            tempOrderItem.Order.Contact__r.Account.FAX__c                                     +separator+                                       
            tempOrderItem.Order.Contact__r.Email                                              +separator+                               
            tempOrderItem.Order.SalesContact__r.FirstName                                     +separator+                                               
            tempOrderItem.Order.SalesContact__r.LastName                                      +separator+                                              
            tempOrderItem.Order.ResidentialStreetName__c                                      +separator+                                               
            tempOrderItem.Order.ResidentialStreetNumber__c                                    +separator+                                                 
            tempOrderItem.Order.ResidentialPostalCode__c                                      +separator+                                               
            tempOrderItem.Order.ResidentialCity__c                                            +separator+                                         
            tempOrderItem.Order.ResidentialState__c                                           +separator+                                          
            tempOrderItem.Order.VendorLastName__c                                             +separator+                                      
            tempOrderItem.Order.VendorFirstName__c                                            +separator+                                       
            tempOrderItem.Order.Agency__c                                                     +separator+                              
            tempOrderItem.Order.Channel__c                                                    +separator+                               
            tempOrderItem.Order.CommercialAction__c                                           +separator+                                       
            tempOrderItem.Order.SupplyStreetName__c                                           +separator+                                       
            tempOrderItem.Order.SupplyStreetNumber__c                                         +separator+                                         
            tempOrderItem.Order.SupplyPostalCode__c                                           +separator+                                       
            tempOrderItem.Order.SupplyCity__c                                                 +separator+                                 
            tempOrderItem.Order.SupplyState__c                                                +separator+                                  
            tempOrderItem.Order.SupplyCityCode__c                                             +separator+                                     
            tempOrderItem.Order.ShippingStreetName__c                                         +separator+                                         
            tempOrderItem.Order.ShippingStreetNumber__c                                       +separator+                                           
            tempOrderItem.Order.ShippingPostalCode__c                                         +separator+                                         
            tempOrderItem.Order.ShippingCity__c                                               +separator+                                   
            tempOrderItem.Order.ShippingProvince__c                                           +separator+                                       
            NOTMAPPED                                                                         +separator+                                            
            tempOrderItem.BillingProfile__r.PaymentMethod__c                                  +separator+                                             
            tempOrderItem.BillingProfile__r.BankName__c                                       +separator+                                                          
            tempOrderItem.BillingProfile__r.BankAgency__c                                     +separator+                                                            
            NOTMAPPED                                                                         +separator+         
            NOTMAPPED                                                                         +separator+         
            tempOrderItem.BillingProfile__r.IbanCountry__c                                    +separator+                                            
            tempOrderItem.BillingProfile__r.IbanCIN_IBAN__c                                   +separator+                                             
            tempOrderItem.BillingProfile__r.IbanCIN__c                                        +separator+                                        
            tempOrderItem.BillingProfile__r.IbanABI__c                                        +separator+                                        
            tempOrderItem.BillingProfile__r.IbanCAB__c                                        +separator+                                        
            tempOrderItem.BillingProfile__r.IbanCodeNumber__c                                 +separator+                                               
            tempOrderItem.BillingProfile__r.BankAccountSignatoryFirstName__c                  +separator+                                                              
            tempOrderItem.BillingProfile__r.BankAccountSignatoryLastName__c                   +separator+                                                             
            tempOrderItem.BillingProfile__r.BankAccountSignatoryFiscalCode__c                 +separator+                                                               
            tempOrderItem.Order.AggregateBilling__c                                           +separator+                                       
            tempOrderItem.Order.SignedDate__c                                                 +separator+                                 
            tempOrderItem.Order.EffectiveDate                                                 +separator+                                 
            tempOrderItem.Order.ServicePointCodeFormula__c                                    +separator+                                              
            NOTMAPPED                                                                         +separator+         
            tempOrderItem.Order.AnnualConsumption__c                                          +separator+                                        
            NOTMAPPED                                                                         +separator+         
            tempOrderItem.Order.AtecoCode__c                                                  +separator+                                
            tempOrderItem.Order.TemporaryConnectionStartDate__c                               +separator+                                                   
            tempOrderItem.Order.TemporaryConnectionEndDate__c                                 +separator+                                                 
            tempOrderItem.Order.ImplantType__c                                                +separator+                                  
            tempOrderItem.Order.RequestOption__c                                              +separator+                                    
            tempOrderItem.Order.PowerCommitted__c                                             +separator+                                     
            NOTMAPPED                                                                         +separator+         
            tempOrderItem.Order.VoltageLevel__c                                               +separator+                                   
            NOTMAPPED                                                                         +separator+         
            tempOrderItem.Order.DistributorCode__c                                            +separator+                                      
            NOTMAPPED                                                                         +separator+         
            tempOrderItem.Order.MarketOrigin__c                                               +separator+                                   
            tempOrderItem.Order.PreviousTrader__c                                             +separator+                                     
            tempOrderItem.Order.VAT__c                                                        +separator+                          
            tempOrderItem.Order.ExciseGAS__c                                                  +separator+                                
            NOTMAPPED                                                                         +separator+         
            tempOrderItem.Order.Profile__c                                                    +separator+                              
            tempOrderItem.Order.CommercialProductVersion__c                                   +separator+                                               
            tempOrderItem.Order.ContractId                                                    +separator+                              
            tempOrderItem.PriceF0__c                                                          +separator+                        
            tempOrderItem.PriceF1__c                                                          +separator+                        
            tempOrderItem.PriceF2__c                                                          +separator+                        
            tempOrderItem.PriceF3__c                                                          +separator+                        
            NOTMAPPED                                                                         +separator+         
            NOTMAPPED                                                                         +separator+         
            NOTMAPPED                                                                         +separator+         
            NOTMAPPED                                                                         +separator+         
            tempOrderItem.PriceGas__c                                                         +separator+                         
            NOTMAPPED                                                                         +separator+         
            NOTMAPPED                                                                         +separator+         
            NOTMAPPED                                                                         +separator+         
            NOTMAPPED                                                                         +separator+         
            NOTMAPPED                                                                         +separator+         
            tempOrderItem.GreenEnergyOption__c                                                +separator+                                  
            NOTMAPPED                                                                         +separator+         
            tempOrderItem.Order.ResidentialPlace__c                                           +separator+                                          
            NOTMAPPED                                                                         +separator+         
            tempOrderItem.Order.SupplyPlace__c                                                +separator+                                  
            NOTMAPPED                                                                         +separator+         
            tempOrderItem.Order.ShippingPlaceCode__c                                          +separator+                                        
            tempOrderItem.Order.ResidentialStreetName__c                                      +separator+                                            
            NOTMAPPED                                                                         +separator+         
            NOTMAPPED                                                                         +separator+         
            NOTMAPPED                                                                         +separator+         
            NOTMAPPED                                                                         +separator+         
            NOTMAPPED                                                                         +separator+         
            tempOrderItem.PriceGreenOption__c                                                 +separator+                                 
            NOTMAPPED                                                                         +separator+         
            NOTMAPPED                                                                         +separator+         
            tempOrderItem.Order.CreatedBy__c                                                  +separator+                                 
            NOTMAPPED                                                                         +separator+         
            NOTMAPPED                                                                         +separator+         
            NOTMAPPED                                                                         +separator+         
            NOTMAPPED                                                                         +separator+         
            tempOrderItem.Order.MaxRequiredPotential__c                                       +separator+                                           
            tempOrderItem.Order.PowerAvailable__c                                             +separator+                                     
            NOTMAPPED                                                                         +separator+         
            NOTMAPPED                                                                         +separator+         
            tempOrderItem.Order.CustomerName__c                                               +separator+                                   
            tempOrderItem.Order.CustomerLastName__c                                           +separator+                                       
            tempOrderItem.Order.CustomerCompanyName__c                                        +separator+                                          
            NOTMAPPED                                                                         +separator+         
            tempOrderItem.Order.CommentForDL__c                                               +separator+                                   
            tempOrderItem.Order.PhoneNumber__c                                                +separator+                                  
            tempOrderItem.Order.ConnectionMandate__c                                          +separator+                                        
            tempOrderItem.Order.SelfCertificationConnection__c                                +separator+                                                  
            tempOrderItem.Order.Disconnectable__c                                             +separator+                                     
            tempOrderItem.Order.DisconnectibilityType__c                                      +separator+                                            
            NOTMAPPED                                                                         +separator+         
            NOTMAPPED                                                                         +separator+         
            NOTMAPPED                                                                         +separator+         
            NOTMAPPED                                                                         +separator+         
            NOTMAPPED                                                                         +separator+         
            NOTMAPPED                                                                         +separator+         
            tempOrderItem.PriceGreenOption__c                                                 +separator+                                 
            tempOrderItem.GreenCertificateIncluded__c                                         +separator+                                         
            NOTMAPPED                                                                         +separator+         
            NOTMAPPED                                                                         +separator+         
            NOTMAPPED                                                                         +separator+         
            NOTMAPPED                                                                         +separator+         
            tempOrderItem.Index1PUN__c                                                        +separator+                          
            tempOrderItem.Index2PUN__c                                                        +separator+                          
            tempOrderItem.Index3PUN__c                                                        +separator+                          
            NOTMAPPED                                                                         +separator+         
            NOTMAPPED                                                                         +separator+         
            NOTMAPPED                                                                         +separator+         
            NOTMAPPED                                                                         +separator+         
            tempOrderItem.Index0PUN__c                                                        +separator+                          
            NOTMAPPED                                                                         +separator+         
            NOTMAPPED                                                                         +separator+         
            NOTMAPPED                                                                         +separator+         
            NOTMAPPED                                                                         +separator+         
            NOTMAPPED                                                                         +separator+         
            tempOrderItem.Order.PreviousHolderFirstName__c                                    +separator+                                               
            tempOrderItem.Order.PreviousHolderLastName__c                                     +separator+                                              
            tempOrderItem.Order.PreviousHolderFiscalCode__c                                   +separator+                                                
            tempOrderItem.Order.PreviousHolderVatNumber__c                                    +separator+                                               
            tempOrderItem.Order.Account.Category__c                                           +separator+                                          
            NOTMAPPED                                                                         +separator+         
            NOTMAPPED                                                                         +separator+         
            NOTMAPPED                                                                         +separator+         
            NOTMAPPED                                                                         +separator+         
            NOTMAPPED                                                                         +separator+         
            NOTMAPPED                                                                         ;     
                                                           
            row = row.replaceAll('null', '');  
                 
                                                      
              
            if (String.isBlank(body)) {
                body=row;
            }
            else {
                body=body+'\n'+row; 
            }
           
        }
        if (listOrderItem!=null && listOrderItem.size()>0 ) {
            contentVersionIds.add(HDT_UTL_ContentVersion.makeFile(body,'OUT_OP_EE.txt',title));
        }
        if(!Test.isRunningTest()){
        	System.enqueueJob(new HDT_QBL_SIE34CallService(runId,status, fileType, errorMessage,contentVersionIds));
        }
     
    } 
       catch (Exception e) {
          errorMessage=e.getMessage();
          status='failed';
          if(!Test.isRunningTest()){
    	  	System.enqueueJob(new HDT_QBL_SIE34CallService(runId,status, fileType, errorMessage,new List<String>()));
          }
       }
      
    }
  
 }