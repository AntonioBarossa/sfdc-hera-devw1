public inherited sharing class HDT_QR_Task {

    public List<Task> getRecordsByIds(Set<Id> ids) {
        return [
            SELECT 
            Id 
            FROM Task 
            WHERE Id IN :ids
            WITH SECURITY_ENFORCED
        ];
    }
}
