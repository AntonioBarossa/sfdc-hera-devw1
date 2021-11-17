public with sharing class HDT_BA_AttributesLead implements Database.Batchable<SObject>, Database.Stateful,Database.AllowsCallouts {
	
	
	public String runId;
	public String status;
	public String errorMessage;
	public Integer fileNumber;
	public List<Id> listIdContentVersion = new List<Id>();
	public Set<String> setEmailContactProcessed = new Set<String>();
	
	
	public HDT_BA_AttributesLead(String paramRunId){
		this.runId = paramRunId;
		this.fileNumber=0;
		
	}
	
	public Database.QueryLocator start(Database.BatchableContext bc) {
		String query ='SELECT id,ContactReason__c,Status,CreatedDate,InterestArea__c,Rating,Email,(SELECT id,Lead__c,ContactId,Contact.Email,Contact.CreatedDate,Lead__r.email,ClientCategory__c,EarlyRecess__c,ServiceEnergy__c,Market__c,Outcome__c,Phase__c,Reason,SalesCompany__c,ServicePoint__c,Status,SupplyType__c,Type FROM Cases__r)FROM lead WHERE  (email !=null OR  email!=\'\') AND (IsConverted=false)AND Status!=\'Expired\'  ORDER BY Email,CreatedDate';
		return Database.getQueryLocator(query);
	}
	
	public void execute(Database.BatchableContext bc, List<Lead> scope) {
		Map<String, Lead> mapLeadByEmail       = new Map<String, Lead>();
		Map<String, Contact> mapContactByEmail = new Map<String, Contact>();
		List<Contact> listContacts             = new List<Contact>();
		status='success';
		
		Map<String, String> mapApiNameToAttribute = new Map<String, String>{'email'=>'email',
		'contactAgeGroup'=>'Fascia d\'età','contactCompany'=>'Società Company Owner','contactCompanyOwner'=>'Company Owner','leadContactReason'=>'leadContactReason','leadInterestArea'=>'leadInterestArea',
		'leadRating'=>'leadRating','leadStatus'=>'leadStatus','billingProfileBillSendingMethod'=>'Modalità invio bolletta','billingProfilepaymentMethod'=>'Modalità pagamento','billingProfileStatus'=>'Status del Profilo',
		'caseClientCategory'=>'Case_Categoria Cliente','caseEarlyRecess'=>'Case_Recesso Anticipato','caseEnergyService'=>'Case_Servizio Energia','caseMarket'=>'Case_Mercato',
		'caseOutcome'=>'Case_Esito','casePhase'=>'Case_Fase','caseReason'=>'Case_Motivo','caseSalesCompany'=>'Case_Società di Vendita','caseServicePoint'=>'Case_Fornitura','caseStatus'=>'Case_Status',
		'caseSupplyType'=>'Case_Tipo fornitura','caseType'=>'Case_Tipo','contractActivatedDate'=>'Data Inizio Contratto','contractCustomerSignedDate'=>'Data Firma Contratto', 'contractEndDate'=>'Data Cessazione Contratto',
		'contractEstimatedEndDate'=>'Data Stimata Fine Contratto','contractRecordType'=>'Commodity Contratto', 'contractStatus'=>'Stato Contratto','orderPhase'=>'Order_Fase',
		'orderRecordTypeId'=>'orderRecordTypeId','orderStatus'=>'Order_Status','orderType'=>'Order_Tipo','servicePointCommoditySector'=>'Settore Merceologico','accountChurnRisk'=>'Account_ChurnRisk',
		'accountCustomerLifeCycleStatus'=>'Account_CustomerLifeCycles','accountCustomerQuality'=>'Account_Customer Quality'};
		
		try {
			
			// logica duplicati start
			for (Lead tempLead : scope) {
				
				if (mapLeadByEmail.get(tempLead.Email)==null) {
					mapLeadByEmail.put(tempLead.Email, tempLead);
				}
				
				else {
					Lead actualLead=mapLeadByEmail.get(tempLead.Email);
					if ( tempLead.CreatedDate>actualLead.CreatedDate) {
						mapLeadByEmail.put(tempLead.Email, tempLead);
					}
				}
			}
			// logica duplicati end
			
			
			// controllo se sono presenti contact con la stessa email dei lead che sto processando
			if (!mapLeadByEmail.isEmpty()) {
				listContacts = [SELECT id,Company__c,CompanyOwner__c,Account.ChurnkRiskCtrl__c ,Email,CreatedDate,
				(SELECT id,Contact__c,Contact__r.Email,BillSendingMethod__c,PaymentMethod__c,Status__c FROM BillingProfiles__r),
				(SELECT id,ContactId,Contact.Email,Contact.CreatedDate,ClientCategory__c,EarlyRecess__c,ServiceEnergy__c,Market__c,Outcome__c,Phase__c,Reason,SalesCompany__c,ServicePoint__c,Status,SupplyType__c,Type FROM Cases),
				(SELECT id,Contact__c,Contact__r.Email,Contact__r.CreatedDate,ActivatedDate,CustomerSignedDate,EndDate,EstimatedEndDate__c,Status FROM Contract__r),
				(SELECT id,Contact__c,Contact__r.Email,Phase__c,RecordTypeId,Status,Type,ServicePoint__r.CommoditySector__c FROM Orders__r) FROM Contact  WHERE  Email IN:mapLeadByEmail.keySet() ORDER BY Email,CreatedDate ]; 	
			}
			
			
			// logica duplicati Contact start
			for (Contact tempContact : listContacts) {
				
				if (mapContactByEmail.get(tempContact.Email)==null) {
					mapContactByEmail.put(tempContact.Email, tempContact);
				}
				else {
					Contact actualContact=mapContactByEmail.get(tempContact.Email);
					
					if (actualContact!=null && tempContact.CreatedDate>actualContact.CreatedDate) {
						mapContactByEmail.put(tempContact.Email, tempContact);
					}
				}
				setEmailContactProcessed.add(tempContact.email);
			}
			// logica duplicati Contact end
			
			
			
			List<Lead> listLeadNotInChunk = [SELECT id,ContactReason__c,CreatedDate,InterestArea__c,Rating,Status,Email,
			(SELECT id,ContactId,Contact.Email,Lead__c,Lead__r.email,ClientCategory__c,EarlyRecess__c,EnergyService__c,Market__c,Outcome__c,Phase__c,Reason,SalesCompany__c,
			ServicePoint__c,Status,SupplyType__c,Type FROM Cases__r)
			FROM lead
			WHERE (IsConverted=false)AND Status !='Expired' AND (Email IN:mapLeadByEmail.keySet() AND Email NOT IN:setEmailContactProcessed  AND Id NOT IN :mapLeadByEmail.values())  ORDER BY Email,CreatedDate];
			
			if (listLeadNotInChunk!=null && !listLeadNotInChunk.isEmpty()) {	
				for (Lead tempLead : listLeadNotInChunk) {
					Lead actualLead=mapLeadByEmail.get(tempLead.Email);
					if ( mapLeadByEmail.get(tempLead.Email)!=null &&(tempLead.CreatedDate>actualLead.CreatedDate)) {
						mapLeadByEmail.remove(tempLead.Email);
					}
				}
			}
			
			if (!setEmailContactProcessed.isEmpty()) {
				mapLeadByEmail.keySet().removeAll(setEmailContactProcessed); 
			}
			
			
			List<BillingProfile__c> listBillingProfile  = new List<BillingProfile__c>();
			List<Case> listCase                         = new List<Case>();
			List<Order> listOrder                       = new List<Order>();
			List<Contract> listContract                 = new List<Contract>();
			
			Map<String, HDT_WRP_Attributes> mapEmailAttributes = new Map<String,HDT_WRP_Attributes>(); 
			
			for (Lead tempLead : mapLeadByEmail.values()) {
				listCase.addAll(tempLead.Cases__r);
				if (mapEmailAttributes.get(tempLead.Email)==null) {
					HDT_WRP_Attributes att= new HDT_WRP_Attributes();
					att.email               = tempLead.Email;
					att.leadInterestArea    = tempLead.InterestArea__c;
					att.leadRating          = tempLead.Rating;
					att.leadStatus          = tempLead.Status;
					att.leadContactReason   = tempLead.ContactReason__c;
					
					mapEmailAttributes.put(tempLead.Email, att);
				}
			/*	else {
					HDT_WRP_Attributes actualAtt=mapEmailAttributes.get(tempLead.Email);
					
					actualAtt.leadInterestArea    = String.isNotBlank(tempLead.InterestArea__c)? actualAtt.leadInterestArea+','+tempLead.InterestArea__c:actualAtt.leadInterestArea;
					actualAtt.leadRating          = String.isNotBlank(String.valueOf(tempLead.Rating))? actualAtt.leadRating+','+String.valueOf(tempLead.Rating):actualAtt.leadRating;
					actualAtt.leadStatus          = String.isNotBlank(tempLead.Status)? actualAtt.leadStatus+','+tempLead.Status:actualAtt.leadStatus;
					actualAtt.leadContactReason   = String.isNotBlank(tempLead.ContactReason__c)? actualAtt.leadContactReason+','+tempLead.ContactReason__c:actualAtt.leadContactReason;
					
					
					
					mapEmailAttributes.put(tempLead.Email, actualAtt);
					
				}*/
				
			}
			
			for (Contact tempContact: mapContactByEmail.values()) {
				listBillingProfile.addAll(tempContact.BillingProfiles__r);
				listCase.addAll(tempContact.cases);
				listContract.addAll(tempContact.Contract__r);
				listOrder.addAll(tempContact.Orders__r);
				
				if (mapEmailAttributes.get(tempContact.Email)==null) {
					HDT_WRP_Attributes att= new HDT_WRP_Attributes();
					att.email=tempContact.Email;
					att.contactCompany=tempContact.Company__c;
					att.contactCompanyOwner=tempContact.CompanyOwner__c;
					att.accountChurnRisk=tempContact.Account.ChurnkRiskCtrl__c ;
					mapEmailAttributes.put(tempContact.Email, att);
				}
			/*	else {
					HDT_WRP_Attributes actualAtt=mapEmailAttributes.get(tempContact.Email);
					actualAtt.contactCompany=String.isNotBlank(tempContact.Company__c)? actualAtt.contactCompany+','+tempContact.Company__c:actualAtt.contactCompany;
					actualAtt.accountChurnRisk=String.isNotBlank(tempContact.Account.ChurnkRiskCtrl__c )? actualAtt.accountChurnRisk+','+tempContact.Account.ChurnkRiskCtrl__c :actualAtt.accountChurnRisk;
					mapEmailAttributes.put(tempContact.Email, actualAtt);
					
				}*/
				
			}
			
			for (Case tempCase : listCase) {
				String email=String.isNotBlank(tempCase.ContactId)?tempCase.Contact.Email:tempCase.Lead__r.email;
				
				// se l'attributo nella classe wrapper non è vuoto, 
				// controllo se l'attributo del case corrente tempCase,se questo non è blank aggiungo att=att+,+attributo del case corrente 
				// se l'attributo del case corrente è vuoto non aggiungo niente
				
				HDT_WRP_Attributes actualAtt=mapEmailAttributes.get(email);
				actualAtt.caseClientCategory  = String.isNotBlank(actualAtt.caseClientCategory)? String.isNotBlank(tempCase.ClientCategory__c               ) ? actualAtt.caseClientCategory+','+tempCase.ClientCategory__c                  :   actualAtt.caseClientCategory:tempCase.ClientCategory__c                 ;                  
				actualAtt.caseEarlyRecess     = String.isNotBlank(actualAtt.caseEarlyRecess   )? String.isNotBlank(String.valueOf(tempCase.EarlyRecess__c)  ) ? actualAtt.caseEarlyRecess   +','+String.valueOf(tempCase.EarlyRecess__c)     :   actualAtt.caseEarlyRecess   :String.valueOf(tempCase.EarlyRecess__c)    ;            
				actualAtt.caseEnergyService   = String.isNotBlank(actualAtt.caseEnergyService )? String.isNotBlank(tempCase.ServiceEnergy__c                ) ? actualAtt.caseEnergyService +','+tempCase.ServiceEnergy__c                   :   actualAtt.caseEnergyService :tempCase.ServiceEnergy__c                  ;                
				actualAtt.caseMarket          = String.isNotBlank(actualAtt.caseMarket        )? String.isNotBlank(tempCase.Market__c                       ) ? actualAtt.caseMarket        +','+tempCase.Market__c                          :   actualAtt.caseMarket        :tempCase.Market__c                         ;  
				actualAtt.caseOutcome         = String.isNotBlank(actualAtt.caseOutcome       )? String.isNotBlank(tempCase.Outcome__c                      ) ? actualAtt.caseOutcome       +','+tempCase.Outcome__c                         :   actualAtt.caseOutcome       :tempCase.Outcome__c                        ;    
				actualAtt.casePhase           = String.isNotBlank(actualAtt.casePhase         )? String.isNotBlank(tempCase.Phase__c                        ) ? actualAtt.casePhase         +','+tempCase.Phase__c                           :   actualAtt.casePhase         :tempCase.Phase__c                          ;
				actualAtt.caseReason          = String.isNotBlank(actualAtt.caseReason        )? String.isNotBlank(tempCase.Reason                          ) ? actualAtt.caseReason        +','+tempCase.Reason                             :   actualAtt.caseReason        :tempCase.Reason                            ;
				actualAtt.caseSalesCompany    = String.isNotBlank(actualAtt.caseSalesCompany  )? String.isNotBlank(tempCase.SalesCompany__c                 ) ? actualAtt.caseSalesCompany  +','+tempCase.SalesCompany__c                    :   actualAtt.caseSalesCompany  :tempCase.SalesCompany__c                   ;             
				actualAtt.caseServicePoint    = String.isNotBlank(actualAtt.caseServicePoint  )? String.isNotBlank(tempCase.ServicePoint__c                 ) ? actualAtt.caseServicePoint  +','+tempCase.ServicePoint__c                    :   actualAtt.caseServicePoint  :tempCase.ServicePoint__c                   ;             
				actualAtt.caseStatus          = String.isNotBlank(actualAtt.caseStatus        )? String.isNotBlank(tempCase.Status                          ) ? actualAtt.caseStatus        +','+tempCase.Status                             :   actualAtt.caseStatus        :tempCase.Status                            ;
				actualAtt.caseSupplyType      = String.isNotBlank(actualAtt.caseSupplyType    )? String.isNotBlank(tempCase.SupplyType__c                   ) ? actualAtt.caseSupplyType    +','+tempCase.SupplyType__c                      :   actualAtt.caseSupplyType    :tempCase.SupplyType__c                     ;         
				actualAtt.caseType            = String.isNotBlank(actualAtt.caseType          )? String.isNotBlank(tempCase.Type                            ) ? actualAtt.caseType          +','+tempCase.Type                               :   actualAtt.caseType          :tempCase.Type                              ;
				mapEmailAttributes.put(email, actualAtt);                                                          
			}
			
			for (BillingProfile__c tempBill : listBillingProfile) {
				
				HDT_WRP_Attributes actualAtt=mapEmailAttributes.get(tempBill.Contact__r.Email);
				actualAtt.billingProfileBillSendingMethod= String.isNotBlank(actualAtt.billingProfileBillSendingMethod)? String.isNotBlank(tempBill.BillSendingMethod__c ) ? actualAtt.billingProfileBillSendingMethod+','+tempBill.BillSendingMethod__c : actualAtt.billingProfileBillSendingMethod : tempBill.BillSendingMethod__c ;                  
				actualAtt.billingProfilepaymentMethod    = String.isNotBlank(actualAtt.billingProfilepaymentMethod)    ? String.isNotBlank(tempBill.PaymentMethod__c )     ? actualAtt.billingProfilepaymentMethod+','+tempBill.PaymentMethod__c         : actualAtt.billingProfilepaymentMethod     : tempBill.PaymentMethod__c     ;   
				actualAtt.billingProfileStatus           = String.isNotBlank(actualAtt.billingProfileStatus)           ? String.isNotBlank(tempBill.Status__c )            ? actualAtt.billingProfileStatus+','+tempBill.Status__c                       : actualAtt.billingProfileStatus            : tempBill.Status__c            ;   
				mapEmailAttributes.put(tempBill.Contact__r.Email, actualAtt);                                                          
				
			}
			for (Contract tempCont : listContract) {
				
				HDT_WRP_Attributes actualAtt=mapEmailAttributes.get(tempCont.Contact__r.Email);
				actualAtt.contractActivatedDate      = String.isNotBlank(actualAtt.contractActivatedDate        )? String.isNotBlank(String.valueOf(tempCont.ActivatedDate))       ? actualAtt.contractActivatedDate+','+String.valueOf(tempCont.ActivatedDate)             : actualAtt.contractActivatedDate      : String.valueOf(tempCont.ActivatedDate)         ;
				actualAtt.contractCustomerSignedDate = String.isNotBlank(actualAtt.contractCustomerSignedDate   )? String.isNotBlank(String.valueOf(tempCont.CustomerSignedDate))  ? actualAtt.contractCustomerSignedDate+','+String.valueOf(tempCont.CustomerSignedDate)   : actualAtt.contractCustomerSignedDate : String.valueOf(tempCont.CustomerSignedDate)    ;
				actualAtt.contractEndDate            = String.isNotBlank(actualAtt.contractEndDate              )? String.isNotBlank(String.valueOf(tempCont.EndDate))             ? actualAtt.contractEndDate+','+String.valueOf(tempCont.EndDate)                         : actualAtt.contractEndDate            : String.valueOf(tempCont.EndDate)               ;
				actualAtt.contractEstimatedEndDate   = String.isNotBlank(actualAtt.contractEstimatedEndDate     )? String.isNotBlank(String.valueOf(tempCont.EstimatedEndDate__c)) ? actualAtt.contractEstimatedEndDate+','+String.valueOf(tempCont.EstimatedEndDate__c)    : actualAtt.contractEstimatedEndDate   : String.valueOf(tempCont.EstimatedEndDate__c)   ;
				mapEmailAttributes.put(tempCont.Contact__r.Email, actualAtt);                                                          
				
			}
			for (Order tempOrd : listOrder) {
				
				
				HDT_WRP_Attributes actualAtt=mapEmailAttributes.get(tempOrd.Contact__r.Email);
				actualAtt.orderPhase                   = String.isNotBlank(actualAtt.orderPhase)                 ? String.isNotBlank(tempOrd.Phase__c)                           ? actualAtt.orderPhase+','+tempOrd.Phase__c                                            : actualAtt.orderPhase                 : tempOrd.Phase__c                           ;
				actualAtt.orderStatus                  = String.isNotBlank(actualAtt.orderStatus)                ? String.isNotBlank(tempOrd.Status)                             ? actualAtt.orderStatus+','+tempOrd.Status                                             : actualAtt.orderStatus                : tempOrd.Status                             ;
				actualAtt.orderType                    = String.isNotBlank(actualAtt.orderType)                  ? String.isNotBlank(tempOrd.Type)                               ? actualAtt.orderType+','+tempOrd.Type                                                 : actualAtt.orderType                  : tempOrd.Type                               ;
				actualAtt.orderRecordTypeId            = String.isNotBlank(actualAtt.orderRecordTypeId)          ? String.isNotBlank(tempOrd.RecordTypeId)                       ? actualAtt.orderRecordTypeId+','+tempOrd.RecordTypeId                                 : actualAtt.orderRecordTypeId          : tempOrd.RecordTypeId                       ;
				actualAtt.servicePointCommoditySector  = String.isNotBlank(actualAtt.servicePointCommoditySector)? String.isNotBlank(tempOrd.ServicePoint__r.CommoditySector__c) ? actualAtt.servicePointCommoditySector+','+tempOrd.ServicePoint__r.CommoditySector__c : actualAtt.servicePointCommoditySector: tempOrd.ServicePoint__r.CommoditySector__c ;
				mapEmailAttributes.put(tempOrd.Contact__r.Email, actualAtt);                                                          
				
			}
			String row='';
			//•	hem:sha256:9db2bf00d1232d1b331daebcd8c8b86e33d8a30f858700d2a585ea0263f57931^gender:male;age:18-24;interest:fishing
			
			for (HDT_WRP_Attributes tempWrp : mapEmailAttributes.values()) {
				row=String.isBlank(row)?row:row+'\n';
				String codeRow='hem:sha256:'+HDT_UTL_Utils.codingSha256(tempWrp.email)+'^';
				row=row+codeRow;

				if (String.isNotBlank(tempWrp.leadStatus)) {
					row = row+mapApiNameToAttribute.get('leadStatus')+':'+tempWrp.leadStatus+';';
				}
				if (String.isNotBlank(tempWrp.contactCompany)) {
					row = row+mapApiNameToAttribute.get('contactCompany')+':'+tempWrp.contactCompany+';';
				}
				if (String.isNotBlank(tempWrp.caseStatus)) {
					row = row+mapApiNameToAttribute.get('caseStatus')+':'+tempWrp.caseStatus+';';
				}
				if (String.isNotBlank(tempWrp.contactCompanyOwner)) {
					row = row+mapApiNameToAttribute.get('contactCompanyOwner')+':'+tempWrp.contactCompanyOwner+';';
				}
				if (String.isNotBlank(tempWrp.leadContactReason)) {
					row = row+mapApiNameToAttribute.get('leadContactReason')+':'+tempWrp.leadContactReason+';';
				}
				if (String.isNotBlank(tempWrp.leadInterestArea)) {
					
					if (';'.equalsIgnoreCase(tempWrp.leadInterestArea.substring(tempWrp.leadInterestArea.length()-1,tempWrp.leadInterestArea.length() )) ) {
						tempWrp.leadInterestArea=tempWrp.leadInterestArea.removeEndIgnoreCase(';');
					}
					row = row+mapApiNameToAttribute.get('leadInterestArea')+':'+tempWrp.leadInterestArea.replace(';', ',');
						
				}
				if (String.isNotBlank(tempWrp.leadRating)) {
					row = row+mapApiNameToAttribute.get('leadRating')+':'+tempWrp.leadRating+';';
				}
				if (String.isNotBlank(tempWrp.billingProfileBillSendingMethod)) {
					row = row+mapApiNameToAttribute.get('billingProfileBillSendingMethod')+':'+tempWrp.billingProfileBillSendingMethod+';';
				}
				if (String.isNotBlank(tempWrp.billingProfilepaymentMethod)) {
					row = row+mapApiNameToAttribute.get('billingProfilepaymentMethod')+':'+tempWrp.billingProfilepaymentMethod+';';
				}
				if (String.isNotBlank(tempWrp.billingProfileStatus)) {
					row = row+mapApiNameToAttribute.get('billingProfileStatus')+':'+tempWrp.billingProfileStatus+';';
				}
				if (String.isNotBlank(tempWrp.caseClientCategory)) {
					row = row+mapApiNameToAttribute.get('caseClientCategory')+':'+tempWrp.caseClientCategory+';';
				}
				if (String.isNotBlank(tempWrp.caseEarlyRecess)) {
					row = row+mapApiNameToAttribute.get('caseEarlyRecess')+':'+tempWrp.caseEarlyRecess+';';
				}
				if (String.isNotBlank(tempWrp.caseEnergyService)) {
					row = row+mapApiNameToAttribute.get('caseEnergyService')+':'+tempWrp.caseEnergyService+';';
				}
				if (String.isNotBlank(tempWrp.caseMarket)) {
					row = row+mapApiNameToAttribute.get('caseMarket')+':'+tempWrp.caseMarket+';';
				}
				if (String.isNotBlank(tempWrp.caseOutcome)) {
					row = row+mapApiNameToAttribute.get('caseOutcome')+':'+tempWrp.caseOutcome+';';
				}
				if (String.isNotBlank(tempWrp.casePhase)) {
					row = row+mapApiNameToAttribute.get('casePhase')+':'+tempWrp.casePhase+';';
				}
				if (String.isNotBlank(tempWrp.caseReason)) {
					row = row+mapApiNameToAttribute.get('caseReason')+':'+tempWrp.caseReason+';';
				}
				if (String.isNotBlank(tempWrp.caseSalesCompany)) {
					row = row+mapApiNameToAttribute.get('caseSalesCompany')+':'+tempWrp.caseSalesCompany+';';
				}
				if (String.isNotBlank(tempWrp.caseServicePoint)) {
					row = row+mapApiNameToAttribute.get('caseServicePoint')+':'+tempWrp.caseServicePoint+';';
				}
				if (String.isNotBlank(tempWrp.caseStatus)) {
					row = row+mapApiNameToAttribute.get('caseStatus')+':'+tempWrp.caseStatus+';';
				}
				if (String.isNotBlank(tempWrp.caseSupplyType)) {
					row = row+mapApiNameToAttribute.get('caseSupplyType')+':'+tempWrp.caseSupplyType+';';
				}
				if (String.isNotBlank(tempWrp.caseType)) {
					row = row+mapApiNameToAttribute.get('caseType')+':'+tempWrp.caseType+';';
				}
				if (String.isNotBlank(tempWrp.contractActivatedDate)) {
					row = row+mapApiNameToAttribute.get('contractActivatedDate')+':'+tempWrp.contractActivatedDate+';';
				}
				if (String.isNotBlank(tempWrp.contractCustomerSignedDate)) {
					row = row+mapApiNameToAttribute.get('contractCustomerSignedDate')+':'+tempWrp.contractCustomerSignedDate+';';
				}
				if (String.isNotBlank(tempWrp.contractEndDate)) {
					row = row+mapApiNameToAttribute.get('contractEndDate')+':'+tempWrp.contractEndDate+';';
				}
				if (String.isNotBlank(tempWrp.contractEstimatedEndDate)) {
					row = row+mapApiNameToAttribute.get('contractEstimatedEndDate')+':'+tempWrp.contractEstimatedEndDate+';';
				}
				if (String.isNotBlank(tempWrp.contractRecordType)) {
					row = row+mapApiNameToAttribute.get('contractRecordType')+':'+tempWrp.contractRecordType+';';
				}
				if (String.isNotBlank(tempWrp.contractStatus)) {
					row = row+mapApiNameToAttribute.get('contractStatus')+':'+tempWrp.contractStatus+';';
				}
				if (String.isNotBlank(tempWrp.orderPhase)) {
					row = row+mapApiNameToAttribute.get('orderPhase')+':'+tempWrp.orderPhase+';';
				}
				if (String.isNotBlank(tempWrp.orderRecordTypeId)) {
					row = row+mapApiNameToAttribute.get('orderRecordTypeId')+':'+tempWrp.orderRecordTypeId+';';
				}
				if (String.isNotBlank(tempWrp.orderStatus)) {
					row = row+mapApiNameToAttribute.get('orderStatus')+':'+tempWrp.orderStatus+';';
				}
				if (String.isNotBlank(tempWrp.orderType)) {
					row = row+mapApiNameToAttribute.get('orderType')+':'+tempWrp.orderType+';';
				}
				if (String.isNotBlank(tempWrp.servicePointCommoditySector)) {
					row = row+mapApiNameToAttribute.get('servicePointCommoditySector')+':'+tempWrp.servicePointCommoditySector+';';
				}
				if (String.isNotBlank(tempWrp.accountChurnRisk)) {
					row = row+mapApiNameToAttribute.get('accountChurnRisk')+':'+tempWrp.accountChurnRisk+';';
				}
				if (String.isNotBlank(tempWrp.accountCustomerLifeCycleStatus)) {
					row = row+mapApiNameToAttribute.get('accountCustomerLifeCycleStatus')+':'+tempWrp.accountCustomerLifeCycleStatus+';';
				}
				if (String.isNotBlank(tempWrp.accountCustomerQuality)) {
					row = row+mapApiNameToAttribute.get('accountCustomerQuality')+':'+tempWrp.accountCustomerQuality+';';
				}
				//row.removeEnd(';');
				Integer indexSep  = row.lastIndexOf(';');
				Integer indexSepAtt  = row.lastIndexOf('^');
				Integer rowLenght = row.length();
				if ((indexSep+1)==rowLenght) {
					 row=row.substring(0, indexSep);
				}
				if ((indexSepAtt+1)==rowLenght) {
					 row=row.replace('\n'+codeRow, '');
				}

		
			}
			if (String.isNotBlank(row)) {
				Blob generateFileBlob = Blob.valueof(row);
				ContentVersion cv = new ContentVersion();
				cv.ContentLocation = 'S';
				cv.VersionData = generateFileBlob;
				Date runDate= Date.today();
				// il nome heradmp_firstpartydata_ potrebbe essere reso dinamico 
				cv.Title = 'heradmp_firstpartydata_'+String.valueOf( runDate.year())+String.valueOf( runDate.month())+String.valueOf( runDate.day())+'_'+String.valueOf(fileNumber);
				cv.PathOnClient = 'heradmp_firstpartydata_'+String.valueOf( runDate.year())+String.valueOf( runDate.month())+String.valueOf( runDate.day())+'_'+String.valueOf(fileNumber)+'.csv';
				insert cv;
				this.fileNumber=this.fileNumber+1;
				listIdContentVersion.add(cv.Id);
			}
			
		}
		catch (Exception e) {
			status='failed';
			errorMessage=e.getMessage();
		}
		
	}
	
	public void finish(Database.BatchableContext bc){
		HDT_BA_AttributesContact attrContact = new HDT_BA_AttributesContact(fileNumber,runId,status,errorMessage,listIdContentVersion,setEmailContactProcessed); 
		Database.executeBatch(attrContact,1000);
		
	}
	
}