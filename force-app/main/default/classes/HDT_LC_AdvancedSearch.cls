public with sharing class HDT_LC_AdvancedSearch {

	private static List<ServicePoint__c> servicePoints;
	private static Map<String, String> servicePointFields = getservicePointObjectFields();
	private static HDT_QR_ServicePoint servicePointQr = new HDT_QR_ServicePoint();
	private static HDT_SRV_ServicePoint servicePointSrv = new HDT_SRV_ServicePoint();
	private static HDT_QR_Contract contractQr = new HDT_QR_Contract();
	private static CS_SelezioneFornitura__c customSetting = servicePointQr.getCustomSetting();



	/*
	 * Retrieve data from ServicePoint Object By ServiceCode
	 */
	@AuraEnabled(cacheable = true)
	public static List<Map<String, Object>> getServicePoints(String parameter,
															 String queryType,String additionalFilter) {
		Set<ServicePoint__c> servicePoints = new Set<ServicePoint__c>();
		system.debug('queryType' + queryType);
		system.debug('additionalFilter' + additionalFilter);
		switch on queryType {
			when 'serialnumber' {
				//Integer.valueOf(parameter);
				if(!parameter.isNumeric()){
					throw new AuraHandledException('La matricola contatore deve contenere solo caratteri numerici');
				}
				servicePointSrv.checkReadAccess(customSetting.OutputServicePoint__c);
				if(additionalFilter=='' || additionalFilter== null){
					servicePoints.addAll(servicePointQr.getServicePointsByMeterSerialNumber(parameter, customSetting.OutputServicePoint__c));
				}else{
					servicePoints.addAll(servicePointQr.getServicePointsByMeterSerialNumberWithFilter(parameter, customSetting.OutputServicePoint__c,additionalFilter));
					//else chiami getRecordFromCodeWithFilter(accountId,additionalFilter) 
				}

			}
			when 'pod' {
				if (parameter.length() < 14 || parameter.length() > 14) {
					throw new AuraHandledException('il codice PDO/PDR deve essere di 14 caratteri');
				}
				servicePointSrv.checkReadAccess(customSetting.OutputServicePoint__c);
				system.debug('additionalFilter***********************************' + additionalFilter);
				if(additionalFilter=='' || additionalFilter== null){
					servicePoints.addAll(servicePointQr.getServicePointsByCode(parameter, customSetting.OutputServicePoint__c));
				}else {
					servicePoints.addAll(servicePointQr.getServicePointsByCodeWithFilter(parameter, customSetting.OutputServicePoint__c,additionalFilter));
					//else chiami getRecordFromCodeWithFilter(accountId,additionalFilter) 
				}
			}
			when 'contract' {
				if (parameter.length() < 10 || parameter.length() > 10) {
					throw new AuraHandledException('Il codice contratto deve essere un numerico di 10 caratteri');
				}
				servicePointSrv.checkReadAccess(customSetting.OutputServicePoint__c);
				
				if(additionalFilter=='' || additionalFilter== null){
					servicePoints.addAll(servicePointQr.getRecordFromCode(parameter, customSetting.OutputServicePoint__c));
				}else {
					servicePoints.addAll(servicePointQr.getRecordFromCodeWithFilter(parameter, customSetting.OutputServicePoint__c,additionalFilter));



				}
			}
			when else {
			}
		}
		checkTheNumberOfRecords(servicePoints.size());
		String[] customSettingFields = customSetting.OutputServicePoint__c.split(',');
		List<Map<String, Object>> output = new List<Map<String, Object>>();
		Map<String, Object> record = new Map<String, Object>();
		for (ServicePoint__c servicePointObject : servicePoints) {
			for (String customSettingField : customSettingFields) {
				if (!customSettingField.contains('.')) {
					if (servicePointObject.get(customSettingField) == null) {
						record.put(servicePointFields.get(customSettingField), '');
					} else {
						record.put(servicePointFields.get(customSettingField),
								servicePointObject.get(customSettingField));
					}
				}
				if (customSettingField.contains('__r')) {
					if (servicePointObject.getSobject(customSettingField.substringBefore('.')) != null) {
						String label = customSettingField.substringBefore('__r') + '__c';
						label = servicePointFields.get(label);
						record.put(label + ' ' + customSettingField.substringAfter('.'),
								servicePointObject.getSobject(customSettingField.substringBefore('.')).get(
										customSettingField.substringAfter('.')));
					}
				}
			}
			output.add(new Map<String, Object>(record));
			record.clear();
		}
		return output;
	}

	@AuraEnabled(cacheable = true)
	public static Map<String, String> servicePointFields() {
		servicePointFields.put('customSetting', customSetting.OutputServicePoint__c);
		return servicePointFields;
	}



//aggiungi parametro additionalFilter
	@AuraEnabled(cacheable = true)
	public static List<Map<String,String>> getContracts(String accountid,String additionalFilter) {

		String type='Contract';
		String fieldContract = customSetting.Output_Contract__c;
		List<String> listField = fieldContract != null ? fieldContract.split(',') : new List<String>();
		
		Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
		Schema.SObjectType leadSchema = schemaMap.get(type);
		Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();

		List<SBQQ__Subscription__c> subscriptions = servicePointQr.getAccountSubscriptions(accountid);
		List<Contract> contracts  = new List<Contract>();
		//if additionalFilter vuoto chiami getAccountContracts
		System.debug('*****************EmINEM:' + fieldContract);
		if(additionalFilter== null ||additionalFilter== ''){
			contracts = contractQr.getAccountContracts(fieldContract,accountid);
		}else{
			System.debug('*****************EmINEM:' + fieldContract);
			contracts = contractQr.getAccountContractsWithFilter(fieldContract,accountId,additionalFilter); 
			//else chiami getAccountContractWithFilter(accountId,additionalFilter) 
		}
        List<Map<String,String>> customSp = new List<Map<String,String>>();
		if(!contracts.isEmpty()){
		for (Contract contract : contracts) {
            Map<String,String> row = new Map<String, String>();
			for(String field : listField){
				String value = '';
				String label = '';
				if(field.contains('__r')){
					List<String> s = field.split('__r.');
					system.debug('************:passa qui');
					if(contract.getSObject(s[0]+'__r') != null){
						system.debug('************:passa anche qui');

						value = (String)contract.getSObject(s[0]+'__r').get(s[1]);

					}
					label = fieldMap.get(s[0]+'__c').getDescribe().getLabel();
				}
				else{
					if(field.contains('.')){
						List<String> s = field.split('\\.');
						value = (String)contract.getSObject(s[0]).get(s[1]);
						label = fieldMap.get(s[0]+'id').getDescribe().getLabel();
					}
					else{
						value = (String)contract.get(field);
						label = fieldMap.get(field).getDescribe().getLabel();
					}
				}
				row.put(label,value);
			}
            customSp.add(row);
		}
	}
		system.debug('getcontratto END :::::' );

		return customSp;
		
        /*List<Map<String,String>> customContracts = new List<Map<String,String>>();
		for (Contract contract : contracts) {
            Map<String,String> row = new Map<String, String>();
            row.put('Contract Number',contract.SAPContractCode__c );
            row.put('Account Name',contract.Account.Name);
            row.put('Service Point',mapSubscriptions.get(contract.Id));
            row.put('Status',contract.Status);
			customContracts.add(row);
		}
		return customContracts;*/
	}

	@AuraEnabled(cacheable = true)
	public static List<Map<String,String>> getContractsBackup(String accountid,String additionalFilter) {
		List<SBQQ__Subscription__c> subscriptions = servicePointQr.getAccountSubscriptions(accountid);
		List<Contract> contracts  = new List<Contract>();
		//if additionalFilter vuoto chiami getAccountContracts
		if(additionalFilter== null ||additionalFilter== ''){
			contracts = contractQr.getAccountContracts(accountid);
		}else{
			contracts = contractQr.getAccountContractsWithFilter(accountId,additionalFilter); 
			//else chiami getAccountContractWithFilter(accountId,additionalFilter) 
		}
		
		
        Map<String, String> mapSubscriptions = new Map<String, String>();
		for (SBQQ__Subscription__c subscription : subscriptions) {
			mapSubscriptions.put(subscription.SBQQ__Contract__c, subscription.ServicePoint__r.ServicePointCode__c);
		}
        List<Map<String,String>> customContracts = new List<Map<String,String>>();
		for (Contract contract : contracts) {
            Map<String,String> row = new Map<String, String>();
            row.put('Contract Number',contract.SAPContractCode__c );
            row.put('Account Name',contract.Account.Name);
            row.put('Service Point',mapSubscriptions.get(contract.Id));
            row.put('Status',contract.Status);
			customContracts.add(row);
		}
		return customContracts;
	}

	/**
	 * TODO , Call the Webservice
	 */
	@AuraEnabled(cacheable = true)
	public static String callWebService(String pod){
		return pod;
	}

	/*
	 * Checking Number of records
	 */
	static void checkTheNumberOfRecords(Integer records) {
		if (records > (customSetting.Max_Record__c).intValue()) {
			throw new AuraHandledException('Numero massimo di record superato');
		}
	}





	/*
	 * Getting All get ServicePoint Fields as Map
	 */
	static Map<String, String> getservicePointObjectFields() {
		Map<String, Schema.SObjectField> fieldsMap = Schema.SObjectType.ServicePoint__c.fields.getMap();
		Map<String, String> fields = new Map<String, String>();
		for (String key : fieldsMap.keyset()) {
			String name = fieldsMap.get(key).getDescribe().getName();
			String label = fieldsMap.get(key).getDescribe().getLabel();
			fields.put(name, label);
		}
		return fields;
	}






	@AuraEnabled(cacheable = true)
	public static List<Map<String,String>> getForniture(String accountid,String additionalFilter) {
		system.debug('getForniture START');
		system.debug('additionalFilter' + additionalFilter);
		String fieldForniture = customSetting.OutputServicePoint__c;
		List<String> listField = fieldForniture != null ? fieldForniture.split(',') : new List<String>();
		List<ServicePoint__c> servicePoints = new List<ServicePoint__c>();
		List<SBQQ__Subscription__c> subscriptions = servicePointQr.getAccountSubscriptions(accountid);

		if(additionalFilter == null || additionalFilter== ''){
			system.debug('entra in additionalFilter == null');
			servicePoints = servicePointQr.getAccountServicePoints(accountid);
		}else{
			system.debug('entra in additionalFilter != null');

			servicePoints = servicePointQr.getAccountServicePointsWithFilter(accountid,additionalFilter);
		}
		system.debug('data get acc : ' + servicePoints);
		String type='ServicePoint__c';

		Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
		Schema.SObjectType leadSchema = schemaMap.get(type);
		Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();

        List<Map<String,String>> customSp = new List<Map<String,String>>();
		for (ServicePoint__c sp : servicePoints) {
            Map<String,String> row = new Map<String, String>();
			for(String field : listField){
				String value = '';
				String label = '';
				if(field.contains('__r')){
					List<String> s = field.split('__r.');
					system.debug('************:' + field + '-' + s);
					value = (String)sp.getSObject(s[0]+'__r').get(s[1]);
					label = fieldMap.get(s[0]+'__c').getDescribe().getLabel();
				}
				else{
					value = (String)sp.get(field);
					label = fieldMap.get(field).getDescribe().getLabel();
				}
				row.put(label,value);
			}
            customSp.add(row);
		}
		system.debug('getForniture END');

		return customSp;
	}

	@AuraEnabled(cacheable = true)
	public static List<Map<String,String>> getFornitureBackup(String accountid,String additionalFilter) {
		system.debug('getForniture START');
		system.debug('additionalFilter' + additionalFilter);
		List<ServicePoint__c> servicePoints = new List<ServicePoint__c>();
		List<SBQQ__Subscription__c> subscriptions = servicePointQr.getAccountSubscriptions(accountid);

		if(additionalFilter == null || additionalFilter== ''){
			system.debug('entra in additionalFilter == null');
			servicePoints = servicePointQr.getAccountServicePoints(accountid);
		}else{
			system.debug('entra in additionalFilter != null');

			servicePoints = servicePointQr.getAccountServicePointsWithFilter(accountid,additionalFilter);
		}
		system.debug('data get acc : ' + servicePoints);
        List<Map<String,String>> customSp = new List<Map<String,String>>();
		for (ServicePoint__c sp : servicePoints) {
            Map<String,String> row = new Map<String, String>();
            row.put('Account Titolare Name',sp.Account__r.Name);
            row.put('Codice Punto',sp.ServicePointCode__c);
            row.put('Matricola Contatore',sp.MeterSN__c);
			row.put('Indirizzo',sp.SupplyAddress__c);
			row.put('Distributore Name',sp.Distributor__r.Name);
			customSp.add(row);
		}
		system.debug('getForniture END');

		return customSp;
	}



}