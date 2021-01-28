/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 22/01/2021
* @description HDT_QR_Contract – Contains queries for Contract
* @history Keltin Mesonjesi – 22/01/2021 – Created class
*/
public inherited sharing class HDT_QR_Contract {
    
    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description Get active records by accountId
    * @param String accountId
    * @return List<Contract>
    */
    public List<Contract> getActiveRecordsByAccountId(String accountId){
        return [
            SELECT
            Name,
            AccountId,
            ContractNumber,
            Status 
            FROM
            Contract
            WHERE AccountId = :accountId
            AND Status = 'Activated'
            WITH SECURITY_ENFORCED
        ];
    }
}
