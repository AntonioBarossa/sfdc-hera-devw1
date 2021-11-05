public with sharing class HDT_UTL_SIE34 {
    private static final string separator  = ';'     ;
    private static final String NOTMAPPED  = ''      ;
    
    /**
    * @description 
    * @param body 
    * @param listCaseEle 
    * @return String 
    **/
    public static String createBodySIE34_2SMEEle(String body,List<Case> listCaseEle ){
        for (Case tempCase : listCaseEle) {
            String name=String.isNotBlank(tempCase.FirstName__c)? ' ' +tempCase.FirstName__c:'';
            
            String row = 
            /*	1	*/  tempCase.CaseNumber                                                                      +separator+                                     
            /*	2	*/  tempCase.CaseNumber                                                                      +separator+                                     
            /*	3	*/  tempCase.CreatedDate                                                                     +separator+                                     
            /*	4	*/  NOTMAPPED                                                                       +separator+                                               
            /*	5	*/  NOTMAPPED                                                                       +separator+                                               
            /*	6	*/  tempCase.SubProcess__c                                                                   +separator+                                     
            /*	7	*/  tempCase.Account.CustomerCode__c                                                         +separator+                                     
            /*	8	*/  tempCase.Account.LastName__c + name                                                      +separator+                                     
            /*	9	*/  tempCase.Account.VATNumber__c                                                            +separator+                                     
            /*	10	*/  tempCase.Account.FiscalCode__c                                                           +separator+                                     
            /*	11	*/  NOTMAPPED                                                                       +separator+                                               
            /*	12	*/  NOTMAPPED                                                                       +separator+                                               
            /*	13	*/  NOTMAPPED                                                                       +separator+                                               
            /*	14	*/  NOTMAPPED                                                                       +separator+                                               
            /*	15	*/  tempCase.Contact.MobilePhone                                                             +separator+                                     
            /*	16	*/  tempCase.Contact.FAX                                                                     +separator+                                     
            /*	17	*/  tempCase.Contact.Email                                                                   +separator+                                     
            /*	18	*/  tempCase.Contact.FirstName                                                               +separator+                                     
            /*	19	*/  tempCase.Contact.LastName                                                                +separator+                                     
            /*	20	*/  tempCase.Account.BillingStreetName__c                                                    +separator+                                     
            /*	21	*/  tempCase.Account.BillingStreetNumber__c                                                  +separator+                                     
            /*	22	*/  tempCase.Account.BillingPostalCode                                                       +separator+                                     
            /*	23	*/  tempCase.Account.BillingCity                                                             +separator+                                     
            /*	24	*/  tempCase.Account.BillingState                                                            +separator+                                     
            /*	25	*/  tempCase.FirstName__c                                                                    +separator+                                     
            /*	26	*/  tempCase.LastName__c                                                                     +separator+                                     
            /*	27	*/  NOTMAPPED                                                                       +separator+                                               
            /*	28	*/  tempCase.ComplaintEntryChannel__c                                                        +separator+                                     
            /*	29	*/  NOTMAPPED                                                                       +separator+                                               
            /*	30	*/  tempCase.ServicePoint__r.SupplyStreet__c                                                 +separator+                                     
            /*	31	*/  tempCase.ServicePoint__r.SupplyStreetNumber__c                                           +separator+                                     
            /*	32	*/  tempCase.ServicePoint__r.SupplyPostalCode__c                                             +separator+                                     
            /*	33	*/  tempCase.ServicePoint__r.SupplyCity__c                                                   +separator+                                     
            /*	34	*/  tempCase.ServicePoint__r.SupplyProvince__c                                               +separator+                                     
            /*	35	*/  tempCase.ServicePoint__r.SupplyCityCode__c                                               +separator+                                     
            /*	36	*/  tempCase.BillingProfile__r.InvoicingStreetName__c                                        +separator+                                     
            /*	37	*/  tempCase.BillingProfile__r.InvoicingStreetNumber__c                                      +separator+                                     
            /*	38	*/  tempCase.BillingProfile__r.InvoicingPostalCode__c                                        +separator+                                     
            /*	39	*/  tempCase.BillingProfile__r.InvoicingCity__c                                              +separator+                                     
            /*	40	*/  tempCase.BillingProfile__r.InvoicingProvince__c                                          +separator+                                     
            /*	41	*/  tempCase.BillingProfile__r.PaymentMethod__c                                              +separator+                                     
            /*	42	*/  tempCase.BillingProfile__r.PaymentMethod__c                                              +separator+                                     
            /*	43	*/  tempCase.BillingProfile__r.BankName__c                                                   +separator+                                     
            /*	44	*/  tempCase.BillingProfile__r.BankAgency__c                                                 +separator+                                     
            /*	45	*/  NOTMAPPED                                                                       +separator+                                               
            /*	46	*/  NOTMAPPED                                                                       +separator+                                               
            /*	47	*/  tempCase.BillingProfile__r.IbanCountry__c                                                +separator+                                     
            /*	48	*/  tempCase.BillingProfile__r.IbanCIN_IBAN__c                                               +separator+                                     
            /*	49	*/  tempCase.BillingProfile__r.IbanCIN__c                                                    +separator+                                     
            /*	50	*/  tempCase.BillingProfile__r.IbanABI__c                                                    +separator+                                     
            /*	51	*/  tempCase.BillingProfile__r.IbanCAB__c                                                    +separator+                                     
            /*	52	*/  tempCase.BillingProfile__r.IbanCodeNumber__c                                             +separator+                                     
            /*	53	*/  tempCase.BillingProfile__r.BankAccountSignatoryFirstName__c                              +separator+                                     
            /*	54	*/  tempCase.BillingProfile__r.BankAccountSignatoryLastName__c                               +separator+                                     
            /*	55	*/  tempCase.BillingProfile__r.BankAccountSignatoryFiscalCode__c                             +separator+                                     
            /*	56	*/  NOTMAPPED                                                                       +separator+                                               
            /*	57	*/  NOTMAPPED                                                                       +separator+                                               
            /*	58	*/  NOTMAPPED                                                                       +separator+                                               
            /*	59	*/  tempCase.PODPDRFormula__c                                                                +separator+                                     
            /*	60	*/  tempCase.CommodityFormula__c                                                             +separator+                                     
            /*	61	*/  NOTMAPPED                                                                       +separator+                                               
            /*	62	*/  tempCase.AnnualConsumption__c                                                            +separator+                                     
            /*	63	*/  NOTMAPPED                                                                       +separator+                                               
            /*	64	*/  tempCase.AtecoCode__c                                                                    +separator+                                     
            /*	65	*/  NOTMAPPED                                                                       +separator+                                               
            /*	66	*/  NOTMAPPED                                                                       +separator+                                               
            /*	67	*/  tempCase.ServicePointType__c                                                             +separator+                                     
            /*	68	*/  tempCase.TensionOption__c                                                                +separator+                                     
            /*	69	*/  tempCase.PowerContractualFormula__c                                                      +separator+                                     
            /*	70	*/  tempCase.Power__c                                                                        +separator+                                     
            /*	71	*/  tempCase.Voltage__c                                                                      +separator+                                     
            /*	72	*/  NOTMAPPED                                                                       +separator+                                               
            /*	73	*/  tempCase.DistributorCode__c                                                              +separator+                                     
            /*	74	*/  tempCase.Distributor__c                                                                  +separator+                                     
            /*	75	*/  NOTMAPPED                                                                       +separator+                                               
            /*	76	*/  NOTMAPPED                                                                       +separator+                                               
            /*	77	*/  tempCase.VATPercentage__c                                                                +separator+                                     
            /*	78	*/  tempCase.Taxes__c                                                                        +separator+                                     
            /*	79	*/  NOTMAPPED                                                                       +separator+                                               
            /*	80	*/  NOTMAPPED                                                                       +separator+                                               
            /*	81	*/  NOTMAPPED                                                                       +separator+                                               
            /*	82	*/  NOTMAPPED                                                                       +separator+                                               
            /*	83	*/  NOTMAPPED                                                                       +separator+                                               
            /*	84	*/  NOTMAPPED                                                                       +separator+                                               
            /*	85	*/  NOTMAPPED                                                                       +separator+                                               
            /*	86	*/  NOTMAPPED                                                                       +separator+                                               
            /*	87	*/  NOTMAPPED                                                                       +separator+                                               
            /*	88	*/  NOTMAPPED                                                                       +separator+                                               
            /*	89	*/  NOTMAPPED                                                                       +separator+                                               
            /*	90	*/  NOTMAPPED                                                                       +separator+                                               
            /*	91	*/  NOTMAPPED                                                                       +separator+                                               
            /*	92	*/  NOTMAPPED                                                                       +separator+                                               
            /*	93	*/  NOTMAPPED                                                                       +separator+                                               
            /*	94	*/  NOTMAPPED                                                                       +separator+                                               
            /*	95	*/  NOTMAPPED                                                                       +separator+                                               
            /*	96	*/  NOTMAPPED                                                                       +separator+                                               
            /*	97	*/  NOTMAPPED                                                                       +separator+                                               
            /*	98	*/  tempCase.Account.BillingStreetNumberExtension__c                                         +separator+                                     
            /*	99	*/  tempCase.Account.BillingPlace__c                                                         +separator+                                     
            /*	100	*/  tempCase.ServicePoint__r.SupplyStreetNumberExtension__c                                  +separator+                                     
            /*	101	*/  tempCase.ServicePoint__r.SupplyPlace__c                                                  +separator+                                     
            /*	102	*/  tempCase.BillingProfile__r.InvoicingStreetNumberExtension__c                             +separator+                                     
            /*	103	*/  tempCase.BillingProfile__r.InvoicingPlace__c                                             +separator+                                     
            /*	104	*/  tempCase.BillingProfile__r.InvoicingAddressFormula__c                                    +separator+                                     
            /*	105	*/  NOTMAPPED                                                                       +separator+                                               
            /*	106	*/  NOTMAPPED                                                                       +separator+                                               
            /*	107	*/  NOTMAPPED                                                                       +separator+                                               
            /*	108	*/  NOTMAPPED                                                                       +separator+                                               
            /*	109	*/  NOTMAPPED                                                                       +separator+                                               
            /*	110	*/  NOTMAPPED                                                                       +separator+                                               
            /*	111	*/  NOTMAPPED                                                                       +separator+                                               
            /*	112	*/  NOTMAPPED                                                                       +separator+                                               
            /*	113	*/  tempCase.CreatedBy.Name                                                                  +separator+                                     
            /*	114	*/  NOTMAPPED                                                                               +separator+                                               
            /*	115	*/  NOTMAPPED                                                                               +separator+                                               
            /*	116	*/  NOTMAPPED                                                                               +separator+                                               
            /*	117	*/  NOTMAPPED                                                                               +separator+                                               
            /*	118	*/  NOTMAPPED                                                                               +separator+                                               
            /*	119	*/  NOTMAPPED                                                                               +separator+                                               
            /*	120	*/  NOTMAPPED                                                                               +separator+                                               
            /*	121	*/  NOTMAPPED                                                                               +separator+                                               
            /*	122	*/  NOTMAPPED                                                                               +separator+                                               
            /*	123	*/  NOTMAPPED                                                                               +separator+                                               
            /*	124	*/  NOTMAPPED                                                                               +separator+                                               
            /*	125	*/  NOTMAPPED                                                                               +separator+                                               
            /*	126	*/  tempCase.DistributorNote__c                                                              +separator+                                     
            /*	127	*/  tempCase.PhoneNumber__c                                                                  +separator+                                     
            /*	128	*/  NOTMAPPED                                                                                +separator+                                               
            /*	129	*/  NOTMAPPED                                                                                +separator+                                               
            /*	130	*/  tempCase.Disconnectable__c                                                               +separator+                                     
            /*	131	*/  tempCase.DisconnectibilityType__c                                                        +separator+                                     
            /*	132	*/  NOTMAPPED                                                                                +separator+                                               
            /*	133	*/  NOTMAPPED                                                                                +separator+                                               
            /*	134	*/  NOTMAPPED                                                                                +separator+                                               
            /*	135	*/  NOTMAPPED                                                                                +separator+                                               
            /*	136	*/  NOTMAPPED                                                                                +separator+                                               
            /*	137	*/  NOTMAPPED                                                                                +separator+                                               
            /*	138	*/  NOTMAPPED                                                                                +separator+                                               
            /*	139	*/  NOTMAPPED                                                                                +separator+                                               
            /*	140	*/  NOTMAPPED                                                                                +separator+                                               
            /*	141	*/  NOTMAPPED                                                                                +separator+                                               
            /*	142	*/  NOTMAPPED                                                                                +separator+                                               
            /*	143	*/  NOTMAPPED                                                                                +separator+                                               
            /*	144	*/  NOTMAPPED                                                                                +separator+                                               
            /*	145	*/  NOTMAPPED                                                                                +separator+                                               
            /*	146	*/  NOTMAPPED                                                                                +separator+                                               
            /*	147	*/  NOTMAPPED                                                                                +separator+                                               
            /*	148	*/  NOTMAPPED                                                                                +separator+                                               
            /*	149	*/  NOTMAPPED                                                                                +separator+                                               
            /*	150	*/  NOTMAPPED                                                                                +separator+                                               
            /*	151	*/  NOTMAPPED                                                                                +separator+                                               
            /*	152	*/  NOTMAPPED                                                                                +separator+                                               
            /*	153	*/  NOTMAPPED                                                                                +separator+                                               
            /*	154	*/  NOTMAPPED                                                                                +separator+                                               
            /*	155	*/  NOTMAPPED                                                                                +separator+                                               
            /*	156	*/  NOTMAPPED                                                                                +separator+                                               
            /*	157	*/  NOTMAPPED                                                                                +separator+                                               
            /*	158	*/  NOTMAPPED                                                                                +separator+                                               
            /*	159	*/  NOTMAPPED                                                                                +separator+                                               
            /*	160	*/  NOTMAPPED                                                                                +separator+                                               
            /*	161	*/  tempCase.Account.Category__c                                                             +separator+                                     
            /*	162	*/  tempCase.Mobile__c                                                                       +separator+                                     
            /*	163	*/  tempCase.RemoteManagementSystem__c                                                       +separator+                                     
            /*	164	*/  NOTMAPPED                                                                                +separator+                                               
            /*	165	*/  NOTMAPPED                                                                                +separator+                                               
            /*	166	*/  tempCase.CustomerRequestDate__c                                                          +separator+                                     
            /*	167	*/  tempCase.Amount__c                                                                       +separator+                                     
            /*	168	*/  tempCase.Phase__c                                                                        +separator+                                     
            /*	169	*/  tempCase.QuotationNumber__c                                                              +separator+                                     
            /*	170	*/  tempCase.ConnectionType__c                                                               +separator+                                     
            /*	171	*/  tempCase.UseTypeEnergy__c                                                                +separator+                                     
            /*	172	*/  NOTMAPPED                                                                                +separator+                                               
            /*	173	*/  NOTMAPPED                                                                                +separator+                                               
            /*	174	*/  tempCase.Account.CustomerType__c                                                         +separator+                                     
            /*	175	*/  NOTMAPPED                                                                                +separator+                                               
            /*	176	*/  NOTMAPPED                                                                                +separator+                                               
            /*	177	*/  NOTMAPPED                                                                                +separator+                                               
            /*	178	*/  NOTMAPPED                                                                                +separator+                                               
            /*	179	*/  NOTMAPPED                                                                                +separator+                                               
            /*	180	*/  NOTMAPPED                                                                                +separator+                                               
            /*	181	*/  NOTMAPPED                                                                                +separator+                                               
            /*	182	*/  NOTMAPPED                                                                                +separator+                                               
            /*	183	*/  NOTMAPPED                                                                                +separator+                                               
            /*	184	*/  NOTMAPPED                                                                                +separator+                                               
            /*	185	*/  NOTMAPPED                                                                                +separator+                                               
            /*	186	*/  NOTMAPPED                                                                                +separator+                                               
            /*	187	*/  NOTMAPPED                                                                                +separator+                                               
            /*	188	*/  NOTMAPPED                                                                                +separator+                                               
            /*	189	*/  tempCase.DisplacementDistance__c                                                         +separator+                                     
            /*	190	*/  NOTMAPPED                                                                                +separator+                                               
            /*	191	*/  NOTMAPPED                                                                                +separator+                                               
            /*	192	*/  tempCase.EndDate__c                                                                      +separator+                                     
            /*	193	*/  NOTMAPPED                                                                                +separator+                                               
            /*	194	*/  NOTMAPPED                                                                                +separator+                                               
            /*	195	*/  NOTMAPPED                                                                                +separator+                                               
            /*	196	*/  NOTMAPPED                                                                                +separator+                                               
            /*	197	*/  NOTMAPPED                                                                                +separator+                                               
            /*	198	*/  tempCase.BillingProfile__r.BillSendingMethod__c                                          +separator+                                     
            /*	199	*/  tempCase.BillingProfile__r.InvoiceEmailAddress__c                                        +separator+                                     
            /*	200	*/  tempCase.Account.FirstName__c                                                            +separator+                                     
            /*	201	*/  tempCase.BillingProfile__r.DivergentSubject__r.ContactCode__c                            +separator+                                 
            /*	202	*/  tempCase.BillingProfile__r.DivergentSubject__r.LastName                                  +separator+                         
            /*	203	*/  tempCase.BillingProfile__r.DivergentSubject__r.FirstName                                 +separator+                             
            /*	204	*/  tempCase.BillingProfile__r.DivergentSubject__r.FiscalCode__c                             +separator+                                             
            /*	205	*/  tempCase.BillingProfile__r.DivergentSubject__r.MailingStreetName__c                      +separator+                                         
            /*	206	*/  tempCase.BillingProfile__r.DivergentSubject__r.MailingStreetNumber__c                    +separator+                                            
            /*	207	*/  NOTMAPPED                                                                                +separator+
            /*	208	*/  tempCase.BillingProfile__r.DivergentSubject__r.MailingPostalCode                         +separator+    
            /*	209	*/  tempCase.BillingProfile__r.DivergentSubject__r.MailingCity                               +separator+
            /*	210	*/  tempCase.BillingProfile__r.DivergentSubject__r.MailingState                              +separator+ 
            /*	211	*/  NOTMAPPED                                                                                +separator+
            /*	212	*/  NOTMAPPED                                                                                +separator+    
            /*	213	*/  NOTMAPPED                                                                                +separator+                         
            /*	214	*/  NOTMAPPED                                                                                +separator+                   
            /*	215	*/  tempCase.BillingProfile__r.InvoiceCertifiedEmailAddress__c                               +separator+       
            /*	216	*/  tempCase.BillingProfile__r.SendCertifiedEmailConsentDate__c                              +separator+       
            /*	217	*/  NOTMAPPED                                                                                +separator+                   
            /*	218	*/  NOTMAPPED                                                                                +separator+                      
            /*	219	*/  NOTMAPPED                                                                                +separator+                      
            /*	220	*/  NOTMAPPED                                                                                +separator+                      
            /*	221	*/  NOTMAPPED                                                                                +separator+                      
            /*	222	*/  NOTMAPPED                                                                                +separator+                      
            /*	223	*/  NOTMAPPED                                                                                +separator+                      
            /*	224	*/  NOTMAPPED                                                                                +separator+                      
            /*	225	*/  NOTMAPPED                                                                                +separator+                      
            /*	226	*/  tempCase.SupplyType__c                                                                   +separator+          
            /*	227	*/  tempCase.Market__c                                                                       +separator+          
            /*	228	*/  tempCase.OperationCode__c                                                                +separator+          
            /*	229	*/  tempCase.QuotationType__c                                                                +separator+          
            /*	230	*/  NOTMAPPED                                                                       +separator+                      
            /*	231	*/  NOTMAPPED                                                                       +separator+                      
            /*	232	*/  NOTMAPPED                                                                       +separator+                      
            /*	233	*/  NOTMAPPED                                                                       +separator+                      
            /*	234	*/  NOTMAPPED                                                                       +separator+                      
            /*	235	*/  NOTMAPPED                                                                       +separator+                      
            /*	236	*/  NOTMAPPED                                                                       +separator+                      
            /*	237	*/  NOTMAPPED                                                                       +separator+                      
            /*	238	*/  NOTMAPPED                                                                       +separator+                      
            /*	239	*/  NOTMAPPED                                                                       +separator+                      
            /*	240	*/  NOTMAPPED                                                                       +separator+                      
            /*	241	*/  NOTMAPPED                                                                       +separator+                      
            /*	242	*/  NOTMAPPED                                                                       +separator+                      
            /*	243	*/  NOTMAPPED                                                                       +separator+                      
            /*	244	*/  NOTMAPPED                                                                       +separator+                      
            /*	245	*/  NOTMAPPED                                                                       +separator+                      
            /*	246	*/  NOTMAPPED                                                                       +separator+                      
            /*	247	*/  NOTMAPPED                                                                       +separator+                      
            /*	248	*/  NOTMAPPED                                                                       +separator+                      
            /*	249	*/  NOTMAPPED                                                                       +separator+                      
            /*	250	*/  NOTMAPPED                                                                       +separator+                      
            /*	251	*/  NOTMAPPED                                                                       +separator+                      
            /*	252	*/  NOTMAPPED                                                                       +separator+                      
            /*	253	*/  NOTMAPPED                                                                       +separator+                      
            /*	254	*/  NOTMAPPED                                                                       +separator+                      
            /*	255	*/  NOTMAPPED                                                                       +separator+                      
            /*	256	*/  NOTMAPPED                                                                       +separator+                      
            /*	257	*/  NOTMAPPED                                                                       +separator+                      
            /*	258	*/  NOTMAPPED                                                                       +separator+                      
            /*	259	*/  NOTMAPPED                                                                       +separator+                      
            /*	260	*/  NOTMAPPED                                                                       +separator+                      
            /*	261	*/  NOTMAPPED                                                                       +separator+                      
            /*	262	*/  NOTMAPPED                                                                       +separator+                      
            /*	263	*/  NOTMAPPED                                                                       +separator+                      
            /*	264	*/  NOTMAPPED                                                                       +separator+                      
            /*	265	*/  NOTMAPPED                                                                       +separator+                      
            /*	266	*/  NOTMAPPED                                                                       +separator+                      
            /*	267	*/  NOTMAPPED                                                                       +separator+                      
            /*	268	*/  NOTMAPPED                                                                       +separator+                      
            /*	269	*/  NOTMAPPED                                                                       +separator+                      
            /*	270	*/  NOTMAPPED                                                                       +separator+                      
            /*	271	*/  NOTMAPPED                                                                       +separator+                      
            /*	272	*/  NOTMAPPED                                                                       +separator+                      
            /*	273	*/  NOTMAPPED                                                                       +separator+                      
            /*	274	*/  NOTMAPPED                                                                       +separator+                      
            /*	275	*/  NOTMAPPED                                                                       +separator+                      
            /*	276	*/  NOTMAPPED                                                                       +separator+                      
            /*	277	*/  NOTMAPPED                                                                       +separator+                      
            /*	278	*/  NOTMAPPED                                                                       +separator+                      
            /*	279	*/  NOTMAPPED                                                                       +separator+                      
            /*	280	*/  NOTMAPPED                                                                       +separator+                      
            /*	281	*/  NOTMAPPED                                                                       +separator+                      
            /*	282	*/  NOTMAPPED                                                                       +separator+                      
            /*	283	*/  NOTMAPPED                                                                       +separator+                      
            /*	284	*/  NOTMAPPED                                                                       +separator+                      
            /*	285	*/  NOTMAPPED                                                                       +separator+                      
            /*	286	*/  NOTMAPPED                                                                       +separator+                      
            /*	287	*/  NOTMAPPED                                                                       +separator+                      
            /*	288	*/  NOTMAPPED                                                                       +separator+                      
            /*	289	*/  NOTMAPPED                                                                       +separator+                      
            /*	290	*/  NOTMAPPED                                                                       +separator+                      
            /*	291	*/  NOTMAPPED                                                                       +separator+                      
            /*	292	*/  NOTMAPPED                                                                       +separator+                      
            /*	293	*/  NOTMAPPED                                                                       +separator+                      
            /*	294	*/  NOTMAPPED                                                                       +separator+                      
            /*	295	*/  NOTMAPPED                                                                       +separator+                      
            /*	296	*/  NOTMAPPED                                                                       +separator+                      
            /*	297	*/  NOTMAPPED                                                                       +separator+                      
            /*	298	*/  NOTMAPPED                                                                       +separator+                      
            /*	299	*/  NOTMAPPED                                                                       +separator+                      
            /*	300	*/  NOTMAPPED                                                                       +separator+                      
            /*	301	*/  NOTMAPPED                                                                       +separator+                      
            /*	302	*/  NOTMAPPED                                                                       +separator+                      
            /*	303	*/  NOTMAPPED                                                                       +separator+                      
            /*	304	*/  NOTMAPPED                                                                       +separator+                      
            /*	305	*/  NOTMAPPED                                                                       +separator+                      
            /*	306	*/  NOTMAPPED                                                                       +separator+                      
            /*	307	*/  NOTMAPPED                                                                       +separator+                      
            /*	308	*/  NOTMAPPED                                                                       +separator+                      
            /*	309	*/  NOTMAPPED                                                                       +separator+                      
            /*	310	*/  NOTMAPPED                                                                       +separator+                      
            /*	311	*/  NOTMAPPED                                                                       +separator+                      
            /*	312	*/  NOTMAPPED                                                                       +separator+                      
            /*	313	*/  NOTMAPPED                                                                       +separator+                      
            /*	314	*/  NOTMAPPED                                                                       +separator+                      
            /*	315	*/  NOTMAPPED                                                                       +separator+                      
            /*	316	*/  NOTMAPPED                                                                       +separator+                      
            /*	317	*/  NOTMAPPED                                                                       +separator+                      
            /*	318	*/  NOTMAPPED                                                                       +separator+                      
            /*	319	*/  NOTMAPPED                                                                       +separator+                      
            /*	320	*/  NOTMAPPED                                                                       +separator+                      
            /*	321	*/  tempCase.CausalCode__c                                                          +separator+          
            /*	322	*/  NOTMAPPED                                                                       +separator+                      
            /*	323	*/  NOTMAPPED                                                                       +separator+                      
            /*	324	*/  NOTMAPPED                                                                       ;                  
            row = row.replaceAll('null', '');                                    
            
            if (String.isBlank(body)) {
                body=row;
            }
            else {
                body=body+'\n'+row; 
            }
        }
        return body;
    }
    
    public static String createBodySIE34_2SMEGas(String body,List<Case> listCaseGas ){
        
        for (Case tempCase : listCaseGas) {
            String name=String.isNotBlank(tempCase.FirstName__c)? ' ' +tempCase.FirstName__c:'';
            
            String row = 
            tempCase.CaseNumber                                                   +separator+                                  
            tempCase.CaseNumber                                                   +separator+                                  
            tempCase.CreatedDate                                                  +separator+                                   
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            tempCase.SubProcess__c                                                +separator+                                     
            tempCase.Account.CustomerCode__c                                      +separator+                                               
            tempCase.Account.LastName__c + name                                   +separator+                                                                        
            tempCase.Account.VATNumber__c                                         +separator+                                            
            tempCase.Account.FiscalCode__c                                        +separator+                                             
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            tempCase.Contact.MobilePhone                                          +separator+                                              
            tempCase.Contact.FAX                                                  +separator+                                      
            tempCase.Contact.Email                                                +separator+                                               
            tempCase.Contact.FirstName                                            +separator+                                         
            tempCase.Contact.LastName                                             +separator+                                        
            tempCase.Account.BillingStreetName__c                                 +separator+                                                    
            tempCase.Account.BillingStreetNumber__c                               +separator+                                                       
            tempCase.Account.BillingPostalCode                                    +separator+                                                  
            tempCase.Account.BillingCity                                          +separator+                                            
            tempCase.Account.BillingState                                         +separator+                                             
            tempCase.FirstName__c                                                 +separator+                                 
            tempCase.LastName__c                                                  +separator+                                
            NOTMAPPED                                                             +separator+                                                                                                                           
            tempCase.ComplaintEntryChannel__c                                     +separator+                                                
            NOTMAPPED                                                             +separator+                                        
            tempCase.ServicePoint__r.SupplyStreet__c                              +separator+                                                       
            tempCase.ServicePoint__r.SupplyStreetNumber__c                        +separator+                                                             
            tempCase.ServicePoint__r.SupplyPostalCode__c                          +separator+                                                           
            tempCase.ServicePoint__r.SupplyCity__c                                +separator+                                                     
            tempCase.ServicePoint__r.SupplyProvince__c                            +separator+                                                         
            tempCase.ServicePoint__r.SupplyCityCode__c                            +separator+                                                         
            tempCase.BillingProfile__r.InvoicingStreetName__c                     +separator+                                                             
            tempCase.BillingProfile__r.InvoicingStreetNumber__c                   +separator+                                                               
            tempCase.BillingProfile__r.InvoicingPostalCode__c                     +separator+                                                             
            tempCase.BillingProfile__r.InvoicingCity__c                           +separator+                                                       
            tempCase.BillingProfile__r.InvoicingProvince__c                       +separator+                                                           
            tempCase.BillingProfile__r.PaymentMethod__c                           +separator+                                                       
            tempCase.BillingProfile__r.PaymentMethod__c                           +separator+                                                       
            tempCase.BillingProfile__r.BankName__c                                +separator+                                                  
            tempCase.BillingProfile__r.BankAgency__c                              +separator+                                                    
            NOTMAPPED                                                             +separator+                                                 
            NOTMAPPED                                                             +separator+                                                 
            tempCase.BillingProfile__r.IbanCountry__c                             +separator+                                                     
            tempCase.BillingProfile__r.IbanCIN_IBAN__c                            +separator+                                                      
            tempCase.BillingProfile__r.IbanCIN__c                                 +separator+                                                 
            tempCase.BillingProfile__r.IbanABI__c                                 +separator+                                                 
            tempCase.BillingProfile__r.IbanCAB__c                                 +separator+                                                 
            tempCase.BillingProfile__r.IbanCodeNumber__c                          +separator+                                                        
            tempCase.BillingProfile__r.BankAccountSignatoryFirstName__c           +separator+                                                                       
            tempCase.BillingProfile__r.BankAccountSignatoryLastName__c            +separator+                                                                      
            tempCase.BillingProfile__r.BankAccountSignatoryFiscalCode__c          +separator+                                                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            tempCase.PODPDRFormula__c                                             +separator+                                        
            tempCase.CommodityFormula__c                                          +separator+                                           
            NOTMAPPED                                                             +separator+                                        
            tempCase.AnnualConsumption__c                                         +separator+                                            
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            tempCase.AtecoCode__c                                                 +separator+                                    
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            tempCase.DistributorCode__c                                           +separator+                                          
            tempCase.Distributor__c                                               +separator+                                      
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            tempCase.VATPercentage__c                                             +separator+                                        
            tempCase.Taxes__c                                                     +separator+                                
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            tempCase.Account.BillingStreetNumberExtension__c                      +separator+                                                               
            tempCase.Account.BillingPlace__c                                      +separator+                                               
            tempCase.ServicePoint__r.SupplyStreetNumberExtension__c               +separator+                                                                      
            tempCase.ServicePoint__r.SupplyPlace__c                               +separator+                                                      
            tempCase.BillingProfile__r.InvoicingStreetNumberExtension__c          +separator+                                                                        
            tempCase.BillingProfile__r.InvoicingPlace__c                          +separator+                                                        
            tempCase.BillingProfile__r.InvoicingAddressFormula__c                 +separator+                                                                 
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            tempCase.CreatedBy.Name                                               +separator+                                      
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                                  
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            tempCase.DistributorNote__c                                           +separator+                                          
            tempCase.PhoneNumber__c                                               +separator+                                      
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            tempCase.Disconnectable__c                                            +separator+                                         
            tempCase.DisconnectibilityType__c                                     +separator+                                                
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            tempCase.Account.Category__c                                          +separator+                                           
            tempCase.Mobile__c                                                    +separator+                                 
            tempCase.Account.CustomerType__c                                      +separator+                                               
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            tempCase.DisplacementDistance__c                                      +separator+                                               
            tempCase.Phase__c                                                     +separator+                                
            tempCase.QuotationNumber__c                                           +separator+                                          
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            tempCase.EndDate__c                                                   +separator+                                  
            tempCase.Amount__c                                                    +separator+                                 
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            tempCase.BillingProfile__r.BillSendingMethod__c                       +separator+                                                           
            tempCase.BillingProfile__r.InvoiceEmailAddress__c                     +separator+                                                             
            tempCase.Account.FirstName__c                                         +separator+                                         
            tempCase.BillingProfile__r.DivergentSubject__r.ContactCode__c         +separator+
            tempCase.BillingProfile__r.DivergentSubject__r.LastName               +separator+
            tempCase.BillingProfile__r.DivergentSubject__r.FirstName              +separator+
            tempCase.BillingProfile__r.DivergentSubject__r.FiscalCode__c          +separator+
            tempCase.BillingProfile__r.DivergentSubject__r.MailingStreetName__c   +separator+
            tempCase.BillingProfile__r.DivergentSubject__r.MailingStreetNumber__c +separator+
            NOTMAPPED                                                             +separator+                               
            tempCase.BillingProfile__r.DivergentSubject__r.MailingPostalCode      +separator+
            tempCase.BillingProfile__r.DivergentSubject__r.MailingCity            +separator+
            tempCase.BillingProfile__r.DivergentSubject__r.MailingState           +separator+                           
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            tempCase.BillingProfile__r.InvoiceCertifiedEmailAddress__c            +separator+                                                                      
            tempCase.BillingProfile__r.SendCertifiedEmailConsentDate__c           +separator+                                                                       
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            tempCase.SupplyType__c                                                +separator+                                     
            tempCase.Market__c                                                    +separator+                                 
            tempCase.OperationCode__c                                             +separator+                                        
            tempCase.QuotationType__c                                             +separator+                                        
            tempCase.Contract__r.ContractSalesCompany__c                          +separator+                                               
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            tempCase.CausalCode__c                                                +separator+                                     
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                             +separator+                                        
            NOTMAPPED                                                               ;              
            row = row.replaceAll('null', '');                                      
            
            if (String.isBlank(body)) {
                body=row;
            }
            else {
                body=body+'\n'+row; 
            }
        }
        return body;
    }
    public static String createBodySIE34_2MMEle(String body,List<Case> listCaseEle ){
        
        for (Case tempCase : listCaseEle) {   
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
            tempCase.BillingProfile__r.DivergentSubject__r.ContactCode__c                      +separator+
            tempCase.BillingProfile__r.DivergentSubject__r.LastName                            +separator+
            tempCase.BillingProfile__r.DivergentSubject__r.FirstName                           +separator+
            tempCase.BillingProfile__r.DivergentSubject__r.FiscalCode__c                       +separator+
            tempCase.BillingProfile__r.DivergentSubject__r.MailingStreetName__c                +separator+
            tempCase.BillingProfile__r.DivergentSubject__r.MailingStreetNumber__c              +separator+
            NOTMAPPED                                                                          +separator+                               
            tempCase.BillingProfile__r.DivergentSubject__r.MailingPostalCode                   +separator+
            tempCase.BillingProfile__r.DivergentSubject__r.MailingCity                         +separator+
            tempCase.BillingProfile__r.DivergentSubject__r.MailingState                        +separator+                                                                         
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
        return body;
    }
    
    public static String createBodySIE34_2MMGas(String body,List<Case> listCaseGas ){
        for (Case tempCase : listCaseGas) {
            String name=String.isNotBlank(tempCase.FirstName__c)?' ' + tempCase.FirstName__c:'';
            
            String row = 
            tempCase.CaseNumber                                                                        +separator+                                     
            tempCase.CaseNumber                                                                        +separator+                                     
            tempCase.CreatedDate                                                                       +separator+                                      
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            tempCase.Account.CustomerCode__c                                                           +separator+                                                  
            tempCase.Account.LastName__c + name                                                        +separator+                                                     
            tempCase.Account.VATNumber__c                                                              +separator+                                               
            tempCase.Account.FiscalCode__c                                                             +separator+                                                
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            tempCase.Contact.MobilePhone                                                               +separator+                                                 
            tempCase.Contact.Fax                                                                       +separator+                                         
            tempCase.Contact.Email                                                                     +separator+                                                  
            tempCase.Contact.FirstName                                                                 +separator+                                            
            tempCase.Contact.LastName                                                                  +separator+                                           
            tempCase.Account.BillingStreetName__c                                                      +separator+                                                       
            tempCase.Account.BillingStreetNumber__c                                                    +separator+                                                          
            tempCase.Account.BillingPostalCode                                                         +separator+                                                     
            tempCase.Account.BillingCity                                                               +separator+                                               
            tempCase.Account.BillingState                                                              +separator+                                                
            tempCase.FirstName__c                                                                      +separator+                                       
            tempCase.LastName__c                                                                       +separator+                                      
            NOTMAPPED                                                                                  +separator+                                    
            tempCase.ComplaintEntryChannel__c                                                          +separator+                                                   
            NOTMAPPED                                                                                  +separator+                                    
            tempCase.ServicePoint__r.SupplyStreet__c                                                   +separator+                                                          
            tempCase.ServicePoint__r.SupplyStreetNumber__c                                             +separator+                                                                
            tempCase.ServicePoint__r.SupplyPostalCode__c                                               +separator+                                                              
            tempCase.ServicePoint__r.SupplyCity__c                                                     +separator+                                                        
            tempCase.ServicePoint__r.SupplyProvince__c                                                 +separator+                                                            
            tempCase.ServicePoint__r.SupplyCityCode__c                                                 +separator+                                                            
            tempCase.BillingProfile__r.InvoicingStreetName__c                                          +separator+                                                                   
            tempCase.BillingProfile__r.InvoicingStreetNumber__c                                        +separator+                                                                     
            tempCase.BillingProfile__r.InvoicingPostalCode__c                                          +separator+                                                                   
            tempCase.BillingProfile__r.InvoicingCity__c                                                +separator+                                                             
            tempCase.BillingProfile__r.InvoicingProvince__c                                            +separator+                                                                 
            tempCase.BillingProfile__r.PaymentMethod__c                                                +separator+                                                             
            tempCase.BillingProfile__r.PaymentMethod__c                                                +separator+                                                             
            tempCase.BillingProfile__r.BankName__c                                                     +separator+                                                        
            tempCase.BillingProfile__r.BankAgency__c                                                   +separator+                                                          
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            tempCase.BillingProfile__r.IbanCountry__c                                                  +separator+                                                           
            tempCase.BillingProfile__r.IbanCIN_IBAN__c                                                 +separator+                                                            
            tempCase.BillingProfile__r.IbanCIN__c                                                      +separator+                                                       
            tempCase.BillingProfile__r.IbanABI__c                                                      +separator+                                                       
            tempCase.BillingProfile__r.IbanCAB__c                                                      +separator+                                                       
            tempCase.BillingProfile__r.IbanCodeNumber__c                                               +separator+                                                              
            tempCase.BillingProfile__r.BankAccountSignatoryFirstName__c                                +separator+                                                                             
            tempCase.BillingProfile__r.BankAccountSignatoryLastName__c                                 +separator+                                                                            
            tempCase.BillingProfile__r.BankAccountSignatoryFiscalCode__c                               +separator+                                                                              
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            tempCase.PODPDRFormula__c                                                                  +separator+                                           
            tempCase.CommodityFormula__c                                                               +separator+                                              
            NOTMAPPED                                                                                  +separator+                                    
            tempCase.AnnualConsumption__c                                                              +separator+                                               
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            tempCase.AtecoCode__c                                                                      +separator+                                       
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            tempCase.DistributorCode__c                                                                +separator+                                             
            tempCase.Distributor__c                                                                    +separator+                                         
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            tempCase.VATPercentage__c                                                                  +separator+                                           
            tempCase.Taxes__c                                                                          +separator+                                   
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            tempCase.Account.BillingStreetNumberExtension__c                                           +separator+                                                                  
            tempCase.Account.BillingPlace__c                                                           +separator+                                                  
            tempCase.ServicePoint__r.SupplyStreetNumberExtension__c                                    +separator+                                                                         
            tempCase.ServicePoint__r.SupplyPlace__c                                                    +separator+                                                         
            tempCase.BillingProfile__r.InvoicingStreetNumberExtension__c                               +separator+                                                                              
            tempCase.BillingProfile__r.InvoicingPlace__c                                               +separator+                                                              
            tempCase.BillingProfile__r.InvoicingAddressFormula__c                                      +separator+                                                                       
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            tempCase.CreatedBy.Name                                                                    +separator+                                         
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            tempCase.DistributorNote__c                                                                +separator+                                             
            tempCase.PhoneNumber__c                                                                    +separator+                                         
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            tempCase.Disconnectable__c                                                                 +separator+                                            
            tempCase.DisconnectibilityType__c                                                          +separator+                                                   
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            tempCase.Account.Category__c                                                               +separator+                                              
            tempCase.Mobile__c                                                                         +separator+                                    
            tempCase.Account.CustomerType__c                                                           +separator+                                                  
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            tempCase.DisplacementDistance__c                                                           +separator+                                                  
            tempCase.Phase__c                                                                          +separator+                                   
            tempCase.QuotationNumber__c                                                                +separator+                                             
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            tempCase.EndDate__c                                                                        +separator+                                     
            tempCase.Amount__c                                                                         +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            tempCase.BillingProfile__r.BillSendingMethod__c                                            +separator+                                                                 
            tempCase.BillingProfile__r.InvoiceEmailAddress__c                                          +separator+                                                                   
            tempCase.Account.FirstName__c                                                              +separator+                                            
            tempCase.BillingProfile__r.DivergentSubject__r.ContactCode__c                              +separator+
            tempCase.BillingProfile__r.DivergentSubject__r.LastName                                    +separator+
            tempCase.BillingProfile__r.DivergentSubject__r.FirstName                                   +separator+
            tempCase.BillingProfile__r.DivergentSubject__r.FiscalCode__c                               +separator+
            tempCase.BillingProfile__r.DivergentSubject__r.MailingStreetName__c                        +separator+
            tempCase.BillingProfile__r.DivergentSubject__r.MailingStreetNumber__c                      +separator+
            NOTMAPPED                                                                                  +separator+                               
            tempCase.BillingProfile__r.DivergentSubject__r.MailingPostalCode                           +separator+
            tempCase.BillingProfile__r.DivergentSubject__r.MailingCity                                 +separator+
            tempCase.BillingProfile__r.DivergentSubject__r.MailingState                                +separator+                                                             
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            tempCase.BillingProfile__r.InvoiceCertifiedEmailAddress__c                                 +separator+                                                                            
            tempCase.BillingProfile__r.SendCertifiedEmailConsentDate__c                                +separator+                                                                             
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            tempCase.SupplyType__c                                                                     +separator+                                        
            tempCase.Market__c                                                                         +separator+                                    
            tempCase.OperationCode__c                                                                  +separator+                                           
            tempCase.QuotationType__c                                                                  +separator+                                           
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            tempCase.CausalCode__c                                                                     +separator+                                        
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                  +separator+                                    
            NOTMAPPED                                                                                       ;
            row = row.replaceAll('null', '');  
            
            if (String.isBlank(body)) {
                body=row;
            }
            else {
                body=body+'\n'+row; 
            }
        }
        
        return body;
    }
    
}
