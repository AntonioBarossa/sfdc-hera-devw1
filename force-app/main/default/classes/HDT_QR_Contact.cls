/**
 * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
 * @date 14/01/2021
 * @description HDT_QR_Contact.cls
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */
public inherited sharing class HDT_QR_Contact {
    
    public Contact getRecordById(String id) {

        List<Contact> contactsList = [
            SELECT
            Name,
            FirstName,
            LastName,
            MobilePhone,
            Phone,
            Email,
            Fax,
            CertifiedEmail__c,
            IndividualId,
            FiscalCode__c,
            AccountId
            FROM Contact
            WHERE Id = :id
            WITH SECURITY_ENFORCED
        ];

        Contact contact = new Contact();

        if (!contactsList.isEmpty()) {
            contact = contactsList[0];
        }

        return contact;
    }

    public List<Contact> getRecordsById(List<String> ids) {

        List<Contact> contacts = Database.query('SELECT Firstname, accountId, LastName, IndividualId,Company__c,CompanyOwner__c  FROM Contact WHERE Id IN :ids WITH SECURITY_ENFORCED'); //HRAWRM-588_code_review_1550
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
            Id, Name,FirstName, LastName, Title, Phone, Email,DegreeOfStudies__c 
            FROM Contact
            WHERE AccountId = :accountId
            WITH SECURITY_ENFORCED
        ];
    }

    public Contact getContactsByIndividual(String individualId){
        return [
            SELECT
            Id,
            Email
            FROM Contact
            WHERE IndividualId = :individualId
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
    
    public List<Contact> getContactsIdByAccountIdList(List<String> accountIds) {
        // Start HRAWRM-450 07/09/2021 add CertifiedEmail__c
        return [Select id,CertifiedEmail__c,accountId,firstname,lastname,FiscalCode__c,Phone,MobilePhone,Email,Individual.ProfilingCompanyConsent__c from Contact where AccountId IN : accountIds];
    }

    // INIZIO SVILUPPI EVERIS

    public List<Contact> getRecordsByIds(Set<Id> ids) {
        return [
            SELECT 
            Id,
            Name,
            Email,
            Phone,
            ContactCode__c,
            MobilePhone,
            IndividualId,
            Fax,
            CertifiedEmail__c,
            MailingAddressFormula__c,
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

    public List<Contact> getContactsByOwnerId(String ownerId, String ownerName) {
        return [
            SELECT Id,
            Name,
            MailingLatitude,
            MailingLongitude
            FROM Contact
            WHERE OwnerId = :ownerId
            AND Name = :ownerName
            WITH SECURITY_ENFORCED
        ];
    }

    public Contact getContactCoordinates(String contactId) {
        return [
            SELECT Id,
            Name,
            MailingLatitude,
            MailingLongitude,
            LastGeolocationLatitude__c,
            LastGeolocationLongitude__c
            FROM Contact
            WHERE Id = :contactId
            WITH SECURITY_ENFORCED
        ];
    }

    public List<Contact> getContactByEmailAddress(String fromEmail){
        return [
            SELECT Id,
                   Name,
                   AccountId
              FROM Contact 
            WHERE Email = :fromEmail
            WITH SECURITY_ENFORCED
        ];
    }

        /**
     * @author Andrei Necsulescu (andrei.necsulescu@webresults.it)
     * @description Get Contact Point records by Id
     * @param String individualId Id of the individual to filter the Leads
     * @param String fields fields to retrieve separated by ,
     */
    public List<Contact> getRecordByIndividual(String individualId, String fields) {

        String query = 'SELECT '+ fields +
                ' FROM Contact WHERE IndividualId = :individualId WITH SECURITY_ENFORCED';

        return Database.query(query);

    }
}