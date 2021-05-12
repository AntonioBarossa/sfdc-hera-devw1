public with sharing class HDT_LC_AdvancedSearch {

	private static List<ServicePoint__c> servicePoints;
	private static Map<String, String> servicePointFields = getservicePointObjectFields();
	private static HDT_QR_ServicePoint servicePointQr = new HDT_QR_ServicePoint();
	private static HDT_SRV_ServicePoint servicePointSrv = new HDT_SRV_ServicePoint();
	private static HDT_QR_Contract contractQr = new HDT_QR_Contract();
	private static CS_SelezioneFornitura__c customSetting = servicePointQr.getCustomSetting();

	
	
	@AuraEnabled
	public static List<Map<String,String>> getIndirizzoFornitura(String accountId) {
		system.debug('ACCOUNTID **********************'+accountId);
		Map<String,String> outPutIndirizzo = new Map<String,String>();
		HDT_QR_ServicePoint sp = new HDT_QR_ServicePoint();
		List<ServicePoint__c> listBp = new List<ServicePoint__c>();
		
		if(accountId != null || accountId != ''){
			listBp = sp.getAddressFornitura(accountId);
		}
		
		List<Map<String,String>> customBp = new List<Map<String,String>>();
		
		if(!listBp.isEmpty()){
		for (ServicePoint__c servicePoint : listBp) {
            Map<String,String> row = new Map<String, String>();
			
				String value = servicePoint.SupplyAddress__c;
				String label = '';
				if(value!=',,,,,,,'){
					row.put(label,value);
				}
				
			
            customBp.add(row);
		}
		}

		return customBp;

	}

	@AuraEnabled
	public static List<Map<String,String>> getIndirizzo(String accountId) {
		system.debug('ACCOUNTID **********************'+accountId);
		Map<String,String> outPutIndirizzo = new Map<String,String>();
		HDT_QR_Contract bp = new HDT_QR_Contract();
		List<BillingProfile__c> listBp = new List<BillingProfile__c>();
		
		if(accountId != null || accountId != ''){
			listBp = bp.getInd(accountId);
		}
		
		List<Map<String,String>> customBp = new List<Map<String,String>>();
		
		if(!listBp.isEmpty()){
		for (BillingProfile__c BillingProfile : listBp) {
            Map<String,String> row = new Map<String, String>();
			
				String value = BillingProfile.InvoicingAddressFormula__c;
				String label = '';

				row.put(label,value);
			
            customBp.add(row);
		}
	}

		return customBp;
	}

	@AuraEnabled
public static Map<String,String> getAddressFromAccount(String accountId)
{
	HDT_QR_Account qr = new HDT_QR_Account();
	Account ac = new Account();
	Map<String,String> outPut = new Map<String,String>();
	if(accountId!=null){
		ac = qr.getBillingAddressAccount(accountId);
	}
	system.debug('BillingAddress******'+ ac.BillingAddressFormula__c);
	String[] billingAddressSplit = ac.BillingAddressFormula__c.split(',');


	if(ac.BillingAddressFormula__c!=null){
		system.debug('entra in if ');

		if(billingAddressSplit[3]!= null){
			outPut.put('Comune',billingAddressSplit[3]);
		}
		if(billingAddressSplit[1]!= null){
			outPut.put('Civico',billingAddressSplit[1]);
		}
		if(billingAddressSplit[5]!= null){
			outPut.put('CAP',billingAddressSplit[5]);
		}
		if(billingAddressSplit[0]!= null){
			outPut.put('Via',billingAddressSplit[0]);
		}
		if(billingAddressSplit[4]!= null){
			outPut.put('Provincia',billingAddressSplit[4]);
		}
		if(billingAddressSplit[6]!= null){
			outPut.put('Stato',billingAddressSplit[6]);
		}
		if(billingAddressSplit[2]!= null){
			outPut.put('Est.Civico',billingAddressSplit[2]);
		}
	
	}

	system.debug('outPut *******'+ outPut);

	return outPut;

}	

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
	 
				servicePointSrv.checkReadAccess(customSetting.OutputServicePoint__c);
				if(additionalFilter=='' || additionalFilter== null){
					servicePoints.addAll(servicePointQr.getServicePointsByMeterSerialNumber(parameter, customSetting.OutputServicePoint__c));
				}else{
					servicePoints.addAll(servicePointQr.getServicePointsByMeterSerialNumberWithFilter(parameter, customSetting.OutputServicePoint__c,additionalFilter));
					//else chiami getRecordFromCodeWithFilter(accountId,additionalFilter) 
				}

			}
			when 'pod' {
				if (parameter.length() < 10 || parameter.length() > 15) {
					throw new AuraHandledException('il codice PDO/PDR deve essere di 15 caratteri');
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
			system.debug('record***********'+record);
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
		
		if(additionalFilter== null ||additionalFilter== ''){
			contracts = contractQr.getAccountContracts(fieldContract,accountid);
		}else{
			
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


	@AuraEnabled
	public static List<Map<String,string>> extractDataFromArriccDataService(ServicePoint__c sp, HDT_WS_ArrichmentDataEntityResponse response ){
		
			servicePoint__c spNew = new servicePoint__c();
			if(sp!= null){
				system.debug('entra in sp diverso da null' + sp);
				spNew = sp;
			}
		Map<string,string> mapRes = new Map<string,string>();
		system.debug('posizioni ***************************'+response.data.posizioni[0]);
	
			for(HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_posizioniResponseObject r : response.data.posizioni){
				if(!String.isBlank(r.campo) && mapRes.get(r.campo.toUpperCase()) == null){
					system.debug('campo ****' + r.campo);
					system.debug('valore ****' + r.valore);
					mapRes.put(r.campo.toUpperCase(),r.valore);
				}
	
			}

		
		/*	
		if(mapRes.get('CALIBRO1')!=null && !String.isBlank(mapRes.get('CALIBRO1'))){
			spNew.MeterClass__c = mapRes.get('CALIBRO1');
		}
		if(mapRes.get('CODICEREMI')!=null && !String.isBlank(mapRes.get('CODICEREMI'))){
			spNew.RemiCode__c = mapRes.get('CODICEREMI');
		}

		if(mapRes.get('CONTRATTO')!=null && !String.isBlank(mapRes.get('CONTRATTO'))){
			spNew.TemporaryContractCode__c = mapRes.get('CONTRATTO');
		}

		if(mapRes.get('CONTRATTO')!=null && !String.isBlank(mapRes.get('CONTRATTO'))){
			spNew.Disconnectable__c = mapRes.get('CONTRATTO');
		}

		if(mapRes.get('FASE')!=null && !String.isBlank(mapRes.get('FASE'))){
			spNew.RequestPhase__c  = mapRes.get('FASE');
		}

		if(mapRes.get('PRESSIONE')!=null && !String.isBlank(mapRes.get('PRESSIONE'))){
			spNew.Pressure__c  = integer.valueOf(mapRes.get('PRESSIONE'));
		}

		*/

				//campi fornitura
				if(mapRes.get('DISTRIBUTORE')!=null && !String.isBlank(mapRes.get('DISTRIBUTORE'))){
					//spNew.Account__r.id =mapRes.get('DISTRIBUTORE') ;
				}
				if(mapRes.get('POD')!=null && !String.isBlank(mapRes.get('POD'))){
					spNew.ServicePointCode__c   = mapRes.get('POD');
                    spNew.Name   = mapRes.get('POD');


				}
				if(mapRes.get('DESCRCOMM')!=null && !String.isBlank(mapRes.get('DESCRCOMM'))){
				
                    if(mapRes.get('DESCRCOMM')== 'Energia elettrica'){
                        spNew.CommoditySector__c = 'Energia Elettrica';

                    }else
                    {
					    spNew.CommoditySector__c = 'Gas';
                    }
		
				}
				if(mapRes.get('IMPIANTO')!=null && !String.isBlank(mapRes.get('IMPIANTO'))){
		
					spNew.ImplantType__c = mapRes.get('IMPIANTO');
				}
				if(mapRes.get('TIPOIMPIANTO')!=null && !String.isBlank(mapRes.get('TIPOIMPIANTO'))){
		
					spNew.ImplantType__c  = mapRes.get('TIPOIMPIANTO')+'-'+mapRes.get('DESCRTIPOIMP');		
				}
				if(mapRes.get('CONSUMOCAPDR')!=null && !String.isBlank(mapRes.get('CONSUMOCAPDR'))){
		
					spNew.AnnualConsumption__c = integer.valueOf(mapRes.get('CONSUMOCAPDR'));
				}
				if(mapRes.get('MERCATO')!=null && !String.isBlank(mapRes.get('MERCATO'))){
		
					spNew.MarketOrigin__c = mapRes.get('MERCATO');
				}
				if(mapRes.get('FLAGTELEGESTIBILE')!=null && !String.isBlank(mapRes.get('FLAGTELEGESTIBILE'))){
		
					spNew.IsRemoteManaged__c =Boolean.valueOf(mapRes.get('FLAGTELEGESTIBILE'));
				}
				if(mapRes.get('POTENZACONTRATTUALE')!=null && !String.isBlank(mapRes.get('POTENZACONTRATTUALE'))){
					spNew.PowerContractual__c = integer.valueOf(mapRes.get('POTENZACONTRATTUALE').subString(0,mapRes.get('POTENZACONTRATTUALE').indexOf('.')+1));
				}
				if(mapRes.get('POTENZATECNICA')!=null && !String.isBlank(mapRes.get('POTENZATECNICA'))){
					spNew.PowerAvailable__c  =integer.valueOf(mapRes.get('POTENZATECNICA').subString(0,mapRes.get('POTENZATECNICA').indexOf('.')+1)) ;
				}
				if(mapRes.get('TENSIONE')!=null && !String.isBlank(mapRes.get('TENSIONE'))){
		
					spNew.VoltageLevel__c = mapRes.get('TENSIONE');
				}
				if(mapRes.get('RESIDENTINDFORNITURA')!=null && !String.isBlank(mapRes.get('RESIDENTINDFORNITURA'))){
		
					spNew.Resident__c = Boolean.valueOf(mapRes.get('RESIDENTINDFORNITURA'));
				}

				//campi indirizzo
				if(mapRes.get('CAP')!=null && !String.isBlank(mapRes.get('CAP'))){

					spNew.SupplyPostalCode__c = mapRes.get('CAP');
				}
				if(mapRes.get('VIA')!=null && !String.isBlank(mapRes.get('VIA'))){
					spNew.SupplyStreet__c  = mapRes.get('VIA');
				}
				if(mapRes.get('TIPOVIA')!=null && !String.isBlank(mapRes.get('TIPOVIA'))){
					spNew.SupplyStreetToponym__c  = mapRes.get('TIPOVIA');
				}
				if(mapRes.get('CIVICO')!=null && !String.isBlank(mapRes.get('CIVICO'))){
					spNew.SupplyStreetNumber__c  = mapRes.get('CIVICO');
				}
				if(mapRes.get('LOCALITÀ')!=null && !String.isBlank(mapRes.get('LOCALITÀ'))){
					spNew.SupplyPlace__c  = mapRes.get('LOCALITÀ');
				}
				if(mapRes.get('CODICEVIA')!=null && !String.isBlank(mapRes.get('CODICEVIA'))){
					spNew.SupplySAPStreetCode__c = mapRes.get('CODICEVIA');
				}
				if(mapRes.get('CODICEPAESE')!=null && !String.isBlank(mapRes.get('CODICEPAESE'))){
					spNew.SupplySAPCityCode__c = mapRes.get('CODICEPAESE');
				}
				if(mapRes.get('REGIONE')!=null && !String.isBlank(mapRes.get('REGIONE'))){

					spNew.SupplyPostalCode__c = mapRes.get('REGIONE');
				}
		system.debug('spNew*****************' + spNew);
		List<ServicePoint__c> servicePoints = new List<ServicePoint__c>();
		servicePoints.add(spNew);

		String type='ServicePoint__c';
		String fieldForniture = customSetting.OutputServicePoint__c;
		List<String> listField = fieldForniture != null ? fieldForniture.split(',') : new List<String>();
		Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
		Schema.SObjectType leadSchema = schemaMap.get(type);
		Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();

        List<Map<String,String>> customSp = new List<Map<String,String>>();
		for (ServicePoint__c spo : servicePoints) {
            Map<String,String> row = new Map<String, String>();
			for(String field : listField){
				String value = '';
				String label = '';
				if(!field.contains('__r')){
					value = (String)spo.get(field);
					label = fieldMap.get(field).getDescribe().getLabel();
				}
	
				row.put(label,value);
			}
            customSp.add(row);
		}

		return customSp;
	}

	

//creare metodo per riempimento lista posizioni (response) e upsert punto di fornitura
//CREARE OGGETTO WRAP
public class HDT_WRP_FieldsObject {
	@AuraEnabled public String statusCode{get;set;}
	@AuraEnabled public String message{get;set;}
	@AuraEnabled public String idFornitura{get;set;}
}
}