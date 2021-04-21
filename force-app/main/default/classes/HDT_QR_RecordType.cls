public inherited sharing class HDT_QR_RecordType {
    
    public Id getRecordTypeIdByName(String developerName) {
        return [
            SELECT Id 
            FROM RecordType 
            WHERE DeveloperName = :developerName
            WITH SECURITY_ENFORCED 
            LIMIT 1
        ].Id;
    }

    public List<Id> getRecordTypeIdsByNames(List<String> developerNames) {

        List<RecordType> recordTypes =  [
            SELECT Id 
            FROM RecordType 
            WHERE DeveloperName IN :developerNames
            WITH SECURITY_ENFORCED 
        ];

        List<Id> recordTypeIds = new List<Id>();
        for (RecordType recordType : recordTypes) {
            recordTypeIds.add(recordType.Id);
        }

        return recordTypeIds;
    }
    
    public RecordType getRecordType(String developerName, String objectType) {
        
        String query = 'SELECT Id FROM RecordType WHERE DeveloperName = :developerName and SobjectType = :objectType WITH SECURITY_ENFORCED';
        List<RecordType> recordTypes = Database.query(query);

        return recordTypes[0];
    }
}
