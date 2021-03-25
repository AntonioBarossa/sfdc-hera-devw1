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
}