public  inherited sharing class HDT_QR_Lead {
    
    public Lead getRecordById(String id) {
        
        String query = 'SELECT  Firstname,LastName,IndividualId,birthdate__c,gender__c,birthcity__c,country,state,city,PostalCode,street,streetName__c,StreetNumber__c,CityCode__c,StreetNumberExtension__c,StreetCode__c FROM Lead WHERE Id = :id WITH SECURITY_ENFORCED';
        List<Lead> leads = Database.query(query);

        return leads[0];

    }

    public List<Lead> getRecordsById(List<String> ids) {
        
        String query = 'SELECT  Firstname,LastName,IndividualId, CompanyOwner__c FROM Lead WHERE Id IN :ids WITH SECURITY_ENFORCED';
        List<Lead> leads = Database.query(query);

        return leads;

    }

    
}
