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

    public Id getRecordTypeIdByName(String developerName, String objectType)
    {
        // return [
        //     SELECT Id 
        //     FROM RecordType 
        //     WHERE DeveloperName = :developerName
        //     AND SobjectType = :objectType
        //     WITH SECURITY_ENFORCED 
        //     LIMIT 1
        // ].Id;

        return Schema.getGlobalDescribe().get(objectType).getDescribe().getRecordTypeInfosByDeveloperName().get(developerName).getRecordTypeId();
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
        
        // String query = 'SELECT Id FROM RecordType WHERE DeveloperName = :developerName and SobjectType = :objectType WITH SECURITY_ENFORCED';
        // List<RecordType> recordTypes = Database.query(query);
        // if(!recordTypes.isEmpty()){
        //     return recordTypes[0];
        // }else{
        //     return null;
        // }

        Id recordTypeId = Schema.getGlobalDescribe().get(objectType).getDescribe().getRecordTypeInfosByDeveloperName().get(developerName).getRecordTypeId();
        RecordType rc = new RecordType(Id = recordTypeId);
        return rc;
    }
}
