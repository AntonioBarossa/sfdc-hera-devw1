public with sharing class HDT_LC_AdvancedSearch {

	private static List<ServicePoint__c> servicePoints;
	private static Map<String, String> servicePointFields = getservicePointObjectFields();
	private static CS_SelezioneFornitura__c customSetting = getCustomSetting();


	/*
	 * Retrieve data from ServicePoint Object By ServiceCode
	 */
	@AuraEnabled(cacheable = true)
	public static List<Map<String, Object>> getServicePoints(String parameter,
															 String queryType) {
		Set<ServicePoint__c> servicePoints = new Set<ServicePoint__c>();

		switch on queryType {
			when 'serialnumber' {
				Integer.valueOf(parameter);
				servicePoints.addAll(getServicePointsByMeterSerialNumber(parameter));
			}
			when 'pod' {
				if (parameter.length() < 14 || parameter.length() > 14) {
					throw new AuraHandledException('La lunghezza dei caratteri è sbagliata');
				}
				servicePoints.addAll(getServicePointsByCode(parameter));
			}
			when 'contract' {
				if (parameter.length() < 10 || parameter.length() > 10) {
					throw new AuraHandledException('La lunghezza dei caratteri è sbagliata');
				}
				servicePoints.addAll(getServicePointsByCode(parameter));
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

	@AuraEnabled(cacheable = true)
	public static List<Map<String,String>> getContracts(String accountid) {
		List<SBQQ__Subscription__c> subscriptions = getAccountSubscriptions(accountid);
        List<Contract> contracts = getAccountContracts(accountid);
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
	 * Query for POD
	 */
	static List<ServicePoint__c> getServicePointsByCode(String code) {
		String stringCode = code.trim();
		String query = 'SELECT ' + customSetting.OutputServicePoint__c +
				' FROM ServicePoint__c WHERE ServicePointCode__c = :stringCode ';
		List<ServicePoint__c> servicePoints = Database.query(query);
		return servicePoints;
	}

	/*
	 * Query for Serial Number
	 */
	static List<ServicePoint__c> getServicePointsByMeterSerialNumber(String serialNumber) {
		String stringSerialNumber = '%' + serialNumber + '%';
		String query = 'SELECT ' + customSetting.OutputServicePoint__c +
				' FROM ServicePoint__c WHERE MeterSN__c LIKE :stringSerialNumber ';
		List<ServicePoint__c> servicePoints = Database.query(query);
		return servicePoints;
	}

	/*
	 * Query for Getting All Account Subscriptions
	 */
	static List<SBQQ__Subscription__c> getAccountSubscriptions(String accountid) {
		//List<ServicePoint__c> servicePoints = [ SELECT ServicePointCode__c ,(SELECT Name,SBQQ__Contract__r.ContractNumber FROM Subscriptions__r) FROM ServicePoint__c ];
		return [SELECT Name, SBQQ__Contract__r.ContractNumber, SBQQ__Account__c, SBQQ__Account__r.Name, Service_Point__r.ServicePointCode__c FROM SBQQ__Subscription__c WHERE SBQQ__Account__c =: accountid];
	}

	/*
	 * Query for Getting All Account Contracts
	 */
	static List<Contract> getAccountContracts(String accountid) {
		return [SELECT ContractNumber, Status, Account.Name, AccountId FROM Contract WHERE AccountId =: accountid];
	}
}