public inherited sharing class HDT_UTL_DocumentalManagement {
	public static List<Map<String,List<sObject>>> getRecordObjectsList(List<SObject> recordsList,String context){
		List<Map<String,List<sObject>>> toReturn = new List<Map<String,List<sObject>>>();
		switch on context {
			when 'Context1' {
				return getRecordObjectsListContext1(recordsList);
			}
			when else {
				return null;
			}
		}
	}
	private static Boolean isSignNeeded(HDT_WRP_DocumentalResponse response){
		List<HDT_WRP_DocumentalResponse.HDT_WRP_DocumentalResponseAttachment> attachmentList = new List<HDT_WRP_DocumentalResponse.HDT_WRP_DocumentalResponseAttachment>();
		attachmentList.addAll(response.deliverPackageResponse.serviceList[0].attachmentList);
		for(HDT_WRP_DocumentalResponse.HDT_WRP_DocumentalResponseAttachment singleAttachment : attachmentList){
			if(singleAttachment.mandatory == 'Y')
				return true;
		}
		return false;
	}
	public static Boolean updateDocumentalPhase(sObject processRecord, HDT_WRP_DocumentalResponse response ){
		String archive = response.deliverPackageResponse.archive;
		String result = response.deliverPackageResponse.result;
		if(result == 'OK'){
			if(archive == 'Y'){
				processRecord.put('DocumentalPhase__c','Preview');
			}else{
				if(isSignNeeded(response)){
					processRecord.put('DocumentalPhase__c','Plico in firma');
				}else {
					processRecord.put('DocumentalPhase__c','Plico inviato');
				}
			}
		}else {
			processRecord.put('DocumentalPhase__c','Errore composizione');
		}
		return HDT_UTL_DatabaseService.updateSObject(processRecord);
	}

	public static sObject getProcessRecord(Id requestId, String context){
		String fieldQ = '';
		String fromQ = '';
		String whereQ = 'Id = \''+requestId + '\'';
		String queryString = 'SELECT ';
		switch on context {
			when 'Order' {
				fieldQ = 'Id, AccountId,DocSendingMethod__c,Email__c,SignMode__c,DocumentalPhase__c';
				fromQ = 'Order';
			}
			when 'Case'{
				fieldQ = 'Id, AccountId,SendMode__c ,Email__c,SignMode__c,DocumentalPhase__c';
				fromQ = 'Case';
			}
			when else {
				fieldQ = 'Id, AccountId,SendMode__c ,Email__c';
				fromQ = 'Account';
			}
		}
		queryString += fieldQ + ' FROM ' + fromQ + ' WHERE ' + whereQ;
		List<sObject> toReturnList = HDT_QR_GenericQuery.getGenericRecords(queryString, fromQ);
		return toReturnList[0];
	}
	public static void createDocumentSendTracking(String message, Id requestId, String envelopeId,sObject processRecord){
		try {
			String sObjName = requestId.getSObjectType().getDescribe().getName();
			DocumentSendTracking__c documentalSendTracking = new DocumentSendTracking__c ();
			/*switch on sObjName {
				when 'Case' {
					documentalSendTracking.CaseId__c = requestId;
					documentalSendTracking.AccountId__c = processRecord.get('AccountId ');
					documentalSendTracking.Receiver__c = processRecord.get('Email__c');
					documentalSendTracking.SendMode__c = processRecord.get('SendMode__c'); 
				}
				when 'Order' {
					documentalSendTracking.OrderId__c = requestId;
					documentalSendTracking.AccountId__c = processRecord.get('AccountId');
					documentalSendTracking.SendMode__c = processRecord.get('DocSendingMethod__c'); 
					documentalSendTracking.Receiver__c = processRecord.get('Email__c');
				}
				when else {
					documentalSendTracking.AccountId__c = processRecord.get('Id');
					documentalSendTracking.Receiver__c = processRecord.get('PrimaryEmail__c');
				}
			}*/
			documentalSendTracking.SendDate__c = Date.today();
			documentalSendTracking.EnvelopeId__c = envelopeId;
			Boolean result = HDT_UTL_DatabaseService.insertSObject(documentalSendTracking);
		} catch (Exception ex) {
			System.debug('Errore ' + ex.getMessage() + ' at line ' + ex.getLineNumber());
		}
	}
	private static List<Map<String,List<sObject>>> getRecordObjectsListContext1(List<SObject> recordsList){
		Case caseObject = (Case) recordsList[0];
		Account accountObject = (Account) caseObject.Account;
		Contract contractObject = (Contract) caseObject.Contract__r;
		List<DocumentSelected__c> documentSelectedObjectList = (List<DocumentSelected__c> ) caseObject.documenti_selezionati__r;
		List<sObject> listCase = new List<sObject>();
		listCase.add(caseObject);
		System.debug('listCase ' + listCase);
		List<sObject> listAccount = new List<sObject>();
		listAccount.add(accountObject);
		List<sObject> listContract = new List<sObject>();
		listContract.add(contractObject);
		Map<String,List<sObject>> mapStringObjectRecords = new Map<String,List<sObject>>{
			'Case' => listCase, 'Account' => listAccount, 'Contract' => listContract, 'DocumentSelected__c' => documentSelectedObjectList
		};
		List<Map<String,List<sObject>>> toReturn = new List<Map<String,List<sObject>>>();
		toReturn.add(mapStringObjectRecords);
		return toReturn;

	}

	public static HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalStructure getDocumentalConfiguration(String context){
		List<Document> documentList = HDT_QR_DocumentalConfiguration.getDocumentByContext(context);
		HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalStructure configuration = (HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalStructure) JSON.deserialize(documentList[0].body.toString(), HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalStructure.class);
		return configuration;
	}

    public static String manageAmountDot(String valString){
		String res = valString;
		Integer df = valString.indexOf('\\.');
		String intero = '';
		if(df>=0){
			if(df==0){
				intero='0';
			}else{
				intero=valString.substring(0,df);
			}
			String  dec=valString.substring(df+1,valString.length());
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
		
		return text;
	}
	
	public static String transformDate(Date dateObj) {
		DateTime dt = DateTime.newInstance(dateObj.year(), dateObj.month(),dateObj.day());
		String dateStr = dt.format('dd/MM/yyyy');
		return dateStr;
	}

	public static String getValueFromMethod(String classString, String method, Map<String,List<sObject>> inputs){
		HDT_UTL_DocumentalManagementInterface support = HDT_UTL_DocumentalManagementFactory.getInstance(classString);
		return support.execute(method,inputs);
	}
	public static Integer getChildCount(String objectString, Map<String,List<sObject>> inputs){
		return inputs.get(objectString)?.size();
	}
	public static String getValue(String objectString, String fieldString, Integer index,Map<String,List<sObject>> inputs,Map<String,Object> formParams){
        String retVal = '';
		try {
			if(inputs.get(objectString) != null && inputs.get(objectString).size()>0){
				if(inputs.get(objectString)[index].get(fieldString) != null){
					retVal = String.valueOf(inputs.get(objectString)[index].get(fieldString));
				}
			}else if(inputs.get(objectString) != null && objectString.equalsIgnoreCase('FormParameters')){
				retVal = String.valueOf(formParams.get(fieldString));
			}
		} catch (Exception ex) {
			System.debug(ex.getMessage() + ' at Line:' + ex.getLineNumber());
		}
        return retVal;
    }
	public static String getValueFromObject(Map<String,List<sObject>> inputs,HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalRecord singleRecord, Integer index,Map<String,Object> formParams){
		String result = '';
		if(singleRecord.object1 != null && singleRecord.object1 != ''){
            result = getValue(singleRecord.object1,singleRecord.field1,index,inputs,formParams);
		}

		if(result == '' && singleRecord.object2 != null && singleRecord.object2 != ''){
			result = getValue(singleRecord.object2,singleRecord.field2,index,inputs,formParams);
		}

		if(result == '' && singleRecord.object3 != null && singleRecord.object3 != ''){
            result = getValue(singleRecord.object3,singleRecord.field3,index,inputs,formParams);
		}
		if(result == '' && singleRecord.object4 != null && singleRecord.object4 != ''){
            result = getValue(singleRecord.object4,singleRecord.field4,index,inputs,formParams);
		}

		if(result != null && result != ''){
			if(singleRecord.isData != null && singleRecord.isData == 'Y' ){
				Date dateObj = Date.valueOf(result);
				result = transformDate(dateObj);
			}else if(singleRecord.manageAmount != null && singleRecord.manageAmount == 'Y'){
				result = manageAmountDot(result);
			}
		}
		return result;
	}
	
	public static String getConcatValueFromObject(Map<String,List<sObject>> inputs,HDT_WRP_DocumentalConfiguration.HDT_WRP_DocumentalRecord singleRecord){
		String result1 = '';
		String result2 = '';
		if(singleRecord.object1 != null && singleRecord.object1 != ''){
			result1 = getValue(singleRecord.object1,singleRecord.field1,0,inputs,null);
		}
		if(result1 != null && result1 != '' && singleRecord.object2 != null && singleRecord.object2 != ''){
			result2 += getValue(singleRecord.object2,singleRecord.field2,0,inputs,null);
		}
		if(singleRecord.separetor == 'space')
			return result1 + ' ' + result2;
		else
			return result1 + singleRecord.separetor + result2;
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
		String result2 = '';
		String resultToReturn = '';
		String jolly = '';
		Integer i = 0;
		System.debug('expression ' + expression);
        expressionArray = expression.split('\\|');
		System.debug('expressionArray ' + expressionArray);
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
					result2 = expressionArray[i++];
					
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
				
					if(result2.indexOf('.')>-1){
						objectField2 = result2.split('\\.');
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
						Integer propValueInt = Integer.valueOf(propValue);
						Integer condizioneInt = Integer.valueOf(condizione);
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
					if(result2 != 'ELSE'){
						resultToReturn = result2;
						break;
					}
				}
				if(resultToReturn == 'sysdate'){
					Date today = Date.today();
					resultToReturn = transformDate(today);
				}
			}
		}catch(Exception ex){
			System.debug(ex.getMessage() + ' ' + ex.getLineNumber());
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
				return 'Context3';
			}
			when 'GC' {
				return 'Context3';
			}
			when 'Account' {
				return 'Context4';
			}
			when else {
				return null;
			}
		}
	}
}