public inherited sharing class HDT_QR_Contact {
    
    public Contact getRecordById(String id) {

        return [
            SELECT
            FirstName,
            LastName,
            FiscalCode__c
            FROM Contact
            WHERE Id = :id
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
    }
 public List<Contact> getRecordsById(List<String> ids) {

        String query = 'SELECT  Firstname,LastName, IndividualId  FROM Contact WHERE Id IN :ids WITH SECURITY_ENFORCED';
        List<Contact> contacts = Database.query(query);
        return contacts;
    }


    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 14/01/2021
    * @description Get Account primary Contact
    * @param String accountid
    * @return Contact
    */
    public List<Contact> getPrimaryContactByAccount(String accountId){
        return [
            SELECT
            Email
            FROM Contact
            WHERE AccountId = :accountId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 27/01/2021
    * @description Get all contacts related to account
    * @param String accountid
    * @return Contact
    */
    public List<Contact> getContactsByAccount(String accountId){
        return [
            SELECT
            Id,
            Email
            FROM Contact
            WHERE AccountId = :accountId
            WITH SECURITY_ENFORCED
        ];
    }

    public List<String> getContactsIdByAccountId(String accountId) {
        List <AccountContactRelation> accountContact = [
            SELECT ContactId from AccountContactRelation 
            WHERE AccountId = :accountId
            WITH SECURITY_ENFORCED
        ];

        List <String> res = new List <String>();
        for (AccountContactRelation acc : accountContact) {
            res.add(acc.ContactId);
        }
        return res;
    }

    // INIZIO SVILUPPI EVERIS

    public List<Contact> getRecordsByIds(Set<Id> ids) {
        return [
            SELECT 
            Id,
            Name,
            Email,
            Phone,
            MobilePhone,
            Fax,
            CertifiedEmail__c,
            CompanyOwner__c
            FROM Contact 
            WHERE Id IN :ids
            WITH SECURITY_ENFORCED
        ];
    }

    // FINE SVILUPPI EVERIS

    public Contact getRecordByFiscalCode(String fiscalCode) {
        String query = 'SELECT  Id, Email , MobilePhone , Phone FROM Contact WHERE FiscalCode__c = :fiscalCode WITH SECURITY_ENFORCED';
        List<Contact> contacts = Database.query(query);
        if(contacts.size()>0){
            return contacts[0];
        }else{
            return null;

        }
    }
}
