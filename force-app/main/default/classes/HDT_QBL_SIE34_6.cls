/**
 * @description       : 
 * @last modified on  : 30-09-2021
**/
public with sharing class HDT_QBL_SIE34_6 implements Queueable  {
    private String runId                   ;   
    private Datetime filterDate            ;
    private String fileType                ;
    private List<String> contentVersionIds ;
    private final String NOTMAPPED=''      ;
 
 
 
    /**
    * @description :  
    * @param varRunId 
    * @param varDate 
    * @param varFileType 
    **/
    public HDT_QBL_SIE34_6(String varRunId,String varDate,String varFileType) {
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
 
       String condition = '  LastModifiedDate >=:filterDate  ';
       String query     = 'SELECT DistributorNote__c,Account.LastName__c,CaseNumber,CreatedDate,SubProcess__c,Account.CustomerCode__c,Account.VATNumber__c,Account.FiscalCode__c,Contact.MobilePhone,Contact.FAX,Contact.Email,Contact.FirstName,Contact.LastName,Account.BillingStreetName__c,Account.BillingStreetNumber__c,Account.BillingPostalCode,Account.BillingCity,Account.BillingState,FirstName__c,LastName__c,ComplaintEntryChannel__c,ServicePoint__r.SupplyStreet__c,ServicePoint__r.SupplyStreetNumber__c,ServicePoint__r.SupplyPostalCode__c,ServicePoint__r.SupplyCity__c,ServicePoint__r.SupplyProvince__c,ServicePoint__r.SupplyCityCode__c,BillingProfile__r.InvoicingStreetName__c,BillingProfile__r.InvoicingStreetNumber__c,BillingProfile__r.InvoicingCity__c,BillingProfile__r.InvoicingProvince__c,BillingProfile__r.PaymentMethod__c,BillingProfile__r.BankName__c,BillingProfile__r.BankAgency__c,BillingProfile__r.IbanCountry__c,BillingProfile__r.IbanCIN_IBAN__c,BillingProfile__r.IbanCIN__c,BillingProfile__r.IbanABI__c,BillingProfile__r.IbanCAB__c,BillingProfile__r.IbanCodeNumber__c,BillingProfile__r.BankAccountSignatoryLastName__c,PODPDRFormula__c,CommodityFormula__c,AnnualConsumption__c,AtecoCode__c,ServicePointType__c,TensionOption__c,PowerContractualFormula__c,Power__c ,Voltage__c,DistributorCode__c,Distributor__c,VATPercentage__c,Taxes__c,Account.BillingStreetNumberExtension__c,Account.BillingPlace__c,ServicePoint__r.SupplyStreetNumberExtension__c,ServicePoint__r.SupplyPlace__c,BillingProfile__r.InvoicingStreetNumberExtension__c,BillingProfile__r.InvoicingPlace__c,BillingProfile__r.InvoicingAddressFormula__c,CreatedBy.Name,PhoneNumber__c,Disconnectable__c,DisconnectibilityType__c,Account.Category__c,Mobile__c,RemoteManagementSystem__c,CustomerRequestDate__c,Amount__c,QuotationNumber__c,ConnectionType__c,UseTypeEnergy__c,Account.CustomerType__c,DisplacementDistance__c,BillingProfile__r.BillSendingMethod__c,BillingProfile__r.InvoiceEmailAddress__c,Account.FirstName__c,BillingProfile__r.ContractAccountCode__c,BillingProfile__r.BankAccountSignatoryFirstName__c,BillingProfile__r.BankAccountSignatoryFiscalCode__c,BillingProfile__r.InvoicingPostalCode__c,BillingProfile__r.InvoiceCertifiedEmailAddress__c,BillingProfile__r.SendCertifiedEmailConsentDate__c FROM Case ';
       
       // Delete Start old File
       String title                   = 'OUT_RDS_PIATTE' ;
       HDT_UTL_ContentVersion.deleteFiles(title)         ;
       // Delete End old File
       String separator = ';'                            ;
    
       try {
          
     
          List<Case> listCase = Database.query(query+condition);
          
          String body  ='';
          for (Case tempCase : listCase) {
            String name=String.isNotBlank(tempCase.FirstName__c)? ' ' +tempCase.FirstName__c:'';

             String row =			
            /*	1	*/ tempCase.CaseNumber                                                                                  +separator+	                                                                             
            /*	2	*/ tempCase.CaseNumber                                                                                  +separator+	                                                                             
            /*	3	*/ tempCase.CreatedDate                                                                                 +separator+	                                                                              
            /*	4	*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	5	*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	6	*/ tempCase.SubProcess__c                                                                               +separator+	                                                                                
            /*	7	*/ tempCase.Account.CustomerCode__c                                                                     +separator+	                                                                                          
            /*	8	*/ tempCase.Account.LastName__c +name                                                                   +separator+	                                                                                                                   
            /*	9	*/ tempCase.Account.VATNumber__c                                                                        +separator+	                                                                                       
            /*	10	*/ tempCase.Account.FiscalCode__c                                                                       +separator+	                                                                                        
            /*	11	*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	12	*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	13	*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	14	*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	15	*/ tempCase.Contact.MobilePhone                                                                         +separator+	                                                                                         
            /*	16	*/ tempCase.Contact.FAX                                                                                 +separator+	                                                                                 
            /*	17	*/ tempCase.Contact.Email                                                                               +separator+	                                                                                          
            /*	18	*/ tempCase.Contact.FirstName                                                                           +separator+	                                                                                    
            /*	19	*/ tempCase.Contact.LastName                                                                            +separator+	                                                                                   
            /*	20	*/ tempCase.Account.BillingStreetName__c                                                                +separator+	                                                                                               
            /*	21	*/ tempCase.Account.BillingStreetNumber__c                                                              +separator+	                                                                                                  
            /*	22	*/ tempCase.Account.BillingPostalCode                                                                   +separator+	                                                                                             
            /*	23	*/ tempCase.Account.BillingCity                                                                         +separator+	                                                                                       
            /*	24	*/ tempCase.Account.BillingState                                                                        +separator+	                                                                                        
            /*	25	*/ tempCase.FirstName__c                                                                                +separator+	                                                                            
            /*	26	*/ tempCase.LastName__c                                                                                 +separator+	                                                                           
            /*	27	*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	28	*/ tempCase.ComplaintEntryChannel__c                                                                    +separator+	                                                                                           
            /*	29	*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	30	*/ tempCase.ServicePoint__r.SupplyStreet__c                                                             +separator+	                                                                                                  
            /*	31	*/ tempCase.ServicePoint__r.SupplyStreetNumber__c                                                       +separator+	                                                                                                        
            /*	32	*/ tempCase.ServicePoint__r.SupplyPostalCode__c                                                         +separator+	                                                                                                      
            /*	33	*/ tempCase.ServicePoint__r.SupplyCity__c                                                               +separator+	                                                                                                
            /*	34	*/ tempCase.ServicePoint__r.SupplyProvince__c                                                           +separator+	                                                                                                    
            /*	35	*/ tempCase.ServicePoint__r.SupplyCityCode__c                                                           +separator+	                                                                                                    
            /*	36	*/ tempCase.BillingProfile__r.InvoicingStreetName__c                                                    +separator+	                                                                                                           
            /*	37	*/ tempCase.BillingProfile__r.InvoicingStreetNumber__c                                                  +separator+	                                                                                                             
            /*	38	*/ tempCase.BillingProfile__r.InvoicingPostalCode__c                                                    +separator+	                                                                                                           
            /*	39	*/ tempCase.BillingProfile__r.InvoicingCity__c                                                          +separator+	                                                                                                     
            /*	40	*/ tempCase.BillingProfile__r.InvoicingProvince__c                                                      +separator+	                                                                                                         
            /*	41	*/ tempCase.BillingProfile__r.PaymentMethod__c                                                          +separator+	                                                                                                     
            /*	42	*/ tempCase.BillingProfile__r.PaymentMethod__c                                                          +separator+	                                                                                                     
            /*	43	*/ tempCase.BillingProfile__r.BankName__c                                                               +separator+	                                                                                                
            /*	44	*/ tempCase.BillingProfile__r.BankAgency__c                                                             +separator+	                                                                                                  
            /*	45	*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	46	*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	47	*/ tempCase.BillingProfile__r.IbanCountry__c                                                            +separator+	                                                                                                   
            /*	48	*/ tempCase.BillingProfile__r.IbanCIN_IBAN__c                                                           +separator+	                                                                                                    
            /*	49	*/ tempCase.BillingProfile__r.IbanCIN__c                                                                +separator+	                                                                                               
            /*	50	*/ tempCase.BillingProfile__r.IbanABI__c                                                                +separator+	                                                                                               
            /*	51	*/ tempCase.BillingProfile__r.IbanCAB__c                                                                +separator+	                                                                                               
            /*	52	*/ tempCase.BillingProfile__r.IbanCodeNumber__c                                                         +separator+	                                                                                                      
            /*	53	*/ tempCase.BillingProfile__r.BankAccountSignatoryFirstName__c                                          +separator+	                                                                                                                     
            /*	54	*/ tempCase.BillingProfile__r.BankAccountSignatoryLastName__c                                           +separator+	                                                                                                                    
            /*	55	*/ tempCase.BillingProfile__r.BankAccountSignatoryFiscalCode__c                                         +separator+	                                                                                                                      
            /*	56	*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	57	*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	58	*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	59	*/ tempCase.PODPDRFormula__c                                                                            +separator+	                                                                                   
            /*	60	*/ tempCase.CommodityFormula__c                                                                         +separator+	                                                                                      
            /*	61	*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	62	*/ tempCase.AnnualConsumption__c                                                                        +separator+	                                                                                       
            /*	63	*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	64	*/ tempCase.AtecoCode__c                                                                                +separator+	                                                                               
            /*	65	*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	66	*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	67	*/ tempCase.ServicePointType__c                                                                         +separator+	                                                                                      
            /*	68	*/ tempCase.TensionOption__c                                                                            +separator+	                                                                                   
            /*	69	*/ tempCase.PowerContractualFormula__c                                                                  +separator+	                                                                                             
            /*	70	*/ tempCase.Power__c                                                                                    +separator+	                                                                           
            /*	71	*/ tempCase.Voltage__c                                                                                  +separator+	                                                                             
            /*	72	*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	73	*/ tempCase.DistributorCode__c                                                                          +separator+	                                                                                     
            /*	74	*/ tempCase.Distributor__c                                                                              +separator+	                                                                                 
            /*	75	*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	76	*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	77	*/ tempCase.VATPercentage__c                                                                            +separator+	                                                                                   
            /*	78	*/ tempCase.Taxes__c                                                                                    +separator+	                                                                           
            /*	79	*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	80	*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	81	*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	82	*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	83	*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	84	*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	85	*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	86	*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	87	*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	88	*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	89	*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	90	*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	91	*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	92	*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	93	*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	94	*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	95	*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	96	*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	97	*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	98	*/ tempCase.Account.BillingStreetNumberExtension__c                                                     +separator+	                                                                                                          
            /*	99	*/ tempCase.Account.BillingPlace__c                                                                     +separator+	                                                                                          
            /*	100*/ tempCase.ServicePoint__r.SupplyStreetNumberExtension__c                                              +separator+	                                                                                                                 
            /*	101*/ tempCase.ServicePoint__r.SupplyPlace__c                                                              +separator+	                                                                                                 
            /*	102*/ tempCase.BillingProfile__r.InvoicingStreetNumberExtension__c                                         +separator+	                                                                                                                      
            /*	103*/ tempCase.BillingProfile__r.InvoicingPlace__c                                                         +separator+	                                                                                                      
            /*	104*/ tempCase.BillingProfile__r.InvoicingAddressFormula__c                                                +separator+	                                                                                                               
            /*	105*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	106*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	107*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	108*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	109*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	110*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	111*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	112*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	113*/ tempCase.CreatedBy.Name                                                                              +separator+	                                                                                 
            /*	114*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	115*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	116*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	117*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	118*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	119*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	120*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	121*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	122*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	123*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	124*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	125*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	126*/ tempCase.DistributorNote__c                                                                          +separator+	                                                                                     
            /*	127*/ tempCase.PhoneNumber__c                                                                              +separator+	                                                                                 
            /*	128*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	129*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	130*/ tempCase.Disconnectable__c                                                                           +separator+	                                                                                    
            /*	131*/ tempCase.DisconnectibilityType__c                                                                    +separator+	                                                                                           
            /*	132*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	133*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	134*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	135*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	136*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	137*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	138*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	139*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	140*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	141*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	142*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	143*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	144*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	145*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	146*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	147*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	148*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	149*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	150*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	151*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	152*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	153*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	154*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	155*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	156*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	157*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	158*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	159*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	160*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	161*/ tempCase.Account.Category__c                                                                         +separator+	                                                                                      
            /*	162*/ tempCase.Mobile__c                                                                                   +separator+	                                                                            
            /*	163*/ tempCase.RemoteManagementSystem__c                                                                   +separator+	                                                                                            
            /*	164*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	165*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	166*/ tempCase.CustomerRequestDate__c                                                                      +separator+	                                                                                         
            /*	167*/ tempCase.Amount__c                                                                                   +separator+	                                                                            
            /*	168*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	169*/ tempCase.QuotationNumber__c                                                                          +separator+	                                                                                     
            /*	170*/ tempCase.ConnectionType__c                                                                           +separator+	                                                                                    
            /*	171*/ tempCase.UseTypeEnergy__c                                                                            +separator+	                                                                                   
            /*	172*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	173*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	174*/ tempCase.Account.CustomerType__c                                                                     +separator+	                                                                                          
            /*	175*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	176*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	177*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	178*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	179*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	180*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	181*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	182*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	183*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	184*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	185*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	186*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	187*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	188*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	189*/ tempCase.DisplacementDistance__c                                                                     +separator+	                                                                                          
            /*	190*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	191*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	192*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	193*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	194*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	195*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	196*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	197*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	198*/ tempCase.BillingProfile__r.BillSendingMethod__c                                                      +separator+	                                                                                                         
            /*	199*/ tempCase.BillingProfile__r.InvoiceEmailAddress__c                                                    +separator+	                                                                                                           
            /*	200*/ tempCase.Account.FirstName__c                                                                        +separator+	                                                                                       
            /*	201*/ tempCase.BillingProfile__r.ContractAccountCode__c                                                    +separator+	                                                                                                           
            /*	202*/ tempCase.BillingProfile__r.BankAccountSignatoryLastName__c                                           +separator+	                                                                                             
            /*	203*/ tempCase.BillingProfile__r.BankAccountSignatoryFirstName__c                                          +separator+	                                                                                                                      
            /*	204*/ tempCase.BillingProfile__r.BankAccountSignatoryFiscalCode__c                                         +separator+	                                                                                                                      
            /*	205*/ tempCase.BillingProfile__r.InvoicingStreetName__c                                                    +separator+	                                                                                                          
            /*	206*/ tempCase.BillingProfile__r.InvoicingStreetNumber__c                                                  +separator+	                                                                                                           
            /*	207*/ NOTMAPPED                                                                                            +separator+	                                                                                           
            /*	208*/ tempCase.BillingProfile__r.InvoicingPostalCode__c                                                    +separator+	                                                                                                      
            /*	209*/ tempCase.BillingProfile__r.InvoicingCity__c                                                          +separator+	                                                                                                 
            /*	210*/ tempCase.BillingProfile__r.InvoicingProvince__c                                                      +separator+	                                                                                                  
            /*	211*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	212*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	213*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	214*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	215*/ tempCase.BillingProfile__r.InvoiceCertifiedEmailAddress__c                                           +separator+	                                                                                                                    
            /*	216*/ tempCase.BillingProfile__r.SendCertifiedEmailConsentDate__c                                          +separator+	                                                                                                                     
            /*	217*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	218*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	219*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	220*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	221*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	222*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	223*/ NOTMAPPED                                                                                            +separator+	                                                                   
            /*	224*/ NOTMAPPED                                                                                             ;	  
            
            row = row.replaceAll('null', '');  
             if (String.isBlank(body)) {
                body=row;
             }
             else {
                body=body+'\n'+row; 
             }
          }
          if (listCase!=null && listCase.size()>0 ) {
             contentVersionIds.add(HDT_UTL_ContentVersion.makeFile(body,'OUT_RDS_PIATTE.txt',title));
          }
          if(!Test.isRunningTest()){
            System.enqueueJob(new HDT_QBL_SIE34CallService(runId,status, fileType,errorMessage,contentVersionIds));
          }
       } catch (Exception e) {
          errorMessage=e.getMessage();
          status='failed';
          if(!Test.isRunningTest()){
            System.enqueueJob(new HDT_QBL_SIE34CallService(runId,status, fileType, errorMessage,new List<String>()));
         }
         
       }
      
    }
  
 }
 