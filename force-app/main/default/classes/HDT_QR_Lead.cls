public  inherited sharing class HDT_QR_Lead {
    
    public Lead getRecordById(String id) {
        
        String query = 'SELECT  Firstname,LastName,IndividualId FROM Lead WHERE Id = :id WITH SECURITY_ENFORCED';
        List<Lead> leads = Database.query(query);

        return leads[0];

    }

    public List<Lead> getRecordsById(List<String> ids) {
        
        String query = 'SELECT  Firstname,LastName,IndividualId FROM Lead WHERE Id IN :ids WITH SECURITY_ENFORCED';
        List<Lead> leads = Database.query(query);

        return leads;

    }

    
}
