/**
 * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
 * @date 30/10/2020
 * @description HDT_QR_ServicePoint.cls - Class that holds queries for ServicePoint__c
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */
public inherited sharing class HDT_QR_ServicePoint {
	
	private static HDT_SRV_Contract contractSrv = new HDT_SRV_Contract();
	String fieldSp =  'Id, Account__c, Account__r.Name, CommoditySector__c, ServicePointCode__c, MeterSN__c, SupplyAddress__c, Distributor__r.Name,recordType.Name,ImplantType__c,ImplantTypeTemp__c,MeterStatus__c,SupplyPlace__c';
	/*
	 * Query for Getting All Account Service Points
	 */
	public List<ServicePoint__c> getAccountServicePoints(String accountid) {
		system.debug('accountId : '+ accountId);
		contractSrv.checkReadAccess('Id, Account__c,Account__r.Name, ServicePointCode__c, MeterSN__c, SupplyAddress__c, Distributor__r.Name,recordType.Name,');
		List<ServicePoint__c> listSp = new List<ServicePoint__c>();
		return listSp= [SELECT Id, Account__c,Account__r.Name, ServicePointCode__c, MeterSN__c, SupplyAddress__c, Distributor__r.Name,recordType.Name,MeterStatus__c,CommoditySector__c,ImplantType__c,ImplantTypeTemp__c FROM ServicePoint__c WHERE Account__c =: accountid WITH SECURITY_ENFORCED];
	}
	
	/**
	 * @description getAddressFornitura
	 * @param accountid
	 * @return List<ServicePoint__c>
	 */
	public List<ServicePoint__c> getAddressFornitura(String accountid) {
		system.debug('accountId : '+ accountId);
		contractSrv.checkReadAccess('Account__c, SupplyStreet__c, SupplyStreetNumber__c, SupplyStreetNumberExtension__c, SupplyPlace__c, SupplyCity__c,SupplyProvince__c, SupplyPostalCode__c, SupplyCountry__c');
		List<ServicePoint__c> listSp = new List<ServicePoint__c>();
		return listSp= [SELECT Account__c, SupplyStreet__c, SupplyStreetNumber__c, SupplyStreetNumberExtension__c, SupplyPlace__c, SupplyCity__c,SupplyProvince__c, SupplyPostalCode__c, SupplyCountry__c,SupplySAPCityCode__c,SupplySAPStreetCode__c FROM ServicePoint__c WHERE Account__c =: accountid WITH SECURITY_ENFORCED];
	}

	/**
	 * @description Query for Getting All Account Service Points
	 * @param accountid
	 * @param additionalFilter
	 * @return List<ServicePoint__c>
	 */
	public List<ServicePoint__c> getAccountServicePointsWithFilter(String accountid,String additionalFilter) {
		system.debug('getAccountServicePointsWithFilter START');
		contractSrv.checkReadAccess(fieldSp);
		// String query;
		List<ServicePoint__c> listSp = new List<ServicePoint__c>();
		if(additionalFilter.contains('Commodity')){
			listSp = Database.query('SELECT '+String.escapeSingleQuotes(fieldSp)+' FROM ServicePoint__c WHERE Account__c =: accountid '+ additionalFilter);
		}
		//List<ServicePoint__c> listSP = [SELECT Id, Account__c, ServicePointCode__c, MeterSN__c, SupplyAddress__c, Distributor__c,recordType.Name FROM ServicePoint__c WHERE Account__c =: accountid WITH SECURITY_ENFORCED];
		system.debug('listSP : ************' + listSp);
		system.debug('getAccountServicePointsWithFilter END');

		return listSp;
	}
    
	/**
	 * @description Modificato in string l'id
	 * @param id
	 * @param fields
	 * @return List<ServicePoint__c>
	 */
    public List<ServicePoint__c> getRecordById(String id, String fields) {
		contractSrv.checkReadAccess(fields);
        List<ServicePoint__c> servicePoints = Database.query('SELECT '+ String.escapeSingleQuotes(fields) + ' FROM ServicePoint__c WHERE Id = :id WITH SECURITY_ENFORCED LIMIT 1');

        return servicePoints;
	}

	/**
	 * @description getRecordByIdList
	 * @param id
	 * @param fields
	 * @return List<ServicePoint__c>
	 */
	public List<ServicePoint__c> getRecordByIdList(List<String> id, String fields) {
		contractSrv.checkReadAccess(fields);

        List<ServicePoint__c> servicePoints = Database.query('SELECT '+ String.escapeSingleQuotes(fields) + ' FROM ServicePoint__c WHERE Id IN :id ');

        return servicePoints;
	}

	/**
	 * @description getRecordByCode
	 * @param code
	 * @param fields
	 * @return List<ServicePoint__c>
	 */
	public List<ServicePoint__c> getRecordByCode(String code, String fields) {
		contractSrv.checkReadAccess(fields);
        List<ServicePoint__c> servicePoints = Database.query('SELECT '+ String.escapeSingleQuotes(fields) + ' FROM ServicePoint__c WHERE ServicePointCode__c = :code WITH SECURITY_ENFORCED LIMIT 1');
        return servicePoints;
    }

	/**
	 * @description getRecordFromCode
	 * @param code
	 * @param fields
	 * @return List<ServicePoint__c>
	 */
    public List<ServicePoint__c> getRecordFromCode(String code, String fields) {
		system.debug('getRecordByCode HDT_QR_ServicePoint START');
		contractSrv.checkReadAccess(fields);
		List<Contract> contracts = Database.query('SELECT Id, Name, ServicePoint__c,ContractNumber,SAPContractCode__c  FROM Contract WHERE SAPContractCode__c =:code LIMIT 1');
		system.debug('List contracts'+contracts.toString());
		String spCode ;
		if(!Contracts.isEmpty()){
			system.debug('entra qui'+contracts.toString());
			system.debug('entra qui'+contracts.get(0).servicePoint__c);
			spCode= contracts.get(0).servicePoint__c;

		}
		List<ServicePoint__c> servicePoints = new List<ServicePoint__c>();
		system.debug('spCode ******** :' + spCode);
		if(spCode != null){
			servicePoints = Database.query('SELECT '+ String.escapeSingleQuotes(fields) + ' FROM ServicePoint__c WHERE Id = :spCode LIMIT 1');
		}
        
		system.debug('getRecordByCode HDT_QR_ServicePoint END');

        return servicePoints;
    }

	/**
	 * @description getRecordFromCodeWithFilter
	 * @param code
	 * @param fields
	 * @param additionalFilter
	 * @return List<ServicePoint__c>
	 */
	public List<ServicePoint__c> getRecordFromCodeWithFilter(String code, String fields, string additionalFilter) {
		system.debug('getRecordFromCodeWithFilter HDT_QR_ServicePoint START');
		contractSrv.checkReadAccess(fields);
		// string queryContract;
		List<Contract> contracts = new List<Contract>();

		if(additionalFilter.contains('status')){
			contracts = Database.query('SELECT Id, Name, ServicePoint__c,ContractNumber,SAPContractCode__c  FROM Contract WHERE SAPContractCode__c =:code '+additionalFilter+'LIMIT 1');
		}else{
			String addFilterReplaced = additionalFilter.replaceAll('CommoditySector__c', 'ServicePoint__r.CommoditySector__c');
			system.debug('******************' + addFilterReplaced);
			contracts = Database.query('SELECT Id, Name, ServicePoint__c,ContractNumber,SAPContractCode__c, ServicePoint__r.CommoditySector__c FROM Contract WHERE SAPContractCode__c =:code '+ addFilterReplaced +' LIMIT 1');
		}
		system.debug('List contracts'+contracts.toString());
		String spCode ;
		if(!contracts.isEmpty()){
			system.debug('entra qui'+contracts.toString());
			system.debug('entra qui'+contracts.get(0).servicePoint__c);
			spCode= contracts.get(0).servicePoint__c;

		}
		List<ServicePoint__c> servicePoints = new List<ServicePoint__c>();
		system.debug('spCode ******** :' + spCode);
		if(spCode != null){
			// String query ;
			if(additionalFilter.contains('Commodity')){
				servicePoints = Database.query('SELECT '+ String.escapeSingleQuotes(fields) + ' FROM ServicePoint__c WHERE Id = :spCode '+additionalFilter+' LIMIT 1');
			}
			else
			{
				servicePoints = Database.query('SELECT '+ String.escapeSingleQuotes(fields) + ' FROM ServicePoint__c WHERE Id = :spCode LIMIT 1');
			}
			
		}
        
		system.debug('getRecordFromCodeWithFilter HDT_QR_ServicePoint END');

        return servicePoints;
    }

    /** 
	 * @description Query for Serial Number
	 * @param serialNumber
	 * @param fields
	 * @return List<ServicePoint__c>
	 */
	public List<ServicePoint__c> getServicePointsByMeterSerialNumber(String serialNumber, String fields) {
		contractSrv.checkReadAccess(fields);
		String stringSerialNumber = '%' + serialNumber + '%';
		List<ServicePoint__c> servicePoints = Database.query('SELECT ' + String.escapeSingleQuotes(fields) +	' FROM ServicePoint__c WHERE MeterSN__c LIKE :stringSerialNumber ');
		return servicePoints;
    }
	
	/** 
	 * @description getServicePointsByMeterSerialNumberWithFilter
	 * @param serialNumber
	 * @param fields
	 * @param additionalFilter
	 * @return List<ServicePoint__c>
	 */
	public List<ServicePoint__c> getServicePointsByMeterSerialNumberWithFilter(String serialNumber, String fields,String additionalFilter){
		system.debug('getServicePointsByMeterSerialNumberWithFilter START');
		contractSrv.checkReadAccess(fields);
		String stringSerialNumber = '%' + serialNumber + '%';
		// String query;
		List<ServicePoint__c> servicePoints = new List<ServicePoint__c>();
		if(!additionalFilter.contains('status')){
			servicePoints =	Database.query('SELECT ' + String.escapeSingleQuotes(fields) + ' FROM ServicePoint__c WHERE MeterSN__c LIKE :stringSerialNumber '+ additionalFilter);
		}
		else
		{
			servicePoints = Database.query('SELECT ' + String.escapeSingleQuotes(fields) + ' FROM ServicePoint__c WHERE MeterSN__c LIKE :stringSerialNumber ');
		}
		
		system.debug('getServicePointsByMeterSerialNumberWithFilter END');
		return servicePoints;
	}
    
    /**
	 * @description Query for POD
	 * @param code
	 * @param fields
	 * @return List<ServicePoint__c>
	 */
	public List<ServicePoint__c> getServicePointsByCode(String code, String fields) {
		contractSrv.checkReadAccess(fields);
		String stringCode = code.trim();
		List<ServicePoint__c> servicePoints = Database.query('SELECT ' + String.escapeSingleQuotes(fields) + ' FROM ServicePoint__c WHERE ServicePointCode__c = :stringCode ');
		return servicePoints;
	}

	/**
	 * @description getServicePointsByCodeWithFilter
	 * @param code
	 * @param fields
	 * @param additionalFilter
	 * @return List<ServicePoint__c>
	 */
	public List<ServicePoint__c> getServicePointsByCodeWithFilter(String code, String fields,String additionalFilter) {
		contractSrv.checkReadAccess(fields);
		String stringCode = code.trim();
		// String query;
		List<ServicePoint__c> servicePoints = new List<ServicePoint__c>();
		if(!additionalFilter.contains('status')){
			servicePoints = Database.query('SELECT ' + String.escapeSingleQuotes(fields) + ' FROM ServicePoint__c WHERE ServicePointCode__c = :stringCode '+ additionalFilter);
		}
		else
		{
			servicePoints = Database.query('SELECT ' + String.escapeSingleQuotes(fields) +	' FROM ServicePoint__c WHERE ServicePointCode__c = :stringCode ');
		}

		// List<ServicePoint__c> servicePoints = Database.query(query);
		return servicePoints;
	}

	/**
	 * @description Query for Getting All Account Contracts
	 * @param accountid
	 * @return List<Contract>
	 */
	public List<Contract> getAccountContracts(String accountid) {
		contractSrv.checkReadAccess('ContractNumber, Status, Account.Name, AccountId');
		return [SELECT ContractNumber, Status, Account.Name, AccountId FROM Contract WHERE AccountId =: accountid  WITH SECURITY_ENFORCED];
	}

	/**
	 * @description Query for Getting All Account Subscriptions
	 * @param accountid
	 * @return List<SBQQ__Subscription__c>
	 */
	public List<SBQQ__Subscription__c> getAccountSubscriptions(String accountid) {
		contractSrv.checkReadAccess(' Name, SBQQ__Contract__r.ContractNumber, SBQQ__Account__c, SBQQ__Account__r.Name, ServicePoint__r.ServicePointCode__c');
		//List<ServicePoint__c> servicePoints = [ SELECT ServicePointCode__c ,(SELECT Name,SBQQ__Contract__r.ContractNumber FROM Subscriptions__r) FROM ServicePoint__c ];
		return [SELECT Name, SBQQ__Contract__r.ContractNumber, SBQQ__Account__c, SBQQ__Account__r.Name, ServicePoint__r.ServicePointCode__c FROM SBQQ__Subscription__c WHERE SBQQ__Account__c =: accountid WITH SECURITY_ENFORCED];
	}

	/**
	 * @description Getting Custom Settimg 'CS_SelezioneFornitura'
	 * @return CS_SelezioneFornitura__c
	 */
	public CS_SelezioneFornitura__c getCustomSetting() {
		contractSrv.checkReadAccess('Max_Record__c, OutputServicePoint__c');
		return [SELECT Output_Contract__c,Max_Record__c, OutputServicePoint__c FROM CS_SelezioneFornitura__c WITH SECURITY_ENFORCED][0];
	}

	/**
	 * @description Getting Custom Settimg FIELD REQUIRED ELE 'CS_SelezioneFornitura'
	 * @return CS_SelezioneFornitura__c
	 */
	@AuraEnabled
	public static CS_SelezioneFornitura__c getCustomSettingFieldsRequiredEle() {
		contractSrv.checkReadAccess('FieldRequiredEle__c');
		return [SELECT FieldRequiredEle__c FROM CS_SelezioneFornitura__c WITH SECURITY_ENFORCED];
	}

	/**
	 * @description Getting Custom Settimg FIELD REQUIRED GAS 'CS_SelezioneFornitura'
	 * @return CS_SelezioneFornitura__c
	 */
	@AuraEnabled
	public static CS_SelezioneFornitura__c getCustomSettingFieldsRequiredGas() {
		contractSrv.checkReadAccess('FieldRequiredGas__c');
		return [SELECT FieldRequiredGas__c FROM CS_SelezioneFornitura__c WITH SECURITY_ENFORCED];
	}
}