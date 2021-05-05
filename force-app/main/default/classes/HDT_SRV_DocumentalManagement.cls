public class HDT_SRV_DocumentalManagement{
	 
	public static String generateRequest(String recordId, String context, String formParams){
		String payload = '';
		String body = '';
		List<HDT_WRP_DocumentalRequest.HDT_WRP_DocumentalDriver> driver = new List<HDT_WRP_DocumentalRequest.HDT_WRP_DocumentalDriver>();
		Map<String,Object> driverPayloadMap = new Map<String,Object>();
		List<Map<String,Object>> driverPayloadListMap = new List<Map<String,Object>>();
		Map<String,Object> formParamsMap = formParams != null? (Map<String,Object>) JSON.deserializeUntyped(formParams) : new Map<String,Object>();
		String documentalContext = HDT_UTL_DocumentalManagement.getDocumentalContext(context);
		HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalStructure payloadStructure = HDT_UTL_DocumentalManagement.getDocumentalConfiguration(documentalContext);
		HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalStructure driverStructure = HDT_UTL_DocumentalManagement.getDocumentalConfiguration('Driver');
		HDT_WRP_IntegrationObject.HDT_WRP_IntegrationParentObject integrationObjConfig =  HDT_UTL_IntegrationObject.getIntegrationObjectConfiguration('HDT_IntegrationObject__mdt', 'Id, JSON__c', 'DeveloperName = \'Documentale_'+ documentalContext + '\'', 'JSON__c');
		Map<String,String> recordQueryMap = HDT_UTL_IntegrationObject.generateQueryString(integrationObjConfig,recordId); 
		List<sObject> recordList = HDT_QR_GenericQuery.getGenericRecords(recordQueryMap.get('queryString'), recordQueryMap.get('parentObject'));
		List<Map<String,List<sObject>>> recordObjectsListMap = HDT_UTL_DocumentalManagement.getRecordObjectsList(recordList,documentalContext);
		formParamsMap.put('Contesto',context);
		for(Integer i=0; i < recordObjectsListMap.size(); i++){
			driver = generateDriver(recordObjectsListMap[i], payloadStructure,formParamsMap);
			payload = generatePayload(recordObjectsListMap[i], payloadStructure,formParamsMap);
			//System.debug(payload);
			driverPayloadMap.put('driver', driver);
			driverPayloadMap.put('payload', payload);
			driverPayloadListMap.add(new Map<String,Object>(driverPayloadMap));
		}
		body = composeJSON(recordId, driverPayloadListMap);
		//System.debug(body);
		//HDT_WRP_DocumentalResponse documentalResponse = new HDT_WRP_DocumentalResponse();
		//HDT_WS_DocumentalIntegration service = new HDT_WS_DocumentalIntegration();
		//documentalResponse = HDT_WS_DocumentalIntegration.submitRequest(body);
		//manageResponseFuture(JSON.serialize(documentalResponse), context);
		//System.debug(documentalResponse);
		return body;
	}
	@future
	public static void createPublicLinkFuture(String recordId,String base64,String fileName){
		String publicLink = createPublicLink(recordId,base64,fileName);
		//updateOrder con link?
	}
	public static String createPublicLink(String recordId,String base64,String fileName){
		try {
			ContentVersion cv = HDT_UTL_DocumentalManagement.createContectVersion(base64,fileName);
			ContentDocumentLink cl = HDT_UTL_DocumentalManagement.createContentLink(cv.Id, recordId);
			String publicLink =  HDT_UTL_DocumentalManagement.createContentDistribution(cv.Id);
			return publicLink;
		} catch (Exception ex) {
			System.debug('Errore ' + ex.getMessage() + ' at line ' + ex.getLineNumber());
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

	@future
	private static void manageResponseFuture(String responseString, String context){
		HDT_WRP_DocumentalResponse response = (HDT_WRP_DocumentalResponse) JSON.deserialize(responseString, HDT_WRP_DocumentalResponse.class);
		manageResponse(response,context);
	}

	private static void manageResponse(HDT_WRP_DocumentalResponse response, String context){
		try{
			SObject processRecord = HDT_UTL_DocumentalManagement.getProcessRecord((Id) response.deliverPackageResponse.requestId, context);
			if(context == 'Order' || context == 'Case'){
				HDT_UTL_DocumentalManagement.updateDocumentalPhase(processRecord, response);
			}
			if(response.deliverPackageResponse.archive != null && response.deliverPackageResponse.archive == 'Y' ){
				if(response.responseStatus == 200 || response.responseStatus == 201 ){
					HDT_UTL_DocumentalManagement.createDocumentSendTracking(response.deliverPackageResponse.message,response.deliverPackageResponse.requestId, response.deliverPackageResponse.packageIds,processRecord);
					HDT_UTL_DocumentalManagement.createDocumentEnvelopeAttachment(response,context);
				}
			}
		}catch(Exception ex){
			System.debug('Errore ' + ex.getMessage() + ' at line ' + ex.getLineNumber());
		}
	}
	private static String composeJSON(String recordId, List<Map<String,Object>> driverPayloadListMap){
		HDT_WRP_DocumentalRequest documentalRequest = new HDT_WRP_DocumentalRequest();
		HDT_WRP_DocumentalRequest.HDT_WRP_DocumentalPackage sPackage = new HDT_WRP_DocumentalRequest.HDT_WRP_DocumentalPackage();
		HDT_WRP_DocumentalRequest.HDT_WRP_DocumentalDeliverPackageRequest sPackageRequest = new HDT_WRP_DocumentalRequest.HDT_WRP_DocumentalDeliverPackageRequest();
		try{
			sPackageRequest.requestId = recordId;
			for(Map<String,Object> singleMap : driverPayloadListMap){
				//sPackage.driver = singleMap.get('driver');
				//sPackage.payload = singleMap.get('payload');
				sPackage = new HDT_WRP_DocumentalRequest.HDT_WRP_DocumentalPackage((List<HDT_WRP_DocumentalRequest.HDT_WRP_DocumentalDriver>)singleMap.get('driver'),(String)singleMap.get('payload'));
				
				sPackageRequest.sPackage.add(sPackage);
			}
			documentalRequest.deliverPackageRequest = sPackageRequest;
		}catch(Exception ex){
			System.debug(ex.getMessage() + ' Line: ' + ex.getLineNumber());
		}
		return JSON.serialize(documentalRequest);
	}
	private static List<HDT_WRP_DocumentalRequest.HDT_WRP_DocumentalDriver> generateDriver(Map<String,List<sObject>> inputs,HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalStructure configurations,Map<String,Object> formParams){
		List<Map<String,String>> driverListMap = new List<Map<String,String>>();
		Map<String,String> driverMap = new Map<String,String>();
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
						value = HDT_UTL_DocumentalManagement.getValueFromObject(inputs,singleRecord,0,formParams);
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
				driver.name = payloadField;
				driver.value = value;
				driverList.add(new HDT_WRP_DocumentalRequest.HDT_WRP_DocumentalDriver(driver));
			}	
		}
		return driverList;
	}
	
	private static String generatePayload(Map<String,List<sObject>> inputs,HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalStructure configurations,Map<String,Object> formParams){
		String[] payloadArray = new List<String>();
		String payload = '';
		Boolean recordNull = true;
		String div='|';
		String fineRiga='\n';
		String value = '';
		Map<String,String> context = new Map<String,String>();
		Map<String,String> iteratorContext = new Map<String,String>();
		Integer countRecords = 1;
		for(HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalSection singleSection : configurations.sections){
			String iterative = singleSection.iterative;
			String recordType = singleSection.recordType;
			String object1 =  singleSection.object1;
			List<HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalRecord> records = singleSection.records;

			if(iterative == 'SI'){
				countRecords = HDT_UTL_DocumentalManagement.getChildCount(object1, inputs);
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
					if(value != '' || defaultVal != '')
						recordNull = false;
				}
				if(!recordNull){
					payloadArray.add(fineRiga);
					payload += String.join(payloadArray, div);
					value = '';
				}
			}	
		}
		Blob payloadBlob = Blob.valueOf(payload);
		payload = EncodingUtil.base64Encode(payloadBlob);
		return payload;		
	}

	public static String getSignModeConfiguration(String processType, String source){
        String configurationJSON = '';
		try{
			Map<String,String> sendMode = new Map<String,String>();
			Map<String,String> signMode = new Map<String,String>();
			List<HDT_WRP_SignModeConfiguration> signSendConfigurationList = new List<HDT_WRP_SignModeConfiguration>();
			HDT_WRP_SignModeConfiguration signSendConfiguration = new HDT_WRP_SignModeConfiguration();
			List<HDT_SignModeSettings__mdt> signModeSettingsList = HDT_QR_DocumentalConfiguration.getSignModeSettings(processType,source);
			for(HDT_SignModeSettings__mdt singleRecord : signModeSettingsList){
				sendMode = new Map<String,String>();
				signMode = new Map<String,String>();
				signSendConfiguration = new HDT_WRP_SignModeConfiguration();
				signMode.put('label', singleRecord.SignMode__c);
				signMode.put('value', singleRecord.SignMode__c);
				signSendConfiguration.signMode = new Map<String,String>(signMode);
				if(singleRecord.SendMode1__c != null && singleRecord.SendMode1__c != ''){
					sendMode.put('label',singleRecord.SendMode1__c);
					sendMode.put('value',singleRecord.SendMode1__c);
					Map<String,String> prova = new Map<String,String>(sendMode);
					signSendConfiguration.sendMode.add(prova);
				}
				if(singleRecord.SendMode2__c != null && singleRecord.SendMode2__c != ''){
					sendMode.put('label',singleRecord.SendMode2__c);
					sendMode.put('value',singleRecord.SendMode2__c);
					signSendConfiguration.sendMode.add(new Map<String,String>(sendMode));
				}
				if(singleRecord.SendMode3__c != null && singleRecord.SendMode3__c != ''){
					sendMode.put('label',singleRecord.SendMode3__c);
					sendMode.put('value',singleRecord.SendMode3__c);
					signSendConfiguration.sendMode.add(new Map<String,String>(sendMode));
				}
				signSendConfigurationList.add(new HDT_WRP_SignModeConfiguration(signSendConfiguration));
			}
			configurationJSON = JSON.serialize(signSendConfigurationList);
		}catch(Exception ex){
            configurationJSON = ex.getMessage() + ' ' + ex.getLineNumber();
        }
        return configurationJSON;
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
}