/**
 * @description       : 

**/
public with sharing class HDT_QBL_SIE34_7 implements Queueable  {
    private String runId                   ;   
    private Datetime filterDate                ;
    private String fileType                ;
    private List<String> contentVersionIds ;
    private final String NOTMAPPED='';
 
 
 
    /**
    * @description :  
    * @param varRunId 
    * @param varDate 
    * @param varFileType 
    **/
    public HDT_QBL_SIE34_7(String varRunId,String varDate,String varFileType) {
       this.runId             = varRunId                                             ;
       this.filterDate        = HDT_UTL_LeadProcess.getDateTimeFromString(varDate)   ;
       this.fileType          = varFileType                                          ;
       this.contentVersionIds = new List<String>()                                   ;
    }
 
 
    /**
    * @description 
    * @param context 
    **/
    public void execute(QueueableContext context) {
       String status                  = 'success'   ;
       String errorMessage            = ''          ;
       String condition = ' WHERE Order.ProcessType__c = \'VAS\' AND Order.Phase__c = \'Completata\' ';
       String query     = 'SELECT Id,ContinuityChangeOffer__c,DurationVas__c,PriceNet__c,PriceNetDiscounted__c,Quantity,DiscountEurMWh__c,VasActivationDate__c,BillingMode__c,PaymentMode__c,Order.BillingPostalCode__c ,Order.BillingCity__c ,Order.BillingStreetName__c ,Order.BillingProvince__c ,Order.CustomerCode__c,Order.Account.FiscalCode__c,Order.EndDate,Order.EffectiveDate__c,Order.SignedDate__c,Order.Email__c,Order.CustomerVATNumber__c,Order.VAT__c ,Order.ServicePointCodeFormula__c,Order.OrderNumber,Order.PhoneNumber__c,Order.CommercialProductVersion__c FROM OrderItem ';
       String separator = ';';
 
    
       try {
          
     
          List<OrderItem> listOrderItem = Database.query(query+condition);
          
          String body  ='';
          for (OrderItem tempOrderItem : listOrderItem) {
                String row=
            /*	1	*/	tempOrderItem.ContinuityChangeOffer__c	            +separator+	
            /*	2	*/	tempOrderItem.DurationVas__c	                    +separator+	
            /*	3	*/	tempOrderItem.PriceNet__c	                        +separator+	
            /*	4	*/	tempOrderItem.PriceNetDiscounted__c	                +separator+	
            /*	5	*/	tempOrderItem.Quantity	                            +separator+	
            /*	6	*/	tempOrderItem.DiscountEurMWh__c	                    +separator+	
            /*	7	*/	tempOrderItem.VasActivationDate__c	                +separator+	
            /*	8	*/	tempOrderItem.BillingMode__c	                    +separator+	
            /*	9	*/	tempOrderItem.PaymentMode__c	                    +separator+	
            /*	10	*/	tempOrderItem.Order.BillingPostalCode__c 	        +separator+	
            /*	11	*/	tempOrderItem.Order.BillingCity__c 	                +separator+	
            /*	12	*/	tempOrderItem.Order.BillingStreetName__c 	        +separator+	
            /*	13	*/	tempOrderItem.Order.BillingProvince__c 	            +separator+	
            /*	14	*/	tempOrderItem.Order.OrderNumber	                    +separator+	
            /*	15	*/	tempOrderItem.Order.CustomerCode__c	                +separator+	
            /*	16	*/	tempOrderItem.Order.Account.FiscalCode__c           +separator+	
            /*	17	*/	tempOrderItem.Order.EndDate	                        +separator+	
            /*	18	*/	tempOrderItem.Order.EffectiveDate__c	            +separator+	
            /*	19	*/	tempOrderItem.Order.SignedDate__c	                +separator+	
            /*	20	*/	tempOrderItem.Order.Email__c	                    +separator+	
            /*	21	*/	tempOrderItem.Order.CustomerVATNumber__c	        +separator+	
            /*	22	*/	tempOrderItem.Order.VAT__c 	                        +separator+	
            /*	23	*/	tempOrderItem.Order.ServicePointCodeFormula__c	    +separator+	
            /*	24	*/	tempOrderItem.Order.OrderNumber	                    +separator+	
            /*	25	*/	tempOrderItem.Order.PhoneNumber__c	                +separator+	
            /*	26	*/	tempOrderItem.Order.CommercialProductVersion__c	    +separator+	
            /*	27	*/	NOTMAPPED	                                        +separator+	
            /*	28	*/	NOTMAPPED	                                        +separator+	
            /*	29	*/	NOTMAPPED	                                        +separator+	
            /*	30	*/	NOTMAPPED	                                        +separator+	
            /*	31	*/	NOTMAPPED	                                        +separator+	
            /*	32	*/	NOTMAPPED	                                        +separator+	
            /*	33	*/	NOTMAPPED	                                        +separator+	
            /*	34	*/	NOTMAPPED	                                        +separator+	
            /*	35	*/	NOTMAPPED	                                        +separator+	
            /*	36	*/	NOTMAPPED	                                        +separator+	
            /*	37	*/	NOTMAPPED	                                        +separator+	
            /*	38	*/	NOTMAPPED	                                        +separator+	
            /*	39	*/	NOTMAPPED	                                        +separator+	
            /*	40	*/	NOTMAPPED	                                        +separator+	
            /*	41	*/	NOTMAPPED	                                        +separator+	
            /*	42	*/	NOTMAPPED	                                        +separator+	
            /*	43	*/	NOTMAPPED	                                        +separator+	
            /*	44	*/	NOTMAPPED	                                        +separator+	
            /*	45	*/	NOTMAPPED	                                        +separator+	
            /*	46	*/	NOTMAPPED	                                        +separator+	
            /*	47	*/	NOTMAPPED	                                        +separator+	
            /*	48	*/	NOTMAPPED	                                        +separator+	
            /*	49	*/	NOTMAPPED	                                        +separator+	
            /*	50	*/	NOTMAPPED	                                        +separator+	
            /*	51	*/	NOTMAPPED	                                        +separator+	
            /*	52	*/	NOTMAPPED	                                        +separator+	
            /*	53	*/	NOTMAPPED	                                        +separator+	
            /*	54	*/	NOTMAPPED	                                        +separator+	
            /*	55	*/	NOTMAPPED	                                        +separator+	
            /*	56	*/	NOTMAPPED	                                        +separator+	
            /*	57	*/	NOTMAPPED	                                        +separator+	
            /*	58	*/	NOTMAPPED	                                        ;	
 
             row = row.replaceAll('null', '');  
             if (String.isBlank(body)) {
                body=row;
             }
             else {
                body=body+'\n'+row; 
             }
          }
          if (listOrderItem!=null && listOrderItem.size()>0 ) {
               contentVersionIds.add(HDT_UTL_ContentVersion.makeFile(body,'OUT_VAS.txt','OUT_VAS'));
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
 