/**
 * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
 * @date 30/10/2020
 * @description HDT_QR_ServicePoint.cls - Class that holds queries for ServicePoint__c
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */
public inherited sharing class HDT_QR_ServicePoint {
	
	private static HDT_SRV_Contract contractSrv = new HDT_SRV_Contract();
	String fieldSp =  'Id, Account__c, Account__r.Name, CommoditySector__c, ServicePointCode__c, SAPImplantCode__c,MeterSN__c, SupplyAddress__c, Distributor__c, Distributor__r.Name, RecordType.Name, ImplantType__c, ImplantTypeTemp__c, MeterStatus__c, SupplyPlace__c';
	/*
	 * Query for Getting All Account Service Points
	 */
	public List<ServicePoint__c> getAccountServicePoints(String accountid) {
		contractSrv.checkReadAccess('Id, Account__c,Account__r.Name, ServicePointCode__c,SAPImplantCode__c, MeterSN__c, SupplyAddress__c, Distributor__c, Distributor__r.Name,recordType.Name,');
		List<ServicePoint__c> listSp = new List<ServicePoint__c>();
		return listSp= [SELECT Id, Account__c,Account__r.Name, ServicePointCode__c,SAPImplantCode__c, MeterSN__c, SupplyAddress__c, Distributor__c, Distributor__r.Name,recordType.Name,MeterStatus__c,CommoditySector__c,ImplantType__c,ImplantTypeTemp__c FROM ServicePoint__c WHERE Account__c =: accountid WITH SECURITY_ENFORCED];
	}
	
	/**
	 * @description getAddressFornitura
	 * @param accountid
	 * @return List<ServicePoint__c>
	 */
	public List<ServicePoint__c> getAddressFornitura(String accountid) {
		contractSrv.checkReadAccess('Account__c, SupplyStreet__c,SupplyStreetName__c, SupplyStreetNumber__c, SupplyStreetNumberExtension__c, SupplyPlace__c, SupplyCity__c,SupplyProvince__c, SupplyPostalCode__c, SupplyCountry__c');
		List<ServicePoint__c> listSp = new List<ServicePoint__c>();
		return listSp= [SELECT Account__c, SupplyCityCode__c,SupplyStreetCode__c,SupplyStreetName__c,SupplyStreet__c, SupplyStreetNumber__c, SupplyStreetNumberExtension__c, SupplyPlace__c, SupplyCity__c,SupplyProvince__c, SupplyPostalCode__c, SupplyCountry__c,SupplySAPCityCode__c,SupplySAPStreetCode__c FROM ServicePoint__c WHERE Account__c =: accountid WITH SECURITY_ENFORCED];
	}

	/**
	 * @description Query for Getting All Account Service Points
	 * @param accountid
	 * @param additionalFilter
	 * @return List<ServicePoint__c>
	 */
	public List<ServicePoint__c> getAccountServicePointsWithFilter(String accountid,String additionalFilter) {

		List<ServicePoint__c> listSp = new List<ServicePoint__c>();

		contractSrv.checkReadAccess(fieldSp);
		if(additionalFilter.contains('Commodity')){
			String query = 'SELECT ' +fieldSp +' FROM ServicePoint__c WHERE Account__c =: accountid ' +additionalFilter;
			listSp = Database.query(String.escapeSingleQuotes(query).replace('\\', ''));
		}
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
	 * @description getRecordByImplantCode
	 * @param implantCode
	 * @param fields
	 * @return List<ServicePoint__c>
	 */
	public List<ServicePoint__c> getRecordByImplantCode(String implantCode, String fields) {
		contractSrv.checkReadAccess(fields);
        List<ServicePoint__c> servicePoints = Database.query('SELECT '+ String.escapeSingleQuotes(fields) + ' FROM ServicePoint__c WHERE SAPImplantCode__c = :implantCode WITH SECURITY_ENFORCED LIMIT 1');
        return servicePoints;
    }

	/**
	 * @description getRecordFromCode
	 * @param code
	 * @param fields
	 * @return List<ServicePoint__c>
	 */
    public List<ServicePoint__c> getRecordFromCode(String code, String fields) {
		contractSrv.checkReadAccess(fields);
		List<Contract> contracts = Database.query('SELECT Id, Name, ServicePoint__c,ContractNumber,SAPContractCode__c  FROM Contract WHERE SAPContractCode__c =:code LIMIT 1');
		String spCode ;
		if(!Contracts.isEmpty()){
			spCode= contracts.get(0).servicePoint__c;
		}
		List<ServicePoint__c> servicePoints = new List<ServicePoint__c>();
		if(spCode != null){
			servicePoints = Database.query('SELECT '+ String.escapeSingleQuotes(fields) + ' FROM ServicePoint__c WHERE Id = :spCode LIMIT 1');
		}
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

		contractSrv.checkReadAccess(fields);
		List<Contract> contracts = new List<Contract>();

		if(additionalFilter.contains('status')){
			contracts = Database.query('SELECT Id, Name, ServicePoint__c,ContractNumber,SAPContractCode__c  FROM Contract WHERE SAPContractCode__c =:code '+String.escapeSingleQuotes(additionalFilter).replace('\\', '')+'LIMIT 1');
		}
		else{
			String addFilterReplaced = additionalFilter.replaceAll('CommoditySector__c', 'ServicePoint__r.CommoditySector__c');
			contracts = Database.query('SELECT Id, Name, ServicePoint__c,ContractNumber,SAPContractCode__c, ServicePoint__r.CommoditySector__c FROM Contract WHERE SAPContractCode__c =:code '+ String.escapeSingleQuotes(addFilterReplaced).replace('\\', '') +' LIMIT 1');
		}
		String spCode ;
		if(!contracts.isEmpty()){
			spCode= contracts.get(0).servicePoint__c;
		}
		List<ServicePoint__c> servicePoints = new List<ServicePoint__c>();
		if(spCode != null){
			if(additionalFilter.contains('Commodity')){
				servicePoints = Database.query('SELECT '+ String.escapeSingleQuotes(fields) + ' FROM ServicePoint__c WHERE Id = :spCode '+String.escapeSingleQuotes(additionalFilter).replace('\\', '')+' LIMIT 1');
			}
			else{
				servicePoints = Database.query('SELECT '+ String.escapeSingleQuotes(fields) + ' FROM ServicePoint__c WHERE Id = :spCode LIMIT 1');
			}
		}

        return servicePoints;
    }

    /** 
	 * @description Query for Serial Number
	 * @param serialNumber
	 * @param fields
	 * @return List<ServicePoint__c>
	 */
	@SuppressWarnings('PMD.UnusedLocalVariable')
	public List<ServicePoint__c> getServicePointsByMeterSerialNumber(String serialNumber, String fields) {
		contractSrv.checkReadAccess(fields);
		String stringSerialNumber = '%' + serialNumber + '%';
		List<ServicePoint__c> servicePoints = Database.query('SELECT ' + String.escapeSingleQuotes(fields) +' FROM ServicePoint__c WHERE MeterSN__c LIKE :stringSerialNumber ');
		return servicePoints;
    }
	
	/** 
	 * @description getServicePointsByMeterSerialNumberWithFilter
	 * @param serialNumber
	 * @param fields
	 * @param additionalFilter
	 * @return List<ServicePoint__c>
	 */
	@SuppressWarnings('PMD.UnusedLocalVariable')
	public List<ServicePoint__c> getServicePointsByMeterSerialNumberWithFilter(String serialNumber, String fields, String additionalFilter){

		contractSrv.checkReadAccess(fields);
		String stringSerialNumber = '%' + serialNumber + '%';
		
		List<ServicePoint__c> servicePoints = new List<ServicePoint__c>();
		if(!additionalFilter.contains('status')){
			servicePoints =	Database.query(' SELECT ' + String.escapeSingleQuotes(fields) +' FROM ServicePoint__c WHERE MeterSN__c LIKE :stringSerialNumber '+ String.escapeSingleQuotes(additionalFilter).replace('\\', ''));
		}
		else{
			servicePoints = Database.query(' SELECT ' + String.escapeSingleQuotes(fields) +' FROM ServicePoint__c WHERE MeterSN__c LIKE :stringSerialNumber ');
		}		
		return servicePoints;
	}

	/** 
	 * @description Query for Address
	 * @param address
	 * @param fields
	 * @return List<ServicePoint__c>
	 */
	@SuppressWarnings('PMD.UnusedLocalVariable')
	public List<ServicePoint__c> getServicePointsByAddress(String address, String fields) {
		contractSrv.checkReadAccess(fields);
		String stringAddress = '%' + address + '%';
		List<ServicePoint__c> servicePoints = Database.query('SELECT ' + String.escapeSingleQuotes(fields) +' FROM ServicePoint__c WHERE CommoditySector__c = \'Ambiente\' AND ServicePointCode__c != null AND SupplyAddress__c LIKE :stringAddress LIMIT 50');
		return servicePoints;
    }
    
    /**
	 * @description Query for POD
	 * @param code
	 * @param fields
	 * @return List<ServicePoint__c>
	 */
	@SuppressWarnings('PMD.UnusedLocalVariable')
	public List<ServicePoint__c> getServicePointsByCode(String code, String fields) {
		contractSrv.checkReadAccess(fields);
		String stringCode = code.trim();
		List<ServicePoint__c> servicePoints = Database.query('SELECT ' + String.escapeSingleQuotes(fields) + ' FROM ServicePoint__c WHERE ServicePointCode__c = :stringCode ');
		return servicePoints;
	}

	/**
	 * @description Query for POD
	 * @param code
	 * @param fields
	 * @return List<ServicePoint__c>
	 */
	@SuppressWarnings('PMD.UnusedLocalVariable')
	public List<ServicePoint__c> getServicePointsByCodeWater(String code, String fields) {
		contractSrv.checkReadAccess(fields);
		String stringCode = code.trim();
		List<ServicePoint__c> servicePoints = Database.query('SELECT ' + String.escapeSingleQuotes(fields) + ' FROM ServicePoint__c WHERE CommoditySector__c = \'Acqua\' AND ServicePointCode__c = :stringCode ');
		return servicePoints;
	}

	@SuppressWarnings('PMD.UnusedLocalVariable')
	public List<ServicePoint__c> getServicePointsByDatiCatastali(List<String> datiCatastaliList, String fields ) {

		List<LandRegistry__c> landRegistries = Database.query('SELECT ServicePoint__c FROM LandRegistry__c WHERE RegistryCity__c IN :datiCatastaliList AND RegistryCityCode__c IN :datiCatastaliList AND UrbanSection__c IN :datiCatastaliList AND Sheet__c IN :datiCatastaliList AND ParticleSheet__c IN :datiCatastaliList AND Subaltern__c  IN :datiCatastaliList LIMIT 50 ');
		System.debug('I Land Registry sono: ' +landRegistries);
		List<String> servicePointIds = new List<String>();
		for (LandRegistry__c landRegistry : landRegistries){
			servicePointIds.add(landRegistry.ServicePoint__c);
		}
		System.debug('I Service Point sono: ' +servicePointIds);
		List<ServicePoint__c> servicePoints = Database.query('SELECT ' + String.escapeSingleQuotes(fields) + ' FROM ServicePoint__c WHERE Id IN :servicePointIds ');
		return servicePoints;
    }

	/**
	 * @description getServicePointsByCodeWithFilter
	 * @param code
	 * @param fields
	 * @param additionalFilter
	 * @return List<ServicePoint__c>
	 */
	@SuppressWarnings('PMD.UnusedLocalVariable')
	public List<ServicePoint__c> getServicePointsByCodeWithFilter(String code, String fields,String additionalFilter) {

		contractSrv.checkReadAccess(fields);
		String stringCode = code.trim();
		
		List<ServicePoint__c> servicePoints = new List<ServicePoint__c>();
		if(!additionalFilter.contains('status')){
			servicePoints = Database.query('SELECT ' + String.escapeSingleQuotes(fields) + ' FROM ServicePoint__c WHERE ServicePointCode__c = :stringCode '+ String.escapeSingleQuotes(additionalFilter).replace('\\', ''));
		}
		else{
			servicePoints = Database.query('SELECT ' + String.escapeSingleQuotes(fields) +	' FROM ServicePoint__c WHERE ServicePointCode__c = :stringCode ');
		}

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
	/**
	 * @description Getting Custom Settimg FIELD REQUIRED ACQUA 'CS_SelezioneFornitura'
	 * @return CS_SelezioneFornitura__c
	 */
	@AuraEnabled
	public static CS_SelezioneFornitura__c getCustomSettingFieldsRequiredAcqua() {
		contractSrv.checkReadAccess('FieldRequiredWater__c');
		return [SELECT FieldRequiredWater__c FROM CS_SelezioneFornitura__c WITH SECURITY_ENFORCED];
	}

	/**
	 * @description Getting Custom Settimg FIELD REQUIRED AMBIENTE 'CS_SelezioneFornitura'
	 * @return CS_SelezioneFornitura__c
	 */
	@AuraEnabled
	public static CS_SelezioneFornitura__c getCustomSettingFieldsRequiredAmbiente() {
		contractSrv.checkReadAccess('FieldRequiredWaste__c');
		return [SELECT FieldRequiredWaste__c FROM CS_SelezioneFornitura__c WITH SECURITY_ENFORCED];
	}
}