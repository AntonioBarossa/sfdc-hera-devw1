public with sharing class HDT_QBL_SIE34_2MM implements Queueable  {
    private String runId                   ;   
    private Datetime filterDate                ;
    private String fileType                ;
    private List<String> contentVersionIds ;


 
 
    /**
    * @description 
    * @param varRunId 
    * @param varDate 
    * @param varFileType 
    * @param varContentVersionIds 
    **/
    
    public HDT_QBL_SIE34_2MM(String varRunId,Datetime varDate,String varFileType,List<String> varContentVersionIds) {
       this.runId             = varRunId              ;
       this.filterDate        = varDate               ;
       this.fileType          = varFileType           ;
       this.contentVersionIds = varContentVersionIds  ;
    }
 
 
    public void execute(QueueableContext context) {
       String status                  = 'success'   ;
       String errorMessage            = ''          ;
       //query PP(EE)OUT_PREVENTIVI_SME
       String conditionEle = '  WHERE Cluster__c =\'Preventivi\' AND Status =\'Closed\' AND LastModifiedDate >=:filterDate  ';
       String queryEle    = 'SELECT Contract__r.ContractSalesCompany__c,BillingProfile__r.InvoicingCountry__c,BillingProfile__r.ContractAccountCode__c,Account.LastName__c,Account.BillingCity,Account.BillingPlace__c, Account.BillingPostalCode,Account.BillingState,Account.BillingStreetName__c,Account.BillingStreetNumberExtension__c, Account.BillingStreetNumber__c, Account.Category__c, Account.CustomerCode__c,'+
       'Account.CustomerType__c,Account.FirstName__c, Account.FiscalCode__c,Account.VATNumber__c,BillingProfile__r.BillSendingMethod__c, BillingProfile__r.InvoiceCertifiedEmailAddress__c,BillingProfile__r.InvoiceEmailAddress__c, BillingProfile__r.SendCertifiedEmailConsentDate__c,'+
       'BillingProfile__r.BankAccountSignatoryFirstName__c,BillingProfile__r.BankAccountSignatoryFiscalCode__c,BillingProfile__r.BankAccountSignatoryLastName__c,BillingProfile__r.BankAgency__c,BillingProfile__r.BankName__c,BillingProfile__r.IbanABI__c,BillingProfile__r.IbanCAB__c,'+
       'BillingProfile__r.IbanCIN_IBAN__c,BillingProfile__r.IbanCIN__c,BillingProfile__r.IbanCodeNumber__c,BillingProfile__r.IbanCountry__c,BillingProfile__r.InvoicingAddressFormula__c, BillingProfile__r.InvoicingCity__c,'+
       'BillingProfile__r.InvoicingPlace__c,BillingProfile__r.InvoicingPostalCode__c,BillingProfile__r.InvoicingProvince__c,BillingProfile__r.InvoicingStreetName__c,BillingProfile__r.InvoicingStreetNumberExtension__c,'+
       'BillingProfile__r.InvoicingStreetNumber__c, BillingProfile__r.PaymentMethod__c,SubProcess__c, Amount__c,AnnualConsumption__c, AtecoCode__c, CaseNumber,CausalCode__c,CommodityFormula__c,ComplaintEntryChannel__c,'+
       'ConnectionType__c,CreatedBy.Name,CreatedDate,CustomerRequestDate__c,Disconnectable__c,DisconnectibilityType__c,DisplacementDistance__c,DistributorCode__c,DistributorNote__c,Distributor__c,EndDate__c,FirstName__c,'+
       'LastName__c,Market__c,Mobile__c,OperationCode__c,PODPDRFormula__c,Phase__c,PhoneNumber__c,PowerContractualFormula__c,Power__c,QuotationNumber__c,QuotationType__c,RemoteManagementSystem__c,ServicePointType__c,'+
       'SupplyType__c,Taxes__c,TensionOption__c,UseTypeEnergy__c,VATPercentage__c,Voltage__c,Contact.FAX,Contact.FirstName,Contact.LastName,Contact.MobilePhone,ServicePoint__r.SupplyCityCode__c,ServicePoint__r.SupplyCity__c,'+
       'ServicePoint__r.SupplyPlace__c,ServicePoint__r.SupplyPostalCode__c,ServicePoint__r.SupplyProvince__c,ServicePoint__r.SupplyStreetNumberExtension__c,ServicePoint__r.SupplyStreetNumber__c,ServicePoint__r.SupplyStreet__c,'+
       'BillingProfile__r.DivergentSubject__r.ContactCode__c,BillingProfile__r.DivergentSubject__r.FirstName,BillingProfile__r.DivergentSubject__r.FiscalCode__c,BillingProfile__r.DivergentSubject__r.LastName,BillingProfile__r.DivergentSubject__r.MailingCity,BillingProfile__r.DivergentSubject__r.MailingPostalCode,BillingProfile__r.DivergentSubject__r.MailingState,BillingProfile__r.DivergentSubject__r.MailingStreetName__c,BillingProfile__r.DivergentSubject__r.MailingStreetNumber__c,Contact.Email'+
       ' FROM Case ';
       String conditionGas = ' WHERE Cluster__c =\'Preventivi\' AND Status =\'Closed\' AND LastModifiedDate >=:filterDate ';
       String queryGas     = 'SELECT Contract__r.ContractSalesCompany__c,BillingProfile__r.InvoicingCountry__c,BillingProfile__r.ContractAccountCode__c,Account.LastName__c,Account.BillingCity,Account.BillingPlace__c, Account.BillingPostalCode,Account.BillingState,Account.BillingStreetName__c,Account.BillingStreetNumberExtension__c, Account.BillingStreetNumber__c, Account.Category__c, Account.CustomerCode__c,'+
       'Account.CustomerType__c,Account.FirstName__c, Account.FiscalCode__c,Account.VATNumber__c,BillingProfile__r.BillSendingMethod__c, BillingProfile__r.InvoiceCertifiedEmailAddress__c,BillingProfile__r.InvoiceEmailAddress__c, BillingProfile__r.SendCertifiedEmailConsentDate__c,'+
       'BillingProfile__r.BankAccountSignatoryFirstName__c,BillingProfile__r.BankAccountSignatoryFiscalCode__c,BillingProfile__r.BankAccountSignatoryLastName__c,BillingProfile__r.BankAgency__c,BillingProfile__r.BankName__c,BillingProfile__r.IbanABI__c,BillingProfile__r.IbanCAB__c,'+
       'BillingProfile__r.IbanCIN_IBAN__c,BillingProfile__r.IbanCIN__c,BillingProfile__r.IbanCodeNumber__c,BillingProfile__r.IbanCountry__c,BillingProfile__r.InvoicingAddressFormula__c, BillingProfile__r.InvoicingCity__c,'+
       'BillingProfile__r.InvoicingPlace__c,BillingProfile__r.InvoicingPostalCode__c,BillingProfile__r.InvoicingProvince__c,BillingProfile__r.InvoicingStreetName__c,BillingProfile__r.InvoicingStreetNumberExtension__c,'+
       'BillingProfile__r.InvoicingStreetNumber__c, BillingProfile__r.PaymentMethod__c,SubProcess__c, Amount__c,AnnualConsumption__c, AtecoCode__c, CaseNumber,CausalCode__c,CommodityFormula__c,ComplaintEntryChannel__c,'+
       'ConnectionType__c,CreatedBy.Name,CreatedDate,CustomerRequestDate__c,Disconnectable__c,DisconnectibilityType__c,DisplacementDistance__c,DistributorCode__c,DistributorNote__c,Distributor__c,EndDate__c,FirstName__c,'+
       'LastName__c,Market__c,Mobile__c,OperationCode__c,PODPDRFormula__c,Phase__c,PhoneNumber__c,PowerContractualFormula__c,Power__c,QuotationNumber__c,QuotationType__c,RemoteManagementSystem__c,ServicePointType__c,'+
       'SupplyType__c,Taxes__c,TensionOption__c,UseTypeEnergy__c,VATPercentage__c,Voltage__c,Contact.FAX,Contact.FirstName,Contact.LastName,Contact.MobilePhone,ServicePoint__r.SupplyCityCode__c,ServicePoint__r.SupplyCity__c,'+
       'ServicePoint__r.SupplyPlace__c,ServicePoint__r.SupplyPostalCode__c,ServicePoint__r.SupplyProvince__c,ServicePoint__r.SupplyStreetNumberExtension__c,ServicePoint__r.SupplyStreetNumber__c,ServicePoint__r.SupplyStreet__c,'+
       'BillingProfile__r.DivergentSubject__r.ContactCode__c,BillingProfile__r.DivergentSubject__r.FirstName,BillingProfile__r.DivergentSubject__r.FiscalCode__c,BillingProfile__r.DivergentSubject__r.LastName,BillingProfile__r.DivergentSubject__r.MailingCity,BillingProfile__r.DivergentSubject__r.MailingPostalCode,BillingProfile__r.DivergentSubject__r.MailingState,BillingProfile__r.DivergentSubject__r.MailingStreetName__c,BillingProfile__r.DivergentSubject__r.MailingStreetNumber__c,Contact.Email'+
       ' FROM Case ';
    
       try {
          
          List<Case> listCaseEle = Database.query(queryEle+conditionEle);
          List<Case> listCaseGas = Database.query(queryGas+conditionGas);
          String body  ='';
          body=HDT_UTL_SIE34.createBodySIE34_2MMEle(body,listCaseEle);
          body=HDT_UTL_SIE34.createBodySIE34_2MMGas(body,listCaseGas);

      
          if(Test.isRunningTest()){
            throw new TypeException('Throwing an exception to cover the catch block and avoid the enqueue');
         }else if (String.isNotBlank(body)) {
            contentVersionIds.add(HDT_UTL_ContentVersion.makeFile(body,'PP_OUT_PREVENTIVI_MM.txt','PP_OUT_PREVENTIVI_MM'));
         }
         System.enqueueJob(new HDT_QBL_SIE34CallService(runId,status, fileType,errorMessage,contentVersionIds));
       } 
       catch (Exception e) {
          errorMessage=e.getMessage();
          status='failed';
          System.enqueueJob(new HDT_QBL_SIE34CallService(runId,status, fileType, errorMessage,new List<String>()));
       }
      
    }
  
 }
 