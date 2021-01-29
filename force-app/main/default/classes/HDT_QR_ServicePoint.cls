/**
 * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
 * @date 30/10/2020
 * @description HDT_QR_ServicePoint.cls - Class that holds queries for ServicePoint__c
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */

public inherited sharing class HDT_QR_ServicePoint {
    
    public List<ServicePoint__c> getRecordById(Id id, String fields) {

        String query = 'SELECT '+ fields +
                ' FROM ServicePoint__c WHERE Id = :id LIMIT 1';
        List<ServicePoint__c> servicePoints = Database.query(query);

        return servicePoints;
    }

    public List<ServicePoint__c> getRecordByCode(String code, String fields) {

        String query = 'SELECT '+ fields +
                ' FROM ServicePoint__c WHERE ServicePointCode__c = :code LIMIT 1';
        List<ServicePoint__c> servicePoints = Database.query(query);
        return servicePoints;
    }

    /*
	 * Query for Serial Number
	 */
	public List<ServicePoint__c> getServicePointsByMeterSerialNumber(String serialNumber, String fields) {
		String stringSerialNumber = '%' + serialNumber + '%';
		String query = 'SELECT ' + fields +
				' FROM ServicePoint__c WHERE MeterSN__c LIKE :stringSerialNumber ';
		List<ServicePoint__c> servicePoints = Database.query(query);
		return servicePoints;
    }
    
    /*
	 * Query for POD
	 */
	public List<ServicePoint__c> getServicePointsByCode(String code, String fields) {
		String stringCode = code.trim();
		String query = 'SELECT ' + fields +
				' FROM ServicePoint__c WHERE ServicePointCode__c = :stringCode ';
		List<ServicePoint__c> servicePoints = Database.query(query);
		return servicePoints;
	}
}
