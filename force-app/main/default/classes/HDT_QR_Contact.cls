/**
 * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
 * @date 14/01/2021
 * @description HDT_QR_Contact.cls
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */
public inherited sharing class HDT_QR_Contact {
    
    /**
    * @description getRecordById
    * @param id
    * @return Contact
    */
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
            AccountId,
            CreatedDate
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

    /**
    * @description getRecordsById
    * @param ids
    * @return List<Contact>
    */
    public List<Contact> getRecordsById(List<String> ids) {

        List<Contact> contacts = Database.query('SELECT Firstname, accountId, LastName, IndividualId,Company__c,CompanyOwner__c  FROM Contact WHERE Id IN :ids WITH SECURITY_ENFORCED'); //HRAWRM-588_code_review_1550
        return contacts;
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 14/01/2021
    * @description Get Account primary Contact
    * @param accountId
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
    * @param accountId
    * @return List<Contact>
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
    
    /**
    * @description getContactsByIndividual
    * @param individualId
    * @return Contact
    */
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

    /**
    * @description getContactsIdByAccountId
    * @param accountId
    * @return List<String>
    */
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
    
    /**
    * @description getContactsIdByAccountIdList
    * @param accountIds
    * @return List<Contact>
    */
    public List<Contact> getContactsIdByAccountIdList(List<String> accountIds) {

        return [SELECT Id, CertifiedEmail__c, AccountId, Firstname, Lastname, FiscalCode__c, Phone, MobilePhone, Email, IndividualId, Individual.ProfilingCompanyConsent__c
                FROM Contact WHERE AccountId IN : accountIds WITH SECURITY_ENFORCED];
    }

    // INIZIO SVILUPPI EVERIS

    /**
    * @description getRecordsByIds
    * @param ids
    * @return List<Contact>
    */
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
            Individual.OneshotBlacklist__c,
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

    /**
    * @description getRecordByFiscalCode
    * @param fiscalCode
    * @return Contact
    */
    public Contact getRecordByFiscalCode(String fiscalCode) {
        List<Contact> contacts = Database.query('SELECT  Id, Email , MobilePhone , Phone FROM Contact WHERE FiscalCode__c = :fiscalCode WITH SECURITY_ENFORCED');
        if(contacts.size()>0){
            return contacts[0];
        }else{
            return null;

        }
    }

    /**
    * @description getContactsByOwnerId
    * @param ownerId
    * @param ownerName
    * @return List<Contact>
    */
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

    /**
    * @description getContactCoordinates
    * @param contactId
    * @return Contact
    */
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

    /**
    * @description getContactByEmailAddress
    * @param fromEmail
    * @return List<Contact>
    */
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
     * @param individualId Id of the individual to filter the Leads
     * @param fields fields to retrieve separated by ,
     * @return List<Contact>
     */
    public List<Contact> getRecordByIndividual(String individualId, String fields) {
        List<Contact> contacts = Database.query('SELECT '+ String.escapeSingleQuotes(fields) + ' FROM Contact WHERE IndividualId = :individualId WITH SECURITY_ENFORCED');
        
        SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE, contacts);

        return decision.getRecords();

    }
    public List<Contact> getContactList(String filter){
        HDT_QR_Helper qrHelper=new HDT_QR_Helper();
        qrHelper.setObj('Contact');
        qrHelper.setFilter(filter);
        return (List<Contact>)qrHelper.getListSObject();

    }

    public List<Contact> getContactByAccountIdConsumoAnomaloMassivo(Set<Id> accountId){
        return [SELECT Id,AccountId,Phone,MobilePhone,Account.PrimaryEmail__c,Email	FROM Contact WHERE AccountId IN: accountId WITH SECURITY_ENFORCED ];
    }
}