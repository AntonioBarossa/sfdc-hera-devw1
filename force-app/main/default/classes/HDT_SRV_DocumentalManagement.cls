@SuppressWarnings('PMD.AvoidDebugStatements, PMD.ExcessiveClassLength, PMD.ExcessivePublicCount, PMD.CyclomaticComplexity, PMD.AvoidDeeplyNestedIfStmts, PMD.NcssMethodCount, PMD.ExcessiveParameterList')
public with sharing class  HDT_SRV_DocumentalManagement{
	
	public static String generateRequest(String recordId, String context, String formParams){
		
		//DEBUG
		String debugString = 'HDT_SRV_DocumentalManagement - generateRequest';
		System.debug(LoggingLevel.DEBUG, debugString);
		
		String payload = '';
		String body = '';
		List<HDT_WRP_DocumentalRequest.HDT_WRP_DocumentalDriver> driver = new List<HDT_WRP_DocumentalRequest.HDT_WRP_DocumentalDriver>();
		Map<String,Object> driverPayloadMap = new Map<String,Object>();
		List<Map<String,Object>> driverPayloadListMap = new List<Map<String,Object>>();
		
		Map<String,Object> formParamsMap = formParams != null? (Map<String,Object>) JSON.deserializeUntyped(formParams) : new Map<String,Object>();
		String documentalContext = HDT_UTL_DocumentalManagement.getDocumentalContext(context);
		
		//estrae Body da Documento (con Name = context) e lo formatta come HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalStructure
		HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalStructure payloadStructure = HDT_UTL_DocumentalManagement.getDocumentalConfiguration(documentalContext);
		HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalStructure driverStructure = HDT_UTL_DocumentalManagement.getDocumentalConfiguration('Driver3');
		
		//inserito per gestire la documentazione anticipata che si basa su single Order. Sfrutta il Context4 per recuperare la struttura del payload e il context5 per la struttura record
		documentalContext = context.equalsIgnoreCase('DocumentazioneAnticipata')?'Context5':documentalContext;
		
		//Viene estratto un Custom Metadata apposito identificato dal documentalContext. 
		HDT_WRP_IntegrationObject.HDT_WRP_IntegrationParentObject integrationObjConfig =  HDT_UTL_IntegrationObject.getIntegrationObjectConfiguration('HDT_IntegrationObject__mdt', 'Id, JSON__c', 'DeveloperName = \'Documentale_'+ documentalContext + '\'', 'JSON__c');
		
		//Formula una serie di query Strings dove vengono estratti l'oggetto interessato dal processo e numerosi Childs di varia natura, secondo quanto indicato nei Custom Metadata
		Map<String,String> recordQueryMap = HDT_UTL_IntegrationObject.generateQueryString(integrationObjConfig, recordId); 
		
		//Esegue le query che ha formulato nel passaggio precedente
		List<sObject> recordList = HDT_QR_GenericQuery.getGenericRecords(recordQueryMap.get('queryString'), recordQueryMap.get('parentObject'));
		
		//Restituisce una lista in cui, per ogni order è presente una mappa dove sono stati suddivisi per tipologia i record inseriti indistintamente in recordsList.
		List<Map<String, List<sObject>>> recordObjectsListMap = HDT_UTL_DocumentalManagement.getRecordObjectsList(recordList, documentalContext);
		formParamsMap.put('Contesto', context);
		
		//sub-processing della lista di mappe realizzata al punto precedente.
		//nuovo campo Customer Info settoreMerceologico
		String settoreMerceologico = '';
		for(Integer i=0; i < recordObjectsListMap.size(); i++){
			driver = generateDriver(recordObjectsListMap[i], driverStructure, formParamsMap);
			payload = generatePayload(recordObjectsListMap[i], payloadStructure, formParamsMap);
			
			if(context.equalsIgnoreCase('EC')){
				payload += generatePayloadEstrattoConto(formParamsMap);
			}else if(context.equalsIgnoreCase('GC')){
				payload += generatePayloadGestioneCredito(formParamsMap);
			}

			//nuova logica per campo settore merceologico
			String objectName = '';
			if(context.equalsIgnoreCase('EC') || context.equalsIgnoreCase('GC') || context.equalsIgnoreCase('Account')){
				objectName = 'Case';
			}else if(context.equalsIgnoreCase('DocumentazioneAnticipata')){
				objectName='Order';
			}
			else {
				objectName=context;
			}
			if ('Case'.equalsIgnoreCase(objectName) || 'Order'.equalsIgnoreCase(objectName)){
				String retrivedValue = HDT_UTL_DocumentalManagement.getValue(objectName, 'CommodityFormula__c', 0, recordObjectsListMap[i], formParamsMap);
				switch on retrivedValue {
					when  'Gas' {
						retrivedValue = '#GAS';
					}
					when  'Energia Elettrica' {
						retrivedValue = '#ELE';
					}
					when else {
						retrivedValue = '';
					}
				}
				if (String.isNotEmpty(retrivedValue) && !settoreMerceologico.contains(retrivedValue)) {
					settoreMerceologico += retrivedValue;
				}
			}
			//fine logica per campo settore merceologico
			Blob payloadBlob = Blob.valueOf(payload);
			payload = EncodingUtil.base64Encode(payloadBlob);
			System.debug(LoggingLevel.DEBUG, 'Paylod ' + payload);
			
			driverPayloadMap.put('driver', driver);
			driverPayloadMap.put('payload', payload);
			driverPayloadListMap.add(new Map<String,Object>(driverPayloadMap));
		}
		if (String.isNotEmpty(settoreMerceologico)){
			formParamsMap.put('SettMerceologico',settoreMerceologico.substring(1));
		}
		
		body = composeJson(recordId, driverPayloadListMap, formParamsMap, recordObjectsListMap[0]);
		System.debug(LoggingLevel.DEBUG, 'Body ' + body);
		
		return body;
	}

	public static String generateGetAttachmentRequest(String recordId){
		if (String.isBlank(recordId)) {
			throw new HDT_UTL_HeraException('Necessario passare in input un Id di DocumentalActivity__c per visualizzare il documento.');
		}

		DocumentalActivity__c actMoga = HDT_QR_DocumentalConfiguration.getDocumentalActivityById(recordId);
		if (actMoga == null) {
			throw new HDT_UTL_HeraException('Necessario passare in input un Id di DocumentalActivity__c per visualizzare il documento.');
		}
		if(String.isNotBlank(actMoga.DocumentalSystem__c) && 'Intesa'.equalsIgnoreCase(actMoga.DocumentalSystem__c)){
			throw new HDT_UTL_HeraException('I documenti gestiti in OTP sono visibili tramite il tasto Visualizza Plico');
		}

		if (String.isBlank(actMoga.AttachmentCode__c)) {
			throw new HDT_UTL_HeraException('Impossibile visualizzare allegato, Codice Allegato non disponibile.');
		}

		JSONGenerator gen = JSON.createGenerator(false);

		gen.writeStartObject();
		gen.writeFieldName('attachmentInfo');
		gen.writeStartArray();
		gen.writeStartObject();
		gen.writeStringField('key', 'pt_numero_plico');
		gen.writeStringField('value', actMoga.EnvelopeId__c);
		gen.writeEndObject();
		gen.writeStartObject();
		gen.writeStringField('key', 'pt_codice_allegato');
		gen.writeStringField('value', actMoga.AttachmentCode__c);
		gen.writeEndObject();
		gen.writeStartObject();
		gen.writeStringField('key', 'pt_timestamp');
		gen.writeStringField('value', actMoga.PostelTimestamp__c);
		gen.writeEndObject();
		gen.writeEndArray();
		gen.writeEndObject();

		String body = gen.getAsString();
		System.debug(LoggingLevel.DEBUG, 'Postel body: ' + body);
		return body;
	}

	public static String generateGetEnvelopeRequest(SObject documentalObject, String documentType){
		if (documentalObject == null) {
			throw new HDT_UTL_HeraException('Necessario passare in input una instanza di DocumentalActivity__c o DocumentSendTracking__c per visualizzare il documento.');
		}

		if (String.isBlank(documentType)) {
			throw new HDT_UTL_HeraException('Errore interno nel recupero del documento archiviato.');
		}

		String envelopeId = (String) documentalObject.get('EnvelopeId__c');
		if (String.isBlank(envelopeId)) {
			throw new HDT_UTL_HeraException('Impossibile visualizzare il plico archiviato, Id Plico non disponibile.');
		}

		String body = '';
		if (documentType == 'pdf') {

			JSONGenerator gen = JSON.createGenerator(false);
			gen.writeStartObject();
			gen.writeFieldName('envelopeInfo');
			gen.writeStartArray();
			gen.writeStartObject();
			gen.writeStringField('key', 'pt_numero_offerta');
			gen.writeStringField('value', envelopeId);
			gen.writeEndObject();
			gen.writeEndArray();
			gen.writeEndObject();
			body = gen.getAsString();

		} else {

			JSONGenerator gen = JSON.createGenerator(false);
			DocusignSettings__c docusignCustomSettings = DocusignSettings__c.getInstance();
			gen.writeStartObject();
			gen.writeStringField('customerId', docusignCustomSettings.CustomerEnviromentId__c);
			gen.writeStringField('transactionId', envelopeId);
			gen.writeBooleanField('getCustomFields', true);
			gen.writeStringField('typeDoc', 'ALL');
			gen.writeEndObject();
			body = gen.getAsString();
		}

		System.debug(LoggingLevel.DEBUG, 'GetEnvelopeRequest body: ' + body);
		return body;
	}

	public static String generateResendDocusignEnvelopeRequest(String recordId){
		if (String.isBlank(recordId)) {
			throw new HDT_UTL_HeraException('Necessario passare in input un Id di DocumentSendTracking__c per re-inviare la busta.');
		}

		DocumentSendTracking__c sendTrack = HDT_QR_DocumentalConfiguration.getDocumentSendTrackingById(recordId);
		if (sendTrack == null) {
			throw new HDT_UTL_HeraException('Necessario passare in input un Id di DocumentSendTracking__c per re-inviare la busta.');
		}

		if (String.isBlank(sendTrack.EnvelopeId__c)) {
			throw new HDT_UTL_HeraException('Impossibile re-inviare la busta, Id Plico non disponibile.');
		}

		JSONGenerator gen = JSON.createGenerator(false);
		DocusignSettings__c docusignCustomSettings = DocusignSettings__c.getInstance();

		gen.writeStartObject();
		gen.writeStringField('customerId', docusignCustomSettings.CustomerEnviromentId__c);
		gen.writeStringField('transactionId', sendTrack.EnvelopeId__c);
		gen.writeEndObject();

		String body = gen.getAsString();
		System.debug(LoggingLevel.DEBUG, 'Intesa body: ' + body);
		return body;
	}

	public static String generateDiscardDocusignEnvelopeRequest(String recordId){
		if (String.isBlank(recordId)) {
			throw new HDT_UTL_HeraException('Necessario passare in input un Id di DocumentSendTracking__c per re-inviare la busta.');
		}

		DocumentSendTracking__c sendTrack = HDT_QR_DocumentalConfiguration.getDocumentSendTrackingById(recordId);
		if (sendTrack == null) {
			throw new HDT_UTL_HeraException('Necessario passare in input un Id di DocumentSendTracking__c per re-inviare la busta.');
		}

		if (String.isBlank(sendTrack.EnvelopeId__c)) {
			throw new HDT_UTL_HeraException('Impossibile re-inviare la busta, Id Plico non disponibile.');
		}

		JSONGenerator gen = JSON.createGenerator(false);
		DocusignSettings__c docusignCustomSettings = DocusignSettings__c.getInstance();

		gen.writeStartObject();
		gen.writeStringField('customerId', docusignCustomSettings.CustomerEnviromentId__c);
		gen.writeStringField('transactionId', sendTrack.EnvelopeId__c);
		gen.writeEndObject();

		String body = gen.getAsString();
		System.debug(LoggingLevel.DEBUG, 'Intesa body: ' + body);
		return body;
	}

	@future
	public static void createPublicLinkFuture(String recordId,String base64,String fileName){
		String publicLink = createPublicLink(recordId,base64,fileName);
		Order ord = new Order();
		ord.Id = recordId;
		switch on fileName{
			when 'MODULISTICA_NO_B12'{
				ord.InformationFormLink__c = publicLink;
			}when 'MODULISTICA_B12'{
				ord.SendFormLink__c = publicLink;
			}when 'DELIBERA_40'{
				ord.Decision40Link__c = publicLink;
			}
		}
		HDT_UTL_DatabaseService.updateSObject(ord);
	}

	public static String createPublicLink(String recordId,String base64,String fileName){
		try {
			ContentVersion cv = HDT_UTL_DocumentalManagement.createContectVersion(base64,fileName);
			/*
				@Author: Davide Viola - 19/10/2021
				Description: PMD -> Commentata variabile non utilizzata.
			*/
			/*ContentDocumentLink cl = */HDT_UTL_DocumentalManagement.createContentLink(cv.Id, recordId);
			String publicLink =  HDT_UTL_DocumentalManagement.createContentDistribution(cv.Id,fileName);
			return publicLink;
		} catch (Exception ex) {
			System.debug(LoggingLevel.DEBUG, 'Errore ' + ex.getMessage() + ' at line ' + ex.getLineNumber());
			return null;
		}
	}

	@future(callout=true)
	public static void executeCalloutRequestFuture(String body, String context){
		
		HDT_WRP_DocumentalResponse documentalResponse = new HDT_WRP_DocumentalResponse();
		documentalResponse = HDT_WS_DocumentalIntegration.submitRequest(body);
		
		manageResponse(documentalResponse, context);
		
	}
	
	public static HDT_WRP_DocumentalResponse executeCalloutRequest(String body,String context){
		HDT_WRP_DocumentalResponse documentalResponse = new HDT_WRP_DocumentalResponse();
		documentalResponse = HDT_WS_DocumentalIntegration.submitRequest(body);
		manageResponseFuture(JSON.serialize(documentalResponse), context);
		return documentalResponse;
	}

	public static HDT_WRP_DocumentalResponse.HDT_WRP_PostelResponse executeGetAttachmentCalloutRequest(String body){
		HDT_WRP_DocumentalResponse.HDT_WRP_PostelResponse postelResponse = new HDT_WRP_DocumentalResponse.HDT_WRP_PostelResponse();
		postelResponse = HDT_WS_DocumentalIntegration.submitGetAttachmentRequest(body);
		if (postelResponse.responseCode != 200) {
			throw new HDT_UTL_HeraException('Errore Postel nel recupero del documento archiviato');
		}
		return postelResponse;
	}
	
	public static HDT_WRP_DocumentalResponse.HDT_WRP_PostelResponse executeGetEnvelopeCalloutRequest(String body, String documentType){
		if (String.isBlank(documentType)) {
			throw new HDT_UTL_HeraException('Errore interno nel recupero del documento archiviato.');
		}

		HDT_WRP_DocumentalResponse.HDT_WRP_PostelResponse postelResponse = new HDT_WRP_DocumentalResponse.HDT_WRP_PostelResponse();
		if (documentType == 'pdf') {
			postelResponse = HDT_WS_DocumentalIntegration.submitGetEnvelopePostelRequest(body);
			if (postelResponse.responseCode != 200) {
				throw new HDT_UTL_HeraException('Errore Postel nel recupero del documento archiviato');
			}
		} else {
			postelResponse = HDT_WS_DocumentalIntegration.submitGetIntesaZipRequest(body);
			if (postelResponse.responseCode != 200) {
				throw new HDT_UTL_HeraException('Errore Intesa nel recupero del documento archiviato');
			}
		}

		return postelResponse;
	}

	public static HDT_WRP_DocumentalResponse.HDT_WRP_IntesaResponse executeResendDocusignEnvelopeCalloutRequest(String body){
		HDT_WRP_DocumentalResponse.HDT_WRP_IntesaResponse responseWrap = new HDT_WRP_DocumentalResponse.HDT_WRP_IntesaResponse();
		responseWrap = HDT_WS_DocumentalIntegration.submitResendDocusignEnvelopeRequest(body);
		return responseWrap;
	}

	public static HDT_WRP_DocumentalResponse.HDT_WRP_IntesaResponse executeDiscardDocusignEnvelopeCalloutRequest(String body){
		HDT_WRP_DocumentalResponse.HDT_WRP_IntesaResponse responseWrap = new HDT_WRP_DocumentalResponse.HDT_WRP_IntesaResponse();
		responseWrap = HDT_WS_DocumentalIntegration.submitDiscardDocusignEnvelopeRequest(body);
		return responseWrap;
	}

	public static String getTransactionId(String envelopeId){
		String transactionId;
		DocusignSettings__c docusignCustomSettings = DocusignSettings__c.getInstance();
		String addonUrl = '?customerId='+docusignCustomSettings.CustomerEnviromentId__c+'&envelopeId='+envelopeId;
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setEndpoint('Callout:DocusignTransaction'+addonUrl);
		request.setMethod('GET');
		HttpResponse response = http.send(request);
		if (response.getStatusCode() == 200) {
			Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
			System.debug(LoggingLevel.DEBUG, 'Response: ' + results);
			if (results.containsKey('data')) {
				Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(results.get('data')));
				transactionId = (String) data.get('transactionId');
			}
			
			System.debug(LoggingLevel.DEBUG, 'Received the following transactionId: ' + transactionId);
		}
		return transactionId;
	}
	public static SObject getSobjectFromTransactionId(String transactionId){
		if(String.isBlank(transactionId)){ 
			return null;
		}
		
		SObject docSendTracking = HDT_QR_DocumentalConfiguration.getDocumentSendTracking(transactionId);
		if(docSendTracking != null){
			if(docSendTracking.get('Case__c') != null){
				List<SObject> caseList = HDT_QR_GenericQuery.getGenericRecords('SELECT Id,AccountId,Phase__c,DocumentalPhase__c,DocumentalProcessType__c,Cluster__c,Contact.IndividualId,Type,Lead__r.IndividualId FROM Case WHERE Id = \''+(String)docSendTracking.get('Case__c')+'\'', 'Case');
				return caseList[0];
			}else {
				List<SObject> orderList = HDT_QR_GenericQuery.getGenericRecords('SELECT Id,AccountId,Phase__c,DocumentalPhase__c,DocumentalProcessType__c,Cluster__c,Contact__r.IndividualId FROM Order WHERE Id = \''+(String)docSendTracking.get('Order__c')+'\'', 'Order');
				return orderList[0];
			}
		}else{
			return null;
		}
	}

	public static void updateSobjectFromDocusign(SObject record,HDT_WRP_DocusignNotify.HDT_WRP_DocusignNotifyRequest requestBody, String envelopeId){
		if(record != null){
			String status = requestBody.status;
			String cluster = (String)record.get('Cluster__c');
			List<HDT_WRP_DocusignNotify.HDT_WRP_DocusignNotifyRadio> listOfRadio = new List<HDT_WRP_DocusignNotify.HDT_WRP_DocusignNotifyRadio>();
			List<HDT_WRP_DocusignNotify.HDT_WRP_DocusignNotifyData> listOfData = new List<HDT_WRP_DocusignNotify.HDT_WRP_DocusignNotifyData>();
            if(requestBody.listOfRadioGroup != null && requestBody.listOfRadioGroup.size()>0){
				listOfRadio.addAll(requestBody.listOfRadioGroup);
				System.debug(LoggingLevel.DEBUG, requestBody.listOfRadioGroup);
			}
			if(requestBody.listOfDataText != null && requestBody.listOfDataText.size()>0){
				listOfData.addAll(requestBody.listOfDataText);
			}
			
			if(record.getSobjectType() == Case.getSobjectType()){
				String caseType = (String)record.get('Type');
				if(status.equalsIgnoreCase('completed')){
					record.put('DocumentalPhase__c','Plico firmato');
					if(cluster.equalsIgnoreCase('Preventivi') || cluster.equalsIgnoreCase('Verifiche')){
						record.put('Phase__c','Preventivo accettato');
					}
					if ('Rimborso'.equalsIgnoreCase(caseType) || 'Piano Rateizzazione'.equalsIgnoreCase(caseType)){
						HDT_UTL_Case.createActivity((Id)record.get('Id'), 'Validazione Firma OTP', 'Validazione Firma OTP', 'Validazione Firma OTP');
					}
				}else{
					//Che fase documentale settare?
					if(cluster.equalsIgnoreCase('Preventivi') || cluster.equalsIgnoreCase('Verifiche')){
						record.put('Phase__c','Preventivo rifiutato');
					}
				}
			}else {
				if(status.equalsIgnoreCase('completed')){
					// La DocumentalPhase__c per l'Order verrà valorizzata nel method handleRadioGroup() in base ai radio button (Legge 80 ecc.)
					//record.put('DocumentalPhase__c','Plico firmato');
					record.put('SignedDate__c', Date.today()); // data necessaria per far scattare logiche sui processi di vendita.
				}
			}
			handleRadioGroup(record,listOfRadio,envelopeId);
			handleLandRegistry(record,listOfData,listOfRadio);
			HDT_UTL_DatabaseService.upsertSObject(record);
		}
	}

	public static void logDocusignError(SObject record,HDT_WRP_DocusignNotify.HDT_WRP_DocusignNotifyRequest requestBody){
		if(record != null && requestBody != null){
			/*
				@Author: Davide Viola - 19/10/2021
				Description: PMD -> Commentate variabili non utilizzate.
			*/
			/*String status = requestBody.status;
			String processType = (String)record.get('DocumentalProcessType__c');
			String cluster = (String)record.get('Cluster__c');*/
			Id recordId = (Id)record.get('Id');
			HDT_UTL_DocumentalManagement.createDocumentalActivityForError(requestBody.outcomeDescription, recordId, requestBody.envelopeId, record);
		}
	}

	public static void createIntesaDocumentalActivity(SObject parentRecord,HDT_WRP_DocusignNotify.HDT_WRP_DocusignNotifyRequest requestBody,String transactionId){
		if(parentRecord != null){
			String status = requestBody.status;
			if(status.equalsIgnoreCase('completed')){
				DocumentalActivity__c documentalActivity  = HDT_UTL_DocumentalManagement.initDocumentalActivity(parentRecord,transactionId);
				if (documentalActivity != null){
					documentalActivity.ActivityType__c = 'Documentazione completa';
					try {
						HDT_UTL_DatabaseService.insertSObject(documentalActivity);
					} catch (Exception ex) {
						System.debug(LoggingLevel.DEBUG, 'Errore DML: ' + ex.getMessage());
					}
				}
			}
		}
	}

	private static void handleRadioGroup(Sobject record, List<HDT_WRP_DocusignNotify.HDT_WRP_DocusignNotifyRadio> listOfRadio, String envelopeId){
        if(listOfRadio != null && listOfRadio.size()>0){
			String individualId;
			if(record.getSobjectType() == Case.getSobjectType()){
				Case caseRecord = (Case) record;
				Contact caseContact = (Contact) caseRecord.Contact;
				Lead caseLead;
				if (caseContact != null){
					individualId = caseContact.IndividualId;
				}else {
					caseLead = (Lead) caseRecord.Lead__r;
					individualId = caseLead != null? caseLead.IndividualId:'';
				}
			}else{
				Order orderRecord = (Order) record;
				//FIX data firma su order figli
				//List<Order> orderList = HDT_QR_GenericQuery.getGenericRecords('select Id,Account.RecordType.DeveloperName,DocumentalProcessType__c,SignedDate__c,DateSentToSII__c,MaxAfterthoughtDate__c from Order where ParentOrder__c = \''+(String)orderRecord.Id+'\'', 'Order');
				Contact orderContact = (Contact) orderRecord.Contact__r;
				if (orderContact != null){
					individualId = orderContact.IndividualId;
				}else{
					System.debug(LoggingLevel.DEBUG, 'Impossibile aggiornare flag privacy, nessun riferimento di Contact su Order: ' + (String) record.get('Id'));
				}
			}
			Individual individualRecord = new Individual();

			if(record.getSobjectType() == Case.getSobjectType()){
				//Settare phase del case in completata
				record.put('Phase__c', 'Completata');
				List<SObject> attachmentList = HDT_QR_GenericQuery.getGenericRecords('select id,AttachmentCode__c, Description__c, Version__c from DocumentalEnvelopeAttachment__c where Case__c = \''+(String)record.get('Id')+'\'', 'DocumentalEnvelopeAttachment__c');
				for(HDT_WRP_DocusignNotify.HDT_WRP_DocusignNotifyRadio singleRadio : listOfRadio){
					String privacyVersion;
					for(DocumentalEnvelopeAttachment__c singleAttachment : (List<DocumentalEnvelopeAttachment__c>) attachmentList){
						if(singleAttachment.AttachmentCode__c.indexOf('PRIVACY')>-1){
							privacyVersion = singleAttachment.Version__c;
						}
					}
					if(singleRadio.selected.equalsIgnoreCase('true')){
						String value = singleRadio.value.equalsIgnoreCase('YES')?'SI':'NO';
						if(singleRadio.groupName.indexOf('radio1') > -1){
							record.put('MarketingPrivacy__c', value);
							individualRecord.MarketingPrivacy__c = value;
							individualRecord.PrivacyMarketingChoiceDate__c = Date.today();
							individualRecord.PrivacyMarketingChoiceSource__c = 'CONTRATTO';
							individualRecord.MarketingPrivacyVersion__c = privacyVersion;
						}else if (singleRadio.groupName.indexOf('radio2') > -1) {
							record.put('ProfilingPrivacy__c', value);
							individualRecord.ProfilingPrivacy__c = value;
							individualRecord.PrivacyProfilingChoiceDate__c = Date.today();
							individualRecord.PrivacyProfilingChoiceSource__c = 'CONTRATTO';
							individualRecord.ProfilingPrivacyVersion__c = privacyVersion;
						}
					}
				}
			}else{
				List<SObject> attachmentList = HDT_QR_GenericQuery.getGenericRecords('select id,AttachmentCode__c, Description__c, Version__c from DocumentalEnvelopeAttachment__c where Order__c = \''+(String)record.get('Id')+'\'', 'DocumentalEnvelopeAttachment__c');
				List<SObject> orderList = HDT_QR_GenericQuery.getGenericRecords('SELECT Id,Instance326__c,AccountId,DocumentLow80__c,Phase__c,DocumentalPhase__c,DocumentalProcessType__c,Cluster__c,OrderNumber FROM Order WHERE ParentOrder__c = \''+(String)record.get('Id')+'\' AND ProcessType__c != \'VAS\'', 'Order');
				List<SObject> orderToUpdate = new List<SObject>();
				List<wrts_prcgvr__Activity__c> voltureActList = new List<wrts_prcgvr__Activity__c>();
				Boolean isVoltura = false;
				Set<String> moduliOpzionaliMancanti = new Set<String>();
				List<DocumentalActivity__c> activitiesToCreate = new List<DocumentalActivity__c>();
				DocumentalActivity__c actOtpSign  = HDT_UTL_DocumentalManagement.initDocumentalActivity(record, envelopeId);
				if (actOtpSign != null){
					actOtpSign.ActivityType__c = 'Plico Firmato OTP';
					activitiesToCreate.add(actOtpSign);
				}

				for(HDT_WRP_DocusignNotify.HDT_WRP_DocusignNotifyRadio singleRadio : listOfRadio){
					System.debug(LoggingLevel.DEBUG, 'Checking radiobutton: ' + JSON.serialize(singleRadio));
					String privacyVersion;
					// TODO DA FIXARE: attachmentList è vuoto poichè il record in contesto è l'order padre, mentre gli attachment sono sotto gli order figli.
					for(DocumentalEnvelopeAttachment__c singleAttachment : (List<DocumentalEnvelopeAttachment__c>) attachmentList){
						if(singleAttachment.AttachmentCode__c.indexOf('PRIVACY')>-1){
							privacyVersion = singleAttachment.Version__c;
						}
					}
					if(singleRadio.selected.equalsIgnoreCase('true')){
						String value = singleRadio.value.equalsIgnoreCase('YES')?'SI':'NO';
						if(singleRadio.groupName.indexOf('radio1') > -1){
							individualRecord.MarketingPrivacy__c = value;
							individualRecord.PrivacyMarketingChoiceDate__c = Date.today();
							individualRecord.MarketingPrivacyVersion__c = privacyVersion;
							individualRecord.PrivacyMarketingChoiceSource__c = 'CONTRATTO';
						}else if (singleRadio.groupName.indexOf('radio2') > -1) {
							individualRecord.ProfilingPrivacy__c = value;
							individualRecord.PrivacyProfilingChoiceDate__c = Date.today(); 
							individualRecord.ProfilingPrivacyVersion__c = privacyVersion;
							individualRecord.PrivacyMarketingChoiceSource__c = 'CONTRATTO';
						}
						// Verifica radiobutton nei moduli opzionali (dati catastali, legge 80, istanza 326)
						// I nomi dei radiobutton sono presenti nel JSON che manda Docusign
						if (singleRadio.groupName.contains('DTC_radio1')){
							String actDescription = 'Ritornato correttamente';
							if (singleRadio.value.equalsIgnoreCase('Pulsante di opzione1') && singleRadio.selected.equalsIgnoreCase('true')){
								if(singleRadio.groupName.contains('_1')){
									actDescription  = actDescription + ' su ordine '+ orderList[0].get('OrderNumber');
								}else {
									actDescription  = actDescription + ' su ordine '+ orderList[1].get('OrderNumber');
								}
								DocumentalActivity__c documentalActivity  = HDT_UTL_DocumentalManagement.initDocumentalActivity(record, envelopeId);
								if (documentalActivity != null){
									documentalActivity.AttachmentCode__c = 'DATI_CATASTALI'; // utilizziamo un Id fittizio al posto del codice allegato Engage1, poichè non riusciamo a recuperarlo.
									documentalActivity.ActivityType__c = 'Allegati ricevuti';
									documentalActivity.AttachmentDescription__c = actDescription;
									activitiesToCreate.add(documentalActivity);
								}
							} else {
								moduliOpzionaliMancanti.add(singleRadio.groupName);
							}
						}
						if (singleRadio.groupName.contains('L80_radio')){
							if (singleRadio.value.equalsIgnoreCase('Pulsante di opzione1') && singleRadio.selected.equalsIgnoreCase('true')){
								String actDescriptionLeggeOtt = 'Ritornato correttamente';
								if(singleRadio.groupName.contains('_1')){
									actDescriptionLeggeOtt  = actDescriptionLeggeOtt + ' su ordine '+ orderList[0].get('OrderNumber');
									orderList[0].put('DocumentLow80__c','Validato');
								}else {
									actDescriptionLeggeOtt  = actDescriptionLeggeOtt + ' su ordine '+ orderList[1].get('OrderNumber');
									orderList[1].put('DocumentLow80__c','Validato');
								}
								DocumentalActivity__c documentalActivity  = HDT_UTL_DocumentalManagement.initDocumentalActivity(record, envelopeId);
								if (documentalActivity != null){
									documentalActivity.AttachmentCode__c = 'LEGGE_80'; // utilizziamo un Id fittizio al posto del codice allegato Engage1, poichè non riusciamo a recuperarlo.
									documentalActivity.ActivityType__c = 'Allegati ricevuti';
									documentalActivity.AttachmentDescription__c = actDescriptionLeggeOtt;
									activitiesToCreate.add(documentalActivity);
								}
							} else {
								moduliOpzionaliMancanti.add(singleRadio.groupName);
							}
						}
						if (singleRadio.groupName.contains('326_radio')){
							if (singleRadio.value.equalsIgnoreCase('Pulsante di opzione1') && singleRadio.selected.equalsIgnoreCase('true')){
								String actDescriptionIstanza = 'Ritornato correttamente';
								if(singleRadio.groupName.contains('_1')){
									actDescriptionIstanza  = actDescriptionIstanza + ' su ordine '+ orderList[0].get('OrderNumber');
									orderList[0].put('Instance326__c','Validato');
								}else {
									actDescriptionIstanza  = actDescriptionIstanza + ' su ordine '+ orderList[1].get('OrderNumber');
									orderList[1].put('Instance326__c','Validato');
								}
								DocumentalActivity__c documentalActivity  = HDT_UTL_DocumentalManagement.initDocumentalActivity(record, envelopeId);
								if (documentalActivity != null){
									documentalActivity.AttachmentCode__c = 'ISTANZA_326'; // utilizziamo un Id fittizio al posto del codice allegato Engage1, poichè non riusciamo a recuperarlo.
									documentalActivity.ActivityType__c = 'Allegati ricevuti';
									documentalActivity.AttachmentDescription__c = actDescriptionIstanza;
									activitiesToCreate.add(documentalActivity);
								}
							} else {
								moduliOpzionaliMancanti.add(singleRadio.groupName);
							}
						}
						
						
					}
				}
				try {
					if (!moduliOpzionaliMancanti.isEmpty()) {
						System.debug(LoggingLevel.DEBUG, 'Moduli opzionali NON compilati: ' + moduliOpzionaliMancanti);
						record.put('DocumentalPhase__c','Plico firmato senza moduli opzionali');
					} else {
						record.put('DocumentalPhase__c','Plico firmato');
					}
					record.put('Phase__c','Documentazione Gestita');
					record.put('SignedDate__c', Date.today());
					Order orderRecord = (Order) record;
					HDT_UTL_DatabaseService.updateSObject(record);
					if (!activitiesToCreate.isEmpty()){
						HDT_UTL_DatabaseService.insertSObject(activitiesToCreate);
					}
					List<Order> childToUpdate = new List<Order>();
					Map<Id,String> orderPhaseMap = new Map<Id,String>();
					orderList = HDT_QR_GenericQuery.getGenericRecords('SELECT Id,Instance326__c,AccountId,DocumentLow80__c,Phase__c,DocumentalPhase__c,DocumentalProcessType__c,Cluster__c,OrderNumber FROM Order WHERE ParentOrder__c = \''+(String)record.get('Id')+'\' AND ProcessType__c != \'VAS\'', 'Order');
					for(Sobject childOrder : orderList){
						Order singleOrder = new Order();
						singleOrder.Id = childOrder.Id;
						singleOrder.CIAccoutn__c = 'Validato';
						singleOrder.CILegalRepresentative__c = 'Validato';
						singleOrder.DocumentLow80__c = (String)childOrder.get('DocumentLow80__c');
						singleOrder.Instance326__c = (String)childOrder.get('Instance326__c');
						singleOrder.DocumentPackage__c = 'Validato';
						String leggeOtt = (String)childOrder.get('DocumentLow80__c');
						String istanza = (String)childOrder.get('Instance326__c');
						if((String.isBlank(leggeOtt) || (String.isNotBlank(leggeOtt) && leggeOtt.equalsIgnoreCase('Validato'))) && 
						(String.isBlank(istanza) || (String.isNotBlank(istanza) && istanza.equalsIgnoreCase('Validato')))
						&& (!'Annullato'.equalsIgnoreCase((String)childOrder.get('Phase__c')) && !'Accettazione Voltura'.equalsIgnoreCase((String)childOrder.get('Phase__c')) && !'Credit Check KO'.equalsIgnoreCase((String)childOrder.get('Phase__c')) && !'Attesa Credit Check'.equalsIgnoreCase((String)childOrder.get('Phase__c')))){
							singleOrder.Phase__c = 'Documentazione Validata';
							orderPhaseMap.put(singleOrder.Id, 'Documentazione Validata');
						}
						childToUpdate.add(singleOrder);
					}
					/**
					 * AF Fix Accettazione Voltura.
					 * E' necessario chiudere l'attività prima di settare Documentazione Validata
					 */
					/*try {
						if(!orderList.isEmpty()){
							Set<Id> voltOrdSet = new Set<Id>();
							String processTypeVol = '';
							String phase = '';
							for (SObject voltOrder : orderList) {
								processTypeVol = (String)voltOrder.get('DocumentalProcessType__c');
								phase = orderPhaseMap.get((Id)voltOrder.get('Id')) != null? orderPhaseMap.get((Id)voltOrder.get('Id')):'';
								if(String.isNotBlank(processTypeVol) && processTypeVol.containsIgnoreCase('Voltura') && String.isNotBlank(phase) && phase.equalsIgnoreCase('Documentazione Validata')){
									voltOrdSet.add((Id)voltOrder.get('Id'));
								}
							}
							if(!voltOrdSet.isEmpty()){
								voltureActList = [SELECT Id,wrts_prcgvr__Status__c FROM wrts_prcgvr__Activity__c WHERE Order__c IN:voltOrdSet AND wrts_prcgvr__Status__c = 'Aperta' AND Type__c = 'Accettazione Voltura'  WITH SECURITY_ENFORCED];
								for(wrts_prcgvr__Activity__c singleAct : voltureActList){
									singleAct.wrts_prcgvr__Status__c = 'Chiusa';
								}
								if(!voltureActList.isEmpty()){
									HDT_UTL_DatabaseService.updateSObject(voltureActList);
								}
							}
						}
					} catch (Exception ex) {
						//no throws
					}*/
					if(!childToUpdate.isEmpty()){
						HDT_UTL_DatabaseService.updateSObject(childToUpdate);
					}
					
				}catch(Exception ex){
					HDT_UTL_IntegrationLog.handleGenericErrorRequest(JSON.serialize(listOfRadio),'POST', ex.getMessage()+' row number --> ' + ex.getLineNumber(), 'Handle Docusign Notify', (String)record.get('Id'));
					System.debug(LoggingLevel.DEBUG, 'Errore DML: ' + ex.getMessage());
				}
			}

			if (individualId != null){
				individualRecord.Id = individualId;
				try {
					HDT_UTL_DatabaseService.updateSObject(individualRecord);
				}catch(Exception ex){
					System.debug(LoggingLevel.DEBUG, 'Errore DML: ' + ex.getMessage());
				}
			}
		}else if(record.getSobjectType() == Order.getSobjectType()){
			record.put('DocumentalPhase__c','Plico firmato');
			record.put('Phase__c','Documentazione Gestita');
			HDT_UTL_DatabaseService.updateSObject(record);
		}
	}
	private static void handleLandRegistry( Sobject record, List<HDT_WRP_DocusignNotify.HDT_WRP_DocusignNotifyData> listOfData, List<HDT_WRP_DocusignNotify.HDT_WRP_DocusignNotifyRadio> listOfRadio){
		if(record != null && record.getSobjectType() == Case.getSobjectType()){
			return;
		}
		List<Order> orderList = (List<Order>)HDT_QR_GenericQuery.getGenericRecords('SELECT Id,OrderNumber,ServicePoint__c,EffectiveDate__c,SupplyState__c,SurfaceServed__c,SupplyType__c FROM Order WHERE ParentOrder__c = \''+(String)record.get('Id')+'\' AND ProcessType__c != \'VAS\'', 'Order');
		List<LandRegistry__c> registries = new List<LandRegistry__c>();
		Map<String, String> docusignData = new Map<String, String>();
		for (HDT_WRP_DocusignNotify.HDT_WRP_DocusignNotifyData singleData : listOfData) {
			docusignData.put(singleData.dataName, singleData.dataValue);
		}

		// Mappa che contiene solo i radiobutton selezionati.
		Map<String, String> docusignRadioGroups = new Map<String, String>();
		for (HDT_WRP_DocusignNotify.HDT_WRP_DocusignNotifyRadio singleRadio : listOfRadio) {
			if(singleRadio.selected.equalsIgnoreCase('true')) {
				docusignRadioGroups.put(singleRadio.groupName, singleRadio.value);
			}
		}
		Integer i = 1;
		for(Order childOrder : orderList){
			LandRegistry__c reg = HDT_UTL_DocumentalManagement.createLandRegistryRecord(docusignData, docusignRadioGroups, childOrder,i);
			registries.add(reg);
			i++;
		}
		

		if (!registries.isEmpty()){
			try {
				System.debug(LoggingLevel.DEBUG, '# dati catastali da inserire: ' + registries.size());
				HDT_UTL_DatabaseService.insertSObject(registries);
			}catch(Exception ex){
				System.debug(LoggingLevel.DEBUG, 'Errore DML: ' + ex.getMessage());
			}
		}
	}

	@future
	private static void manageResponseFuture(String responseString, String context){
		HDT_WRP_DocumentalResponse response = (HDT_WRP_DocumentalResponse) JSON.deserialize(responseString, HDT_WRP_DocumentalResponse.class);
		manageResponse(response,context);
	}

	private static void manageResponse(HDT_WRP_DocumentalResponse response, String context){
		try{
			SObject processRecord = HDT_UTL_DocumentalManagement.getProcessRecord((String) response.deliverPackageResponse.requestId, context);
			
			Id recordId = (Id)processRecord.get('Id');
			if(context == 'Order' || context == 'Case'){
				try{
					HDT_UTL_DocumentalManagement.updateDocumentalPhase(processRecord, response,context);
				}catch(Exception ex){
					System.debug(LoggingLevel.DEBUG, 'Errore ' + ex.getMessage() + ' at line ' + ex.getLineNumber());
				}
			}
			
			if(response.deliverPackageResponse.archive != null && response.deliverPackageResponse.archive == 'Y' ){
				if((response.responseCode == 200 || response.responseCode == 201) && response.deliverPackageResponse.result == '000'){
					String msg = response.deliverPackageResponse.message;
					String pkgId = response.deliverPackageResponse.packageIds;
					HDT_UTL_DocumentalManagement.createDocumentSendTracking(msg, recordId, pkgId, processRecord);
					HDT_UTL_DocumentalManagement.createDocumentEnvelopeAttachment(response, context);
					if(context == 'Order' && (String)processRecord.get('DocSendingMethod__c') != null && (String)processRecord.get('DocSendingMethod__c') == 'Stampa Cartacea'){
						Date dToday = Date.today();
						String dateStr = dToday.day() + '/' + dToday.month() + '/' + dToday.year();
						createPublicLink(recordId, response.deliverPackageResponse.composedDocument, 'Plico Contrattuale ' +dateStr);
					}
				}
			}
		}catch(Exception ex){
			System.debug(LoggingLevel.DEBUG, 'Errore ' + ex.getMessage() + ' at line ' + ex.getLineNumber());
		}
	}
	private static String composeJson(String recordId, List<Map<String,Object>> driverPayloadListMap,Map<String,Object> formParams,Map<String,List<sObject>> inputs){
		
		HDT_WRP_DocumentalRequest documentalRequest = new HDT_WRP_DocumentalRequest();
		HDT_WRP_DocumentalRequest.HDT_WRP_DocumentalPackage sPackage = new HDT_WRP_DocumentalRequest.HDT_WRP_DocumentalPackage();
		HDT_WRP_DocumentalRequest.HDT_WRP_DocumentalDeliverPackageRequest sPackageRequest = new HDT_WRP_DocumentalRequest.HDT_WRP_DocumentalDeliverPackageRequest();
		String mode = (String) formParams.get('mode') != null? (String) formParams.get('mode'):'';
		String context = (String) formParams.get('Contesto') != null? (String) formParams.get('Contesto'):'';
		String signMode = (String) formParams.get('signMode') != null? (String) formParams.get('signMode'):'';
		String parsedContext = '';
		String processNumber = '';
		
		try{
			if(context.equalsIgnoreCase('EC') || context.equalsIgnoreCase('GC') || context.equalsIgnoreCase('Account')){
				parsedContext = 'Case';
			}else if(context.equalsIgnoreCase('DocumentazioneAnticipata')){
				parsedContext='Order';
			}
			else {
				parsedContext=context;
			}
			if(context.equalsIgnoreCase('Case')){
				processNumber = HDT_UTL_DocumentalManagement.getValue('Case', 'CaseNumber', 0, inputs, formParams);
			}else if(context.equalsIgnoreCase('Order')){
				processNumber = HDT_UTL_DocumentalManagement.getValue('ParentOrder', 'OrderNumber', 0, inputs, formParams);
			}else if(context.equalsIgnoreCase('DocumentazioneAnticipata')){
				processNumber = HDT_UTL_DocumentalManagement.getValue('Order', 'OrderNumber', 0, inputs, formParams);
			}else{
				processNumber = recordId;
			}
			sPackageRequest.requestId = processNumber;
			sPackageRequest.objectName = parsedContext;
			sPackageRequest.objectId = recordId;
			sPackageRequest.signMode = signMode;
			sPackageRequest.mode = mode;
			sPackageRequest.documentId = '1';
			for(Map<String,Object> singleMap : driverPayloadListMap){
				sPackage = new HDT_WRP_DocumentalRequest.HDT_WRP_DocumentalPackage((List<HDT_WRP_DocumentalRequest.HDT_WRP_DocumentalDriver>)singleMap.get('driver'),(String)singleMap.get('payload'));
				sPackageRequest.sPackage.add(sPackage);
			}
			if(mode.equalsIgnoreCase('Print') && signMode.indexOf('OTP') >-1){
				sPackageRequest.signInfo = addDocusingInformation(formParams,inputs);
			}else{
				sPackageRequest.signInfo = new HDT_WRP_DocumentalRequest.HDT_WRP_DocumentalSignInfo();
			}
			documentalRequest.deliverPackageRequest = sPackageRequest;
		}catch(Exception ex){
			System.debug(LoggingLevel.DEBUG, ex.getMessage() + ' Line: ' + ex.getLineNumber());
		}
		return JSON.serialize(documentalRequest);
	}

	private static HDT_WRP_DocumentalRequest.HDT_WRP_DocumentalSignInfo addDocusingInformation(Map<String,Object> formParams,Map<String,List<sObject>> inputs){
		HDT_WRP_DocumentalRequest.HDT_WRP_DocumentalSignInfo signInfo = new HDT_WRP_DocumentalRequest.HDT_WRP_DocumentalSignInfo();
		HDT_WRP_DocumentalRequest.HDT_WRP_DocumentalCustomerInfo customerInfo = new HDT_WRP_DocumentalRequest.HDT_WRP_DocumentalCustomerInfo();
		HDT_WRP_DocumentalRequest.HDT_WRP_DocumentalTemplate templateInfo = new HDT_WRP_DocumentalRequest.HDT_WRP_DocumentalTemplate();
		try {
			//signInfo
			String rdsCase = HDT_UTL_DocumentalManagement.getValue('Case', 'CaseNumber', 0, inputs, formParams);
			String rdsOrder = HDT_UTL_DocumentalManagement.getValue('ParentOrder', 'OrderNumber', 0, inputs, formParams);
			String telephoneNumberCase = HDT_UTL_DocumentalManagement.getValue('Case','PhoneNumber__c',0,inputs,formParams);
			String telephoneNumberOrder = HDT_UTL_DocumentalManagement.getValue('ParentOrder','PhoneNumber__c',0,inputs,formParams);
			String telephoneNumber = '+39';
			String emailCase = HDT_UTL_DocumentalManagement.getValue('Case','Email__c',0,inputs,formParams);
			String emailOrder = HDT_UTL_DocumentalManagement.getValue('ParentOrder','ShippingMail__c',0,inputs,formParams);
			if(String.isNotBlank(telephoneNumberCase)){
				telephoneNumber = telephoneNumber + telephoneNumberCase;
			}else {
				telephoneNumber = telephoneNumber + telephoneNumberOrder;
			}
			
			DocusignSettings__c docusignCustomSettings = DocusignSettings__c.getInstance();
			signInfo.customerEnvironmentId = docusignCustomSettings.CustomerEnviromentId__c;
			signInfo.idCheckConfigurationName = docusignCustomSettings.IdCheckConfigurationName__c;
			signInfo.pageUrl = docusignCustomSettings.PageUrl__c;
			signInfo.requireIdLookup = docusignCustomSettings.RequireIdLookup__c;
			signInfo.transcodeTemplate = 'true';
			signInfo.status = docusignCustomSettings.Status__c;
			signInfo.senderProvidedNumbers.add(telephoneNumber);
			//customerInfo
			String email = String.isNotBlank(emailCase)?emailCase:emailOrder;
			String creationUrl = formParams.get('signMode') == 'OTP Remoto'? 'false':'true';
			String clientUserId = formParams.get('signMode') == 'OTP Coopresenza'? '1':null;
			String vatCode = HDT_UTL_DocumentalManagement.getValue('Account','VATNumber__c',0,inputs,formParams);
			String fiscalCode = HDT_UTL_DocumentalManagement.getValue('Account','FiscalCode__c',0,inputs,formParams);
			String accountName = HDT_UTL_DocumentalManagement.getValue('PrimaryContact','Name',0,inputs,formParams);
			String firstName = HDT_UTL_DocumentalManagement.getValue('PrimaryContact','FirstName',0,inputs,formParams);
			String lastName = HDT_UTL_DocumentalManagement.getValue('PrimaryContact','LastName',0,inputs,formParams);
			String processTypeCase = HDT_UTL_DocumentalManagement.getValue('Case','DocumentalProcessType__c',0,inputs,formParams);
			String cluster = HDT_UTL_DocumentalManagement.getValue('Case','Cluster__c',0,inputs,formParams);
			String processType = 'Plico contrattuale';
			Datetime today = Datetime.now(); 
			String rds = String.isNotBlank(rdsCase)? rdsCase : rdsOrder;
			if(String.isNotBlank(processTypeCase)){
				processType = processTypeCase;
			}
			if(String.isBlank(accountName)){
				firstName = HDT_UTL_DocumentalManagement.getValue('Case','FirstName__c',0,inputs,formParams);
				lastName = HDT_UTL_DocumentalManagement.getValue('Case','LastName__c',0,inputs,formParams);
				accountName = firstName + ' ' + lastName;
			}
			customerInfo.email = email;
			customerInfo.name = accountName;
			customerInfo.fiscalCode = fiscalCode;
			customerInfo.vatNumber = vatCode;
			customerInfo.creationUrl = creationUrl;
			customerInfo.clientUserId = clientUserId;
			customerInfo.emailSubject = 'HERA - ' + processType;
			customerInfo.roleName = 'Cliente';
			//@ealpi nuovi campi inviati
			customerInfo.rds = rds;
			customerInfo.dateCreationDocument = today.format('yyyy-MM-dd HH:mm:ss');
			customerInfo.dateLoadingDocument = today.format('yyyy-MM-dd HH:mm:ss');
			customerInfo.surnameCompanyName = lastName;
			customerInfo.nameCompanyName = firstName;
			if (formParams.containsKey('SettMerceologico')){
				customerInfo.commoditySector = (String)formParams.get('SettMerceologico');
			}
			String documentPrintType = '';
			if (processType == 'Plico contrattuale'){
				documentPrintType = 'C';
			}else if (cluster == 'Preventivi' || cluster == 'Verifiche'){
				documentPrintType = 'P';
			}else if (cluster == 'Pagamenti'){
				documentPrintType = 'D';
			}
			customerInfo.documentPrintType = documentPrintType;

			List<CS_DaysToExpiration__c> daysToExpiration = [SELECT NumberOfDays__c FROM CS_DaysToExpiration__c WHERE Type__c='BustaDocusign' WITH SECURITY_ENFORCED];
			if (!daysToExpiration.isEmpty() && Integer.valueOf(daysToExpiration[0].NumberOfDays__c) > 0) {
				customerInfo.expireEnabled = 'true';
				customerInfo.expireAfter = daysToExpiration[0].NumberOfDays__c;
			} else {
				customerInfo.expireEnabled = 'false';
			}

			signInfo.customerInfo = customerInfo;

			//template
			templateInfo.sequence = docusignCustomSettings.Sequence__c;
			templateInfo.templateId = docusignCustomSettings.TemplateId__c;
			signInfo.template = templateInfo;
		} catch (Exception ex) {
			System.debug(LoggingLevel.DEBUG, 'Error in method addDocusingInformation ' + ex.getLineNumber() + ' ' + ex.getMessage());
		}
		return signInfo;
	}
	
	private static List<HDT_WRP_DocumentalRequest.HDT_WRP_DocumentalDriver> generateDriver(Map<String,List<sObject>> inputs, HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalStructure configurations, Map<String,Object> formParams){
		
		//DEBUG
		String debugString = 'HDT_SRV_DocumentalManagement - generateDriver';
		System.debug(LoggingLevel.DEBUG, debugString);
		
		/*
            @Author: Davide Viola - 19/10/2021
            Description: PMD -> Commentate variabili non utilizzate.
        */
        /*List<Map<String,String>> driverListMap = new List<Map<String,String>>();
		Map<String,String> driverMap = new Map<String,String>();*/
		String value = '';
		
		HDT_WRP_DocumentalRequest.HDT_WRP_DocumentalDriver driver = new HDT_WRP_DocumentalRequest.HDT_WRP_DocumentalDriver();
		List<HDT_WRP_DocumentalRequest.HDT_WRP_DocumentalDriver> driverList = new List<HDT_WRP_DocumentalRequest.HDT_WRP_DocumentalDriver>();
		
		for(HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalSection singleSection : configurations.sections){
			
			List<HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalRecord> records = singleSection.records;

			for(HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalRecord singleRecord : records){
				
				String expression = singleRecord.expression!=null?singleRecord.expression:'';
				String classString = singleRecord.classString!=null?singleRecord.classString:'';
				String methodString = singleRecord.methodString!=null?singleRecord.methodString:'';
				String separetor = singleRecord.separetor!=null?singleRecord.separetor:'';
				String defaultVal = singleRecord.defaultVal!=null?singleRecord.defaultVal:'';
				String payloadField = singleRecord.payloadField!=null?singleRecord.payloadField:'';

				if(expression != null && expression != ''){
					value = HDT_UTL_DocumentalManagement.calculateExpression(inputs, expression, formParams);
				}
				//Nel caso in cui l'espressione ritorna $ deve essere ereditato il valore da uno dei controlli sotto
				if((expression != null && expression != '' && value == '$') || expression == ''){
					if(classString != null && classString != '' && methodString != null && methodString != ''){
						value = HDT_UTL_DocumentalManagement.getValueFromMethod(classString, methodString, inputs, formParams);
					}else if(separetor != null && separetor != ''){
							//TODO Implentare getConcatValue
							value = HDT_UTL_DocumentalManagement.getConcatValueFromObject(inputs,singleRecord);
							value = HDT_UTL_DocumentalManagement.removeSpecialChar(value);
					}else{
						value = HDT_UTL_DocumentalManagement.getValueFromObject(inputs, singleRecord, 0, formParams);
						value = HDT_UTL_DocumentalManagement.removeSpecialChar(value);
					}
					if(value == '' && defaultVal != null && defaultVal != ''){
						if(defaultVal == 'sysdate'){
							Date today = Date.today();
							defaultVal = HDT_UTL_DocumentalManagement.transformDate(today);
						}
						value = defaultVal;
					}
				}else{
					value = HDT_UTL_DocumentalManagement.removeSpecialChar(value);
				}
				//System.debug(LoggingLevel.DEBUG, 'Value for ' + payloadField + ' is : ' + value);
				driver.name = payloadField;
				driver.value = value;
				driverList.add(new HDT_WRP_DocumentalRequest.HDT_WRP_DocumentalDriver(driver));
			}	
		}
		return driverList;
	}
	
	private static String generatePayload(Map<String,List<sObject>> inputs,HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalStructure configurations,Map<String,Object> formParams){
		
		//DEBUG
		String debugString = 'HDT_SRV_DocumentalManagement - generatePayload';
		System.debug(LoggingLevel.DEBUG, debugString);
		
		String[] payloadArray = new List<String>();
		String payload = '';
		Boolean recordNull = true;
		String div='|';
		String fineRiga='\n';
		String value = '';
		/*
            @Author: Davide Viola - 19/10/2021
            Description: PMD -> Commentate variabili non utilizzate.
        */
        /*Map<String,String> context = new Map<String,String>();
		Map<String,String> iteratorContext = new Map<String,String>();*/
		Integer countRecords = 1;
		
		for(HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalSection singleSection : configurations.sections){
			String iterative = singleSection.iterative;
			String recordType = singleSection.recordType;
			String objectOne =  singleSection.object1;
			List<HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalRecord> records = singleSection.records;

			if(iterative == 'SI'){
				countRecords = HDT_UTL_DocumentalManagement.getChildCount(objectOne, inputs);
			}else{
				countRecords = 1;
			}
			
			for(Integer i = 0; i< countRecords; i++){
				payloadArray = new List<String>();
				payloadArray.add(recordType);
				for(HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalRecord singleRecord : records){
					String expression = singleRecord.expression!=null?singleRecord.expression:'';
					String classString = singleRecord.classString!=null?singleRecord.classString:'';
					String methodString = singleRecord.methodString!=null?singleRecord.methodString:'';
					String separetor = singleRecord.separetor!=null?singleRecord.separetor:'';
					String defaultVal = singleRecord.defaultVal!=null?singleRecord.defaultVal:'';

					if(expression != null && expression != ''){
						value = HDT_UTL_DocumentalManagement.calculateExpression(inputs,expression,formParams);
					}
					//Nel caso in cui l'espressione ritorna $ deve essere ereditato il valore da uno dei controlli sotto
					if((expression != null && expression != '' && value == '$') || expression == ''){
						if(classString != null && classString != '' && methodString != null && methodString != ''){
							value = HDT_UTL_DocumentalManagement.getValueFromMethod(classString,methodString,inputs,formParams);
						}else if(separetor != null && separetor != ''){
								//TODO Implentare getConcatValue
								value = HDT_UTL_DocumentalManagement.getConcatValueFromObject(inputs,singleRecord);
								value = HDT_UTL_DocumentalManagement.removeSpecialChar(value);
						}else{
							value = HDT_UTL_DocumentalManagement.getValueFromObject(inputs,singleRecord,i,formParams);
							value = HDT_UTL_DocumentalManagement.removeSpecialChar(value);
						}
						if(value == '' && defaultVal != null && defaultVal != ''){
							if(defaultVal == 'sysdate'){
								Date today = Date.today();
								defaultVal = HDT_UTL_DocumentalManagement.transformDate(today);
							}
							payloadArray.add(defaultVal);
						}else{
							payloadArray.add(value);
						}
					}else{
						value = HDT_UTL_DocumentalManagement.removeSpecialChar(value);
						payloadArray.add(value);
					}
					//VERIFICO SE HO SETTATO UN VALORE DIVERSO DA NULL, UTILIZZO LA VARIABILE recordNull PER CAPIRE SE TUTTO IL RECORD è COMPOSTO DA | VUOTI
					if(value != '' || defaultVal != ''){
						recordNull = false;
					}
				}
				if(!recordNull){
					payloadArray.add(fineRiga);
					payload += String.join(payloadArray, div);
					value = '';
					recordNull=true;
				}
			}	
		}
		//Blob payloadBlob = Blob.valueOf(payload);
		//payload = EncodingUtil.base64Encode(payloadBlob);
		return payload;		
	}

	/*

		Genera la porzione di payload relativa all'Estratto Conto, in particolare le sezioni 80 e 81.
		Esempio di stringa generata (con due CA, ognuno con una sezione 81):

		'00310|80|1|200000291833|bollettino postale|28.92|
		00310|81|2|Hera S.p.A.|X||||0000106000081527|NO|10/01/2006|28.92|28.92|||31/01/2006|
		00310|80|1|200000585749|bollettino postale|858.41|
		00310|81|2|HERA Comm Unipersonale|||X||0000406000130632|NO|01/02/2006|858.41|858.41|||23/02/2006|'

		*/

	public static String generatePayloadEstrattoConto(Map<String,Object> formParams){
		
		//DEBUG
		String debugString = 'HDT_SRV_DocumentalManagement - generatePayloadEstrattoConto';
		System.debug(LoggingLevel.DEBUG, debugString);
		
		String payload = '';
		String div='|';
		String fineRiga='\n';
		try {
			String servizioAcqua = 'ACQUA';
			String servizioEle = 'ENERGIA ELETTRICA';
			String servizioGas = 'GAS';
			String servizioAmbiente = 'AMBIENTE';
			String servizioTlr = '';
			String altriServizi = '';
			Boolean storno = false;
			String documents = (String) formParams.get('EstrattoConto');
			List<Object> primoLivelloList = (List<Object>)JSON.deserializeUntyped(documents);
			Map<String,Object> primolivello = (Map<String, Object>)primoLivelloList[0];
			List<Object> secondoLivelloList = new List<Object>();
			Map<String, Object> secondoLivello = new Map<String, Object>();
			System.debug(LoggingLevel.DEBUG, primolivello);
			
			//Inizializzo le variabili con i valori del primo record
			String previousCa = (String)primolivello.get('contoContrattuale');
			String previousModPagamento = (String)primolivello.get('modalitaPagamentoCA');
			/*
				@Author: Davide Viola - 19/10/2021
				Description: PMD -> Commentata variabile non utilizzata.
			*/
			//String previousSocieta = (String)primolivello.get('societa');
			Double residuoTotale = 0.0;
			String payloadRecordOttantuno = '';
			Integer i = -1;
			
			for (Object singleRecord : primoLivelloList) {
				i++;
				primolivello = (Map<String, Object>) singleRecord;
				secondoLivelloList = (List<Object>)primolivello.get('secondoLivelloInformativo');
				
				String currentCa = (String)primolivello.get('contoContrattuale');
				Double residuo = Double.valueOf(primolivello.get('residuo'));
				String modPagamento = (String)primolivello.get('modalitaPagamentoCA');
				String societa = (String)primolivello.get('societa');
				String tipoDocPareggio = ''; //TK 633881C
				String[] recordOttantuno = new List<String>();
				recordOttantuno.add('00310');
				recordOttantuno.add('81');
				recordOttantuno.add('2');
				recordOttantuno.add(societa);

				// Inizializziamo quattro elementi per i 4 flag servizio (Acqua, EE, Gas, Ambiente)
				for (Integer j = 0; j < 4; j++) {
					recordOttantuno.add('');
				}

				// Per valorizzare i 4 flag servizio bisogna scendere al secondo livello informativo.
				// TICKET 572291C: tracciamo se al secondo livello il motivo di pareggio è STORNO.
				
				for (Object singleRecordSecondoLivello : secondoLivelloList) {
					secondoLivello = (Map<String, Object>) singleRecordSecondoLivello;
					Integer n = recordOttantuno.size();
					String motivoDiPareggio = (String)secondoLivello.get('motivoDiPareggio');
					if (motivoDiPareggio == 'STORNO') {
						storno = true;
					} else {
						storno = false;
					}
					//TK 633881C: cerchiamo al secondo livello il campo TD_PAREGGIO, se valorizzato con 'VC'
					String tipoDocPareggioSecLivello = (String)secondoLivello.get('tdPareggio');
					if (String.isNotBlank(tipoDocPareggioSecLivello) && tipoDocPareggioSecLivello == 'VC') {
						tipoDocPareggio = 'VC';
					}
					
					String servizio = (String)secondoLivello.get('settoreMerceologico');
					servizio = servizio != null? servizio.toUpperCase():'';
					if (servizio == servizioAcqua) {
						recordOttantuno[(n-1) - 3] = 'X';
					} else if (servizio == servizioEle) {
						recordOttantuno[(n-1) - 2] = 'X';
					} else if (servizio == servizioGas) {
						recordOttantuno[(n-1) - 1] = 'X';
					} else if (servizio == servizioAmbiente) {
						recordOttantuno[(n-1)] = 'X';
					} else if (servizio == 'TELERISCALDAMENTO') {
						servizioTlr = 'X';
					} else if (servizio != '') {
						altriServizi = 'X';
					}
				}
				if(String.isNotBlank((String)primolivello.get('numeroDocumento'))){
					recordOttantuno.add((String)primolivello.get('numeroDocumento'));
				}else{
					String numeroFattura = (String)primolivello.get('numeroFattura') != null? (String)primolivello.get('numeroFattura'):'';
					for(Integer z = 0; z < numeroFattura.length(); z++){
						if(numeroFattura.charAt(z) != 0){
							numeroFattura = numeroFattura.substring(z,numeroFattura.length());
							recordOttantuno.add(numeroFattura);
							break;
						}
					}
					//recordOttantuno.add(childPrimoLivello.GetProperty('NumeroFattura'));
				}	
				recordOttantuno.add((String)primolivello.get('rateizzato'));
				if(String.isNotBlank((String)primolivello.get('dataEmissione'))){
					//String dataEmissione = new Date(childPrimoLivello.GetProperty('DataEmissione'));
					recordOttantuno.add((String)primolivello.get('dataEmissione'));
				}else{
					recordOttantuno.add('');
				}
				
				Double importo = Double.valueOf(primolivello.get('importo'));
				recordOttantuno.add(String.valueOf(importo));
				recordOttantuno.add(String.valueOf(residuo));
				String docStatus = HDT_UTL_DocumentalManagement.calculateDocumentStatus(importo, residuo, storno);
				recordOttantuno.add(docStatus);
				recordOttantuno.add((String)primolivello.get('Ceduta'));
				if(String.isNotBlank((String)primolivello.get('dataScadenza'))){
					//String dataScadenza = new Date(childPrimoLivello.GetProperty('DataScadenza'));
					recordOttantuno.add((String)primolivello.get('dataScadenza'));
				}else{
					recordOttantuno.add('');
				}
				//AGGIUNTI FLAG SERVIZI IN CODA PERCHE' PRIMA NON GESTITI
				recordOttantuno.add(servizioTlr);
				recordOttantuno.add(altriServizi);
				//NUOVI CAMPI aggiunti al tracciato per la Gestione Credito: CONTRATTO e TIPO_DOCUMENTO - Vuoti nell'EC
				recordOttantuno.add('');
				recordOttantuno.add('');
				recordOttantuno.add(tipoDocPareggio); //TK 633881C
				recordOttantuno.add(fineRiga);
				servizioTlr = '';
				altriServizi = '';
				
				// STESSO CA
				if (currentCa == previousCa) {
					residuoTotale += residuo;
					payloadRecordOttantuno += String.join(recordOttantuno,div);
				}

				// Nuovo E Ultimo CA. Quindi dobbiamo generare DUE record 80.
				String[] recordOttanta = new List<String>();
				if (currentCa != previousCa && i == primoLivelloList.size()-1) {
					recordOttanta.add('00310');
					recordOttanta.add('80');
					recordOttanta.add('1');
					recordOttanta.add(previousCa);
					recordOttanta.add(previousModPagamento);
					recordOttanta.add(String.valueOf(residuoTotale));
					recordOttanta.add(fineRiga);

					payload += String.join(recordOttanta,div) + payloadRecordOttantuno;

					residuoTotale = residuo;
					payloadRecordOttantuno = String.join(recordOttantuno,div);

					recordOttanta = new List<String>();
					recordOttanta.add('00310');
					recordOttanta.add('80');
					recordOttanta.add('1');
					recordOttanta.add(currentCa);
					recordOttanta.add(modPagamento);
					recordOttanta.add(String.valueOf(residuoTotale));
					recordOttanta.add(fineRiga);
					
					payload += String.join(recordOttanta,div) + payloadRecordOttantuno;
				} else if (currentCa != previousCa || i == primoLivelloList.size()-1) {
					// NUOVO CA, oppure il CA è l'ultimo. Quindi siamo pronti per generare il record 80.
					recordOttanta = new List<String>();
					recordOttanta.add('00310');
					recordOttanta.add('80');
					recordOttanta.add('1');
					recordOttanta.add(previousCa);
					recordOttanta.add(previousModPagamento);
					recordOttanta.add(String.valueOf(residuoTotale));
					recordOttanta.add(fineRiga);

					payload += String.join(recordOttanta,div) + payloadRecordOttantuno;

					// Reset Stringiabili globali che sono concatenate finchè il CA non cambia.
					residuoTotale = residuo;
					payloadRecordOttantuno = String.join(recordOttantuno,div);
					// Salviamo il nuovo CA.
					previousCa = currentCa;
					previousModPagamento = modPagamento;
				}
			}

			// Rimuoviamo lo \n alla fine.
			//Blob payloadBlob = Blob.valueOf(payload.substring(0, payload.length() - fineRiga.length()));
			//payload = EncodingUtil.base64Encode(payloadBlob);
			
		} catch (Exception ex) {
			System.debug(LoggingLevel.DEBUG, 'Errore nella generazione del Payload EC ' + ex.getMessage() + ' at line: ' + ex.getLineNumber());
		}
		return payload.substring(0, payload.length() - fineRiga.length());
	}

	/*

Genera la porzione di payload relativa alla vista Gestione Credito.

*/
	public static String generatePayloadGestioneCredito(Map<String,Object> formParams){
		
		//DEBUG
		String debugString = 'HDT_SRV_DocumentalManagement - generatePayloadGestioneCredito';
		System.debug(LoggingLevel.DEBUG, debugString);
		
		String payload = '';
		String div='|';
		String fineRiga='\n';
		try {
			String servizioAcqua = 'ACQUA';
			String servizioEle = 'ENERGIA ELETTRICA';
			String servizioGas = 'GAS';
			String servizioAmbiente = 'AMBIENTE';
			String servizioTlr = '';
			String altriServizi = '';
			
			Integer i = -1;
			String documents = (String) formParams.get('EstrattoConto');
			List<Object> primoLivelloList = (List<Object>)JSON.deserializeUntyped(documents);
			Map<String,Object> primolivello = (Map<String, Object>)primoLivelloList[0];
			/*
				@Author: Davide Viola - 19/10/2021
				Description: PMD -> Commentata variabile non utilizzata.
			*/
			/*List<Object> secondoLivelloList = new List<Object>();
			Map<String, Object> secondoLivello = new Map<String, Object>();*/
			System.debug(LoggingLevel.DEBUG, primolivello);
			
			Boolean ordineDiPagamento = false;

			String previousCa = (String)primolivello.get('contoContrattuale');
			String previousModPagamento = (String)primolivello.get('modalitaPagamentoCA');
			Double residuoTotale = 0;
			String payloadRecordOttantuno = '';

			for (Object singleRecord : primoLivelloList) {
				i++;
				primolivello = (Map<String, Object>) singleRecord;
				String currentCa = (String)primolivello.get('contoContrattuale');
				Double residuo = Double.valueOf(primolivello.get('residuo'));
				String modPagamento = (String)primolivello.get('modalitaPagamentoCA');
				
				if (String.isNotBlank((String)primolivello.get('ordineDiPagamento'))) {
					ordineDiPagamento = true;
				} else {
					ordineDiPagamento = false;	
				}
				
				String[] recordOttantuno = new List<String>();
				recordOttantuno.add('00310');
				recordOttantuno.add('81');
				recordOttantuno.add('2');
				recordOttantuno.add(''); // La stampa della Gestione Credito non prevede la società nel pdf.

				// Inizializziamo quattro elementi per i 4 flag servizio (Acqua, EE, Gas, Ambiente)
				for (Integer j = 0; j < 4; j++) {
					recordOttantuno.add('');
				}

				//Valorizziamo i 4 flag servizio e ci segnamo se siamo nel caso TLR o Altri Servizi.
				Integer n = recordOttantuno.size();
				String servizio = (String)primolivello.get('settoreMerceologico');
				servizio = servizio != null? servizio.toUpperCase():'';
				if (servizio == servizioAcqua) {
					recordOttantuno[(n-1) - 3] = 'X';
				} else if (servizio == servizioEle) {
					recordOttantuno[(n-1) - 2] = 'X';
				} else if (servizio == servizioGas) {
					recordOttantuno[(n-1) - 1] = 'X';
				} else if (servizio == servizioAmbiente) {
					recordOttantuno[(n-1)] = 'X';
				} else if (servizio == 'TELERISCALDAMENTO') {
					servizioTlr = 'X';
				} else if (servizio == 'ALTRI SERVIZI') {
					altriServizi = 'X';
				}

				if(String.isNotBlank((String)primolivello.get('documento'))){
					recordOttantuno.add((String)primolivello.get('documento'));
				}else{
					String numeroFattura = (String)primoLivello.get('numeroFattura');
					for(Integer z = 0; z < numeroFattura.length(); z++){
						if(numeroFattura.charAt(z) != 0){
							numeroFattura = numeroFattura.substring(z,numeroFattura.length());
							recordOttantuno.add(numeroFattura);
							break;
						}
					}
					//recordOttantuno.add((String)primoLivello.get('numeroFattura'));
				}
				recordOttantuno.add((String)primoLivello.get('rateizzato'));
				if(String.isNotBlank((String)primoLivello.get('dataEmissione'))){
					String dataEmissione = (String)primoLivello.get('dataEmissione');
					recordOttantuno.add(dataEmissione);
				}else{
					recordOttantuno.add('');
				}
				
				recordOttantuno.add('');
				
				if (ordineDiPagamento) {
					recordOttantuno.add('0');
				} else {
					recordOttantuno.add(String.valueOf(residuo));
				}
				String ufficioIncassi = primolivello.get('recuperoCrediti') != null? (String) primolivello.get('recuperoCrediti'):'';
				String docStatus = HDT_UTL_DocumentalManagement.calculateDocumentStatusGc(ufficioIncassi, residuo, ordineDiPagamento);
				recordOttantuno.add(docStatus);
				recordOttantuno.add((String)primoLivello.get('Ceduta'));
				if(String.isNotBlank((String)primoLivello.get('dataScadenza'))){
					recordOttantuno.add((String)primoLivello.get('dataScadenza'));
				}else{
					recordOttantuno.add('');
				}
				//AGGIUNTI FLAG SERVIZI IN CODA PERCHE' PRIMA NON GESTITI
				recordOttantuno.add(servizioTLR);
				recordOttantuno.add(altriServizi);

				servizioTLR = '';
				altriServizi = '';
				//NUOVI CAMPI aggiunti al tracciato per la Gestione Credito: CONTRATTO e TIPO_DOCUMENTO 
				recordOttantuno.add((String)primoLivello.get('contratto'));
				recordOttantuno.add((String)primoLivello.get('tipoDocumento'));
				recordOttantuno.add(fineRiga);

				// STESSO CA
				if (currentCa == previousCa) {
					if (!ordineDiPagamento) {
						residuoTotale += residuo;
					}
					payloadRecordOttantuno += String.join(recordOttantuno,div);
				}

				// Nuovo E Ultimo CA. Quindi dobbiamo generare DUE record 80.
				String[] recordOttanta = new List<String>();
				if (currentCa != previousCa && i == primoLivelloList.size() - 1) {
					recordOttanta = new List<String>();
					recordOttanta.add('00310');
					recordOttanta.add('80');
					recordOttanta.add('1');
					recordOttanta.add(previousCa);
					recordOttanta.add(previousModPagamento);
					recordOttanta.add(String.valueOf(residuoTotale));
					recordOttanta.add(fineRiga);

					payload += String.join(recordOttanta,div) + payloadRecordOttantuno;

					residuoTotale = residuo;
					payloadRecordOttantuno = String.join(recordOttantuno,div);

					recordOttanta = new List<String>();
					recordOttanta.add('00310');
					recordOttanta.add('80');
					recordOttanta.add('1');
					recordOttanta.add(currentCa);
					recordOttanta.add(modPagamento);
					recordOttanta.add(String.valueOf(residuoTotale));
					recordOttanta.add(fineRiga);
					
					payload += String.join(recordOttanta,div) + payloadRecordOttantuno;
				} else if (currentCa != previousCa || i == primoLivelloList.size() - 1) {
					// NUOVO CA, oppure il CA è l'ultimo. Quindi siamo pronti per generare il record 80.
					recordOttanta = new List<String>();
					recordOttanta.add('00310');
					recordOttanta.add('80');
					recordOttanta.add('1');
					recordOttanta.add(previousCa);
					recordOttanta.add(previousModPagamento);
					recordOttanta.add(String.valueOf(residuoTotale));
					recordOttanta.add(fineRiga);

					payload += String.join(recordOttanta,div) + payloadRecordOttantuno;

					// Reset variabili globali che sono concatenate finchè il CA non cambia.
					residuoTotale = residuo;
					payloadRecordOttantuno = String.join(recordOttantuno,div);
					// Salviamo il nuovo CA.
					previousCa = currentCa;
					previousModPagamento = modPagamento;
				}
			}

			// Rimuoviamo lo \n alla fine.
			//Blob payloadBlob = Blob.valueOf(payload.substring(0, payload.length() - fineRiga.length()));
			//payload = EncodingUtil.base64Encode(payloadBlob);

		} catch (Exception ex) {
			System.debug(LoggingLevel.DEBUG, 'Errore nella generazione del Payload GC ' + ex.getMessage() + ' at line: ' + ex.getLineNumber());
		}
		return payload.substring(0, payload.length() - fineRiga.length());
	}
	
	// Restituisce il tipo di documento archiviato: 'zip' se il documento è stato firmato con OTP, 'pdf' altrimenti.
	public static String getDocumentType(SObject documentalObject){
		if (documentalObject == null) {
			throw new HDT_UTL_HeraException('Errore interno nel recupero del documento archiviato.');
		}

		String signMode = '';

		if (documentalObject.getSobjectType() == DocumentalActivity__c.getSObjectType()) {
			DocumentalActivity__c documentalActivity = (DocumentalActivity__c) documentalObject;
			if (String.isNotBlank(documentalActivity.CaseId__c)) {
				Case c = (Case) documentalActivity.CaseId__r;
				signMode = c.SignMode__c;
			} else if (String.isNotBlank(documentalActivity.OrderId__c)) {
				Order o = (Order) documentalActivity.OrderId__r;
				signMode = o.SignatureMethod__c;
			}
		} else if (documentalObject.getSobjectType() == DocumentSendTracking__c.getSObjectType()) {
			DocumentSendTracking__c documentSendTracking = (DocumentSendTracking__c) documentalObject;
			if (String.isNotBlank(documentSendTracking.Case__c)) {
				Case c = (Case) documentSendTracking.Case__r;
				signMode = c.SignMode__c;
			} else if (String.isNotBlank(documentSendTracking.Order__c)) {
				Order o = (Order) documentSendTracking.Order__r;
				signMode = o.SignatureMethod__c;
			}
		}
		if (String.isNotBlank(signMode)) {
			return signMode.contains('OTP') ? 'zip' : 'pdf';	
		}else {
			return 'pdf';
		}
		
	}

	public static String getSignModeConfiguration(String processType, String source){
        String configurationJson = '';
		try{
			Map<String,String> sendMode = new Map<String,String>();
			Map<String,String> signMode = new Map<String,String>();
			List<HDT_WRP_SignModeConfiguration> signSendConfigurationList = new List<HDT_WRP_SignModeConfiguration>();
			HDT_WRP_SignModeConfiguration signSendConfiguration = new HDT_WRP_SignModeConfiguration();
			List<HDT_SignModeSettings__mdt> signModeSettingsList = HDT_QR_DocumentalConfiguration.getSignModeSettings(processType,source);
			System.debug(LoggingLevel.DEBUG, 'signModeSettingsList: ' + signModeSettingsList);
			for(HDT_SignModeSettings__mdt singleRecord : signModeSettingsList){
				System.debug(LoggingLevel.DEBUG, 'processing sign mode: ' + singleRecord.SignMode__c);
				sendMode = new Map<String,String>();
				signMode = new Map<String,String>();
				signSendConfiguration = new HDT_WRP_SignModeConfiguration();
				signMode.put('label', singleRecord.SignMode__c);
				signMode.put('value', singleRecord.SignMode__c);
				signSendConfiguration.signMode = new Map<String,String>(signMode);

				if (source == 'Sportello' && singleRecord.SignMode__c == 'Cartacea'){ // workaround per non far esplodere il numero di configurazioni in HDT_SignModeSettings__mdt
					System.debug(LoggingLevel.DEBUG, 'forcing send mode Stampa Cartacea');
					sendMode.put('label','Stampa Cartacea');
					sendMode.put('value','Stampa Cartacea');
					signSendConfiguration.sendMode.add(new Map<String,String>(sendMode));
				} else {
					if(singleRecord.SendMode1__c != null && singleRecord.SendMode1__c != ''){
						System.debug(LoggingLevel.DEBUG, 'adding send mode: ' + singleRecord.SendMode1__c);
						sendMode.put('label',singleRecord.SendMode1__c);
						sendMode.put('value',singleRecord.SendMode1__c);
						Map<String,String> prova = new Map<String,String>(sendMode);
						signSendConfiguration.sendMode.add(prova);
					}
					if(singleRecord.SendMode2__c != null && singleRecord.SendMode2__c != ''){
						System.debug(LoggingLevel.DEBUG, 'adding send mode: ' + singleRecord.SendMode2__c);
						sendMode.put('label',singleRecord.SendMode2__c);
						sendMode.put('value',singleRecord.SendMode2__c);
						signSendConfiguration.sendMode.add(new Map<String,String>(sendMode));
					}
					if(singleRecord.SendMode3__c != null && singleRecord.SendMode3__c != ''){
						System.debug(LoggingLevel.DEBUG, 'adding send mode: ' + singleRecord.SendMode3__c);
						sendMode.put('label',singleRecord.SendMode3__c);
						sendMode.put('value',singleRecord.SendMode3__c);
						signSendConfiguration.sendMode.add(new Map<String,String>(sendMode));
					}
				}

				signSendConfigurationList.add(new HDT_WRP_SignModeConfiguration(signSendConfiguration));
			}
			configurationJson = JSON.serialize(signSendConfigurationList);
		}catch(Exception ex){
            configurationJson = ex.getMessage() + ' ' + ex.getLineNumber();
        }
        return configurationJson;
    }

	public static void logEmailForAccountStatement(String recordId, String formParams) {
		if (String.isBlank(recordId) || String.isBlank(formParams)){
			System.debug(LoggingLevel.WARN, 'Invalid inputs for logEmailForAccountStatement method');
			return;
		}

		Map<String,Object> formParamsMap = formParams != null? (Map<String,Object>) JSON.deserializeUntyped(formParams) : new Map<String,Object>();
		String email = (String) formParamsMap.get('email');

		if (String.isBlank(email)) {
			System.debug(LoggingLevel.WARN, 'logEmailForAccountStatement: empty email');
			return;
		}

		Account acc = new Account();
		acc.Id = recordId;
		acc.LastUsedPostelEmail__c = email;

		try {
			HDT_UTL_DatabaseService.updateSObject(acc);
		} catch(Exception ex) {
			System.debug(LoggingLevel.DEBUG, 'DLM error: ' + ex.getMessage());
		}
	}

	// Aggiorna la fase del Case o Order a 'Comunicazione EngageOne KO'
	public static void logDiscardPhase(Id idToUpdate) {
		SObject objToUpdate = idToUpdate.getSObjectType().newSObject(idToUpdate);
		objToUpdate.put('Phase__c', 'Comunicazione EngageOne KO');
		try {
			HDT_UTL_DatabaseService.updateSObject(objToUpdate);
		} catch (Exception e) {
			System.debug(LoggingLevel.DEBUG, 'exception at line ' + e.getLineNumber() + ' ' + e.getMessage());
		}
	}

	public class HDT_WRP_SignModeConfiguration{
		Map<String,String> signMode;
		List<Map<String,String>> sendMode;

		public HDT_WRP_SignModeConfiguration(HDT_WRP_SignModeConfiguration config){
			this.signMode = config.signMode;
			this.sendMode = new List<Map<String,String>>();
			this.sendMode.addAll(config.sendMode);
		}
		public HDT_WRP_SignModeConfiguration(){
			this.signMode = new Map<String,String>();
			this.sendMode = new List<Map<String,String>>();
		}
	}

	public static String queryContactPoint(String email,String phone,String contactId){
		List<SObject> cpEmailList = new List<Sobject>();
		List<SObject> parentSobj = new List<SObject>();
		String sobjName = ((Id)contactId).getSObjectType().getDescribe().getName();
		if( sobjName == 'Lead')
		{
			parentSobj = [SELECT Id, IndividualId FROM Lead WHERE Id = :contactId WITH SECURITY_ENFORCED];
		}
		else 
		{
			parentSobj = [SELECT Id, IndividualId FROM Contact WHERE Id = :contactId WITH SECURITY_ENFORCED];	
		}
		if(String.isNotBlank(email)){
			cpEmailList =HDT_QR_GenericQuery.getGenericRecords('Id', 'ContactPointEmail', 'EmailAddress =\''+String.escapeSingleQuotes(email)+'\' AND ParentId=\''+parentSobj[0].get('IndividualId')+'\'');
			if(cpEmailList.isEmpty() && sobjName == 'Contact')
			{
				cpEmailList =HDT_QR_GenericQuery.getGenericRecords('Id', 'ContactPointEmail', 'EmailAddress =\''+String.escapeSingleQuotes(email)+'\' AND Contact__c=\''+contactId+'\'');
			}
		}
		List<SObject> cpPhone = new List<Sobject>();
		if(String.isNotBlank(phone)){
			cpPhone = HDT_QR_GenericQuery.getGenericRecords('Id', 'ContactPointPhone', 'TelephoneNumber =\''+String.escapeSingleQuotes(phone)+'\' AND ParentId=\''+parentSobj[0].get('IndividualId')+'\'');
			if(cpPhone.isEmpty() && sobjName == 'Contact')
			{
				cpPhone = HDT_QR_GenericQuery.getGenericRecords('Id', 'ContactPointPhone', 'TelephoneNumber =\''+String.escapeSingleQuotes(phone)+'\' AND Contact__c=\''+contactId+'\'');
			}
		}	
		Map<String,String> result = new Map<String,String>();
		if((!cpEmailList.isEmpty() && !cpPhone.isEmpty()) || (String.isBlank(email) && String.isBlank(phone))
		||(!cpEmailList.isEmpty() && cpPhone.isEmpty() && String.isBlank(phone))
		||(cpEmailList.isEmpty() && String.isBlank(email) && !cpPhone.isEmpty())){
			result.put('email', 'OK');
			result.put('phone', 'OK');
			result.put('result', 'OK');
		}else if(cpEmailList.isEmpty() && cpPhone.isEmpty() && String.isNotBlank(email) && String.isNotBlank(phone)){
			result.put('email', 'KO');
			result.put('phone', 'KO');
			result.put('result', 'KO');
			result.put('message', 'Attenzione! Scegliendo di procedere verrano creati i contact point: ' + email + ' e ' + phone);
		}else if(cpEmailList.isEmpty() && String.isNotBlank(email)){
			result.put('email', 'KO');
			result.put('phone', 'OK');
			result.put('result', 'KO');
			result.put('message', 'Attenzione! Scegliendo di procedere verrà creato il contact point: ' + email); 
		}else if(cpPhone.isEmpty() && String.isNotBlank(phone)) {
			result.put('email', 'OK');
			result.put('phone', 'KO');
			result.put('result', 'KO');
			result.put('message', 'Attenzione! Scegliendo di procedere verrà creato il contact point: ' + phone);
		}
		return JSON.serialize(result);
	}

	public static String createContactPoint(String email,String phone,String contactId){
		String result = 'OK';
		String sobjName = ((Id)contactId).getSObjectType().getDescribe().getName();
		try{
			HDT_QR_Contact qrContact = new HDT_QR_Contact();
			SObject sobj;
			if(sobjName == 'Contact')
			{
				sobj = qrContact.getRecordById(contactId);
			}
			else
			{
				sobj = [SELECT Id, IndividualId FROM Lead WHERE Id = :contactId WITH SECURITY_ENFORCED LIMIT 1]; 
			}
			List<SObject> objectList = new List<SObject>();
			if(String.isNotBlank(email)){
				ContactPointEmail cpEmail = new ContactPointEmail();
				cpEmail.ParentId = (String) sobj.get('IndividualId');
				cpEmail.EmailAddress = email;
				cpEmail.Type__c = 'E-mail Anagrafica';
				if(sobjName == 'Contact')
				{
					cpEmail.Contact__c = contactId;
				}
				objectList.add(cpEmail);
			}
	
			if(String.isNotBlank(phone)){
				ContactPointPhone cpPhone = new ContactPointPhone();
				cpPhone.ParentId = (String) sobj.get('IndividualId');
				cpPhone.TelephoneNumber = phone;
				cpPhone.Type__c = 'Mobile';
				if(sobjName == 'Contact')
				{
					cpPhone.Contact__c = contactId;
				}
				cpPhone.Prefix__c = '+39';
				objectList.add(cpPhone);
			}
			if(!objectList.isEmpty()){
				HDT_UTL_DatabaseService.insertSObject(objectList);
			}
		}catch(Exception ex){
			result = 'KO';
		}
		return result;
	}
}