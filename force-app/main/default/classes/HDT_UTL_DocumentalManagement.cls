@SuppressWarnings('PMD.AvoidDebugStatements, PMD.ExcessiveParameterList, PMD.ExcessiveClassLength, PMD.CyclomaticComplexity, PMD.ExcessivePublicCount, PMD.AvoidDeeplyNestedIfStmts, PMD.NcssMethodCount')
public inherited sharing class HDT_UTL_DocumentalManagement {
	public static List<Map<String,List<sObject>>> getRecordObjectsList(List<SObject> recordsList, String context){
		/*
			@Author: Davide Viola - 20/10/2021
			Description: PMD -> Commentata variabile non utilizzata.
		*/
		//List<Map<String,List<sObject>>> toReturn = new List<Map<String,List<sObject>>>();
		switch on context {
			when 'Context1' {
				return getRecordObjectsListContext1(recordsList);
			}
			when 'Context2'{
				return getRecordObjectsListContext2(recordsList);
			}
			when 'Context3'{
				return getRecordObjectsListContext3(recordsList);
			}
			when 'Context4'{
				return getRecordObjectsListContext4(recordsList);
			}
			when 'Context5'{
				return getRecordObjectsListContext1(recordsList);
			}
			when else {
				return null;
			}
		}
	}
	public static ContentVersion createContectVersion(String base64, String filename){
		ContentVersion cv = new ContentVersion();
		cv.VersionData = EncodingUtil.base64Decode(base64);
		cv.Title = filename;
		cv.PathOnClient = filename + '.pdf';
		cv.ContentLocation = 'S';
		try {
			//Sostituire con HDT_UTL_DatabaseService.insertSObject()
			HDT_UTL_DatabaseService.insertSObject(cv);
			return cv;
		} catch(DMLException e) {
			System.debug(LoggingLevel.DEBUG, e);
			return null;
		}
	}

	public static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
		if (contentVersionId == null || recordId == null) { return null; }
		ContentDocumentLink cdl = new ContentDocumentLink();
		cdl.ContentDocumentId = [
			SELECT ContentDocumentId 
			FROM ContentVersion 
			WHERE Id =: contentVersionId
		].ContentDocumentId;
		cdl.LinkedEntityId = recordId;
		// ShareType is either 'V', 'C', or 'I'
		// V = Viewer, C = Collaborator, I = Inferred
		cdl.ShareType = 'V';
		try {
			HDT_UTL_DatabaseService.insertSObject(cdl);
			return cdl;
		} catch(DMLException e) {
			System.debug(LoggingLevel.DEBUG, e);
			return null;
		}
	}
	private static String getSharedLink(String cdId){
		if (cdId == null) { return null; }
		String queryString = 'SELECT Id,DistributionPublicUrl FROM ContentDistribution WHERE Id = \''+cdId+'\'';
		try {
			List<SObject> recordList = HDT_QR_GenericQuery.getGenericRecords(queryString, 'ContentDistribution');
			ContentDistribution cd = (ContentDistribution)recordList[0];
			return cd.DistributionPublicUrl;
		} catch (Exception e) {
			System.debug(LoggingLevel.DEBUG, e);
			return null;
		}
		
	}

	public static String createContentDistribution(String contentVersionId,String fileName){
		if (contentVersionId == null) { return null; }
		ContentDistribution cd = new ContentDistribution();
		cd.Name = fileName;
		cd.ContentVersionId = contentVersionId;
		cd.PreferencesAllowViewInBrowser= true;
		cd.PreferencesLinkLatestVersion=true;
		cd.PreferencesNotifyOnVisit=true;
		cd.PreferencesPasswordRequired=false;
		cd.PreferencesAllowOriginalDownload= true;
		try {
			HDT_UTL_DatabaseService.insertSObject(cd);
			return getSharedLink(cd.Id);
		} catch(DMLException e) {
			System.debug(LoggingLevel.DEBUG, e);
			return null;
		}
	}
	
	public static void createDocumentEnvelopeAttachment(HDT_WRP_DocumentalResponse response, String context){
		
		//DEBUG
		String debugString = 'HDT_UTL_DocumentalManagement - createDocumentEnvelopeAttachment';
		System.debug(LoggingLevel.DEBUG, debugString);
		
		try {
			String recordId;
			List<HDT_WRP_DocumentalResponse.HDT_WRP_DocumentalResponseAttachment> attachmentList = new List<HDT_WRP_DocumentalResponse.HDT_WRP_DocumentalResponseAttachment>();
			List<HDT_WRP_DocumentalResponse.HDT_WRP_DocumentalResponseServiceItem> serviceItemList = new List<HDT_WRP_DocumentalResponse.HDT_WRP_DocumentalResponseServiceItem>();
			serviceItemList.addAll(response.deliverPackageResponse.serviceList);
			
			List<DocumentalEnvelopeAttachment__c> envelopeList = new List<DocumentalEnvelopeAttachment__c>();
			List<Order> orderList = new List<Order>();
			Set<String> serviceItemSet = new Set<String>();
			Map<String,Id> processNumberIdMap = new Map<String,Id>();
			for(HDT_WRP_DocumentalResponse.HDT_WRP_DocumentalResponseServiceItem serviceItem : serviceItemList){
				serviceItemSet.add(serviceItem.serviceId);
			}
			List<SObject> processRecods = HDT_QR_DocumentalConfiguration.getRecordFromServiceItems(context, serviceItemSet);
			for(SObject singleRecord : processRecods){
				if(context.equalsIgnoreCase('Case')){
					processNumberIdMap.put((String)singleRecord.get('CaseNumber'), (Id)singleRecord.get('Id'));
				}else{
					processNumberIdMap.put((String)singleRecord.get('OrderNumber'), (Id)singleRecord.get('Id'));
				}
			}
			for(HDT_WRP_DocumentalResponse.HDT_WRP_DocumentalResponseServiceItem serviceItem : serviceItemList){
				recordId = (Id) processNumberIdMap.get(serviceItem.serviceId);
				for(HDT_WRP_DocumentalResponse.HDT_WRP_DocumentalResponseAttachment singleAttachment : serviceItem.attachmentList){
					DocumentalEnvelopeAttachment__c envelope = new DocumentalEnvelopeAttachment__c();
					envelope.AttachmentCode__c = singleAttachment.code;
					envelope.Required__c = singleAttachment.mandatory == '1'? true:false;
					envelope.IsDocusignSpecialTemplate__c = singleAttachment.signature == '1'? true:false;
					envelope.Version__c = singleAttachment.version;
					if(context.equalsIgnoreCase('Case')){
						envelope.Case__c = recordId;
					}else if(context.equalsIgnoreCase('Order')){
						envelope.Order__c = recordId;
						if(String.isNotBlank(singleAttachment.code) && singleAttachment.code.indexOf('CGC') > -1){
							Order singleOrder = new Order();
							singleOrder.Id = recordId;
							singleOrder.GeneralContractConditions__c = singleAttachment.code;
							orderList.add(singleOrder);
						}
					}
					envelopeList.add(envelope);
				}
			}
			
			if(envelopeList.size()>0){
				Boolean result = HDT_UTL_DatabaseService.insertSObject(envelopeList);
				System.debug(LoggingLevel.DEBUG, debugString + ' - result: '+ result);
			}
			if(orderList.size()>0){
				Boolean resultOrder = HDT_UTL_DatabaseService.updateSObject(orderList);
				System.debug(LoggingLevel.DEBUG, debugString + ' - resultOrder: '+ resultOrder);
			}
			
		} catch (Exception ex) {
			System.debug(LoggingLevel.DEBUG, 'Error in class HDT_UTL_DocumentalManagement method createDocumentEnvelopeAttachment at line' + ex.getLineNumber() + '. Error: '+ ex.getMessage());
		}
	}

	private static Boolean isSignNeeded(HDT_WRP_DocumentalResponse response){
		List<HDT_WRP_DocumentalResponse.HDT_WRP_DocumentalResponseAttachment> attachmentList = new List<HDT_WRP_DocumentalResponse.HDT_WRP_DocumentalResponseAttachment>();
		attachmentList.addAll(response.deliverPackageResponse.serviceList[0].attachmentList);
		for(HDT_WRP_DocumentalResponse.HDT_WRP_DocumentalResponseAttachment singleAttachment : attachmentList){
			if(singleAttachment.mandatory == '1'){
				return true;
			}
		}
		return false;
	}
	public static Boolean updateDocumentalPhase(SObject processRecord, HDT_WRP_DocumentalResponse response,String context){
		String archive = response.deliverPackageResponse.archive;
		String result = response.deliverPackageResponse.result;
		String cluster = '';
		String quotationType = '';
		Boolean isMassive = false;
		String signatureMethod = '';
		String signMode='';
		if(context.equalsIgnoreCase('Order')){
			isMassive = (Boolean) processRecord.get('isMassive__c');
		}
		if(result == '000'){
			if(archive != 'Y'){
				processRecord.put('DocumentalPhase__c','Preview');
			}else{
				if(isSignNeeded(response)){
					processRecord.put('DocumentalPhase__c','Plico in firma');
				}else {
					processRecord.put('DocumentalPhase__c','Plico inviato');
				}
				
				if(context.equalsIgnoreCase('Case')){
					signMode = (String) processRecord.get('SignMode__c');
					cluster = (String) processRecord.get('Cluster__c');
					quotationType = (String) processRecord.get('QuotationType__c');
					if(cluster.equalsIgnoreCase('Preventivi') && String.isNotBlank(quotationType) && quotationType.equalsIgnoreCase('Predeterminabile')){
						processRecord.put('Phase__c','Attesa conferma preventivo cliente');
					}
				} else {
					signMode = (String) processRecord.get('SignatureMethod__c');
				}
				// Oltre alla DocusignExpirationDate__c, settiamo anche il campo DocusignExpirationDate__c se necessario.
			
				if (signMode != null && signMode.containsIgnoreCase('OTP')) {
					List<CS_DaysToExpiration__c> daysToExpiration = [SELECT NumberOfDays__c FROM CS_DaysToExpiration__c WHERE Type__c='BustaDocusign' WITH SECURITY_ENFORCED];
					if (!daysToExpiration.isEmpty()) {
						Integer numberOfDays = Integer.valueOf(daysToExpiration[0].NumberOfDays__c);
						if (numberOfDays > 0) {
							Date expirationDate = Date.today().addDays(numberOfDays);
							processRecord.put('DocusignExpirationDate__c', expirationDate);
						}
					}
				}
				if(isMassive){
					signatureMethod = (String) processRecord.get('SignatureMethod__c');
					if(!signatureMethod.equalsIgnoreCase('Contratto già firmato')){
						processRecord.put('Phase__c', 'Documentazione da inviare');
					}
				}
			}
		}else {
			processRecord.put('DocumentalPhase__c','Errore composizione');
			if(isMassive){
				processRecord.put('Phase__c', 'Comunicazione EngageOne KO');
			}
		}
		return HDT_UTL_DatabaseService.updateSObject(processRecord);
	}
	
	//SObject processRecord = HDT_UTL_DocumentalManagement.getProcessRecord((String) response.deliverPackageResponse.requestId, context);
	public static SObject getProcessRecord(String requestId, String context){
		String fieldString = '';
		String fromString = '';
		String whereString = '';
		String queryString = 'SELECT ';
		switch on context {
			when 'Order','DocumentazioneAnticipata' {
				fieldString = 'Id, AccountId,DocSendingMethod__c,Email__c,ShippingMail__c,SignMode__c,DocumentalPhase__c,Cluster__c,Phase__c,isMassive__c,SignatureMethod__c';
				fromString = 'Order';
				whereString = ' OrderNumber = \''+requestId + '\'';
			}
			when 'Case'{
				fieldString = 'Id, AccountId,SendMode__c, Email__c,SignMode__c,DocumentalPhase__c,Cluster__c,QuotationType__c';
				fromString = 'Case';
				whereString = ' CaseNumber = \''+requestId + '\'';
			}
			when else {
				fieldString = 'Id,PrimaryEmail__c,SendMode__c,LastUsedPostelEmail__c';
				fromString = 'Account';
				whereString = 'Id = \''+requestId + '\'';
			}
		}
		queryString += fieldString + ' FROM ' + fromString + ' WHERE ' + whereString;
		System.debug(LoggingLevel.DEBUG, 'Query: ' + queryString);
		List<sObject> toReturnList = HDT_QR_GenericQuery.getGenericRecords(queryString, fromString);
		return toReturnList[0];
	}
	
	public static void createDocumentSendTracking(String message, Id requestId, String envelopeId, SObject processRecord){
		try {
			String sObjName = requestId.getSObjectType().getDescribe().getName();
			DocumentSendTracking__c documentalSendTracking = new DocumentSendTracking__c ();
			
			switch on sObjName {
				when 'Case' {
					documentalSendTracking.Case__c = (Id) requestId;
					System.debug(LoggingLevel.DEBUG, '### Account Id: '+processRecord.get('AccountId'));
					documentalSendTracking.Account__c = (Id) processRecord.get('AccountId');
					documentalSendTracking.Receiver__c = (String) processRecord.get('Email__c');
					documentalSendTracking.SendMode__c = (String) processRecord.get('SendMode__c');
					documentalSendTracking.Type__c = 'Plico';
				}
				when 'Order','DocumentazioneAnticipata' {
					documentalSendTracking.Order__c = (Id) requestId;
					documentalSendTracking.Account__c = (Id) processRecord.get('AccountId');
					documentalSendTracking.SendMode__c = (String) processRecord.get('DocSendingMethod__c');
					documentalSendTracking.Receiver__c = (String) processRecord.get('ShippingMail__c');
					documentalSendTracking.Type__c = 'Plico Contrattuale';
				}
				when else {
					documentalSendTracking.Account__c = (Id) processRecord.get('Id');
					documentalSendTracking.SendMode__c = (String) processRecord.get('SendMode__c');
					documentalSendTracking.Receiver__c = (String) processRecord.get('LastUsedPostelEmail__c');
					documentalSendTracking.Type__c = 'Estratto Conto';
				}
			}
			
			documentalSendTracking.SendDate__c = Date.today();
			documentalSendTracking.EnvelopeId__c = envelopeId;
			/*
				@Author: Davide Viola - 20/10/2021
				Description: PMD -> Commentata variabile non utilizzata.
			*/
			/*Boolean result = */HDT_UTL_DatabaseService.insertSObject(documentalSendTracking);
			
		} catch (Exception ex) {
			System.debug(LoggingLevel.DEBUG, 'Errore nella classe HDT_UTL_DocumentalManagement metodo createDocumentSendTracking ' + ex.getMessage() + ' at line ' + ex.getLineNumber());
		}
	}
	public static void createDocumentalActivityForError(String errorMessage, Id requestId, String envelopeId,SObject processRecord){
		String activityType;
		if ('35'.equals(errorMessage)){
			errorMessage = 'Indirizzo Email non valido.';
			activityType = 'Busta Docusign non consegnata';
			try{
				String sObjName = requestId.getSObjectType().getDescribe().getName();
				wrts_prcgvr__Activity__c activityBusta = new wrts_prcgvr__Activity__c ();
				Id actRecordTypeId = Schema.SObjectType.wrts_prcgvr__Activity__c.getRecordTypeInfosByDeveloperName().get('HDT_RT_Scarto').getRecordTypeId();
				String conditionById = '';
				switch on sObjName {
					when 'Case' {
						activityBusta.Case__c = (Id) requestId;
						conditionById = 'Case__c = \''+requestId+'\'';
					}
					when 'Order' {
						conditionById = 'Order__c = \''+requestId+'\'';
						activityBusta.Order__c = (Id) requestId;
					}
				}
				activityBusta.RecordTypeId=actRecordTypeId;
				activityBusta.wrts_prcgvr__Description__c='Indirizzo Email non valido.';
				activityBusta.DiscardCategory__c = 'Scarto complesso';
				activityBusta.Type__c=activityType;
				List<wrts_prcgvr__Activity__c> actToUpdate = String.isBlank(conditionById)? 
					new List<wrts_prcgvr__Activity__c>() :
					HDT_QR_GenericQuery.getGenericRecords('Id, wrts_prcgvr__Status__c', 'wrts_prcgvr__Activity__c', 'Type__c = \''+activityType+'\' AND wrts_prcgvr__IsClosed__c = false AND ' + conditionById);
				if (actToUpdate.isEmpty()){
					HDT_UTL_DatabaseService.insertSObject(activityBusta);
				}
			} catch (Exception ex) {
				System.debug(LoggingLevel.DEBUG, 'Errore nella classe HDT_UTL_DocumentalManagement metodo createDocumentalActivityForError ' + ex.getMessage() + ' at line ' + ex.getLineNumber());
			}
		}else{
			try {
				String sObjName = requestId.getSObjectType().getDescribe().getName();
				DocumentalActivity__c documentalActivity = new DocumentalActivity__c ();
				switch on sObjName {
					when 'Case' {
						documentalActivity.CaseId__c = (Id) requestId;
						//System.debug(LoggingLevel.DEBUG, '### Account Id: '+processRecord.get('AccountId'));
					}
					when 'Order' {
						documentalActivity.OrderId__c = (Id) requestId;
					}
				}
				documentalActivity.EnvelopeId__c = envelopeId;
				documentalActivity.ErrorDescription__c = String.isNotBlank(errorMessage) ? errorMessage : 'Errore Firma OTP';
				documentalActivity.ActivityType__c = activityType;
				/*
					@Author: Davide Viola - 20/10/2021
					Description: PMD -> Commentata variabile non utilizzata.
				*/
				/*Boolean result = */HDT_UTL_DatabaseService.insertSObject(documentalActivity);
			} catch (Exception ex) {
				System.debug(LoggingLevel.DEBUG, 'Errore nella classe HDT_UTL_DocumentalManagement metodo createDocumentalActivityForError ' + ex.getMessage() + ' at line ' + ex.getLineNumber());
			}
		}

	}
	
	public static DocumentalActivity__c initDocumentalActivity(sObject parentRecord,String envelopeId){
		DocumentalActivity__c documentalActivity = new DocumentalActivity__c ();
		try {
			Id requestId = (Id) parentRecord.get('Id');
			String sObjName = requestId.getSObjectType().getDescribe().getName();
			switch on sObjName {
				when 'Case' {
					documentalActivity.CaseId__c =  requestId;
				}
				when 'Order' {
					documentalActivity.OrderId__c = requestId;
				}
			}
			documentalActivity.EnvelopeId__c = envelopeId;
			documentalActivity.ReturnDate__c = Date.today();
		} catch (Exception ex) {
			System.debug(LoggingLevel.DEBUG, 'Errore nella classe HDT_UTL_DocumentalManagement metodo createDocumentalActivity ' + ex.getMessage() + ' at line ' + ex.getLineNumber());
		}
		return documentalActivity;
	}
	
	public static void createLandRegistryData(Id requestId,sObject processRecord){
		try {
			String sObjName = requestId.getSObjectType().getDescribe().getName();
			if (sObjName != 'Order'){
				System.debug(LoggingLevel.DEBUG, 'Necessario passare un Order per procedere con la creazione dei dati catastali.');
				return;
			}

			// TODO DLM

		} catch (Exception ex) {
			System.debug(LoggingLevel.DEBUG, 'Errore nella classe HDT_UTL_DocumentalManagement metodo createLandRegistryData ' + ex.getMessage() + ' at line ' + ex.getLineNumber());
		}
	}
	private static List<Map<String,List<sObject>>> getRecordObjectsListContext2(List<SObject> recordsList){
		Case caseObject = (Case) recordsList[0];
		Account accountObject = (Account) caseObject.Account;
		Contact contactObject = (Contact) caseObject.Contact;
		List<DocumentSelected__c> documentSelectedObjectList = (List<DocumentSelected__c> ) caseObject.documenti_selezionati__r;
		List<sObject> listCase = new List<sObject>();
		listCase.add(caseObject);
		System.debug(LoggingLevel.DEBUG, 'listCase ' + listCase);
		List<sObject> listAccount = new List<sObject>();
		listAccount.add(accountObject);
		List<sObject> listContact = new List<sObject>();
		listContact.add(contactObject);
		Map<String,List<sObject>> mapStringObjectRecords = new Map<String,List<sObject>>{
			'Case' => listCase, 'Account' => listAccount, 'PrimaryContact' => listContact, 'DocumentSelected' => documentSelectedObjectList
		};
		List<Map<String,List<sObject>>> toReturn = new List<Map<String,List<sObject>>>();
		toReturn.add(mapStringObjectRecords);
		return toReturn;
	}

	private static List<Map<String,List<sObject>>> getRecordObjectsListContext3(List<SObject> recordsList){
		
		List<Account> listAccount = new List<Account>();
		Account accountObject = (Account) recordsList[0];
		listAccount.add(accountObject);

		List<Case> listCase = (List<Case>) accountObject.Cases;
		List<Order> listOrder = (List<Order>) accountObject.Orders;
		List<BillingProfile__c> listBp = (List<BillingProfile__c>) accountObject.BillingProfiles__r;
		
		List<AccountContactRelation> listAccContRel = (List<AccountContactRelation>) accountObject.AccountContactRelations;
		List<Contact> listContact = new List<Contact>();
		for(AccountContactRelation accConRel : listAccContRel){
			listContact.add(accConRel.Contact);
		}
		
		Map<String,List<sObject>> mapStringObjectRecords = new Map<String,List<sObject>>{
			'CaseList' => listCase,'OrderList' => listOrder, 'Account' => listAccount, 'ContactList' => listContact, 'BillingProfileList' => listBp, 'AccountContactRelationList' => listAccContRel
		};
		List<Map<String,List<sObject>>> toReturn = new List<Map<String,List<sObject>>>();
		toReturn.add(mapStringObjectRecords);
		return toReturn;
	} 

	private static List<Map<String,List<sObject>>> getRecordObjectsListContext4(List<SObject> recordsList){
		Account accountObject = (Account) recordsList[0];
		List<sObject> listAccount = new List<sObject>();
		listAccount.add(accountObject);
		Map<String,List<sObject>> mapStringObjectRecords = new Map<String,List<sObject>>{
			'Account' => listAccount
		};
		List<Map<String,List<sObject>>> toReturn = new List<Map<String,List<sObject>>>();
		toReturn.add(mapStringObjectRecords);
		return toReturn;
	}

	
	//Restituisce una lista in cui, per ogni order è presente una mappa dove sono stati suddivisi per tipologia i record inseriti indistintamente in recordsList.
	private static List<Map<String,List<sObject>>> getRecordObjectsListContext1(List<SObject> recordsList){
		
		List<Map<String,List<sObject>>> toReturn = new List<Map<String,List<sObject>>>();
		Map<String,List<sObject>> mapStringObjectRecords = new Map<String,List<sObject>>();
		
		for(Order singleOrder : (List<Order>) recordsList){
			mapStringObjectRecords = new Map<String,List<sObject>>();
			
			List<OrderItem> orderItemList = new List<OrderItem>();
			List<OrderItem> orderItemVasList = new List<OrderItem>();
			
			//USER
			User seller = (User) singleOrder.SaleBy__r;
			List<User> userList = new List<User>();
			userList.add(seller);
			mapStringObjectRecords.put('Seller', userList);
			
			//ACCOUNT
			Account account = (Account) singleOrder.Account;
			List<Account> accountList = new List<Account>();
			accountList.add(account);
			mapStringObjectRecords.put('Account', accountList);
			
			//CONTACT
			Contact contact = (Contact) singleOrder.Contact__r;
			List<Contact> contactList = new List<Contact>();
			contactList.add(contact);
			mapStringObjectRecords.put('PrimaryContact', contactList);
			
			//PARENT ORDER
			Order parentOrder = (Order) singleOrder.ParentOrder__r;
			List<sObject> parentOrderList = new List<sObject>();
			parentOrderList.add(parentOrder);
			mapStringObjectRecords.put('ParentOrder', parentOrderList);
			
			//SINGLE ORDER
			List<sObject> orderList = new List<sObject>();
			orderList.add(singleOrder);
			mapStringObjectRecords.put('Order', orderList);
			
			//PROCESSING ORDER ITEMS
			for(OrderItem singleOrderItem : (List<OrderItem>) singleOrder.OrderItems){
				orderItemList = new List<OrderItem>();
				String family = singleOrderItem.ProductFamily__c;
				if(family == 'Offerta commerciale'){
					orderItemList.add(singleOrderItem);
					mapStringObjectRecords.put('ItemCommercialOffer', orderItemList);
				}else if(family == 'VAS Prodotto' || family == 'VAS Servizio'){
					orderItemList.add(singleOrderItem);
					mapStringObjectRecords.put('ParentItemVAS', orderItemList);
				}else if(family.equalsIgnoreCase('VAS Opzione servizio') || family.equalsIgnoreCase('VAS Opzione prodotto') || family.equalsIgnoreCase('VAS Fatturabili')){
					orderItemVasList.add(singleOrderItem);
					mapStringObjectRecords.put('ItemVAS', orderItemVasList);
				}else if(family.indexOf('Bonus') > -1){
					orderItemList.add(singleOrderItem);
					mapStringObjectRecords.put('ItemBonus', orderItemList);
				}else if(family.indexOf('Promozione') > -1){
					orderItemList.add(singleOrderItem);
					mapStringObjectRecords.put('ItemPromotion', orderItemList);
				}
			}
			
			toReturn.add(new Map<String,List<sObject>>(mapStringObjectRecords));
		}
		
		return toReturn;
	}
	
	//estrae Body da Documento (con Name = context) e lo formatta come HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalStructure
	public static HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalStructure getDocumentalConfiguration(String context){
		List<Document> documentList = HDT_QR_DocumentalConfiguration.getDocumentByContext(context);
		HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalStructure configuration;
		configuration = (HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalStructure) JSON.deserialize(documentList[0].body.toString(), HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalStructure.class);
		return configuration;
	}

  public static String manageAmountDot(String valString){
		String res = valString;
		Integer df = valString.indexOf('.');
		String intero = '';
		if(df>=0){
			if(df==0){
				intero='0';
			}else{
				intero=valString.substring(0,df);
			}
			String dec=valString.substring(df+1,valString.length());
			if(dec.length()==1){
				dec=dec+'0';
			}
			res=intero+','+dec;
		}
		else{
			if(valString=='' || valString == null){
				valString='0';
			}
			res = valString+',00';
		}
		
		return res;
	}

  
	public static String removeSpecialChar (String text){
		text = text.replaceAll('[à]','a\'');
		text = text.replaceAll('[èé]','e\'');
		text = text.replaceAll('[ì]','i\'');
		text = text.replaceAll('[ò]','o\'');
		text = text.replaceAll('[ù]','u\'');
		text = text.replaceAll('\r\n',' ');
		text = text.replaceAll('\n\r',' ');
		text = text.replaceAll('[ì]','i\'');
		text = text.replaceAll('À','A\'');
		text = text.replaceAll('Á','A\'');
		text = text.replaceAll('Ù','U\'');
		text = text.replaceAll('Ú','U\'');
		text = text.replaceAll('Ó','O\'');
		text = text.replaceAll('Ò','O\'');
		text = text.replaceAll('È','E\'');
		text = text.replaceAll('É','E\'');
		text = text.replaceAll('Ì','I\'');
		text = text.replaceAll('Í','I\'');
		text = text.replaceAll('[’‘“”]','\'');
		text = text.replaceAll('·', '-');
		text = text.replaceAll('\u00A0', ' '); // 00A0 = carattere unicode "No-Break Space"
		text = text.replaceAll('\u2026', '...'); // 2026 = carattere unicode "horizontal ellipsis"

		return text;
	}
	
	public static String transformDate(Date dateObj) {
		DateTime dt = DateTime.newInstance(dateObj.year(), dateObj.month(),dateObj.day());
		String dateStr = dt.format('dd/MM/yyyy');
		return dateStr;
	}

	public static String getValueFromMethod(String classString, String method, Map<String,List<sObject>> inputs,Map<String,Object> formParams){
		HDT_UTL_DocumentalManagementInterface support = HDT_UTL_DocumentalManagementFactory.getInstance(classString);
		return support.execute(method,inputs,formParams);
	}
	public static Integer getChildCount(String objectString, Map<String,List<sObject>> inputs){
		return inputs.get(objectString)?.size();
	}
	public static String getValue(String objectString, String fieldString, Integer index, Map<String,List<sObject>> inputs, Map<String,Object> formParams){
    String retVal = '';
		try {
			if(inputs.get(objectString) != null && inputs.get(objectString).size()>0 && inputs.get(objectString)[0] != null){
				if(inputs.get(objectString)[index].get(fieldString) != null){
					retVal = String.valueOf(inputs.get(objectString)[index].get(fieldString));
				}
			}else if(objectString.equalsIgnoreCase('FormParameters') && formParams != null && formParams.get(fieldString) != null){
				retVal = String.valueOf(formParams.get(fieldString));
			}
		} catch (Exception ex) {
			System.debug(LoggingLevel.DEBUG, objectString + ' ' + fieldString +' '+ index + ' '+ ex.getMessage() + ' at Line:' + ex.getLineNumber());
		}
    return retVal;
  }
	public static String getValueFromObject(Map<String,List<sObject>> inputs, HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalRecord singleRecord, Integer index,Map<String,Object> formParams){
		String result = '';
		if(singleRecord.object1 != null && singleRecord.object1 != '' && singleRecord.field1 != null){
      result = getValue(singleRecord.object1, singleRecord.field1, index, inputs, formParams);
		}

		if(result == '' && singleRecord.object2 != null && singleRecord.object2 != '' && singleRecord.field2 != null){
			result = getValue(singleRecord.object2, singleRecord.field2, index, inputs, formParams);
		}

		if(result == '' && singleRecord.object3 != null && singleRecord.object3 != '' && singleRecord.field3 != null){
      result = getValue(singleRecord.object3, singleRecord.field3, index, inputs, formParams);
		}
		if(result == '' && singleRecord.object4 != null && singleRecord.object4 != '' && singleRecord.field4 != null){
      result = getValue(singleRecord.object4, singleRecord.field4, index, inputs, formParams);
		}

		if(result != null && result != ''){
			if(singleRecord.isData != null && singleRecord.isData == 'Y' ){
				try {
					Date dateObj = Date.valueOf(result);
					result = transformDate(dateObj);
				} catch (Exception ex) {
					System.debug(LoggingLevel.DEBUG, 'Attenzione! Rimuovere flag is data nella sezione' + singleRecord.recordType);
				}
			}else if(singleRecord.manageAmount != null && singleRecord.manageAmount == 'Y'){
				result = manageAmountDot(result);
			}
		}
		return result;
	}
	
	public static String getConcatValueFromObject(Map<String,List<sObject>> inputs,HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalRecord singleRecord){
		String resultOne = '';
		String resultTwo = '';
		if(singleRecord.object1 != null && singleRecord.object1 != ''){
			resultOne = getValue(singleRecord.object1,singleRecord.field1,0,inputs,null);
		}
		if(resultOne != null && resultOne != '' && singleRecord.object2 != null && singleRecord.object2 != ''){
			resultTwo += getValue(singleRecord.object2,singleRecord.field2,0,inputs,null);
		}
		if(singleRecord.separetor == 'space'){
			return resultOne + ' ' + resultTwo;
		} else {
			return resultOne + singleRecord.separetor + resultTwo;
		}
	}

	public static String calculateExpression(Map<String,List<sObject>> inputs,String expression, Map<String,Object> formParams){
		String[] expressionArray = new List<String>();
		String objectCondition = '';
		String fieldCondition = '';
		String[] fieldArray = new List<String>();
		String[] objectField1 = new List<String>();
		String[] objectField2 = new List<String>();
		String propValue = '';
		String operatore = '';
		String condizione = '';
		String result = '';
		String resultTwo = '';
		String resultToReturn = '';
		String jolly = '';
		Integer i = 0;
		
		//System.debug(LoggingLevel.DEBUG, 'expression ' + expression);
    	expressionArray = expression.split('\\|');
		
		//System.debug(LoggingLevel.DEBUG, 'expressionArray ' + expressionArray);
		try{
			if(expressionArray.size()>0){
				while(i<expressionArray.size()){
					fieldArray = new List<String>();
					objectField1 = new List<String>();
					objectField2 = new List<String>();
					jolly = expressionArray[i++];
					fieldArray = expressionArray[i++].split('\\.');
					operatore = expressionArray[i++];
					condizione = expressionArray[i++];
					result = expressionArray[i++];
					resultTwo = expressionArray[i++];
					
					objectCondition = fieldArray[0];
					fieldCondition = fieldArray[1];
					
					if(result.indexOf('.')>-1){
						objectField1 = result.split('\\.');
						/*if(inputs.get(objectField1[0]) != null && inputs.get(objectField1[0]).size()>0){
							if(inputs.get(objectField1[0])[0].get(objectField1[1]) != null){
								result = String.valueOf(inputs.get(objectField1[0])[0].get(objectField1[1]));
							}
						}*/
						result = getValue(objectField1[0],objectField1[1],0,inputs,formParams);
					}
				
					if(resultTwo.indexOf('.')>-1){
						objectField2 = resultTwo.split('\\.');
						/*if(inputs.get(objectField2[0]) != null && inputs.get(objectField2[0]).size()>0){
							if(inputs.get(objectField2[0])[0].get(objectField2[1]) != null){
								result = String.valueOf(inputs.get(objectField2[0])[0].get(objectField2[1]));
							}
						}*/
						result = getValue(objectField2[0],objectField2[1],0,inputs,formParams);
					}
					if(inputs.get(objectCondition) != null && inputs.get(objectCondition).size() > 0 && inputs.get(objectCondition)[0].get(fieldCondition) != null){
						propValue = String.valueOf(inputs.get(objectCondition)[0].get(fieldCondition));
					}
					if(operatore == '='){
						if(propValue == condizione){
							resultToReturn = result;
							break;
						}
					}else if(operatore == '<>'){
						if(propValue != condizione){
							resultToReturn = result;
							break;
						}
					}else if(operatore == '<'){
						Integer propValueInt = Integer.valueOf(propValue);
						Integer condizioneInt = Integer.valueOf(condizione);
						if(propValueInt < condizioneInt){
							resultToReturn = result;
							break;
						}
					}else if(operatore == '>'){
						/*
							@Author: Davide Viola - 20/10/2021
							Description: PMD -> Commentate variabili non utilizzate.
						*/
						/*Integer propValueInt = Integer.valueOf(propValue);
						Integer condizioneInt = Integer.valueOf(condizione);*/
						if(propValue > condizione){
							resultToReturn = result;
							break;
						}
					}else if(operatore == 'LIKE'){
						if(propValue.indexOf(condizione)>-1){
							resultToReturn = result;
							break;
						}
					}else{
						break;
					}
					if(resultTwo != 'ELSE'){
						if(resultTwo.equalsIgnoreCase('noValue')){
							resultToReturn = '';
						}
						resultToReturn = resultTwo;
						break;
					}
				}
				if(resultToReturn == 'sysdate'){
					Date today = Date.today();
					resultToReturn = transformDate(today);
				}
				if(resultToReturn == 'noValue'){
					resultToReturn = '';
				}
			}
		}catch(Exception ex){
			System.debug(LoggingLevel.DEBUG, 'for expressione '+expression + ' ' + ex.getMessage() + ' ' + ex.getLineNumber());
		}
		
    	return resultToReturn;
	}
	
	public static String getDocumentalContext(String context){
		switch on context {
			when 'Order' {
				return 'Context1';
			}
			when 'Case' {
				return 'Context2';
			}
			when 'EC' {
				return 'Context4';
			}
			when 'GC' {
				return 'Context4';
			}
			when 'Account' {
				return 'Context3';
			}
			when 'DocumentazioneAnticipata'{
				return 'Context4';
			}
			when else {
				return null;
			}
		}
	}
	
	// Calcola lo Stato Documento da mandare a EngageOne per le stampe della vista Gestione Credito.
	public static String calculateDocumentStatusGc(String ufficioIncassi, Double residuo, Boolean ordineDiPagamento){
		String statoDocumento = '';
		try {
			// Verifichiamo se l'ufficio incassi è valorizzato con un BP.
			// Di solito un BP inizia sempre con 100.
			if (ufficioIncassi == '' || ufficioIncassi.substring(0, 3) == '100') {
				if (residuo > 0) {
					if (ordineDiPagamento) {
						statoDocumento = 'Pagato';
					} else {
						statoDocumento = 'Da pagare';
					}
				} else if (residuo < 0) {
					if (ordineDiPagamento) {
						statoDocumento = 'Accreditato';
					} else {
						statoDocumento = 'Da accreditare';
					}
				}
			} else {
				switch on ufficioIncassi{
					when 'BANCASIST1','CESSPASALV', 'CESSPASAL1', 'BANCASIST2', 'BANCASIST3', 'BANCASIST4', 'BANCAFFCT0', 'BANCASIST5', 'BANCAFFCT1', 'BANCASIST6', 'BANCAFFCT2', 'BANCASIST7', 'BANCAFFCT3'{
						statoDocumento = 'Cessione credito ad altra società';
					}
					when 'CESSIONSAL'{
						statoDocumento = 'Cessione credito a nuovo trader';
					}
					when 'CESSKLEIN2','HM_CESS_NP','CESEUROPAF','CREDCEDUTO','CESAAAEURO' {
						statoDocumento = 'Cessione credito a terzi';
					}
				}

				if(String.isBlank(statoDocumento)) {
					statoDocumento = 'Soc. rec. esterna';
				}
			}
		} catch (Exception ex) {
			System.debug(LoggingLevel.DEBUG, 'Errore calcolo stato documento GC ' + ex.getMessage());
		}
		return statoDocumento;
	}

	public static String calculateDocumentStatus(Double importo, Double residuo, Boolean storno){
		if (storno == true) {
			return 'Storno';
		}

		if (residuo > 0) {
			return 'Da pagare';
		}
		
		if (importo > 0 && residuo == 0) {
			return 'Pagato';
		}
		
		if (importo < 0 && residuo == 0) {
			return 'Accreditato';
		}
		
		if (importo < 0 && residuo < 0) {
			return 'Da accreditare';
		}
		
		return ''; // Non dovrebbe mai accadere.
	}

	/*
		Crea un record del tracciato dei dati catastali.
		docusignData e docusignRadioGroups sono mappa create a partire dalla classe HDT_WRP_DocusignNotify popolata dall'integrazione inbound con docusign.
		childOrder è l'Order figlio del processo per il quale è stata richiesta la compilazione del modulo dei dati catastali.

		Di seguito il tracciato AS-IS della SIE dei dati catastali:

		CODICE_OFFERTA					VARCHAR2(100)
		IMPIANTO						VARCHAR2(100)
		DESTINAZIONE_USO				VARCHAR2(30)
		PROGRESSIVO_SAP					VARCHAR2(100)
		DT_INI_CONTRATTO				DATE
		CODICE_ASSENZA_DATI_CATASTALI	VARCHAR2(30)
		COMUNE_AMMINISTRATIVO			VARCHAR2(100)
		COMUNE_CATASTALE				VARCHAR2(100)
		CODICE_COMUNE_CATASTALE			VARCHAR2(50)
		PROVINCIA_UBICAZIONE			VARCHAR2(2)
		TIPO_UNITA						VARCHAR2(50)
		SEZIONE_URBANA					VARCHAR2(50)
		FOGLIO							VARCHAR2(30)
		PARTICELLA						VARCHAR2(50)
		PARTICELLA_TAVOLARE				VARCHAR2(10)
		TIPO_PARTICELLA					VARCHAR2(50)
		SUBALTERNO						VARCHAR2(30)
		QUALIFICA_TITOLARE				VARCHAR2(30)
		ROW_ID_RDO						VARCHAR2(100)
		CATEGORIA_CATASTALE				VARCHAR2(30)
		SUPERFICIE_CATASTALE			NUMBER

		Di seguito le transcodifiche AS-IS implementate dalla SIE:

		Transcodifica DESTINAZIONE_USO:
		Val									decodifica
		Uso abitativo						1
		Immobile tenuto a disposizione		2
		Uso commerciale						3
		Locali adibiti a box				4
		Altri usi							5

		Transcodifica CODICE_ASSENZA_DATI_CATASTALI

		Val								decodifica
		da RD							0
		Immobile non accatastato		1
		Immobile non accatastabile		2

		Transcodifica TIPO_UNITA
		Val				decodifica
		Fabbricato		F
		Terreno			T

		Transcodifica TIPO_PARTICELLA
		Val				decodifica
		Fondiario		F
		Edificiale		E

		Transcodifica QUALIFICA_TITOLARE
		Val								decodifica
		Proprietario					1
		Usufruttuario					2
		Locatario						3
		Tit. altro diritto su immob.	4

		Di seguito un estratto di tracciato AS-IS:
		1-26371887987/1-C45530S;4003560309;1;;20201006;99991231;;RAVENNA;RAVENNA;H199;RA;F;;46;632;.;E;24;3;;
		1-27373306691/1-CKPCYMQ;4003141636;1;;20201111;99991231;;FAENZA;FAENZA;D458;RA;F;.;192;13;.;E;6;1;A/3;151
	 */
	public static LandRegistry__c createLandRegistryRecord(Map<String, String> docusignData, Map<String, String> docusignRadioGroups, Order childOrder,Integer i) {
		LandRegistry__c r = new LandRegistry__c();

		if (docusignData == null || childOrder == null) {
			return r;
		}
		String supplyType = childOrder.SupplyType__c;
		String destinazioneUso = '';
		if(String.isNotBlank(supplyType) && (supplyType.equalsIgnoreCase('Domestico') || supplyType.equalsIgnoreCase('A-Domestico'))) {
			destinazioneUso = '1';
		}else {
			destinazioneUso = '2';
		}

		//codice_offerta;
		r.OfferCode__c = childOrder.OrderNumber;
		// impianto
		r.ServicePoint__c = childOrder.ServicePoint__c;
		// destinazione_uso
		r.DestinationUsage__c = destinazioneUso;
		// dt_ini_contratto;
		r.StartDate__c = childOrder.EffectiveDate__c;
		// codice_assenza_dati_catastali; 
		r.CodeMissingRegistryData__c = transcodeCodiceAssenzaDatiCatastali(docusignRadioGroups.get('DTC_radiocat_'+i));
		// comune_amministrativo;
		r.LegalCity__c = docusignData.get('DTC_comune_amm_'+i);
		// comune_catastale;
		r.RegistryCity__c = docusignData.get('DTC_comune_cat_'+i);
		// codice_comune_catastale;
		r.RegistryCityCode__c = docusignData.get('DTC_cod_comune_'+i);
		// provincia_ubicazione;
		r.Province__c = childOrder.SupplyState__c;
		// tipo_unita;
		r.UnitType__c = docusignData.get('DTC_tipo_uni_'+i); // Il modulo richiede l'inserimento di F o T, quindi non servono transcodifiche.
		// sezione_urbana;
		r.UrbanSection__c = docusignData.get('DTC_sezione_'+i);
		// foglio;
		r.Sheet__c = docusignData.get('DTC_foglio_'+i);
		// particella;
		r.ParticleSheet__c = docusignData.get('DTC_partic_'+i);
		// particella_tavolare;
		r.ParticleTable__c = docusignData.get('DTC_estens_partic_'+i);
		// tipo_particella;
		r.ParticleType__c = docusignData.get('DTC_tipo_partic_'+i);
		// subalterno;
		r.Subaltern__c = docusignData.get('DTC_sub_'+i);
		// qualifica_titolare;
		r.Title__c = transcodeQualificaTitolare(docusignRadioGroups.get('DTC_qualitadi_'+i));
		// Categoria_Catastale;
		// r.RegistryCategory__c = ???? TODO: da dove prendere la categoria catastale? non sembra esserci nel modulo, nè sull'order nè sul service point.
		// Superficie_Catastale
		r.RegistrySurface__c = childOrder.SurfaceServed__c;
		r.Order__c = childOrder.Id;

		return r;
	}

	private static String transcodeCodiceAssenzaDatiCatastali(String docusignValue) {
		String transcoded = '';

		switch on docusignValue {
			when 'Pulsante di opzione1' { // Immobile non ancora iscritto al Catasto
				transcoded = '1';
			}
			when 'Pulsante di opzione2' { // Utenza non relativa ad un immobile ovvero immobile non iscrivibile in Catasto
				transcoded = '2';
			}
			when 'Pulsante di opzione3' { // Fornitura temporanea di servizi
				transcoded = '';  // valore non gestito da transcodifica AS-IS, per adesso lo ignoriamo.
			}
			when 'Pulsante di opzione4' { // Utenza per usi comuni o condominiali
				transcoded = '';  // valore non gestito da transcodifica AS-IS, per adesso lo ignoriamo.
			}
		}

		return transcoded;
	}

	private static String transcodeQualificaTitolare(String docusignValue) {
		String transcoded = '';

		switch on docusignValue {
			when 'Pulsante di opzione1' { // Proprietario
				transcoded = '1';
			}
			when 'Pulsante di opzione2' { // Locatario
				transcoded = '3';
			}
			when 'Pulsante di opzione3' { // Usufruttuario
				transcoded = '2';
			}
			when 'Pulsante di opzione4' { // Titolare di altro diritto sull'immobile
				transcoded = '4';
			}
			when 'Pulsante di opzione5' { // Rappresentante legale o volontario
				transcoded = ''; // valore non gestito da transcodifica AS-IS, per adesso lo ignoriamo.
			}
		}

		return transcoded;
	}
}