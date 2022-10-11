/**
 * @author Keltin Mesonjesi (keltin.mesonjesi@protonmail.ch)
 * @date 05/10/2020
 * @description HDT_LC_AdvancedSearch Class
 * @history Keltin Mesonjesi – 05/10/2020 – Created Class
 */
public with sharing class HDT_LC_AdvancedSearch {

	private static List<ServicePoint__c> servicePoints;
	private static Map<String, String> servicePointFields = getservicePointObjectFields();
	private static HDT_QR_ServicePoint servicePointQr = new HDT_QR_ServicePoint();
	private static HDT_SRV_ServicePoint servicePointSrv = new HDT_SRV_ServicePoint();
	private static HDT_QR_Contract contractQr = new HDT_QR_Contract();
	private static HDT_QR_Case caseQr = new HDT_QR_Case();
	private static CS_SelezioneFornitura__c customSetting = servicePointQr.getCustomSetting();

	@AuraEnabled
	public static Boolean isInBlacklist(String pod){
		if(String.isBlank(pod))return false;
		HDT_QR_Blacklist qrBlack = new HDT_QR_Blacklist();
		Blacklist__c blacklist = qrBlack.getBlacklist(pod);
		Boolean response = false;
		if(blacklist.POD__C != null && blacklist.isActive__c!=false){
			response = true;
		}
		return response;
	}


	@AuraEnabled
	public static List<case> searchModificaContratti(String podPdr){
		List<case> modificaContratti = caseQr.getCaseModificaContratti(podPdr);
		return modificaContratti;
	}

	@AuraEnabled
    public static Boolean permissionForFlagContract(){
        Boolean res = FeatureManagement.checkPermission('HDT_CP_SupplySelectionSearch');
        return res;
    }
	
	@AuraEnabled
	public static List<HDT_WRP_AddressObject> getIndirizzoFornitura(String accountId) {
		system.debug('ACCOUNTID **********************'+accountId);
		// Map<String,String> outPutIndirizzo = new Map<String,String>(); // ! Unused variable
		HDT_QR_ServicePoint sp = new HDT_QR_ServicePoint();
		List<ServicePoint__c> listBp = new List<ServicePoint__c>();
		List<HDT_WRP_AddressObject>  listWrapObject = new List<HDT_WRP_AddressObject>();
		//HDT_WRP_AddressObject wrapObject = new HDT_WRP_AddressObject();
		
		if(accountId != null || accountId != ''){
			listBp = sp.getAddressFornitura(accountId);
		}
		
		
		if(!listBp.isEmpty()){
		for (ServicePoint__c servicePoint : listBp){
			HDT_WRP_AddressObject wrapObject = new HDT_WRP_AddressObject();
			if(servicePoint.SupplyCity__c !='' && servicePoint.SupplyCity__c != null){
				
				wrapObject.Comune=servicePoint.SupplyCity__c ;
			}
			else{
				
				wrapObject.Comune='';
			}
			if(servicePoint.SupplyStreet__c !='' && servicePoint.SupplyStreet__c != null){

				wrapObject.Via= servicePoint.SupplyStreet__c  ;
			}
			if(servicePoint.SupplyStreetName__c !='' && servicePoint.SupplyStreetName__c != null){

				wrapObject.Via= servicePoint.SupplyStreetName__c  ;
			}
			else{
				
				wrapObject.Via='';
				
			}
			if(servicePoint.SupplyStreetNumber__c !='' && servicePoint.SupplyStreetNumber__c != null){
				
				wrapObject.Civico= servicePoint.SupplyStreetNumber__c   ;
			}
			else{
				
				wrapObject.Civico='';
			}
			
			if(servicePoint.SupplyStreetNumberExtension__c !='' && servicePoint.SupplyStreetNumberExtension__c != null){
				
				wrapObject.EstensCivico= servicePoint.SupplyStreetNumberExtension__c  ;
			}
			else{
				
				wrapObject.EstensCivico='';
			}
			if(servicePoint.SupplyPostalCode__c !='' && servicePoint.SupplyPostalCode__c != null){
				
				wrapObject.CAP= servicePoint.SupplyPostalCode__c   ;
			}
			else{
				
				wrapObject.CAP='';
			}
			if(servicePoint.SupplyProvince__c !='' && servicePoint.SupplyProvince__c != null){
				
				wrapObject.Provincia= servicePoint.SupplyProvince__c  ;
			}
			else{
				
				wrapObject.Provincia='';
			}
			if(servicePoint.SupplyCountry__c !='' && servicePoint.SupplyCountry__c != null){
				
				wrapObject.Stato= servicePoint.SupplyCountry__c  ;
			}
			else{
				
				wrapObject.Stato='';
			}
			// if(servicePoint.SupplySAPStreetCode__c !='' && servicePoint.SupplySAPStreetCode__c != null){
				
			// 	wrapObject.CodiceViaStradarioSAP= servicePoint.SupplySAPStreetCode__c  ;
			// }
			if(servicePoint.SupplyStreetCode__c !='' && servicePoint.SupplyStreetCode__c != null){
				
				wrapObject.CodiceViaStradarioSAP= servicePoint.SupplyStreetCode__c  ;
			}
			else{
				
				wrapObject.CodiceViaStradarioSAP='';
			}
			// if(servicePoint.SupplySAPCityCode__c !='' && servicePoint.SupplySAPCityCode__c != null){
				
			// 	wrapObject.CodiceComuneSAP=servicePoint.SupplySAPCityCode__c  ;
			// }
			if(servicePoint.SupplyCityCode__c !='' && servicePoint.SupplyCityCode__c != null){
				
				wrapObject.CodiceComuneSAP=servicePoint.SupplyCityCode__c  ;
			}
			else{
				
				wrapObject.CodiceComuneSAP='';
			}
			system.debug('wrapObject address : '+  wrapObject );

			listWrapObject.add(wrapObject);
			system.debug('listWrapObject address in For : '+  listWrapObject );
		}
		}
		system.debug('listWrapObject address : '+  listWrapObject );
		return listWrapObject;

	}

	@AuraEnabled
	public static  HDT_WRP_AddressObject getIndirizzo(String accountId) {
		system.debug('ACCOUNTID **********************'+accountId);

		HDT_WRP_AddressObject wrapObject = new HDT_WRP_AddressObject();
		// List<HDT_WRP_AddressObject> listWrapperObject = new List<HDT_WRP_AddressObject>(); // !Unused variables
		//Map<String,String> outPutIndirizzo = new Map<String,String>();
		HDT_QR_Account qr = new HDT_QR_Account();		
		Account ac = new Account();
		
		if(accountId != null || accountId != ''){
			ac = qr.getBillingAddressAccount(accountId);
		}
		
		if(ac!= null){

		if(ac.BillingCity != null){
			
			wrapObject.Comune= ac.BillingCity ;
		}
		else{
			
			wrapObject.Comune=' ';
		}
		if(ac.BillingStreetName__c != null){
			
			wrapObject.Via= ac.BillingStreetName__c ;
		}
		else{
			
			wrapObject.Via=', ';
			
		}
		if(ac.BillingStreetNumber__c != null){
			
			wrapObject.Civico= ac.BillingStreetNumber__c ;
		}
		else{
			
			wrapObject.Civico=', ';
		}
		
		if(ac.BillingStreetNumberExtension__c != null){
			
			wrapObject.EstensCivico= ac.BillingStreetNumberExtension__c ;
		}
		else{
			
			wrapObject.EstensCivico=', ';
		}
		if(ac.BillingPostalCode != null){
			
			wrapObject.CAP= ac.BillingPostalCode ;
		}
		else{
			
			wrapObject.CAP=', ';
		}
		if(ac.BillingState != null){
			
			wrapObject.Provincia= ac.BillingState ;
		}
		else{
			
			wrapObject.Provincia=', ';
		}
		if(ac.BillingCountry != null){
			
			wrapObject.Stato= ac.BillingCountry ;
		}
		else{
			
			wrapObject.Stato=', ';
		}
		if(ac.BillingStreetCode__c != null){
			
			wrapObject.CodiceViaStradarioSAP= ac.BillingStreetCode__c ;
		}
		else{
			
			wrapObject.CodiceViaStradarioSAP=', ';
		}
		if(ac.BillingCityCode__c != null){
			
			wrapObject.CodiceComuneSAP= ac.BillingCityCode__c ;
		}
		else{
			
			wrapObject.CodiceComuneSAP=', ';
		}

			

		/*row.put(label,wrapObject);


		
		customBp.add(row);*/
		

		
	}
	
		return wrapObject;
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
		system.debug('Account retrieved******'+ ac);

			if(ac.BillingCity != null){
				outPut.put('Comune',ac.BillingCity);
			}
			if(ac.BillingStreetNumber__c != null){
				outPut.put('Civico',ac.BillingStreetNumber__c);
			}
			if(ac.BillingPostalCode != null){
				outPut.put('CAP',ac.BillingPostalCode);
			}
			if(ac.BillingStreetName__c != null){
				outPut.put('Via',ac.BillingStreetName__c );
			}
			if(ac.BillingState != null){
				outPut.put('Provincia',ac.BillingState);
			}
			if(ac.BillingCountry != null){
				outPut.put('Stato',ac.BillingCountry);
			}
			if(ac.BillingStreetNumberExtension__c != null){
				outPut.put('Est.Civico',ac.BillingStreetNumberExtension__c);
			}
			if(ac.BillingStreetCode__c != null){
				outPut.put('Codice Via Stradario SAP',ac.BillingStreetCode__c);
			}
			if(ac.BillingCityCode__c != null){
				outPut.put('Codice Comune SAP',ac.BillingCityCode__c);
			}
			if(ac.BillingPlace__c != null){
				outPut.put('Localita',ac.BillingPlace__c);
			}

		system.debug('outPut *******'+ outPut);

		return outPut;

	}

	/*
	 * Retrieve data from ServicePoint Object By ServiceCode
	 */
	@AuraEnabled(cacheable = true)
	public static List<Map<String, Object>> getServicePoints(String parameter,String queryType,String additionalFilter,
	                                                                          Boolean isSuperUser, String datiCatastali) {
		Set<ServicePoint__c> servicePoints = new Set<ServicePoint__c>();
		HDT_QR_Contract contractQr= new HDT_QR_Contract();
		system.debug('queryType' + queryType);
		system.debug('additionalFilter' + additionalFilter);
		Boolean isSerachFromContract = false;												
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
				isSerachFromContract=true;
			}

			when 'podH2o' {
				if (parameter.length() < 5 || parameter.length() > 20) {
					throw new AuraHandledException('Il Codice Punto Presa deve essere di compreso tra 5 e 20 caratteri');
				}
				servicePointSrv.checkReadAccess(customSetting.OutputServicePoint__c);
				servicePoints.addAll(servicePointQr.getServicePointsByCodeWater(parameter, customSetting.OutputServicePoint__c));
			}

			when 'address' {
				servicePointSrv.checkReadAccess(customSetting.OutputServicePoint__c);
				servicePoints.addAll(servicePointQr.getServicePointsByAddress(parameter, customSetting.OutputServicePoint__c));

			}

			when 'datiCatastali' {
				return servicePointQr.getServicePointsByDatiCatastali(datiCatastali, customSetting.OutputServicePoint__c);

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
			if(isSerachFromContract != true){
				isSuperUser=false;
			}

			Contract c = contractQr.getSapContractCode(servicePointObject.ServicePointCode__c,isSuperUser);
			

				if(c.SAPContractCode__c!=null){
					String value = '';
					String label = '';
					label='Codice Contratto';
					value=(String) c.SAPContractCode__c;
					record.put(label,value);

				}else{
					String value = '';
					String label = '';
					label='Codice Contratto';
					value=' ';
					record.put(label,value);
				}
			

			system.debug('record***********'+record);
			output.add(new Map<String, Object>(record));
			record.clear();
		}


		return output;
	}

	@AuraEnabled(cacheable = true)
	public static List<Map<String, Object>> getServicePoints(String parameter,String queryType,
																			  String additionalFilter,Boolean isSuperUser) {
		return getServicePoints(parameter,queryType,additionalFilter,isSuperUser, '');
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

		List<Contract> contracts  = new List<Contract>();
		
		if(additionalFilter== null ||additionalFilter== ''){
			contracts = contractQr.getAccountContracts(fieldContract,accountid);
		}else{
			
			contracts = contractQr.getAccountContractsWithFilter(fieldContract,accountId,additionalFilter); 
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
		
	}

	@AuraEnabled(cacheable = true)
	public static List<Map<String,String>> getContractsBackup(String accountid,String additionalFilter) {
		List<SBQQ__Subscription__c> subscriptions = servicePointQr.getAccountSubscriptions(accountid);
		List<Contract> contracts  = new List<Contract>();
		if(additionalFilter== null ||additionalFilter== ''){
			contracts = contractQr.getAccountContracts(accountid);
		}else{
			contracts = contractQr.getAccountContractsWithFilter(accountId,additionalFilter); 
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
	@TestVisible
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
	public static List<Map<String, String>> getForniture(String accountid,String additionalFilter) {
		
		String fieldForniture = customSetting.OutputServicePoint__c;
		HDT_QR_Contract contractQr= new HDT_QR_Contract();
		List<String> listField = fieldForniture != null ? fieldForniture.split(',') : new List<String>();
		List<ServicePoint__c> servicePoints = new List<ServicePoint__c>();

		if(additionalFilter == null || additionalFilter== ''){
			servicePoints = servicePointQr.getAccountServicePoints(accountid);
		}
		else{
			servicePoints = servicePointQr.getAccountServicePointsWithFilter(accountid,additionalFilter);
		}

		String type='ServicePoint__c';
		List<String> servicePointsCodes = new List<String>();
		for(ServicePoint__c s :servicePoints){
			servicePointsCodes.add(s.ServicePointCode__c);
		}
		
		List<Contract> c = contractQr.getSapContractCode(servicePointsCodes);
		Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
		Schema.SObjectType leadSchema = schemaMap.get(type);
		Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();

        List<Map<String,String>> customSp = new List<Map<String,String>>();
		for (ServicePoint__c sp : servicePoints) {
            Map<String,String> row = new Map<String, String>();
			if(sp.Id != null)
			{
				row.put('ServicePointId', sp.Id);
			}
			for(String field : listField){
				String value = '';
				String label = '';
				
				if(field.contains('__r')){
					List<String> s = field.split('__r.');
					if(sp.getSObject(s[0]+'__r')!=null){						
						value = (String)sp.getSObject(s[0]+'__r').get(s[1]);
						label = fieldMap.get(s[0]+'__c').getDescribe().getLabel();
					}
				}
				else{
					value = (String)sp.get(field);
					label = fieldMap.get(field).getDescribe().getLabel();
				}
				row.put(label,value);
			}
			if(!c.isEmpty() ){
				for(Contract con :c){
					String value = '';
					String label = '';
					if(con.ServicePoint__r.ServicePointCode__c== sp.ServicePointCode__c){
						label='Codice Contratto';
						value=(String) con.SAPContractCode__c;
						row.put(label,value);
					}
					else{
						label='Codice Contratto';
						value=' ';
						row.put(label,value);
					}
				}				
			}
            customSp.add(row);
		}
		return customSp;
	}

	@AuraEnabled(cacheable = true)
	public static List<Map<String,String>> getFornitureBackup(String accountid,String additionalFilter) {
		system.debug('getForniture START');
		system.debug('additionalFilter' + additionalFilter);
		List<ServicePoint__c> servicePoints = new List<ServicePoint__c>();

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

	


public class HDT_WRP_FieldsObject {
	@AuraEnabled public String statusCode{get;set;}
	@AuraEnabled public String message{get;set;}
	@AuraEnabled public String idFornitura{get;set;}
}
}