/**
 * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
 * @date 30/10/2020
 * @description HDT_QR_ServicePoint.cls - Class that holds queries for ServicePoint__c
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */

public inherited sharing class HDT_QR_ServicePoint {
	
	private static HDT_SRV_Contract contractSrv = new HDT_SRV_Contract();
	String fieldSp =  'Id, Account__c, Account__r.Name, CommoditySector__c, ServicePointCode__c, MeterSN__c, SupplyAddress__c, Distributor__r.Name,recordType.Name,ImplantType__c';
	/*
	 * Query for Getting All Account Service Points
	 */
	public  List<ServicePoint__c> getAccountServicePoints(String accountid) {
		system.debug('accountId : '+ accountId);
		contractSrv.checkReadAccess('Id, Account__c,Account__r.Name, ServicePointCode__c, MeterSN__c, SupplyAddress__c, Distributor__r.Name,recordType.Name');
		List<ServicePoint__c> listSp = new List<ServicePoint__c>();
		return listSp= [SELECT Id, Account__c,Account__r.Name, ServicePointCode__c, MeterSN__c, SupplyAddress__c, Distributor__r.Name,recordType.Name FROM ServicePoint__c WHERE Account__c =: accountid WITH SECURITY_ENFORCED];
	}

	/*
	 * Query for Getting All Account Service Points
	 */
	public  List<ServicePoint__c> getAccountServicePointsWithFilter(String accountid,String additionalFilter) {
		system.debug('getAccountServicePointsWithFilter START');
		contractSrv.checkReadAccess(fieldSp);
        String query;
		IF(additionalFilter.contains('Commodity')){
			query = 'SELECT '+fieldSp+' FROM ServicePoint__c WHERE Account__c =: accountid '+additionalFilter;
		}
		//List<ServicePoint__c> listSP = [SELECT Id, Account__c, ServicePointCode__c, MeterSN__c, SupplyAddress__c, Distributor__c,recordType.Name FROM ServicePoint__c WHERE Account__c =: accountid WITH SECURITY_ENFORCED];
		List<ServicePoint__c> listSp = Database.query(query);
		system.debug('listSP : ************' + listSp);
		system.debug('getAccountServicePointsWithFilter END');

		return listSp;
	}
    
    
    public List<ServicePoint__c> getRecordById(Id id, String fields) {
		contractSrv.checkReadAccess(fields);
        String query = 'SELECT '+ fields +
                ' FROM ServicePoint__c WHERE Id = :id LIMIT 1';
        List<ServicePoint__c> servicePoints = Database.query(query);

        return servicePoints;
	}

	public List<ServicePoint__c> getRecordByCode(String code, String fields) {
		contractSrv.checkReadAccess(fields);
        String query = 'SELECT '+ fields +
                ' FROM ServicePoint__c WHERE ServicePointCode__c = :code LIMIT 1';
        List<ServicePoint__c> servicePoints = Database.query(query);
        return servicePoints;
    }

    public List<ServicePoint__c> getRecordFromCode(String code, String fields) {
		system.debug('getRecordByCode HDT_QR_ServicePoint START');
		contractSrv.checkReadAccess(fields);
		string queryContract = 'SELECT Id, Name, ServicePoint__c,ContractNumber,SAPContractCode__c  FROM Contract WHERE SAPContractCode__c =:code LIMIT 1';
		List<Contract> contracts = Database.query(queryContract);
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
			String query = 'SELECT '+ fields +
                ' FROM ServicePoint__c WHERE Id = :SpCode LIMIT 1';
			servicePoints = Database.query(query);
		}
        
		system.debug('getRecordByCode HDT_QR_ServicePoint END');

        return servicePoints;
    }

	public List<ServicePoint__c> getRecordFromCodeWithFilter(String code, String fields, string additionalFilter) {
		system.debug('getRecordFromCodeWithFilter HDT_QR_ServicePoint START');
		contractSrv.checkReadAccess(fields);
		string queryContract;
		if(additionalFilter.contains('status')){
			queryContract = 'SELECT Id, Name, ServicePoint__c,ContractNumber,SAPContractCode__c  FROM Contract WHERE SAPContractCode__c =:code '+additionalFilter+'LIMIT 1';
		}else{
			String addFilterReplaced = additionalFilter.replaceAll('CommoditySector__c', 'ServicePoint__r.CommoditySector__c');
			system.debug('******************' + addFilterReplaced);
			queryContract = 'SELECT Id, Name, ServicePoint__c,ContractNumber,SAPContractCode__c, ServicePoint__r.CommoditySector__c FROM Contract WHERE SAPContractCode__c =:code '+ addFilterReplaced +' LIMIT 1';
		}
		List<Contract> contracts = Database.query(queryContract);
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
			String query ;
			if(additionalFilter.contains('Commodity')){
				 query = 'SELECT '+ fields +
                ' FROM ServicePoint__c WHERE Id = :SpCode '+additionalFilter+' LIMIT 1';
			}
			else
			{
				 query = 'SELECT '+ fields +
                ' FROM ServicePoint__c WHERE Id = :SpCode LIMIT 1';
			}

			servicePoints = Database.query(query);
		}
        
		system.debug('getRecordFromCodeWithFilter HDT_QR_ServicePoint END');

        return servicePoints;
    }
    /*
	 * Query for Serial Number
	 */
	public List<ServicePoint__c> getServicePointsByMeterSerialNumber(String serialNumber, String fields) {
		contractSrv.checkReadAccess(fields);
		String stringSerialNumber = '%' + serialNumber + '%';
		String query = 'SELECT ' + fields +
				' FROM ServicePoint__c WHERE MeterSN__c LIKE :stringSerialNumber ';
		List<ServicePoint__c> servicePoints = Database.query(query);
		return servicePoints;
    }


	
	public List<ServicePoint__c> getServicePointsByMeterSerialNumberWithFilter(String serialNumber, String fields,String additionalFilter){
		system.debug('getServicePointsByMeterSerialNumberWithFilter START');
		contractSrv.checkReadAccess(fields);
		String stringSerialNumber = '%' + serialNumber + '%';
		String query;
		if(!additionalFilter.contains('status')){
			query = 'SELECT ' + fields +
				' FROM ServicePoint__c WHERE MeterSN__c LIKE :stringSerialNumber '+ additionalFilter;
		}
		else
		{
			query = 'SELECT ' + fields +
			' FROM ServicePoint__c WHERE MeterSN__c LIKE :stringSerialNumber ';
		}

		List<ServicePoint__c> servicePoints = Database.query(query);
		system.debug('getServicePointsByMeterSerialNumberWithFilter END');
		return servicePoints;
	}
    
    /*
	 * Query for POD
	 */
	public List<ServicePoint__c> getServicePointsByCode(String code, String fields) {
		contractSrv.checkReadAccess(fields);
		String stringCode = code.trim();
		String query = 'SELECT ' + fields +
				' FROM ServicePoint__c WHERE ServicePointCode__c = :stringCode ';
		List<ServicePoint__c> servicePoints = Database.query(query);
		return servicePoints;
	}


	public List<ServicePoint__c> getServicePointsByCodeWithFilter(String code, String fields,String additionalFilter) {
		contractSrv.checkReadAccess(fields);
		String stringCode = code.trim();
		String query ;
		if(!additionalFilter.contains('status')){
			query = 'SELECT ' + fields +
			' FROM ServicePoint__c WHERE ServicePointCode__c = :stringCode '+ additionalFilter;
		}
		else
		{
			query = 'SELECT ' + fields +
			' FROM ServicePoint__c WHERE ServicePointCode__c = :stringCode ';
		}
		
		List<ServicePoint__c> servicePoints = Database.query(query);
		return servicePoints;
	}


		/*
	 * Query for Getting All Account Contracts
	 */
	public List<Contract> getAccountContracts(String accountid) {
		contractSrv.checkReadAccess('ContractNumber, Status, Account.Name, AccountId');
		return [SELECT ContractNumber, Status, Account.Name, AccountId FROM Contract WHERE AccountId =: accountid  WITH SECURITY_ENFORCED];
	}

		/*
	 * Query for Getting All Account Subscriptions
	 */
	public List<SBQQ__Subscription__c> getAccountSubscriptions(String accountid) {
		contractSrv.checkReadAccess(' Name, SBQQ__Contract__r.ContractNumber, SBQQ__Account__c, SBQQ__Account__r.Name, ServicePoint__r.ServicePointCode__c');
		//List<ServicePoint__c> servicePoints = [ SELECT ServicePointCode__c ,(SELECT Name,SBQQ__Contract__r.ContractNumber FROM Subscriptions__r) FROM ServicePoint__c ];
		return [SELECT Name, SBQQ__Contract__r.ContractNumber, SBQQ__Account__c, SBQQ__Account__r.Name, ServicePoint__r.ServicePointCode__c FROM SBQQ__Subscription__c WHERE SBQQ__Account__c =: accountid WITH SECURITY_ENFORCED];
	}




	/*
	 * Getting Custom Settimg 'CS_SelezioneFornitura'
	 */
	public CS_SelezioneFornitura__c getCustomSetting() {
		contractSrv.checkReadAccess('Max_Record__c, OutputServicePoint__c');
		return [SELECT Output_Contract__c,Max_Record__c, OutputServicePoint__c FROM CS_SelezioneFornitura__c][0];
	}

		/*
	 * Getting Custom Settimg FIELD REQUIRED ELE 'CS_SelezioneFornitura'
	 */
	@AuraEnabled
	public static CS_SelezioneFornitura__c getCustomSettingFieldsRequiredEle() {
		contractSrv.checkReadAccess('FieldRequiredEle__c');
		return [SELECT FieldRequiredEle__c FROM CS_SelezioneFornitura__c];
	}

			/*
	 * Getting Custom Settimg FIELD REQUIRED GAS 'CS_SelezioneFornitura'
	 */
	@AuraEnabled
	public static CS_SelezioneFornitura__c getCustomSettingFieldsRequiredGas() {
		contractSrv.checkReadAccess(' FieldRequiredGas__c');
		return [SELECT FieldRequiredGas__c FROM CS_SelezioneFornitura__c];
	}
}
