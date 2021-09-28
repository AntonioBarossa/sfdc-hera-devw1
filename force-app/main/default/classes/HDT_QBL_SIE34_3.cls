public with sharing class HDT_QBL_SIE34_3 implements Queueable  {
   private String runId;   
   private Date filterDate;
   private String errorMessage;

   public HDT_QBL_SIE34_3(String varRunId,Date varDate) {
      System.debug('Start HDT_QBL_SIE34_3');
      this.runId=varRunId;
      this.filterDate=varDate;
   }


   public void execute(QueueableContext context) {
      System.debug('HDT_QBL_SIE34_3.execute');
      String condition=' WHERE Cluster__c IN (\'Disattivazioni\',\'Morosità\') AND Type=\'Interruzione Fornitura\' AND Status !=\'Closed\' ';
      String query = 'SELECT Account.BillingCity,Account.BillingPlace__c,Account.BillingPostalCode, Account.BillingState, Account.BillingStreetName__c,Account.BillingStreetNumber__c, Account.CustomerCode__c,Account.FirstName__c, Account.FiscalCode__c,Account.LastName__c, Account.VATNumber__c,CASE.CaseNumber, CausalCode__c,CommodityFormula__c,SalesCompany__c,CreatedBy.Name,Distributor__c,NotPerformedBefore__c,PhoneNumber__c,PODPDRFormula__c,ServicePoint__r.MeterType__c,ServicePoint__r.SupplyCity__c,ServicePoint__r.SupplyPlace__c,ServicePoint__r.SupplyPostalCode__c,ServicePoint__r.SupplyProvince__c,ServicePoint__r.SupplyStreetNumber__c,ServicePoint__r.SupplyStreet__c,SubProcess__c,VATPercentage__c,DeliveryAddress__c,Contract__c, BillingProfile__r.InvoicingAddressFormula__c, Subscription__r.SBQQ__ProductName__c FROM Case';
      
   }
}
