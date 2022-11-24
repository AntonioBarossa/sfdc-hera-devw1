/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 25/02/2021
* @description HDT_QR_AccountContactRelation – Contains queries for AccountContactRelation
* @history Keltin Mesonjesi – 25/02/2021 – Created class
*/
public inherited sharing class HDT_QR_AccountContactRelation {
     
    public List<AccountContactRelation> getAccountContactRelation(Id accountId, Id contactId, String fields){
        String query= 'Select '+fields+ ' FROM AccountContactRelation WHERE AccountId = :accountId And ContactId = :contactId';
        List<AccountContactRelation> listAccCon= Database.query(query);

        return listAccCon;
    }
    public List<AccountContactRelation> getAccountContactRelation(List<String> accountId, List<String> contactId, String fields){
        String query= 'Select '+fields+ ' FROM AccountContactRelation WHERE AccountId IN :accountId And ContactId IN :contactId';
        List<AccountContactRelation> listAccCon= Database.query(query);

        return listAccCon;
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Get records filtered by account and contact
     * @param String accountId
     * @param String contactId
     * @return List<AccountContactRelation>
     */
    public List<AccountContactRelation> getRecordsFilteredByAccountAndContact(String accountId, String contactId){

        return [
            SELECT
            Roles
            FROM AccountContactRelation
            WHERE AccountId = :accountId
            AND ContactId = :contactId
            WITH SECURITY_ENFORCED
        ];
    }


    public List<AccountContactRelation> getRecordByAccountId(String accountId){

        return [
            SELECT 
            Id,Contact.name,Roles,Contact.HomePhone,
            ContactId,Contact.Phone,
            Contact.MobilePhone,
            Contact.Email
            FROM AccountContactRelation
            WHERE AccountId = :accountId
            AND IsActive = true
            AND IsDirect = true
            WITH SECURITY_ENFORCED
        ];


    }


    // INIZIO SVILUPPI EVERIS

    public List<AccountContactRelation> getContactsByAccountWithRoles(String accountId) {
    
        return [
            SELECT 
            Id, AccountId,Contact.name,Roles,Contact.HomePhone,
            ContactId,Contact.Phone,
            Contact.MobilePhone,
            Contact.Email,Contact.IndividualId,Contact.BPInterlocutor__c,EndDate,StartDate, Contact.ContactCode__c
            FROM AccountContactRelation 
            WHERE 
            AccountId = :accountId 
            WITH SECURITY_ENFORCED
        ];

    }
    public List<AccountContactRelation> getContactsByAccountWithRoles(List<Id> accountIds) {
    
        return [
            SELECT 
            Id, AccountId,Contact.name,Roles,Contact.HomePhone,
            ContactId,Contact.Phone,
            Contact.MobilePhone,
            Contact.Email,Contact.IndividualId
            FROM AccountContactRelation 
            WHERE 
            AccountId IN:accountIds 
            WITH SECURITY_ENFORCED
        ];

    }

    public List<AccountContactRelation> getPrimaryContactRelations(Set<Id> ids) {
    
        return [
            SELECT 
            AccountId,
            Account.CompanyOwner__c,
            ContactId, 
            Roles
            FROM AccountContactRelation 
            WHERE AccountId IN :ids
            AND Roles INCLUDES ('Titolare')
            AND IsActive = True
            WITH SECURITY_ENFORCED
        ];

    }

    public List<AccountContactRelation> getPrimaryRelationsByContacts(Set<Id> contactIds) {

        return [
            SELECT 
            AccountId,
            ContactId, 
            Roles
            FROM AccountContactRelation 
            WHERE ContactId IN :contactIds
            AND Roles INCLUDES ('Titolare')
            AND IsActive = True
            WITH SECURITY_ENFORCED
        ];

    }

    public AccountContactRelation getPrimaryContactRelation(Id accountId) {
    
        List<AccountContactRelation> relations = [
            SELECT 
            AccountId,
            ContactId,
            Contact.MobilePhone,
            Contact.Email,
            Roles
            FROM AccountContactRelation 
            WHERE AccountId = :accountId
            AND Roles INCLUDES ('Titolare')
            AND IsActive = True
            WITH SECURITY_ENFORCED
        ];

        if (relations.size() > 0) {
            return relations[0];
        }

        return null;
    }

    
    public AccountContactRelation getLegalRepresentativeRelation(Id accountId) {
    
        List<AccountContactRelation> relations = [
            SELECT 
            AccountId,
            ContactId,
            Contact.MobilePhone,
            Contact.Email,
            Roles
            FROM AccountContactRelation 
            WHERE AccountId = :accountId
            AND Roles INCLUDES ('Legale rappresentante')
            AND IsActive = True
            WITH SECURITY_ENFORCED
        ];

        if (relations.size() > 0) {
            return relations[0];
        }

        return null;
    }

    // Restituisce l'ACR del Legale Rappresentante se presente, altrimenti restituisce quella del Titolare.
    public AccountContactRelation getPrimaryContactRelationBusiness(Id accountId) {
    
        AccountContactRelation legalAcr = getLegalRepresentativeRelation(accountId);
        if (legalAcr != null ) {
            return legalAcr;
        }

        return getPrimaryContactRelation(accountId);
    }

    public List<AccountContactRelation> getAdministratorRelations() {
    
        return [
            SELECT 
            AccountId,
            ContactId, 
            Roles
            FROM AccountContactRelation 
            WHERE Roles INCLUDES ('Amministratore condominio')
            AND IsActive = True
            WITH SECURITY_ENFORCED
        ];

    }

    public AccountContactRelation getActiveAdministratorRelation(String accountId) {
    
        List<AccountContactRelation> relations = [
            SELECT
            Id,
            AccountId,
            ContactId, 
            Roles
            FROM AccountContactRelation 
            WHERE Roles INCLUDES ('Amministratore condominio')
            AND IsActive = True
            AND AccountId = :accountId
            WITH SECURITY_ENFORCED
        ];

        if (relations.size() > 1) {
            System.debug('ATTENZIONE: Account associato contemporaneamente a più amministratori di condominio: ' + accountId);
        }

        if (relations.size() > 0) {
            return relations[0];
        }

        return null;

    }

    public List<AccountContactRelation> getSolContactRelations(String accountId) {
    
        return [
            SELECT
            Id,
            AccountId,
            ContactId,
            Roles
            FROM AccountContactRelation
            WHERE
            AccountId = :accountId
            AND IsManagerSOL__c = True
            AND IsActive = True
            WITH SECURITY_ENFORCED
        ];
    }

    public List<AccountContactRelation> getSolContactRelation(String accountId, String contactId) {
    
        return [
            SELECT
            Id,
            AccountId,
            ContactId,
            Roles
            FROM AccountContactRelation
            WHERE
            AccountId = :accountId
            AND ContactId = :contactId
            AND IsManagerSOL__c = True
            AND IsActive = True
            WITH SECURITY_ENFORCED
        ];
    }

    public List<AccountContactRelation> getRelatedAccounts(Id contactId) {

        return [
            SELECT 
            AccountId,
            Account.Name,
            Account.FirstName__c,
            Account.LastName__c,
            Account.FiscalCode__c,
            Account.VATNumber__c,
            Account.CustomerCode__c,
            ContactId, 
            Roles
            FROM AccountContactRelation 
            WHERE ContactId = :contactId
            AND IsActive = True
            WITH SECURITY_ENFORCED
        ];

    }

    // FINE SVILUPPI EVERIS

    /**@frpanico 17/01/2022
     * Aggiunto metodo per servizio Crea BpCa
     */
    public List<AccountContactRelation> getCreateBpCa(String accountId)
    {
        return 
        [
        SELECT Id,
        Roles
        FROM AccountContactRelation
        WHERE Roles INCLUDES ('Titolare','Familiare','Amministratore condominio','Legale rappresentante')
        AND AccountId = :accountId
        WITH SECURITY_ENFORCED
        ];
    }

    public static List<AccountContactRelation> getAccountContactData(String acrId)
    {
        return 
        [
        SELECT AccountId,
        Account.Name,
        Account.FirstName__c,
        Account.LastName__c,
        Account.RecordTypeId,
        Account.Category__c,
        Account.Fax,
        Account.CustomerMarking__c,
        Account.FiscalCode__c,
        Account.VatNumber__c,
        Account.BillingCity,
        Account.BillingCountry,
        Account.BillingPostalCode,
        Account.BillingState,
        Account.BillingStreetNumber__c,
        Account.BillingStreetName__c,
        Account.CustomerCode__c,
        Account.MobilePhone__c,
        Account.BuildingFloor__c,
        Account.PrimaryEmail__c,
        Account.VATGroup__c,
        Account.VATGroupStartDate__c,
        Account.VATGroupEndDate__c,
        //Account.BillingStreetToponym__c,
        ContactId,
        Contact.MobilePhone,
        Contact.CertifiedEmail__c,
        Contact.Email,
        Contact.Phone,
        Contact.ContactCode__c,
        Roles
        FROM AccountContactRelation
        WHERE Id = :acrId
        WITH SECURITY_ENFORCED
        ];
    }

}
