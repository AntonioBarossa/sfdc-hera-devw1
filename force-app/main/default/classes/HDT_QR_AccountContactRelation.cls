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
}
