public inherited sharing class HDT_QR_Contact {
    
    public Contact getRecordById(String id) {

        return [
            SELECT
            LastName
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
    public Contact getPrimaryContactByAccount(String accountId){
        return [
            SELECT
            Email
            FROM Contact
            WHERE AccountId = :accountId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
    }
}