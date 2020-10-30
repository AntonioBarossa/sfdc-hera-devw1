public with sharing class HDT_QR_ServicePoint {
    
    public List<ServicePoint__c> getRecordById(Id id, String fields) {
        
        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('ServicePoint__c', fields, 'read');
        securityAccess.checkSecurityAccess();

        String stringId = String.escapeSingleQuotes(id);
        String stringFields = String.escapeSingleQuotes(fields);

        String query = 'SELECT '+ stringFields +
                ' FROM ServicePoint__c WHERE Id = :stringId LIMIT 1';
        List<ServicePoint__c> servicePoints = Database.query(query);

        return servicePoints;
    }

    public List<ServicePoint__c> getRecordByCode(String code, String fields) {
        
        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('ServicePoint__c', fields, 'read');
        securityAccess.checkSecurityAccess();

        String stringCode = String.escapeSingleQuotes(code.trim());
        String stringFields = String.escapeSingleQuotes(fields);

        String query = 'SELECT '+ stringFields +
                ' FROM ServicePoint__c WHERE ServicePointCode__c = :stringCode LIMIT 1';
        List<ServicePoint__c> servicePoints = Database.query(query);
        return servicePoints;
    }
}
