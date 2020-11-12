public inherited sharing class HDT_QR_ServicePoint {
    
    public List<ServicePoint__c> getRecordById(Id id, String fields) {
        

        // String stringId = String.escapeSingleQuotes(id);
        // String stringFields = String.escapeSingleQuotes(fields);

        String query = 'SELECT '+ fields +
                ' FROM ServicePoint__c WHERE Id = :id LIMIT 1';
        List<ServicePoint__c> servicePoints = Database.query(query);

        return servicePoints;
    }

    public List<ServicePoint__c> getRecordByCode(String code, String fields) {
        
        

        // String stringCode = String.escapeSingleQuotes(code.trim());
        // String stringFields = String.escapeSingleQuotes(fields);

        String query = 'SELECT '+ fields +
                ' FROM ServicePoint__c WHERE ServicePointCode__c = :code LIMIT 1';
        List<ServicePoint__c> servicePoints = Database.query(query);
        return servicePoints;
    }
}
