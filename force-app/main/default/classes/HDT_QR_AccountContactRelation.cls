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
            SELECT ContactId,
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
            ContactId, 
            Roles
            FROM AccountContactRelation 
            WHERE 
            AccountId = :accountId 
            WITH SECURITY_ENFORCED
        ];

    }

    public List<AccountContactRelation> getPrimaryContactRelations(Set<Id> ids) {
    
        return [
            SELECT 
            AccountId,
            ContactId, 
            Roles
            FROM AccountContactRelation 
            WHERE AccountId IN :ids
            AND Roles  = 'Titolare'
            WITH SECURITY_ENFORCED
        ];

    }

    public AccountContactRelation getPrimaryContactRelation(Id accountId) {
    
        List<AccountContactRelation> relations = [
            SELECT 
            AccountId,
            ContactId, 
            Roles
            FROM AccountContactRelation 
            WHERE AccountId = :accountId
            AND Roles  = 'Titolare'
            WITH SECURITY_ENFORCED
        ];

        if (relations.size() > 0) {
            return relations[0];
        }

        return null;
    }

    public List<AccountContactRelation> getAdministratorRelations() {
    
        return [
            SELECT 
            AccountId,
            ContactId, 
            Roles
            FROM AccountContactRelation 
            WHERE Roles INCLUDES ('Amministratore condominio')
            WITH SECURITY_ENFORCED
        ];

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
            WITH SECURITY_ENFORCED
        ];
    }

    // FINE SVILUPPI EVERIS

}
