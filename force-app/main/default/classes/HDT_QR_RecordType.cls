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
}
