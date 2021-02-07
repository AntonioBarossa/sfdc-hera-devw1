/**
 * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
 * @date 30/10/2020
 * @description HDT_QR_ServicePoint.cls - Class that holds queries for ServicePoint__c
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */

public inherited sharing class HDT_QR_ServicePoint {

	private static HDT_SRV_Contract contractSrv = new HDT_SRV_Contract();
	String fieldSP =  'Id, Account__c, Account__r.Name, CommoditySector__c, ServicePointCode__c, MeterSN__c, SupplyAddress__c, Distributor__r.Name,recordType.Name';
	/*
	 * Query for Getting All Account Service Points
	 */
	public  List<ServicePoint__c> getAccountServicePoints(String accountid) {
		system.debug('accountId : '+ accountId);
		contractSrv.checkReadAccess('Id, Account__c,Account__r.Name, ServicePointCode__c, MeterSN__c, SupplyAddress__c, Distributor__r.Name,recordType.Name');
		List<ServicePoint__c> listSP = new List<ServicePoint__c>();
		return listSP= [SELECT Id, Account__c,Account__r.Name, ServicePointCode__c, MeterSN__c, SupplyAddress__c, Distributor__r.Name,recordType.Name FROM ServicePoint__c WHERE Account__c =: accountid WITH SECURITY_ENFORCED];
	}

	/*
	 * Query for Getting All Account Service Points
	 */
	public  List<ServicePoint__c> getAccountServicePointsWithFilter(String accountid,String additionalFilter) {
		system.debug('getAccountServicePointsWithFilter START');
		contractSrv.checkReadAccess(fieldSP);
        String query = 'SELECT '+fieldSP+' FROM ServicePoint__c WHERE Account__c =: accountid '+additionalFilter;
		//List<ServicePoint__c> listSP = [SELECT Id, Account__c, ServicePointCode__c, MeterSN__c, SupplyAddress__c, Distributor__c,recordType.Name FROM ServicePoint__c WHERE Account__c =: accountid WITH SECURITY_ENFORCED];
		List<ServicePoint__c> listSP = Database.query(query);
		system.debug('listSP : ************' + listSP);
		system.debug('getAccountServicePointsWithFilter END');

		return listSP;
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
		string queryContract = 'SELECT Id, Name, ServicePoint__c,ContractNumber FROM Contract WHERE ContractNumber =:code LIMIT 1';
		List<Contract> Contracts = Database.query(queryContract);
		system.debug('List contracts'+Contracts.toString());
		String spCode ;
		if(!Contracts.isEmpty()){
			system.debug('entra qui'+Contracts.toString());
			system.debug('entra qui'+Contracts.get(0).servicePoint__c);
			spCode= Contracts.get(0).servicePoint__c;

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
		system.debug('getRecordByCode HDT_QR_ServicePoint START');
		contractSrv.checkReadAccess(fields);
		string queryContract = 'SELECT Id, Name, ServicePoint__c,ContractNumber FROM Contract WHERE ContractNumber =:code' +additionalFilter +'LIMIT 1';
		List<Contract> Contracts = Database.query(queryContract);
		system.debug('List contracts'+Contracts.toString());
		String spCode ;
		if(!Contracts.isEmpty()){
			system.debug('entra qui'+Contracts.toString());
			system.debug('entra qui'+Contracts.get(0).servicePoint__c);
			spCode= Contracts.get(0).servicePoint__c;

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
		contractSrv.checkReadAccess(fields);
		String stringSerialNumber = '%' + serialNumber + '%';
		String query = 'SELECT ' + fields +
				' FROM ServicePoint__c WHERE MeterSN__c LIKE :stringSerialNumber '+ additionalFilter;
		List<ServicePoint__c> servicePoints = Database.query(query);
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
		String query = 'SELECT ' + fields +
				' FROM ServicePoint__c WHERE ServicePointCode__c = :stringCode '+ additionalFilter;
		List<ServicePoint__c> servicePoints = Database.query(query);
		return servicePoints;
	}
}
