/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 25/02/2021
* @description HDT_QR_AccountContactRelation – Contains queries for AccountContactRelation
* @history Keltin Mesonjesi – 25/02/2021 – Created class
*/
public inherited sharing class HDT_QR_AccountContactRelation {
    
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
}
