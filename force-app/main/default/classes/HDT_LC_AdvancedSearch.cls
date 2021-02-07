public with sharing class HDT_LC_AdvancedSearch {

	private static List<ServicePoint__c> servicePoints;
	private static Map<String, String> servicePointFields = getservicePointObjectFields();
	private static CS_SelezioneFornitura__c customSetting = getCustomSetting();
	private static HDT_QR_ServicePoint servicePointQr = new HDT_QR_ServicePoint();
	private static HDT_SRV_ServicePoint servicePointSrv = new HDT_SRV_ServicePoint();
	private static HDT_QR_Contract contractQr = new HDT_QR_Contract();



	/*
	 * Retrieve data from ServicePoint Object By ServiceCode
	 */
	@AuraEnabled(cacheable = true)
	public static List<Map<String, Object>> getServicePoints(String parameter,
															 String queryType,String additionalFilter) {
		Set<ServicePoint__c> servicePoints = new Set<ServicePoint__c>();
		system.debug('queryType' + queryType);

		switch on queryType {
			when 'serialnumber' {
				Integer.valueOf(parameter);
				servicePointSrv.checkReadAccess(customSetting.OutputServicePoint__c);
				if(additionalFilter==''||additionalFilter== null){
					servicePoints.addAll(servicePointQr.getServicePointsByMeterSerialNumber(parameter, customSetting.OutputServicePoint__c));
				}else{
					servicePoints.addAll(servicePointQr.getServicePointsByMeterSerialNumberWithFilter(parameter, customSetting.OutputServicePoint__c,additionalFilter));
					//else chiami getRecordFromCodeWithFilter(accountId,additionalFilter) 
				}

			}
			when 'pod' {
				if (parameter.length() < 14 || parameter.length() > 14) {
					throw new AuraHandledException('La lunghezza dei caratteri è sbagliata');
				}
				servicePointSrv.checkReadAccess(customSetting.OutputServicePoint__c);
				if(additionalFilter==''||additionalFilter== null){
					servicePoints.addAll(servicePointQr.getServicePointsByCode(parameter, customSetting.OutputServicePoint__c));
				}else {
					servicePoints.addAll(servicePointQr.getServicePointsByCodeWithFilter(parameter, customSetting.OutputServicePoint__c,additionalFilter));
					//else chiami getRecordFromCodeWithFilter(accountId,additionalFilter) 
				}
			}
			when 'contract' {
				if (parameter.length() < 8 || parameter.length() > 8) {
					throw new AuraHandledException('La lunghezza dei caratteri è sbagliata');
				}
				servicePointSrv.checkReadAccess(customSetting.OutputServicePoint__c);
				//if additionalFilter vuoto chiami getRecordFromCode
				if(additionalFilter==''||additionalFilter== null){
					servicePoints.addAll(servicePointQr.getRecordFromCode(parameter, customSetting.OutputServicePoint__c));
				}else {
					servicePoints.addAll(servicePointQr.getRecordFromCodeWithFilter(parameter, customSetting.OutputServicePoint__c,additionalFilter));

					//else chiami getRecordFromCodeWithFilter(accountId,additionalFilter) 

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
		List<SBQQ__Subscription__c> subscriptions = getAccountSubscriptions(accountid);
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
			mapSubscriptions.put(subscription.SBQQ__Contract__c, subscription.Service_Point__r.ServicePointCode__c);
		}
        List<Map<String,String>> customContracts = new List<Map<String,String>>();
		for (Contract contract : contracts) {
            Map<String,String> row = new Map<String, String>();
            row.put('Contract Number',contract.ContractNumber);
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
	 * Getting Custom Settimg 'CS_SelezioneFornitura'
	 */
	static CS_SelezioneFornitura__c getCustomSetting() {
		return [SELECT Max_Record__c, OutputServicePoint__c FROM CS_SelezioneFornitura__c][0];
	}

/**
 * Getting Custom metadata type HDT_FiltriProcessiSelFornitura__mdt
 */
	static HDT_FiltriProcessiSelFornitura__mdt getProcessi(){
		string query = 'SELECT Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, ContrattiCliente__c, Disalimentabile__c, StatoContratto__c, StatoFornitura__c, TipoProcesso__c, TipoServizio__c, FornitureCliente__c FROM HDT_FiltriProcessiSelFornitura__mdt';
		return database.query(query);
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

	/*
	 * Query for Getting All Account Subscriptions
	 */
	static List<SBQQ__Subscription__c> getAccountSubscriptions(String accountid) {
		//List<ServicePoint__c> servicePoints = [ SELECT ServicePointCode__c ,(SELECT Name,SBQQ__Contract__r.ContractNumber FROM Subscriptions__r) FROM ServicePoint__c ];
		return [SELECT Name, SBQQ__Contract__r.ContractNumber, SBQQ__Account__c, SBQQ__Account__r.Name, Service_Point__r.ServicePointCode__c FROM SBQQ__Subscription__c WHERE SBQQ__Account__c =: accountid WITH SECURITY_ENFORCED];
	}

	/*
	 * Query for Getting All Account Contracts
	 */
	static List<Contract> getAccountContracts(String accountid) {
		HDT_FiltriProcessiSelFornitura__mdt processi = new HDT_FiltriProcessiSelFornitura__mdt();
		processi = getProcessi();
		system.debug('get value of custom metdata type'+ processi);
		return [SELECT ContractNumber, Status, Account.Name, AccountId FROM Contract WHERE AccountId =: accountid  WITH SECURITY_ENFORCED];
	}


	@AuraEnabled(cacheable = true)
	public static List<Map<String,String>> getForniture(String accountid,String additionalFilter) {
		system.debug('getForniture START');
		system.debug('additionalFilter' + additionalFilter);
		List<ServicePoint__c> servicePoints = new List<ServicePoint__c>();
		List<SBQQ__Subscription__c> subscriptions = getAccountSubscriptions(accountid);

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


			/*
	 * Query for Getting All Account Service Points
	 */
	static List<ServicePoint__c> getAccountServicePoints(String accountid) {
		system.debug('getAccountServicePoints START');
		HDT_FiltriProcessiSelFornitura__mdt processi = new HDT_FiltriProcessiSelFornitura__mdt();
		processi = getProcessi();
		system.debug('get value of custom metdata type'+ processi.tipoServizio__c);

		system.debug('getAccountServicePoints END');
		return [SELECT Id, Account__c, ServicePointCode__c, MeterSN__c, SupplyAddress__c, Distributor__c,recordType.Name FROM ServicePoint__c WHERE Account__c =: accountid AND recordType.Name=: processi.tipoServizio__c WITH SECURITY_ENFORCED];
	}

}