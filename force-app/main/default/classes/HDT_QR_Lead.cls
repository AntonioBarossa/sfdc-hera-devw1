/**
* @author Sabina Levonja (sabina.levonja@dunegroup.it)
* @date 21/04/2021
* @description HDT_QR_Lead 
* @history Sabina Levonja – 21/04/2021 – created class 
*/
public  inherited sharing class HDT_QR_Lead {
    
    public Lead getRecordById(String id) {
        
        String query = 'SELECT  Firstname,LastName,IndividualId,birthdate__c,gender__c,birthcity__c,country,state,city,PostalCode,street,streetName__c,StreetNumber__c,CityCode__c,StreetNumberExtension__c,StreetCode__c,PlaceCode__c,Place__c,IsAddressVerified__c,CreatedBy.LoginChannel__c FROM Lead WHERE Id = :id WITH SECURITY_ENFORCED';
        List<Lead> leads = Database.query(query);

        return leads[0];

    }

    public List<Lead> getRecordsById(List<String> ids) {
        
        String query = 'SELECT  Firstname,LastName,IndividualId, CompanyOwner__c FROM Lead WHERE Id IN :ids WITH SECURITY_ENFORCED';
        List<Lead> leads = Database.query(query);

        return leads;

    }

           /**
     * @author Andrei Necsulescu (andrei.necsulescu@webresults.it)
     * @description Get Contact Point records by Id
     * @param String individualId Id of the individual to filter the Leads
     * @param String fields fields to retrieve separated by ,
     */
    public List<Lead> getRecordByIndividual(String individualId, String fields) {

        String query = 'SELECT '+ fields +
                ' FROM Lead WHERE IndividualId = :individualId WITH SECURITY_ENFORCED';

        return Database.query(query);

    }
    
}